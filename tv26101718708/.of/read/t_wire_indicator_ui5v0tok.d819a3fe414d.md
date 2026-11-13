Calculation: TrendUp = EMA(close, short length) > EMA(close, long length) AND Supertrend is bullish (direction up)
Calculation: TrendDown = EMA(close, short length) <= EMA(close, long length) AND Supertrend is bearish (direction down)
Calculation: HTF_Up = on a higher timeframe than the chart, using the last completed higher-timeframe bar: EMA(close, short length) > EMA(close, long length) AND Supertrend is bullish (same parameters as the chart)
Calculation: HTF_Down = on a higher timeframe than the chart, using the last completed higher-timeframe bar: EMA(close, short length) < EMA(close, long length) AND Supertrend is bearish (same parameters as the chart)
Long: TrendUp on the current bar AND TrendUp was false on the previous bar
Long: the Long condition above AND 50 < RSI < overbought level AND HTF_Up (a stricter variant of the Long above)
Short: TrendDown on the current bar AND TrendDown was false on the previous bar (the previous bar's EMA comparison is strict, short < long)
Short: the Short condition above AND oversold level < RSI < 50 AND HTF_Down (a stricter variant of the Short above)