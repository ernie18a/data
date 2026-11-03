Calculation: Upper band = Volume-weighted average of highs over the lookback, rounded to the configured price precision; use the value shifted forward by the configured number of bars. Calculate from completed bars on the indicator timeframe, which may be higher or lower than the chart timeframe.
Calculation: Lower band = Volume-weighted average of lows over the same lookback and volume series as the upper band, rounded to the configured price precision; use the value shifted forward by the configured number of bars. Calculate from completed bars on the indicator timeframe, which may be higher or lower than the chart timeframe.
Long: Completed bar close > upper band AND previous completed bar close <= its upper band
Short: Completed bar close < lower band AND previous completed bar close >= its lower band
Exit: long, completed bar close < lower band
Exit: short, completed bar close > upper band