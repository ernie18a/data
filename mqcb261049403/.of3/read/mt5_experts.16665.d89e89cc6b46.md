Calculation: Fast trend = JFATL(applied price, shorter lookback)
Calculation: Slow trend = X2MA(applied price, longer lookback)
Long: Fast trend > Fast trend[1]
Short: Fast trend < Fast trend[1]
Long: Slow trend > Slow trend[1]
Short: Slow trend < Slow trend[1]
Long: Fast trend on chart bars using T1 values at the selected signal-bar offset is rising
Short: Fast trend on chart bars using T1 values at the selected signal-bar offset is falling
Short: Fast trend on chart bars using T1 values at the selected signal-bar offset is flat
Long: Slow trend on chart bars using T2 values at the selected signal-bar offset is rising
Short: Slow trend on chart bars using T2 values at the selected signal-bar offset is falling
Long: Slow trend on chart bars using T2 values at the selected signal-bar offset is falling
Short: Slow trend on chart bars using T2 values at the selected signal-bar offset is rising
Long: Slow trend is rising on T3 bars at bar closure AND Fast trend changes from rising to non-rising on T3 signal bars at bar closure
Short: Slow trend is falling on T3 bars at bar closure AND Fast trend changes from falling to non-falling on T3 signal bars at bar closure
Exit: long, Slow trend is falling OR Fast trend is rising
Exit: short, Slow trend is rising OR Fast trend is falling