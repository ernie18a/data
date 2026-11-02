Calculation: Swing high and swing low = highest high and lowest low, respectively, over the extreme lookback including the current chart bar; the age of each is the number of chart bars since its most recent occurrence.
Calculation: Short distance = (swing high - close) / swing high; long distance = (close - swing low) / swing low.
Calculation: Short reversal = high < previous high AND close < previous low; long reversal = low > previous low AND close > previous high.
Calculation: Regime = ADX of the last completed higher-timeframe bar.
Calculation: Armed = regime >= unlock threshold AND extreme age > shorter impulse-age threshold AND extreme age <= longer freshness threshold AND distance <= armed-distance threshold AND reversal = false.
Calculation: Window = regime >= unlock threshold AND extreme age <= freshness threshold AND reversal = true AND distance <= window-distance threshold.
Calculation: Active = armed = true OR window = true, using the swing extreme, distance, and reversal corresponding to the position side.
Long: regime >= unlock threshold AND swing low age <= freshness threshold AND long reversal = true.
Long: armed = true using the swing low, long distance, and long reversal AND armed on the previous bar = false.
Short: regime >= unlock threshold AND swing high age <= freshness threshold AND short reversal = true.
Short: armed = true using the swing high, short distance, and short reversal AND armed on the previous bar = false.
Exit: long, active on the previous bar = true AND active = false.
Exit: short, active on the previous bar = true AND active = false.