Calculation: Volume-weighted price = sum(volume × selected OHLC-derived price) over a rolling lookback divided by max(sum(volume), 1).
Calculation: Normalized price = 100 × (volume-weighted price − rolling minimum of volume-weighted price) / max(rolling maximum − rolling minimum, price increment) − 50; both extrema use the same lookback and include the current bar.
Calculation: Fast line = moving average of normalized price; slow line = moving average of the fast line using the same smoothing method and parameters.
Long: Chart-timeframe fast line > slow line.
Short: Chart-timeframe fast line <= slow line.
Long: At the first chart bar of a higher-timeframe bar, the still-forming higher-timeframe fast line > slow line AND the preceding higher-timeframe fast line <= slow line.
Short: At the first chart bar of a higher-timeframe bar, the still-forming higher-timeframe fast line <= slow line AND the preceding higher-timeframe fast line > slow line.