Calculation: Opening range high/low = highest high and lowest low during the configured opening-range interval, aggregated from completed lower-timeframe bars.
Calculation: Confirmed upward/downward opening-range break = close beyond the opening-range high/low with at least the configured fraction of the candle body beyond that level.
Calculation: Break score = one point each for breakout volume above 1.5 times its 20-bar average, at least half the candle body beyond the broken opening-range level, close beyond that level by 0.25 ATR, and close on the confirming side of VWAP; add the opening-range-close RMI point, daily RSI penalty, and developing-POC position point as defined by their bullish or bearish alignment.
Calculation: RMI = 14-period Wilder averages of positive and negative 3-bar close changes, converted to a 0–100 relative-strength value.
Calculation: Cumulative volume delta = cumulative volume × (2 × close − high − low) / (high − low); for zero-range bars, assign volume by the change in close.
Calculation: Higher low at a level = current low exceeds the prior bar's low, the prior bar's low is below the low two bars ago, and current close is within the configured ATR distance of an opening-range, VWAP, prior-day high/low, or prior-day VWAP level; the prior bar's low must also be within that distance of one of those levels.
Calculation: Lower high at a level = current high is below the prior bar's high, the prior bar's high exceeds the high two bars ago, and current close is within the configured ATR distance of an opening-range, VWAP, prior-day high/low, or prior-day VWAP level; the prior bar's high must also be within that distance of one of those levels.
Calculation: Bullish RMI divergence = price forms a lower low while RMI forms a higher low versus a prior RMI pivot, with the prior or current RMI pivot oversold; bearish RMI divergence = price forms a higher high while RMI forms a lower high versus a prior RMI pivot, with the prior or current RMI pivot overbought. Confirm when RMI slope flips in the matching direction.
Calculation: Bullish CVD divergence = a 5-bar price pivot low is below the low 5 bars earlier, cumulative delta exceeds its value at the earlier pivot, and close is in the candle's upper half; bearish CVD divergence is the inverse at a 5-bar pivot high, with close in the lower half.
Calculation: Opening-range retest buffer = the greater of 0.1 ATR and 3% of opening-range height.
Calculation: Failed-break trap = after an opening-range break, price returns inside the range within the configured bar window before reaching the first range-height target; the prior candle must be opposite-colored and its body at least the configured fraction of opening-range height. Also require the configured cooldown to have elapsed and the gap filter to pass.
Calculation: Nested compression = each of the two latest completed higher-timeframe bars is strictly inside the preceding bar's range and has a smaller body; bullish if all three bars close above open, bearish if all three close below open.
Long: Confirmed upward opening-range break AND break score >= 2
Long: Bullish opening-range retest: an upward break is active, stored break score >= 2, more than one bar has elapsed since the break, low is within the opening-range retest buffer of the high, and close is above the high (by the configured buffer when enabled)
Long: Failed downward opening-range break trap
Long: VWAP reclaim or reclaim retest: close confirms above VWAP after the prior two closes were below it; for reclaim, also meet the configured body-confirmation and reclaim-quality score, or for retest, a prior reclaim is active and price tests and closes above VWAP
Long: Bullish CVD divergence
Long: Bullish RMI divergence
Long: Higher low at a level
Long: Confirmed W pattern: two lows match within the configured ATR tolerance, are separated by the configured minimum and maximum bars, and the second low has at least one of: proximity to value-area low, lower VWAP band, opening-range low, prior-month low, developing POC, a prior-bar bottom sweep, or a higher RMI than at the first low
Long: Bullish POC retest: price crossed above developing POC after two closes below it, then retests within the configured proximity and closes above POC with at least half the candle body above it
Long: Bullish 15-minute or 30-minute nested compression, evaluated when that higher-timeframe bar completes
Long: Completed higher-timeframe dragonfly doji: body/range below the configured threshold, lower wick/range above 0.60, and upper wick/range below 0.15
Short: Confirmed downward opening-range break AND break score >= 2
Short: Bearish opening-range retest: a downward break is active, stored break score >= 2, more than one bar has elapsed since the break, high is within the opening-range retest buffer of the low, and close is below the low (by the configured buffer when enabled)
Short: Failed upward opening-range break trap
Short: VWAP rejection or rejection retest: close confirms below VWAP after the prior two closes were above it; for rejection, also meet the configured body-confirmation and rejection-quality score, or for retest, a prior rejection is active and price tests and closes below VWAP
Short: Bearish CVD divergence
Short: Bearish RMI divergence
Short: Lower high at a level
Short: Confirmed M pattern: two highs match within the configured ATR tolerance, are separated by the configured minimum and maximum bars, and the second high has at least one of: proximity to value-area high, upper VWAP band, opening-range high, prior-month high, developing POC, a prior-bar top sweep, or a lower RMI than at the first high
Short: Bearish POC retest: price crossed below developing POC after two closes above it, then retests within the configured proximity and closes below POC with at least half the candle body below it
Short: Bearish 15-minute or 30-minute nested compression, evaluated when that higher-timeframe bar completes
Short: Completed higher-timeframe gravestone doji: body/range below the configured threshold, upper wick/range above 0.60, and lower wick/range below 0.15