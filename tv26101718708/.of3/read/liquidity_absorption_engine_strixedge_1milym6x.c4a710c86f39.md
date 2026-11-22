Calculation: VolRatio = volume / SMA(volume, core lookback)
Calculation: Absorption = min(1, max(-1, ((min(open, close) - low) - (high - max(open, close))) / (high - low) * min(VolRatio, absorption volume cap) / absorption scale))
Calculation: SweepSign = 1 if low < Lowest(low[1], core lookback) AND close > Lowest(low[1], core lookback), else -1 if high > Highest(high[1], core lookback) AND close < Highest(high[1], core lookback), else 0
Calculation: FlowNorm = min(1, max(-1, EMA((close - close[1]) / ATR(ATR lookback) * min(VolRatio, flow volume cap), flow smoothing)))
Calculation: PrimaryMix = min(1, max(-1, engine absorption weight * Absorption + engine sweep weight * SweepSign + engine flow weight * FlowNorm))
Calculation: SecondaryMix = (DNA absorption weight * Absorption + DNA sweep weight * SweepSign + DNA flow weight * FlowNorm) / DNA normalization
Calculation: Blend = min(1, max(-1, engine share * PrimaryMix + DNA share * SecondaryMix))
Calculation: Tilt = EMA(50 + 50 * Blend, flow smoothing)
Long: Tilt >= signal threshold
Long: Tilt > long lean threshold
Long: Tilt crosses above signal threshold AND position side[1] is flat AND (bar is confirmed closed OR bar close confirmation is off)
Short: Tilt <= 100 - signal threshold
Short: Tilt < short lean threshold
Short: Tilt crosses below (100 - signal threshold) AND position side[1] is flat AND (bar is confirmed closed OR bar close confirmation is off)
Exit: long, bar is after entry bar AND (low <= entry price - stop-loss ATR multiplier * ATR(ATR lookback) at entry bar OR high >= entry price + TP3 ATR multiplier * ATR(ATR lookback) at entry bar)
Exit: short, bar is after entry bar AND (high >= entry price + stop-loss ATR multiplier * ATR(ATR lookback) at entry bar OR low <= entry price - TP3 ATR multiplier * ATR(ATR lookback) at entry bar)