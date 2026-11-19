Calculation: OpeningRangeHigh = highest(high, opening-range period on chart bars), fixed after the period ends
Calculation: OpeningRangeLow = lowest(low, opening-range period on chart bars), fixed after the period ends
Calculation: CandleBodyLength = abs(close - open)
Calculation: UpperWickLength = high - max(open, close)
Calculation: LowerWickLength = min(open, close) - low
Long: EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback) OR crosses above(high, OpeningRangeHigh) after the opening-range period OR (LowerWickLength >= CandleBodyLength * wick/body threshold AND UpperWickLength <= CandleBodyLength * opposite-wick/body limit AND CandleBodyLength > 0 AND close > open) OR (close[1] < open[1] AND close > open AND close > open[1] AND open < close[1])
Short: EMA(close, shorter EMA lookback) <= EMA(close, longer EMA lookback) OR crosses below(low, OpeningRangeLow) after the opening-range period OR (UpperWickLength >= CandleBodyLength * wick/body threshold AND LowerWickLength <= CandleBodyLength * opposite-wick/body limit AND CandleBodyLength > 0 AND close < open) OR (close[1] > open[1] AND close < open AND close < open[1] AND open > close[1])