# Beyond the Buzz: Forensic Bayesian Modeling of Global Coffee Demand
## Executive summary 
Roughly 1 billion people worldwide drink coffee regularly, with an estimated 2.25 billion cups consumed every day. Coffee is the second most consumed beverage globally after water, with around 30-35% of the global population drinking it, largely driven by high consumption in the U.S. and Europe.

This analysis investigates the dynamic search interest for the term "Coffee" using Google Trends data from 2017 through mid-2026 and provide next year forecast.
The primary objective was to decompose this highly non-stationary and seasonal time series into its core structural drivers—long-term growth, annual periodicity, and short-term momentum—using a Normal Dynamic Linear Model (NDLM).

By applying the principle of superposition, the model successfully isolated the underlying market trajectory from significant observational noise, providing a mathematically grounded framework for understanding and forecasting digital consumer behavior.

The modeling process utilized a Bayesian framework to estimate unknown system and observational variances. The final architecture combined a second-order polynomial trend, two trigonometric seasonal harmonics ($q=2$), and a stationary AR(2) process to capture short-term correlations. 

Through a grid search, a discount factor of $\delta = 0.97$ was identified as optimal, minimizing the Mean Squared Error (MSE) to 60.36 and yielding a Root Mean Squared Error (RMSE) of 7.77. 
Results confirm a robust, stochastic upward trend in coffee interest that has accelerated since 2021, coupled with a highly regular seasonal "pulse" that peaks annually in December and January. 
The 20-month forecast predicts continued baseline growth through 2026, offering high-resolution insights into the persistent and predictable nature of global coffee demand.

## Introduction 
The Problem: Google Trends data provides invaluable insights into consumer behavior, but it is notoriously "noisy" and "non-stationary." The search interest for a global commodity like coffee does not possess a constant mean or variance; it is subject to sudden viral shocks, shifting baselines, and erratic short-term fluctuations.

The Goal: The primary objective of this analysis is to perform a structural decomposition of the "Coffee" time series. The aim is to isolate the true, underlying "growth" of market interest from the predictable "seasonal wiggles" and the unpredictable "short-term noise."

The Process: To achieve this high-resolution extraction, the analysis employs a Normal Dynamic Linear Model (NDLM). The methodology transitions from standard Maximum Likelihood Estimation (MLE) used to identify autoregressive parameters to a full Bayesian Filtering and Smoothing approach. Crucially, the model utilizes discount factors to adaptively handle the system's unknown covariance matrices, ensuring the forecast remains mathematically grounded even when historical patterns shift.
<p align="center">
  <img src="/Figures/Fig1 Interest Over Time.png" width="80%">
  <br>
  <b>Figure 1:</b> Coffee Trend 2004 - 2026
</p>

## Data Description & Exploratory Data Analysis (EDA)

The Data: The dataset comprises over 100 continuous monthly observations of the search term "Coffee," indexed from January 2017 to May 2025.

The Patterns: Exploratory analysis reveals two dominant visual features: a persistent annual cycle and a distinct "structural break." Prior to 2020, baseline interest grew linearly; however, around 2021, the data exhibits a clear acceleration, establishing a higher, more volatile baseline.

Stationarity Check: A preliminary review confirms the raw series is strictly non-stationary, invalidating standard ARMA approaches. The presence of a shifting baseline justifies the implementation of a 2nd-order Polynomial Trend (a Local Linear Trend model) within the NDLM framework, allowing the model to mathematically track both the level and the growth rate of coffee interest rather than forcing a reversion to a simple flat mean.
<p align="center">
  <img src="/Figures/Fig 2 ACF PACF.png" width="80%">
  <br>
  <b>Figure 2:</b> ACF PACF for Coffee Trend 2004 - 2026
</p>

<p align="center">
  <img src="/Figures/Fig 3 Subset.png" width="80%">
  <br>
  <b>Figure 3:</b> Coffee Trend 2018 - 2026
</p>
<p align="center">
  <img src="/Figures/Fig 4 ACF PACF sub.png" width="80%">
  <br>
  <b>Figure 4:</b> ACF PACF for Coffee Trend 2018 - 2026
</p>

## Methods & Model Building 
By leveraging the Superposition Principle, the time series was modeled as a linear combination of independent latent components. 
The complete state vector contains 8 unobservable states: 

  $$\theta_t = \begin{bmatrix} \theta_{Trend} \\ \theta_{Seasonal} \\ \theta_{AR} \end{bmatrix}$$

Superposition Principle: The state-space matrix was constructed by stacking a 2nd-order polynomial trend (2 states), a trigonometric seasonal component with two harmonics ($q=2$, providing 4 states to capture the wave), and a stationary autoregressive component (2 states).

AR Identification: To capture the short-term momentum and correlation in the noise, an autoregressive process was fitted to the detrended data.
Using the Maximum Likelihood Estimation method (ar(method="mle")), an AR(2) process was identified as optimal, yielding coefficients

$\phi_1 = 0.3191$ and $\phi_2 = 0.6747$.

Variance Estimation: In real-world internet data, observational noise is rarely known. 
The observational variance ($S_t$) was treated as unknown but constant. Through Bayesian conjugate analysis, the filtered variance converged to a stable estimate of approximately 

3.24.Optimization: To define the unknown system covariance matrices without overfitting, the model was optimized using a grid search over a range of Discount Factors ($\delta$). 
A discount factor of $\delta = 0.97$ was selected, as it successfully minimized the Mean Squared Error (MSE) to 60.35.
This hyperparameter choice provides the optimal balance between adapting to new data shocks and preserving historical stability.

## Mathematical Framework 

The analysis is driven by the standard State-Space formulation of the Normal Dynamic Linear Model:

Observation Equation:
$$y_t = F_t' \theta_t + v_t, \quad v_t \sim N(0, V)$$
Where $y_t$ is the observed search volume, $F_t$ is the design matrix, $\theta_t$ is the latent state vector, and $V$ is the unknown constant observational variance.

System (Evolution) Equation:
$$\theta_t = G_t \theta_{t-1} + w_t, \quad w_t \sim N(0, W_t)$$
Where $G_t$ is the evolution matrix advancing the states, and $w_t$ is the system evolution noise.

Variance Discounting:Instead of specifying the highly complex system covariance matrix $W_t$ manually, it is defined adaptively using the optimized discount factor $\delta \in (0, 1]$: $$W_t = \frac{1-\delta}{\delta} P_{t-1}$$ Where $P_{t-1}$ 
is the posterior variance matrix from the previous time step, ensuring the uncertainty scales proportionately with the state estimation.

### Model Parameters & Optimization Results

| Parameter | Value | Significance / Interpretation |
| :--- | :--- | :--- |
| **Optimal Discount Factor ($\delta$)** | 0.9700 | Balance of stability vs. recent change |
| **Observational Variance ($S_t$)** | 3.2440 | Estimate of stable irregular noise |
| **AR(1) Coefficient ($\phi_1$)** | 0.3191 | Short-term momentum (1-month lag) |
| **AR(2) Coefficient ($\phi_2$)** | 0.6747 | Short-term momentum (2-month lag) |
| **Mean Squared Error (MSE)** | 60.3574 | Model fit optimization metric |
| **Root Mean Squared Error (RMSE)** | 7.7690 | Average error in search hits |

## Results & Discussion 

### State Decomposition: 
<p align="center">
  <img src="/Figures/Fig 8 Smoothed Decomp.png" width="80%">
  <br>
  <b>Figure 5:</b> State Decomposition
</p>
The structural decomposition successfully unbundled the complex signal. The top panel isolates the "Growth"—demonstrating the smooth, stochastic upward trajectory of the baseline trend. The middle panel isolates the "Pulse"—the $q=2$ harmonic wave proving that the seasonal amplitude remains consistent despite the rising trend.

### Residual Analysis: (Insert One-Step-Ahead Residual Plot Here)
A critical audit of the model's validity lies in its errors. The one-step-ahead residuals behave as a stationary white noise process, fluctuating randomly around zero with no discernible autocorrelation. This confirms the model is statistically valid and that the Trend, Seasonal, and AR components have successfully extracted all available systematic information from the data.

<p align="center">
  <img src="Figures/Fig 6  Seasonal Effect Resid plot.png" width="80%">
  <br>
  <b>Figure 7:</b> Isolated Seasonal Component 
</p>


<p align="center">
  <img src="/Figures/Fig 7 Resid plot.png" width="80%">
  <br>
  <b>Figure 6:</b> Residual Analysis
</p>


### Forecasting :
<p align="center">
  <img src="/Figures/Fig 5 Coffee trend.png" width="80%">
  <br>
  <b>Figure 8:</b> Forecasting Coffee Trend for May 2026 - May 2027
</p>
The 20-month forecast seamlessly bridges historical data with predictive estimates. The projection shows a continued upward trajectory. Notably, the 95% Credible Intervals (the shaded region) widen appropriately as the forecast extends into 2026 and 2027, accurately representing the increasing mathematical uncertainty inherent in Bayesian forecasting over time. 

## Why NDLM is Preferred:

Structural Decomposition (Superposition): Unlike ARIMA, which treats the series as a single mathematical black box, NDLM follows the Superposition Principle. This allows you to explicitly unbundle the data into independent, interpretable engines: a stochastic trend, trigonometric seasonality, and autoregressive components. You can literally "see" the growth separately from the seasonal pulse.

Bayesian Adaptability: NDLMs operate within a Bayesian framework, allowing parameters to evolve over time. While an OLS model assumes a fixed "global" relationship, the NDLM uses Bayesian filtering and smoothing to update its "beliefs" as new data arrives. This makes it far superior for "noisy" data like Google Trends, where the baseline can shift suddenly (like the 2021 coffee interest acceleration).

Handling Uncertainty: NDLMs provide Credible Intervals rather than simple Confidence Intervals. Because it estimates the full posterior distribution of the states, the model provides a more realistic representation of risk. As you saw in your forecast, the widening "blue fan" accurately reflects how uncertainty compounds the further you look into the future.

Discount Factor Optimization: Instead of forcing the user to specify complex system variances ($W_t$), NDLMs use Discount Factors ($\delta$). This provides a single, elegant hyperparameter (like your $0.97$) to balance the trade-off between "remembering" the long-term history and "adapting" to short-term shocks.

## Conclusions 

Main Finding: Search interest for "Coffee" is not a static habit or a passing digital fad; it exhibits a consistent, stochastic upward trend that has functionally doubled the baseline interest since 2017.

Seasonality: The isolated trigonometric component proves that global consumer behavior regarding coffee is highly periodic. The structural isolation of this wave confirms a significant and predictable "winter spike," with interest consistently peaking in December and January.

The application of the NDLM framework provided a highly robust method for handling the unknown variances of complex systems. By dynamically filtering "noisy" internet data, the optimized model achieved high precision, maintaining an RMSE of less than 8 on a 100-point scale. 
This structural approach transitions raw search data from a reactive metric into a reliable, predictive tool for long-term demand planning.





