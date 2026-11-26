Calculation: relative volume = volume / SMA(volume, volume lookback)
Calculation: OBV slope = EMA(OBV(close, volume), OBV smoothing lookback) minus its value at the OBV slope lookback
Calculation: regression line = LinReg(log(close), regression lookback, zero offset)
Calculation: regression deviation = StDev(log(close) - regression line, regression lookback)
Calculation: regression slope = regression line minus its value at the regression slope lookback
Calculation: regression upper and lower bands = exp(regression line plus or minus regression deviation times regression band multiplier)
Calculation: weekly bullish regime = chart-bar close(T1, bar still forming) > EMA(close, short lookback, T1, bar still forming) AND that EMA > EMA(close, long lookback, T1, bar still forming)
Calculation: weekly bearish regime = chart-bar close(T1, bar still forming) < EMA(close, short lookback, T1, bar still forming) AND that EMA < EMA(close, long lookback, T1, bar still forming)
Calculation: internal bullish structure = the latest confirmed internal pivot high and low are each above their respective previous values; internal bearish structure = each is below its previous value; use the internal pivot lookback for both pivot sides
Calculation: external bullish structure = the latest confirmed external pivot high and low are each above their respective previous values; external bearish structure = each is below its previous value; use the external pivot lookback for both pivot sides
Calculation: bullish BOS = on a confirmed chart bar, close crosses above the latest internal pivot high AND relative volume >= BOS relative-volume threshold; bearish BOS = close crosses below the latest internal pivot low AND relative volume >= threshold
Calculation: external bullish BOS and external bearish BOS = the corresponding bullish or bearish BOS condition using the latest external pivot high or low
Calculation: structure trend = bullish after a bullish internal or external BOS or bullish CHoCH; bearish after a bearish internal or external BOS or bearish CHoCH; otherwise retain the previous trend, initially neutral
Calculation: bullish CHoCH = (bullish BOS OR external bullish BOS) AND (prior structure trend is bearish OR internal bearish structure OR external bearish structure) AND regression slope is positive; bearish CHoCH = (bearish BOS OR external bearish BOS) AND (prior structure trend is bullish OR internal bullish structure OR external bullish structure) AND regression slope is negative
Calculation: failed bullish BOS = after a bullish internal or external BOS, within the failed BOS lookback and after its break bar, close is below the broken level; failed bearish BOS = after a bearish internal or external BOS, within that lookback and after its break bar, close is above the broken level
Calculation: bullish structure display = the first applicable structure label in this order is bullish: bullish CHoCH, bearish CHoCH, external bullish BOS, external bearish BOS, bullish BOS, bearish BOS, failed bearish BOS, failed bullish BOS, external bullish structure, external bearish structure, internal bullish structure, internal bearish structure, bullish structure trend, bearish structure trend; bearish structure display = the first applicable label is bearish
Calculation: OBV trend = OBV slope is positive or negative
Calculation: regression trend = regression slope is positive or negative
Calculation: pattern features per bar = log(close / prior close) divided by ATR/close; (high - low)/ATR; (close - open)/ATR; (upper wick - lower wick)/ATR; log(relative volume) times candle direction when volume feature is enabled, otherwise zero; and (close - EMA(close, trend feature lookback))/ATR when trend feature is enabled, otherwise zero
Calculation: pattern distance = square root of the mean across the pattern lookback of the sum of squared differences between corresponding pattern features, weighted by each feature weight divided by the sum of feature weights
Calculation: kNN forecast return, high, low and confidence = use the nearest historical patterns by pattern distance; average their forward return, high and low with the selected neighbor weights, and set confidence to the larger positive or nonpositive outcome count divided by the neighbor count
Calculation: smoothed forecast return, high and low = EMA of the corresponding kNN output using the prediction smoothing lookback
Calculation: projected mid, high and low = close * exp(the corresponding smoothed forecast output)
Calculation: kNN magnitude score = clamp(abs(smoothed forecast return / max((ATR/close) * sqrt(forecast horizon), epsilon)) * magnitude multiplier, zero, magnitude cap); confidence adjustment = (kNN confidence - neutral confidence) * confidence multiplier
Calculation: bullish kNN score = clamp(if smoothed forecast return is nonnegative, baseline + kNN magnitude score + confidence adjustment, otherwise baseline - kNN magnitude score - confidence adjustment); bearish kNN score = clamp(if return is negative, baseline + magnitude score + confidence adjustment, otherwise baseline - magnitude score - confidence adjustment); use the score bounds
Calculation: regression position = (log(close) - regression line) / regression deviation when deviation is positive, otherwise neutral; bullish regression score = clamp(baseline + normalized regression slope * slope weight - max(regression position, positive zero) * extension penalty, score bounds); bearish regression score = clamp(baseline - normalized regression slope * slope weight + min(regression position, negative zero) * extension penalty, score bounds)
Calculation: side structure score = clamp(base score selected by whether structure trend matches the side, plus bonuses for matching internal structure, external structure, internal BOS, external BOS, CHoCH and failed opposite-side BOS, score bounds)
Calculation: side volume score = clamp(base score selected by whether relative volume meets the high or normal threshold, plus bonuses for a matching candle direction, matching close direction with rising volume, matching OBV slope, and volume above its average, score bounds)
Calculation: bullish and bearish weekly adjustments = the weekly regime adjustment for a matching regime, opposing regime, or neutral regime, or zero when the weekly filter is disabled
Calculation: bull score = clamp(bullish kNN score * kNN weight + bullish regression score * regression weight + bullish structure score * structure weight + bullish volume score * volume weight + bullish weekly adjustment, score bounds); bear score = the corresponding weighted bearish scores and bearish weekly adjustment
Calculation: forecast side = bullish when bull score >= bear score, otherwise bearish
Calculation: bullish invalidation = latest internal pivot low - ATR * invalidation buffer, or latest external pivot low - ATR * buffer if no internal pivot low exists, or regression lower band if neither exists; bearish invalidation = latest internal pivot high + ATR * buffer, or latest external pivot high + ATR * buffer if no internal pivot high exists, or regression upper band if neither exists
Calculation: swing range = absolute difference between latest external pivot high and low when both exist, otherwise between latest internal pivot high and low when both exist, otherwise ATR * swing range fallback multiplier
Calculation: side target candidates = for bullish forecast, projected mid, projected high, regression upper band, nearest swing high above close, ATR expansion above close, measured move above close and Fibonacci extension above close; for bearish forecast use projected mid, projected low, regression lower band, nearest swing low below close, ATR expansion below close, measured move below close and Fibonacci extension below close
Calculation: target candidate score = clamp(side score * side score weight + kNN confidence * confidence weight + side volume score * volume weight + side regression score * regression weight + side structure score * structure weight + clamp(distance base - abs(candidate price - close)/ATR * distance penalty, distance score bounds) + source-specific bonus + weekly alignment adjustment, target score bounds); merge candidates within the ATR merge distance, retaining the higher-scored candidate, then rank by score
Calculation: ranked target one = highest-scored eligible side target candidate after merging
Long: bullish BOS OR external bullish BOS OR bullish CHoCH OR failed bearish BOS
Short: bearish BOS OR external bearish BOS OR bearish CHoCH OR failed bullish BOS
Long: bullish structure display
Short: bearish structure display
Long: OBV slope is positive
Short: OBV slope is negative
Long: regression slope is positive
Short: regression slope is negative
Long: weekly bullish regime
Short: weekly bearish regime
Long: bull score - bear score >= minimum directional edge
Short: bear score - bull score >= minimum directional edge
Long: on a confirmed chart bar, forecast side is bullish AND bull score >= high-probability threshold AND its prior-bar value was below that threshold
Short: on a confirmed chart bar, forecast side is bearish AND bear score >= high-probability threshold AND its prior-bar value was below that threshold
Exit: long, on a confirmed chart bar AND forecast side is bullish AND (high >= ranked target one OR close < bullish invalidation)
Exit: short, on a confirmed chart bar AND forecast side is bearish AND (low <= ranked target one OR close > bearish invalidation)