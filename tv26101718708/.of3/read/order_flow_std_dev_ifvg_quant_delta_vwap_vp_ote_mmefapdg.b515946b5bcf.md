Calculation: Delta = sum of lower-timeframe T1 volume on intrabars with close >= open minus volume on intrabars with close < open, per chart bar; if no intrabars exist, classify chart-bar volume by close >= open.
Calculation: Session CVD = cumulative Delta since the session reset; rising means current CVD > CVD at the CVD-lag parameter, falling means current CVD < CVD at that lag.
Calculation: Volume z-score = (volume - SMA(volume, z-score lookback)) / STDEV(volume, z-score lookback).
Calculation: Rolling value mean = SUM(hlc3 * volume, profile lookback) / SUM(volume, profile lookback).
Calculation: Absorption = volume >= SMA(volume, volume-average lookback) * volume multiplier AND high - low <= ATR(ATR lookback) * range multiplier AND (Delta < 0 AND close >= (high + low) / 2 for bullish absorption, or Delta > 0 AND close <= (high + low) / 2 for bearish absorption).
Calculation: Smoothed aggressive-buy share = 100 * SMA(buy volume, pressure lookback) / (SMA(buy volume, pressure lookback) + SMA(sell volume, pressure lookback)); use 50 when the denominator is zero.
Calculation: Session VWAP deviation = (close - session VWAP) / the session volume-weighted standard deviation of hlc3 from session VWAP.
Calculation: Volume Profile POC = midpoint of the price row with greatest volume, distributing each bar's volume across rows in proportion to each row's overlap with that bar's range over the profile lookback.
Calculation: Bull score = count of Delta > 0, rising Session CVD, close > session VWAP, close > rolling value mean, volume z-score > its threshold, and buy-volume share >= imbalance threshold OR bullish absorption.
Calculation: Bear score = count of Delta < 0, falling Session CVD, close < session VWAP, close <= rolling value mean, volume z-score > its threshold, and sell-volume share >= imbalance threshold OR bearish absorption.
Calculation: Chart OTE zone = use the latest two confirmed pivot highs and lows with the chart swing lookback; bias turns bearish when the latest high is lower than the prior high, otherwise turns bullish when the latest low is higher than the prior low, otherwise retains its prior bias. Require latest high > latest low and, when swing order is required, the latest low pivot precedes the latest high pivot for bullish bias or the latest high pivot precedes the latest low pivot for bearish bias. With leg = latest high - latest low, bullish bounds are latest high - leg * near retracement through latest high - leg * far retracement; bearish bounds are latest low + leg * near retracement through latest low + leg * far retracement, where near and far are the lesser and greater retracement parameters.
Calculation: T2/T3 OTE zones = apply the same pivot-bias and retracement calculation on T2 and T3 bars, using the separate HTF swing lookback and without the swing-order filter; chart bars take values from the still-forming T2/T3 bars.
Calculation: FVG/IFVG zones = on confirmed chart bars, bullish FVG when low > high[n] and the gap is at least ATR(ATR lookback) * minimum-gap multiplier; bearish FVG when high < low[n] and the gap is at least that size. A bullish FVG flips bearish when close falls below its midpoint, or its bottom in full-fill mode; a bearish FVG flips bullish when close rises above its midpoint, or its top in full-fill mode. A flipped zone is invalidated by reclaiming the original zone or exceeding the expiry bars; it is large when its height >= ATR(ATR lookback) * minimum-zone multiplier.
Long: Delta >= 0.
Short: Delta < 0.
Long: Session CVD >= 0.
Short: Session CVD < 0.
Long: rising Session CVD.
Short: falling Session CVD.
Long: smoothed aggressive-buy share >= upper pressure threshold.
Short: smoothed aggressive-buy share <= lower pressure threshold.
Long: buy-volume share >= imbalance threshold AND volume > 0.
Short: sell-volume share >= imbalance threshold AND volume > 0.
Long: bullish absorption.
Short: bearish absorption.
Long: buy-volume share >= imbalance threshold on this and the previous chart bar.
Short: sell-volume share >= imbalance threshold on this and the previous chart bar.
Long: close > session VWAP AND absolute Session VWAP deviation < the outer-band multiplier.
Short: close <= session VWAP AND absolute Session VWAP deviation < the outer-band multiplier.
Long: a Volume Profile POC exists AND close > POC.
Short: a Volume Profile POC exists AND close <= POC.
Long: confirmed bullish FVG forms.
Short: confirmed bearish FVG forms.
Long: a valid bearish FVG flips bullish.
Short: a valid bullish FVG flips bearish.
Long: an active large bullish IFVG is retested with low <= its top AND close > its top.
Short: an active large bearish IFVG is retested with high >= its bottom AND close < its bottom.
Long: Chart OTE has a valid bullish zone.
Short: Chart OTE has a valid bearish zone.
Long: close is within the valid bullish Chart OTE zone.
Short: close is within the valid bearish Chart OTE zone.
Long: a valid bullish T2 or T3 OTE zone exists.
Short: a valid bearish T2 or T3 OTE zone exists.
Long: close is within a valid bullish T2 or T3 OTE zone.
Short: close is within a valid bearish T2 or T3 OTE zone.
Long: close enters the valid bullish Chart OTE zone from outside it.
Short: close enters the valid bearish Chart OTE zone from outside it.
Long: bull score >= minimum score AND bull score > bear score AND (location gate is disabled OR close is within a bullish Chart OTE zone OR a bullish IFVG retest occurs OR close is within a bullish T2 or T3 OTE zone) AND the chart bar closes AND more than the cooldown parameter bars have elapsed since the previous signal.
Short: bear score >= minimum score AND bear score > bull score AND (location gate is disabled OR close is within a bearish Chart OTE zone OR a bearish IFVG retest occurs OR close is within a bearish T2 or T3 OTE zone) AND the chart bar closes AND more than the cooldown parameter bars have elapsed since the previous signal.
Long: bull score >= bear score AND bull score >= minimum score AND (location gate is disabled OR close is within a bullish Chart OTE zone OR a bullish IFVG retest occurs OR close is within a bullish T2 or T3 OTE zone).
Short: bear score > bull score AND bear score >= minimum score AND (location gate is disabled OR close is within a bearish Chart OTE zone OR a bearish IFVG retest occurs OR close is within a bearish T2 or T3 OTE zone).