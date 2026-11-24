Calculation: Bull trend = close > EMA(close, longer EMA lookback) AND EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback)
Calculation: Bear trend = close < EMA(close, longer EMA lookback) AND EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback)
Calculation: High volume = volume > SMA(volume, volume lookback) * volume multiplier
Calculation: Bar range = max(high - low, minimum price increment)
Calculation: Body size = abs(close - open)
Calculation: Upper wick = high - max(open, close)
Calculation: Lower wick = min(open, close) - low
Calculation: Close location = (close - low) / bar range
Calculation: Delta proxy = volume * close location - volume * (1 - close location)
Calculation: Average absolute delta = EMA(abs(delta proxy), delta lookback)
Calculation: Delta strength = delta proxy / average absolute delta when average absolute delta > 0, otherwise 0
Calculation: Cumulative delta = cumulative sum of delta proxy
Calculation: Cumulative delta signal = EMA(cumulative delta, delta smoothing length)
Calculation: Bullish flow impulse = delta strength >= delta strength threshold AND cumulative delta >= cumulative delta signal AND close location >= bullish flow location threshold
Calculation: Bearish flow impulse = delta strength <= -delta strength threshold AND cumulative delta <= cumulative delta signal AND close location <= bearish flow location threshold
Calculation: Bullish absorption = high volume AND lower wick > body size AND close location >= bullish absorption location threshold
Calculation: Bearish absorption = high volume AND upper wick > body size AND close location <= bearish absorption location threshold
Calculation: Bullish exhaustion = high volume AND upper wick > body size * exhaustion wick multiplier AND close location < bullish flow location threshold AND close > open
Calculation: Bearish exhaustion = high volume AND lower wick > body size * exhaustion wick multiplier AND close location > bearish flow location threshold AND close < open
Calculation: Failed break above = high > highest(high, trap lookback)[1] AND close < highest(high, trap lookback)[1]
Calculation: Failed break below = low < lowest(low, trap lookback)[1] AND close > lowest(low, trap lookback)[1]
Calculation: Long trap = failed break below AND delta strength < 0 AND close location >= bullish absorption location threshold
Calculation: Short trap = failed break above AND delta strength > 0 AND close location <= bearish absorption location threshold
Calculation: Impulse body = body size >= EMA(body size, delta lookback) * impulse body multiplier
Calculation: Bullish impulse tag = impulse body AND bullish flow impulse AND close > high[1]
Calculation: Bearish impulse tag = impulse body AND bearish flow impulse AND close < low[1]
Calculation: Volume pass = volume filter disabled OR high volume
Calculation: Session pass = session filter disabled OR datetime is within the configured allowed session
Calculation: Near VWAP = abs(close - VWAP) <= ATR(ATR lookback) * VWAP proximity parameter
Calculation: Near EMA = abs(close - EMA(close, longer EMA lookback)) <= ATR(ATR lookback) * EMA proximity parameter OR abs(close - EMA(close, shorter EMA lookback)) <= ATR(ATR lookback) * EMA proximity parameter
Calculation: Bullish VWAP reclaim = close > VWAP AND close[1] <= VWAP[1]
Calculation: Bearish VWAP rejection = close < VWAP AND close[1] >= VWAP[1]
Calculation: Bullish EMA flip = EMA(close, shorter EMA lookback) crosses above EMA(close, longer EMA lookback)
Calculation: Bearish EMA flip = EMA(close, shorter EMA lookback) crosses below EMA(close, longer EMA lookback)
Calculation: Continuation break above = close > highest(high, continuation break lookback)[1]
Calculation: Continuation break below = close < lowest(low, continuation break lookback)[1]
Calculation: Pullback break above = close > highest(high, pullback break lookback)[1]
Calculation: Pullback break below = close < lowest(low, pullback break lookback)[1]
Calculation: Reversal break above = close > highest(high, reversal break lookback)[1]
Calculation: Reversal break below = close < lowest(low, reversal break lookback)[1]
Calculation: Trigger break above = close > highest(high, trigger break lookback)[1]
Calculation: Trigger break below = close < lowest(low, trigger break lookback)[1]
Calculation: Bullish rejection candle = lower wick >= body size * rejection wick ratio AND close location >= bullish flow location threshold AND close > open
Calculation: Bearish rejection candle = upper wick >= body size * rejection wick ratio AND close location <= bearish flow location threshold AND close < open
Calculation: Long watch = Bull trend AND session pass AND (near EMA OR near VWAP)
Calculation: Short watch = Bear trend AND session pass AND (near EMA OR near VWAP)
Calculation: Pullback long watch = Bull trend AND close > VWAP AND near EMA AND session pass
Calculation: Pullback short watch = Bear trend AND close < VWAP AND near EMA AND session pass
Calculation: Reversal long watch = close < VWAP AND bullish EMA flip AND session pass
Calculation: Reversal short watch = close > VWAP AND bearish EMA flip AND session pass
Calculation: Long trigger confirmation = session pass AND (long watch OR pullback long watch OR reversal long watch) AND (bullish rejection candle OR trigger break above OR long trap OR bullish impulse tag)
Calculation: Short trigger confirmation = session pass AND (short watch OR pullback short watch OR reversal short watch) AND (bearish rejection candle OR trigger break below OR short trap OR bearish impulse tag)
Calculation: Bull regime flip = close > VWAP AND EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback) AND close > EMA(close, shorter EMA lookback)
Calculation: Bear regime flip = close < VWAP AND EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback) AND close < EMA(close, shorter EMA lookback)
Calculation: Bull thesis reset = Bull trend AND close > VWAP AND (bullish flow impulse OR trigger break above OR continuation break above)
Calculation: Bear thesis reset = Bear trend AND close < VWAP AND (bearish flow impulse OR trigger break below OR continuation break below)
Calculation: Long thesis invalid = invalidation enabled AND ((VWAP flip invalidation enabled AND bear regime flip) OR (opposite flow invalidation enabled AND (bearish flow impulse OR bearish absorption OR short trap))) AND NOT bull thesis reset
Calculation: Short thesis invalid = invalidation enabled AND ((VWAP flip invalidation enabled AND bull regime flip) OR (opposite flow invalidation enabled AND (bullish flow impulse OR bullish absorption OR long trap))) AND NOT bear thesis reset
Calculation: Bullish momentum watch = momentum state enabled AND Bull trend AND close > VWAP AND session pass AND (bullish flow impulse OR continuation break above OR trigger break above) AND NOT long thesis invalid
Calculation: Bearish momentum watch = momentum state enabled AND Bear trend AND close < VWAP AND session pass AND (bearish flow impulse OR continuation break below OR trigger break below) AND NOT short thesis invalid
Calculation: Bullish flow pass = order-flow scoring disabled OR bullish flow impulse OR bullish absorption OR long trap
Calculation: Bearish flow pass = order-flow scoring disabled OR bearish flow impulse OR bearish absorption OR short trap
Calculation: Long flow gate = order-flow filter disabled OR bullish flow pass
Calculation: Short flow gate = order-flow filter disabled OR bearish flow pass
Calculation: Long trigger pass = trigger requirement disabled OR long trigger confirmation
Calculation: Short trigger pass = trigger requirement disabled OR short trigger confirmation
Calculation: Pullback volume pass = pullback volume requirement disabled OR high volume
Calculation: Reversal volume pass = reversal volume requirement disabled OR high volume
Calculation: Long pullback execution base = lower-timeframe execution enabled AND pullback long watch AND Bull trend AND close > VWAP AND near EMA AND trigger break above AND NOT long thesis invalid
Calculation: Short pullback execution base = lower-timeframe execution enabled AND pullback short watch AND Bear trend AND close < VWAP AND near EMA AND trigger break below AND NOT short thesis invalid
Calculation: Raw bullish continuation = continuation engine enabled AND Bull trend AND (VWAP filter disabled OR bullish VWAP reclaim) AND volume pass AND continuation break above AND long flow gate AND session pass AND long trigger pass AND NOT long thesis invalid
Calculation: Raw bearish continuation = continuation engine enabled AND Bear trend AND (VWAP filter disabled OR bearish VWAP rejection) AND volume pass AND continuation break below AND short flow gate AND session pass AND short trigger pass AND NOT short thesis invalid
Calculation: Raw bullish pullback = pullback engine enabled AND ((Bull trend AND close > VWAP AND near EMA AND pullback break above AND pullback volume pass AND long flow gate AND session pass AND long trigger pass AND NOT long thesis invalid) OR long pullback execution base)
Calculation: Raw bearish pullback = pullback engine enabled AND ((Bear trend AND close < VWAP AND near EMA AND pullback break below AND pullback volume pass AND short flow gate AND session pass AND short trigger pass AND NOT short thesis invalid) OR short pullback execution base)
Calculation: Raw bullish reversal = reversal engine enabled AND close < VWAP AND bullish VWAP reclaim AND bullish EMA flip AND reversal break above AND reversal volume pass AND long flow gate AND session pass AND long trigger pass AND NOT long thesis invalid
Calculation: Raw bearish reversal = reversal engine enabled AND close > VWAP AND bearish VWAP rejection AND bearish EMA flip AND reversal break below AND reversal volume pass AND short flow gate AND session pass AND short trigger pass AND NOT short thesis invalid
Calculation: Bullish momentum score = (Bull trend ? trend score weight : 0) + (close > VWAP ? location score weight : 0) + (high volume ? volume score weight : 0) + (continuation break above ? breakout score weight : 0) + (near EMA ? EMA proximity score weight : 0) + (session pass ? session score weight : 0) + bullish flow score
Calculation: Bearish momentum score = (Bear trend ? trend score weight : 0) + (close < VWAP ? location score weight : 0) + (high volume ? volume score weight : 0) + (continuation break below ? breakout score weight : 0) + (near EMA ? EMA proximity score weight : 0) + (session pass ? session score weight : 0) + bearish flow score
Calculation: Bullish pullback score = (Bull trend ? trend score weight : 0) + (close > VWAP ? pullback location score weight : 0) + (near EMA ? pullback EMA score weight : 0) + (pullback break above ? pullback breakout score weight : 0) + (pullback volume pass ? pullback volume score weight : 0) + bullish flow score
Calculation: Bearish pullback score = (Bear trend ? trend score weight : 0) + (close < VWAP ? pullback location score weight : 0) + (near EMA ? pullback EMA score weight : 0) + (pullback break below ? pullback breakout score weight : 0) + (pullback volume pass ? pullback volume score weight : 0) + bearish flow score
Calculation: Bullish reversal score = (close < VWAP ? reversal location score weight : 0) + (bullish VWAP reclaim ? VWAP reclaim score weight : 0) + (bullish EMA flip ? EMA flip score weight : 0) + (reversal break above ? reversal breakout score weight : 0) + (reversal volume pass ? reversal volume score weight : 0) + bullish flow score
Calculation: Bearish reversal score = (close > VWAP ? reversal location score weight : 0) + (bearish VWAP rejection ? VWAP reclaim score weight : 0) + (bearish EMA flip ? EMA flip score weight : 0) + (reversal break below ? reversal breakout score weight : 0) + (reversal volume pass ? reversal volume score weight : 0) + bearish flow score
Calculation: Bullish flow score = order-flow scoring enabled ? (bullish flow impulse ? flow impulse score : bullish absorption ? absorption score : bullish exhaustion ? exhaustion penalty : 0) + (long trap ? trap score boost : 0) + (bullish impulse tag ? impulse score boost : 0) : 0
Calculation: Bearish flow score = order-flow scoring enabled ? (bearish flow impulse ? flow impulse score : bearish absorption ? absorption score : bearish exhaustion ? exhaustion penalty : 0) + (short trap ? trap score boost : 0) + (bearish impulse tag ? impulse score boost : 0) : 0
Calculation: Pre-long context = raw bullish continuation OR raw bullish pullback OR raw bullish reversal OR long trigger confirmation OR long watch OR pullback long watch OR reversal long watch OR bullish momentum watch
Calculation: Pre-short context = raw bearish continuation OR raw bearish pullback OR raw bearish reversal OR short trigger confirmation OR short watch OR pullback short watch OR reversal short watch OR bearish momentum watch
Calculation: Bullish entry confidence = clamp(max(bullish momentum score, bearish momentum score, bullish pullback score, bearish pullback score, bullish reversal score, bearish reversal score) - trend conflict penalty - location conflict penalty - flow conflict penalty - no modifier penalty - no trigger penalty, confidence minimum, confidence maximum), where trend conflict applies if (pre-long context OR bullish momentum score > bearish momentum score) AND Bear trend OR (pre-short context OR bearish momentum score > bullish momentum score) AND Bull trend; location conflict applies if (pre-long context OR bullish momentum score > bearish momentum score) AND close < VWAP OR (pre-short context OR bearish momentum score > bullish momentum score) AND close > VWAP; flow conflict applies if (pre-long context OR bullish momentum score > bearish momentum score) AND (bearish flow impulse OR bearish absorption OR short trap OR bearish impulse tag) OR (pre-short context OR bearish momentum score > bullish momentum score) AND (bullish flow impulse OR bullish absorption OR long trap OR bullish impulse tag); no modifier penalty applies if none of long trap, short trap, bullish impulse tag, or bearish impulse tag; no trigger penalty applies if trigger requirement is enabled and neither trigger is confirmed
Calculation: Bullish entry = raw bullish continuation OR (raw bullish pullback AND (NOT long pullback execution base OR bullish entry confidence >= minimum entry score)) OR raw bullish reversal OR (bullish momentum watch AND bullish entry confidence >= minimum entry score)
Calculation: Bearish entry = raw bearish continuation OR (raw bearish pullback AND (NOT short pullback execution base OR bullish entry confidence >= minimum entry score)) OR raw bearish reversal OR (bearish momentum watch AND bullish entry confidence >= minimum entry score)
Calculation: Long stop = min(low on entry bar, entry price - ATR(ATR lookback) on entry bar * stop multiplier)
Calculation: Short stop = max(high on entry bar, entry price + ATR(ATR lookback) on entry bar * stop multiplier)
Long: Bullish entry
Short: Bearish entry
Long: long watch OR pullback long watch OR reversal long watch OR bullish momentum watch OR (bullish flow impulse AND close > VWAP AND NOT Bear trend)
Short: short watch OR pullback short watch OR reversal short watch OR bearish momentum watch OR (bearish flow impulse AND close < VWAP AND NOT Bull trend)
Long: long trigger confirmation
Short: short trigger confirmation
Long: Bull trend
Short: Bear trend
Long: delta strength >= 0
Short: delta strength < 0
Long: close location >= bullish flow location threshold
Short: close location <= bearish flow location threshold
Long: cumulative delta >= cumulative delta signal
Short: cumulative delta < cumulative delta signal
Long: bullish flow impulse OR bullish absorption
Short: bearish flow impulse OR bearish absorption
Long: long trap OR bullish impulse tag
Short: short trap OR bearish impulse tag
Exit: Long, low <= long stop
Exit: Short, high >= short stop
Exit: Long, long thesis invalid
Exit: Short, short thesis invalid