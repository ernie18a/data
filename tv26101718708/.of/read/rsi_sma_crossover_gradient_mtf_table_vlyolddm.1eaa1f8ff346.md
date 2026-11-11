Calculation: RSI SMA = simple moving average of RSI, calculated on the same timeframe as the RSI.
Calculation: Crossover regime = 1 after RSI crosses above RSI SMA and -1 after RSI crosses below RSI SMA; retain the last regime until the next crossover.
Calculation: MTF RSI and RSI SMA = RSI and its SMA calculated on each selected higher or lower timeframe; on historical bars use the last completed higher-timeframe bar or the last available lower-timeframe bar, and on a live bar use the available bar still forming.
Long: RSI > RSI SMA OR (RSI = RSI SMA AND crossover regime = 1).
Short: RSI < RSI SMA OR (RSI = RSI SMA AND crossover regime = -1).
Long: MTF RSI > MTF RSI SMA OR (MTF RSI = MTF RSI SMA AND MTF RSI > RSI midpoint).
Short: MTF RSI < MTF RSI SMA OR (MTF RSI = MTF RSI SMA AND MTF RSI <= RSI midpoint).
Long: MTF RSI SMA > MTF RSI SMA at the earlier bar specified by the slope lookback.
Short: MTF RSI SMA < MTF RSI SMA at the earlier bar specified by the slope lookback.