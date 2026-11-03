Calculation: Confirmed pivot high = a chart-bar high greater than or equal to each high in an equal-length window before it and strictly greater than each high in the window after it; it is confirmed at the end of the latter window.
Calculation: Confirmed pivot low = a chart-bar low less than or equal to each low in an equal-length window before it and strictly less than each low in the window after it; it is confirmed at the end of the latter window.
Calculation: Higher-timeframe VWAP = sum of chart-bar typical price times volume divided by sum of chart-bar volume since the start of the higher-timeframe bar still forming.
Calculation: Higher-timeframe cumulative volume delta = sum since the start of the higher-timeframe bar still forming of chart-bar volume when close >= open and negative chart-bar volume otherwise.
Long: A pivot high is confirmed.
Short: A pivot low is confirmed.
Long: Close > the latest confirmed pivot high AND that pivot high has not previously been broken; alternatively, high > that level under the same condition.
Short: Close < the latest confirmed pivot low AND that pivot low has not previously been broken; alternatively, low < that level under the same condition.
Long: Close > higher-timeframe VWAP.
Short: Close <= higher-timeframe VWAP.
Long: Close > higher-timeframe VWAP AND higher-timeframe cumulative volume delta > 0.
Short: Close < higher-timeframe VWAP AND higher-timeframe cumulative volume delta < 0.
Long: Higher-timeframe cumulative volume delta >= 0.
Short: Higher-timeframe cumulative volume delta < 0.
Long: Higher-timeframe close >= higher-timeframe open, using the bar still forming.
Short: Higher-timeframe close < higher-timeframe open, using the bar still forming.