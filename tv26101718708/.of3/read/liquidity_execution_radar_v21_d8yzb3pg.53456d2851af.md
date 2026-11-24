Calculation: Bar range = high - low.
Calculation: Body fraction = abs(close - open) / bar range when bar range > 0, otherwise the zero-range body-fraction parameter.
Calculation: Upper-wick fraction = (high - max(open, close)) / bar range when bar range > 0, otherwise the zero-range wick-fraction parameter.
Calculation: Lower-wick fraction = (min(open, close) - low) / bar range when bar range > 0, otherwise the zero-range wick-fraction parameter.
Calculation: Bullish close location = (close - low) / bar range when bar range > 0, otherwise the zero-range close-location parameter.
Calculation: Bearish close location = (high - close) / bar range when bar range > 0, otherwise the zero-range close-location parameter.
Calculation: Relative volume = volume / SMA(volume, volume-average lookback) when the average is positive, otherwise the zero-average relative-volume parameter.
Calculation: Strong volume = relative volume >= strong-volume multiplier.
Calculation: Dead volume = relative volume < dead-volume multiplier.
Calculation: High-volume small-range bar = volume > SMA(volume, volume-average lookback) * strong-volume multiplier AND bar range < SMA(bar range, range-average lookback) * small-result range multiplier.
Calculation: Bullish displacement = close > open AND bar range > ATR(ATR lookback) * displacement ATR multiplier AND body fraction > displacement body-fraction threshold AND bullish close location > displacement close-location threshold AND not dead volume.
Calculation: Bearish displacement = close < open AND bar range > ATR(ATR lookback) * displacement ATR multiplier AND body fraction > displacement body-fraction threshold AND bearish close location > displacement close-location threshold AND not dead volume.
Calculation: Bullish absorption = lower-wick fraction > wick threshold AND body fraction < absorption body-fraction threshold AND high-volume small-range bar AND close > low + bar range * absorption close-location threshold.
Calculation: Bearish absorption = upper-wick fraction > wick threshold AND body fraction < absorption body-fraction threshold AND high-volume small-range bar AND close < high - bar range * absorption close-location threshold.
Calculation: Compression = Highest(high, compression lookback) - Lowest(low, compression lookback) < SMA(bar range, compression lookback) * compression lookback * compression range multiplier.
Calculation: Previous T1 high = high of the last completed T1 bar, requested with lookahead on and carried onto chart bars.
Calculation: Previous T1 low = low of the last completed T1 bar, requested with lookahead on and carried onto chart bars.
Calculation: Previous T1 midpoint = (previous T1 high + previous T1 low) / 2.
Calculation: Current T1 open = open of the current, forming T1 bar, requested with lookahead on and carried onto chart bars.
Calculation: Average T1 range = SMA(high - low of the current, forming T1 bar, ADR lookback), calculated on chart bars from current T1 values requested with lookahead on.
Calculation: ADR upper level = current T1 open + average T1 range.
Calculation: ADR lower level = current T1 open - average T1 range.
Calculation: Near ADR upper level = close >= ADR upper level - ATR(ATR lookback) * ADR proximity multiplier.
Calculation: Near ADR lower level = close <= ADR lower level + ATR(ATR lookback) * ADR proximity multiplier.
Calculation: Kill zone = UTC chart-bar hour is within the configured opening-hour window for the London, New York, or Asian session; each window ends at its configured start hour plus the shared session duration.
Calculation: Locked Asian high and low = highest high and lowest low of chart bars in the configured Asian UTC opening window, frozen after that window ends until the T1 period changes.
Calculation: Liquidity tolerance = ATR(ATR lookback) * equal-level tolerance multiplier.
Calculation: Upper liquidity-cluster level = highest high among chart-bar offsets from one through the cluster lookback whose absolute distance from Highest(high, cluster lookback) is <= liquidity tolerance; it exists only when at least one offset qualifies.
Calculation: Upper liquidity-cluster hit count = number of chart-bar offsets from one through the cluster lookback whose high is within liquidity tolerance of Highest(high, cluster lookback).
Calculation: Lower liquidity-cluster level = lowest low among chart-bar offsets from one through the cluster lookback whose absolute distance from Lowest(low, cluster lookback) is <= liquidity tolerance; it exists only when at least one offset qualifies.
Calculation: Lower liquidity-cluster hit count = number of chart-bar offsets from one through the cluster lookback whose low is within liquidity tolerance of Lowest(low, cluster lookback).
Calculation: Liquidity above = upper liquidity-cluster hit count >= cluster hit-count threshold OR high one chart bar ago >= previous T1 high - liquidity tolerance OR a locked Asian high exists AND high one chart bar ago >= locked Asian high - liquidity tolerance.
Calculation: Liquidity below = lower liquidity-cluster hit count >= cluster hit-count threshold OR low one chart bar ago <= previous T1 low + liquidity tolerance OR a locked Asian low exists AND low one chart bar ago <= locked Asian low + liquidity tolerance.
Calculation: Sweep buffer = ATR(ATR lookback) * sweep ATR multiplier.
Calculation: High sweep = high > previous T1 high + sweep buffer AND close < previous T1 high, OR a locked Asian high exists AND high > locked Asian high + sweep buffer AND close < locked Asian high, OR liquidity above AND an upper liquidity-cluster level exists AND high > upper liquidity-cluster level + sweep buffer AND close < upper liquidity-cluster level.
Calculation: Low sweep = low < previous T1 low - sweep buffer AND close > previous T1 low, OR a locked Asian low exists AND low < locked Asian low - sweep buffer AND close > locked Asian low, OR liquidity below AND a lower liquidity-cluster level exists AND low < lower liquidity-cluster level - sweep buffer AND close > lower liquidity-cluster level.
Calculation: HTF bullish bias = close of the current, forming T2 bar > midpoint of its high and low AND close of the current, forming T2 bar > EMA(close, HTF EMA lookback, T2 current/forming bar); these T2 values are taken on chart bars.
Calculation: HTF bearish bias = close of the current, forming T2 bar < midpoint of its high and low AND close of the current, forming T2 bar < EMA(close, HTF EMA lookback, T2 current/forming bar); these T2 values are taken on chart bars.
Calculation: Trend-up T1 context = close > previous T1 high AND close > previous T1 midpoint.
Calculation: Trend-down T1 context = close < previous T1 low AND close < previous T1 midpoint.
Calculation: Near-term upward run = Rising(close, price-run lookback).
Calculation: Near-term downward run = Falling(close, price-run lookback).
Calculation: Bullish volume divergence = near-term upward run AND relative volume < relative volume one chart bar ago AND relative volume one chart bar ago < relative volume two chart bars ago.
Calculation: Bearish volume divergence = near-term downward run AND relative volume < relative volume one chart bar ago AND relative volume one chart bar ago < relative volume two chart bars ago.
Calculation: Bullish exhaustion score = clamp(round(SMA(bullish raw exhaustion points, exhaustion smoothing lookback)), exhaustion score floor, exhaustion score ceiling), where bullish raw exhaustion points are the sum of the run points when the near-term upward run is true, upper-wick points when upper-wick fraction > wick threshold, close-location points when close < high - bar range * exhaustion close-location threshold, divergence points when bullish volume divergence is true, and T1-break points when close > previous T1 high.
Calculation: Bearish exhaustion score = clamp(round(SMA(bearish raw exhaustion points, exhaustion smoothing lookback)), exhaustion score floor, exhaustion score ceiling), where bearish raw exhaustion points are the sum of the run points when the near-term downward run is true, lower-wick points when lower-wick fraction > wick threshold, close-location points when close > low + bar range * exhaustion close-location threshold, divergence points when bearish volume divergence is true, and T1-break points when close < previous T1 low.
Calculation: Latest confirmed swing high and low = most recent confirmed Pivot High(high, swing lookback left, swing lookback right) and Pivot Low(low, swing lookback left, swing lookback right) on chart bars; each level persists until another pivot of that side confirms.
Calculation: Bullish market-structure shift = a latest confirmed swing high exists AND close > latest confirmed swing high + ATR(ATR lookback) * market-structure ATR buffer AND bullish displacement.
Calculation: Bearish market-structure shift = a latest confirmed swing low exists AND close < latest confirmed swing low - ATR(ATR lookback) * market-structure ATR buffer AND bearish displacement.
Calculation: In discount = close < previous T1 midpoint.
Calculation: In premium = close > previous T1 midpoint.
Calculation: Good regime = kill zone AND not dead volume AND abs(close - previous T1 midpoint) >= ATR(ATR lookback) * mid-chop ATR threshold AND not (ADR filter enabled AND ((near ADR upper level AND HTF bullish bias) OR (near ADR lower level AND HTF bearish bias))).
Calculation: Bad regime = dead volume OR (ADR filter enabled AND ((near ADR upper level AND HTF bullish bias AND not high sweep) OR (near ADR lower level AND HTF bearish bias AND not low sweep))).
Calculation: Regime score = good-regime points when good regime is true, otherwise bad-regime points when bad regime is true, otherwise neutral-regime points.
Calculation: Bullish reclaim = long sweep-armed state AND bars since its sweep <= confirmation-bar limit AND close > previous T1 low AND close > open.
Calculation: Bearish reclaim = short sweep-armed state AND bars since its sweep <= confirmation-bar limit AND close < previous T1 high AND close < open.
Calculation: Long setup state = reset to idle when the T1 period changes; while idle, a low sweep arms a long setup and stores that bar's low, while a high sweep arms a short setup only if a low sweep did not arm on that bar. A long setup advances from sweep-armed to reclaimed on a bullish reclaim, then to confirmed when bullish displacement AND (bullish market-structure shift OR close > previous T1 midpoint) AND not dead volume. A short setup advances analogously on bearish reclaim, then bearish displacement AND (bearish market-structure shift OR close < previous T1 midpoint) AND not dead volume. Sweep-armed or reclaimed states reset to idle after the confirmation-bar limit expires, after checking that bar's reclaim and confirmation; confirmed states persist until the T1 period changes.
Calculation: Reward/risk(entry, stop, target) = abs(target - entry) / abs(entry - stop) when abs(entry - stop) > 0, otherwise the zero-risk reward/risk parameter.
Calculation: Bullish target levels = previous T1 midpoint; locked Asian high if it exists otherwise previous T1 high; and the lesser of (upper liquidity-cluster level if it exists otherwise previous T1 high) and ADR upper level.
Calculation: Bearish target levels = previous T1 midpoint; locked Asian low if it exists otherwise previous T1 low; and the greater of (lower liquidity-cluster level if it exists otherwise previous T1 low) and ADR lower level.
Calculation: Bullish best reward/risk = maximum Reward/risk(close, stored long-sweep low, each bullish target level).
Calculation: Bearish best reward/risk = maximum Reward/risk(close, stored short-sweep high, each bearish target level).
Calculation: Bullish reward/risk points = top reward/risk points when bullish best reward/risk >= top reward/risk threshold, otherwise middle reward/risk points when it >= middle reward/risk threshold, otherwise lower reward/risk points when it >= lower reward/risk threshold, otherwise zero points.
Calculation: Bearish reward/risk points = top reward/risk points when bearish best reward/risk >= top reward/risk threshold, otherwise middle reward/risk points when it >= middle reward/risk threshold, otherwise lower reward/risk points when it >= lower reward/risk threshold, otherwise zero points.
Calculation: Bullish reversal score = reversal low-sweep points when low sweep is true + reversal reclaim points when bullish reclaim is true + reversal displacement points when bullish displacement is true + reversal shift points when bullish market-structure shift is true + reversal exhaustion points when bearish exhaustion score > exhaustion-score threshold + reversal discount points when in discount + reversal regime points when good regime + reversal liquidity points when liquidity above.
Calculation: Bearish reversal score = reversal high-sweep points when high sweep is true + reversal reclaim points when bearish reclaim is true + reversal displacement points when bearish displacement is true + reversal shift points when bearish market-structure shift is true + reversal exhaustion points when bullish exhaustion score > exhaustion-score threshold + reversal premium points when in premium + reversal regime points when good regime + reversal liquidity points when liquidity below.
Calculation: Bullish continuation score = continuation HTF points when HTF bullish bias + continuation midpoint points when close > previous T1 midpoint + continuation displacement points when bullish displacement + continuation volume points when strong volume + continuation no-opposing-sweep points when not high sweep + continuation trend points when trend-up T1 context + continuation ADR points when not near ADR upper level + continuation compression points when compression.
Calculation: Bearish continuation score = continuation HTF points when HTF bearish bias + continuation midpoint points when close < previous T1 midpoint + continuation displacement points when bearish displacement + continuation volume points when strong volume + continuation no-opposing-sweep points when not low sweep + continuation trend points when trend-down T1 context + continuation ADR points when not near ADR lower level + continuation compression points when compression.
Calculation: Bullish final score = the greater of bullish reversal score and bullish continuation score + bullish reward/risk points + int(regime score * regime-score contribution factor), capped at the weak-regime score ceiling when bad regime is true.
Calculation: Bearish final score = the greater of bearish reversal score and bearish continuation score + bearish reward/risk points + int(regime score * regime-score contribution factor), capped at the weak-regime score ceiling when bad regime is true.
Calculation: Bullish grade = A+ when bullish final score >= A+ score threshold AND bullish best reward/risk >= minimum A reward/risk; otherwise A when bullish final score >= A score threshold AND bullish best reward/risk >= minimum A reward/risk; otherwise B when bullish final score >= B score threshold AND bullish best reward/risk >= minimum B reward/risk; otherwise C when bullish final score >= C score threshold; otherwise No Trade.
Calculation: Bearish grade = A+ when bearish final score >= A+ score threshold AND bearish best reward/risk >= minimum A reward/risk; otherwise A when bearish final score >= A score threshold AND bearish best reward/risk >= minimum A reward/risk; otherwise B when bearish final score >= B score threshold AND bearish best reward/risk >= minimum B reward/risk; otherwise C when bearish final score >= C score threshold; otherwise No Trade.
Calculation: Bullish entry = long setup state is confirmed AND bullish final score >= entry score threshold AND (A-only filter is disabled OR bullish grade is A+ or A).
Calculation: Bearish entry = short setup state is confirmed AND bearish final score >= entry score threshold AND (A-only filter is disabled OR bearish grade is A+ or A).
Calculation: Bullish context = neither entry is true AND bullish final score > bearish final score + context margin.
Calculation: Bearish context = neither entry is true AND bearish final score > bullish final score + context margin.
Long: low sweep.
Short: high sweep.
Long: long setup state is sweep-armed or reclaimed.
Short: short setup state is sweep-armed or reclaimed.
Long: bullish market-structure shift.
Short: bearish market-structure shift.
Long: bullish absorption.
Short: bearish absorption.
Long: bullish displacement AND strong volume.
Short: bearish displacement AND strong volume.
Long: HTF bullish bias.
Short: HTF bearish bias.
Long: trend-up T1 context.
Short: trend-down T1 context.
Long: in discount.
Short: in premium.
Long: bullish grade is A+, A, B, or C.
Short: bearish grade is A+, A, B, or C.
Long: bullish entry.
Short: bearish entry.
Long: bullish context.
Short: bearish context.
Long: low sweep AND kill zone AND strong volume.
Short: high sweep AND kill zone AND strong volume.
Long: bullish absorption AND bullish market-structure shift AND neither entry is true AND neither a low sweep nor a high sweep is outside the kill zone.
Short: bearish absorption AND bearish market-structure shift AND neither entry is true AND neither a low sweep nor a high sweep is outside the kill zone AND not (bullish absorption AND bullish market-structure shift).
Long: near ADR upper level AND bullish final score > bearish final score AND neither entry is true AND neither a low sweep nor a high sweep is outside the kill zone AND neither bullish nor bearish absorption is paired with its matching market-structure shift.
Short: near ADR lower level AND bearish final score > bullish final score AND neither entry is true AND neither a low sweep nor a high sweep is outside the kill zone AND neither bullish nor bearish absorption is paired with its matching market-structure shift AND not (near ADR upper level AND bullish final score > bearish final score).