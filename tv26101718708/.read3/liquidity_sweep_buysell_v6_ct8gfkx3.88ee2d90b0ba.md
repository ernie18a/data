Calculation: bullish sweep = low <= latest confirmed Pivot low(low, swing length, swing length) × (1 − sweep tolerance / 100) AND close > latest confirmed Pivot low(low, swing length, swing length)
Calculation: bearish sweep = high >= latest confirmed Pivot high(high, swing length, swing length) × (1 + sweep tolerance / 100) AND close < latest confirmed Pivot high(high, swing length, swing length)
Long: bullish sweep AND (EMA filter disabled OR close > EMA(close, EMA lookback)) AND (volume filter disabled OR volume > SMA(volume, volume-average lookback))
Short: bearish sweep AND (EMA filter disabled OR close < EMA(close, EMA lookback)) AND (volume filter disabled OR volume > SMA(volume, volume-average lookback))
Exit: long, bearish sweep
Exit: short, bullish sweep