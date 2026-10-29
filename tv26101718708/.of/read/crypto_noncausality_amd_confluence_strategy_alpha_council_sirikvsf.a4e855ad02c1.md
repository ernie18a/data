Calculation: Hurst proxy = 1 − log10(sum of true range over the lookback / (highest high − lowest low over the lookback)) / log10(lookback)
Calculation: Laguerre RSI = upward differences summed across four recursively smoothed close-price stages, divided by the sum of upward and downward differences across those stages
Calculation: Asian session high/low = highest high and lowest low during the current Asian session, retained for the following session
Calculation: Calm/compressed regime = volatility ratio below its threshold AND Hurst proxy below its threshold; volatility ratio = ATR divided by its longer-term average ATR
Calculation: HMM regime = calm/compressed regime when its condition holds; otherwise, if Hurst proxy is above its threshold and ADX is above its threshold, classify as bull trend when at least two of RSI above its midpoint, positive directional index above negative directional index, and volume delta above zero hold; classify as bear trend when at least two of the inverse conditions hold; otherwise classify as chop
Long: low < Asian session low AND close > Asian session low AND bar is in the London session AND Laguerre RSI < oversold threshold AND (HMM is disabled AND Hurst proxy < its threshold OR HMM is enabled AND HMM regime is chop or calm/compressed)
Short: long-only mode is disabled AND high > Asian session high AND close < Asian session high AND bar is in the London session AND Laguerre RSI > overbought threshold AND (HMM is disabled AND Hurst proxy < its threshold OR HMM is enabled AND HMM regime is chop or calm/compressed)
Exit: long, (close − entry price) / entry price >= take-profit threshold AND close < fast EMA
Exit: short, (entry price − close) / entry price >= take-profit threshold AND close > fast EMA
Exit: long, close <= entry price × (1 − logical-stop threshold)
Exit: short, close >= entry price × (1 + logical-stop threshold)
Exit: long, low <= entry price × (1 − catastrophic-stop threshold)
Exit: short, high >= entry price × (1 + catastrophic-stop threshold)