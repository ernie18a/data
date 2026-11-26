Calculation: comparison prices = (close, close) or (low, high), selected by a parameter
Calculation: Trend(T) runs on T bars, including the bar still forming; on the first available bar, Trend is long if close > open and short otherwise; on each later bar, if the prior Trend is long, Trend is long if the long comparison price > low[n] for any n from 1 through the lookback and short otherwise; if the prior Trend is short, Trend is short if the short comparison price < high[n] for any n from 1 through the lookback and long otherwise
Long: Trend on chart bars = long
Short: Trend on chart bars = short
Long: on the first chart bar of each T1 bar, Trend on the still-forming T1 bar = long
Short: on the first chart bar of each T1 bar, Trend on the still-forming T1 bar = short