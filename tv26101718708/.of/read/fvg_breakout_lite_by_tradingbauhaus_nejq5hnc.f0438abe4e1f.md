Calculation: Bullish FVG = current low > high two bars ago AND previous close > high two bars ago
Calculation: Bearish FVG = current high < low two bars ago AND previous close < low two bars ago
Calculation: Average volume = simple moving average of volume over a lookback
Calculation: Midpoint = average of the highest high and lowest low over the trend lookback
Calculation: Bullish broken state = reset to false when low > the highest high over the trend lookback ending two bars ago AND a bullish FVG forms; otherwise set to true when current low < the greater of the previous bullish trigger and current midpoint. The bullish trigger is reset to the high two bars ago on that reset condition; otherwise it is the greater of its previous value and current midpoint.
Calculation: Bearish broken state = reset to false when high < the lowest low over the trend lookback ending two bars ago AND a bearish FVG forms; otherwise set to true when current high > the lesser of the previous bearish trigger and current midpoint. The bearish trigger is reset to the low two bars ago on that reset condition; otherwise it is the lesser of its previous value and current midpoint.
Long: Bullish FVG AND bullish broken state is false AND current volume > average volume × volume threshold
Short: Bearish FVG AND bearish broken state is false AND current volume > average volume × volume threshold
Exit: Long, low <= entry price × (1 − stop-loss fraction) OR high >= entry price × (1 + take-profit fraction)
Exit: Short, high >= entry price × (1 + stop-loss fraction) OR low <= entry price × (1 − take-profit fraction)