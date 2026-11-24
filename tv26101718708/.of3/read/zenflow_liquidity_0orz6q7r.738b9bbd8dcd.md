Calculation: bullish trend = close > EMA(close, slow lookback) AND EMA(close, fast lookback) > EMA(close, slow lookback), with the fast lookback shorter than the slow lookback
Calculation: bearish trend = close < EMA(close, slow lookback) AND EMA(close, fast lookback) < EMA(close, slow lookback)
Calculation: above VWAP = close > VWAP(close)
Calculation: below VWAP = close < VWAP(close)
Calculation: VWAP reclaim = close > VWAP(close) AND close[1] <= VWAP(close)[1]
Calculation: VWAP rejection = close < VWAP(close) AND close[1] >= VWAP(close)[1]
Calculation: near VWAP = abs(close - VWAP(close)) <= ATR(ATR lookback) * VWAP proximity parameter
Calculation: near EMA = abs(close - EMA(close, slow lookback)) <= ATR(ATR lookback) * EMA proximity parameter OR abs(close - EMA(close, fast lookback)) <= ATR(ATR lookback) * EMA proximity parameter
Calculation: session passes = session filter disabled OR session setting permits all bars OR datetime is within the configured session selected by the session setting
Calculation: high volume = volume > SMA(volume, volume lookback) * volume multiplier
Calculation: bar range = max(high - low, minimum price increment)
Calculation: body size = abs(close - open)
Calculation: upper wick = high - max(open, close)
Calculation: lower wick = min(open, close) - low
Calculation: close location = (close - low) / bar range
Calculation: bullish EMA flip = EMA(close, fast lookback) crosses above EMA(close, slow lookback)
Calculation: bearish EMA flip = EMA(close, fast lookback) crosses below EMA(close, slow lookback)
Calculation: continuation break high = close > highest(high, continuation lookback)[1]
Calculation: continuation break low = close < lowest(low, continuation lookback)[1]
Calculation: pullback break high = close > highest(high, pullback lookback)[1]
Calculation: pullback break low = close < lowest(low, pullback lookback)[1]
Calculation: reversal break high = close > highest(high, reversal lookback)[1]
Calculation: reversal break low = close < lowest(low, reversal lookback)[1]
Calculation: trigger break high = close > highest(high, trigger lookback)[1]
Calculation: trigger break low = close < lowest(low, trigger lookback)[1]
Calculation: long watch = bullish trend AND session passes AND (near EMA OR near VWAP)
Calculation: short watch = bearish trend AND session passes AND (near EMA OR near VWAP)
Calculation: pullback long watch = bullish trend AND above VWAP AND near EMA AND session passes
Calculation: pullback short watch = bearish trend AND below VWAP AND near EMA AND session passes
Calculation: reversal long watch = below VWAP AND bullish EMA flip AND session passes
Calculation: reversal short watch = above VWAP AND bearish EMA flip AND session passes
Calculation: prior T1 high = high of the last completed T1 bar, mapped onto chart bars
Calculation: prior T1 low = low of the last completed T1 bar, mapped onto chart bars
Calculation: sell-side sweep = ICT overlay enabled AND ((low < prior T1 low AND close > prior T1 low) OR (low < lowest(low, liquidity lookback)[1] AND close > lowest(low, liquidity lookback)[1]))
Calculation: buy-side sweep = ICT overlay enabled AND ((high > prior T1 high AND close < prior T1 high) OR (high > highest(high, liquidity lookback)[1] AND close < highest(high, liquidity lookback)[1]))
Calculation: recent sell-side sweep = ICT overlay enabled AND bars since sell-side sweep <= recent-sweep window
Calculation: recent buy-side sweep = ICT overlay enabled AND bars since buy-side sweep <= recent-sweep window
Calculation: buy pressure volume = volume * close location
Calculation: sell pressure volume = volume * (1 - close location)
Calculation: delta proxy = buy pressure volume - sell pressure volume
Calculation: average absolute delta = EMA(abs(delta proxy), order-flow lookback)
Calculation: delta strength = delta proxy / average absolute delta when average absolute delta is positive, otherwise zero
Calculation: cumulative delta proxy = cumulative sum(delta proxy)
Calculation: cumulative delta signal = EMA(cumulative delta proxy, cumulative-delta smoothing lookback)
Calculation: bullish order-flow impulse = delta strength >= delta-strength threshold AND cumulative delta proxy >= cumulative delta signal AND close location >= upper close-location threshold
Calculation: bearish order-flow impulse = delta strength <= negative delta-strength threshold AND cumulative delta proxy <= cumulative delta signal AND close location <= lower close-location threshold
Calculation: bullish absorption = high volume AND lower wick > body size AND close location >= middle bullish close-location threshold
Calculation: bearish absorption = high volume AND upper wick > body size AND close location <= middle bearish close-location threshold
Calculation: bullish exhaustion = high volume AND upper wick > body size * exhaustion wick multiplier AND close location < upper close-location threshold AND close > open
Calculation: bearish exhaustion = high volume AND lower wick > body size * exhaustion wick multiplier AND close location > lower close-location threshold AND close < open
Calculation: long trap = low < lowest(low, trap lookback)[1] AND close > lowest(low, trap lookback)[1] AND delta strength < zero AND close location >= middle bullish close-location threshold
Calculation: short trap = high > highest(high, trap lookback)[1] AND close < highest(high, trap lookback)[1] AND delta strength > zero AND close location <= middle bearish close-location threshold
Calculation: impulse body = body size >= EMA(body size, order-flow lookback) * impulse-body multiplier
Calculation: bullish impulse tag = impulse body AND bullish order-flow impulse AND close > high[1]
Calculation: bearish impulse tag = impulse body AND bearish order-flow impulse AND close < low[1]
Calculation: long order-flow gate = order-flow filter disabled OR order-flow scoring disabled OR bullish order-flow impulse OR bullish absorption OR long trap
Calculation: short order-flow gate = order-flow filter disabled OR order-flow scoring disabled OR bearish order-flow impulse OR bearish absorption OR short trap
Calculation: volume gate = volume filter disabled OR high volume
Calculation: pullback volume gate = pullback volume requirement disabled OR high volume
Calculation: reversal volume gate = reversal volume requirement disabled OR high volume
Calculation: bullish rejection candle = lower wick >= body size * rejection wick ratio AND close location >= upper close-location threshold AND close > open
Calculation: bearish rejection candle = upper wick >= body size * rejection wick ratio AND close location <= lower close-location threshold AND close < open
Calculation: long trigger confirmation = session passes AND (long watch OR pullback long watch OR reversal long watch) AND (bullish rejection candle OR trigger break high OR long trap OR bullish impulse tag)
Calculation: short trigger confirmation = session passes AND (short watch OR pullback short watch OR reversal short watch) AND (bearish rejection candle OR trigger break low OR short trap OR bearish impulse tag)
Calculation: bullish regime flip = above VWAP AND EMA(close, fast lookback) > EMA(close, slow lookback) AND close > EMA(close, fast lookback)
Calculation: bearish regime flip = below VWAP AND EMA(close, fast lookback) < EMA(close, slow lookback) AND close < EMA(close, fast lookback)
Calculation: bullish thesis reset = bullish trend AND above VWAP AND (bullish order-flow impulse OR trigger break high OR continuation break high)
Calculation: bearish thesis reset = bearish trend AND below VWAP AND (bearish order-flow impulse OR trigger break low OR continuation break low)
Calculation: long thesis invalidation = invalidation enabled AND ((VWAP-flip invalidation enabled AND bearish regime flip) OR (opposite-order-flow invalidation enabled AND (bearish order-flow impulse OR bearish absorption OR short trap))) AND NOT bullish thesis reset
Calculation: short thesis invalidation = invalidation enabled AND ((VWAP-flip invalidation enabled AND bullish regime flip) OR (opposite-order-flow invalidation enabled AND (bullish order-flow impulse OR bullish absorption OR long trap))) AND NOT bearish thesis reset
Calculation: momentum long watch = momentum state enabled AND bullish trend AND above VWAP AND session passes AND (bullish order-flow impulse OR continuation break high OR trigger break high) AND NOT long thesis invalidation
Calculation: momentum short watch = momentum state enabled AND bearish trend AND below VWAP AND session passes AND (bearish order-flow impulse OR continuation break low OR trigger break low) AND NOT short thesis invalidation
Calculation: long lower-timeframe execution base = lower-timeframe execution enabled AND pullback long watch AND trigger break high AND NOT long thesis invalidation
Calculation: short lower-timeframe execution base = lower-timeframe execution enabled AND pullback short watch AND trigger break low AND NOT short thesis invalidation
Calculation: continuation long = continuation engine enabled AND bullish trend AND (VWAP filter disabled OR VWAP reclaim) AND volume gate AND continuation break high AND long order-flow gate AND session passes AND (trigger requirement disabled OR long trigger confirmation) AND NOT long thesis invalidation
Calculation: continuation short = continuation engine enabled AND bearish trend AND (VWAP filter disabled OR VWAP rejection) AND volume gate AND continuation break low AND short order-flow gate AND session passes AND (trigger requirement disabled OR short trigger confirmation) AND NOT short thesis invalidation
Calculation: raw pullback long = pullback engine enabled AND ((bullish trend AND above VWAP AND near EMA AND pullback break high AND pullback volume gate AND long order-flow gate AND session passes AND (trigger requirement disabled OR long trigger confirmation) AND NOT long thesis invalidation) OR long lower-timeframe execution base)
Calculation: raw pullback short = pullback engine enabled AND ((bearish trend AND below VWAP AND near EMA AND pullback break low AND pullback volume gate AND short order-flow gate AND session passes AND (trigger requirement disabled OR short trigger confirmation) AND NOT short thesis invalidation) OR short lower-timeframe execution base)
Calculation: pullback long = raw pullback long AND (NOT long lower-timeframe execution base OR entry confidence >= minimum entry confidence)
Calculation: pullback short = raw pullback short AND (NOT short lower-timeframe execution base OR entry confidence >= minimum entry confidence)
Calculation: reversal long = reversal engine enabled AND below VWAP AND VWAP reclaim AND bullish EMA flip AND reversal break high AND reversal volume gate AND long order-flow gate AND session passes AND (trigger requirement disabled OR long trigger confirmation) AND NOT long thesis invalidation
Calculation: reversal short = reversal engine enabled AND above VWAP AND VWAP rejection AND bearish EMA flip AND reversal break low AND reversal volume gate AND short order-flow gate AND session passes AND (trigger requirement disabled OR short trigger confirmation) AND NOT short thesis invalidation
Calculation: raw long context = continuation long OR raw pullback long OR reversal long OR long trigger confirmation OR long watch OR pullback long watch OR reversal long watch OR momentum long watch
Calculation: raw short context = continuation short OR raw pullback short OR reversal short OR short trigger confirmation OR short watch OR pullback short watch OR reversal short watch OR momentum short watch
Calculation: bullish order-flow score = zero when order-flow scoring is disabled, otherwise (bullish impulse score weight if bullish order-flow impulse, else bullish absorption score weight if bullish absorption, else negative bullish exhaustion penalty if bullish exhaustion, else zero) + (trap boost if long trap, else zero) + (impulse boost if bullish impulse tag, else zero)
Calculation: bearish order-flow score = zero when order-flow scoring is disabled, otherwise (bearish impulse score weight if bearish order-flow impulse, else bearish absorption score weight if bearish absorption, else negative bearish exhaustion penalty if bearish exhaustion, else zero) + (trap boost if short trap, else zero) + (impulse boost if bearish impulse tag, else zero)
Calculation: bullish ICT score = sweep score boost if recent sell-side sweep, else zero
Calculation: bearish ICT score = sweep score boost if recent buy-side sweep, else zero
Calculation: bullish score = (trend score weight if bullish trend, else zero) + (VWAP score weight if above VWAP, else zero) + (volume score weight if high volume, else zero) + (break score weight if continuation break high, else zero) + (EMA proximity score weight if near EMA, else zero) + (session score weight if session passes, else zero) + bullish order-flow score + bullish ICT score
Calculation: bearish score = (trend score weight if bearish trend, else zero) + (VWAP score weight if below VWAP, else zero) + (volume score weight if high volume, else zero) + (break score weight if continuation break low, else zero) + (EMA proximity score weight if near EMA, else zero) + (session score weight if session passes, else zero) + bearish order-flow score + bearish ICT score
Calculation: pullback bullish score = (trend score weight if bullish trend, else zero) + (VWAP score weight if above VWAP, else zero) + (pullback EMA proximity score weight if near EMA, else zero) + (pullback break score weight if pullback break high, else zero) + (pullback volume score weight if pullback volume gate, else zero) + bullish order-flow score + bullish ICT score
Calculation: pullback bearish score = (trend score weight if bearish trend, else zero) + (VWAP score weight if below VWAP, else zero) + (pullback EMA proximity score weight if near EMA, else zero) + (pullback break score weight if pullback break low, else zero) + (pullback volume score weight if pullback volume gate, else zero) + bearish order-flow score + bearish ICT score
Calculation: reversal bullish score = (VWAP location score weight if below VWAP, else zero) + (VWAP reclaim score weight if VWAP reclaim, else zero) + (EMA flip score weight if bullish EMA flip, else zero) + (reversal break score weight if reversal break high, else zero) + (reversal volume score weight if reversal volume gate, else zero) + bullish order-flow score + bullish ICT score
Calculation: reversal bearish score = (VWAP location score weight if above VWAP, else zero) + (VWAP rejection score weight if VWAP rejection, else zero) + (EMA flip score weight if bearish EMA flip, else zero) + (reversal break score weight if reversal break low, else zero) + (reversal volume score weight if reversal volume gate, else zero) + bearish order-flow score + bearish ICT score
Calculation: long context active = raw long context OR bullish score > bearish score
Calculation: short context active = raw short context OR bearish score > bullish score
Calculation: conflict penalty = trend-conflict penalty if ((long context active AND bearish trend) OR (short context active AND bullish trend)) + location-conflict penalty if ((long context active AND below VWAP) OR (short context active AND above VWAP)) + order-flow-conflict penalty if ((long context active AND (bearish order-flow impulse OR bearish absorption OR short trap OR bearish impulse tag)) OR (short context active AND (bullish order-flow impulse OR bullish absorption OR long trap OR bullish impulse tag))) + no-modifier penalty if no trap or impulse tag is present + no-trigger penalty if trigger requirement is enabled and neither trigger is confirmed
Calculation: entry confidence = clamp(max(bullish score, bearish score, pullback bullish score, pullback bearish score, reversal bullish score, reversal bearish score) - conflict penalty, confidence floor, confidence cap)
Calculation: momentum long = momentum state enabled AND momentum long watch AND entry confidence >= minimum entry confidence
Calculation: momentum short = momentum state enabled AND momentum short watch AND entry confidence >= minimum entry confidence
Calculation: long entry signal = continuation long OR pullback long OR reversal long OR momentum long
Calculation: short entry signal = continuation short OR pullback short OR reversal short OR momentum short
Calculation: stored long stop = min(entry-bar low, entry price - ATR(ATR lookback, entry bar) * stop ATR multiplier)
Calculation: stored short stop = max(entry-bar high, entry price + ATR(ATR lookback, entry bar) * stop ATR multiplier)
Long: bullish trend
Short: bearish trend
Long: sell-side sweep
Short: buy-side sweep
Long: recent sell-side sweep
Short: recent buy-side sweep
Long: bullish order-flow impulse OR bullish absorption
Short: bearish order-flow impulse OR bearish absorption
Long: long trap OR bullish impulse tag
Short: short trap OR bearish impulse tag
Long: bullish order-flow impulse AND above VWAP AND NOT bearish trend
Short: bearish order-flow impulse AND below VWAP AND NOT bullish trend
Long: long watch
Short: short watch
Long: pullback long watch
Short: pullback short watch
Long: reversal long watch
Short: reversal short watch
Long: momentum long watch
Short: momentum short watch
Long: long trigger confirmation
Short: short trigger confirmation
Long: long entry signal
Short: short entry signal
Exit: long, low <= stored long stop OR long thesis invalidation
Exit: short, high >= stored short stop OR short thesis invalidation