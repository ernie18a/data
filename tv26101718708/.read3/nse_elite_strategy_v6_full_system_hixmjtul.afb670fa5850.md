Calculation: ATR = ATR(ATR lookback)
Calculation: VolFilter = ATR / close * 100 < max ATR percent
Calculation: SessionFilter = (session filter disabled OR bar time in session window) AND NOT (opening exclusion enabled AND bar time in opening exclusion window) AND NOT (closing exclusion enabled AND bar time in closing exclusion window)
Calculation: RRFilter = target ATR multiple / stop ATR multiple >= minimum risk-reward ratio
Calculation: UpTrend = EMA(close, shorter EMA lookback) > EMA(close, middle EMA lookback) AND EMA(close, middle EMA lookback) > EMA(close, longer EMA lookback)
Calculation: DownTrend = EMA(close, shorter EMA lookback) < EMA(close, middle EMA lookback) AND EMA(close, middle EMA lookback) < EMA(close, longer EMA lookback)
Calculation: SlowK = SMA(Stochastic(close, high, low, stochastic K lookback), stochastic smoothing lookback)
Calculation: SlowD = SMA(SlowK, stochastic D lookback)
Calculation: MACDMain = MACD line(close, MACD shorter lookback, MACD longer lookback)
Calculation: MACDSignal = EMA(MACDMain, MACD signal lookback)
Calculation: RSI = RSI(close, RSI lookback)
Calculation: VolumeSpike = volume > SMA(volume, volume lookback) * volume multiplier
Calculation: SuperTrendDir = SuperTrend direction(SuperTrend factor, ATR lookback)
Calculation: StrongUpMove = close > close[1] * (1 + strong move threshold)
Calculation: StrongDownMove = close < close[1] * (1 - strong move threshold)
Calculation: BullOBTouch = low <= high[1] evaluated at most recent StrongUpMove bar AND high >= low[1] evaluated at most recent StrongUpMove bar
Calculation: BearOBTouch = low <= high[1] evaluated at most recent StrongDownMove bar AND high >= low[1] evaluated at most recent StrongDownMove bar
Calculation: LastPivotHigh = most recent defined PivotHigh(high, swing lookback, swing lookback)
Calculation: PrevPivotHigh = second most recent defined PivotHigh(high, swing lookback, swing lookback)
Calculation: LastPivotLow = most recent defined PivotLow(low, swing lookback, swing lookback)
Calculation: PrevPivotLow = second most recent defined PivotLow(low, swing lookback, swing lookback)
Calculation: InsideBarPattern = inside bar enabled AND high < high[1] AND low > low[1]
Calculation: Doji = doji enabled AND |close - open| <= (high - low) * doji body ratio
Calculation: BullishCandle = (engulfing enabled AND bullish engulfing) OR (pin bar enabled AND min(open, close) - low >= |close - open| * pin wick multiple AND high - max(open, close) <= |close - open| * pin small-wick multiple AND high > low) OR (InsideBarPattern[1] AND close > high[2]) OR (Doji AND close[1] < open[1])
Calculation: BearishCandle = (engulfing enabled AND bearish engulfing) OR (pin bar enabled AND high - max(open, close) >= |close - open| * pin wick multiple AND min(open, close) - low <= |close - open| * pin small-wick multiple AND high > low) OR (InsideBarPattern[1] AND close < low[2]) OR (Doji AND close[1] > open[1])
Calculation: BullishDivergence = lowest(low, divergence shorter lookback) < lowest(low, divergence longer lookback) AND lowest(RSI, divergence shorter lookback) > lowest(RSI, divergence longer lookback)
Calculation: BearishDivergence = highest(high, divergence shorter lookback) > highest(high, divergence longer lookback) AND highest(RSI, divergence shorter lookback) < highest(RSI, divergence longer lookback) AND EMA(close, shorter EMA lookback) < EMA(close, middle EMA lookback)
Calculation: LongScore = trend weight * [UpTrend] + structure weight * [structure filter disabled OR LastPivotHigh > PrevPivotHigh OR LastPivotLow > PrevPivotLow] + RSI weight * [RSI > RSI midline AND RSI < RSI overbought level] + MACD weight * [MACDMain > MACDSignal AND MACDMain > 0] + MACD cross weight * [MACDMain crosses above MACDSignal] + stochastic weight * [SlowK > SlowD AND SlowK < stochastic upper level] + volume weight * [VolumeSpike AND close > open] + candle weight * [BullishCandle] + SuperTrend weight * [SuperTrendDir < 0] + order block weight * [BullOBTouch] + divergence weight * [BullishDivergence]
Calculation: ShortScore = trend weight * [DownTrend] + structure weight * [structure filter disabled OR LastPivotHigh < PrevPivotHigh OR LastPivotLow < PrevPivotLow] + RSI weight * [RSI < RSI midline AND RSI > RSI oversold level] + MACD weight * [MACDMain < MACDSignal AND MACDMain < 0] + MACD cross weight * [MACDMain crosses below MACDSignal] + stochastic weight * [SlowK < SlowD AND SlowK > stochastic lower level] + volume weight * [VolumeSpike AND close < open] + candle weight * [BearishCandle] + SuperTrend weight * [SuperTrendDir > 0] + order block weight * [BearOBTouch] + divergence weight * [BearishDivergence]
Long: LongScore >= score threshold AND SessionFilter AND VolFilter AND RRFilter AND position side is flat
Short: ShortScore >= score threshold AND SessionFilter AND VolFilter AND RRFilter AND position side is flat
Long: BullishDivergence
Short: BearishDivergence
Long: BullOBTouch
Short: BearOBTouch
Long: low - high[2] > close * FVG threshold percent / 100
Short: low[2] - high > close * FVG threshold percent / 100
Long: SuperTrendDir < 0
Short: SuperTrendDir > 0
Exit: long, low <= entry price - ATR at entry bar * stop ATR multiple
Exit: long, high >= entry price + ATR at entry bar * target ATR multiple
Exit: long, trailing enabled AND low <= highest high since entry - ATR at entry bar * trailing ATR multiple
Exit: long, DownTrend
Exit: short, high >= entry price + ATR at entry bar * stop ATR multiple
Exit: short, low <= entry price - ATR at entry bar * target ATR multiple
Exit: short, trailing enabled AND high >= lowest low since entry + ATR at entry bar * trailing ATR multiple
Exit: short, UpTrend