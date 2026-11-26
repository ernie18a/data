Calculation: RangeHigh1 = max(high) over bars inside range window 1 of the current T1 bar
Calculation: RangeLow1 = min(low) over bars inside range window 1 of the current T1 bar
Calculation: RangeHigh2 = max(high) over bars inside range window 2 of the current T1 bar
Calculation: RangeLow2 = min(low) over bars inside range window 2 of the current T1 bar
Calculation: T3Close = close(T3, last completed bar)
Calculation: DownRun = 0 on a new T1 bar, otherwise DownRun[1] + 1 if T3Close < T3Close[1], else 0
Calculation: UpRun = 0 on a new T1 bar, otherwise UpRun[1] + 1 if T3Close > T3Close[1], else 0
Calculation: LowSweep1 = in trade window 1 AND low < RangeLow1 AND DownRun >= min consecutive candles
Calculation: LowSweep2 = in trade window 2 AND low < RangeLow2 AND DownRun >= min consecutive candles
Calculation: HighSweep1 = in trade window 1 AND high > RangeHigh1 AND UpRun >= min consecutive candles
Calculation: HighSweep2 = in trade window 2 AND high > RangeHigh2 AND UpRun >= min consecutive candles
Calculation: SweptLow1 = NOT new T1 bar AND SweptLow1[1] OR LowSweep1
Calculation: SweptLow2 = NOT new T1 bar AND SweptLow2[1] OR LowSweep2
Calculation: SweptHigh1 = NOT new T1 bar AND SweptHigh1[1] OR HighSweep1
Calculation: SweptHigh2 = NOT new T1 bar AND SweptHigh2[1] OR HighSweep2
Calculation: LevelA = round((close - level offset A) / price step) * price step + level offset A
Calculation: LevelB = round((close - level offset B) / price step) * price step + level offset B
Calculation: TouchLow = low <= LevelA AND close > LevelA
Calculation: TouchHigh = high >= LevelB AND close < LevelB
Calculation: Displacement = (high - low) > highest(high - low, displacement lookback)[1]
Calculation: DisplacementOK = Displacement OR NOT require displacement
Calculation: BullFVG = low > high[FVG offset] AND close > high[FVG offset]
Calculation: BearFVG = high < low[FVG offset] AND close < low[FVG offset]
Calculation: BullFVGOK = BullFVG OR NOT require FVG
Calculation: BearFVGOK = BearFVG OR NOT require FVG
Calculation: TrendClose = close(T1, last completed bar)
Calculation: TrendEMA = EMA(close, T1 EMA length, T1, last completed bar)
Calculation: TrendSlope = TrendEMA - TrendEMA[slope lookback]
Calculation: T2EMA = EMA(close, T2 EMA length, T2, last completed bar)
Calculation: WeeklyBullOK = TrendClose > T2EMA OR NOT require weekly alignment
Calculation: WeeklyBearOK = TrendClose <= T2EMA OR NOT require weekly alignment
Calculation: DayOpen = open of the first chart bar of the current T1 bar
Calculation: ConsolidationRange = max(high) - min(low) over bars inside consolidation window of the current T1 bar, up to the current bar
Calculation: Consolidating = in consolidation window AND ConsolidationRange < consolidation multiplier * ATR(ATR length) OR in post-consolidation window AND Consolidating[1]
Long: in trade window 1 AND SweptLow1 AND TouchLow AND DisplacementOK AND BullFVGOK
Short: in trade window 1 AND SweptHigh1 AND TouchHigh AND DisplacementOK AND BearFVGOK
Long: in trade window 2 AND SweptLow2 AND TouchLow AND DisplacementOK AND BullFVGOK
Short: in trade window 2 AND SweptHigh2 AND TouchHigh AND DisplacementOK AND BearFVGOK
Long: LowSweep1 AND close < open
Long: LowSweep2 AND close < open
Short: HighSweep1 AND close > open
Short: HighSweep2 AND close > open
Long: TrendClose > TrendEMA AND WeeklyBullOK AND close < DayOpen AND NOT Consolidating
Short: TrendClose <= TrendEMA AND WeeklyBearOK AND close > DayOpen AND NOT Consolidating
Long: TrendClose > TrendEMA AND TrendSlope > 0
Short: TrendClose <= TrendEMA AND TrendSlope < 0