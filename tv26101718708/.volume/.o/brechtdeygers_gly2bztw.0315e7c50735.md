Calculation: Displacement = abs(close − open) > ATR × displacement multiplier AND volume / simple moving average of volume ≥ minimum volume ratio
Calculation: Demand zone = previous bar’s low-to-high range, created when close > open and Displacement is true
Calculation: Supply zone = previous bar’s low-to-high range, created when close ≤ open and Displacement is true
Calculation: First retest = the first bar whose range intersects a fresh zone without breaching it
Calculation: Long entry = zone top − zone height × entry-depth fraction; long stop = zone bottom − ATR × stop-buffer multiplier; long target = long entry + (long entry − long stop) × risk/reward ratio
Calculation: Short entry = zone bottom + zone height × entry-depth fraction; short stop = zone top + ATR × stop-buffer multiplier; short target = short entry − (short stop − short entry) × risk/reward ratio
Long: First retest of a fresh demand zone AND close > EMA
Short: First retest of a fresh supply zone AND close < EMA
Exit: long, high ≥ long target OR low ≤ long stop
Exit: short, low ≤ short target OR high ≥ short stop