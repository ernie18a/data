Calculation: alignment score = for each i in {1,2,3,4}, count one when RSI(close, RSI lookback, T_i forming bar, sampled on chart bars) >= RSI midpoint and one when chart close > EMA(close, EMA lookback, T_i forming bar, sampled on chart bars), summed across all i; T1 < T2 < T3 < T4 in duration
Long: for any i in {1,2,3,4}, chart close > EMA(close, EMA lookback, T_i forming bar, sampled on chart bars)
Short: for any i in {1,2,3,4}, chart close <= EMA(close, EMA lookback, T_i forming bar, sampled on chart bars)
Long: for any i in {1,2,3,4}, RSI(close, RSI lookback, T_i forming bar, sampled on chart bars) <= RSI oversold threshold OR (RSI(close, RSI lookback, T_i forming bar, sampled on chart bars) >= RSI midpoint AND RSI(close, RSI lookback, T_i forming bar, sampled on chart bars) < RSI overbought threshold
Short: for any i in {1,2,3,4}, RSI(close, RSI lookback, T_i forming bar, sampled on chart bars) >= RSI overbought threshold
Long: chart close > VWAP(source, reset interval T5, calculated on chart bars) OR chart close > VWAP(source, reset interval T6, calculated on chart bars), where T5 < T6 in duration
Short: chart close <= VWAP(source, reset interval T5, calculated on chart bars) OR chart close <= VWAP(source, reset interval T6, calculated on chart bars), where T5 < T6 in duration
Long: alignment score >= strong bullish threshold
Short: alignment score < bearish-state boundary