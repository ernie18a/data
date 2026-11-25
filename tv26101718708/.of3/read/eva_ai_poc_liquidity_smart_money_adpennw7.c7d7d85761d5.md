Calculation: profile VAH = Volume Profile VAH(profile-range OHLCV, value-area fraction; when lower-timeframe precision is enabled, use T1 last completed bars sampled on chart bars, otherwise chart bars)
Calculation: profile VAL = Volume Profile VAL(profile-range OHLCV, value-area fraction; when lower-timeframe precision is enabled, use T1 last completed bars sampled on chart bars, otherwise chart bars)
Long: close > profile VAH
Long: confirmed chart bar AND valid current profile AND close crosses above profile VAH
Short: close < profile VAL
Short: confirmed chart bar AND valid current profile AND close crosses below profile VAL