Calculation: volume-weighted candle change = (close - open) × volume
Calculation: bullish imbalance = max(0, bullish imbalance[1] + volume-weighted candle change) × imbalance decay, initialized at zero
Calculation: bearish imbalance = max(0, bearish imbalance[1] - volume-weighted candle change) × imbalance decay, initialized at zero
Long: (bearish imbalance / SMA(abs(volume-weighted candle change), delta-average lookback)) > imbalance threshold AND volume-weighted candle change > 0
Short: (bullish imbalance / SMA(abs(volume-weighted candle change), delta-average lookback)) > imbalance threshold AND volume-weighted candle change < 0
Exit: long, low <= close - ATR(ATR lookback) × stop multiplier OR high >= close + ATR(ATR lookback) × target multiplier
Exit: short, high >= close + ATR(ATR lookback) × stop multiplier OR low <= close - ATR(ATR lookback) × target multiplier