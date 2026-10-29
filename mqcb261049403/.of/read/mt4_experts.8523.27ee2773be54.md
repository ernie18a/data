Calculation: Previous-day percentage deviation = 100 × (previous completed daily close / preceding completed daily close − 1); use daily bars from a timeframe higher than the chart timeframe.
Calculation: Aggregate open profit = sum of each open position’s signed profit in points, using the entry price, current price, and position side.
Long: For instrument 1, previous-day percentage deviation > 0 AND trading enabled AND broker time is 00:05–00:12 AND trading allowed
Long: For instrument 2, previous-day percentage deviation > 0 AND trading enabled AND broker time is 00:05–00:12 AND trading allowed
Long: For instrument 3, previous-day percentage deviation < 0 AND trading enabled AND broker time is 00:05–00:12 AND trading allowed
Long: For instrument 4, previous-day percentage deviation > 0 AND trading enabled AND broker time is 00:05–00:12 AND trading allowed
Long: For each open long position among instruments 1–4, aggregate open profit ≤ −emergency loss AND emergency trading enabled AND that position’s profit > 0
Short: For instrument 1, previous-day percentage deviation < 0 AND trading enabled AND broker time is 00:05–00:12 AND trading allowed
Short: For instrument 2, previous-day percentage deviation < 0 AND trading enabled AND broker time is 00:05–00:12 AND trading allowed
Short: For instrument 3, previous-day percentage deviation > 0 AND trading enabled AND broker time is 00:05–00:12 AND trading allowed
Short: For instrument 4, previous-day percentage deviation < 0 AND trading enabled AND broker time is 00:05–00:12 AND trading allowed
Short: For each open short position among instruments 1–4, aggregate open profit ≤ −emergency loss AND emergency trading enabled AND that position’s profit > 0
Exit: long and short, broker hour ≥ 23
Exit: long and short, profit monitoring enabled AND aggregate open profit ≥ profit target
Exit: long and short, loss monitoring enabled AND aggregate open profit ≤ −loss limit