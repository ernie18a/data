Calculation: SmoothedOpen = EMA((open + close[1]) / 2, open smoothing lookback)
Calculation: FastEMA = EMA(close, shorter lookback)
Calculation: TrendLine = (VWAP trend enabled AND cumulative volume != 0) ? RollingVWAP(close, VWAP lookback) : EMA(close, longer lookback)
Calculation: SmoothedLinReg = EMA(LinearRegression(close, linear regression lookback, 0), regression smoothing lookback)
Calculation: STLine = SuperTrend(ATR lookback, ATR multiplier) value
Calculation: STDir = SuperTrend(ATR lookback, ATR multiplier) direction, -1 when up and +1 when down
Calculation: Momentum = RSI(close, RSI lookback)
Calculation: MomentumMA = SMA(Momentum, RSI-MA lookback)
Calculation: PivotHigh = last confirmed pivot high of high with pivot lookback bars on each side
Calculation: PivotLow = last confirmed pivot low of low with pivot lookback bars on each side
Calculation: HighVolume = volume > high-volume multiplier * SMA(volume, high-volume lookback)
Calculation: BullSweep = (min(low, low[1]) < PivotLow AND close > PivotLow) OR (min(low, low[1]) < PivotLow[1] AND close > PivotLow[1])
Calculation: BearSweep = (max(high, high[1]) > PivotHigh AND close < PivotHigh) OR (max(high, high[1]) > PivotHigh[1] AND close < PivotHigh[1])
Calculation: BullOB = close[1] < open[1] AND close > open AND close > high[1] AND BullSweep
Calculation: BearOB = close[1] > open[1] AND close < open AND close < low[1] AND BearSweep
Calculation: BullSignal = datetime > backtest start AND datetime < backtest end AND close > PivotHigh AND FastEMA > TrendLine AND STDir < 0 AND SmoothedOpen > SmoothedOpen[1] AND ((filter enabled AND SmoothedLinReg > SmoothedLinReg[slope lag]) OR (filter disabled AND close > SmoothedLinReg)) AND ((MomentumMA crosses above RSI midline AND Momentum > MomentumMA AND RSI condition enabled) OR (close > STLine AND position side is not long))
Calculation: BearSignal = datetime > backtest start AND datetime < backtest end AND close < PivotLow AND FastEMA < TrendLine AND STDir > 0 AND SmoothedOpen <= SmoothedOpen[1] AND ((filter enabled AND SmoothedLinReg < SmoothedLinReg[slope lag]) OR (filter disabled AND close < SmoothedLinReg)) AND ((MomentumMA crosses below RSI midline AND Momentum < MomentumMA AND RSI condition enabled) OR (close < STLine AND position side is not short))
Calculation: LastSignalSide = full take-profit mode ? (BullSignal AND NOT BullSignal[1] ? 1 : (BearSignal AND NOT BearSignal[1] ? -1 : LastSignalSide[1])) : 0
Long: long entries enabled AND BullSignal AND NOT BullSignal[1] AND LastSignalSide[1] != 1
Short: short entries enabled AND BearSignal AND NOT BearSignal[1] AND LastSignalSide[1] != -1
Exit: long, FastEMA < TrendLine AND STDir > 0 AND close < PivotLow AND close < SmoothedLinReg
Exit: short, FastEMA > TrendLine AND STDir < 0 AND close > PivotHigh AND close > SmoothedLinReg
Long: FastEMA > TrendLine AND STDir < 0 AND close > SmoothedLinReg AND SmoothedOpen > SmoothedOpen[1]
Short: FastEMA < TrendLine AND STDir > 0 AND close < SmoothedLinReg AND SmoothedOpen <= SmoothedOpen[1]
Long: SmoothedLinReg > SmoothedLinReg[slope lag]
Short: SmoothedLinReg < SmoothedLinReg[slope lag]
Long: close > open AND HighVolume
Short: close < open AND HighVolume
Long: BullOB
Short: BearOB
Long: BullSweep AND close[1] < open[1] AND close > open AND close > open[1] AND NOT BullOB
Short: BearSweep AND close[1] > open[1] AND close < open AND close < open[1] AND NOT BearOB
Long: close[2] < open[2] AND close[1] > open[1] AND close[1] > high[2] AND (low[1] > close[2] - rejection-block wick fraction * (close[2] - low[2]) OR low[1] < low[2])
Short: close[2] > open[2] AND close[1] < open[1] AND close[1] < low[2] AND (high[1] < close[2] + rejection-block wick fraction * (high[2] - close[2]) OR high[1] > high[2])