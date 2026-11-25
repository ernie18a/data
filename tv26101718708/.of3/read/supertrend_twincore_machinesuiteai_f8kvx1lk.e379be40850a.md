Calculation: candidate win rate = cumulative share of candidates whose close at the outcome-lookahead bars after the candidate close moved strictly in the candidate direction
Calculation: active fast trend = adaptive Supertrend(fast multiplier selected by LOW/MID/HIGH PercentRank(ATR(shorter fast lookback)/close, regime lookback), shorter fast ATR lookback) when adaptive mode is Always or measured and its candidate win rate exceeds the fixed fast candidate win rate by the improvement margin with both samples at least the minimum; otherwise fixed Supertrend(fixed multiplier, shorter fast ATR lookback)
Calculation: consensus candidate = first chart bar on which the selected fast-trend stream and the slow Supertrend(slow multiplier, longer slow ATR lookback) agree in a direction not shared on the preceding bar; fixed and adaptive streams use their own prior consensus histories
Calculation: signal blocked = enabled flip-cluster gate and rolling sum of selected fast-trend direction changes over the flip window at least the flip threshold, OR enabled ADX gate and ADX below its threshold (the gate is Always, or Measured when the high-ADX candidate win rate exceeds the low-ADX candidate win rate by the improvement margin with both samples at least the minimum), OR enabled strict T1 gate and the T1 Supertrend direction differs from the candidate direction; T1 values are read from its last completed bar on chart bars
Long: on a confirmed chart bar, consensus candidate direction is up AND signal is not blocked
Short: on a confirmed chart bar, consensus candidate direction is down AND signal is not blocked
Long: on a confirmed chart bar, consensus candidate direction is up AND signal is blocked
Short: on a confirmed chart bar, consensus candidate direction is down AND signal is blocked
Exit: long, on a confirmed bar after entry, the selected trailing-stop Supertrend (fast or slow) flips down
Exit: short, on a confirmed bar after entry, the selected trailing-stop Supertrend (fast or slow) flips up
Exit: long, on a confirmed bar after entry, low <= entry price - fixed stop ATR multiple × ATR(shorter fast lookback) at entry OR slow Supertrend flips down
Exit: short, on a confirmed bar after entry, high >= entry price + fixed stop ATR multiple × ATR(shorter fast lookback) at entry OR slow Supertrend flips up
Exit: long, on a confirmed bar after entry, high >= entry price + first target multiplier × ATR(shorter fast lookback) at entry
Exit: long, on a confirmed bar after entry, high >= entry price + second target multiplier × ATR(shorter fast lookback) at entry
Exit: long, on a confirmed bar after entry, high >= entry price + third target multiplier × ATR(shorter fast lookback) at entry
Exit: short, on a confirmed bar after entry, low <= entry price - first target multiplier × ATR(shorter fast lookback) at entry
Exit: short, on a confirmed bar after entry, low <= entry price - second target multiplier × ATR(shorter fast lookback) at entry
Exit: short, on a confirmed bar after entry, low <= entry price - third target multiplier × ATR(shorter fast lookback) at entry