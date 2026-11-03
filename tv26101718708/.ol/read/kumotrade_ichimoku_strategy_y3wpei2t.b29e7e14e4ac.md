Calculation: Tenkan-sen = midpoint of the highest high and lowest low over a shorter lookback.
Calculation: Kijun-sen = midpoint of the highest high and lowest low over a longer lookback than Tenkan-sen.
Calculation: Senkou A = average of the current Tenkan-sen and Kijun-sen.
Calculation: Senkou B = midpoint of the highest high and lowest low over its lookback.
Calculation: Cloud upper = greater of Senkou A and Senkou B, both evaluated 25 bars earlier; Cloud lower = lesser of those values.
Calculation: Stochastic %D = moving average of smoothed stochastic %K.
Calculation: Long trailing stop = highest close over the last 5 bars minus 3 × ATR(5); update only when this value rises.
Calculation: Short trailing stop = lowest low over the last 5 bars plus 3 × ATR(5); update only when this value falls.
Long: low[1] < Kijun-sen[1] AND low[2] >= Kijun-sen[2] AND close[1] > Kijun-sen[1] AND close > cloud upper AND Tenkan-sen >= Kijun-sen AND close > open
Long: Tenkan-sen > Kijun-sen AND low > Tenkan-sen AND low - Tenkan-sen[1] < ATR(5) AND Tenkan-sen[1] >= Tenkan-sen[2] AND Kijun-sen[1] > Kijun-sen[2] AND Tenkan-sen - Kijun-sen < 1.5 × ATR(5) AND close > open AND Senkou A > Senkou B AND volume > 1.25 × EMA(volume, 25)
Long: position is flat AND datetime >= configured start time AND datetime <= configured end time AND low > Kijun-sen AND Kijun-sen > Tenkan-sen AND close < Senkou A evaluated 25 bars earlier AND close > open AND (high < cloud lower - ATR(5)/2 OR low > cloud upper + ATR(5)) AND Stochastic %D < 29
Short: position is flat AND datetime >= configured start time AND datetime <= configured end time AND close < cloud lower AND high crosses above Kijun-sen AND Stochastic %D >= 90 AND Stochastic %D < prior-bar Stochastic %D AND Senkou B > Senkou A
Exit: long, close < long trailing stop AND bar is confirmed
Exit: short, close > short trailing stop AND bar is confirmed