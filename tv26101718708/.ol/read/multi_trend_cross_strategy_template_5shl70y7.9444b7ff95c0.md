Calculation: Fast trend = selected trend indicator applied to the selected price source with a shorter lookback
Calculation: Slow trend = selected trend indicator applied to the selected price source with a longer lookback
Long: Fast trend > Slow trend AND datetime is within the configured start and end times
Short: Fast trend < Slow trend AND datetime is within the configured start and end times
Exit: Long, Fast trend < Slow trend AND datetime is within the configured start and end times
Exit: Short, Fast trend > Slow trend AND datetime is within the configured start and end times
Exit: Long, datetime is before the configured start time or after the configured end time
Exit: Short, datetime is before the configured start time or after the configured end time