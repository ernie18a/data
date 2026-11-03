Calculation: Swing high/low = most recent pivot high/low: compare each bar’s high/low with the highest high/lowest low over the following lookback bars; update the pivot when the high/low from that many bars ago exceeds the corresponding range.
Calculation: Bullish/bearish order block = on a close crossing above the swing high/below the swing low, respectively, the range of the lowest low/highest high candle between that pivot and the crossing bar, using candle bodies or full wicks as configured; discard a bullish block when a candle body closes below it and a bearish block when a body closes above it.
Calculation: Bullish structure = close > latest swing high. Bearish structure = close < latest swing low.
Calculation: Near bullish/bearish order block = close is within the latest valid bullish/bearish block range.
Calculation: Fast and slow rate of change = (close − close N bars ago) / close N bars ago × 100, using a shorter N for fast and a longer N for slow.
Calculation: Bullish divergence = fast rate of change > slow rate of change AND fast rate of change > its prior-bar value AND close < prior-bar close. Bearish divergence = fast rate of change < slow rate of change AND fast rate of change < its prior-bar value AND close > prior-bar close.
Calculation: Bullish/bearish volume pressure = volume / 5-bar volume SMA > 1.2 AND close > open / close < open, respectively.
Calculation: Bullish/bearish imbalance = (close − low) > (high − close) × 1.5 / (high − close) > (close − low) × 1.5, respectively, AND volume > 5-bar volume SMA.
Calculation: Bullish/bearish acceleration = close momentum acceleration > 0 / < 0, respectively, AND close − prior-bar close > 0 / < 0, respectively; acceleration is the third difference of close.
Calculation: Early bullish/bearish signal = (corresponding divergence OR volume pressure OR imbalance) AND corresponding acceleration.
Calculation: Momentum strength = (close − close 5 bars ago) / 20-bar ATR. Strong bullish/bearish momentum = momentum strength > 0.3 / < −0.3, respectively.
Calculation: True bullish/bearish impulse = (corresponding early signal OR strong momentum) AND (corresponding structure OR divergence).
Calculation: Bullish/bearish sweep = low < bullish block bottom AND close > bullish block bottom / high > bearish block top AND close < bearish block top, respectively.
Calculation: Bullish/bearish rejection = close > open / close < open, respectively, AND the upper/lower wick exceeds the candle body range times the configured wick proportion and is at least the total candle range times the configured minimum wick proportion.
Calculation: High volume confirmation = GC1! volume exceeds its configured-length SMA times its configured multiplier OR exceeds that SMA by 3% OR rises for 3 bars.
Calculation: Trend = close > / < configured-length close SMA for bullish / bearish trend, respectively.
Calculation: Quant score = rounded sum of configured weights for: either-side structure; either-side price inside an order block; either-side block strength > 50 (block size / 3-bar ATR × 100, capped at 100; otherwise 3 points); either-side rejection; high volume confirmation; either-side sweep; trend aligned with same-side structure; UTC hour 2–23; absolute 5-bar price change > 14-bar ATR × 0.35; quick reversal between consecutive candle directions (+8); choppy range (current high−low / 14-bar ATR < 0.25) (−10); and ATR contribution. ATR contribution is 25 for either true impulse, else 18 for either early signal, else 12 if absolute momentum strength > 0.30, else 15 for either divergence, else 0; add 8 for either-side volume pressure.
Long: early bullish signal
Long: true bullish impulse
Long: bullish divergence
Long: bullish sweep
Long: Quant score ≥ configured signal threshold AND bullish structure AND near bullish order block AND close > configured-length close SMA
Short: early bearish signal
Short: true bearish impulse
Short: bearish divergence
Short: bearish sweep
Short: Quant score ≥ configured signal threshold AND bearish structure AND near bearish order block AND close < configured-length close SMA