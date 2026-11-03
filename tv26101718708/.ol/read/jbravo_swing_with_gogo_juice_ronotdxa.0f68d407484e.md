Calculation: VWAP = session volume-weighted average of (high + low + close) / 3
Calculation: Candle body low = min(open, close)
Calculation: Lower of SMA 9 and EMA 20 = min(SMA 9, EMA 20)
Calculation: SMA 9 uptrend = SMA 9 > its value 2 bars ago
Calculation: SMA 180 uptrend = SMA 180 > its value 2 bars ago
Calculation: EMA 20 uptrend = EMA 20 > 20-period SMA of close shifted 2 bars back
Long: VWAP > EMA 20
Long: no position and candle body low > SMA 9
Long: no position and candle body low > SMA 9 AND SMA 9 uptrend AND EMA 20 uptrend AND SMA 180 uptrend AND SMA 9 > EMA 20 AND EMA 20 > SMA 180
Short: VWAP < EMA 20
Exit: long, VWAP < EMA 20
Exit: short, VWAP > EMA 20
Exit: long, position is long AND close < lower of SMA 9 and EMA 20