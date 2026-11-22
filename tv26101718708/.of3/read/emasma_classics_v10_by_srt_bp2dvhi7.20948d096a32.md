Calculation: FastMA = MAType1(close, shortest lookback)
Calculation: MidMA = MAType2(close, shorter lookback)
Calculation: SlowMA = MAType3(close, longer lookback)
Calculation: SlowestMA = MAType4(close, longest lookback)
Calculation: UpStack = FastMA > MidMA AND MidMA > SlowMA AND SlowMA > SlowestMA
Calculation: DownStack = FastMA < MidMA AND MidMA < SlowMA AND SlowMA < SlowestMA
Calculation: Compressed = MIN(ABS(FastMA - MidMA), ABS(MidMA - SlowMA), ABS(FastMA - SlowMA)) < ATR(spacing lookback) * spacing threshold
Calculation: LadderNet = (lowest(low, longest ladder lookback) < lowest(low, longer ladder lookback)) + (lowest(low, longer ladder lookback) < lowest(low, long ladder lookback)) + (lowest(low, long ladder lookback) < lowest(low, short ladder lookback)) + (lowest(low, short ladder lookback) < lowest(low, shortest ladder lookback)) - (highest(high, longest ladder lookback) > highest(high, longer ladder lookback)) - (highest(high, longer ladder lookback) > highest(high, long ladder lookback)) - (highest(high, long ladder lookback) > highest(high, short ladder lookback)) - (highest(high, short ladder lookback) > highest(high, shortest ladder lookback))
Calculation: Engulf = high[1] - low[1] >= ATR(engulf lookback)[1] * engulf threshold AND MIN(open[1], close[1]) < MIN(open[2], close[2]) AND MAX(open[1], close[1]) > MAX(open[2], close[2]) AND ABS(close[1] - open[1]) >= engulf minimum body fraction * (high[1] - low[1])
Calculation: BullEngulf = Engulf AND close[1] > open[1]
Calculation: BearEngulf = Engulf AND close[1] < open[1]
Calculation: LongTail = high[1] - low[1] >= ATR(tail lookback)[1] * tail threshold AND ABS(close[1] - open[1]) >= tail minimum body fraction * (high[1] - low[1])
Calculation: BullLongTail = LongTail AND close[1] > open[1] AND MIN(open[1], close[1]) - low[1] >= tail fraction * (high[1] - low[1])
Calculation: BearLongTail = LongTail AND close[1] < open[1] AND high[1] - MAX(open[1], close[1]) >= tail fraction * (high[1] - low[1])
Calculation: RSIline = RSI(source, rsi lookback)
Calculation: RSIsignal = SMA(RSIline, rsi MA lookback)
Calculation: BullRetrace = lowest(RSIline, retrace lookback) < lower break level AND RSIline >= lower break level AND RSIsignal <= lower MA threshold AND RSIline crosses above RSIsignal AND sum(BullRetrace, cooldown lookback)[1] = 0
Calculation: BearRetrace = highest(RSIline, retrace lookback) > upper break level AND RSIline <= upper break level AND RSIsignal >= upper MA threshold AND RSIline crosses below RSIsignal AND sum(BearRetrace, cooldown lookback)[1] = 0
Long: UpStack AND NOT Compressed
Long: UpStack AND LadderNet >= 1
Long: BullEngulf
Long: BullLongTail
Long: UpStack AND (BullEngulf OR BullLongTail)
Long: RSIline[1] < upper break level AND RSIline >= upper break level
Long: BullRetrace
Short: DownStack AND NOT Compressed
Short: DownStack AND LadderNet <= -1
Short: BearEngulf
Short: BearLongTail
Short: DownStack AND (BearEngulf OR BearLongTail)
Short: RSIline[1] > lower break level AND RSIline <= lower break level
Short: BearRetrace