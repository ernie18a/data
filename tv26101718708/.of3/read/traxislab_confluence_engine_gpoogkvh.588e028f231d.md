Calculation: CVD = running total of volume * CLV(high, low, close), where CLV = ((close - low) - (high - close)) / (high - low) and CLV = 0 when high = low
Calculation: DeltaEMA = EMA(volume * CLV(high, low, close), P_dp)
Calculation: StructureHigh = most recent PivotHigh(high, P_ms, 1), cleared when close crosses above StructureHigh
Calculation: StructureLow = most recent PivotLow(low, P_ms, 1), cleared when close crosses below StructureLow
Calculation: StructureTrend = 1 when close crosses above StructureHigh, -1 when close crosses below StructureLow, otherwise StructureTrend[1]
Calculation: RealBullBOS = close crosses above StructureHigh AND CVD > CVD[P_cvd] AND volume > P_bos_vol * SMA(volume, P_vol_ma)
Calculation: RealBearBOS = close crosses below StructureLow AND CVD < CVD[P_cvd] AND volume > P_bos_vol * SMA(volume, P_vol_ma)
Calculation: CHoCHBull = close crosses above StructureHigh AND StructureTrend[1] = -1
Calculation: CHoCHBear = close crosses below StructureLow AND StructureTrend[1] = 1
Calculation: BullDivRun = number of consecutive bars ending now where close < close[P_div] AND CVD > CVD[P_div], else 0
Calculation: BearDivRun = number of consecutive bars ending now where close > close[P_div] AND CVD < CVD[P_div], else 0
Calculation: VolumeRatio = volume / SMA(volume, P_vol_ma)
Calculation: RangeRatio = (high - low) / SMA(high - low, P_vol_ma)
Calculation: AbsorptionBull = VolumeRatio >= P_eff AND RangeRatio <= P_abs AND close < EMA(close, P_ema)
Calculation: AbsorptionBear = VolumeRatio >= P_eff AND RangeRatio <= P_abs AND close > EMA(close, P_ema)
Calculation: ClimaxTop = VolumeRatio >= P_eff AND RangeRatio >= P_clx AND close > open AND close > EMA(close, P_ema)
Calculation: ClimaxBottom = VolumeRatio >= P_eff AND RangeRatio >= P_clx AND close < open AND close < EMA(close, P_ema)
Calculation: SweepLow = most recent PivotLow(low, P_sw, 1), cleared when BullSweep occurs
Calculation: BullSweep = low < SweepLow AND close > SweepLow
Calculation: SweepHigh = most recent PivotHigh(high, P_sw, 1), cleared when BearSweep occurs
Calculation: BearSweep = high > SweepHigh AND close < SweepHigh
Calculation: Equilibrium = (highest(high, P_pd) + lowest(low, P_pd)) / 2, recalculated on bars where RealBullBOS or RealBearBOS occurs and otherwise held
Calculation: BullFVGScore = F_base + F_big * [low - high[2] > P_gap_hi * ATR(P_atr)] + F_small * [low - high[2] > P_gap_lo * ATR(P_atr) AND low - high[2] <= P_gap_hi * ATR(P_atr)] + F_vol * [volume[1] > P_fvg_vol * SMA(volume, P_vol_ma)] + F_zone * [high[2] < Equilibrium] + F_bos * [RealBullBOS OR (bars since the most recent PivotHigh(high, P_ms, 1) bar < P_bn AND StructureTrend = 1)], where [x] = 1 if x holds, else 0
Calculation: BearFVGScore = F_base + F_big * [low[2] - high > P_gap_hi * ATR(P_atr)] + F_small * [low[2] - high > P_gap_lo * ATR(P_atr) AND low[2] - high <= P_gap_hi * ATR(P_atr)] + F_vol * [volume[1] > P_fvg_vol * SMA(volume, P_vol_ma)] + F_zone * [low[2] > Equilibrium] + F_bos * [RealBearBOS OR (bars since the most recent PivotLow(low, P_ms, 1) bar < P_bn AND StructureTrend = -1)], where [x] = 1 if x holds, else 0
Calculation: StoredFVGs = list of held FVGs, where a bull FVG (low > high[2] AND BullFVGScore >= P_fvg_min) is held with top = low and bottom = high[2], and a bear FVG (high < low[2] AND BearFVGScore >= P_fvg_min) is held with top = low[2] and bottom = high; a bull FVG is removed when low <= bottom, a bear FVG is removed when high >= top, any FVG is removed when more than P_age bars old, and when more than P_fvg_max are held the oldest is removed
Calculation: BullScore = W_div * [BullDivRun >= P_conf AND volume > SMA(volume, P_vol_ma)] + W_bos * [RealBullBOS] + W_choch * [CHoCHBull] + W_abs * [AbsorptionBull] + W_sweep * [BullSweep AND volume > P_sw_vol * SMA(volume, P_vol_ma)] + W_fvg * [for some bull FVG in StoredFVGs, abs(close - (its top + its bottom) / 2) < P_near * ATR(P_atr)] + W_zone * [close < Equilibrium] + W_clx * [ClimaxBottom] + W_delta * [DeltaEMA > 0], where [x] = 1 if x holds, else 0
Calculation: BearScore = W_div * [BearDivRun >= P_conf AND volume > SMA(volume, P_vol_ma)] + W_bos * [RealBearBOS] + W_choch * [CHoCHBear] + W_abs * [AbsorptionBear] + W_sweep * [BearSweep AND volume > P_sw_vol * SMA(volume, P_vol_ma)] + W_fvg * [for some bear FVG in StoredFVGs, abs(close - (its top + its bottom) / 2) < P_near * ATR(P_atr)] + W_zone * [close > Equilibrium] + W_clx * [ClimaxTop] + W_delta * [DeltaEMA < 0], where [x] = 1 if x holds, else 0
Calculation: BullLabel = BullScore >= P_cf AND bars since last true BullLabel > P_cd
Calculation: BearLabel = BearScore >= P_cf AND bars since last true BearLabel > P_cd
Long: RealBullBOS
Long: CHoCHBull
Long: BullDivRun >= P_conf AND volume > SMA(volume, P_vol_ma)
Long: BullDivRun = P_conf AND volume > SMA(volume, P_vol_ma)
Long: AbsorptionBull
Long: ClimaxBottom
Long: ClimaxTop
Long: BullSweep
Long: low > high[2] AND BullFVGScore >= P_fvg_min
Long: BullLabel
Long: BullScore >= P_al AND bars since last true BullLabel > P_cd
Long: BullScore >= P_strong AND BullScore >= P_al AND bars since last true BullLabel > P_cd
Short: RealBearBOS
Short: CHoCHBear
Short: BearDivRun >= P_conf AND volume > SMA(volume, P_vol_ma)
Short: BearDivRun = P_conf AND volume > SMA(volume, P_vol_ma)
Short: AbsorptionBear
Short: ClimaxTop
Short: ClimaxBottom
Short: BearSweep
Short: high < low[2] AND BearFVGScore >= P_fvg_min
Short: BearLabel
Short: BearScore >= P_al AND bars since last true BearLabel > P_cd
Short: BearScore >= P_strong AND BearScore >= P_al AND bars since last true BearLabel > P_cd