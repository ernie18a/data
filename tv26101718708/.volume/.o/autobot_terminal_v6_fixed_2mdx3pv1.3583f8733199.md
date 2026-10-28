Calculation: 4-hour resistance = latest confirmed pivot high from 4-hour bars
Calculation: 4-hour support = latest confirmed pivot low from 4-hour bars
Calculation: Previous-day high/low = high/low of the last completed daily bar
Calculation: Hourly confirmation candle = open and close of the last completed hourly bar
Calculation: Support zone = close is at or above 4-hour support and within a small buffer above it, or at or above previous-day low and within a small buffer above it
Calculation: Resistance zone = close is at or below 4-hour resistance and within a small buffer below it, or at or below previous-day high and within a small buffer below it
Calculation: Active resistance = 4-hour resistance if available, otherwise previous-day high if available, otherwise close
Calculation: Active support = 4-hour support if available, otherwise previous-day low if available, otherwise close
Calculation: Short stop = active resistance plus a small buffer
Calculation: Long stop = active support minus a small buffer
Calculation: Short target = entry price minus a multiple of (short stop minus entry price)
Calculation: Long target = entry price plus a multiple of (entry price minus long stop)
Long: position is flat AND time is within the allowed session AND (daily close is above the daily long-term SMA calculated with the current daily bar included AND support zone AND (last completed hourly close is above its open OR above 4-hour support) OR daily close is below that SMA AND support zone) AND close crosses above VWAP
Short: position is flat AND time is within the allowed session AND daily close is below the daily long-term SMA calculated with the current daily bar included AND resistance zone AND (last completed hourly close is below its open OR below previous-day low) AND close crosses below VWAP
Exit: short, low <= short target OR high >= short stop
Exit: long, high >= long target OR low <= long stop