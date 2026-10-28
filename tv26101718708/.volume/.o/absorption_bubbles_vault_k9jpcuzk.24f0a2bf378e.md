Calculation: Scaled volume = current volume divided by the rolling standard deviation of volume, or 0 when the standard deviation is 0
Calculation: Lower-wick zone = (high + low) / 2 is between low and the lower of open and close
Calculation: Upper-wick zone = (high + low) / 2 is between the higher of open and close and high
Long: lower-wick zone AND low is at or below the lowest low over a short lookback including the current bar AND volume > its rolling EMA AND scaled volume >= the small-bubble threshold multiplier
Short: upper-wick zone AND high is at or above the highest high over a short lookback including the current bar AND volume > its rolling EMA AND scaled volume >= the small-bubble threshold multiplier