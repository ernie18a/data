Calculation: Bullish structure state = on confirmation of a pivot high, set true if a previous confirmed pivot high exists and the new pivot high is higher; otherwise set false. Retain the state between pivot-high confirmations; initialize false.
Calculation: Bearish structure state = on confirmation of a pivot low, set true if a previous confirmed pivot low exists and the new pivot low is lower; otherwise set false. Retain the state between pivot-low confirmations; initialize false.
Long: close > open AND close - open > ATR multiplied by an impulse threshold
Short: close < open AND open - close > ATR multiplied by an impulse threshold
Long: close > open AND close - open > ATR multiplied by an impulse threshold AND previous close < previous open
Short: close < open AND open - close > ATR multiplied by an impulse threshold AND previous close > previous open
Long: low > high two bars ago AND low - high two bars ago >= close multiplied by a gap-size threshold
Short: high < low two bars ago AND low two bars ago - high >= close multiplied by a gap-size threshold
Long: bullish structure state = true
Short: bearish structure state = true