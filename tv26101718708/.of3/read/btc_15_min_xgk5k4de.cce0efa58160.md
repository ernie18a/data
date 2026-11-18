Calculation: Sampled close = chart close on the first chart bar of each T2 interval, carried forward on chart bars until the next T2 interval
Calculation: RSI source = RSI(CUM(CHANGE(sampled close) * volume), RSI lookback)
Calculation: Z = -EMA(RSI source[1] - WMA(RSI source, oscillator lookback)[1], oscillator lookback)
Calculation: Modified HMA(src, HMA lookback) = WMA(3 * WMA(src, HMA lookback / 6) - WMA(src, HMA lookback / 4) - WMA(src, HMA lookback / 2), HMA lookback / 2)
Calculation: T1 reference = Modified HMA(close[1], HMA lookback)[shift] evaluated on T1 bars and sampled onto chart bars from completed T1 bars
Calculation: Upper percentage channel = SMA(close, channel lookback) + upper channel percentage * close / 100
Calculation: Adaptive lookback = minute parameter / chart timeframe multiplier * 7 when chart bars are intraday and the multiplier is at least 1; otherwise 60 / chart timeframe multiplier * 24 * 7 when intraday and the multiplier is below 60; otherwise 7
Calculation: M = (WMA(low, adaptive lookback) + WMA(high, adaptive lookback)) / 2
Calculation: Upper deviation band = EMA(M, shared band and color lookback) + deviation multiplier * STDEV(M, shared band and color lookback)
Calculation: Lower deviation band = EMA(M, shared band and color lookback) - deviation multiplier * STDEV(M, shared band and color lookback)
Calculation: Long color level = close on each bar where M crosses above the lower deviation band, otherwise its prior value, initially zero
Calculation: Short color level = close on each bar where M crosses below the upper deviation band, otherwise its prior value, initially zero
Calculation: Color midpoint = (HIGHEST(Short color level, shared band and color lookback) + LOWEST(Long color level, shared band and color lookback)) / 2
Long: close >= Color midpoint
Short: close < Color midpoint
Long: (Z crosses above 0 OR LINREG(close, regression lookback, 0) crosses above T1 reference) AND (EMA filter is disabled OR EMA(close, shorter filter lookback) > EMA(close, longer filter lookback)) AND this is the first raw long signal since the latest raw short signal, where a raw short signal is LINREG(close, regression lookback, 0) crossing below T1 reference OR close[1] crossing below the upper percentage channel
Long: rebuy toggle enabled AND low crosses below (1 - rebuy stop percentage / 100) * the open of the latest eligible raw long signal bar AND the latest eligible raw signal is long AND no eligible raw long signal occurs on this bar
Short: high crosses above (1 + signal profit threshold / 100) * the open of the latest eligible raw long signal bar AND the latest eligible raw signal is long AND no eligible raw long signal occurs on this bar AND this is the first such target crossing since the latest eligible raw long signal
Exit: long, high >= entry price * (1 + first take-profit percentage / 100) OR high >= entry price * (1 + second take-profit percentage / 100) OR low <= entry price * (1 - stop-loss percentage / 100)
Exit: short, low <= entry price * (1 - first take-profit percentage / 100) OR low <= entry price * (1 - second take-profit percentage / 100) OR high >= entry price * (1 + stop-loss percentage / 100)