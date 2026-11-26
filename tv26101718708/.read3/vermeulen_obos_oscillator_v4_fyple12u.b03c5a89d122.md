Calculation: Smoothed RSI = EMA(RSI(close, RSI lookback), RSI smoothing lookback)
Calculation: Relative volume = volume / SMA(volume, volume lookback), when volume is available and positive
Calculation: Panic ratio = max(0, panic/FOMO midpoint − Smoothed RSI) / panic/FOMO scale × Relative volume; zero when volume is unavailable or nonpositive
Calculation: FOMO ratio = max(0, Smoothed RSI − panic/FOMO midpoint) / panic/FOMO scale × Relative volume; zero when volume is unavailable or nonpositive
Calculation: Momentum reading = momentum baseline + ((close − lowest(low, momentum lookback)) / (highest(high, momentum lookback) − lowest(low, momentum lookback)) − momentum center) × momentum scale; momentum baseline when the range is zero
Long: Smoothed RSI crosses above the RSI oversold level on a confirmed chart bar AND NOT (panic ratio > panic/FOMO threshold AND close < open AND, if the RTH filter is enabled, during the New York regular-hours session)
Long: Momentum reading < momentum oversold level on a confirmed chart bar AND, if the RTH filter is enabled, during the New York regular-hours session
Long: FOMO ratio > panic/FOMO threshold AND close > open AND abs(close − EMA(close, price-extension EMA lookback)) > ATR(ATR lookback) on a confirmed chart bar AND, if the RTH filter is enabled, during the New York regular-hours session
Long: ADX(ADX lookback) <= ADX threshold AND Smoothed RSI > RSI midline
Long: SMA(close, macro SMA lookback) > SMA(close, macro SMA lookback)[macro slope lookback] AND close > SMA(close, macro SMA lookback)
Short: panic ratio > panic/FOMO threshold AND close < open on a confirmed chart bar AND, if the RTH filter is enabled, during the New York regular-hours session
Short: Momentum reading > momentum overbought level on a confirmed chart bar AND, if the RTH filter is enabled, during the New York regular-hours session
Short: Smoothed RSI crosses below the RSI overbought level on a confirmed chart bar AND NOT (FOMO ratio > panic/FOMO threshold AND close > open AND abs(close − EMA(close, price-extension EMA lookback)) > ATR(ATR lookback) AND, if the RTH filter is enabled, during the New York regular-hours session)
Short: ADX(ADX lookback) <= ADX threshold AND Smoothed RSI <= RSI midline
Short: SMA(close, macro SMA lookback) < SMA(close, macro SMA lookback)[macro slope lookback] AND close < SMA(close, macro SMA lookback)