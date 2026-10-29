Calculation: XMACD = shorter-lookback smoothed applied price minus longer-lookback smoothed applied price
Calculation: Signal = smoothed XMACD
Long: chart-timeframe XMACD > 0 AND XMACD > previous chart-timeframe XMACD
Long: chart-timeframe XMACD > 0 AND XMACD < previous chart-timeframe XMACD
Long: chart-timeframe XMACD > previous chart-timeframe Signal
Long: higher-timeframe XMACD > 0 AND XMACD > previous higher-timeframe XMACD, using the last completed higher-timeframe bar
Long: higher-timeframe XMACD > 0 AND XMACD < previous higher-timeframe XMACD, using the last completed higher-timeframe bar
Long: higher-timeframe XMACD > higher-timeframe Signal, using the last completed higher-timeframe bar
Short: chart-timeframe XMACD < 0 AND XMACD < previous chart-timeframe XMACD
Short: chart-timeframe XMACD < 0 AND XMACD > previous chart-timeframe XMACD
Short: chart-timeframe XMACD < previous chart-timeframe Signal
Short: higher-timeframe XMACD < 0 AND XMACD < previous higher-timeframe XMACD, using the last completed higher-timeframe bar
Short: higher-timeframe XMACD < 0 AND XMACD > previous higher-timeframe XMACD, using the last completed higher-timeframe bar
Short: higher-timeframe XMACD < higher-timeframe Signal, using the last completed higher-timeframe bar