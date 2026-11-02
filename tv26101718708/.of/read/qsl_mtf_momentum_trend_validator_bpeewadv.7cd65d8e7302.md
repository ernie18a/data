Calculation: Moving averages = four moving averages of the chosen price source, using the same selectable type (SMA, EMA, or DEMA) and successively longer lengths.
Calculation: Timeframe values = calculate each selected moving average, ATR, slope, and momentum candle on the chart timeframe or on selected higher or lower timeframes; for other timeframes use either the last completed bar or the still-forming bar, consistently as selected.
Calculation: Pair counts = for each selected timeframe, count adjacent moving-average pairs where the shorter average is greater than the longer average as bullish pairs, and those where it is less as bearish pairs.
Calculation: Bias counts = for each moving-average length, sort selected timeframes from shorter to longer and count adjacent timeframe pairs where the average on the shorter timeframe is greater than its value on the longer timeframe as bullish pairs, and those where it is less as bearish pairs.
Calculation: Alignment counts = count selected timeframes with three bullish pairs and those with three bearish pairs.
Calculation: Normalized slope = change in a moving average over a selected number of its timeframe's bars divided by that number and by current ATR. Joint slope is the smaller normalized slope when both shortest averages have positive slopes, the larger when both have negative slopes, and zero otherwise.
Calculation: Stack score = weighted mean across selected timeframes of (bullish pair count minus bearish pair count) / 3 multiplied by (0.6 + 0.4 × min(abs(shortest moving average minus longest moving average) / ATR / separation threshold, 1)); use zero separation when ATR is unavailable or nonpositive. Weights are equal or increase with timeframe rank from shortest to longest.
Calculation: Momentum candidate = a bar with positive open whose percentage change is 100 × (close − open) / open and whose turnover is volume × close; relative turnover is 100 × (bar turnover / mean turnover over the selected trailing day of bars, including that bar − 1). A candidate passes when turnover is at least its threshold or that threshold is zero, AND relative turnover is at least its threshold or that threshold is zero. Search the selected lookback of momentum-timeframe bars ending at the selected completed or forming bar. The latest qualifying candidate is the most recent passing bar whose percentage change is at least the positive change threshold or at most its negative; if both directions qualify on the same bar, prefer up.
Long: On the chart timeframe, the shortest moving average is greater than or equal to the second-shortest moving average OR the shortest moving average is greater than or equal to the longest moving average.
Short: On the chart timeframe, the shortest moving average is less than the second-shortest moving average OR the shortest moving average is less than the longest moving average.
Long: On any selected timeframe, a shorter moving average is greater than the next longer moving average.
Short: On any selected timeframe, a shorter moving average is less than the next longer moving average.
Long: For any moving-average length, bullish bias pairs outnumber bearish bias pairs.
Short: For any moving-average length, bearish bias pairs outnumber bullish bias pairs.
Long: On any selected timeframe, bullish pairs outnumber bearish pairs.
Short: On any selected timeframe, bearish pairs outnumber bullish pairs.
Long: Bullish alignment count exceeds bearish alignment count.
Short: Bearish alignment count exceeds bullish alignment count.
Long: On any selected timeframe, joint slope is greater than zero.
Short: On any selected timeframe, joint slope is less than zero.
Long: Stack score is greater than zero.
Short: Stack score is less than zero.
Long: The latest qualifying momentum candidate has percentage change at least the positive change threshold.
Short: The latest qualifying momentum candidate has percentage change at most the negative change threshold AND the same candidate does not also meet the positive change threshold.
Long: No qualifying momentum candidate exists in the lookback AND the selected momentum-timeframe bar has percentage change greater than or equal to zero.
Short: No qualifying momentum candidate exists in the lookback AND the selected momentum-timeframe bar has percentage change less than zero.
Long: On the chart timeframe, all four moving averages are ordered from highest to lowest as their lengths increase AND this ordering was false on the previous chart bar.
Short: On the chart timeframe, all four moving averages are ordered from lowest to highest as their lengths increase AND this ordering was false on the previous chart bar.
Long: Every selected timeframe has three bullish pairs AND this was false on the previous chart bar.
Short: Every selected timeframe has three bearish pairs AND this was false on the previous chart bar.
Long: The selected momentum-timeframe bar is an up candidate AND the preceding chart bar did not indicate a current up candidate.
Short: The selected momentum-timeframe bar is a down candidate AND the preceding chart bar did not indicate a current down candidate.