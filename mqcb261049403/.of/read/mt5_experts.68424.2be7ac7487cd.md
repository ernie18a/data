Calculation: Bullish outside bar = the last completed chart bar has a lower low and higher high than the preceding completed chart bar, and closes above that bar’s high
Calculation: Bearish outside bar = the last completed chart bar has a lower low and higher high than the preceding completed chart bar, and closes below that bar’s low
Long: no open position AND Bullish outside bar AND ONNX Buy-class probability > probability threshold
Short: no open position AND Bearish outside bar AND ONNX Sell-class probability > probability threshold
Exit: Long, price <= low of the signal bar OR price >= entry price + (entry price - low of the signal bar) × risk/reward ratio
Exit: Short, price >= high of the signal bar OR price <= entry price - (high of the signal bar - entry price) × risk/reward ratio