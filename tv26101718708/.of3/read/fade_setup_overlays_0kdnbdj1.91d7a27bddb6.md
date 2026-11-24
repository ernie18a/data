Calculation: extreme age(side) = chart bars since the most recent chart bar whose high equals highest(high, extreme lookback) for short, or whose low equals lowest(low, extreme lookback) for long
Calculation: distance from extreme(side) (%) = 100 × (highest(high, extreme lookback) − close) / highest(high, extreme lookback) for short, or 100 × (close − lowest(low, extreme lookback)) / lowest(low, extreme lookback) for long
Calculation: reversal(side) = high < high[1] AND close < low[1] for short; low > low[1] AND close > high[1] for long
Calculation: regime unlocked = ADX(DI lookback, ADX smoothing, T1 bars), using the last completed T1 bar, >= regime threshold
Calculation: fade armed(side) = regime unlocked AND extreme age(side) > impulse age AND extreme age(side) <= freshness AND distance from extreme(side) <= armed-distance limit AND NOT reversal(side)
Calculation: fade active(side) = fade armed(side) OR (regime unlocked AND extreme age(side) <= freshness AND reversal(side) AND distance from extreme(side) <= window-distance limit)
Long: selected side is long AND (fade armed(long) OR (regime unlocked AND extreme age(long) <= freshness AND reversal(long)))
Short: selected side is short AND (fade armed(short) OR (regime unlocked AND extreme age(short) <= freshness AND reversal(short)))
Exit: long, fade active(long) on the previous chart bar AND NOT fade active(long) on the current chart bar
Exit: short, fade active(short) on the previous chart bar AND NOT fade active(short) on the current chart bar