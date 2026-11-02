Calculation: SMA MACD = shorter-lookback SMA of close minus longer-lookback SMA of close; its signal line is an SMA of that difference.
Calculation: Stochastic RSI K = SMA of 100 × (RSI of close − lowest RSI) / (highest RSI − lowest RSI) over a stochastic lookback; D = SMA of K using a separate smoothing lookback.
Calculation: Average-down deviation = initial deviation for the first additional order; each subsequent deviation = previous deviation × deviation multiplier + initial deviation.
Long: The selected signal is SMA MACD AND SMA MACD crosses above its signal line.
Long: The selected signal is money flow index of close AND money flow index is at or below its threshold.
Long: The selected signal is RSI of close AND RSI is at or below its threshold.
Long: The selected signal is stochastic RSI AND K crosses above D.
Long: A long position is open AND the number of open entries is below the maximum allowed AND low falls below the first entry price × (1 − the next average-down deviation).
Exit: long, high rises above the quantity-weighted average entry price × (1 + take-profit fraction).
Exit: long, stop loss is enabled AND the number of open entries equals the maximum allowed AND low is at or below the last entry price × (1 − stop-loss fraction).