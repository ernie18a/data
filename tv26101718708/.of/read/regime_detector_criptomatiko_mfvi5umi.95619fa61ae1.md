Calculation: Weekly RSI = RSI of weekly closes on the higher weekly timeframe, using the last completed weekly bar
Calculation: Separation = Weekly RSI − SMA of Weekly RSI, using a longer lookback for the RSI and a shorter lookback for its SMA
Calculation: Regime = UPTREND when Separation > minimum separation; DOWNTREND when Separation < −minimum separation; otherwise SIDEWAYS
Long: Regime = UPTREND AND Regime differs from the previous chart bar's Regime
Short: Regime = DOWNTREND AND Regime differs from the previous chart bar's Regime