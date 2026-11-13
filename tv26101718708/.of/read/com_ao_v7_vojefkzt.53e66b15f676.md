Calculation: SwingHigh/SwingLow = pivot high/low (extreme versus an equal number of bars on each side, known only after the right-side bars complete); H1,H0 = latest, previous SwingHigh; L1,L0 = latest, previous SwingLow
Calculation: Range = |H1 - L1|
Calculation: LongZone = low <= H1 - 0.5*Range AND close >= H1 - 0.786*Range
Calculation: ShortZone = high >= L1 + 0.5*Range AND close <= L1 + 0.786*Range
Calculation: SweepLow = low < L0 AND close > L0; SweepHigh = high > H0 AND close < H0
Calculation: BullFVG = low > high 2 bars ago, zone top = low, zone bottom = high 2 bars ago (keep latest); BullFVGRetest = on a later bar, low <= top AND close > bottom. BearFVG = high < low 2 bars ago, zone top = low 2 bars ago, zone bottom = high (keep latest); BearFVGRetest = on a later bar, high >= bottom AND close < top
Calculation: BullOB = when close > H1, take the high/low of the most recent bearish candle (close<open) (keep latest); BullOBRetest = low <= OB high AND close >= OB low. BearOB = when close < L1, take the high/low of the most recent bullish candle (keep latest); BearOBRetest = high >= OB low AND close <= OB high
Calculation: LongPullback = LongZone AND (BullFVGRetest OR BullOBRetest OR |EMA - (H1 - 0.618*Range)|/close <= small tolerance OR SweepLow)
Calculation: ShortPullback = ShortZone AND (BearFVGRetest OR BearOBRetest OR |EMA - (L1 + 0.618*Range)|/close <= small tolerance OR SweepHigh)
Calculation: Accumulation = SweepLow AND lower wick > k*body (k>1) AND close > open AND volume > SMA(volume) AND MFI(hlc3) > previous MFI
Calculation: Distribution = SweepHigh AND upper wick > k*body (k>1) AND close < open AND volume > SMA(volume) AND MFI(hlc3) < previous MFI
Calculation: UptrendBias = close > EMA AND EMA > previous EMA AND H1 > H0 AND L1 > L0 AND RSI > 50 AND MACD line > signal line AND MACD histogram > previous histogram AND NOT (|H1-H0|/close < small tolerance) AND NOT Distribution
Calculation: DowntrendBias = close < EMA AND EMA < previous EMA AND H1 < H0 AND L1 < L0 AND RSI < 50 AND MACD line < signal line AND MACD histogram < previous histogram AND NOT (|L1-L0|/close < small tolerance) AND NOT Accumulation
Calculation: ChaseRise = close > close N bars ago AND percent rise over N bars >= threshold AND NOT LongPullback
Calculation: ChaseFall = close < close N bars ago AND percent fall over N bars >= threshold AND NOT ShortPullback
Calculation: LongSetup = UptrendBias AND LongPullback AND volume > SMA(volume) AND close > open AND close > previous high (on completed bar)
Calculation: ShortSetup = DowntrendBias AND ShortPullback AND volume > SMA(volume) AND close < open AND close < previous low (on completed bar)
Long: LongSetup AND NOT LongSetup on previous bar
Long: Accumulation
Long: UptrendBias AND NOT LongSetup AND NOT ChaseRise
Short: ShortSetup AND NOT ShortSetup on previous bar
Short: Distribution
Short: DowntrendBias AND NOT ShortSetup AND NOT ChaseFall
Exit: long, low <= (L1 at entry bar - small multiple of ATR) OR high >= any of H1 at entry bar + {0.272, 0.618, 1.0}*Range at entry bar (ascending staged targets)
Exit: short, high >= (H1 at entry bar + small multiple of ATR) OR low <= any of L1 at entry bar - {0.272, 0.618, 1.0}*Range at entry bar (ascending staged targets)