Calculation: CloseLocation = (close - low) / (high - low) if high > low, else the midpoint value
Calculation: ExtBaseline = EMA(close, shorter lookback), EMA(close, longer lookback), or SMA(close, longest lookback), as selected by the extension baseline
Calculation: ExtMinDistance = ATR(ext ATR lookback) * ext ATR multiplier
Calculation: PivotLeft = pivot left lookback (weekly/monthly) if the chart is weekly or monthly, else pivot left lookback (other)
Calculation: NewBasePivot = PivotHigh(high, PivotLeft, pivot right lookback) is not na AND (BaseHigh[1] is na OR (PivotHigh(high, PivotLeft, pivot right lookback) > BaseHigh[1] AND (PivotHigh(high, PivotLeft, pivot right lookback) - Lowest(low, prior low lookback)[pivot right lookback]) / Lowest(low, prior low lookback)[pivot right lookback] * 100 >= min prior gain))
Calculation: TestHigh = PivotHigh(high, PivotLeft, pivot right lookback) if NewBasePivot, else BaseHigh[1]
Calculation: TestStart = bar index - pivot right lookback if NewBasePivot, else CandStart[1]
Calculation: TestLow = Lowest(low, pivot right lookback + 1) if NewBasePivot, else min(CandLow[1], low)
Calculation: BaseReset = high > TestHigh AND bar index - TestStart < min base length
Calculation: CandHigh = na if (TestHigh - TestLow) / TestHigh * 100 > max base depth OR bar index - TestStart > max base duration, else high if BaseReset, else TestHigh
Calculation: CandStart = bar index if BaseReset, else TestStart
Calculation: CandLow = low if BaseReset, else TestLow
Calculation: BaseBars = bar index - CandStart
Calculation: BaseRangePct = (CandHigh - CandLow) / CandHigh * 100
Calculation: BreakoutOfBase = BaseBars >= min base length AND close > CandHigh AND close[1] <= CandHigh
Calculation: BaseHigh = na if BreakoutOfBase, else CandHigh
Calculation: RightLowOffset = bars-back index of the lowest low over bars 1 through floor(BaseBars / 2) - 1
Calculation: LeftLowOffset = bars-back index of the lowest low over bars floor(BaseBars / 2) through BaseBars
Calculation: MiddleHigh = highest high over bars from RightLowOffset back through LeftLowOffset back
Calculation: BaseType = high tight flag if BaseBars <= HTF max duration AND BaseRangePct <= HTF max depth; else cup with handle if Lowest(low, max(min handle bars, floor(BaseBars * handle bar fraction)))[1] >= CandLow + (CandHigh - CandLow) * handle level fraction AND BaseRangePct >= cup min depth; else double bottom if MiddleHigh >= CandLow + (CandHigh - CandLow) * W peak fraction AND BaseRangePct >= W min depth; else flat base if BaseBars <= flat max duration AND BaseRangePct <= flat max depth; else base
Long: (count of i from 1 to pullback window where close[i] < EMA(close, shorter lookback)[i]) >= min pullback bars AND close > EMA(close, shorter lookback) AND close > EMA(close, longer lookback) AND (close[1] <= EMA(close, shorter lookback)[1] OR close[1] <= EMA(close, longer lookback)[1]) AND close > open
Long: ExtBaseline - close >= ExtMinDistance AND CloseLocation >= reversal close limit AND high < ExtBaseline AND volume > SMA(volume, volume lookback) AND close < EMA(close, T1 lookback, T1, last completed bar)
Long: volume >= SMA(volume, volume lookback) * HVC volume multiplier AND CloseLocation >= HVC close limit
Long: abs(close - open) >= ATR(ignite ATR lookback) * ignite body multiplier AND CloseLocation >= ignite close limit AND volume > SMA(volume, volume lookback) * ignite volume multiplier
Long: (high[1] - max(open[1], close[1])) > (high[1] - low[1]) * upper-wick ratio AND open > max(open[1], close[1]) AND open < high[1] AND close > open
Long: low < low[1] AND close > high[1] AND close > open
Long: low < Lowest(low, undercut lookback)[1] AND close > Lowest(low, undercut lookback)[1] AND close > open
Long: BreakoutOfBase AND BaseType = high tight flag
Long: BreakoutOfBase AND BaseType = cup with handle
Long: BreakoutOfBase AND BaseType = double bottom
Long: BreakoutOfBase AND BaseType = flat base
Long: BreakoutOfBase AND BaseType = base
Short: close - ExtBaseline >= ExtMinDistance AND CloseLocation <= exhaustion close limit AND low > ExtBaseline AND volume > SMA(volume, volume lookback) AND close > EMA(close, T1 lookback, T1, last completed bar)
Short: (close[1] >= EMA(close, shorter lookback)[1] OR close[1] >= EMA(close, longer lookback)[1]) AND close < EMA(close, shorter lookback) AND close < EMA(close, longer lookback) AND close < open