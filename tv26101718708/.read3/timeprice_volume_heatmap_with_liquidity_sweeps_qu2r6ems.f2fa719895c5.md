Calculation: PoolHigh = lowest PivotHigh(high, pivot strength, pivot strength) among the latest max levels confirmed pivot highs within level max age bars that high has not exceeded since their confirmation
Calculation: PoolLow = highest PivotLow(low, pivot strength, pivot strength) among the latest max levels confirmed pivot lows within level max age bars that low has not gone below since their confirmation
Calculation: POC = VolumeProfilePOC(high, low, volume, lookback, price rows)
Calculation: UpVolume = SUM(volume where close > open, lookback)
Calculation: DownVolume = SUM(volume where close < open, lookback)
Long: low < PoolLow
Short: high > PoolHigh
Long: close > POC
Short: close <= POC
Long: UpVolume >= DownVolume
Short: UpVolume < DownVolume