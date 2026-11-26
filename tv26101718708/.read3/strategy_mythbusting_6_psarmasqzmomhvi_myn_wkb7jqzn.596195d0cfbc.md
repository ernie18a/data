Calculation: psar = PSAR(high, low, PSAR start, PSAR increment, PSAR maximum)
Calculation: longer-lookback MA = MA(close, longer lookback, longer MA type, T1, last completed bar)
Calculation: shorter-lookback MA = MA(close, shorter lookback, shorter MA type, T2, last completed bar)
Calculation: range = high - low
Calculation: range average = SMA(range, HVI length)
Calculation: volume average = SMA(volume, HVI length)
Calculation: midpoint = (high[1] + low[1]) / 2
Calculation: upper band = midpoint + range[1] / divisor
Calculation: lower band = midpoint - range[1] / divisor
Calculation: squeeze momentum = SqueezeMomentum(close, high, low, squeeze length)
Calculation: adx = ADX(high, low, close, DI length, ADX smoothing)
Long: psar < close AND psar[1] >= close[1] AND close > longer-lookback MA AND close > shorter-lookback MA AND shorter-lookback MA > longer-lookback MA AND (close > midpoint OR (range > range average AND close > upper band AND volume > volume average) OR (high > high[1] AND range < range average / range factor AND volume < volume average) OR (low < low[1] AND range < range average / range factor AND volume > volume average)) AND squeeze momentum > 0 AND adx > ADX threshold
Short: psar >= close AND psar[1] < close[1] AND close < longer-lookback MA AND close < shorter-lookback MA AND shorter-lookback MA < longer-lookback MA AND (close < midpoint OR (range > range average AND close < lower band AND volume > volume average)) AND squeeze momentum < 0 AND adx > ADX threshold
Exit: long, high >= entry price * (1 + profit target 1 / 100)
Exit: long, high >= entry price * (1 + profit target 2 / 100)
Exit: long, high >= entry price * (1 + profit target 3 / 100)
Exit: long, high >= entry price * (1 + profit target 4 / 100)
Exit: long, close < entry price * (1 - stop loss / 100)
Exit: short, low <= entry price * (1 - profit target 1 / 100)
Exit: short, low <= entry price * (1 - profit target 2 / 100)
Exit: short, low <= entry price * (1 - profit target 3 / 100)
Exit: short, low <= entry price * (1 - profit target 4 / 100)
Exit: short, close > entry price * (1 + stop loss / 100)