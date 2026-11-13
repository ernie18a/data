Calculation: BullTFs = count of the six timeframes (a set spanning timeframes lower than and higher than the chart timeframe, same EMA length for all) in which that timeframe's close > EMA(close) of that timeframe; each timeframe uses the bar containing the current chart bar, still forming (not the last completed bar)
Calculation: BearTFs = count of the same six timeframes in which that timeframe's close < EMA(close) of that timeframe, with the same bar usage
Long: Supertrend direction on the chart timeframe changes from downtrend to uptrend on this bar AND BullTFs >= a minimum bullish count
Short: Supertrend direction on the chart timeframe changes from uptrend to downtrend on this bar AND BearTFs >= a minimum bearish count
Exit: long, Short condition is true on this bar (position reverses to short)
Exit: short, Long condition is true on this bar (position reverses to long)