Calculation: dLogRSI_close = current minus previous-bar value of RSI(ln(close)); dLogRSI_low = same using ln(low); lookback is the same for both
Calculation: osc = EMA(close, shorter lookback) - EMA(close, longer lookback)
Calculation: M = current minus previous-bar value of RSI(osc, long lookback)
Calculation: S = current minus previous-bar value of RSI(EMA(M, smoothing lookback), same long lookback as in M)
Calculation: T = (M + S) / 2
Long: (dLogRSI_close crosses above level A1 OR dLogRSI_close crosses above level A2, where A2 < A1 OR dLogRSI_low crosses above level A3, where A3 > A1; all levels positive) AND close > open of the still-forming bar on every one of several other timeframes (each may be higher or lower than the chart timeframe)
Long: (M OR S OR T crosses above any one of several ascending positive levels, each level checked separately) AND close > open of the still-forming bar on every one of several other timeframes (each may be higher or lower than the chart timeframe)
Short: (dLogRSI_low crosses below -A3 OR dLogRSI_close crosses below -A1 OR dLogRSI_close crosses below -A2) AND close < open of the still-forming bar on every one of several other timeframes (each may be higher or lower than the chart timeframe)
Short: (M OR S OR T crosses below any one of several descending negative levels, the mirror of the long levels, each level checked separately) AND close < open of the still-forming bar on every one of several other timeframes (each may be higher or lower than the chart timeframe)