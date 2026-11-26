Calculation: IB high = highest(high) during the current Initial Balance window
Calculation: IB low = lowest(low) during the current Initial Balance window
Calculation: IB range = max(IB high - IB low, minimum tick size)
Calculation: IB midpoint = (IB high + IB low) / 2
Calculation: Safe ATR = max(ATR(ATR lookback) if available, otherwise True Range, minimum tick size)
Calculation: Break buffer = Safe ATR * break-buffer parameter
Calculation: Retest buffer = Safe ATR * retest-buffer parameter
Calculation: Failure buffer = Safe ATR * failure-buffer parameter
Calculation: High-good score(value, weak threshold, strong threshold) = 0 if value is unavailable or thresholds are equal; otherwise clamp((value - weak threshold) / (strong threshold - weak threshold) * 100, 0, 100)
Calculation: Peak score(value, low threshold, ideal threshold, high threshold) = clamp((value - low threshold) / (ideal threshold - low threshold) * 100, 0, 100) when value <= ideal threshold; otherwise clamp((high threshold - value) / (high threshold - ideal threshold) * 100, 0, 100)
Calculation: IB-width score = Peak score(IB range / Safe ATR, low IB-width threshold, sensitivity-selected ideal IB-width parameter, sensitivity-selected high IB-width parameter)
Calculation: Volume score = High-good score(volume / SMA(volume, relative-volume lookback), weak relative-volume threshold, strong relative-volume threshold), using 1 when volume or its average is unavailable or the average is not positive
Calculation: Volatility fit = Peak score(Safe ATR / SMA(ATR(ATR lookback), max(ATR lookback * ATR-baseline multiplier, acceptance lookback)), low volatility-ratio threshold, ideal volatility-ratio threshold, high volatility-ratio threshold), using a ratio of 1 when the average is unavailable or not positive
Calculation: Close location = clamp((close - low) / max(high - low, minimum tick size), 0, 1)
Calculation: Break edge = IB high for an upward first break and IB low for a downward first break
Calculation: Break close quality = clamp(break-distance weight * High-good score(first-break close's distance beyond the IB edge, Break buffer, Safe ATR * break-quality distance parameter) + close-location weight * directional close location * 100, 0, 100), using the first-break bar's values; directional close location is Close location for an upward break and 1 - Close location for a downward break
Calculation: Bars since break = number of chart bars since the first IB break
Calculation: Outside accepted = close > Break edge for an upward break or close < Break edge for a downward break
Calculation: Back inside = close < Break edge - Failure buffer for an upward break or close > Break edge + Failure buffer for a downward break
Calculation: Deep failure = close < IB midpoint for an upward break or close > IB midpoint for a downward break
Calculation: Retest touch = Bars since break > 0 and ((upward break and low <= Break edge + Retest buffer and close >= Break edge - Failure buffer) or (downward break and high >= Break edge - Retest buffer and close <= Break edge + Failure buffer))
Calculation: Retest score = held-retest score if a retest has already held; otherwise back-inside score if Back inside; otherwise outside score if Outside accepted; otherwise neutral score
Calculation: Acceptance score = clamp(IB-width weight * IB-width score + break-quality weight * Break close quality + retest weight * Retest score + volume weight * Volume score + volatility-fit weight * Volatility fit, 0, 100)
Calculation: Failure risk = clamp(inside penalty when Back inside + deep-failure penalty when Deep failure + time penalty when Bars since break > acceptance lookback + close-weakness weight * (100 - directional close location * 100) + participation-weakness weight * (100 - Volume score) + width-weakness weight * (100 - IB-width score), 0, 100)
Long: after the Initial Balance window completes, during the tracking session, on an intraday chart timeframe no greater than T1, with no prior break in the session, close > IB high + Break buffer on a confirmed bar unless live updating is selected
Short: after the Initial Balance window completes, during the tracking session, on an intraday chart timeframe no greater than T1, with no prior break in the session, close < IB low - Break buffer on a confirmed bar unless live updating is selected
Long: the first break was upward, Retest touch, no retest has already held, not Back inside, and the bar is confirmed unless live updating is selected
Short: the first break was downward, Retest touch, no retest has already held, not Back inside, and the bar is confirmed unless live updating is selected
Long: the first break was upward, not previously accepted or failed, Outside accepted, Acceptance score >= minimum acceptance score, Failure risk <= acceptance risk limit, Bars since break >= acceptance confirmation bars, and the bar is confirmed unless live updating is selected
Short: the first break was downward, not previously accepted or failed, Outside accepted, Acceptance score >= minimum acceptance score, Failure risk <= acceptance risk limit, Bars since break >= acceptance confirmation bars, and the bar is confirmed unless live updating is selected
Exit: long, the first break was upward, not previously failed, the bar is confirmed unless live updating is selected, and (Deep failure or (Back inside and Failure risk >= failure risk threshold))
Exit: short, the first break was downward, not previously failed, the bar is confirmed unless live updating is selected, and (Deep failure or (Back inside and Failure risk >= failure risk threshold))