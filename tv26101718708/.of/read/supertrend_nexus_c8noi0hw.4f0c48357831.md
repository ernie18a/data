Calculation: ATR = Wilder (RMA) average of true range over a fixed lookback
Calculation: ER = abs(close - close N bars ago) / sum of abs(close - prior close) over the same N bars (0 if the denominator is 0)
Calculation: mult = max_mult - (max_mult - min_mult) * ER (max_mult > min_mult; higher ER gives a smaller multiplier)
Calculation: Supertrend bands: raw_upper = hl2 + mult*ATR, raw_lower = hl2 - mult*ATR. final_lower = max(raw_lower, prior final_lower) if prior close > prior final_lower, else raw_lower. final_upper = min(raw_upper, prior final_upper) if prior close < prior final_upper, else raw_upper. On the first bar, the prior values are the current values.
Calculation: trend = +1 or -1, initial +1, carried forward each bar. It becomes +1 if prior trend is -1 AND close > prior bar's final_upper. It becomes -1 if prior trend is +1 AND close < prior bar's final_lower. Otherwise it is unchanged.
Long: trend flips from -1 to +1 on this bar (prior trend = -1 AND close > prior bar's final_upper)
Short: trend flips from +1 to -1 on this bar (prior trend = +1 AND close < prior bar's final_lower)