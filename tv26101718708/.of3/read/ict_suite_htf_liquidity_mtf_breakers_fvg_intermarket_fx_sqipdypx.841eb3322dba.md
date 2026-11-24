Calculation: Bullish breaker setup = a newly confirmed Pivot low(low, left lookback, right lookback) is below the preceding confirmed Pivot low, and the latest confirmed Pivot high(high, left lookback, right lookback) lies after that preceding low and before the new low; arm the intervening pivot high as the break level until it is exceeded or the setup expires after the arm-duration parameter.
Calculation: Bearish breaker setup = a newly confirmed Pivot high(high, left lookback, right lookback) is above the preceding confirmed Pivot high, and the latest confirmed Pivot low(low, left lookback, right lookback) lies after that preceding high and before the new high; arm the intervening pivot low as the break level until it is exceeded or the setup expires after the arm-duration parameter.
Long: bullish breaker setup is armed AND close > its intervening pivot-high break level
Short: bearish breaker setup is armed AND close < its intervening pivot-low break level
Long: current high >= bottom AND current low <= top of an active bullish breaker zone for the first time, where the zone is the intervening pivot-high candle's wick range or body according to the zone-source setting
Short: current high >= bottom AND current low <= top of an active bearish breaker zone for the first time, where the zone is the intervening pivot-low candle's wick range or body according to the zone-source setting
Long: low > high[2]
Short: high < low[2]
Long: a live, unflipped bearish FVG exists AND close > its top
Short: a live, unflipped bullish FVG exists AND close < its bottom
Long: for each configured timeframe T1 through T8, close >= open of that timeframe's bar, sampled on chart bars using lookahead-off values (forming bar in realtime, latest completed bar historically)
Short: for each configured timeframe T1 through T8, close < open of that timeframe's bar, sampled on chart bars using lookahead-off values (forming bar in realtime, latest completed bar historically)
Long: for each configured timeframe T1 through T8, EMA(close, shorter lookback) >= EMA(close, longer lookback), sampled on chart bars using lookahead-off values (forming bar in realtime, latest completed bar historically)
Short: for each configured timeframe T1 through T8, EMA(close, shorter lookback) < EMA(close, longer lookback), sampled on chart bars using lookahead-off values (forming bar in realtime, latest completed bar historically)
Long: for each dashboard external measure (dollar index, volatility index, S&P 500 index, Nasdaq index, Dow index, gold price, US 10-year yield), close on chart bars > its selected bias reference (open of T9 bar or EMA(close, lookback) on chart timeframe); external data uses lookahead off
Short: for each dashboard external measure (dollar index, volatility index, S&P 500 index, Nasdaq index, Dow index, gold price, US 10-year yield), close on chart bars < its selected bias reference (open of T9 bar or EMA(close, lookback) on chart timeframe); external data uses lookahead off
Long: for each displayed FX pair, close > open of its T9 bar, sampled on chart bars using lookahead-off values (forming bar in realtime, latest completed bar historically)
Short: for each displayed FX pair, close < open of its T9 bar, sampled on chart bars using lookahead-off values (forming bar in realtime, latest completed bar historically)
Long: exactly one of external series A and external series B has low <= lowest(low, lookback)[1], using their chart-timeframe bars sampled with lookahead off
Short: exactly one of external series A and external series B has high >= highest(high, lookback)[1], using their chart-timeframe bars sampled with lookahead off