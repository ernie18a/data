Calculation: Timeframe score = For each of four configurable timeframes, add +1 if close > bias EMA and -1 otherwise, and add +1 if shorter-term EMA > longer-term EMA and -1 otherwise; if ADX < its trend threshold, divide the sum by 2 and round to the nearest integer. The bias EMA has a longer period than the longer-term EMA. Calculate on each timeframe's bars; for a higher timeframe use the last completed bar, for a lower timeframe use the last completed intrabar within the chart bar, and for the chart timeframe use the current bar.
Calculation: Consensus = sum of the four timeframe scores divided by the maximum possible sum.
Long: Any timeframe score > 0
Short: Any timeframe score < 0
Long: Consensus >= bullish consensus threshold
Short: Consensus <= bearish consensus threshold
Long: Every timeframe score equals its maximum possible value
Short: Every timeframe score equals its minimum possible value
Long: Previous chart bar consensus <= 0 AND current consensus > bullish consensus threshold
Short: Previous chart bar consensus >= 0 AND current consensus < bearish consensus threshold
Long: RSI on any of the four timeframes >= bullish RSI threshold
Short: RSI on any of the four timeframes < bearish RSI threshold