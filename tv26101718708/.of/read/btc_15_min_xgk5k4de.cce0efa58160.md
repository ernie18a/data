Calculation: Higher-timeframe sampled-close momentum = the negative EMA-smoothed difference between RSI of cumulative volume-weighted sampled-close changes and the weighted moving average of that RSI; use the prior chart-bar values of both RSI series. The sampled close updates at a higher-timeframe boundary.
Calculation: Modified HMA = WMA of (3 × WMA(close, half-length / 3) − WMA(close, half-length / 2) − WMA(close, half-length)); use the prior completed lower-timeframe bar, with the configured shift.
Calculation: Percentage-channel upper = SMA(close, lookback) + close × upper percentage.
Calculation: Last long-signal price = open of the most recent accepted long-signal bar.
Long: (short-lookback EMA(close) > long-lookback EMA(close)) AND (higher-timeframe sampled-close momentum crosses above zero OR chart-timeframe linear regression of close crosses above the modified HMA)
Long: low crosses below last long-signal price × (1 − loss percentage) AND no long signal occurs on this bar AND the most recent accepted signal is long
Short: linear regression of close crosses below the modified HMA OR prior-bar close crosses below the percentage-channel upper
Short: high crosses above last long-signal price × (1 + profit percentage) AND no long signal occurs on this bar AND the most recent accepted signal is long
Exit: long, high crosses above average entry price × (1 + either of two profit percentages) OR low crosses below average entry price × (1 − loss percentage)
Exit: short, low crosses below average entry price × (1 − either of two profit percentages) OR high crosses above average entry price × (1 + loss percentage)