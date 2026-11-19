Calculation: Fast EMA = EMA(close, shorter EMA lookback)
Calculation: Slow EMA = EMA(close, longer EMA lookback)
Calculation: ATR = ATR(ATR lookback)
Calculation: Prior liquidity low = lowest(low[1], liquidity lookback)
Calculation: Prior liquidity high = highest(high[1], liquidity lookback)
Calculation: T1 midpoint = (high(T1, last completed bar) + low(T1, last completed bar)) / 2, sampled on chart bars
Calculation: Bullish bias = close(T1, last completed bar) > T1 midpoint, evaluated on chart bars
Calculation: Bearish bias = close(T1, last completed bar) < T1 midpoint, evaluated on chart bars
Calculation: Uptrend = close > Fast EMA AND Fast EMA > Slow EMA
Calculation: Downtrend = close < Fast EMA AND Fast EMA < Slow EMA
Calculation: Fast EMA rising = Fast EMA > Fast EMA[slope lookback]
Calculation: Fast EMA falling = Fast EMA < Fast EMA[slope lookback]
Calculation: Bullish sweep = low < Prior liquidity low AND close > Prior liquidity low AND close - low > ATR × sweep ATR multiple selected by entry mode
Calculation: Bearish sweep = high > Prior liquidity high AND close < Prior liquidity high AND high - close > ATR × sweep ATR multiple selected by entry mode
Calculation: Bullish rejection = close > open AND min(open, close) - low > abs(close - open) × wick/body multiple selected by entry mode AND close >= high - (high - low) × close-location fraction
Calculation: Bearish rejection = close < open AND high - max(open, close) > abs(close - open) × wick/body multiple selected by entry mode AND close <= low + (high - low) × close-location fraction
Calculation: Session allowed = session filter disabled OR datetime is within the configured session in the configured timezone
Calculation: Long signal condition = Session allowed AND Bullish sweep AND Bullish rejection AND (daily bias filter disabled OR Bullish bias) AND (RSI filter disabled OR (RSI(close, RSI lookback) > RSI midpoint parameter AND RSI(close, RSI lookback) < upper RSI threshold parameter)) AND (ADX filter disabled OR ADX(DMI lookback, same ADX smoothing lookback) >= minimum ADX parameter) AND (entry mode does not require slope OR Fast EMA rising) AND more than the cooldown parameter bars since the previous long signal AND close > Fast EMA AND Fast EMA > Slow EMA AND chart bar confirmed
Calculation: Trend short signal condition = Session allowed AND Bearish sweep AND Bearish rejection AND (daily bias filter disabled OR Bearish bias) AND (RSI filter disabled OR (RSI(close, RSI lookback) < RSI midpoint parameter AND RSI(close, RSI lookback) > lower RSI threshold parameter)) AND (ADX filter disabled OR ADX(DMI lookback, same ADX smoothing lookback) >= minimum ADX parameter) AND (entry mode does not require slope OR Fast EMA falling) AND more than the cooldown parameter bars since the previous short signal AND close < Fast EMA AND Fast EMA < Slow EMA AND chart bar confirmed
Calculation: Premium short signal condition = premium sell enabled AND Session allowed AND Bearish sweep AND Bearish rejection AND close > Fast EMA AND Fast EMA falling AND more than the cooldown parameter bars since the previous short signal AND chart bar confirmed
Calculation: Long stop = lowest(low, stop lookback) captured on the long entry signal bar
Calculation: Short stop = highest(high, stop lookback) captured on the short entry signal bar
Calculation: Long target = long entry signal bar close + (long entry signal bar close - Long stop) × risk/reward parameter
Calculation: Short target = short entry signal bar close - (Short stop - short entry signal bar close) × risk/reward parameter
Calculation: Long wait condition = Session allowed AND Bullish sweep AND (daily bias filter disabled OR Bullish bias) AND (trend filter disabled OR Uptrend) AND NOT Long signal condition
Calculation: Short wait condition = Session allowed AND Bearish sweep AND (daily bias filter disabled OR Bearish bias) AND (trend filter disabled OR Downtrend) AND NOT Trend short signal condition AND NOT Premium short signal condition
Long: Bullish bias
Short: Bearish bias
Long: Uptrend
Short: Downtrend
Long: Fast EMA rising
Short: Fast EMA falling
Long: Bullish rejection
Short: Bearish rejection
Long: Bullish sweep
Short: Bearish sweep
Long: Long wait condition
Short: Short wait condition
Long: Long signal condition
Short: Trend short signal condition
Short: Premium short signal condition
Long: Long signal condition AND position is flat AND close > Long stop
Short: (Trend short signal condition OR Premium short signal condition) AND position is flat AND Short stop > close
Exit: long, low <= Long stop OR high >= Long target
Exit: short, high >= Short stop OR low <= Short target