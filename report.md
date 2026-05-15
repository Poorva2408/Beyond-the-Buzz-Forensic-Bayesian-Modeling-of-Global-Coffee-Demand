## Beyond the Buzz: Forensic Bayesian Modeling of Global Coffee Demand
### Executive Summary
   Coffee is the world’s second most consumed beverage, trailing only water.
   With ~2.25 billion cups consumed daily, the digital footprint of this commodity is massive yet volatile.
   This analysis applies a Normal Dynamic Linear Model (NDLM) to Google Trends data (2017–2026) to decompose search interest into latent structural drivers.
   By optimizing a Bayesian framework with a discount factor of $\delta = 0.97$, we isolated a robust, stochastic upward trend and a predictable annual seasonal
   "pulse." The model achieved an RMSE of 7.77, providing a high-resolution tool for long-term demand forecasting.
   

### Introduction
Google Trends data is notoriously "noisy." Search interest for global commodities does not possess a constant mean; it is subject to viral shocks and 
shifting baselines. The goal of this "forensic" audit is to move beyond simple curve-fitting. We utilize the Superposition Principle to unbundle the 
"Coffee" time series into its core engines: growth, periodicity, and short-term momentum, ensuring the final forecast is grounded in structural reality 
rather than observational noise.

### Data Description & Exploratory Analysis (EDA)
The dataset comprises monthly observations from Jan 2017 to May 2025.
Structural Break: A distinct acceleration in baseline interest is visible around 2021, establishing a higher volatility floor.
Stationarity: The raw series is strictly non-stationary. ACF/PACF analysis confirms significant lags at 12 months, justifying a trigonometric seasonal 
component and a 2nd-order polynomial trend to track both the level and the growth rate.
<table style="width: 100%; border-collapse: collapse; border: none;">
  <tr style="border: none;">
    <td align="center" style="border: none; width: 50%;">
      <img src="/Figures/Fig1 Interest Over Time.png" width="100%" alt="Model Comparison Audit">
      <br>
      <b>Figure 2:</b> Coffee Trend 2004-2026
    </td>
    <td align="center" style="border: none; width: 50%;">
      <img src="/Figures/Fig 9 Decomposition.png" width="100%" alt="Decomposition">
      <br>
      <b>Figure 3:</b> Decomposition of Coffee Trend
    </td>
   </tr>
</table>

<table style="width: 100%; border-collapse: collapse; border: none;">
  <tr style="border: none;">
    <td align="center" style="border: none; width: 50%;">
      <img src="/Figures/Fig1 Interest Over Time.png" width="100%" alt="Model Comparison Audit">
      <br>
      <b>Figure 2:</b> Coffee Trend 2004-2026
    </td>
    <td align="center" style="border: none; width: 50%;">
      <img src="/Figures/Fig 9 Decomposition.png" width="100%" alt="Decomposition">
      <br>
      <b>Figure 3:</b> Decomposition of Coffee Trend
    </td>
   </tr>
</table>

### Mathematical Framework & Prior Selection
The model follows the standard State-Space formulation:

Observation Equation:
  $$y_t = F_t' \theta_t + v_t, \quad v_t \sim N(0, V)$$
  
System (Evolution) Equation:
  $$\theta_t = G_t \theta_{t-1} + w_t, \quad w_t \sim N(0, W_t)$$

### Prior Specification ($m_0, C_0$)
To ensure the model remains objective, we utilized a Diffuse Prior.
Initial Mean ($m_0$): Set to the first observation for Level; 
$0$ for all other states.
Initial Variance ($C_0$): Initialized with high uncertainty ($\kappa = 10^7$) for trend and seasonal states, allowing the data to dominate the prior quickly.
Observational Variance ($V$): Treated as unknown. 
We used an Inverse-Gamma prior ($n_0=1, S_0=0.01$) to allow for conjugate Bayesian updates of the noise floor.

### Probabilistic Diagnostics (Bayesian Learning)
A core requirement of this audit is proving the model "learns." We evaluate this through the evolution of the filtering and smoothing distributions.
<table style="width: 100%; border-collapse: collapse; border: none;">
  <tr style="border: none;">
    <td align="center" style="border: none; width: 50%;">
      <img src="/Figures/Fig1 Interest Over Time.png" width="100%" alt="Model Comparison Audit">
      <br>
      <b>Figure 2:</b> Coffee Trend 2004-2026
    </td>
    <td align="center" style="border: none; width: 50%;">
      <img src="/Figures/Fig 9 Decomposition.png" width="100%" alt="Decomposition">
      <br>
      <b>Figure 3:</b> Decomposition of Coffee Trend
    </td>
   </tr>
</table>

Evolution of Belief (Filtering)
As the recursive Kalman filter processes data, the posterior distribution of the Trend Level undergoes a visible transformation.
At $t=10$: The distribution is diffuse (wide), indicating high initial uncertainty.
At $t=100$: The distribution is concentrated (narrow and tall). This Posterior Concentration is mathematical proof of Bayesian convergence; 
the model has successfully reduced state uncertainty through evidence accumulation.

The Value of Hindsight (Smoothing)
We compare the Filtered distribution (real-time belief) with the Smoothed distribution (full-sample belief). 
The smoothed estimates consistently exhibit lower variance. 
By utilizing "future" data to refine past estimates, the smoother provides a more precise forensic 
look at the 2021 structural break, correcting for the lags inherent in real-time filtering.

### Results & Discussion
| Parameter | Value | Interpretation |
| :--- | :--- | :--- |
| **Discount Factor (delta)** | 0.97 | Optimal balance of adaptation vs. stability |
| **Noise Floor (S_t)** | 3.24 | Converged estimate of observational error |
| **AR Coefficients (phi_1, phi_2)** | 0.31, 0.67 | Significant short-term momentum |

Structural Decomposition
The Growth (Trend): Isolated a stochastic upward trajectory that has nearly doubled the baseline interest since 2017.
The Pulse (Seasonality): Two trigonometric harmonics ($q=2$) reveal a regular annual "winter spike," peaking every December/January.
Residual Audit: One-step-ahead residuals behave as Gaussian white noise, confirming that all systematic information has been extracted.

### Forecasting & Uncertainty
The 20-month forecast predicts continued baseline growth through 2027. Crucially, the 95% Credible Intervals (the "blue fan") widen as the projection extends. 
This accurately represents the compounding entropy in state-space modeling, providing a realistic risk-assessment framework for stakeholders.

### Conclusion
The NDLM framework successfully transitions "Coffee" search data from a reactive metric to a predictive asset. By leveraging the superposition of trend, 
seasonal, and AR components, we have provided a robust, Bayesian-validated model that accounts for unknown variances and structural shifts. 
This approach confirms that coffee demand is not merely a fad, but a structurally growing global habit.

