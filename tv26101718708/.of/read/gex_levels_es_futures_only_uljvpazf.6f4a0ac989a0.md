Calculation: Premium = futures close minus cash-index close from the last completed bars of the same higher timeframe, when their close timestamps match
Calculation: GEX level = manually supplied base level + Premium
Calculation: Short zone = adjusted short-zone lower and upper levels
Calculation: Long zone = adjusted long-zone lower and upper levels
Calculation: Confirmed swing high/low = pivot high/low confirmed after the same number of bars on each side
Long: (high >= Long zone lower level AND low <= Long zone upper level) OR (close > adjusted ceiling AND close crosses above the latest confirmed swing high)
Short: (high >= Short zone lower level AND low <= Short zone upper level) OR (close < adjusted zero-gamma level AND close crosses below the latest confirmed swing low)
Exit: long, low <= adjusted long stop level OR high >= adjusted long target 1 level OR high >= adjusted long target 2 level
Exit: short, high >= adjusted short stop level OR low <= adjusted short target 1 level OR low <= adjusted short target 2 level