Calculation: Chart TSI = TSI(DeMarker(chart DeMarker lookback), chart momentum lookback, chart first smoothing lookback, chart second smoothing lookback, chart smoothing method, chart smoothing phase)
Calculation: Chart TSI signal = moving average(Chart TSI, chart smoothing method, chart smoothing phase, chart signal lookback)
Long: Chart TSI > Chart TSI signal
Short: Chart TSI < Chart TSI signal
Calculation: T1 TSI = TSI(DeMarker(T1 DeMarker lookback), T1 momentum lookback, T1 first smoothing lookback, T1 second smoothing lookback, T1 smoothing method, T1 smoothing phase)
Calculation: T1 TSI signal = moving average(T1 TSI, T1 smoothing method, T1 smoothing phase, T1 signal lookback), calculated on T1 bars; chart bars use values from the T1 bar still forming
Long: T1 TSI > T1 TSI signal
Short: T1 TSI < T1 TSI signal