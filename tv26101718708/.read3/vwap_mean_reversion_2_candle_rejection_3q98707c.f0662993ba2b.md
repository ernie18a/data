Calculation: Lower deviation band = VWAP(close) - ATR(ATR lookback) * band multiplier
Calculation: Upper deviation band = VWAP(close) + ATR(ATR lookback) * band multiplier
Calculation: Long stop level = VWAP(close) - ATR(ATR lookback) * stop multiplier
Calculation: Short stop level = VWAP(close) + ATR(ATR lookback) * stop multiplier
Calculation: EMA change = abs(EMA(close, EMA lookback) - EMA(close, EMA lookback)[slope lag])
Long: (low[1] < Lower deviation band[1] OR low < Lower deviation band) AND close > Lower deviation band AND VWAP(close) - close >= (close - Long stop level) * risk-reward multiple AND (New York hour(datetime) >= evening hour OR New York hour(datetime) <= overnight hour) AND EMA change < ATR(ATR lookback) * slope threshold
Short: (high[1] > Upper deviation band[1] OR high > Upper deviation band) AND close < Upper deviation band AND close - VWAP(close) >= (Short stop level - close) * risk-reward multiple AND (New York hour(datetime) >= evening hour OR New York hour(datetime) <= overnight hour) AND EMA change < ATR(ATR lookback) * slope threshold
Exit: long, low <= Long stop level OR high >= VWAP(close)
Exit: short, high >= Short stop level OR low <= VWAP(close)