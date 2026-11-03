Calculation: Internal/swing pivot high = high at the respective lookback bars ago when it equals the highest high in the centered window of twice that lookback plus one bars; the internal lookback is shorter than the swing lookback
Calculation: Internal/swing pivot low = low at the respective lookback bars ago when it equals the lowest low in the centered window of twice that lookback plus one bars; the internal lookback is shorter than the swing lookback
Calculation: Bullish fair value gap = current low > high two bars ago AND previous close > high two bars ago
Calculation: Bearish fair value gap = current high < low two bars ago AND previous close < low two bars ago
Calculation: Equilibrium = (highest high over the lookback + lowest low over the same lookback) / 2
Calculation: Discount = close < equilibrium
Calculation: Premium = close > equilibrium
Calculation: Long initial stop = signal-bar low − ATR × stop multiplier
Calculation: Short initial stop = signal-bar high + ATR × stop multiplier
Calculation: Long target = signal close + (signal close − long initial stop) × reward/risk multiplier
Calculation: Short target = signal close − (short initial stop − signal close) × reward/risk multiplier
Calculation: Long stop = the greater of the previous long stop and low − ATR × stop multiplier; reset it to entry price when the long target is reached
Calculation: Short stop = the lesser of the previous short stop and high + ATR × stop multiplier; reset it to entry price when the short target is reached
Long: flat AND (close crosses above the latest internal pivot high OR close crosses above the latest swing pivot high) AND Discount AND (current bullish fair value gap OR previous-bar bullish fair value gap)
Short: flat AND (close crosses below the latest internal pivot low OR close crosses below the latest swing pivot low) AND Premium AND (current bearish fair value gap OR previous-bar bearish fair value gap)
Exit: long, high >= long target
Exit: long, low <= long stop
Exit: short, low <= short target
Exit: short, high >= short stop