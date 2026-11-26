Calculation: Evidence 1 = tanh((EMA(close, EMA length) - EMA(close, EMA length)[EMA slope lookback]) / (ATR(ATR lookback) * EMA slope lookback)) if ATR(ATR lookback) > 0, else 0
Calculation: Evidence 2 = (RSI(close, RSI length) - RSI midpoint parameter) / RSI midpoint parameter
Calculation: Evidence 3 = tanh((close - close[1]) / ATR(ATR lookback)) if ATR(ATR lookback) > 0, else 0
Calculation: Evidence 4 = tanh(((volume - volume[1]) / StDev(volume, volume lookback)) * sign(close - close[1]) / volume evidence damping parameter) if StDev(volume, volume lookback) > 0, else 0
Calculation: Evidence 5 = tanh(((high - low) / SMA(high - low, range lookback) - range expansion baseline parameter) * sign(close - close[1])) if SMA(high - low, range lookback) > 0, else 0
Calculation: Evidence 6 = (((close - lowest(low, position range lookback)) / (highest(high, position range lookback) - lowest(low, position range lookback))) - range position center parameter) * range position scale parameter if highest(high, position range lookback) > lowest(low, position range lookback), else 0
Calculation: Evidence mass(s) = (max(s, 0) * abs(s), max(-s, 0) * abs(s), 1 - abs(s)) for long, short, and hold mass
Calculation: DempsterFuse((aL,aS,aH),(bL,bS,bH)) = normalize((aL*bL+aL*bH+aH*bL, aS*bS+aS*bH+aH*bS, aH*bH) / max(1-aL*bS-aS*bL, numerical floor parameter))
Calculation: Final mass triplet = DempsterFuse(DempsterFuse(DempsterFuse(DempsterFuse(DempsterFuse(Evidence mass(Evidence 1), Evidence mass(Evidence 2)), Evidence mass(Evidence 3)), Evidence mass(Evidence 4)), Evidence mass(Evidence 5)), Evidence mass(Evidence 6))
Calculation: Net mass difference = Final mass long - Final mass short
Long: Final mass long > mass threshold
Long: Net mass difference > 0
Long: Final mass long crosses above mass threshold
Long: Net mass difference crosses above 0
Long: Final mass long > mass threshold AND (session restriction is disabled OR chart-bar datetime is within the session window) AND position is flat or short AND current chart bar index minus last signal chart bar index is at least the cooldown length AND chart bar is confirmed; last signal chart bar index is initialized to zero
Short: Final mass long <= mass threshold AND Final mass short > mass threshold
Short: Net mass difference < 0
Short: Final mass short crosses above mass threshold
Short: Net mass difference crosses below 0
Short: Final mass short > mass threshold AND (session restriction is disabled OR chart-bar datetime is within the session window) AND position is flat or long AND current chart bar index minus last signal chart bar index is at least the cooldown length AND chart bar is confirmed; last signal chart bar index is initialized to zero