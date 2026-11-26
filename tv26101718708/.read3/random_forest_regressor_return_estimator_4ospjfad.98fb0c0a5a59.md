Calculation: RF_FORECAST(horizon) = mean over trees of a random forest regressor's prediction at step horizon, fit on the last training-bars samples that end max horizon bars before the current bar, where each sample's features are RSI(close, RSI lookback), NATR(high, low, close, ATR lookback), CCI(close, CCI lookback), VOL_RATIO(volume, volume lookback), PRICE_SMA_RATIO(close, SMA lookback), MOM(close, momentum lookback), BB_WIDTH(close, BB lookback, BB multiplier), ADX(high, low, close, ADX lookback), and its targets are the percent changes of close to each of the next 1 to max horizon bars, with number of trees, max depth, min samples per leaf, threshold candidates per feature per node, max features per split, and random seed as forest parameters, predicted from the features of the current bar
Calculation: VOL_RATIO(volume, lookback) = volume / SMA(volume, lookback)
Calculation: PRICE_SMA_RATIO(close, lookback) = close / SMA(close, lookback)
Long: RF_FORECAST(max horizon) >= 0
Short: RF_FORECAST(max horizon) < 0
Long: max horizon >= near horizon AND RF_FORECAST(near horizon) >= 0
Short: max horizon >= near horizon AND RF_FORECAST(near horizon) < 0
Long: max horizon >= mid horizon AND RF_FORECAST(mid horizon) >= 0
Short: max horizon >= mid horizon AND RF_FORECAST(mid horizon) < 0
Long: max horizon >= far horizon AND RF_FORECAST(far horizon) >= 0
Short: max horizon >= far horizon AND RF_FORECAST(far horizon) < 0