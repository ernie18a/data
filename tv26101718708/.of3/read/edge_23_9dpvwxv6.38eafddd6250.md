Calculation: BullDivergence(O, P_os, P_lookback) = O < P_os AND bull anchor[1] exists AND low < anchor low[1] AND O > anchor O[1]; bull anchor = (low, O) of the bar with the lowest O among bars with O < P_os since the anchor was last cleared; the anchor is cleared on the first bar more than P_lookback bars after its bar
Calculation: BearDivergence(O, P_ob, P_lookback) = O > P_ob AND bear anchor[1] exists AND high > anchor high[1] AND O < anchor O[1]; bear anchor = (high, O) of the bar with the highest O among bars with O > P_ob since the anchor was last cleared; the anchor is cleared on the first bar more than P_lookback bars after its bar
Calculation: RelativeVolume = volume / SMA(volume, P_vol_len)
Calculation: LowerShadowShare = (min(open, close) - low) / (high - low)
Calculation: UpperShadowShare = (high - max(open, close)) / (high - low)
Calculation: BullCount = count of true among BullDivergence(RSI(close, P_rsi_len), P_rsi_os, P_lookback), BullDivergence(MFI((high + low + close) / 3, P_mfi_len), P_mfi_os, P_lookback), and (RelativeVolume >= P_vol_mult AND LowerShadowShare >= P_wick AND RSI(close, P_rsi_len) < P_rsi_os)
Calculation: BearCount = count of true among BearDivergence(RSI(close, P_rsi_len), P_rsi_ob, P_lookback), BearDivergence(MFI((high + low + close) / 3, P_mfi_len), P_mfi_ob, P_lookback), and (RelativeVolume >= P_vol_mult AND UpperShadowShare >= P_wick AND RSI(close, P_rsi_len) > P_rsi_ob)
Calculation: MaxBullScore(X) = max over monitored external markets of BullScore, where BullScore = BullCount + (1 if ATR(P_atr_len) / SMA(ATR(P_atr_len), P_atr_avg_len) > P_atr_ext, else 0) when BullCount >= 1 AND BearCount = 0, and 0 otherwise; evaluated on bars of X, where X = chart uses the current bar and X = T1 to T4 uses the last completed bar of X
Calculation: MaxBearScore(X) = max over monitored external markets of BearScore, where BearScore = BearCount + (1 if ATR(P_atr_len) / SMA(ATR(P_atr_len), P_atr_avg_len) > P_atr_ext, else 0) when BearCount >= 1 AND BullCount = 0, and 0 otherwise; evaluated on bars of X, where X = chart uses the current bar and X = T1 to T4 uses the last completed bar of X
Long: BullDivergence(RSI(close, P_rsi_len), P_rsi_os, P_lookback)
Short: BearDivergence(RSI(close, P_rsi_len), P_rsi_ob, P_lookback)
Long: MaxBullScore(chart) >= P_strong
Long: MaxBullScore(T1) >= P_strong
Long: MaxBullScore(T2) >= P_strong
Long: MaxBullScore(T3) >= P_strong
Long: MaxBullScore(T4) >= P_strong
Short: MaxBearScore(chart) >= P_strong
Short: MaxBearScore(T1) >= P_strong
Short: MaxBearScore(T2) >= P_strong
Short: MaxBearScore(T3) >= P_strong
Short: MaxBearScore(T4) >= P_strong
Long: MaxBullScore(chart) >= P_premium OR MaxBullScore(T1) >= P_premium OR MaxBullScore(T2) >= P_premium OR MaxBullScore(T3) >= P_premium OR MaxBullScore(T4) >= P_premium
Short: MaxBearScore(chart) >= P_premium OR MaxBearScore(T1) >= P_premium OR MaxBearScore(T2) >= P_premium OR MaxBearScore(T3) >= P_premium OR MaxBearScore(T4) >= P_premium