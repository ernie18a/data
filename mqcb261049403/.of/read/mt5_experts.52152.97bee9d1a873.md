Calculation: Higher-timeframe SMA = simple moving average of close on a higher timeframe, using the still-forming bar and a longer lookback than the chart-timeframe SMA
Long: RSI < oversold threshold AND close > chart-timeframe SMA AND close > higher-timeframe SMA
Short: RSI > overbought threshold AND close < chart-timeframe SMA AND close < higher-timeframe SMA
Calculation: Initial stop-loss = entry price ± chart-timeframe ATR at entry × stop multiplier (subtract for long; add for short)
Calculation: Take-profit = entry price ± chart-timeframe ATR at entry × take-profit multiplier (add for long; subtract for short)
Calculation: Trailing stop for long = close − chart-timeframe ATR × trailing multiplier; trailing multiplier steps from low to medium to high as the absolute distance between close and entry exceeds one then two ATRs
Calculation: Trailing stop for short = close + chart-timeframe ATR × trailing multiplier; trailing multiplier steps from low to medium to high as the absolute distance between close and entry exceeds one then two ATRs
Exit: long, close <= active stop-loss OR close >= take-profit
Exit: short, close >= active stop-loss OR close <= take-profit