Long: On chart bars with timeframe <= T2, close > open(T1, bar still forming, on chart bars taking values from T1)
Short: On chart bars with timeframe <= T2, close < open(T1, bar still forming, on chart bars taking values from T1)
Calculation: Daily percentage change = (selected asset close - selected asset open at T1) / selected asset open at T1 * 100
Long: chart timeframe is intraday AND daily percentage change >= 0
Short: chart timeframe is intraday AND daily percentage change <= 0