Calculation: Williams %R = 100 × (source close − highest high over the lookback) / (highest high over the lookback − lowest low over the lookback), using selected indicator-timeframe bars; if the range is zero, use −50. The script requests this timeframe with lookahead off: historical values update when the timeframe bar completes; realtime values can use the still-forming bar.
Calculation: Signal line = configured moving average of Williams %R over the signal lookback, using the same indicator-timeframe bars and bar availability as Williams %R.
Long: Williams %R crosses above the signal line
Long: Williams %R crosses above the oversold level
Short: Williams %R crosses below the signal line
Short: Williams %R crosses below the overbought level