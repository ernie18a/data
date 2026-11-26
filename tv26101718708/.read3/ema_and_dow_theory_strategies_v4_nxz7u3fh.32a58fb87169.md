Calculation: Dow trend = On each chart bar, carry forward the latest pivot high and pivot low with left and right lookbacks equal to the swing lookback; start neutral, set trend up if close exceeds the latest pivot high and trend is not up, then set trend down if close is below the latest pivot low and trend is not down.
Long: EMA(close, EMA lookback) > EMA(close, EMA lookback)[1] AND Dow trend = up AND ADX(DI lookback, ADX smoothing) > ADX threshold
Short: EMA(close, EMA lookback) < EMA(close, EMA lookback)[1] AND Dow trend = down AND ADX(DI lookback, ADX smoothing) > ADX threshold
Exit: long, close-based return percentage = (close - entry price) / entry price × 100 < stop-loss threshold
Exit: short, close-based return percentage = (entry price - close) / entry price × 100 < stop-loss threshold
Exit: long, Dow trend = down
Exit: short, Dow trend = up
Exit: long, BE stop enabled AND the maximum close-based return percentage since entry has reached the BE trigger AND low <= entry price adjusted upward by the fee buffer
Exit: short, BE stop enabled AND the maximum close-based return percentage since entry has reached the BE trigger AND high >= entry price adjusted downward by the fee buffer
Exit: long, first target has not triggered in the current position AND high > entry-signal close + ATR(lookback at entry signal) × ATR distance factor × first target multiplier
Exit: long, second target has not triggered in the current position AND high > entry-signal close + ATR(lookback at entry signal) × ATR distance factor × second target multiplier
Exit: long, third target has not triggered in the current position AND high > entry-signal close + ATR(lookback at entry signal) × ATR distance factor × third target multiplier
Exit: short, first target has not triggered in the current position AND low < entry-signal close - ATR(lookback at entry signal) × ATR distance factor × first target multiplier
Exit: short, second target has not triggered in the current position AND low < entry-signal close - ATR(lookback at entry signal) × ATR distance factor × second target multiplier
Exit: short, third target has not triggered in the current position AND low < entry-signal close - ATR(lookback at entry signal) × ATR distance factor × third target multiplier