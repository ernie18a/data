Calculation: LTF triple = three consecutive completed bars (b2 oldest, b1 middle, b0 newest) from the continuous series of bars of a timeframe lower than the chart timeframe; a triple may straddle two chart bars.
Calculation: ATR = Average True Range on the chart timeframe, long lookback, last completed chart bar; k = a fixed threshold multiplier.
Calculation: Bull zone bottom = close(b2) if (close(b2) > open(b2) AND close(b2) < open(b1)) else high(b2).
Calculation: Bear zone top = close(b2) if (close(b2) < open(b2) AND close(b2) > open(b1)) else low(b2).
Long: on an LTF triple, high(b1) > high(b2) AND low(b0) > high(b2) AND (low(b0) - high(b2)) > k * ATR (bullish fair value gap).
Short: on an LTF triple, low(b1) < low(b2) AND high(b0) < low(b2) AND (low(b2) - high(b0)) > k * ATR (bearish fair value gap).
Exit: long, chart close < Bull zone bottom of the triple that triggered the long.
Exit: short, chart close > Bear zone top of the triple that triggered the short.