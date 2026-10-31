Calculation: Hull trend = smooth(2 × smooth(selected OHLC-derived price, half the base length) − smooth(selected OHLC-derived price, base length), smoothing length), using the same selected moving-average method and phase for all smoothing operations.
Calculation: Hull signal = smooth(Hull trend, floor(square root of the base length)), using the same moving-average method and phase.
Long: Hull trend > Hull signal.
Short: Hull trend < Hull signal.
Long: Hull trend on a higher timeframe > Hull signal on the same higher timeframe, using the bar still forming at the start of the higher-timeframe bar and holding that comparison until the next higher-timeframe bar starts.
Short: Hull trend on a higher timeframe < Hull signal on the same higher timeframe, using the bar still forming at the start of the higher-timeframe bar and holding that comparison until the next higher-timeframe bar starts.