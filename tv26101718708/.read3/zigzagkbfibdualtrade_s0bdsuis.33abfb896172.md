Calculation: Active A→B swing = the most recent ZigZag pivot whose end price is below its start price, using the price-deviation and minimum pivot-separation parameters; A is its start price and B is its end price, updated to the current low while the current bar is the pivot endpoint
Calculation: Trade state = waiting for T1 when a new active swing appears; in T1 after a T1 long signal; waiting for T1 after a T1 stop; waiting for T2 after a T1 target; in T2 after a T2 long signal; after a T2 stop, waiting for T2 if a T1 long signal has occurred since the active swing appeared, otherwise waiting for T1; done after a T2 target; state persists until a listed transition or a new active swing
Calculation: T1 stop level = B + (A − B) × T1 stop retracement parameter
Calculation: T1 entry threshold = B + (A − B) × T1 entry-zone upper-bound parameter
Calculation: T1 target and T2 stop level = B + (A − B) × T1 target-zone lower-bound parameter
Calculation: T2 entry threshold = B + (A − B) × T1 target-zone upper-bound parameter
Calculation: T2 target level = B + (A − B) × T2 target-zone lower-bound parameter
Long: trade state is waiting for T1 AND close > T1 entry threshold AND close[1] <= T1 entry threshold AND NOT (close > T2 entry threshold AND close[1] <= T2 entry threshold) AND (EMA filter disabled OR (close > EMA(close, shorter lookback) AND close > EMA(close, longer lookback))) AND (volume filter disabled OR volume > volume multiplier × SMA(volume, lookback))
Long: trade state is waiting for T1 or waiting for T2 AND close > T2 entry threshold AND close[1] <= T2 entry threshold AND (EMA filter disabled OR (close > EMA(close, shorter lookback) AND close > EMA(close, longer lookback))) AND (volume filter disabled OR volume > volume multiplier × SMA(volume, lookback))
Exit: long, trade state is in T1 AND high >= T1 target and T2 stop level
Exit: long, trade state is in T1 AND high < T1 target and T2 stop level AND close < T1 stop level
Exit: long, trade state is in T2 AND high >= T2 target level
Exit: long, trade state is in T2 AND high < T2 target level AND close < T1 target and T2 stop level