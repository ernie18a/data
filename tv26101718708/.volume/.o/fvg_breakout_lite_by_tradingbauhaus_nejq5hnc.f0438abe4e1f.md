Calculation: Bullish FVG = current low > high two bars ago AND previous-bar close > high two bars ago
Calculation: Bearish FVG = current high < low two bars ago AND previous-bar close < low two bars ago
Calculation: Rolling upper band = highest high over a configurable lookback; use its value from two bars ago
Calculation: Rolling lower band = lowest low over a configurable lookback; use its value from two bars ago
Calculation: Rolling midpoint = average of the current rolling highest high and lowest low over the trend lookback
Calculation: Bullish breakout FVG = current low > rolling upper band from two bars ago AND bullish FVG
Calculation: Bearish breakout FVG = current high < rolling lower band from two bars ago AND bearish FVG
Calculation: Average volume = simple moving average of volume over a configurable lookback
Calculation: High volume = current volume > average volume × a configurable multiplier
Calculation: Bullish broken state = starts false; reset to false on a bullish breakout FVG, then set true when current low < bullish trigger level. Bullish trigger level starts at 0, resets to high two bars ago on a bullish breakout FVG, and each bar becomes the greater of its prior value and the current rolling midpoint before testing the low.
Calculation: Bearish broken state = starts false; reset to false on a bearish breakout FVG, then set true when current high > bearish trigger level. Bearish trigger level starts at 0, resets to low two bars ago on a bearish breakout FVG, and each bar becomes the lesser of its prior value and the current rolling midpoint before testing the high.
Long: bullish breakout FVG OR (bullish FVG AND NOT bullish broken state AND high volume)
Short: bearish breakout FVG OR (bearish FVG AND NOT bearish broken state AND high volume)
Exit: long, current low ≤ entry price × (1 − configurable stop-loss percentage) OR current high ≥ entry price × (1 + configurable take-profit percentage)
Exit: short, current high ≥ entry price × (1 + configurable stop-loss percentage) OR current low ≤ entry price × (1 − configurable take-profit percentage)