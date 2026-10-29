Calculation: Gap top = max(close of the last completed chart bar before a new configured higher-timeframe gap period, open of the first chart bar in that period)
Calculation: Gap bottom = min(close of the last completed chart bar before a new configured higher-timeframe gap period, open of the first chart bar in that period)
Calculation: Above-gap flag = true after any bar since the latest gap period began has high > gap top; reset when a new gap period begins
Calculation: Below-gap flag = true after any bar since the latest gap period began has low < gap bottom; reset when a new gap period begins
Calculation: Trade-available flag = true until an entry occurs; reset at each day boundary
Long: Trade-available flag AND position is flat AND gap exists AND above-gap flag AND low <= gap top AND low > gap bottom
Short: Trade-available flag AND position is flat AND gap exists AND below-gap flag AND high >= gap bottom AND high < gap top
Exit: long, low reaches or falls below the trailing stop
Exit: short, high reaches or rises above the trailing stop