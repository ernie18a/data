Calculation: Aggregated open interest = sum over exchanges of Open interest, with missing values as zero
Calculation: Volume anomaly = volume > SMA(volume, V) + K * STDEV(volume, V)
Calculation: Body ratio = ABS(close - open) / ABS(high - low)
Calculation: Long signal = BarsSince(low < Lowest(low, L)[1] AND close > Lowest(low, L)[1]) <= E AND (Volume anomaly OR Body ratio < B) AND Tether dominance < SMA(Tether dominance, D) AND Aggregated open interest <= SMA(Aggregated open interest, O) AND Sum(Long signal, E)[1] = 0
Calculation: Short signal = BarsSince(high > Highest(high, L)[1] AND close < Highest(high, L)[1]) <= E AND (Volume anomaly OR Body ratio < B) AND Tether dominance > SMA(Tether dominance, D) AND Aggregated open interest > SMA(Aggregated open interest, O) AND Sum(Short signal, E)[1] = 0
Long: position flat AND Long signal
Long: position long AND close < entry price AND Long signal
Short: position flat AND Short signal
Short: position short AND close > entry price AND Short signal
Calculation: Long lock = unset if position flat; else entry price * (1 + LK2) if high >= entry price * (1 + LK2); else entry price * (1 + LK1) if high >= entry price * (1 + LK1) AND Long lock[1] is unset; else Long lock[1]; where LK2 > LK1
Calculation: Short lock = unset if position flat; else entry price * (1 - LK2) if low <= entry price * (1 - LK2); else entry price * (1 - LK1) if low <= entry price * (1 - LK1) AND Short lock[1] is unset; else Short lock[1]; where LK2 > LK1
Exit: long, close >= entry price * (1 + TP) AND close < EMA(close, F)
Exit: long, close <= entry price * (1 - SL)
Exit: long, high >= entry price * (1 + MX)
Exit: long, Long lock[1] is set AND low <= Long lock[1]
Exit: long, Long lock[1] is unset AND low <= entry price * (1 - CAT)
Exit: short, close <= entry price * (1 - TP) AND close > EMA(close, F)
Exit: short, close >= entry price * (1 + SL)
Exit: short, low <= entry price * (1 - MX)
Exit: short, Short lock[1] is set AND high >= Short lock[1]
Exit: short, Short lock[1] is unset AND high >= entry price * (1 + CAT)