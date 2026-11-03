Calculation: Confirmed pivot high = a bar’s high above the highs in equal-length lookback windows on both sides; available after the right-side bars complete on the chart timeframe
Calculation: Confirmed pivot low = a bar’s low below the lows in equal-length lookback windows on both sides; available after the right-side bars complete on the chart timeframe
Calculation: Candle body-to-range ratio = abs(close - open) / (high - low)
Calculation: Prior-day close = close of the last completed daily bar (higher timeframe)
Calculation: Prior-prior-day open = open of the daily bar two bars before the current daily bar (higher timeframe)
Long: close crosses above the latest confirmed pivot high AND candle body-to-range ratio is at least the configured minimum
Short: close crosses below the latest confirmed pivot low AND candle body-to-range ratio is at least the configured minimum
Long: close > prior-day close
Short: close <= prior-day close
Long: prior-day close >= prior-prior-day open AND price has crossed below prior-prior-day open during the current day, using the configured wick-or-close reference
Short: prior-day close < prior-prior-day open AND price has crossed above prior-prior-day open during the current day, using the configured wick-or-close reference