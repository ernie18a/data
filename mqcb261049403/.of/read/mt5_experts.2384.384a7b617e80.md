Calculation: Fast line = short-period simple moving average of RSI on a selected price, calculated on the last completed higher-timeframe bar.
Calculation: Slow line = longer-period simple moving average of the fast line, calculated on the same higher-timeframe bars.
Long: Fast line > slow line AND previous higher-timeframe fast line <= previous higher-timeframe slow line.
Short: Fast line < slow line AND previous higher-timeframe fast line >= previous higher-timeframe slow line.
Exit: long, fast line < slow line OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, fast line > slow line OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.