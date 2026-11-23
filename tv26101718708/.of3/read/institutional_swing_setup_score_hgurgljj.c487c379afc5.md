Calculation: MaStack = close > SMA(close, shorter MA length) AND SMA(close, shorter MA length) > SMA(close, middle MA length) AND SMA(close, middle MA length) > SMA(close, longer MA length)
Calculation: TrendPoints = trend MA-stack points * [MaStack] + trend slope points * [SMA(close, longer MA length) > SMA(close, longer MA length)[slope lookback]] + trend above-slow points * [close > SMA(close, longer MA length)] + trend far-from-low points * [close > lowest(low, long-range lookback) * far-from-low factor] + trend near-high points * [close > highest(high, long-range lookback) * near-high factor]
Calculation: RelLine = close / benchmark close
Calculation: RelLineRising = RelLine > SMA(RelLine, RS smoothing length)
Calculation: RelStrengthGap = (close / close[RS performance lookback] - 1) - (benchmark close / benchmark close[RS performance lookback] - 1)
Calculation: RelPoints = RS rising points * [RelLineRising] + RS new-high points * [RelLine >= highest(RelLine, RS high lookback) * RS new-high tolerance] + relperf points * clamp(RelStrengthGap * relative performance scale, 0, 1)
Calculation: RangeHigh = highest(high, base lookback)
Calculation: RangeWidthPct = (RangeHigh - lowest(low, base lookback)) / RangeHigh * 100
Calculation: PullFromHighPct = (RangeHigh - close) / RangeHigh * 100
Calculation: TightLimit = tight range reference / tightness sensitivity
Calculation: HigherLowRun = on a bar where pivot low(low, pivot bars, pivot bars) is confirmed, HigherLowRun + 1 if that pivot low > the prior confirmed pivot low, else 0
Calculation: StructurePoints = tightness weight * clamp(100 - RangeWidthPct / TightLimit * 100, 0, 100) + compression weight * clamp(100 - PullFromHighPct / (TightLimit * compression fraction) * 100, 0, 100) + higher-low weight * min(HigherLowRun, higher-low cap) / higher-low cap * 100
Calculation: NormAtr = NATR(ATR length)
Calculation: BandWidthPct = BollingerBandWidthPct(close, BB length, BB multiplier)
Calculation: VolatilityPoints = ATR contraction points * [NormAtr < SMA(NormAtr, contraction lookback)] + band contraction points * [BandWidthPct < SMA(BandWidthPct, contraction lookback)] + percent-rank weight * (100 - PercentRank(NormAtr, percent-rank lookback))
Calculation: UpDownVolRatio = sum over i = 0 to up-down lookback - 1 of volume[i] * [close[i] > close[i+1]], divided by sum over the same i of volume[i] * [close[i] < close[i+1]]; if the denominator is 0, the ratio is infinity when the numerator is > 0, else 1
Calculation: AdLine = A/D line(high, low, close, volume)
Calculation: AccumulationUp = AdLine > SMA(AdLine, A/D smoothing length)
Calculation: ThrustWindow = [close[i] > close[i+1] AND volume[i] / SMA(volume, longer volume length)[i] >= volume multiplier] is true for some i = 0 to participation lookback - 1
Calculation: VolumePoints = dry-up points * [SMA(volume, shorter volume length) < SMA(volume, longer volume length) * dry-up factor] + strong-demand points * [UpDownVolRatio > strong-demand threshold] + accumulation points * [AccumulationUp] + pullback points * [close < close[1] AND volume < SMA(volume, longer volume length)] + thrust points * [ThrustWindow]
Calculation: ResistanceTouches = sum over i = 0 to resistance-test lookback - 1 of [high[i] >= RangeHigh * (1 - breakout proximity percent / 100) AND high[i] < RangeHigh]
Calculation: FreshBreakout = high >= RangeHigh * base new-high tolerance AND ThrustWindow AND MaStack AND RelLineRising
Calculation: BreakoutPoints = clamp(breakout trend weight * TrendPoints + breakout RS weight * RelPoints + breakout volume weight * VolumePoints + breakout structure weight * StructurePoints + breakout volatility weight * VolatilityPoints + breakout near-high points * [PullFromHighPct < breakout proximity percent] + breakout tight-tested points * [RangeWidthPct < tight range reference AND ResistanceTouches >= min resistance tests] + confirm bonus * [FreshBreakout], 0, 100)
Calculation: SetupScore = (setup trend weight * TrendPoints + setup RS weight * RelPoints + setup structure weight * StructurePoints + setup volatility weight * VolatilityPoints + setup volume weight * VolumePoints + setup breakout weight * BreakoutPoints) / (setup trend weight + setup RS weight + setup structure weight + setup volatility weight + setup volume weight + setup breakout weight)
Long: SetupScore crosses above test entry threshold
Exit: long, SetupScore crosses below test exit threshold
Long: FreshBreakout AND NOT FreshBreakout[1]
Long: SetupScore crosses above alert score threshold
Long: SetupScore >= alert score threshold
Long: SetupScore - SetupScore[improvement lookback] > improvement threshold
Long: AccumulationUp AND NOT AccumulationUp[1]
Long: VolumePoints crosses above exceptional volume threshold
Long: BreakoutPoints crosses above high-confidence breakout threshold