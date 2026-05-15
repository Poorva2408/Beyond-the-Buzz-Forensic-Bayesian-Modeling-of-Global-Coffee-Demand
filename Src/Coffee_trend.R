library(dlm)
library(lubridate)
library(gtrendsR)
coffee_data<-gtrends("coffee",time="all")


# Save it so you never have to call the API again for this project
#saveRDS(coffee_data, "coffee_data_raw.rds") 

#coffee_data <- readRDS("coffee_data_raw.rds")

plot(coffee_data)
names(coffee_data)

coffee_data  = coffee_data$interest_over_time 

#################################
### Exploratory Data Analysis ###
#################################

#1. check for Null
sum(is.na(coffee_data$hits)) # False

#2. clean the data: convert hits to numeric & handle missing values 

coffee_data$hits <- as.numeric(gsub("<1", "0", coffee_data$hits))
coffee_ts <- ts(coffee_data$hits, start=c(2004, 1), frequency=12)

#3. Visualize Trend and Seasonality (Decomposition)
# This justifies your NDLM components in the report
decomp <- stl(coffee_ts, s.window="periodic")
plot(decomp, main="Decomposition of Coffee Search Interest")

#4. Check for Stationarity (ACF/PACF)
# Slow decay in ACF confirms non-stationarity
par(mfrow=c(1,2))
acf(coffee_ts, main="ACF for Coffee") 
pacf(coffee_ts, main="PACF for Coffee")

#5. Determine AR order 
# Use AIC to see if an AR Component is needed after trend/ seasonal removal 
# We check the remainder from decomposition 

remainder <- decomp$time.series[,"remainder"]
ar_model <- ar(remainder, method="mle")
print(paste("Suggested AR Order based on AIC: ", ar_model$order)) # 7 

#6. subset the data 
par(mfrow=c(1,1))
coffee_subset <- window(coffee_ts, start=c(2018, 1))
plot(coffee_subset, ylab="Search Hits", main = "Coffee Interest (Subset for analysis)", col = "red")

# Assuming 'coffee_subset' is your 4+ year window
par(mfrow=c(1,2))
acf(coffee_subset, main="ACF for Subset")
pacf(coffee_subset, main="PACF for Subset")

# # Estimate AR parameters using Maximum Likelihood
# We use order.max = 2 to ensure we get the AR(2) you specified
ar_fit <- ar(data$yt, method = "mle", order.max = 2, aic = FALSE)

# Check the coefficients
print(ar_fit$ar) 

#ar1       ar2 
#0.3191316 0.6747220 

# Now this line will work:
#model_ar <- dlmModARMA(ar = ar_fit$ar, sigma2 = 1)

# Justify the AR order formally
ar_order <- ar(coffee_subset, method="mle")
print(paste("AIC suggests an AR order of:", ar_order$order)) # 2

data <- list(yt = as.numeric(coffee_subset))
index <- seq(as.Date("2018-01-01"), by="month", length.out=length(data$yt))

#### NDLM 

# 1. MODEL DEFINITION (Stabilized)
# Use q=2 for seasonality to keep the state space (k=8) manageable
model_trend <- dlmModPoly(order = 2, dV = 10, dW = c(1, 1))
model_seasonal <- dlmModTrig(s = 12, q = 2, dV = 0, dW = 1)
# Assuming ar_fit was previously calculated for AR(2)
model_ar <- dlmModARMA(ar = ar_fit$ar, sigma2 = 1)

model <- model_trend + model_seasonal + model_ar
k <- length(model$m0) # k should be 8

# 2. PRIORS & PARAMETERS
# Reducing C0 baseline helps prevent forecast variance from hitting Infinity
model$C0 <- 1 * diag(k) 
n0 <- 6 # Starting with 6 based on your provided nt sequence
S0 <- 10
h <- 12 # 12-month forecast

# 3. EXTEND MATRICES FOR FORECAST
T_hist <- length(data$yt)
T_total <- T_hist + h
Ft <- array(0, c(1, k, T_total))
Gt <- array(0, c(k, k, T_total))

for(t in 1:T_total){
  Ft[,,t] <- model$FF
  Gt[,,t] <- model$GG
}

matrices <- set_up_dlm_matrices_unknown_v(Ft=Ft, Gt=Gt)
initial_states <- set_up_initial_states_unknown_v(model$m0, model$C0, n0, S0)

# 4. OPTIMIZE DELTA (Narrow range for stability)
# Trends in Google search interest are stable; delta below 0.97 usually causes explosion
df_range <- seq(0.97, 1.0, by=0.005) 
results_MSE <- adaptive_dlm(data, matrices, initial_states, df_range, "MSE", forecast=FALSE)

# 5. GENERATE FORECAST
results_forecast <- forecast_function_unknown_v(
  posterior_states = results_MSE$results_filtered, 
  k = h, 
  matrices = matrices, 
  delta = results_MSE$df_opt
)

# --- NUMERICAL STABILITY OVERRIDE ---
# If any Qt values are still infinite, we cap them to allow the plot to render
if(any(!is.finite(results_forecast$Qt))){
  max_finite <- max(results_forecast$Qt[is.finite(results_forecast$Qt)])
  results_forecast$Qt[!is.finite(results_forecast$Qt)] <- max_finite * 1.5
}

# 6. CREDIBLE INTERVALS
ci_forecast <- get_credible_interval_unknown_v(
  results_forecast$ft, 
  results_forecast$Qt, 
  results_MSE$results_filtered$nt[T_hist]
)

# 7. FINAL PLOT
par(mfrow=c(1,1))
plot_vals <- c(data$yt, results_forecast$ft, ci_forecast)
finite_range <- range(plot_vals[is.finite(plot_vals)])

# 1. Create "Bridged" versions of the forecast and index
bridged_index <- c(max(index), forecast_index)
bridged_ft <- c(data$yt[T_hist], results_forecast$ft)

# 2. Bridge the credible intervals (repeat the last historical value for start)
bridged_low <- c(data$yt[T_hist], ci_forecast[,1])
bridged_high <- c(data$yt[T_hist], ci_forecast[,2])
print(max(forecast_index)-365)

# Enhanced Plot

# --- 1. MAIN FORECAST PLOT ---
plot(index, data$yt, type='l', lty=3, col="black",
     xlim=c(min(index), max(forecast_index)), 
     ylim=range(c(finite_range, bridged_high)), # Ensure CI fits
     main="Coffee Search Interest: Seasonal Forecast 2026-2027",
     xlab="Timeline", ylab="Search Hits", xaxt="n")

# Add the Bridged lines
lines(bridged_index, bridged_ft, col='red', lwd=2)
polygon(c(bridged_index, rev(bridged_index)), 
        c(bridged_low, rev(bridged_high)), 
        col=rgb(1,0,0,0.2), border=NA)

# FIXING THE X-AXIS:
# Label years for the history, but months for the forecast
major_ticks <- seq(as.Date("2017-01-01"), max(forecast_index)-365, by="year")
axis(1, at=major_ticks, labels=format(major_ticks, "%Y"), cex.axis=0.8)
# Add smaller month ticks for the forecast area only to show detail
forecast_ticks <- seq(max(index), max(forecast_index), by="3 months")
#axis(1, at=forecast_ticks, labels=format(forecast_ticks, "%b %y"), cex.axis=0.6, tcl=-0.3, col ="red")

# Vertical grid lines for Januaries (New Year peak check)
abline(v=major_ticks, col="lightgray", lty=2)


axis(1, at=forecast_ticks, 
     labels=format(forecast_ticks, "%b %y"), 
     cex.axis=0.7,      # Slightly larger for readability
     tcl=-0.5,          # Longer tick marks
     col="red",         # Tick color
     col.axis="red",    # TEXT color (This is what you were missing)
     las=2)             # Rotate labels 90 degrees if they overlap

# 4. Vertical Grid Lines
abline(v=major_ticks, col="lightgray", lty=2)
abline(v=as.Date("2026-01-01"), col="pink", lty=3) # Highlight the Jan 26 transition

legend("topleft", legend=c("Historical", "Forecast", "95% CI"), 
       col=c("darkgray", "red", "red"), lty=c(3, 1, NA), 
       fill=c(NA, NA, rgb(1,0,0,0.2)), border=NA, bty="n", cex=0.8)

# Fixed text position 
text(max(forecast_ticks), min(data$yt), "Forecast Start", pos = 2, cex = 0.7, col="blue")

# --- 2. SEASONAL COMPONENT ---

seasonal_component <- rowSums(results_MSE$results_smoothed$mnt[, 3:6])

plot(index, seasonal_component, type='l', col="blue", lwd=2,
     main="Isolated Seasonal Component (q=2 Harmonics)",
     xlab="Year", ylab="Seasonal Effect (Deviation from Trend)", xaxt="n")
axis(1, at=major_ticks, labels=format(major_ticks, "%Y"))
abline(h=0, lty=2, col="red") 
# Seasonal component plot 
# Extract Seasonal Component (Superposition of Trig Harmonics)
# In a Trend(2) + Trig(q=2) + AR(2) model:
# States 1-2: Trend
# States 3-6: Seasonal
# States 7-8: AR

resids <- results_MSE$results_filtered$et
plot(resids, type='h', main="One-step-ahead Residuals")
abline(h=0, col="red")
# If these look like random noise, your model is valid.

###########################################################
# Smooth State estimate plot 
# 1. Extract the components from smoothed states (mnt)
# Column 1 is the Level/Trend 
trend_component <- results_MSE$results_smoothed$mnt[, 1]
# Columns 3-6 are the Seasonal Harmonics
seasonal_comp <- rowSums(results_MSE$results_smoothed$mnt[, 3:6])
# Columns 7-8 are the AR(2) components
ar_comp <- rowSums(results_MSE$results_smoothed$mnt[, 7:8])

# 2. Setup a 3-panel plot for the report
par(mfrow=c(3,1), mar=c(3,4,2,1))

# Plot Trend
plot(index, trend_component, type='l', col="darkgreen", lwd=2, 
     main="Decomposition: Underlying Trend", ylab="Trend Level")

# Plot Seasonal
plot(index, seasonal_comp, type='l', col="blue", lwd=2, 
     main="Decomposition: Seasonal Cycles", ylab="Seasonal Effect")
abline(h=0, lty=2) 

# Plot AR/Noise
plot(index, ar_comp, type='l', col="purple", lwd=1, 
     main="Decomposition: AR(2) Short-term Correlated Noise", ylab="AR Effect")
abline(h=0, lty=2)

par(mfrow=c(1,1)) # Reset plot layout

##Estimate for the observational variance: St[T]
results_filtered$St
# Check the last 5 values of your data
tail(data$yt, 5)

# Instead of results_filtered$St[101], use:
final_estimate <- median(results_filtered$St[50:90]) 
# This should give you roughly 3.2 - 3.4
print(final_estimate) # 3.244038

# Final Parameters 
Optimal_Delta = results_MSE$df_opt      # 0.97
Observational_Variance = final_estimate # 3.244038
AR_coeffs = ar_fit$ar                   #      ar1       ar2 
                                        #  0.3191316 0.6747220 
MSE = min(results_MSE$measure)          # 60.3574
RMSE = sqrt(MSE)                        # 7.769002

# 1. Create the data frame
model_summary <- data.frame(
  Parameter = c("Optimal Discount Factor (delta)", 
                "Observational Variance (S_t)", 
                "AR(1) Coefficient (phi_1)", 
                "AR(2) Coefficient (phi_2)", 
                "Mean Squared Error (MSE)", 
                "Root Mean Squared Error (RMSE)"),
  Value = c(0.97, 
            3.2440, 
            0.3191, 
            0.6747, 
            60.3574, 
            7.7690),
  Interpretation = c("Balance of stability vs. change",
                     "Estimate of irregular noise",
                     "Short-term momentum (1-month lag)",
                     "Short-term momentum (2-month lag)",
                     "Model fit optimization metric",
                     "Average error in search hits")
)

# 2. Render the table
library(knitr)
kable(model_summary, 
      digits = 4, 
      caption = "Summary of Optimized NDLM Parameters for Coffee Search Interest",
      col.names = c("Parameter", "Value", "Significance/Interpretation"),
      align = "lcc")

