Calculation: Relative volume = current bar volume / simple moving average of volume over the volume-average lookback, including the current bar
Calculation: Bullish close strength = (close - low) / (high - low), or 0.5 when high equals low
Calculation: Bearish close strength = (high - close) / (high - low), or 0.5 when high equals low
Calculation: Prior high = highest high in the preceding breakout-lookback bars, excluding the current bar
Calculation: Prior low = lowest low in the preceding breakout-lookback bars, excluding the current bar
Long: close > prior high AND close > open AND bullish close strength >= close-strength requirement AND relative volume >= strong-volume multiplier
Short: close < prior low AND close < open AND bearish close strength >= close-strength requirement AND relative volume >= strong-volume multiplier