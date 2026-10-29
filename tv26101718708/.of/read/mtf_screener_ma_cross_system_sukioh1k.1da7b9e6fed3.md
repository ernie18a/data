Calculation: Long initial stop = entry price × (1 − stop percentage) in percentage mode, or entry price − ATR × stop multiplier in ATR mode
Calculation: Long target = entry price × (1 + target percentage) in percentage mode, or entry price + ATR × stop multiplier × risk/reward ratio in ATR mode
Calculation: Short initial stop = entry price × (1 + stop percentage) in percentage mode, or entry price + ATR × stop multiplier in ATR mode
Calculation: Short target = entry price × (1 − target percentage) in percentage mode, or entry price − ATR × stop multiplier × risk/reward ratio in ATR mode
Calculation: Risk/reward progress = (close − entry price) / initial risk for a long position, or (entry price − close) / initial risk for a short position
Calculation: Long advanced stop = max(entry price, close − ATR × trailing multiplier) after the partial-close trigger
Calculation: Short advanced stop = min(entry price, close + ATR × trailing multiplier) after the partial-close trigger
Long: Selected fast/medium, fast/slow, or medium/slow moving-average pair crosses upward
Long: Selected fast/medium, fast/slow, or medium/slow moving-average pair crosses upward AND close > higher-timeframe HMA calculated from the last completed higher-timeframe bar
Short: Selected fast/medium, fast/slow, or medium/slow moving-average pair crosses downward
Short: Selected fast/medium, fast/slow, or medium/slow moving-average pair crosses downward AND close < higher-timeframe HMA calculated from the last completed higher-timeframe bar
Exit: Long, low ≤ long initial stop OR high ≥ long target
Exit: Short, high ≥ short initial stop OR low ≤ short target
Exit: Long, risk/reward progress ≥ break-even trigger AND low ≤ entry price
Exit: Short, risk/reward progress ≥ break-even trigger AND high ≥ entry price
Exit: Long, risk/reward progress ≥ partial-close trigger (close partial position); after trigger, low ≤ entry price
Exit: Short, risk/reward progress ≥ partial-close trigger (close partial position); after trigger, high ≥ entry price
Exit: Long, risk/reward progress ≥ partial-close trigger AND low ≤ long advanced stop
Exit: Short, risk/reward progress ≥ partial-close trigger AND high ≥ short advanced stop