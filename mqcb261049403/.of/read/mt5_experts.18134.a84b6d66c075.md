Calculation: Fast line = a configurable smoother of the 39-bar FATL digital filter of the selected OHLC-derived price; its smoothing lookback is shorter than the slow line’s
Calculation: Slow line = a configurable smoother of the 65-bar SATL digital filter of the selected OHLC-derived price; its smoothing lookback is longer than the fast line’s
Long: Fast line on the last completed bar of the configured indicator timeframe > slow line on that bar AND fast line on the preceding completed bar of that timeframe <= slow line on that bar
Short: Fast line on the last completed bar of the configured indicator timeframe < slow line on that bar AND fast line on the preceding completed bar of that timeframe >= slow line on that bar
Exit: short, Fast line on the last completed bar of the configured indicator timeframe > slow line on that bar
Exit: long, Fast line on the last completed bar of the configured indicator timeframe < slow line on that bar