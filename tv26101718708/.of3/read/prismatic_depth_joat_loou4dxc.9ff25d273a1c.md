Calculation: Bull structure score = structure weight when the latest confirmed pivot high exceeds the preceding confirmed pivot high OR the latest confirmed pivot low exceeds the preceding confirmed pivot low, AND close exceeds the latest confirmed pivot low; otherwise zero. Pivots use equal left and right confirmation lookbacks.
Calculation: Bear structure score = structure weight when the latest confirmed pivot high is below the preceding confirmed pivot high OR the latest confirmed pivot low is below the preceding confirmed pivot low, AND close is below the latest confirmed pivot high; otherwise zero. Pivots use equal left and right confirmation lookbacks.
Calculation: Bull volume score = volume weight when the linear regression slope of OBV over the OBV slope lookback is positive; otherwise zero.
Calculation: Bear volume score = volume weight when the linear regression slope of OBV over the OBV slope lookback is negative; otherwise zero.
Calculation: Bull momentum count = the count of these conditions that hold: close > KAMA(close, KAMA lookback), RSI(close, RSI lookback) > RSI midpoint, Williams %R(Williams %R lookback) > upper Williams %R threshold.
Calculation: Bear momentum count = the count of these conditions that hold: close < KAMA(close, KAMA lookback), RSI(close, RSI lookback) < RSI midpoint, Williams %R(Williams %R lookback) < lower Williams %R threshold.
Calculation: Bull momentum score = momentum weight × bull momentum count / number of momentum conditions.
Calculation: Bear momentum score = momentum weight × bear momentum count / number of momentum conditions.
Calculation: Bull liquidity score = liquidity weight when the current low is below the latest confirmed pivot low and close is above that pivot low; otherwise zero.
Calculation: Bear liquidity score = liquidity weight when the current high is above the latest confirmed pivot high and close is below that pivot high; otherwise zero.
Calculation: ATR ratio = ATR(ATR lookback) / max(SMA(ATR(ATR lookback), ATR baseline lookback), denominator floor).
Calculation: Bull volatility score = volatility weight when ATR ratio is strictly between the lower and upper ATR ratio thresholds and bull momentum count meets the minimum aligned momentum count; otherwise zero.
Calculation: Bear volatility score = volatility weight when ATR ratio is strictly between the lower and upper ATR ratio thresholds and bear momentum count meets the minimum aligned momentum count; otherwise zero.
Calculation: Session high and low = running highest high and lowest low since the date-boundary reset.
Calculation: Session position = (close - session midpoint) / session range × session position scale, where session midpoint is (session high + session low) / two and session range is session high - session low; use zero when session range is zero.
Calculation: Bull session score = when session position is below zero, the lesser of session weight and abs(session position) × session weight / full-score session distance; otherwise session weight × neutral session fraction.
Calculation: Bear session score = when session position is above zero, the lesser of session weight and abs(session position) × session weight / full-score session distance; otherwise session weight × neutral session fraction.
Calculation: HTF EMA = EMA(close, HTF EMA lookback, T1, latest non-lookahead value including the forming T1 bar in realtime), calculated on T1 bars and sampled on chart bars.
Calculation: Bull HTF score = HTF weight when the HTF score toggle is enabled and chart close exceeds HTF EMA; otherwise zero.
Calculation: Bear HTF score = HTF weight when the HTF score toggle is enabled and chart close is below HTF EMA; otherwise zero.
Calculation: Signed volume = volume when close >= open, otherwise negative volume.
Calculation: Cumulative signed volume = cumulative sum of signed volume, initialized at zero.
Calculation: Volume delta ratio = signed volume / volume when volume is positive; otherwise zero.
Calculation: Candle body fraction = min(abs(close - open) / (high - low), body fraction cap) when high > low; otherwise zero.
Calculation: Relative volume component = min(max(volume / EMA(volume, delta volume lookback) - one, zero) / volume expansion scale, volume component cap) when that EMA is positive; otherwise zero.
Calculation: Delta pressure score = (abs(volume delta ratio) × delta ratio coefficient + relative volume component × volume component coefficient + candle body fraction × body component coefficient) × pressure score scale.
Calculation: Bull delta score = delta weight when delta pressure score exceeds the pressure threshold and cumulative signed volume crosses above its SMA(cumulative signed volume, delta average lookback); otherwise zero.
Calculation: Bear delta score = delta weight when delta pressure score exceeds the pressure threshold and cumulative signed volume crosses below its SMA(cumulative signed volume, delta average lookback); otherwise zero.
Calculation: Bull score = bull structure score + bull volume score + bull momentum score + bull liquidity score + bull volatility score + bull session score + bull HTF score + bull delta score.
Calculation: Bear score = bear structure score + bear volume score + bear momentum score + bear liquidity score + bear volatility score + bear session score + bear HTF score + bear delta score.
Calculation: Initial stop distance = abs(close - Supertrend level) for Supertrend mode; min(abs(close - Supertrend level), ATR(ATR lookback) × ATR cap multiplier) for ATR cap mode; close × fixed stop percentage for fixed percentage mode; or abs(close - latest confirmed pivot low) for a long signal and abs(close - latest confirmed pivot high) for a short signal in pivot mode, using close minus ATR for a missing long pivot and close plus ATR for a missing short pivot.
Calculation: Long stop level = entry price - initial stop distance at entry.
Calculation: Short stop level = entry price + initial stop distance at entry.
Calculation: Long target level = entry price + initial stop distance at entry × target reward multiple.
Calculation: Short target level = entry price - initial stop distance at entry × target reward multiple.
Long: Bull score >= minimum score AND bull score - bear score >= minimum directional lead AND (VWMA gate is disabled OR close > VWMA(close, VWMA lookback)) AND (Supertrend gate is disabled OR Supertrend direction is bullish) AND (ribbon gate is disabled OR HMA(close, ribbon base length) > HMA(close, ribbon base length + ribbon step × longest-line multiplier)) AND (ADX gate is disabled OR ADX from DMI(DI lookback, ADX smoothing length) > minimum ADX) AND (session filter is disabled OR the chart bar time in UTC is within the configured session).
Short: Bear score >= minimum score AND bear score - bull score >= minimum directional lead AND (VWMA gate is disabled OR close < VWMA(close, VWMA lookback)) AND (Supertrend gate is disabled OR Supertrend direction is bearish) AND (ribbon gate is disabled OR HMA(close, ribbon base length) < HMA(close, ribbon base length + ribbon step × longest-line multiplier)) AND (ADX gate is disabled OR ADX from DMI(DI lookback, ADX smoothing length) > minimum ADX) AND (session filter is disabled OR the chart bar time in UTC is within the configured session).
Long: Bull score >= minimum score AND bull score - bear score >= minimum directional lead AND all enabled VWMA, Supertrend, ribbon, ADX, and session gates pass AND this long signal was false on the preceding chart bar AND chart bars since the preceding confirmed signal meet the cooldown AND the current bar is confirmed.
Short: Bear score >= minimum score AND bear score - bull score >= minimum directional lead AND all enabled VWMA, Supertrend, ribbon, ADX, and session gates pass AND this short signal was false on the preceding chart bar AND chart bars since the preceding confirmed signal meet the cooldown AND the current bar is confirmed.
Long: Bull score >= extreme score threshold.
Short: Bull score < extreme score threshold AND bear score >= extreme score threshold.
Long: HMA(close, ribbon base length) > HMA(close, ribbon base length + ribbon step × longest-line multiplier).
Short: HMA(close, ribbon base length) < HMA(close, ribbon base length + ribbon step × longest-line multiplier).
Long: Supertrend direction is bullish.
Short: Supertrend direction is bearish.
Long: Bull structure score > bear structure score.
Short: Bear structure score > bull structure score.
Long: Bull volume score > bear volume score.
Short: Bear volume score > bull volume score.
Long: Bull momentum score > bear momentum score.
Short: Bear momentum score > bull momentum score.
Long: Bull liquidity score > bear liquidity score.
Short: Bear liquidity score > bull liquidity score.
Long: Bull volatility score > bear volatility score.
Short: Bear volatility score > bull volatility score.
Long: Bull session score > bear session score.
Short: Bear session score > bull session score.
Long: Bull HTF score > bear HTF score.
Short: Bear HTF score > bull HTF score.
Long: Bull delta score > bear delta score.
Short: Bear delta score > bull delta score.
Long: Bull score >= bear score.
Short: Bear score > bull score.
Exit: long, high >= long target level OR low <= long stop level.
Exit: short, low <= short target level OR high >= short stop level.