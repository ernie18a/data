Calculation: ER = Efficiency Ratio(close, baseline lookback)
Calculation: SC = min(acceleration factor * (ER * (2 / (fast smoothing period + 1) - 2 / (slow smoothing period + 1)) + 2 / (slow smoothing period + 1))^2, 1)
Calculation: Baseline = Baseline[1] + SC * (close - Baseline[1])
Calculation: Upper = Baseline + ATR(high, low, close, envelope ATR lookback) * envelope multiplier
Calculation: Lower = Baseline - ATR(high, low, close, envelope ATR lookback) * envelope multiplier
Calculation: UpRun = close > Upper ? UpRun[1] + 1 : 0
Calculation: DnRun = close < Lower ? DnRun[1] + 1 : 0
Calculation: FlowState = (FlowState[1] <= 0 AND UpRun >= confirmation count) ? 1 : (FlowState[1] >= 0 AND DnRun >= confirmation count) ? -1 : FlowState[1]
Calculation: VolumeIndex = volume / SMA(volume, volume lookback)
Calculation: VolPts = VolumeIndex >= volume high threshold ? top points : VolumeIndex >= volume mid threshold ? mid points : 0
Calculation: BodyShare = abs(close - open) / (high - low)
Calculation: BodyPts = BodyShare >= body high threshold ? top points : BodyShare >= body mid threshold ? mid points : low points
Calculation: EffPts = ER >= efficiency high threshold ? top points : ER >= efficiency mid threshold ? mid points : low points
Calculation: LongScore = (Momentum(close, momentum lookback) > 0 ? top points : 0) + VolPts + BodyPts + EffPts
Calculation: ShortScore = (Momentum(close, momentum lookback) < 0 ? top points : 0) + VolPts + BodyPts + EffPts
Calculation: EntryStopDist = ATR stop mode ? ATR(high, low, close, stop ATR lookback) * stop ATR multiple : entry price * stop percent / 100, with ATR evaluated on the entry bar
Long: FlowState == 1
Long: FlowState crosses above 0
Long: FlowState crosses above 0 AND LongScore >= minimum quality
Short: FlowState == -1
Short: FlowState crosses below 0
Short: FlowState crosses below 0 AND ShortScore >= minimum quality
Exit: long, bars since entry > 0 AND (low <= entry price - EntryStopDist OR high >= entry price + take-profit R multiple * EntryStopDist)
Exit: short, bars since entry > 0 AND (high >= entry price + EntryStopDist OR low <= entry price - take-profit R multiple * EntryStopDist)