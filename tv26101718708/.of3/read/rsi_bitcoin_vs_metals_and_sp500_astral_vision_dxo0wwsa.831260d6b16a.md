Calculation: Selected RSI = RSI(close, RSI lookback, T1, last completed bar historically and still-forming bar in realtime), computed on T1 bars and sampled onto chart bars with lookahead off for the selected component series, or the arithmetic mean on chart bars of the three component-series RSIs
Long: Mode=Extremes AND Selected RSI <= oversold threshold
Short: Mode=Extremes AND Selected RSI >= overbought threshold
Long: Mode=Trend AND EMA(Selected RSI, EMA lookback) >= 50, calculated on chart bars from the T1 RSI values
Short: Mode=Trend AND EMA(Selected RSI, EMA lookback) < 50, calculated on chart bars from the T1 RSI values