Calculation: NormImpulse = 100 * min(abs(close - open) / ATR(ATR length), impulse cap) / impulse cap
Calculation: NormVolume = 100 * min(volume / SMA(volume, volume SMA length), volume cap) / volume cap
Calculation: NormVolExp = 100 * min(BollingerBandwidth(close, BB length, BB multiplier) / SMA(BollingerBandwidth(close, BB length, BB multiplier), BB length), width cap) / width cap
Calculation: RawScore = (impulse weight * NormImpulse + volume weight * NormVolume + volatility weight * NormVolExp) / (impulse weight + volume weight + volatility weight)
Calculation: Score = SMA(RawScore, smoothing length)
Calculation: Pressure = SMA((close - open) / ATR(ATR length), pressure lookback)
Calculation: Bull = close > EMA(close, direction EMA length) AND Pressure > pressure threshold
Calculation: Bear = close < EMA(close, direction EMA length) AND Pressure < -pressure threshold
Calculation: ActiveThreshold = if threshold mode is adaptive then max(lower clamp, min(upper clamp, nz(SMA(Score, adaptive length) + StandardDeviation(Score, adaptive length) * adaptive multiplier, fixed threshold))) else fixed threshold
Calculation: ScoreRange = Highest(Score, regime lookback) - Lowest(Score, regime lookback)
Calculation: RegimeOK = (regime filter is not block-compressed OR NOT (ScoreRange < compressed level)) AND (regime filter is not only-expanding OR ScoreRange > expanding level)
Calculation: HTFEMA = EMA(close, EMA filter length, T1, last completed bar), taken one T1 bar earlier if the confirmed-HTF parameter is set
Calculation: BarsSinceTriangle = bars since the most recent earlier bar on which a Long or Short triangle condition held (infinite if none)
Calculation: CooldownOK = cooldown is not used OR BarsSinceTriangle >= cooldown bars
Long: Bull
Long: Bull AND Score crosses above ActiveThreshold
Long: Bull AND Score crosses above ActiveThreshold AND (TF EMA filter is not used OR close > EMA(close, EMA filter length)) AND (HTF EMA filter is not used OR close > HTFEMA) AND RegimeOK AND CooldownOK
Short: Bear
Short: Bear AND Score crosses above ActiveThreshold
Short: Bear AND Score crosses above ActiveThreshold AND (TF EMA filter is not used OR close < EMA(close, EMA filter length)) AND (HTF EMA filter is not used OR close < HTFEMA) AND RegimeOK AND CooldownOK