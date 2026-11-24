Calculation: fast T3 = T3(selected source, shorter T3 lookback, shared T3 smoothing factor)
Calculation: slow T3 = T3(selected source, longer T3 lookback, same T3 smoothing factor)
Calculation: selected MA(source, type, lookback) = the selected one of SMA(source, lookback), EMA(source, lookback), EMA(Heikin-Ashi open, lookback), T3(source, lookback, shared T3 smoothing factor), DEMA(source, lookback), TEMA(source, lookback), HMA(source, lookback), WMA(source, lookback), VWMA(source, lookback), SWMA(source), or VWAP(source)
Calculation: MA1 = selected MA(selected source, independently selected type 1, independently selected lookback 1)
Calculation: MA2 = selected MA(selected source, independently selected type 2, independently selected lookback 2)
Calculation: MA3 = selected MA(selected source, independently selected type 3, independently selected lookback 3)
Calculation: TSI = TSI(close, selected short lookback, selected long lookback), using separate fast and slow short and long lookback inputs selected by TSI speed
Calculation: TSI signal = EMA(TSI, fast or slow signal lookback selected by TSI speed)
Calculation: RSI = RSI(close, fast or slow RSI lookback selected by TSI speed)
Calculation: Parabolic SAR = Parabolic SAR(start, increment, maximum)
Calculation: dashboard score = one positive point for each bullish component, one negative point for each bearish component, and zero for each neutral component, summed across: TRM (TSI > TSI signal and RSI > RSI midpoint threshold; TSI < TSI signal and RSI < RSI midpoint threshold; otherwise neutral), T3 reversal (fast T3 >= slow T3 and close > slow T3; fast T3 <= slow T3 and close < slow T3; otherwise neutral), TSI curl (TSI < TSI signal and TSI rises from the previous chart bar; TSI > TSI signal and TSI falls from the previous chart bar; otherwise neutral), RSI (RSI > RSI midpoint threshold; otherwise bearish), TSI (TSI > TSI signal; otherwise bearish), each of MA1, MA2, and MA3 (close > that MA; otherwise bearish), and Parabolic SAR (close >= Parabolic SAR; otherwise bearish)
Long: TSI crosses above TSI signal AND RSI > RSI midpoint threshold OR RSI crosses above RSI midpoint threshold AND TSI > TSI signal
Short: TSI crosses below TSI signal AND RSI < RSI midpoint threshold OR RSI crosses below RSI midpoint threshold AND TSI < TSI signal
Long: TSI > TSI signal AND RSI > RSI midpoint threshold
Short: TSI < TSI signal AND RSI < RSI midpoint threshold
Long: close > slow T3
Short: close < slow T3
Long: close crosses above slow T3
Short: close crosses below slow T3
Long: Heikin-Ashi close > slow T3 OR Heikin-Ashi close = slow T3 AND Heikin-Ashi close >= Heikin-Ashi open
Short: Heikin-Ashi close < slow T3 OR Heikin-Ashi close = slow T3 AND Heikin-Ashi close < Heikin-Ashi open
Long: fast T3 > fast T3[1] OR slow T3 > slow T3[1]
Short: fast T3 <= fast T3[1] OR slow T3 <= slow T3[1]
Long: fast T3 > slow T3
Short: fast T3 <= slow T3
Long: TSI < TSI signal AND TSI rises from the previous chart bar
Short: TSI > TSI signal AND TSI falls from the previous chart bar
Long: close crosses above MA1 AND close > MA2 OR close crosses above MA2 AND close > MA1
Short: close crosses below MA1 AND close < MA2 OR close crosses below MA2 AND close < MA1
Long: close > MA1 AND close > MA2
Short: close < MA1 AND close < MA2
Long: close > MA1 OR close > MA2 OR close > MA3
Short: close <= MA1 OR close <= MA2 OR close <= MA3
Long: MA1 > MA1[1] OR MA2 > MA2[1] OR MA3 > MA3[1]
Short: MA1 <= MA1[1] OR MA2 <= MA2[1] OR MA3 <= MA3[1]
Long: MA1 < HL2 OR MA2 < MA1 OR MA3 < MA2
Short: MA1 >= HL2 OR MA2 >= MA1 OR MA3 >= MA2
Long: RSI crosses above RSI midpoint threshold OR RSI crosses above lower RSI momentum threshold
Short: RSI crosses below RSI midpoint threshold OR RSI crosses below upper RSI momentum threshold
Long: RSI > RSI midpoint threshold
Short: RSI <= RSI midpoint threshold
Long: TSI > TSI signal
Short: TSI <= TSI signal
Long: close crosses above Parabolic SAR
Short: close crosses below Parabolic SAR
Long: close >= Parabolic SAR
Short: close < Parabolic SAR
Long: dashboard score is positive
Short: dashboard score is negative