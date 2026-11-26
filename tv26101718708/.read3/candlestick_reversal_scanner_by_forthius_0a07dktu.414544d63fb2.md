Calculation: body = abs(close - open)
Calculation: range = high - low
Calculation: upper wick = high - max(open, close)
Calculation: lower wick = min(open, close) - low
Calculation: body fraction = if range > 0 then body / range else 0
Calculation: bullish candle = close > open
Calculation: bearish candle = close < open
Calculation: minimum body = close × minimum-body-percent parameter / 100%
Calculation: ATR = ATR(ATR-lookback parameter)
Calculation: RSI = RSI(close, RSI-lookback parameter)
Calculation: fast EMA = EMA(close, fast-lookback parameter)
Calculation: slow EMA = EMA(close, slow-lookback parameter)
Calculation: normalized EMA slope = (fast EMA - fast EMA value slope-interval bars ago) / (ATR × slope interval)
Calculation: downtrend = close < fast EMA AND fast EMA < slow EMA AND normalized EMA slope < negative slope-threshold parameter
Calculation: uptrend = close > fast EMA AND fast EMA > slow EMA AND normalized EMA slope > slope-threshold parameter
Calculation: ranging = NOT uptrend AND NOT downtrend
Calculation: downtrend context = downtrend OR (relaxed-trend parameter enabled AND ranging)
Calculation: uptrend context = uptrend OR (relaxed-trend parameter enabled AND ranging)
Calculation: wick tolerance = ATR × clean-wick-tolerance-percent parameter / 100%
Calculation: latest resistance = most recent confirmed pivot high of high using the pivot-lookback parameter on both sides
Calculation: latest support = most recent confirmed pivot low of low using the pivot-lookback parameter on both sides
Calculation: near resistance = latest resistance exists AND abs(high - latest resistance) <= ATR × support-resistance-tolerance parameter
Calculation: near support = latest support exists AND abs(low - latest support) <= ATR × support-resistance-tolerance parameter
Calculation: bullish divergence = low < lowest(low, divergence-lookback parameter)[1] AND RSI > lowest(RSI, divergence-lookback parameter)[1]
Calculation: bearish divergence = high > highest(high, divergence-lookback parameter)[1] AND RSI < highest(RSI, divergence-lookback parameter)[1]
Calculation: strong trend = ADX from DMI(DI-lookback parameter, ADX-smoothing parameter) > minimum-ADX parameter
Calculation: volume average = SMA(volume, volume-average-lookback parameter)
Calculation: volume qualifies = volume exists AND volume > volume average × volume-multiplier parameter
Calculation: bullish confirmation points = count of true conditions among volume qualifies, near support, RSI below bullish-RSI threshold parameter, strong trend, bullish divergence
Calculation: bearish confirmation points = count of true conditions among volume qualifies, near resistance, RSI above bearish-RSI threshold parameter, strong trend, bearish divergence
Calculation: dragonfly doji = body fraction <= doji-body-fraction parameter AND lower wick >= ATR × reversal-wick parameter AND upper wick <= wick tolerance AND range >= ATR × minimum-pattern-range parameter
Calculation: gravestone doji = body fraction <= doji-body-fraction parameter AND upper wick >= ATR × reversal-wick parameter AND lower wick <= wick tolerance AND range >= ATR × minimum-pattern-range parameter
Calculation: hammer shape = body fraction <= hammer-body-fraction parameter AND lower wick >= ATR × reversal-wick parameter AND upper wick <= max(body × hammer-opposing-wick-body parameter, wick tolerance) AND range >= ATR × minimum-pattern-range parameter
Calculation: inverted-hammer shape = body fraction <= inverted-hammer-body-fraction parameter AND upper wick >= ATR × reversal-wick parameter AND lower wick <= max(body × inverted-hammer-opposing-wick-body parameter, wick tolerance) AND range >= ATR × minimum-pattern-range parameter
Calculation: bullish engulfing shape = bearish candle[1] AND bullish candle AND close >= open[1] AND open <= close[1] AND body > body[1] × engulfing-body-ratio parameter AND body > minimum body AND body[1] > minimum body[1]
Calculation: bearish engulfing shape = bullish candle[1] AND bearish candle AND close <= open[1] AND open >= close[1] AND body > body[1] × engulfing-body-ratio parameter AND body > minimum body AND body[1] > minimum body[1]
Calculation: required downward star gap = if true-gap parameter enabled then high[1] < low[2] else open[1] < close[2]
Calculation: required upward star gap = if true-gap parameter enabled then low[1] > high[2] else open[1] > close[2]
Calculation: morning-star shape = bearish candle[2] AND body[2] > minimum body[2] × star-body multiplier parameter AND body[1] / max(range[1], positive-epsilon parameter) < star-middle-body-fraction parameter AND bullish candle AND body > minimum body × star-body multiplier parameter AND close > average(open[2], close[2]) AND required downward star gap
Calculation: evening-star shape = bullish candle[2] AND body[2] > minimum body[2] × star-body multiplier parameter AND body[1] / max(range[1], positive-epsilon parameter) < star-middle-body-fraction parameter AND bearish candle AND body > minimum body × star-body multiplier parameter AND close < average(open[2], close[2]) AND required upward star gap
Calculation: piercing shape = bearish candle[1] AND body[1] > minimum body[1] AND bullish candle AND (if true-gap parameter enabled then open < low[1] else open < close[1]) AND close > average(open[1], close[1]) AND close < open[1] AND body > minimum body
Calculation: dark-cloud shape = bullish candle[1] AND body[1] > minimum body[1] AND bearish candle AND (if true-gap parameter enabled then open > high[1] else open > close[1]) AND close < average(open[1], close[1]) AND close > open[1] AND body > minimum body
Calculation: three-white-soldiers shape = bullish candle AND bullish candle[1] AND bullish candle[2] AND close > close[1] AND close[1] > close[2] AND open <= close[1] AND open >= open[1] AND open[1] <= close[2] AND open[1] >= open[2] AND body > minimum body AND body[1] > minimum body[1] AND body[2] > minimum body[2]
Calculation: three-black-crows shape = bearish candle AND bearish candle[1] AND bearish candle[2] AND close < close[1] AND close[1] < close[2] AND open >= close[1] AND open <= open[1] AND open[1] >= close[2] AND open[1] <= open[2] AND body > minimum body AND body[1] > minimum body[1] AND body[2] > minimum body[2]
Calculation: tweezer-bottom shape = bearish candle[1] AND bullish candle AND abs(low - low[1]) <= ATR × tweezer-tolerance parameter AND lower wick >= body
Calculation: tweezer-top shape = bullish candle[1] AND bearish candle AND abs(high - high[1]) <= ATR × tweezer-tolerance parameter AND upper wick >= body
Calculation: bullish-harami shape = bearish candle[1] AND body[1] > minimum body[1] × harami-prior-body multiplier parameter AND bullish candle AND max(open, close) <= max(open[1], close[1]) AND min(open, close) >= min(open[1], close[1]) AND body < body[1] × harami-body-ratio parameter
Calculation: bearish-harami shape = bullish candle[1] AND body[1] > minimum body[1] × harami-prior-body multiplier parameter AND bearish candle AND max(open, close) <= max(open[1], close[1]) AND min(open, close) >= min(open[1], close[1]) AND body < body[1] × harami-body-ratio parameter
Calculation: bullish dragonfly candidate = dragonfly doji AND downtrend context
Calculation: bullish engulfing candidate = bullish engulfing shape AND downtrend context[1]
Calculation: morning-star candidate = morning-star shape AND downtrend context[2]
Calculation: three-white-soldiers candidate = three-white-soldiers shape AND downtrend context[3]
Calculation: bullish hammer candidate = hammer shape AND downtrend context AND NOT bullish dragonfly candidate
Calculation: piercing candidate = piercing shape AND downtrend context[1]
Calculation: bullish-harami candidate = bullish-harami shape AND downtrend context[1]
Calculation: tweezer-bottom candidate = tweezer-bottom shape AND downtrend context
Calculation: inverted-hammer candidate = inverted-hammer shape AND downtrend context
Calculation: bearish gravestone candidate = gravestone doji AND uptrend context
Calculation: bearish engulfing candidate = bearish engulfing shape AND uptrend context[1]
Calculation: evening-star candidate = evening-star shape AND uptrend context[2]
Calculation: three-black-crows candidate = three-black-crows shape AND uptrend context[3]
Calculation: shooting-star candidate = inverted-hammer shape AND uptrend context AND NOT bearish gravestone candidate
Calculation: dark-cloud candidate = dark-cloud shape AND uptrend context[1]
Calculation: bearish-harami candidate = bearish-harami shape AND uptrend context[1]
Calculation: tweezer-top candidate = tweezer-top shape AND uptrend context
Calculation: hanging-man candidate = hammer shape AND uptrend context
Calculation: engulfing ratio = body / max(body[1], positive-epsilon parameter)
Calculation: close-top fraction = if range > 0 then (close - low) / range else 0
Calculation: close-bottom fraction = if range > 0 then (high - close) / range else 0
Calculation: bullish-engulfing quality = min(large quality-score cap parameter, (engulfing ratio >= engulfing-ratio-high parameter ? high-tier quality points parameter : engulfing ratio >= engulfing-ratio-low parameter ? low-tier quality points parameter : 0) + (close-top fraction >= engulfing-close-high parameter ? high-tier quality points parameter : close-top fraction >= engulfing-close-low parameter ? low-tier quality points parameter : 0))
Calculation: bearish-engulfing quality = min(large quality-score cap parameter, (engulfing ratio >= engulfing-ratio-high parameter ? high-tier quality points parameter : engulfing ratio >= engulfing-ratio-low parameter ? low-tier quality points parameter : 0) + (close-bottom fraction >= engulfing-close-high parameter ? high-tier quality points parameter : close-bottom fraction >= engulfing-close-low parameter ? low-tier quality points parameter : 0))
Calculation: lower-wick ATR ratio = lower wick / max(ATR, positive-epsilon parameter)
Calculation: upper-wick ATR ratio = upper wick / max(ATR, positive-epsilon parameter)
Calculation: body-top position = if range > 0 then (min(open, close) - low) / range else 0
Calculation: body-bottom position = if range > 0 then (high - max(open, close)) / range else 0
Calculation: hammer quality = min(large quality-score cap parameter, (lower-wick ATR ratio >= long-wick quality-high parameter ? high-tier quality points parameter : lower-wick ATR ratio >= long-wick quality-low parameter ? low-tier quality points parameter : 0) + (body-top position >= body-position quality parameter ? one body-position quality point parameter : 0) + (upper wick <= max(body × small-opposing-wick parameter, ATR × small-opposing-wick ATR parameter) ? one wick quality point parameter : 0))
Calculation: shooting-star quality = min(large quality-score cap parameter, (upper-wick ATR ratio >= long-wick quality-high parameter ? high-tier quality points parameter : upper-wick ATR ratio >= long-wick quality-low parameter ? low-tier quality points parameter : 0) + (body-bottom position >= body-position quality parameter ? one body-position quality point parameter : 0) + (lower wick <= max(body × small-opposing-wick parameter, ATR × small-opposing-wick ATR parameter) ? one wick quality point parameter : 0))
Calculation: dragonfly quality = min(large quality-score cap parameter, (lower-wick ATR ratio >= long-wick quality-high parameter ? high-tier quality points parameter : lower-wick ATR ratio >= long-wick quality-low parameter ? low-tier quality points parameter : 0) + (upper wick <= wick tolerance ? one wick quality point parameter : 0))
Calculation: gravestone quality = min(large quality-score cap parameter, (upper-wick ATR ratio >= long-wick quality-high parameter ? high-tier quality points parameter : upper-wick ATR ratio >= long-wick quality-low parameter ? low-tier quality points parameter : 0) + (lower wick <= wick tolerance ? one wick quality point parameter : 0))
Calculation: inverted-hammer quality = min(small quality-score cap parameter, (upper-wick ATR ratio >= long-wick quality-high parameter ? high-tier quality points parameter : upper-wick ATR ratio >= long-wick quality-low parameter ? low-tier quality points parameter : 0) + (body-bottom position >= body-position quality parameter ? one body-position quality point parameter : 0))
Calculation: hanging-man quality = min(small quality-score cap parameter, (lower-wick ATR ratio >= long-wick quality-high parameter ? high-tier quality points parameter : lower-wick ATR ratio >= long-wick quality-low parameter ? low-tier quality points parameter : 0) + (body-top position >= body-position quality parameter ? one body-position quality point parameter : 0))
Calculation: morning-star doji fraction = body[1] / max(range[1], positive-epsilon parameter)
Calculation: morning-star penetration = (close - close[2]) / max(open[2] - close[2], positive-epsilon parameter)
Calculation: evening-star penetration = (close[2] - close) / max(close[2] - open[2], positive-epsilon parameter)
Calculation: morning-star quality = min(large quality-score cap parameter, (morning-star doji fraction <= star-doji quality-high parameter ? high-tier quality points parameter : morning-star doji fraction <= star-doji quality-low parameter ? low-tier quality points parameter : 0) + (morning-star penetration >= star-penetration-high parameter ? high-tier quality points parameter : morning-star penetration >= star-penetration-low parameter ? low-tier quality points parameter : 0))
Calculation: evening-star quality = min(large quality-score cap parameter, (morning-star doji fraction <= star-doji quality-high parameter ? high-tier quality points parameter : morning-star doji fraction <= star-doji quality-low parameter ? low-tier quality points parameter : 0) + (evening-star penetration >= star-penetration-high parameter ? high-tier quality points parameter : evening-star penetration >= star-penetration-low parameter ? low-tier quality points parameter : 0))
Calculation: piercing penetration = (close - close[1]) / max(open[1] - close[1], positive-epsilon parameter)
Calculation: dark-cloud penetration = (close[1] - close) / max(close[1] - open[1], positive-epsilon parameter)
Calculation: piercing quality = piercing penetration >= piercing-top-tier parameter ? top-tier quality points parameter : piercing penetration >= piercing-middle-tier parameter ? middle-tier quality points parameter : piercing penetration >= piercing-low-tier parameter ? low-tier quality points parameter : 0
Calculation: dark-cloud quality = dark-cloud penetration >= dark-cloud-top-tier parameter ? top-tier quality points parameter : dark-cloud penetration >= dark-cloud-middle-tier parameter ? middle-tier quality points parameter : dark-cloud penetration >= dark-cloud-low-tier parameter ? low-tier quality points parameter : 0
Calculation: average three-bar body fraction = average(body fraction, body fraction[1], body fraction[2])
Calculation: average three-bar close-top fraction = average(close-top fraction, close-top fraction[1], close-top fraction[2])
Calculation: average three-bar close-bottom fraction = average(close-bottom fraction, close-bottom fraction[1], close-bottom fraction[2])
Calculation: three-white-soldiers quality = min(large quality-score cap parameter, (average three-bar body fraction >= three-bar-body-high parameter ? high-tier quality points parameter : average three-bar body fraction >= three-bar-body-low parameter ? low-tier quality points parameter : 0) + (average three-bar close-top fraction >= three-bar-close-position parameter ? one body-position quality point parameter : 0))
Calculation: three-black-crows quality = min(large quality-score cap parameter, (average three-bar body fraction >= three-bar-body-high parameter ? high-tier quality points parameter : average three-bar body fraction >= three-bar-body-low parameter ? low-tier quality points parameter : 0) + (average three-bar close-bottom fraction >= three-bar-close-position parameter ? one body-position quality point parameter : 0))
Calculation: tweezer-bottom tightness = abs(low - low[1]) / max(ATR, positive-epsilon parameter)
Calculation: tweezer-top tightness = abs(high - high[1]) / max(ATR, positive-epsilon parameter)
Calculation: tweezer-bottom quality = min(large quality-score cap parameter, (tweezer-bottom tightness <= tweezer-tightness-high parameter ? high-tier quality points parameter : tweezer-bottom tightness <= tweezer-tightness-low parameter ? low-tier quality points parameter : 0) + (lower wick / max(body, positive-epsilon parameter) >= tweezer-wick-body parameter ? one wick quality point parameter : 0))
Calculation: tweezer-top quality = min(large quality-score cap parameter, (tweezer-top tightness <= tweezer-tightness-high parameter ? high-tier quality points parameter : tweezer-top tightness <= tweezer-tightness-low parameter ? low-tier quality points parameter : 0) + (upper wick / max(body, positive-epsilon parameter) >= tweezer-wick-body parameter ? one wick quality point parameter : 0))
Calculation: harami ratio = body / max(body[1], positive-epsilon parameter)
Calculation: bullish-harami quality = min(large quality-score cap parameter, (harami ratio <= harami-ratio-high parameter ? high-tier quality points parameter : harami ratio <= harami-ratio-low parameter ? low-tier quality points parameter : 0) + (body[1] / max(ATR, positive-epsilon parameter) >= harami-prior-body ATR parameter ? one body-position quality point parameter : 0))
Calculation: bearish-harami quality = min(large quality-score cap parameter, (harami ratio <= harami-ratio-high parameter ? high-tier quality points parameter : harami ratio <= harami-ratio-low parameter ? low-tier quality points parameter : 0) + (body[1] / max(ATR, positive-epsilon parameter) >= harami-prior-body ATR parameter ? one body-position quality point parameter : 0))
Calculation: volume score(ratio) = ratio >= volume-score-high parameter ? high-tier quality points parameter : ratio >= volume-score-low parameter ? low-tier quality points parameter : 0
Calculation: previous-bar volume ratio = volume / max(volume[1], positive-epsilon parameter)
Calculation: prior-two-bar average volume ratio = volume / max(average(volume[1], volume[2]), positive-epsilon parameter)
Calculation: average-volume ratio = volume / max(volume average, positive-epsilon parameter)
Calculation: bullish pattern quality = bullish engulfing candidate ? bullish-engulfing quality : morning-star candidate ? morning-star quality : three-white-soldiers candidate ? three-white-soldiers quality : bullish dragonfly candidate ? dragonfly quality : bullish hammer candidate ? hammer quality : piercing candidate ? piercing quality : bullish-harami candidate ? bullish-harami quality : tweezer-bottom candidate ? tweezer-bottom quality : inverted-hammer candidate ? inverted-hammer quality : 0
Calculation: bearish pattern quality = bearish engulfing candidate ? bearish-engulfing quality : evening-star candidate ? evening-star quality : three-black-crows candidate ? three-black-crows quality : bearish gravestone candidate ? gravestone quality : shooting-star candidate ? shooting-star quality : dark-cloud candidate ? dark-cloud quality : bearish-harami candidate ? bearish-harami quality : tweezer-top candidate ? tweezer-top quality : hanging-man candidate ? hanging-man quality : 0
Calculation: bullish volume points = bullish engulfing candidate ? volume score(previous-bar volume ratio) : morning-star candidate OR three-white-soldiers candidate ? volume score(prior-two-bar average volume ratio) : bullish dragonfly candidate OR bullish hammer candidate OR inverted-hammer candidate ? volume score(average-volume ratio) : piercing candidate OR bullish-harami candidate OR tweezer-bottom candidate ? volume score(previous-bar volume ratio) : 0
Calculation: bearish volume points = bearish engulfing candidate ? volume score(previous-bar volume ratio) : evening-star candidate OR three-black-crows candidate ? volume score(prior-two-bar average volume ratio) : bearish gravestone candidate OR shooting-star candidate OR hanging-man candidate ? volume score(average-volume ratio) : dark-cloud candidate OR bearish-harami candidate OR tweezer-top candidate ? volume score(previous-bar volume ratio) : 0
Calculation: bullish strength = bullish pattern quality + bullish confirmation points + bullish volume points
Calculation: bearish strength = bearish pattern quality + bearish confirmation points + bearish volume points
Calculation: bullish geometry = bullish engulfing candidate OR morning-star candidate OR three-white-soldiers candidate OR bullish dragonfly candidate OR bullish hammer candidate OR piercing candidate OR bullish-harami candidate OR tweezer-bottom candidate OR inverted-hammer candidate
Calculation: bearish geometry = bearish engulfing candidate OR evening-star candidate OR three-black-crows candidate OR bearish gravestone candidate OR shooting-star candidate OR dark-cloud candidate OR bearish-harami candidate OR tweezer-top candidate OR hanging-man candidate
Calculation: minimum strength threshold = grade-A strength threshold parameter if selected minimum grade is A, grade-B strength threshold parameter if selected minimum grade is B, otherwise grade-C strength threshold parameter
Long: uptrend
Short: downtrend
Long: bullish geometry AND bullish strength >= minimum strength threshold AND (confirmation-only parameter disabled OR chart bar is closed) AND (no prior bullish fire OR bars since prior bullish fire > same-direction cooldown parameter)
Short: bearish geometry AND bearish strength >= minimum strength threshold AND (confirmation-only parameter disabled OR chart bar is closed) AND (no prior bearish fire OR bars since prior bearish fire > same-direction cooldown parameter)
Long: bullish dragonfly candidate AND (confirmation-only parameter disabled OR chart bar is closed)
Short: bearish gravestone candidate AND (confirmation-only parameter disabled OR chart bar is closed)