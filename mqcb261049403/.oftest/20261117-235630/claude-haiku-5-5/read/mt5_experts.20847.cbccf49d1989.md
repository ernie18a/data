Long: bar count > warm-up length AND open[1] < SMA(close, lookback)[shift] AND close[1] > SMA(close, lookback)[shift]
Short: bar count > warm-up length AND open[1] > SMA(close, lookback)[shift] AND close[1] < SMA(close, lookback)[shift]
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance