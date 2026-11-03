Calculation: Current-day high = high of the still-forming higher-timeframe daily bar.
Calculation: Current-day low = low of the still-forming higher-timeframe daily bar.
Calculation: Entry reference high = high of the previous completed higher-timeframe daily bar when chart-bar hour > 10 or hour = 9 and minute > 30; otherwise, high of the still-forming higher-timeframe daily bar.
Calculation: Entry reference low = low of the previous completed higher-timeframe daily bar when chart-bar hour > 10 or hour = 9 and minute > 30; otherwise, low of the still-forming higher-timeframe daily bar.
Calculation: Premarket high = highest high of chart-timeframe bars from the first bar of the session through the current bar while chart-bar time is before 09:30 or at/after 16:00; retain the last value outside those times.
Calculation: Premarket low = lowest low of chart-timeframe bars from the first bar of the session through the current bar while chart-bar time is before 09:30 or at/after 16:00; retain the last value outside those times.
Long: Position is flat AND (close crosses above premarket high OR close crosses above entry reference high).
Short: Position is flat AND (close crosses below premarket low OR close crosses below entry reference low).
Exit: Long, close crosses above current-day high.
Exit: Short, close crosses below current-day low.