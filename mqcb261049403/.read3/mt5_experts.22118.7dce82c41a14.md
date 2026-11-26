Calculation: SSL_NRTR color = bullish when close > smooth(high, lookback, method, phase), bearish when close < smooth(low, same lookback, method, phase), otherwise neutral
Long: On T1 bars, last completed SSL_NRTR color is bullish AND the preceding completed T1 color is neutral or bearish
Short: On T1 bars, last completed SSL_NRTR color is bearish AND the preceding completed T1 color is neutral or bullish
Exit: long, low <= entry price - stop-loss points × point size OR high >= entry price + take-profit points × point size OR elapsed minutes since entry > holding-time limit
Exit: short, high >= entry price + stop-loss points × point size OR low <= entry price - take-profit points × point size OR elapsed minutes since entry > holding-time limit