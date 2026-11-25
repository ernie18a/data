Calculation: fast MA = MA(fast applied price, fast method, shorter lookback, fast shift, T1, last completed bar), read on chart bars
Calculation: slow MA = MA(slow applied price, slow method, longer lookback, slow shift, T1, last completed bar), read on chart bars
Long: after fast MA > slow MA, current Ask >= signal Ask + breakout distance AND fast MA >= slow MA AND hour(datetime) < cutoff hour AND NOT (Friday close enabled AND Friday(datetime) AND hour(datetime) >= Friday close hour)
Short: after fast MA < slow MA, current Bid <= signal Bid - breakout distance AND fast MA <= slow MA AND hour(datetime) < cutoff hour AND NOT (Friday close enabled AND Friday(datetime) AND hour(datetime) >= Friday close hour)
Exit: long, fast MA < slow MA OR (Friday close enabled AND Friday(datetime) AND hour(datetime) >= Friday close hour)
Exit: short, fast MA > slow MA OR (Friday close enabled AND Friday(datetime) AND hour(datetime) >= Friday close hour)