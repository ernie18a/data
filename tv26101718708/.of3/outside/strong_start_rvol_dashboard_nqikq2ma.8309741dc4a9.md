Calculation: Percentage change = (T1 close - previous T1 close) / previous T1 close × 100
Calculation: RVOL rank = rank of relative volume among watchlist symbols with valid relative volume, highest first
Long: T1 open > previous T1 close AND T1 low >= previous T1 close × gap-hold multiplier
Long: RVOL rank < max(1, round(number of watchlist symbols with valid relative volume × top-ranked percentage / 100)) AND percentage change >= move threshold
Short: RVOL rank < max(1, round(number of watchlist symbols with valid relative volume × top-ranked percentage / 100)) AND percentage change <= -move threshold