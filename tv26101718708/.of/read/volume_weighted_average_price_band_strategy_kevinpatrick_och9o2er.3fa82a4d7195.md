Calculation: VWAP = session-anchored volume-weighted average price of close, reset at the start of each session
Calculation: ML = short-length EMA of the series (SMA(close, N) + s*(VWAP - SMA(close, N))), where s is between 0 and 1 and the series is read from f bars earlier (shifted forward by f bars)
Calculation: STD = standard deviation of close over the same N used in the SMA above
Calculation: UpperBand_k = ML + m_k*STD; LowerBand_k = ML - m_k*STD; two band levels exist with m_1 < m_2
Long: position is flat AND close crosses above LowerBand_k (previous close <= previous LowerBand_k AND current close > current LowerBand_k), using one selected band level k (narrow or wide)
Short: close crosses below UpperBand_k (previous close >= previous UpperBand_k AND current close < current UpperBand_k) for the narrow band level OR the wide band level
Long: VWAP > ML
Short: VWAP < ML
Long: close > UpperBand_1
Short: close < LowerBand_1
Exit: long, low <= entry price*(1 - stop%) AND TP1 has not yet been reached since entry (full stop on the whole position)
Exit: long, high >= entry price*(1 + tp1%) (close a small part of the position; marks TP1 reached)
Exit: long, high >= entry price*(1 + tp2%) (close a further part), with tp2% > tp1%
Exit: long, high >= entry price*(1 + tp3%) (close a further part), with tp3% > tp2%
Exit: long, TP1 has been reached AND low <= (highest high since entry)*(1 - trail%) (closes the remaining part), with trail% < stop%