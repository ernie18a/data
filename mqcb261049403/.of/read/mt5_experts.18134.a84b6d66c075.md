Calculation: Fast line = Jurik moving average of the Fast Adaptive Trend Line of the selected price, using the shorter smoothing length on the last completed higher-timeframe bar.
Calculation: Slow line = Jurik moving average of the Slow Adaptive Trend Line of the same selected price, using the longer smoothing length on the last completed higher-timeframe bar.
Long: Fast line > slow line AND previous higher-timeframe fast line <= previous higher-timeframe slow line.
Short: Fast line < slow line AND previous higher-timeframe fast line >= previous higher-timeframe slow line.
Exit: long, fast line < slow line OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, fast line > slow line OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.