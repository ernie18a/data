Calculation: T1 bullish state = MA(close, shorter lookback, T1 MA type, T1, last completed T1 bar; sampled on chart bars) > MA(close, longer lookback, T1 MA type, T1, last completed T1 bar; sampled on chart bars)
Calculation: T1 bearish state = MA(close, shorter lookback, T1 MA type, T1, last completed T1 bar; sampled on chart bars) < MA(close, longer lookback, T1 MA type, T1, last completed T1 bar; sampled on chart bars)
Calculation: T2 bullish state = MA(close, shorter trend lookback, T2 MA type, T2, last completed T2 bar; sampled on chart bars) > MA(close, longer trend lookback, T2 MA type, T2, last completed T2 bar; sampled on chart bars) AND close(T2, last completed bar; sampled on chart bars) > MA(close, price-filter lookback, T2 MA type, T2, last completed T2 bar; sampled on chart bars)
Calculation: T2 bearish state = MA(close, shorter trend lookback, T2 MA type, T2, last completed T2 bar; sampled on chart bars) < MA(close, longer trend lookback, T2 MA type, T2, last completed T2 bar; sampled on chart bars) AND close(T2, last completed bar; sampled on chart bars) < MA(close, price-filter lookback, T2 MA type, T2, last completed T2 bar; sampled on chart bars)
Calculation: T3 bullish state = MA(close, shorter lookback, T3 MA type, T3, last completed T3 bar; sampled on chart bars) > MA(close, longer lookback, T3 MA type, T3, last completed T3 bar; sampled on chart bars)
Calculation: T3 bearish state = MA(close, shorter lookback, T3 MA type, T3, last completed T3 bar; sampled on chart bars) < MA(close, longer lookback, T3 MA type, T3, last completed T3 bar; sampled on chart bars)
Calculation: Full bullish alignment = T1 bullish state AND T2 bullish state AND T3 bullish state
Calculation: Full bearish alignment = T1 bearish state AND T2 bearish state AND T3 bearish state
Calculation: T3 event gate = on chart bars, the time of the last completed T3 bar changes AND (chart-bar-close confirmation is disabled OR the chart bar is confirmed)
Calculation: T3 prior swing high = Highest(high[1], swing lookback, T3, last completed T3 bar; sampled on chart bars)
Calculation: T3 prior swing low = Lowest(low[1], swing lookback, T3, last completed T3 bar; sampled on chart bars)
Calculation: BOS strength passes = strength filter is disabled OR abs(close(T3, last completed bar) - open(T3, last completed bar)) >= SMA(abs(close - open), body-average lookback, T3, last completed T3 bar; sampled on chart bars) * BOS strength multiplier
Calculation: Bullish BOS = T3 event gate AND close(T3, last completed bar) > T3 prior swing high AND BOS strength passes
Calculation: Bearish BOS = T3 event gate AND close(T3, last completed bar) < T3 prior swing low AND BOS strength passes
Calculation: Active BOS = the side and corresponding swing level from the most recent BOS; empty before a BOS, replaced on each BOS, unretested until its first qualifying retest
Calculation: Active BOS valid = validity window is disabled OR completed T3 bars since the active BOS <= BOS validity lookback
Calculation: Long retest = T3 event gate AND active BOS side is bullish AND active BOS is unretested AND active BOS is valid AND close(T3, last completed bar) > active BOS level AND the selected retest-method test passes: low(T3, last completed bar) <= active BOS level OR abs(low(T3, last completed bar) - active BOS level) <= ATR(ATR lookback, T3, last completed T3 bar; sampled on chart bars) * ATR proximity multiplier
Calculation: Short retest = T3 event gate AND active BOS side is bearish AND active BOS is unretested AND active BOS is valid AND close(T3, last completed bar) < active BOS level AND the selected retest-method test passes: high(T3, last completed bar) >= active BOS level OR abs(high(T3, last completed bar) - active BOS level) <= ATR(ATR lookback, T3, last completed T3 bar; sampled on chart bars) * ATR proximity multiplier
Long: T1 bullish state
Long: T2 bullish state
Long: T3 bullish state
Long: Full bullish alignment AND NOT Full bullish alignment[1]
Long: T1 bullish state AND NOT T1 bullish state[1]
Long: T2 bullish state AND NOT T2 bullish state[1]
Long: T3 bullish state AND NOT T3 bullish state[1]
Long: Bullish BOS
Long: Bullish BOS AND Full bullish alignment
Long: Long retest
Long: Long retest AND Full bullish alignment
Short: T1 bearish state
Short: T2 bearish state
Short: T3 bearish state
Short: Full bearish alignment AND NOT Full bearish alignment[1]
Short: T1 bearish state AND NOT T1 bearish state[1]
Short: T2 bearish state AND NOT T2 bearish state[1]
Short: T3 bearish state AND NOT T3 bearish state[1]
Short: Bearish BOS
Short: Bearish BOS AND Full bearish alignment
Short: Short retest
Short: Short retest AND Full bearish alignment