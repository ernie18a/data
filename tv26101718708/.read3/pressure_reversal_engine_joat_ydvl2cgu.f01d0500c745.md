Calculation: BarRange = max(high - low, minimum tick)
Calculation: BodySize = abs(close - open)
Calculation: BuyFraction = clamp(w0 + w1 * (close - low) / BarRange + w2 * BodySize / BarRange + w3 * (1 if close >= open else 0), B_min, B_max)
Calculation: Imbalance = 2 * BuyFraction - 1
Calculation: BidDominant = Imbalance > G_pressure
Calculation: AskDominant = Imbalance < -G_pressure
Calculation: SmallBody = BodySize / BarRange < B_body
Calculation: VolumeExpansion = volume > M_volume * SMA(volume, N_volume)
Calculation: LowerShadow = min(open, close) - low
Calculation: UpperShadow = high - max(open, close)
Calculation: AskAbsorbed = AskDominant AND close > open AND LowerShadow > UpperShadow AND SmallBody AND VolumeExpansion
Calculation: BidAbsorbed = BidDominant AND close < open AND UpperShadow > LowerShadow AND SmallBody AND VolumeExpansion
Calculation: UpBarAskDominant = close > open AND AskDominant
Calculation: DownBarBidDominant = close < open AND BidDominant
Calculation: WindowSkew = sum(volume[k] * Imbalance[k] for k = 0..L_profile-1) / sum(volume[k] for k = 0..L_profile-1)
Calculation: LastPivotHigh = most recent non-NA value of PivotHigh(high, P_left, P_right)
Calculation: LastPivotLow = most recent non-NA value of PivotLow(low, P_left, P_right)
Calculation: PivotHighRejection = high > LastPivotHigh AND close < LastPivotHigh AND AskDominant
Calculation: PivotLowRejection = low < LastPivotLow AND close > LastPivotLow AND BidDominant
Calculation: PivotHighReclaim = close > LastPivotHigh AND close[1] <= LastPivotHigh AND BidDominant
Calculation: PivotLowReclaim = close < LastPivotLow AND close[1] >= LastPivotLow AND AskDominant
Calculation: EmaUp = EMA(close, N_short) > EMA(close, N_long)
Calculation: EmaDown = EMA(close, N_short) < EMA(close, N_long)
Calculation: AboveProfile = close > POC(hlc3, volume, L_profile, R_rows) AND close > VAL(hlc3, volume, L_profile, R_rows, V_va)
Calculation: BelowProfile = close < POC(hlc3, volume, L_profile, R_rows) AND close < VAH(hlc3, volume, L_profile, R_rows, V_va)
Calculation: LongSetup = EmaUp AND AboveProfile AND (AskAbsorbed OR PivotLowRejection OR PivotHighReclaim) AND WindowSkew > -S_skew
Calculation: ShortSetup = EmaDown AND BelowProfile AND (BidAbsorbed OR PivotHighRejection OR PivotLowReclaim) AND WindowSkew < S_skew
Calculation: Entry = (LongSetup OR ShortSetup) AND NOT (Entry[1] OR Entry[2] OR ... OR Entry[C_cool])
Long: LongSetup AND Entry
Short: ShortSetup AND Entry
Long: AskAbsorbed
Short: BidAbsorbed
Exit: long, BidAbsorbed OR DownBarBidDominant OR close < EMA(close, N_short) OR PivotHighRejection
Exit: short, AskAbsorbed OR UpBarAskDominant OR close > EMA(close, N_short) OR PivotLowRejection