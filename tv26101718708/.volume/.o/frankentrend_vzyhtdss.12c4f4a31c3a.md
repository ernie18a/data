Calculation: MACD = short-lookback EMA of close minus long-lookback EMA of close; signal = moving average of MACD
Calculation: ATR trailing stop = recursively updated upper and lower bands based on hl2 ± ATR; trend_xup/trend_xdown = bars since close crosses the stop upward/downward, with trend_xdown incremented when the counts are equal and close is above the stop
Calculation: Vix Fix = (highest close over a lookback − low) / highest close over that lookback × 100; upper threshold = moving average + standard-deviation multiple, high threshold = rolling highest Vix Fix × percentile factor
Calculation: Recent average = volume-weighted moving average of OHLC4
Calculation: Point-and-figure trend = current point-and-figure close compared with its previous close
Long: MACD > signal OR (trend_xup < trend_xdown AND position size < coin limit AND (Vix Fix ≥ upper threshold OR Vix Fix ≥ high threshold)) OR (trend_xup < trend_xdown AND MACD crosses above signal AND MACD > signal AND (Vix Fix ≥ upper threshold OR Vix Fix ≥ high threshold) AND close < recent average − offset)
Short: MACD < signal
Exit: long, (Vix Fix < upper threshold AND Vix Fix < high threshold AND ((high < previous high AND low < previous low) OR close < previous low)) OR unrealized open profit < loss threshold OR point-and-figure close < previous point-and-figure close