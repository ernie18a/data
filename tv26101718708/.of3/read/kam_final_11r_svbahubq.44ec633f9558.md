Calculation: InWindow = (Shanghai time: day of week is Monday to Friday AND time of day >= weekday start time) OR (day of week is Saturday AND time of day <= Saturday end time)
Calculation: BullEngulf(bars) = open[1] > close[1] AND close > open AND close >= open[1] AND open <= close[1] AND close - open > open[1] - close[1] AND high > high[1] AND low < low[1] AND close > high[1]
Calculation: BearEngulf(bars) = close[1] > open[1] AND open > close AND open >= close[1] AND close <= open[1] AND open - close > close[1] - open[1] AND high > high[1] AND low < low[1] AND close < low[1]
Calculation: AverageBody = average of abs(close - open) over chart bars from the latest session start time through the current bar
Calculation: T1Start = chart bar is the first chart bar of a T1 bar
Calculation: T1End = chart bar is the last chart bar of a T1 bar
Calculation: T1LowerBreak = T1End AND close(T1, last completed bar) < BollingerLower(close, band length, band multiplier, T1, last completed bar)
Calculation: T1UpperBreak = T1End AND close(T1, last completed bar) > BollingerUpper(close, band length, band multiplier, T1, last completed bar)
Calculation: T1CrossUp = T1Start AND crosses above(EMA(close, T1 fast EMA lookback, T1, last completed bar), EMA(close, T1 slow EMA lookback, T1, last completed bar))
Calculation: T1BullEngulf = T1Start[1] AND BullEngulf(T1, last completed bar)
Calculation: T1BearEngulf = T1Start[1] AND BearEngulf(T1, last completed bar)
Calculation: OversoldCross = WaveTrend(channel length, average length, chart bars) crosses below oversold level OR WaveTrend(channel length, average length, T2, bar still forming) crosses below oversold level OR WaveTrend(channel length, average length, T3, bar still forming) crosses below oversold level OR WaveTrend(channel length, average length, T1, bar still forming) crosses below oversold level
Calculation: OverboughtCross = WaveTrend(channel length, average length, chart bars) crosses above overbought level OR WaveTrend(channel length, average length, T2, bar still forming) crosses above overbought level OR WaveTrend(channel length, average length, T3, bar still forming) crosses above overbought level OR WaveTrend(channel length, average length, T1, bar still forming) crosses above overbought level
Calculation: FullOversoldCross = OversoldCross AND WaveTrend(channel length, average length, chart bars) < oversold level AND WaveTrend(channel length, average length, T2, bar still forming) < oversold level AND WaveTrend(channel length, average length, T3, bar still forming) < oversold level AND WaveTrend(channel length, average length, T1, bar still forming) < oversold level
Calculation: FullOverboughtCross = OverboughtCross AND WaveTrend(channel length, average length, chart bars) > overbought level AND WaveTrend(channel length, average length, T2, bar still forming) > overbought level AND WaveTrend(channel length, average length, T3, bar still forming) > overbought level AND WaveTrend(channel length, average length, T1, bar still forming) > overbought level
Calculation: BullGapTouch = open, high, low and close of the chart bar all lie within [high of block A, low of block C] of an active bullish gap, where three consecutive blocks A, B, C of block length chart bars form a bullish gap at the last chart bar of block C when low of block C > high of block A, and the gap is inactive from the first later block-end chart bar whose close is below high of block A
Calculation: BearGapTouch = open, high, low and close of the chart bar all lie within [high of block C, low of block A] of an active bearish gap, where three consecutive blocks A, B, C of block length chart bars form a bearish gap at the last chart bar of block C when high of block C < low of block A, and the gap is inactive from the first later block-end chart bar whose close is above low of block A
Exit: long, InWindow[1] AND NOT InWindow
Exit: short, InWindow[1] AND NOT InWindow
Long: BullEngulf(chart bars)
Short: BearEngulf(chart bars)
Long: crosses above(EMA(close, fast EMA lookback), EMA(close, slow EMA lookback))
Short: crosses below(EMA(close, fast EMA lookback), EMA(close, slow EMA lookback))
Long: OversoldCross
Short: OverboughtCross
Long: BullEngulf(chart bars) AND open < BollingerLower(close, band length, band multiplier) AND (T1LowerBreak[1] OR ... OR T1LowerBreak[band window bars]) AND InWindow
Short: BearEngulf(chart bars) AND open > BollingerUpper(close, band length, band multiplier) AND (T1UpperBreak[1] OR ... OR T1UpperBreak[band window bars]) AND InWindow
Long: BullEngulf(chart bars) AND (T1CrossUp[1] OR ... OR T1CrossUp[T1 signal window bars]) AND SuperTrend(ATR length, factor) is uptrend AND InWindow
Short: BearEngulf(chart bars) AND (T1CrossUp[1] OR ... OR T1CrossUp[T1 signal window bars]) AND SuperTrend(ATR length, factor) is downtrend AND InWindow
Long: crosses above(EMA(close, fast EMA lookback), EMA(close, slow EMA lookback)) AND (T1BullEngulf[1] OR ... OR T1BullEngulf[T1 engulf window bars]) AND InWindow
Short: crosses below(EMA(close, fast EMA lookback), EMA(close, slow EMA lookback)) AND (T1BearEngulf[1] OR ... OR T1BearEngulf[T1 engulf window bars]) AND InWindow
Long: BullEngulf(chart bars) AND (FullOversoldCross[0] OR FullOversoldCross[1] OR ... OR FullOversoldCross[WT window bars]) AND InWindow
Short: BearEngulf(chart bars) AND (FullOverboughtCross[0] OR FullOverboughtCross[1] OR ... OR FullOverboughtCross[WT window bars]) AND InWindow
Long: BullEngulf(chart bars) AND abs(close - open) > AverageBody AND BullGapTouch AND SuperTrend(ATR length, factor) is uptrend AND InWindow
Long: BullEngulf(chart bars) AND abs(close - open) <= AverageBody AND BullGapTouch AND SuperTrend(ATR length, factor) is uptrend AND InWindow
Short: BearEngulf(chart bars) AND abs(close - open) > AverageBody AND BearGapTouch AND SuperTrend(ATR length, factor) is downtrend AND InWindow
Short: BearEngulf(chart bars) AND abs(close - open) <= AverageBody AND BearGapTouch AND SuperTrend(ATR length, factor) is downtrend AND InWindow