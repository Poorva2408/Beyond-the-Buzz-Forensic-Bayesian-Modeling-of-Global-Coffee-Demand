# Analysing-Google-Trend-for-Coffee-
## Executive summary 
Roughly 1 billion people worldwide drink coffee regularly, with an estimated 2.25 billion cups consumed every day. Coffee is the second most consumed beverage globally after water, with around 30-35% of the global population drinking it, largely driven by high consumption in the U.S. and Europe.

This analysis investigates the dynamic search interest for the term "Coffee" using Google Trends data from 2017 through mid-2026 and provide next year forcast.
The primary objective was to decompose this highly non-stationary and seasonal time series into its core structural drivers—long-term growth, annual periodicity, and short-term momentum—using a Normal Dynamic Linear Model (NDLM).

By applying the principle of superposition, the model successfully isolated the underlying market trajectory from significant observational noise, providing a mathematically grounded framework for understanding and forecasting digital consumer behavior.

The modeling process utilized a Bayesian framework to estimate unknown system and observational variances. The final architecture combined a second-order polynomial trend, two trigonometric seasonal harmonics ($q=2$), and a stationary AR(2) process to capture short-term correlations. 

Through a grid search, a discount factor of $\delta = 0.97$ was identified as optimal, minimizing the Mean Squared Error (MSE) to 60.36 and yielding a Root Mean Squared Error (RMSE) of 7.77. 
Results confirm a robust, stochastic upward trend in coffee interest that has accelerated since 2021, coupled with a highly regular seasonal "pulse" that peaks annually in December and January. 
The 20-month forecast predicts continued baseline growth through 2026, offering high-resolution insights into the persistent and predictable nature of global coffee demand.

## Introduction 
This project implements a Normal Dynamic Linear Model (NDLM) to analyze and forecast global search interest for the term "Coffee" (via Google Trends). In the context of digital consumer behavior, search data is characterized by high volatility, non-stationary growth, and strong annual periodicity.The primary objective is to decompose the raw signal into its latent components—Long-term Trend, Trigonometric Seasonality, and Short-term Autoregressive Momentum—using the Superposition Principle. To handle the uncertainty of internet-scale data, the model utilizes a Bayesian framework with unknown observational variance and a system covariance matrix optimized through discount factors ($\delta = 0.97$).The result is a robust, adaptive forecasting tool capable of filtering noise to reveal the underlying structural growth of the coffee market through 2026.

<p align="center">
  <img src="path/to/decomposition_plot.png" width="80%">
</p>

