Calculation: Swing high and swing low = most recent confirmed pivot high and pivot low, using the same configurable left and right lookbacks; update each on its confirmation bar.
Calculation: Upward break = consecutive closes above the current swing high reach a confirmation threshold, after the latest swing high was confirmed and before any prior upward break of that swing high. Reset the count when a new swing high is confirmed or close is at or below the swing high.
Calculation: Downward break = consecutive closes below the current swing low reach the same confirmation threshold, after the latest swing low was confirmed and before any prior downward break of that swing low. Reset the count when a new swing low is confirmed or close is at or above the swing low.
Calculation: Warmup = the greater of a minimum bar count and a multiple of the sum of the pivot left and right lookbacks.
Calculation: Structure direction = direction of the most recent upward or downward break after warmup; initially neutral. If both breaks occur on the same bar, direction is downward.
Long: Bar index >= warmup AND upward break.
Short: Bar index >= warmup AND downward break.
Long: A swing high is confirmed AND its value > the previous confirmed swing high.
Short: A swing high is confirmed AND its value <= the previous confirmed swing high.
Long: A swing low is confirmed AND its value > the previous confirmed swing low.
Short: A swing low is confirmed AND its value <= the previous confirmed swing low.
Long: Bar index >= warmup AND low < swing low AND close > swing low.
Short: Bar index >= warmup AND high > swing high AND close < swing high.
Long: Bar index >= warmup AND low > high two bars ago.
Short: Bar index >= warmup AND high < low two bars ago.
Long: True range > ATR multiplied by a threshold AND volume > volume SMA multiplied by a threshold AND structure direction = upward.
Short: True range > ATR multiplied by the same threshold AND volume > volume SMA multiplied by the same threshold AND structure direction = downward.