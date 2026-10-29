Calculation: Smoothed volume-weighted CCI = apply the selected smoothing method to CCI multiplied by selected volume, on the indicator timeframe (which may be higher or lower than the chart timeframe); evaluate at the selected signal-bar offset and the immediately preceding bar. Offset zero is still forming; a positive offset is completed.
Calculation: Direction state = rising when smoothed volume-weighted CCI is greater than its preceding bar, falling when it is less, and otherwise retain the preceding direction state.
Long: Previous direction state is falling AND current direction state is rising
Short: Previous direction state is rising AND current direction state is falling
Exit: long, current direction state is falling
Exit: short, current direction state is rising