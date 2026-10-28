Calculation: Previous-day high/low = high/low of the last completed daily bar.
Calculation: Opening-range high/low = highest high/lowest low during the configured opening-range session; use only after that session completes.
Calculation: Session VWAP = volume-weighted average of bar typical prices (high + low + close)/3, reset at each new day; session standard deviation = square root of volume-weighted typical-price variance.
Calculation: Flow score = sum of tiered points for volume/current average volume, bar range/ATR, absolute candle body/bar range, and absolute close-to-VWAP distance/session standard deviation.
Calculation: Confirmed swing high/low = a pivot high/low confirmed by bars on both sides; use the latest confirmed pivot of each kind.
Calculation: Projected resistance/support trendline = line through the latest two confirmed swing highs/lows, projected by the configured trendline length.
Calculation: Bullish/bearish FVG = current low above high two bars earlier / current high below low two bars earlier, with gap at least the configured minimum ATR multiple.
Calculation: Bullish/bearish IFVG event = close crosses below the bottom of an active bullish FVG / above the top of an active bearish FVG before expiry.
Calculation: Bullish/bearish order-block event = bullish/bearish structure break with a same-direction candle whose range meets the configured ATR displacement threshold; an opposite-direction candle must exist within the configured backward search.
Calculation: Active event = event occurred within its configured memory on the current or a prior bar.
Calculation: Bullish/bearish OR retest = after a close breaks above opening-range high / below opening-range low, within confirmation memory a later bar touches within configured tick tolerance and closes back above / below that level.
Calculation: Bullish/bearish confluence score = count of active sweep, trendline-break, structure-break, VWAP-side, strong-flow, FVG-or-IFVG-or-order-block, and OR-retest-or-OR-position conditions.
Long: opening range is ready AND ((high > previous-day low AND close > previous-day low) OR (low < previous-day low AND close > previous-day low))
Short: opening range is ready AND ((high > previous-day high AND close < previous-day high) OR (high > opening-range high AND close < opening-range high))
Long: close > open AND flow score meets the minimum bubble threshold AND (no prior bullish bubble OR bars since prior bullish bubble meet the configured cooldown)
Short: close < open AND flow score meets the minimum bubble threshold AND (no prior bearish bubble OR bars since prior bearish bubble meet the configured cooldown)
Long: close crosses above projected resistance trendline
Short: close crosses below projected support trendline
Long: close crosses above the latest confirmed swing high
Short: close crosses below the latest confirmed swing low
Long: bullish FVG forms
Short: bearish FVG forms
Long: close breaks above the top of an active bearish FVG
Short: close breaks below the bottom of an active bullish FVG
Long: bullish order-block event
Short: bearish order-block event
Long: bull score meets the configured minimum confirmations AND bull score > bear score
Short: bear score meets the configured minimum confirmations AND bear score > bull score