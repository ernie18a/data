Calculation: Chart-bar intrabar volume delta = sum over T1 bars within each chart bar of (close > open ? volume : close < open ? 0 : volume / 2) minus sum over those bars of (close < open ? volume : close > open ? 0 : volume / 2), using T1 values on chart bars, including the T1 bar still forming
Long: chart-bar intrabar volume delta >= 0
Short: chart-bar intrabar volume delta < 0