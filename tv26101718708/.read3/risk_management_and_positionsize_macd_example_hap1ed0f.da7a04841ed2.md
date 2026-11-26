Calculation: Smoothed MACD = SMA(MACD line(close, fast lookback, slow lookback, MACD MA type, T1 still-forming bar), rounded chart-bars-per-T1-bar lookback), evaluated on chart bars
Calculation: Smoothed MACD signal = SMA(MACD signal line(close, fast lookback, slow lookback, signal lookback, MACD MA type, T1 still-forming bar), rounded chart-bars-per-T1-bar lookback), evaluated on chart bars
Calculation: Smoothed trend MA = SMA(selected trend moving average(close, trend lookback, trend MA type, T2 still-forming bar), rounded chart-bars-per-T2-bar lookback), evaluated on chart bars
Long: Smoothed MACD crosses above Smoothed MACD signal AND Smoothed MACD < 0
Long: Smoothed MACD crosses above Smoothed MACD signal AND Smoothed MACD < 0 AND Smoothed trend MA > its prior chart-bar value
Short: Smoothed MACD crosses below Smoothed MACD signal AND Smoothed MACD > 0
Short: Smoothed MACD crosses below Smoothed MACD signal AND Smoothed MACD > 0 AND Smoothed trend MA < its prior chart-bar value
Exit: long, Smoothed MACD crosses below Smoothed MACD signal
Exit: short, Smoothed MACD crosses above Smoothed MACD signal