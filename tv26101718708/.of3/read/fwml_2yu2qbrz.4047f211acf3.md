Calculation: PriorHigh(T) = high of the last completed T bar, taken on chart bars
Calculation: PriorLow(T) = low of the last completed T bar, taken on chart bars
Calculation: PremarketHigh = highest high of the chart bars in the current day's premarket session
Calculation: PremarketLow = lowest low of the chart bars in the current day's premarket session
Calculation: OpeningHigh = high of the first T3 bar of the regular session of the current day, taken on chart bars once that bar is completed
Calculation: OpeningLow = low of the first T3 bar of the regular session of the current day, taken on chart bars once that bar is completed
Calculation: CallScore = count of true among: close > PriorHigh(T1), close > PremarketHigh, close > PriorHigh(T2), close > OpeningHigh, close > VWAP(hlc3, session), close > EMA(close, lookback, T4, last completed bar), where T2 is longer than T1
Calculation: PutScore = count of true among: close < PriorLow(T1), close < PremarketLow, close < PriorLow(T2), close < OpeningLow, close < VWAP(hlc3, session), close < EMA(close, lookback, T4, last completed bar), where T2 is longer than T1
Long: close > PriorHigh(T1)
Long: close > PremarketHigh
Long: close > PriorHigh(T2)
Long: close > OpeningHigh
Long: close > VWAP(hlc3, session)
Long: close > EMA(close, lookback, T4, last completed bar)
Long: CallScore > PutScore
Short: close < PriorLow(T1)
Short: close < PremarketLow
Short: close < PriorLow(T2)
Short: close < OpeningLow
Short: close < VWAP(hlc3, session)
Short: close < EMA(close, lookback, T4, last completed bar)
Short: PutScore > CallScore