Calculation: FATL color = rising if FATL(close, lookback) > FATL(close, lookback)[1], falling if FATL(close, lookback) < FATL(close, lookback)[1], otherwise the prior bar's FATL color
Long: FATL color is rising on a chart bar
Short: FATL color is falling on a chart bar
Long: On T1 bars, the last completed bar's FATL color is rising AND the preceding T1 bar's FATL color is not rising
Short: On T1 bars, the last completed bar's FATL color is falling AND the preceding T1 bar's FATL color is not falling