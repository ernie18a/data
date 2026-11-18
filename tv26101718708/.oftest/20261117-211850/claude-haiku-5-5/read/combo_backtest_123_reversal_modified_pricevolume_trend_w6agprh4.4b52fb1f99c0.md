Calculation: RawK = 100 * (close - lowest(low, StochLength)) / (highest(high, StochLength) - lowest(low, StochLength)), where lowest and highest cover the last StochLength bars including the current bar
Calculation: FastK = simple moving average of RawK over KSmoothing bars
Calculation: SlowK = simple moving average of FastK over DLength bars
Calculation: ReversalState = 1 if close[2] < close[1] AND close > close[1] AND FastK < SlowK AND FastK > ReversalLevel; -1 if close[2] > close[1] AND close < close[1] AND FastK > SlowK AND FastK < ReversalLevel; otherwise the previous bar's ReversalState
Calculation: OHLC4 = (open + high + low + close) / 4
Calculation: CumPVT = CumPVT[1] + (volume / VolumeDivisor) * (OHLC4 - OHLC4[1]) / OHLC4[1]
Calculation: PVTLine = PVTLevel + PVTScale * CumPVT
Calculation: PVTAverage = simple moving average of PVTLine over PVTLength bars
Calculation: PVTState = 1 if PVTLine > PVTAverage; -1 if PVTLine < PVTAverage; otherwise the previous bar's PVTState
Calculation: Signal = 1 if ReversalState = 1 AND PVTState = 1; -1 if ReversalState = -1 AND PVTState = -1; otherwise 0
Calculation: TradeSignal = -Signal if ReverseTrades is on; otherwise Signal
Long: TradeSignal = 1
Short: TradeSignal = -1
Exit: long, TradeSignal = 0
Exit: short, TradeSignal = 0