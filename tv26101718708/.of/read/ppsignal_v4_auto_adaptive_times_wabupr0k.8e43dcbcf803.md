Calculation: Close LSMA = least-squares moving average of (current close + 2 × previous close + 2 × close two bars ago + close three bars ago) / 6, using the same lookback as Open LSMA, on the higher timeframe’s still-forming bar
Calculation: Open LSMA = least-squares moving average of (current open + 2 × previous open + 2 × open two bars ago + open three bars ago) / 6, using the same lookback as Close LSMA, on the higher timeframe’s still-forming bar
Long: Close LSMA > Open LSMA
Short: Close LSMA < Open LSMA
Exit: Long, Close LSMA < Open LSMA
Exit: Short, Close LSMA > Open LSMA