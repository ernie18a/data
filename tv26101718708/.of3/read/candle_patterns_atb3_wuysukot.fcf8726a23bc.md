Calculation: Body = abs(close - open)
Calculation: Range = high - low
Calculation: UpperWick = high - max(open, close)
Calculation: LowerWick = min(open, close) - low
Calculation: MinWick = ATR(ATR length) * min wick ATR multiple
Calculation: AvgRange = (Range + Range[1] + Range[2] + Range[3]) / 4
Calculation: TrendSlope = EMA(close, trend EMA length) - EMA(close, trend EMA length)[slope lookback]
Calculation: UpTrend = trend filter off OR TrendSlope > ATR(ATR length) * slope multiplier
Calculation: DownTrend = trend filter off OR TrendSlope < -ATR(ATR length) * slope multiplier
Calculation: Trending = UpTrend OR DownTrend
Calculation: MinRange = min(Range, Range[1])
Calculation: LowerWickOK = Range > 0 AND Range[1] > 0 AND LowerWick >= Range * min wick share AND LowerWick[1] >= Range[1] * min wick share AND LowerWick >= MinWick AND LowerWick[1] >= MinWick
Calculation: UpperWickOK = Range > 0 AND Range[1] > 0 AND UpperWick >= Range * min wick share AND UpperWick[1] >= Range[1] * min wick share AND UpperWick >= MinWick AND UpperWick[1] >= MinWick
Calculation: LowerWickDiff = abs(LowerWick - LowerWick[1]) / max(LowerWick, LowerWick[1])
Calculation: UpperWickDiff = abs(UpperWick - UpperWick[1]) / max(UpperWick, UpperWick[1])
Calculation: CandLongWicks = LowerWickOK AND LowerWick < LowerWick[1] AND LowerWickDiff > wick length tolerance AND low > low[1] AND abs(low - low[1]) <= MinRange * wick-tip share AND DownTrend
Calculation: CandShortWicks = UpperWickOK AND UpperWick < UpperWick[1] AND UpperWickDiff > wick length tolerance AND high < high[1] AND abs(high - high[1]) <= MinRange * wick-tip share AND UpTrend
Calculation: CandLongTweezer = close[1] < open[1] AND close > open AND LowerWickOK AND LowerWickDiff <= wick length tolerance AND abs(low - low[1]) <= MinRange * tweezer alignment share AND DownTrend
Calculation: CandShortTweezer = close[1] > open[1] AND close < open AND UpperWickOK AND UpperWickDiff <= wick length tolerance AND abs(high - high[1]) <= MinRange * tweezer alignment share AND UpTrend
Calculation: CandLongEngulf = close > open AND close[1] < open[1] AND close > open[1] AND open < close[1] AND LowerWick > 0 AND Trending
Calculation: CandShortEngulf = close < open AND close[1] > open[1] AND open > close[1] AND close < open[1] AND UpperWick > 0 AND Trending
Calculation: CandLongStrike = close[3] < open[3] AND close[2] < open[2] AND close[1] < open[1] AND close > open AND close > open[3] AND Trending
Calculation: CandShortStrike = close[3] > open[3] AND close[2] > open[2] AND close[1] > open[1] AND close < open AND close < open[3] AND Trending
Calculation: MidSmall = Range[1] > 0 AND Body[1] <= Range[1] * star middle body share AND Body[1] <= Body[2]
Calculation: CandLongStar = close[2] < open[2] AND close[1] > open[1] AND MidSmall AND close > open AND (UpperWick > 0 OR LowerWick > 0) AND close > (open[2] + close[2]) / 2 AND (star trend filter off OR DownTrend) AND low[1] < low[2] AND low[1] < low
Calculation: CandShortStar = close[2] > open[2] AND close[1] < open[1] AND MidSmall AND close < open AND (UpperWick > 0 OR LowerWick > 0) AND close < (open[2] + close[2]) / 2 AND (star trend filter off OR UpTrend) AND high[1] > high[2] AND high[1] > high
Calculation: CandLongSBS = close[3] < open[3] AND close[2] > open[2] AND close[1] < open[1] AND close > open AND AvgRange > 0 AND abs(close[1] - open[2]) <= AvgRange * SBS close tolerance share
Calculation: CandShortSBS = close[3] > open[3] AND close[2] < open[2] AND close[1] > open[1] AND close < open AND AvgRange > 0 AND abs(close[1] - open[2]) <= AvgRange * SBS close tolerance share
Calculation: BullishFVG = high[2] < low AND low - high[2] >= ATR(ATR length) * FVG min ATR fraction
Calculation: BearishFVG = low[2] > high AND low[2] - high >= ATR(ATR length) * FVG min ATR fraction
Calculation: BullIFVG = exists k from 1 to FVG max age + 1 such that BullishFVG[k] AND low < high[k+2] AND low[m] >= high[k+2] for all m from 1 to k-1
Calculation: BearIFVG = exists k from 1 to FVG max age + 1 such that BearishFVG[k] AND high > low[k+2] AND high[m] <= low[k+2] for all m from 1 to k-1
Calculation: BullOverext = high > highest(high[1], extreme lookback) AND high - EMA(close, shorter EMA length) >= ATR(ATR length) * overextension multiple AND close > open
Calculation: BearOverext = low < lowest(low[1], extreme lookback) AND EMA(close, shorter EMA length) - low >= ATR(ATR length) * overextension multiple AND close < open
Calculation: BullSetup = BullOverext OR (BullSetup[1] AND close <= open AND low > EMA(close, shorter EMA length) AND low > EMA(close, longer EMA length) AND bars since BullOverext <= max wait)
Calculation: BearSetup = BearOverext OR (BearSetup[1] AND close >= open AND high < EMA(close, shorter EMA length) AND high < EMA(close, longer EMA length) AND bars since BearOverext <= max wait)
Long: CandLongWicks AND NOT CandLongWicks[1]
Long: CandLongStar AND NOT CandLongStar[1]
Long: CandLongTweezer AND NOT CandLongTweezer[1]
Long: CandLongSBS AND NOT CandLongSBS[1]
Long: close > open AND LowerWick >= Body * dominant wick-to-body ratio AND UpperWick <= Body * opposite wick-to-body ratio AND LowerWick >= MinWick AND DownTrend
Long: Range > 0 AND Body <= Range * doji body share AND LowerWick >= Range * dominant wick share AND UpperWick <= Range * opposite wick share AND DownTrend
Long: CandLongEngulf AND NOT CandLongEngulf[1]
Long: CandLongStrike AND NOT CandLongStrike[1]
Long: close > open AND close[1] > open[1] AND close[2] > open[2] AND close > close[1] AND close[1] > close[2]
Long: close > open AND UpperWick <= Range * marubozu wick share AND LowerWick <= Range * marubozu wick share
Long: BullishFVG
Long: PivotLow(low, sweep lookback, confirmation bars) is defined AND close[confirmation bars] > lowest(low, sweep lookback)[confirmation bars + 1]
Long: BearIFVG
Long: BullSetup[1] AND close <= open AND low > EMA(close, shorter EMA length) AND low <= EMA(close, longer EMA length)
Short: CandShortWicks AND NOT CandShortWicks[1]
Short: CandShortStar AND NOT CandShortStar[1]
Short: CandShortTweezer AND NOT CandShortTweezer[1]
Short: CandShortSBS AND NOT CandShortSBS[1]
Short: close < open AND UpperWick >= Body * dominant wick-to-body ratio AND LowerWick <= Body * opposite wick-to-body ratio AND UpperWick >= MinWick AND UpTrend
Short: Range > 0 AND Body <= Range * doji body share AND UpperWick >= Range * dominant wick share AND LowerWick <= Range * opposite wick share AND UpTrend
Short: close > open AND UpperWick >= Body * dominant wick-to-body ratio AND LowerWick <= Body * opposite wick-to-body ratio AND UpperWick >= MinWick AND UpTrend
Short: close < open AND LowerWick >= Body * dominant wick-to-body ratio AND UpperWick <= Body * opposite wick-to-body ratio AND LowerWick >= MinWick AND UpTrend
Short: CandShortEngulf AND NOT CandShortEngulf[1]
Short: CandShortStrike AND NOT CandShortStrike[1]
Short: close < open AND close[1] < open[1] AND close[2] < open[2] AND close < close[1] AND close[1] < close[2]
Short: close < open AND UpperWick <= Range * marubozu wick share AND LowerWick <= Range * marubozu wick share
Short: BearishFVG
Short: BullIFVG
Short: PivotHigh(high, sweep lookback, confirmation bars) is defined AND close[confirmation bars] < highest(high, sweep lookback)[confirmation bars + 1]
Short: BearSetup[1] AND close >= open AND high < EMA(close, shorter EMA length) AND high >= EMA(close, longer EMA length)