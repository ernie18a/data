Calculation: T1 swing-high pivot = latest T1 bar whose high equals highest(high, swing lookback); reconstructed on chart bars from T1 values, including the still-forming T1 bar
Calculation: T1 swing-low pivot = latest T1 bar whose low equals lowest(low, swing lookback); reconstructed on chart bars from T1 values, including the still-forming T1 bar
Calculation: T1 swing direction = up when the latest swing-high pivot is later than the latest swing-low pivot, otherwise down
Calculation: Confirmed T1 swing-high anchor = latest swing-high pivot when direction changes from up to down; confirmed T1 swing-low anchor = latest swing-low pivot when direction changes from down to up
Long: confirmed swing-high anchor high > previous confirmed swing-high anchor high OR confirmed swing-low anchor low > previous confirmed swing-low anchor low
Short: confirmed swing-high anchor high < previous confirmed swing-high anchor high OR confirmed swing-low anchor low < previous confirmed swing-low anchor low