Calculation: fast MA = SMA, EMA, or VWMA(fast source, shorter lookback), selected by fast type
Calculation: slow MA = SMA, EMA, or VWMA(slow source, longer lookback), selected by slow type
Calculation: VWAP = VWAP(hlc3), anchored at the first chart bar of each T1 bar
Calculation: HMA = HMA(close, HMA length)
Calculation: Supertrend = direction of Supertrend(Supertrend multiplier, Supertrend length), up or down
Calculation: ADX = ADX(ADX length)
Calculation: relative volume = volume / SMA(volume, volume lookback)
Calculation: safe ATR = 1 if ATR(ATR length) is na or 0, else ATR(ATR length)
Calculation: features = (clamp((fast MA - slow MA) / (scale 1 * safe ATR), -1, 1), clamp((close - VWAP) / (scale 2 * safe ATR), -1, 1), clamp((HMA - HMA[2]) / (scale 3 * safe ATR), -1, 1), min(1, relative volume / scale 4))
Calculation: distance(i) = sqrt(sum over components c of features of (c - c[i])^2)
Calculation: neighbors = the k values of i in 1 to lookback window with the smallest distance(i)
Calculation: class label = sign(close[shorter lag] - close[longer lag])
Calculation: bull confidence = if AI engine enabled, 100 * (number of neighbors i with class label[i] = 1) / k; else if legacy long state, fallback confidence; else 0
Calculation: bear confidence = if AI engine enabled, 100 * (number of neighbors i with class label[i] = -1) / k; else if legacy short state, fallback confidence; else 0
Calculation: legacy long state = fast MA > slow MA AND close > VWAP AND fast MA > VWAP AND HMA > HMA[2] AND close > HMA AND Supertrend = up AND ADX > ADX threshold AND relative volume > volume threshold
Calculation: legacy short state = fast MA < slow MA AND close < VWAP AND fast MA < VWAP AND HMA < HMA[2] AND close < HMA AND Supertrend = down AND ADX > ADX threshold AND relative volume > volume threshold
Calculation: AI long state = bull confidence >= confidence threshold AND close > VWAP AND ADX > ADX threshold
Calculation: AI short state = bear confidence >= confidence threshold AND close < VWAP AND ADX > ADX threshold
Long: AI engine enabled AND AI long state AND NOT AI long state[1] AND position side is not long
Long: AI engine disabled AND legacy long state AND NOT legacy long state[1] AND position side is not long
Long: AI long state
Long: fast MA crosses above slow MA
Long: fast MA crosses above VWAP
Long: fast MA > slow MA
Long: close > VWAP AND fast MA > VWAP
Long: HMA > HMA[2] AND close > HMA
Long: Supertrend = up
Short: AI engine enabled AND AI short state AND NOT AI short state[1] AND position side is not short
Short: AI engine disabled AND legacy short state AND NOT legacy short state[1] AND position side is not short
Short: AI short state
Short: fast MA crosses below slow MA
Short: fast MA crosses below VWAP
Short: fast MA <= slow MA
Short: close <= VWAP OR fast MA <= VWAP
Short: HMA < HMA[2] AND close < HMA
Short: Supertrend = down