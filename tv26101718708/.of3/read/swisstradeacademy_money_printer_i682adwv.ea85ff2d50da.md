Calculation: Upper band = SMA(high, band lookback) + standard deviation(high, band lookback) multiplied by band multiplier
Calculation: Lower band = SMA(low, band lookback) − standard deviation(low, band lookback) multiplied by band multiplier
Calculation: Super Bollinger candidate = 0 if either band is unavailable; otherwise, if close > Super Bollinger line[1], max(Super Bollinger line[1], lower band); else if close < Super Bollinger line[1], min(Super Bollinger line[1], upper band); otherwise 0
Calculation: Super Bollinger line = lower band when close crosses above Super Bollinger candidate, upper band when close crosses below Super Bollinger candidate, otherwise Super Bollinger candidate; initial value 0
Calculation: MACD overlay EMA = EMA(close, slow lookback minus fast lookback)
Calculation: MACD overlay signal = SMA(MACD overlay EMA, signal lookback)
Long: close crosses above Super Bollinger candidate OR MACD overlay EMA > MACD overlay EMA[1] OR MACD overlay signal > MACD overlay signal[1] OR MACD overlay EMA > MACD overlay signal OR SMA(close, overlay lookback) > SMA(close, overlay lookback)[1]
Short: close crosses below Super Bollinger candidate OR MACD overlay EMA <= MACD overlay EMA[1] OR MACD overlay signal <= MACD overlay signal[1] OR MACD overlay EMA <= MACD overlay signal OR SMA(close, overlay lookback) <= SMA(close, overlay lookback)[1]