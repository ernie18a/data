Calculation: Normalized RAMO = Z-score of risk-adjusted momentum after combining 60% risk-adjusted momentum, 30% linear-regression momentum projected forward, and 10% momentum acceleration; multiply by 1.2 for bullish exhaustion, 0.8 for bearish exhaustion, otherwise 1, then clamp the Z-score to [-3.5, 3.5]. Risk-adjusted momentum is selected price momentum (percentage change, price difference, or log return) multiplied by max(1 − smoothed current drawdown / smoothed maximum drawdown × risk scaling, 0.05). Current drawdown is the decline from the running peak; maximum drawdown is the rolling maximum of that decline. Drawdowns are smoothed with an adaptive EMA whose alpha increases with the volatility percentile. Momentum acceleration is the EMA of the difference between risk-adjusted momentum and its value at a shorter lookback. Linear-regression momentum uses a longer lookback and projects forward.
Calculation: Signal line = adaptive EMA of normalized RAMO, with alpha increasing with the percentile rank of 20-bar price volatility (standard deviation / mean).
Calculation: Dynamic upper/lower thresholds = normalized RAMO's rolling mean plus/minus a multiplier times its rolling standard deviation; use static thresholds when dynamic thresholds are disabled.
Long: Normalized RAMO crosses above signal line AND is above the lower threshold AND smoothed current drawdown < 70% of smoothed maximum drawdown
Long: Momentum acceleration > 0 AND normalized RAMO < signal line AND normalized RAMO > its prior value AND normalized RAMO > lower threshold AND smoothed current drawdown < 70% of smoothed maximum drawdown
Short: Normalized RAMO crosses below signal line AND is below the upper threshold
Short: Momentum acceleration < 0 AND normalized RAMO > signal line AND normalized RAMO < its prior value AND normalized RAMO < upper threshold
Long: Momentum-regression slope > 0 AND close < prior close
Short: Momentum-regression slope < 0 AND close > prior close
Long: Low < prior low AND prior low < low two bars ago AND normalized RAMO > its prior value AND its prior value > its value two bars ago
Short: High > prior high AND prior high > high two bars ago AND normalized RAMO < its prior value AND its prior value < its value two bars ago
Long: Momentum acceleration crosses above zero
Short: Momentum acceleration crosses below zero
Long: Normalized RAMO < −exhaustion threshold AND volume < its 20-bar SMA
Short: Normalized RAMO > exhaustion threshold AND volume < its 20-bar SMA
Long: Bullish trend becomes true: normalized RAMO > signal line AND normalized RAMO > lower threshold
Short: Bearish trend becomes true: normalized RAMO < signal line AND normalized RAMO < upper threshold
Long: Normalized RAMO < lower threshold AND normalized RAMO < its prior value
Short: Normalized RAMO > upper threshold AND normalized RAMO > its prior value
Exit: Long, normalized RAMO crosses below signal line OR normalized RAMO > upper threshold
Exit: Short, normalized RAMO crosses above signal line OR normalized RAMO < lower threshold