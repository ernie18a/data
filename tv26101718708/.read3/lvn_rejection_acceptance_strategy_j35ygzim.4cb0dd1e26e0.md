Calculation: Upper band = SMA(close, zone lookback) + ATR(ATR lookback) * band-width parameter
Calculation: Lower band = SMA(close, zone lookback) - ATR(ATR lookback) * band-width parameter
Long: position is flat AND ((low < Lower band AND close > Lower band AND volume < SMA(volume, zone lookback) * volume-threshold parameter) OR (close > Upper band AND close[1] > Upper band))
Short: position is flat AND ((high > Upper band AND close < Upper band AND volume < SMA(volume, zone lookback) * volume-threshold parameter) OR (close < Lower band AND close[1] < Lower band))
Exit: long, low <= entry price - ATR(ATR lookback) * stop-distance parameter OR high >= entry price + ATR(ATR lookback) * stop-distance parameter * risk-reward parameter
Exit: short, high >= entry price + ATR(ATR lookback) * stop-distance parameter OR low <= entry price - ATR(ATR lookback) * stop-distance parameter * risk-reward parameter