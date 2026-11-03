Calculation: Pivot level = a confirmed pivot high or low, using equal left and right lookbacks on chart-timeframe bars
Calculation: ATR = average true range
Calculation: Level mass = 1 initially; add 1.618 × 0.5 for each nearby pivot rejected as a duplicate, and add 1.618 × cut ratio on each bar that intersects the level
Calculation: Cut ratio = min(high − level, level − low) / (high − low) when high > level and low < level; otherwise 0
Long: low pivot level, level mass × 5 ≤ 20, no existing level within ATR × sensitivity, absolute(close − level) > ATR × inertia threshold, and (level has not been intersected or close > level)
Short: high pivot level, level mass × 5 ≤ 20, no existing level within ATR × sensitivity, absolute(close − level) > ATR × inertia threshold, and (level has not been intersected or close < level)