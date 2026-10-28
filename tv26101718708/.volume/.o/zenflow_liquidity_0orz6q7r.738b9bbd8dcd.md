Calculation: Fast EMA = exponential moving average of close with a shorter lookback than the slow EMA
Calculation: Slow EMA = exponential moving average of close
Calculation: Volume average = simple moving average of volume
Calculation: High-volume bar = volume > volume average × volume multiplier
Calculation: ATR = average true range
Calculation: VWAP = volume-weighted average price
Calculation: Prior-period high/low = high/low of the last completed daily bar
Calculation: Swing liquidity high/low = highest high / lowest low over a lookback, excluding the current bar
Calculation: Close location = (close − low) / max(high − low, minimum price increment)
Calculation: Delta proxy = volume × (2 × close location − 1)
Calculation: Delta strength = delta proxy / EMA of absolute delta proxy over a longer lookback
Calculation: Cumulative delta proxy = cumulative sum of delta proxy
Calculation: Bullish order-flow impulse = delta strength ≥ threshold AND cumulative delta proxy ≥ its EMA AND close location ≥ 0.60
Calculation: Bearish order-flow impulse = delta strength ≤ −threshold AND cumulative delta proxy ≤ its EMA AND close location ≤ 0.40
Calculation: Bullish absorption = high-volume bar AND lower wick > candle body AND close location ≥ 0.55
Calculation: Bearish absorption = high-volume bar AND upper wick > candle body AND close location ≤ 0.45
Calculation: Long trap = low breaks the prior lookback low AND close recovers above it AND delta strength < 0 AND close location ≥ 0.55
Calculation: Short trap = high breaks the prior lookback high AND close falls below it AND delta strength > 0 AND close location ≤ 0.45
Calculation: Bullish impulse tag = candle body ≥ 1.4 × EMA of candle body AND bullish order-flow impulse AND close > prior high
Calculation: Bearish impulse tag = candle body ≥ 1.4 × EMA of candle body AND bearish order-flow impulse AND close < prior low
Calculation: Buy-side sweep = high > prior-period high AND close < prior-period high, OR high > swing liquidity high AND close < swing liquidity high
Calculation: Sell-side sweep = low < prior-period low AND close > prior-period low, OR low < swing liquidity low AND close > swing liquidity low
Calculation: Bull trend = close > slow EMA AND fast EMA > slow EMA
Calculation: Bear trend = close < slow EMA AND fast EMA < slow EMA
Calculation: VWAP reclaim/rejection = close crosses above/below VWAP from the other side
Calculation: Structure break = close above/below the highest high/lowest low over the applicable lookback, excluding the current bar
Calculation: Near EMA = distance from close to either EMA ≤ ATR × proximity threshold
Calculation: Near VWAP = distance from close to VWAP ≤ ATR × proximity threshold
Calculation: Rejection candle = lower/upper wick ≥ candle body × wick ratio, close location ≥ 0.60/≤ 0.40, and close >/< open
Calculation: Long/short thesis invalid = invalidation enabled AND (opposite VWAP/EMA regime flip OR opposite order-flow impulse/absorption/trap) AND NOT matching thesis reset; bullish regime flip is close > VWAP AND fast EMA > slow EMA AND close > fast EMA; bearish regime flip is the inverse; bullish/bearish thesis reset is matching trend AND close above/below VWAP AND (matching order-flow impulse OR trigger structure break OR general structure break)
Long: bullish trend AND (close above VWAP OR VWAP filter disabled) AND (volume filter disabled OR high-volume bar) AND general structure break up AND order-flow filter passes or is disabled AND session filter passes or is disabled AND (trigger requirement disabled OR long trigger confirmed) AND NOT long thesis invalid
Long: (bullish trend AND close > VWAP AND near EMA AND pullback structure break up AND pullback volume requirement passes AND order-flow filter passes or is disabled AND session filter passes or is disabled AND trigger requirement passes AND NOT long thesis invalid) OR (lower-timeframe execution enabled AND bullish trend AND close > VWAP AND near EMA AND trigger structure break up AND NOT long thesis invalid AND entry confidence ≥ threshold)
Long: close < VWAP AND VWAP reclaim AND fast EMA crosses above slow EMA AND reversal structure break up AND reversal volume requirement passes AND order-flow filter passes or is disabled AND session filter passes or is disabled AND trigger requirement passes AND NOT long thesis invalid
Long: bullish trend AND close > VWAP AND session filter passes or is disabled AND (bullish order-flow impulse OR general structure break up OR trigger structure break up) AND NOT long thesis invalid AND entry confidence ≥ threshold
Long: session filter passes or is disabled AND (bullish trend AND (near EMA OR near VWAP) OR bullish trend AND close > VWAP AND near EMA OR close < VWAP AND fast EMA crosses above slow EMA) AND (lower-wick rejection candle OR trigger structure break up OR long trap OR bullish impulse tag)
Long: sell-side sweep OR bullish absorption
Short: bearish trend AND (close below VWAP OR VWAP filter disabled) AND (volume filter disabled OR high-volume bar) AND general structure break down AND order-flow filter passes or is disabled AND session filter passes or is disabled AND (trigger requirement disabled OR short trigger confirmed) AND NOT short thesis invalid
Short: (bearish trend AND close < VWAP AND near EMA AND pullback structure break down AND pullback volume requirement passes AND order-flow filter passes or is disabled AND session filter passes or is disabled AND trigger requirement passes AND NOT short thesis invalid) OR (lower-timeframe execution enabled AND bearish trend AND close < VWAP AND near EMA AND trigger structure break down AND NOT short thesis invalid AND entry confidence ≥ threshold)
Short: close > VWAP AND VWAP rejection AND fast EMA crosses below slow EMA AND reversal structure break down AND reversal volume requirement passes AND order-flow filter passes or is disabled AND session filter passes or is disabled AND trigger requirement passes AND NOT short thesis invalid
Short: bearish trend AND close < VWAP AND session filter passes or is disabled AND (bearish order-flow impulse OR general structure break down OR trigger structure break down) AND NOT short thesis invalid AND entry confidence ≥ threshold
Short: session filter passes or is disabled AND (bearish trend AND (near EMA OR near VWAP) OR bearish trend AND close < VWAP AND near EMA OR close > VWAP AND fast EMA crosses below slow EMA) AND (upper-wick rejection candle OR trigger structure break down OR short trap OR bearish impulse tag)
Short: buy-side sweep OR bearish absorption
Exit: long, low ≤ entry stop OR long thesis invalid; entry stop is the lower of entry-bar low and entry price − ATR × stop multiplier
Exit: short, high ≥ entry stop OR short thesis invalid; entry stop is the higher of entry-bar high and entry price + ATR × stop multiplier