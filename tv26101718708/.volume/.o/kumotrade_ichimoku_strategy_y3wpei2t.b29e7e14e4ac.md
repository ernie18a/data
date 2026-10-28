Calculation: Tenkan-sen = midpoint of the highest high and lowest low over a shorter lookback
Calculation: Kijun-sen = midpoint of the highest high and lowest low over a longer lookback than Tenkan-sen
Calculation: Senkou Span A = average of Tenkan-sen and Kijun-sen
Calculation: Senkou Span B = midpoint of the highest high and lowest low over a longer lookback than Kijun-sen
Calculation: Senkou max/min = maximum/minimum of Senkou Span A and Senkou Span B, each taken from 25 bars earlier
Calculation: Stochastic D = smoothed stochastic of close within the high-low range
Calculation: No Kumo = high < Senkou min − ATR/2 OR low > Senkou max + ATR
Calculation: Long trailing stop = greater of the prior long trailing stop and highest close over a rolling lookback minus a multiple of ATR; initialize to the latter value
Calculation: Short trailing stop = lesser of the prior short trailing stop and lowest low over a rolling lookback plus a multiple of ATR; initialize to the latter value
Long: flat position AND datetime within configured start and end times AND low > Kijun-sen AND Kijun-sen > Tenkan-sen AND close < Senkou Span A from 25 bars earlier AND close > open AND No Kumo AND Stochastic D < threshold
Long: (previous bar's low crossed below the previous bar's Kijun-sen AND previous bar's close > previous bar's Kijun-sen AND close > Senkou max AND Tenkan-sen >= Kijun-sen AND close > open) OR (Tenkan-sen > Kijun-sen AND low > Tenkan-sen AND low − previous bar's Tenkan-sen < ATR AND previous Tenkan-sen >= Tenkan-sen from two bars earlier AND previous Kijun-sen > Kijun-sen from two bars earlier AND Tenkan-sen − Kijun-sen < a multiple of ATR AND close > open AND Senkou Span A > Senkou Span B AND volume > its rolling EMA multiplied by a factor)
Short: flat position AND datetime within configured start and end times AND close < Senkou min AND high crosses above Kijun-sen AND Stochastic D >= threshold AND previous Stochastic D > current Stochastic D AND Senkou Span B > Senkou Span A
Exit: long, close < long trailing stop AND bar is confirmed
Exit: short, close > short trailing stop AND bar is confirmed