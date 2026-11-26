Calculation: TouchLong(m) = low <= m + ATR(P_atr, last completed bar) * P_up AND low >= m - ATR(P_atr, last completed bar) * P_dn AND close > m AND close > open
Calculation: TouchShort(m) = high >= m - ATR(P_atr, last completed bar) * P_up AND high <= m + ATR(P_atr, last completed bar) * P_dn AND close < m AND close < open
Calculation: AnyBounceLong = TouchLong(EMA(close, L1, T1, last completed bar)) OR TouchLong(EMA(close, L2, T1, last completed bar)) OR TouchLong(EMA(close, L3, T1, last completed bar)) OR TouchLong(EMA(close, L4, T1, last completed bar)) OR TouchLong(EMA(close, L5, T1, last completed bar)) OR TouchLong(SMA(close, S1, T1, last completed bar)) OR TouchLong(SMA(close, S2, T1, last completed bar)) OR TouchLong(SMA(close, S3, T1, last completed bar))
Calculation: AnyRejectShort = TouchShort(EMA(close, L1, T1, last completed bar)) OR TouchShort(EMA(close, L2, T1, last completed bar)) OR TouchShort(EMA(close, L3, T1, last completed bar)) OR TouchShort(EMA(close, L4, T1, last completed bar)) OR TouchShort(EMA(close, L5, T1, last completed bar)) OR TouchShort(SMA(close, S1, T1, last completed bar)) OR TouchShort(SMA(close, S2, T1, last completed bar)) OR TouchShort(SMA(close, S3, T1, last completed bar))
Calculation: AboveAllMAs = close > EMA(close, L1, T1, last completed bar) AND close > EMA(close, L2, T1, last completed bar) AND close > EMA(close, L3, T1, last completed bar) AND close > SMA(close, S1, T1, last completed bar) AND close > EMA(close, L4, T1, last completed bar) AND close > SMA(close, S2, T1, last completed bar) AND close > EMA(close, L5, T1, last completed bar) AND close > SMA(close, S3, T1, last completed bar)
Calculation: NearPriorDayLow = abs(low - low(T1, last completed bar)) <= ATR(P_atr, last completed bar) * P_conf
Calculation: NearPriorDayHigh = abs(high - high(T1, last completed bar)) <= ATR(P_atr, last completed bar) * P_conf
Calculation: PullbackUptrend = close > EMA(close, L1, T1, last completed bar) AND EMA(close, L1, T1, last completed bar) > EMA(close, L2, T1, last completed bar) AND (close > EMA(close, L3, T1, last completed bar) OR NOT P_trend_gate)
Calculation: DownCloses = number of i from 1 to P_lb where close[i] < close[i + 1]
Calculation: DipResumeLong = PullbackUptrend AND DownCloses >= P_min AND close > open AND close > high[1]
Calculation: NearMALong(m) = low > m AND (low - m) / m <= P_prox AND close > open AND NOT TouchLong(m) AND NOT TouchShort(m)
Calculation: NearMAShort(m) = high < m AND (m - high) / m <= P_prox AND close < open AND NOT TouchLong(m) AND NOT TouchShort(m)
Long: AnyBounceLong
Long: AnyBounceLong AND AboveAllMAs
Long: AnyBounceLong AND NearPriorDayLow
Long: DipResumeLong
Long: DipResumeLong AND AboveAllMAs
Long: NearMALong(EMA(close, L1, T1, last completed bar)) OR NearMALong(EMA(close, L2, T1, last completed bar)) OR NearMALong(EMA(close, L3, T1, last completed bar)) OR NearMALong(EMA(close, L4, T1, last completed bar)) OR NearMALong(EMA(close, L5, T1, last completed bar)) OR NearMALong(SMA(close, S1, T1, last completed bar)) OR NearMALong(SMA(close, S2, T1, last completed bar)) OR NearMALong(SMA(close, S3, T1, last completed bar))
Short: AnyRejectShort
Short: AnyRejectShort AND NearPriorDayHigh
Short: NearMAShort(EMA(close, L1, T1, last completed bar)) OR NearMAShort(EMA(close, L2, T1, last completed bar)) OR NearMAShort(EMA(close, L3, T1, last completed bar)) OR NearMAShort(EMA(close, L4, T1, last completed bar)) OR NearMAShort(EMA(close, L5, T1, last completed bar)) OR NearMAShort(SMA(close, S1, T1, last completed bar)) OR NearMAShort(SMA(close, S2, T1, last completed bar)) OR NearMAShort(SMA(close, S3, T1, last completed bar))