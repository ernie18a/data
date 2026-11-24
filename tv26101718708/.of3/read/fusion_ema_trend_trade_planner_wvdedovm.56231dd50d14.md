Calculation: Fast EMA = EMA(close, shortest of four separate EMA lookbacks)
Calculation: Second-fastest EMA = EMA(close, second-shortest EMA lookback)
Calculation: Second-slowest EMA = EMA(close, second-longest EMA lookback)
Calculation: Slowest EMA = EMA(close, longest EMA lookback)
Calculation: Bullish EMA alignment = each active EMA is greater than the next-slower active EMA
Calculation: Bearish EMA alignment = each active EMA is less than the next-slower active EMA
Calculation: Full bullish ribbon = Fast EMA > Second-fastest EMA > Second-slowest EMA > Slowest EMA
Calculation: Full bearish ribbon = Fast EMA < Second-fastest EMA < Second-slowest EMA < Slowest EMA
Calculation: Basis = EMA(hlc3, basis lookback), optionally double-smoothed as EMA(EMA(hlc3, basis lookback), basis lookback)
Calculation: Cloud reference = EMA(hlc3, separate cloud-reference lookback)
Calculation: Fusion EMA mean = arithmetic mean of the active EMAs
Calculation: Ribbon expansion = abs(Fast EMA - slowest active EMA)
Calculation: Long retest reference = configured Fusion EMA mean, Basis, max(Basis, Cloud reference), or highest active EMA
Calculation: Short retest reference = configured Fusion EMA mean, Basis, min(Basis, Cloud reference), or lowest active EMA
Calculation: Higher-timeframe bullish alignment = each active EMA, calculated from the current T1 bar (including its forming value in realtime, lookahead off) and sampled on chart bars, is greater than the next-slower active EMA
Calculation: Higher-timeframe bearish alignment = each active EMA, calculated from the current T1 bar (including its forming value in realtime, lookahead off) and sampled on chart bars, is less than the next-slower active EMA
Calculation: Stop distance = at entry, either ATR(ATR lookback) × ATR stop multiplier or entry price × stop percentage / 100, according to the configured stop method; hold fixed
Calculation: Long stop price = entry price - stop distance
Calculation: Short stop price = entry price + stop distance
Calculation: Planned risk = max(abs(entry price - position-side stop price), instrument minimum price increment), held fixed from entry
Calculation: Long final target = entry price + planned risk × final reward/risk parameter
Calculation: Short final target = entry price - planned risk × final reward/risk parameter
Long: Bullish EMA alignment
Short: Bearish EMA alignment
Long: Basis > Basis[1]
Short: Basis <= Basis[1]
Long: Higher-timeframe bullish alignment
Short: Higher-timeframe bearish alignment
Long: On a confirmed chart bar when close confirmation is required, bullish EMA alignment is true and was false on the prior chart bar
Short: On a confirmed chart bar when close confirmation is required, bearish EMA alignment is true and was false on the prior chart bar
Long: On a confirmed chart bar when close confirmation is required, higher-timeframe bullish alignment is true and was false on the prior chart-bar sample
Short: On a confirmed chart bar when close confirmation is required, higher-timeframe bearish alignment is true and was false on the prior chart-bar sample
Long: On a confirmed chart bar when required, fusion and trade-plan features are enabled, and historical plans are enabled or same-direction re-entry is enabled or no active long plan exists, and (quality filtering is disabled or (close > open AND close > Basis AND Ribbon expansion > ATR(ATR lookback) × minimum expansion parameter AND (higher-timeframe agreement filtering is disabled or Higher-timeframe bullish alignment) AND (ADX(DMI lookback, smoothing lookback) >= minimum ADX parameter when ADX filtering is enabled))), and ((flip trigger is selected AND Bullish EMA alignment is true and was false on the prior chart bar) OR (retest trigger is selected AND a later chart bar after a bullish alignment flip still has Bullish EMA alignment AND low <= Long retest reference + ATR(ATR lookback) × retest tolerance parameter AND close > Long retest reference AND close > open) OR (pullback trigger is selected AND Bullish EMA alignment AND no bullish alignment flip on the current bar AND low <= Long retest reference + ATR(ATR lookback) × retest tolerance parameter AND close > Long retest reference AND close > open))
Short: On a confirmed chart bar when required, fusion and trade-plan features are enabled, and historical plans are enabled or same-direction re-entry is enabled or no active short plan exists, and (quality filtering is disabled or (close < open AND close < Basis AND Ribbon expansion > ATR(ATR lookback) × minimum expansion parameter AND (higher-timeframe agreement filtering is disabled or Higher-timeframe bearish alignment) AND (ADX(DMI lookback, smoothing lookback) >= minimum ADX parameter when ADX filtering is enabled))), and ((flip trigger is selected AND Bearish EMA alignment is true and was false on the prior chart bar) OR (retest trigger is selected AND a later chart bar after a bearish alignment flip still has Bearish EMA alignment AND high >= Short retest reference - ATR(ATR lookback) × retest tolerance parameter AND close < Short retest reference AND close < open) OR (pullback trigger is selected AND Bearish EMA alignment AND no bearish alignment flip on the current bar AND high >= Short retest reference - ATR(ATR lookback) × retest tolerance parameter AND close < Short retest reference AND close < open))
Exit: long, when exit markers, fusion, and trade-plan features are enabled and the configured exit trigger is active-alignment loss and Bullish EMA alignment was true on the prior chart bar and is false now, or full-ribbon loss and Full bullish ribbon was true on the prior chart bar and is false now, or opposite-trend flip and Bearish EMA alignment is true now and was false on the prior chart bar
Exit: short, when exit markers, fusion, and trade-plan features are enabled and the configured exit trigger is active-alignment loss and Bearish EMA alignment was true on the prior chart bar and is false now, or full-ribbon loss and Full bearish ribbon was true on the prior chart bar and is false now, or opposite-trend flip and Bullish EMA alignment is true now and was false on the prior chart bar
Exit: long, low <= Long stop price OR high >= Long final target
Exit: short, high >= Short stop price OR low <= Short final target