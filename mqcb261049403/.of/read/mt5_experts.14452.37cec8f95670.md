Calculation: Step DeMarker = For each step size, independently process DeMarker multiplied by 100 in chronological order. Initialize the previous lower band to positive infinity, the previous upper band to negative infinity, and trend to zero. For each bar, set lower = DeMarker - 2 × step size and upper = DeMarker + 2 × step size. Set trend to +1 if DeMarker > previous upper band, or to -1 if DeMarker < previous lower band; otherwise retain the previous trend. If trend is +1, set lower = max(lower, previous lower band) and output lower + step size. If trend is -1, set upper = min(upper, previous upper band) and output upper - step size. Save both bands for the next bar. Calculate fast and slow lines with the same DeMarker period and a smaller step size for the fast line.
Calculation: Signal lines = Step DeMarker lines calculated on a selectable indicator timeframe, which may be the chart timeframe or a higher or lower timeframe. Use the last completed indicator bar, or the still-forming indicator bar when configured; previous means the preceding indicator bar.
Long: Chart-timeframe fast Step DeMarker > chart-timeframe slow Step DeMarker
Short: Chart-timeframe fast Step DeMarker < chart-timeframe slow Step DeMarker
Long: Signal fast line > signal slow line AND previous signal fast line <= previous signal slow line
Short: Signal fast line < signal slow line AND previous signal fast line >= previous signal slow line
Exit: long, signal fast line < signal slow line
Exit: short, signal fast line > signal slow line
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance