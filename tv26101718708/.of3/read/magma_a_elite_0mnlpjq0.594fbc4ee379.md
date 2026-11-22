Calculation: VolOK = ATR(ATR lookback) / close * 100 >= min ATR percent
Calculation: TrendOK = ADX(ADX lookback) >= min ADX
Calculation: CooldownOK = no earlier bar with an institutional, scalp, or A+ long or short marking, OR bars since the last such bar > cooldown bars
Calculation: BodySize = abs(close - open)
Calculation: RangeSize = high - low
Calculation: LowerShadow = min(open, close) - low
Calculation: UpperShadow = high - max(open, close)
Calculation: VolPeak = volume == highest(volume, volume lookback)
Calculation: InstVolSpike = volume > SMA(volume, volume lookback) * institutional volume multiplier
Calculation: ScalpVolSpike = volume > SMA(volume, volume lookback) * scalp volume multiplier
Calculation: BullAbsorption = VolPeak AND BodySize < RangeSize * absorption body fraction AND close > open AND close > EMA(close, shorter institutional EMA lookback)
Calculation: BullInstSetup = VolOK AND InstVolSpike AND close > EMA(close, shorter institutional EMA lookback) AND EMA(close, shorter institutional EMA lookback) > EMA(close, longer institutional EMA lookback) AND ((LowerShadow > BodySize * wick-to-body ratio AND low < low[1] AND close > low + RangeSize * sweep close fraction) OR BullAbsorption) AND ((close > open AND close > high[1]) OR close > high - RangeSize * reversal close fraction)
Calculation: BearInstSetup = VolOK AND InstVolSpike AND close < EMA(close, shorter institutional EMA lookback) AND EMA(close, shorter institutional EMA lookback) < EMA(close, longer institutional EMA lookback) AND ((UpperShadow > BodySize * wick-to-body ratio AND high > high[1] AND close < high - RangeSize * sweep close fraction) OR (VolPeak AND BodySize < RangeSize * absorption body fraction AND close < open AND close < EMA(close, shorter institutional EMA lookback))) AND ((close < open AND close < low[1]) OR close < low + RangeSize * reversal close fraction)
Calculation: AccumulationBar = volume > SMA(volume, volume lookback) * accumulation volume multiplier AND close > EMA(close, shorter institutional EMA lookback) AND EMA(close, shorter institutional EMA lookback) > EMA(close, longer institutional EMA lookback)
Calculation: DistributionBar = volume > SMA(volume, volume lookback) * accumulation volume multiplier AND close < EMA(close, shorter institutional EMA lookback) AND EMA(close, shorter institutional EMA lookback) < EMA(close, longer institutional EMA lookback)
Calculation: SetupScore = min(100, max(0, (trend weight if EMA(close, shorter institutional EMA lookback) > EMA(close, longer institutional EMA lookback)) + (score volume weight if volume > SMA(volume, volume lookback) * score volume multiplier) + (strong candle weight if BodySize > RangeSize * strong body fraction) + (momentum weight if RSI(close, RSI lookback) > momentum RSI level) + (above-fast weight if close > EMA(close, shorter institutional EMA lookback)) - (chop penalty if not TrendOK) - (chop penalty if not VolOK)))
Calculation: APlusSetup = BullInstSetup AND (BullAbsorption OR AccumulationBar) AND SetupScore >= min A+ score
Calculation: RangeAccumulation = (highest(high, smart accumulation lookback) - lowest(low, smart accumulation lookback)) / close * 100 <= smart max range percent AND abs(EMA(close, shorter institutional EMA lookback) - EMA(close, longer institutional EMA lookback)) / close * 100 <= smart max EMA spread percent
Calculation: ShortStopBreak = close > close[j] + ATR(ATR lookback)[j] * stop ATR multiplier AND close > open, where j = bars since the last BearInstSetup, and false before the first BearInstSetup
Calculation: PanelScore(T) = round(MTF EMA weight * PanelEmaValue + MTF RSI weight * RSI(close, MTF RSI lookback, T, last completed bar)), where PanelEmaValue = MTF EMA-up score if EMA(close, shorter MTF EMA lookback, T, last completed bar) > EMA(close, longer MTF EMA lookback, T, last completed bar), MTF EMA-down score if EMA(close, shorter MTF EMA lookback, T, last completed bar) < EMA(close, longer MTF EMA lookback, T, last completed bar), else MTF EMA-flat score
Long: BullInstSetup AND CooldownOK
Long: VolOK AND TrendOK AND EMA(close, shorter scalp EMA lookback) > EMA(close, longer scalp EMA lookback) AND low <= EMA(close, shorter scalp EMA lookback) AND close > EMA(close, shorter scalp EMA lookback) AND RSI(close, RSI lookback) > RSI midline AND ScalpVolSpike AND CooldownOK
Long: smart alert enabled AND APlusSetup AND (RangeAccumulation[k] for some k from 0 to smart window) AND ((EMA(close, shorter institutional EMA lookback) crosses above EMA(close, longer institutional EMA lookback))[k] for some k from 0 to smart window OR ShortStopBreak[k] for some k from 0 to smart window) AND CooldownOK
Long: NOT smart alert enabled AND APlusSetup AND CooldownOK
Long: AccumulationBar
Long: (LowerShadow > BodySize * trap wick-to-body ratio AND VolPeak AND close > open) AND NOT AccumulationBar AND NOT DistributionBar
Long: PanelScore(T1) >= MTF neutral level
Long: PanelScore(T2) >= MTF neutral level
Long: PanelScore(T3) >= MTF neutral level
Long: PanelScore(T4) >= MTF neutral level
Short: BearInstSetup AND CooldownOK
Short: VolOK AND TrendOK AND EMA(close, shorter scalp EMA lookback) < EMA(close, longer scalp EMA lookback) AND high >= EMA(close, shorter scalp EMA lookback) AND close < EMA(close, shorter scalp EMA lookback) AND RSI(close, RSI lookback) < RSI midline AND ScalpVolSpike AND CooldownOK
Short: DistributionBar
Short: (UpperShadow > BodySize * trap wick-to-body ratio AND VolPeak AND close < open) AND NOT AccumulationBar AND NOT DistributionBar
Short: PanelScore(T1) <= 100 - MTF neutral level AND PanelScore(T1) < MTF neutral level
Short: PanelScore(T2) <= 100 - MTF neutral level AND PanelScore(T2) < MTF neutral level
Short: PanelScore(T3) <= 100 - MTF neutral level AND PanelScore(T3) < MTF neutral level
Short: PanelScore(T4) <= 100 - MTF neutral level AND PanelScore(T4) < MTF neutral level