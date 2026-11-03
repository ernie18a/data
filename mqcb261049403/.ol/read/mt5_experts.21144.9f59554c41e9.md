Calculation: Candle difference = smoothed close minus smoothed open from candle-lookback minus one bars earlier; smooth open and close independently with the same selected moving-average method and parameters.
Calculation: Fast difference = candle difference on the entry timeframe, using its last completed bar and the preceding bar.
Calculation: Slow difference = candle difference on a higher timeframe than the entry timeframe, using its last completed bar.
Long: Chart-timeframe candle difference >= 0
Short: Chart-timeframe candle difference < 0
Long: Forming higher-timeframe candle difference >= 0
Short: Forming higher-timeframe candle difference < 0
Long: Slow difference >= 0 AND fast difference on the last completed bar >= 0 AND fast difference on the preceding bar < 0
Short: Slow difference < 0 AND fast difference on the last completed bar < 0 AND fast difference on the preceding bar >= 0
Exit: long, slow difference < 0 OR fast difference on the last completed bar < 0 OR low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance
Exit: short, slow difference >= 0 OR fast difference on the last completed bar >= 0 OR high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance