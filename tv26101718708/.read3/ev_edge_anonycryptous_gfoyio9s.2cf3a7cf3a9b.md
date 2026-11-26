Calculation: AtrValue = ATR(high, low, close, ATR length)
Calculation: RangeHigh = Highest(high, consolidation lookback)
Calculation: RangeLow = Lowest(low, consolidation lookback)
Calculation: CompressedRun = if RangeHigh - RangeLow < AtrValue * consolidation lookback * compression factor then CompressedRun[1] + 1 else 0
Calculation: Impulse = close[consolidation lookback] - low[consolidation lookback + impulse lookback]
Calculation: RelVol(n) = volume / SMA(volume, n)
Calculation: VwRsi = 100 - 100 / (1 + RMA(max(close - close[1], 0) * RelVol(VW RSI volume length), VW RSI length) / RMA(max(close[1] - close, 0) * RelVol(VW RSI volume length), VW RSI length))
Calculation: Mfi = MFI(high, low, close, volume, MFI length)
Calculation: LongConfirm = (VW RSI confirmation off OR VwRsi > RSI midline) AND (MFI confirmation off OR Mfi > MFI midline)
Calculation: ShortConfirm = (VW RSI confirmation off OR VwRsi < RSI midline) AND (MFI confirmation off OR Mfi < MFI midline)
Calculation: LastLowPivotRsi = VwRsi[divergence pivot window] if PivotLow(VwRsi, divergence pivot window) is not NA, else LastLowPivotRsi[1]
Calculation: LastLowPivotLow = low[divergence pivot window] if PivotLow(VwRsi, divergence pivot window) is not NA, else LastLowPivotLow[1]
Calculation: LastHighPivotRsi = VwRsi[divergence pivot window] if PivotHigh(VwRsi, divergence pivot window) is not NA, else LastHighPivotRsi[1]
Calculation: LastHighPivotHigh = high[divergence pivot window] if PivotHigh(VwRsi, divergence pivot window) is not NA, else LastHighPivotHigh[1]
Calculation: BarsHeld = 1 if the position opened on this bar, else BarsHeld[1] + 1
Calculation: Depth = RangeHigh[BarsHeld] - close for long, close - RangeLow[BarsHeld] for short
Calculation: DriftNorm = (close - entry price) / AtrValue for long, (entry price - close) / AtrValue for short
Calculation: PriceDelta = drift weight * DriftNorm - (if Depth > 0 then retrace base penalty + retrace depth penalty * Depth / AtrValue else 0)
Calculation: VolumeDelta = (RelVol(volume MA length) - 1) * volume scale - (if abs(DriftNorm) < effort drift threshold AND RelVol(volume MA length) > effort volume threshold then effort penalty else 0)
Calculation: Ev = clamp((if BarsHeld = 1 then initial EV else Ev[1]) + EV update step * (price weight * PriceDelta + volume weight * VolumeDelta) / (price weight + volume weight), 0, 100)
Calculation: TrendCount = (EMA(close, fast EMA length) > EMA(close, slow EMA length)) + (EMA(close, fast EMA length, T1, last completed bar) > EMA(close, slow EMA length, T1, last completed bar)) + (EMA(close, fast EMA length, T2, last completed bar) > EMA(close, slow EMA length, T2, last completed bar)) + (EMA(close, fast EMA length, T3, last completed bar) > EMA(close, slow EMA length, T3, last completed bar)) + (EMA(close, fast EMA length, T4, last completed bar) > EMA(close, slow EMA length, T4, last completed bar)) + (EMA(close, fast EMA length, T5, last completed bar) > EMA(close, slow EMA length, T5, last completed bar))
Long: position side is flat AND CompressedRun[1] >= minimum compressed bars AND close > RangeHigh[1] + AtrValue * breakout buffer AND (impulse alignment not required OR Impulse[1] > 0) AND (confirmation filter off OR LongConfirm)
Short: position side is flat AND CompressedRun[1] >= minimum compressed bars AND close < RangeLow[1] - AtrValue * breakout buffer AND (impulse alignment not required OR Impulse[1] < 0) AND (confirmation filter off OR ShortConfirm)
Exit: long, BarsHeld > max bars tracked OR (BarsHeld >= min bars before early exit AND (Ev >= early exit high OR Ev <= early exit low))
Exit: short, BarsHeld > max bars tracked OR (BarsHeld >= min bars before early exit AND (Ev >= early exit high OR Ev <= early exit low))
Long: LongConfirm AND NOT ShortConfirm
Long: VwRsi <= oversold level
Long: VwRsi > RSI midline
Long: Mfi > MFI midline
Long: PivotLow(VwRsi, divergence pivot window) is not NA AND VwRsi[divergence pivot window] > LastLowPivotRsi[1] AND low[divergence pivot window] < LastLowPivotLow[1]
Long: EMA(close, fast EMA length) > EMA(close, slow EMA length)
Long: EMA(close, fast EMA length, T1, last completed bar) > EMA(close, slow EMA length, T1, last completed bar)
Long: EMA(close, fast EMA length, T2, last completed bar) > EMA(close, slow EMA length, T2, last completed bar)
Long: EMA(close, fast EMA length, T3, last completed bar) > EMA(close, slow EMA length, T3, last completed bar)
Long: EMA(close, fast EMA length, T4, last completed bar) > EMA(close, slow EMA length, T4, last completed bar)
Long: EMA(close, fast EMA length, T5, last completed bar) > EMA(close, slow EMA length, T5, last completed bar)
Long: TrendCount >= bull count threshold
Short: ShortConfirm AND NOT LongConfirm
Short: VwRsi >= overbought level
Short: VwRsi <= RSI midline
Short: Mfi <= MFI midline
Short: PivotHigh(VwRsi, divergence pivot window) is not NA AND VwRsi[divergence pivot window] < LastHighPivotRsi[1] AND high[divergence pivot window] > LastHighPivotHigh[1]
Short: EMA(close, fast EMA length) <= EMA(close, slow EMA length)
Short: EMA(close, fast EMA length, T1, last completed bar) <= EMA(close, slow EMA length, T1, last completed bar)
Short: EMA(close, fast EMA length, T2, last completed bar) <= EMA(close, slow EMA length, T2, last completed bar)
Short: EMA(close, fast EMA length, T3, last completed bar) <= EMA(close, slow EMA length, T3, last completed bar)
Short: EMA(close, fast EMA length, T4, last completed bar) <= EMA(close, slow EMA length, T4, last completed bar)
Short: EMA(close, fast EMA length, T5, last completed bar) <= EMA(close, slow EMA length, T5, last completed bar)
Short: TrendCount <= bear count threshold