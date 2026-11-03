Calculation: LSMA = weighted average of the last n closes, with weight (i − (n + 1) / 3) × 6 / (n × (n + 1)) for the close i bars ago, for i = 1…n
Calculation: LSMA angle = instrument-scaled difference between LSMA at the end shift and start shift, divided by twice the distance between those shifts
Long: chart-timeframe LSMA angle > its threshold OR higher-timeframe LSMA angle > its threshold (higher-timeframe bar still forming)
Short: chart-timeframe LSMA angle < −its threshold OR higher-timeframe LSMA angle < −its threshold (higher-timeframe bar still forming)