Long: SMA(IF(funding-rate close(T1) is nonzero, funding-rate close(T1), IF(perpetual close(T1) − open(T1) is missing, 0, (perpetual close(T1) − open(T1)) × parameter)), lookback) on chart bars using T1 values (the still-forming T1 bar in real time, the last completed T1 bar historically) crosses below zero
Calculation: Adjusted funding rate = funding rate on T1 if nonzero; otherwise, zero if perpetual price change on T1 is unavailable, or P1 × (perpetual close − open on T1)
Calculation: Funding-rate SMA = SMA(Adjusted funding rate, P2)
Short: Funding-rate SMA crosses above P3
Exit: short, Funding-rate SMA crosses below P3
Short: Funding-rate SMA crosses above P4
Long: Funding-rate SMA crosses below zero