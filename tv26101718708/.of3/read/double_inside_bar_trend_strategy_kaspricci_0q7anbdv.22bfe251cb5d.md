Calculation: DoubleInsideBar = high < high[1] AND low > low[1] AND high[1] < high[2] AND low[1] > low[2]
Calculation: stop distance = ATR(lookback) × stop multiplier when ATR stop type is selected, otherwise fixed stop distance
Calculation: target distance = stop distance × target ratio when ATR stop type is selected, otherwise fixed target distance
Long: DoubleInsideBar AND close > selected moving average(selected price source, lookback, type)
Short: DoubleInsideBar AND close < selected moving average(selected price source, lookback, type)
Exit: long, low <= entry price - stop distance OR high >= entry price + target distance
Exit: short, high >= entry price + stop distance OR low <= entry price - target distance