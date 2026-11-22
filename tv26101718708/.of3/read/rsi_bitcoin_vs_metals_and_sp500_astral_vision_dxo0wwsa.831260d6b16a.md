Calculation: Selected RSI = RSI(close, RSI lookback, T1, last completed bar historically and still-forming bar in realtime), computed on T1 bars and sampled onto chart bars with lookahead off for the selected component series, or the arithmetic mean on chart bars of the three component-series RSIs
Long: Mode=Extremes AND Selected RSI <= oversold threshold
Short: Mode=Extremes AND Selected RSI >= overbought threshold
Long: Mode=Trend AND EMA(Selected RSI, EMA lookback) >= 50, calculated on chart bars from the T1 RSI values
Short: Mode=Trend AND EMA(Selected RSI, EMA lookback) < 50, calculated on chart bars from the T1 RSI values
Calculation: Selected relative-strength RSI = RSI of the Bitcoin-to-selected-benchmark price ratio over T1 using the RSI period; for the average selection, the arithmetic mean of the gold, silver, and S&P 500 relative-strength RSIs
Long: threshold mode selected AND selected relative-strength RSI < oversold threshold
Short: threshold mode selected AND selected relative-strength RSI > overbought threshold
Long: trend mode selected AND EMA(selected relative-strength RSI, EMA period) >= RSI midpoint
Short: trend mode selected AND EMA(selected relative-strength RSI, EMA period) < RSI midpoint