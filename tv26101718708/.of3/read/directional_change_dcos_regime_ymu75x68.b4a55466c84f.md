Calculation: Direction = Down if Direction[1] = Up AND low <= Up-leg high[1] * (1 - DC threshold); Up if Direction[1] = Down AND high >= Down-leg low[1] * (1 + DC threshold); otherwise Direction[1]; initial value Up
Calculation: Up-leg high = high if Up DC; max(high, Up-leg high[1]) if Direction = Up; otherwise Up-leg high[1]; initial value first close
Calculation: Down-leg low = low if Down DC; min(low, Down-leg low[1]) if Direction = Down; otherwise Down-leg low[1]; initial value first close
Calculation: Up DC = Direction[1] = Down AND Direction = Up
Calculation: Down DC = Direction[1] = Up AND Direction = Down
Calculation: Up OS = Direction[1] = Up AND Direction = Up AND high > Up-leg high[1]
Calculation: Down OS = Direction[1] = Down AND Direction = Down AND low < Down-leg low[1]
Calculation: Uptrend = EMA(close, shorter lookback) > EMA(close, longer lookback) AND ADX(high, low, close, ADX lookback) >= ADX trend minimum
Calculation: Downtrend = EMA(close, shorter lookback) < EMA(close, longer lookback) AND ADX(high, low, close, ADX lookback) >= ADX trend minimum
Calculation: Range = ADX(high, low, close, ADX lookback) <= ADX range maximum
Calculation: Body ratio = abs(close - open) / max(high - low, minimum price increment)
Calculation: Chop = NOT Uptrend AND NOT Downtrend AND SMA(Body ratio, chop lookback) < chop threshold
Calculation: Session-volume filter = bar datetime within session window AND volume > SMA(volume, volume lookback) * volume multiplier
Long: Uptrend AND (Up OS OR Up DC) AND Session-volume filter
Long: Range AND Up DC AND NOT Chop AND Session-volume filter
Long: (Up OS OR Up DC) AND NOT Chop AND Session-volume filter
Short: Downtrend AND (Down OS OR Down DC) AND Session-volume filter
Short: Range AND Down DC AND NOT Chop AND Session-volume filter
Short: (Down OS OR Down DC) AND NOT Chop AND Session-volume filter