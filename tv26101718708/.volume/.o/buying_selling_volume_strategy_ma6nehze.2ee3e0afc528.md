Calculation: Buyer volume = custom-timeframe volume × (close − low) / (high − low); seller volume = custom-timeframe volume × (high − close) / (high − low) (both 0 when high = low), using the bar still forming.
Calculation: Signed volume imbalance = buyer volume if buyer volume > seller volume, otherwise −buyer volume; plus seller volume if seller volume > buyer volume, otherwise −seller volume.
Calculation: Upper band = custom-timeframe SMA of signed volume imbalance + 2 × its standard deviation; both use the same lookback and the bar still forming.
Calculation: Weekly VWAP = VWAP of hlc3 for the week still forming.
Calculation: Daily ATR percentage = 14-day SMA of daily true range divided by daily close × 100; use the daily bar still forming and the prior daily close.
Long: signed volume imbalance > upper band AND buyer volume contribution > seller volume contribution AND close > weekly VWAP
Short: signed volume imbalance > upper band AND buyer volume contribution < seller volume contribution AND close < weekly VWAP
Exit: long, short condition OR close > entry price × (1 + daily ATR percentage × profit multiplier / 100) OR high > that target OR close < entry price × (1 − daily ATR percentage × stop multiplier / 100) OR low < that stop
Exit: short, long condition