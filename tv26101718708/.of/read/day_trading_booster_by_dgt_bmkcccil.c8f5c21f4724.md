Calculation: Confirmed pivot high or low = a chart bar whose high or low is respectively the highest or lowest over equal-length left and right windows; detect it only after the right window completes, using Pine pivot tie handling.
Calculation: Temporary pivot high or low = a confirmed pivot using the shorter pivot window; retain the most recent temporary pivot of each type, initially zero.
Long: A confirmed pivot low is detected.
Short: A confirmed pivot high is detected.
Long: A temporary pivot low is detected AND its low < the previous temporary pivot low.
Short: A temporary pivot high is detected AND its high > the previous temporary pivot high.
Long: Close > the latest confirmed pivot high AND that pivot high has not previously been broken by a close; reset the break flag whenever a new pivot high is confirmed.
Short: Close < the latest confirmed pivot low AND that pivot low has not previously been broken by a close; reset the break flag whenever a new pivot low is confirmed.
Long: Shorter-period moving average > longer-period moving average.
Short: Shorter-period moving average <= longer-period moving average.
Long: Close crosses above the longer-period moving average.
Short: Close crosses below the longer-period moving average.
Long: Volume >= a high threshold times the volume SMA AND close > open OR volume <= a low threshold times the volume SMA AND volume < the high threshold times the volume SMA AND close > open.
Short: Volume >= a high threshold times the volume SMA AND close <= open OR volume <= a low threshold times the volume SMA AND volume < the high threshold times the volume SMA AND close <= open.
Long: The current higher-timeframe weekly bar's open > the last completed higher-timeframe weekly bar's close.
Short: The current higher-timeframe weekly bar's open < the last completed higher-timeframe weekly bar's close.