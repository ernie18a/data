Calculation: Histogram = smooth((RSI of the selected applied price − 50) × selected tick or real volume) using the configured smoothing method and lookback, on the configured indicator timeframe; evaluate completed bars.
Calculation: Volume thresholds = each configured upper or lower level × the same smoothed selected volume on the indicator timeframe, using completed bars.
Calculation: Histogram category = 0 if Histogram > upper threshold 2; 1 if Histogram > upper threshold 1; 2 otherwise; 3 if Histogram < lower threshold 1; 4 if Histogram < lower threshold 2. Apply these tests in that order.
Long: On two consecutive completed indicator-timeframe bars, the newer bar's category is 1 AND the older bar's category > 1, OR the newer bar's category is 0 AND the older bar's category > 0.
Short: On two consecutive completed indicator-timeframe bars, the newer bar's category is 3 AND the older bar's category < 3, OR the newer bar's category is 4 AND the older bar's category < 4.
Exit: Long, the latest completed indicator-timeframe bar's category is 3 OR 4.
Exit: Short, the latest completed indicator-timeframe bar's category is 0 OR 1.