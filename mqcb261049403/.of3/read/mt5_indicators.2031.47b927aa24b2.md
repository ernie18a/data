Calculation: smoothed Williams %R(k) = smoothing(Williams %R(WPR lookback), first-stage smoothing method, initial smoothing lookback + k * smoothing-period increment, first-stage phase)
Calculation: rising line = smoothing(count of k from 0 through number of smoothing-period increments where smoothed Williams %R(k)[0] > smoothed Williams %R(k)[1], second-stage smoothing method, second-stage smoothing lookback, second-stage phase)
Calculation: falling line = smoothing(count of k from 0 through number of smoothing-period increments where smoothed Williams %R(k)[0] <= smoothed Williams %R(k)[1], second-stage smoothing method, second-stage smoothing lookback, second-stage phase)
Long: rising line > falling line on the current, still-forming chart bar
Short: falling line > rising line on the current, still-forming chart bar
Long: rising line > falling line, calculated on T1 bars using the still-forming T1 bar and carried onto chart bars
Short: falling line > rising line, calculated on T1 bars using the still-forming T1 bar and carried onto chart bars