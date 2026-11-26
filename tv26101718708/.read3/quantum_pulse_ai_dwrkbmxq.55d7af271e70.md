Calculation: fast MA = MA(fast source, fast length, fast type), where fast length < slow length
Calculation: slow MA = MA(slow source, slow length, slow type)
Calculation: anchored VWAP = VWAP(hlc3, anchor reset at the start of each T1 bar, on chart bars)
Calculation: hull = HMA(close, hull length)
Calculation: trend bias = Supertrend(stop multiplier, stop length), up or down
Calculation: adx = ADX(adx length)
Calculation: relative volume = volume / SMA(volume, volume average length)
Calculation: guarded ATR = ATR(ATR length), or ATR fallback when that is zero
Calculation: feature 1 = clamp((fast MA - slow MA) / (guarded ATR * feature 1 scale), -1, 1)
Calculation: feature 2 = clamp((close - anchored VWAP) / (guarded ATR * feature 2 scale), -1, 1)
Calculation: feature 3 = clamp((hull - hull[2]) / (guarded ATR * feature 3 scale), -1, 1)
Calculation: feature 4 = min(1, relative volume / feature 4 divisor)
Calculation: direction label = sign(close[short lag] - close[long lag]), where long lag > short lag
Calculation: bull vote share = if AI engine on and bar index > memory lookback: 100 * (number of the neighbor count bars nearest by Euclidean distance over features 1 to 4 among the previous memory lookback bars whose direction label = 1) / neighbor count; if AI engine on: 0; otherwise fallback confidence if baseline long setup, else 0
Calculation: bear vote share = if AI engine on and bar index > memory lookback: 100 * (number of the neighbor count bars nearest by Euclidean distance over features 1 to 4 among the previous memory lookback bars whose direction label = -1) / neighbor count; if AI engine on: 0; otherwise fallback confidence if baseline short setup, else 0
Calculation: baseline long setup = fast MA > slow MA AND close > anchored VWAP AND fast MA > anchored VWAP AND hull > hull[2] AND close > hull AND trend bias is up AND adx > adx threshold AND relative volume > volume threshold
Calculation: baseline short setup = fast MA < slow MA AND close < anchored VWAP AND fast MA < anchored VWAP AND hull < hull[2] AND close < hull AND trend bias is down AND adx > adx threshold AND relative volume > volume threshold
Calculation: AI long setup = bull vote share >= confidence threshold AND close > anchored VWAP AND adx > adx threshold
Calculation: AI short setup = bear vote share >= confidence threshold AND close < anchored VWAP AND adx > adx threshold
Long: baseline long setup AND NOT baseline long setup[1] AND AI engine off AND position side is not long
Long: AI long setup AND NOT AI long setup[1] AND AI engine on AND position side is not long
Long: AI long setup
Long: fast MA crosses above slow MA
Long: fast MA crosses above anchored VWAP
Long: fast MA > slow MA
Long: close > anchored VWAP AND fast MA > anchored VWAP
Long: hull > hull[2] AND close > hull
Long: trend bias is up
Short: baseline short setup AND NOT baseline short setup[1] AND AI engine off AND position side is not short
Short: AI short setup AND NOT AI short setup[1] AND AI engine on AND position side is not short
Short: AI short setup
Short: fast MA crosses below slow MA
Short: fast MA crosses below anchored VWAP
Short: fast MA <= slow MA
Short: close <= anchored VWAP OR fast MA <= anchored VWAP
Short: hull < hull[2] AND close < hull
Short: trend bias is down