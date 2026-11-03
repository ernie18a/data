Calculation: Chart ATR = average true range on the chart timeframe.
Calculation: Reference swing high/low = highest high / lowest low over the configured lookback of completed chart bars before the current bar.
Calculation: Bar delta = volume × ((close − low) − (high − close)) / (high − low), or zero if high = low; average absolute delta = configured moving average of absolute bar delta.
Calculation: Bullish/ bearish trap score = clamp to [0, 100] the weighted sum of the directional conditions below, less the configured overlap penalty when that direction's sweep and reclaim both occur without its absorption or delta-price divergence condition:
- Sweep: bullish, low < reference swing low and close > reference swing low; bearish, high > reference swing high and close < reference swing high. Also require sweep distance ≤ configured ATR multiple and directional wick / candle range ≥ configured minimum.
- Reclaim: within the configured bar window after price broke the reference swing low/high, close > reference swing low / close < reference swing high, respectively.
- Extreme delta: bullish, negative delta magnitude ≥ configured multiple of average absolute delta; bearish, positive delta ≥ that multiple.
- Volume expansion: volume ≥ configured multiple of its moving average.
- Absorption: directional extreme delta and volume expansion both hold, and adverse candle-body progress ≤ configured ATR multiple.
- Delta-price divergence: bullish, bar delta ≤ the prior lookback's lowest delta and close > the prior lookback's lowest close; bearish, bar delta ≥ the prior lookback's highest delta and close < the prior lookback's highest close.
- Large-trade absorption: volume ≥ configured larger multiple of its moving average, adverse candle-body progress ≤ configured ATR multiple, and directional wick / candle range ≥ configured minimum.
- Higher-timeframe proximity: minimum distance from current high/low to the chart reference swings, prior daily/weekly highs/lows, or completed higher-timeframe high/low ≤ configured multiple of completed higher-timeframe ATR. Use the last completed higher-timeframe bar.
- VWAP rejection: bearish, high crosses session VWAP or its upper one-standard-deviation band and close is below that level; bullish, low crosses session VWAP or its lower one-standard-deviation band and close is above that level. Standard deviation uses chart closes.
- Confirmation: bearish, close < prior chart low OR (close < reference swing high and bar delta ≤ 0); bullish, close > prior chart high OR (close > reference swing low and bar delta ≥ 0).
- Exhaustion: volume declines for three consecutive chart bars and current high − low < configured ATR multiple.
Calculation: Stop level = for a long, sweep low − configured ATR multiple; for a short, sweep high + configured ATR multiple. R = absolute distance from entry price to stop level.
Long: bullish trap score ≥ configured minimum entry threshold.
Short: bearish trap score ≥ configured minimum entry threshold.
Exit: long, low ≤ stop level OR high ≥ entry price + R OR high ≥ session VWAP OR high ≥ range midpoint OR high ≥ opposing value area OR high ≥ previous-week high OR high ≥ entry price + configured R multiple.
Exit: short, high ≥ stop level OR low ≤ entry price − R OR low ≤ session VWAP OR low ≤ range midpoint OR low ≤ opposing value area OR low ≤ previous-week low OR low ≤ entry price − configured R multiple.