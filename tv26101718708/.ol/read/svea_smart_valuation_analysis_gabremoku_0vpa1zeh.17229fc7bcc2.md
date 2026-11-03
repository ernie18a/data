Calculation: RSI = relative strength index of close; use the selected overbought and oversold thresholds. In adaptive mode, derive thresholds from the RSI moving average plus/minus its standard deviation over a longer lookback, bound them, then smooth them.
Calculation: Adjusted Bollinger Bands = moving average of close ± Bollinger standard deviation × band multiplier × (1 + ADX / 100 × ADX influence).
Calculation: Top zone = smoothed adjusted upper band plus zone offset; bottom zone = smoothed adjusted lower band minus zone offset. Zone offset is the smoothed band range multiplied by the offset parameter.
Long: RSI crosses above the oversold threshold AND the previous bar was in the bottom zone or oversold AND (if enabled) ADX exceeds the strong-trend threshold AND (if enabled) RSI on both higher timeframes is oversold
Short: RSI crosses below the overbought threshold AND the previous bar was in the top zone or overbought AND (if enabled) ADX exceeds the strong-trend threshold AND (if enabled) RSI on both higher timeframes is overbought
Long: Close enters the bottom zone AND the previous bar was not in the bottom zone AND at least the cooldown lookback bars have elapsed since the previous long zone-entry signal
Short: Close enters the top zone AND the previous bar was not in the top zone AND at least the cooldown lookback bars have elapsed since the previous short zone-entry signal
Long: RSI on the chart timeframe and both higher timeframes is oversold
Short: RSI on the chart timeframe and both higher timeframes is overbought