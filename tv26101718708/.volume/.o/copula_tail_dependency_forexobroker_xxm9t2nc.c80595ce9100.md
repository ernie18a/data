Calculation: One-bar log return = change in the natural logarithm of close
Calculation: Volume change = current volume minus previous bar volume
Calculation: Return rank = count of the latest N return values less than or equal to the current return, divided by N
Calculation: Volume-change rank = count of the latest N volume changes less than or equal to the current volume change, divided by N
Calculation: Lower-tail dependence = EMA of (number of the latest N rank pairs where both ranks are at or below tail fraction u) / (number where volume-change rank is at or below u)
Calculation: Upper-tail dependence = EMA of (number of the latest N rank pairs where both ranks are at or above 1 − u) / (number where volume-change rank is at or above 1 − u)
Long: Upper-tail dependence crosses above the signal threshold AND session filter passes AND position is not long AND cooldown has elapsed since the last signal AND current bar is confirmed
Short: Lower-tail dependence crosses above the signal threshold AND session filter passes AND position is not short AND cooldown has elapsed since the last signal AND current bar is confirmed