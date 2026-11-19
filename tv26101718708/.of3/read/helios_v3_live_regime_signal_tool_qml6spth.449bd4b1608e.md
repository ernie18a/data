Calculation: MACD posture vote = +1 when MACD(close, fast lookback, slow lookback, signal lookback) and its signal line are both above zero; −1 when both are below zero; otherwise 0
Calculation: Spread vote = +1 when SMA(close, spread lookback) > SMA(open, spread lookback); −1 when less; otherwise 0
Calculation: Momentum vote = +1 when close > close[momentum lookback]; −1 when less; otherwise 0
Calculation: Long-average vote = +1 when close > SMA(close, long lookback); otherwise −1
Calculation: OBV vote = +1 when OBV > SMA(OBV, OBV lookback); −1 when less; otherwise 0
Calculation: Relative-strength vote = 0 when relative strength is disabled for the chart; otherwise +1 when close / benchmark close on the current chart bar > SMA(close / benchmark close, ratio lookback), else −1; use the benchmark’s same-timeframe bar on chart bars, including while it is forming
Calculation: Extended score = MACD posture vote + spread vote + momentum vote + long-average vote + OBV vote + relative-strength vote
Calculation: Realized volatility = stdev(log(close / close[1]), volatility lookback) × sqrt(annualization factor) × 100, optionally smoothed with EMA(volatility, smoothing lookback)
Calculation: Extension z-score = (close − SMA(close, long lookback)) / stdev(close, long lookback)
Long: Position is flat AND Extended score ≥ buy-score threshold for the confirmation lookback consecutive chart bars AND Realized volatility ≤ volatility cap AND Extension z-score ≤ buy-extension ceiling AND Extended score ≥ buy-score threshold + full-score increment AND Extension z-score < full-size extension ceiling
Long: Position is flat AND Extended score ≥ buy-score threshold for the confirmation lookback consecutive chart bars AND Realized volatility ≤ volatility cap AND Extension z-score ≤ buy-extension ceiling AND (Extended score < buy-score threshold + full-score increment OR Extension z-score ≥ full-size extension ceiling)
Long: Blocked-marker display is enabled AND position is flat AND Extended score ≥ buy-score threshold on exactly the first confirmation bar AND (Realized volatility > volatility cap OR Extension z-score > buy-extension ceiling)
Short: Blocked-marker display is enabled AND position is long AND Extended score ≤ sell-score threshold on exactly the first confirmation bar AND (Realized volatility > volatility cap OR Extension z-score < sell-extension floor)
Exit: long, Extended score ≤ sell-score threshold for the confirmation lookback consecutive chart bars AND Realized volatility ≤ volatility cap AND Extension z-score ≥ sell-extension floor