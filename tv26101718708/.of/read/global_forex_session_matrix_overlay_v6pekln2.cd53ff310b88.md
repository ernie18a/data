Calculation: Confirmed pivot high/low = the high/low of a chart bar whose high/low is the highest/lowest among a specified number of bars on each side; it becomes available on the bar that completes the right-hand lookback.
Calculation: Temporary pivot high/low = a confirmed pivot high/low calculated with a separate, shorter left and right lookback. Compare it with the preceding temporary pivot of the same kind, initialized to zero.
Long: A confirmed pivot low becomes available.
Short: A confirmed pivot high becomes available.
Long: A temporary pivot low becomes available AND its value is lower than the preceding temporary pivot low.
Short: A temporary pivot high becomes available AND its value is higher than the preceding temporary pivot high.
Long: Close > the latest confirmed pivot high AND that pivot high has not previously been broken by a close.
Short: Close < the latest confirmed pivot low AND that pivot low has not previously been broken by a close.
Long: The shorter-term moving average > the longer-term moving average.
Short: The shorter-term moving average < the longer-term moving average.
Long: The shorter-term moving average crosses above the longer-term moving average.
Short: The shorter-term moving average crosses below the longer-term moving average OR crosses it and ends equal to it.
Long: Close crosses above the longer-term moving average.
Short: Close crosses below the longer-term moving average OR crosses it and ends equal to it.
Long: Close >= the open of the still-forming higher-timeframe trading day.
Short: Close < the open of the still-forming higher-timeframe trading day.
Long: Close >= open AND volume >= a high threshold multiplied by the simple moving average of volume.
Short: Close < open AND volume >= a high threshold multiplied by the simple moving average of volume.
Long: Close > open AND volume <= a low threshold multiplied by the simple moving average of volume.
Short: Close <= open AND (volume >= a high threshold multiplied by the simple moving average of volume OR volume <= a low threshold multiplied by the simple moving average of volume).
Long: The shorter-term moving average >= the longer-term moving average.
Short: The shorter-term moving average < the longer-term moving average.
Long: Close >= open AND the moving averages are unavailable.