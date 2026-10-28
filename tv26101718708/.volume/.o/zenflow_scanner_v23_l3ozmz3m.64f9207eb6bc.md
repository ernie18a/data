Calculation: Fast EMA = exponential moving average of close with a shorter lookback than the slow EMA
Calculation: Slow EMA = exponential moving average of close with a longer lookback than the fast EMA
Calculation: VWAP = volume-weighted average price
Calculation: ATR = average true range
Calculation: High volume = volume > volume moving average × volume multiplier
Calculation: Close location = (close − low) / max(high − low, minimum price increment)
Calculation: Delta proxy = volume × (2 × close location − 1)
Calculation: Delta strength = delta proxy / exponential moving average of absolute delta proxy
Calculation: Cumulative delta = cumulative sum of delta proxy
Calculation: Bullish order-flow impulse = delta strength ≥ threshold AND cumulative delta ≥ its EMA AND close location ≥ 0.60
Calculation: Bearish order-flow impulse = delta strength ≤ −threshold AND cumulative delta ≤ its EMA AND close location ≤ 0.40
Calculation: Bullish absorption = high volume AND lower wick > candle body AND close location ≥ 0.55
Calculation: Bearish absorption = high volume AND upper wick > candle body AND close location ≤ 0.45
Calculation: Long trap = low < prior lookback lowest low AND close > that lowest low AND delta strength < 0 AND close location ≥ 0.55
Calculation: Short trap = high > prior lookback highest high AND close < that highest high AND delta strength > 0 AND close location ≤ 0.45
Calculation: Bullish impulse tag = candle body ≥ 1.4 × its EMA AND bullish order-flow impulse AND close > prior high
Calculation: Bearish impulse tag = candle body ≥ 1.4 × its EMA AND bearish order-flow impulse AND close < prior low
Calculation: Bull trend = close > slow EMA AND fast EMA > slow EMA
Calculation: Bear trend = close < slow EMA AND fast EMA < slow EMA
Calculation: VWAP reclaim = close > VWAP AND prior close ≤ prior VWAP
Calculation: VWAP rejection = close < VWAP AND prior close ≥ prior VWAP
Calculation: Near EMA = absolute distance from close to either EMA ≤ ATR × proximity multiplier
Calculation: Break high/low = close > prior lookback highest high / close < prior lookback lowest low
Calculation: Bullish rejection candle = lower wick ≥ candle body × wick-ratio threshold AND close location ≥ 0.60 AND close > open
Calculation: Bearish rejection candle = upper wick ≥ candle body × wick-ratio threshold AND close location ≤ 0.40 AND close < open
Calculation: Bullish regime flip = close > VWAP AND fast EMA > slow EMA AND close > fast EMA
Calculation: Bearish regime flip = close < VWAP AND fast EMA < slow EMA AND close < fast EMA
Calculation: Long invalidation = invalidation enabled AND ((VWAP-flip invalidation enabled AND bearish regime flip) OR (order-flow invalidation enabled AND (bearish order-flow impulse OR bearish absorption OR short trap))) AND NOT (bull trend AND close > VWAP AND (bullish order-flow impulse OR trigger break high OR break high)
Calculation: Short invalidation = invalidation enabled AND ((VWAP-flip invalidation enabled AND bullish regime flip) OR (order-flow invalidation enabled AND (bullish order-flow impulse OR bullish absorption OR long trap))) AND NOT (bear trend AND close < VWAP AND (bearish order-flow impulse OR trigger break low OR break low))
Calculation: Trigger break high/low = close > prior trigger-lookback highest high / close < prior trigger-lookback lowest low
Calculation: Long trigger = session allowed AND (long watch OR pullback-long watch OR reversal-long watch) AND (bullish rejection candle OR trigger break high OR long trap OR bullish impulse tag)
Calculation: Short trigger = session allowed AND (short watch OR pullback-short watch OR reversal-short watch) AND (bearish rejection candle OR trigger break low OR short trap OR bearish impulse tag)
Calculation: Long watch = bull trend AND session allowed AND (near EMA OR within ATR-based VWAP decision zone)
Calculation: Short watch = bear trend AND session allowed AND (near EMA OR within ATR-based VWAP decision zone)
Calculation: Pullback-long watch = bull trend AND close > VWAP AND near EMA AND session allowed
Calculation: Pullback-short watch = bear trend AND close < VWAP AND near EMA AND session allowed
Calculation: Reversal-long watch = close < VWAP AND fast EMA crosses above slow EMA AND session allowed
Calculation: Reversal-short watch = close > VWAP AND fast EMA crosses below slow EMA AND session allowed
Calculation: Momentum-long watch = momentum state enabled AND bull trend AND close > VWAP AND session allowed AND (bullish order-flow impulse OR break high OR trigger break high) AND NOT long invalidation
Calculation: Momentum-short watch = momentum state enabled AND bear trend AND close < VWAP AND session allowed AND (bearish order-flow impulse OR break low OR trigger break low) AND NOT short invalidation
Calculation: Long entry confidence = clamp to 0–100 of the highest long or short trend, pullback, and reversal score, minus conflict penalties for opposing trend, VWAP location, order flow, absent modifier, and required-but-absent trigger
Calculation: Short entry confidence = same confidence calculation, using the highest of the same directional scores
Long: (continuation enabled AND bull trend AND (VWAP filter disabled OR VWAP reclaim) AND (volume filter disabled OR high volume) AND break high AND (order-flow filter disabled OR bullish order-flow impulse OR bullish absorption OR long trap) AND session allowed AND (trigger not required OR long trigger) AND NOT long invalidation) OR (pullback enabled AND ((bull trend AND close > VWAP AND near EMA AND pullback break high AND (pullback volume not required OR high volume) AND (order-flow filter disabled OR bullish order-flow impulse OR bullish absorption OR long trap) AND session allowed AND (trigger not required OR long trigger) AND NOT long invalidation) OR (lower-timeframe execution enabled AND pullback-long watch AND bull trend AND close > VWAP AND near EMA AND trigger break high AND NOT long invalidation AND long entry confidence ≥ entry threshold))) OR (reversal enabled AND close < VWAP AND VWAP reclaim AND fast EMA crosses above slow EMA AND reversal break high AND (reversal volume not required OR high volume) AND (order-flow filter disabled OR bullish order-flow impulse OR bullish absorption OR long trap) AND session allowed AND (trigger not required OR long trigger) AND NOT long invalidation) OR (momentum state enabled AND momentum-long watch AND long entry confidence ≥ entry threshold) OR long trigger OR bullish absorption OR long watch OR pullback-long watch OR reversal-long watch OR momentum-long watch
Short: (continuation enabled AND bear trend AND (VWAP filter disabled OR VWAP rejection) AND (volume filter disabled OR high volume) AND break low AND (order-flow filter disabled OR bearish order-flow impulse OR bearish absorption OR short trap) AND session allowed AND (trigger not required OR short trigger) AND NOT short invalidation) OR (pullback enabled AND ((bear trend AND close < VWAP AND near EMA AND pullback break low AND (pullback volume not required OR high volume) AND (order-flow filter disabled OR bearish order-flow impulse OR bearish absorption OR short trap) AND session allowed AND (trigger not required OR short trigger) AND NOT short invalidation) OR (lower-timeframe execution enabled AND pullback-short watch AND bear trend AND close < VWAP AND near EMA AND trigger break low AND NOT short invalidation AND short entry confidence ≥ entry threshold))) OR (reversal enabled AND close > VWAP AND VWAP rejection AND fast EMA crosses below slow EMA AND reversal break low AND (reversal volume not required OR high volume) AND (order-flow filter disabled OR bearish order-flow impulse OR bearish absorption OR short trap) AND session allowed AND (trigger not required OR short trigger) AND NOT short invalidation) OR (momentum state enabled AND momentum-short watch AND short entry confidence ≥ entry threshold) OR short trigger OR bearish absorption OR short watch OR pullback-short watch OR reversal-short watch OR momentum-short watch
Exit: Long, low ≤ active stop OR long invalidation
Exit: Short, high ≥ active stop OR short invalidation