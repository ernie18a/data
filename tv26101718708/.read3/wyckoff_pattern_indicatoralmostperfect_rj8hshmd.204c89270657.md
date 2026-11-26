Calculation: Range high = highest(high, base window)
Calculation: Range low = lowest(low, base window)
Calculation: Price position = (close - Range low) / max(Range high - Range low, ATR(ATR length) * ATR fraction)
Calculation: Average volume = SMA(volume, base window)
Calculation: High-volume bar = volume > Average volume * volume multiple
Calculation: Low-volume bar = volume < Average volume * low-volume fraction
Calculation: Relative volatility = STDEV(close, volatility window) / SMA(close, volatility window)
Calculation: In range = Relative volatility < SMA(Relative volatility, base window) * range tightness fraction
Calculation: Mid EMA = EMA(close, mid EMA length)
Calculation: Short-term uptrend = EMA(close, short EMA length) > Mid EMA
Calculation: Long-term uptrend = Mid EMA > EMA(close, long EMA length)
Calculation: RSI = RSI(close, RSI length)
Calculation: MACD hist = MACD histogram(close, fast EMA length, slow EMA length, signal EMA length)
Calculation: Accumulation score = major weight * (Price position < lower position bound) + minor weight * (NOT Long-term uptrend) + major weight * (In range) + minor weight * (Low-volume bar AND In range) + minor weight * (RSI < RSI midline) + minor weight * (MACD hist > MACD hist[MACD slope lag])
Calculation: Distribution score = major weight * (Price position > upper position bound) + minor weight * (Long-term uptrend) + major weight * (In range) + minor weight * (Low-volume bar AND In range) + minor weight * (RSI > RSI midline) + minor weight * (MACD hist < MACD hist[MACD slope lag])
Calculation: Accumulation run length = IF (Accumulation score >= score threshold AND Accumulation score > Distribution score) THEN Accumulation run length[1] + 1 ELSE 0
Calculation: Distribution run length = IF (Distribution score >= score threshold AND Distribution score > Accumulation score) THEN Distribution run length[1] + 1 ELSE 0
Calculation: Accumulation state = Accumulation run length >= confirmation bars
Calculation: Distribution state = Distribution run length >= confirmation bars
Calculation: Prior structure low = lowest(low, structure window)[1]
Calculation: Prior structure high = highest(high, structure window)[1]
Calculation: Short average volume = SMA(volume, short volume window)
Calculation: Spring event = close > open AND low < Prior structure low AND close > Prior structure low AND volume > Short average volume
Calculation: Upthrust event = close < open AND high > Prior structure high AND close < Prior structure high AND volume > Short average volume
Calculation: SOS volume average = SMA(volume, SOS volume window)
Calculation: SOS event = close > open AND close > highest(close, SOS price window)[1] AND volume > SOS volume average AND MACD hist > 0
Calculation: SOW event = close < open AND close < lowest(close, SOS price window)[1] AND volume > SOS volume average AND MACD hist < 0
Calculation: LPS event = close > open AND NOT High-volume bar AND Short-term uptrend AND Price position > LPS position floor
Calculation: LPSY event = close < open AND NOT High-volume bar AND NOT Short-term uptrend AND Price position < LPSY position ceiling
Calculation: Accumulation phase = IF NOT Accumulation state THEN 0 ELSE Accumulation phase[1] passed in order through: 0 becomes 1; 1 becomes 2 if In range; 2 becomes 3 if Spring event; 3 becomes 4 if SOS event; 4 becomes 5 if Short-term uptrend AND NOT In range
Calculation: Distribution phase = IF NOT Distribution state THEN 0 ELSE Distribution phase[1] passed in order through: 0 becomes 1; 1 becomes 2 if In range; 2 becomes 3 if Upthrust event; 3 becomes 4 if SOW event; 4 becomes 5 if NOT Short-term uptrend AND NOT In range
Calculation: Buy condition = (Accumulation state AND (Accumulation phase = 3 OR Accumulation phase = 4 OR LPS event)) OR (NOT Distribution state AND Spring event)
Calculation: Sell condition = (Distribution state AND (Distribution phase = 3 OR Distribution phase = 4 OR LPSY event)) OR (NOT Accumulation state AND Upthrust event)
Long: Buy condition AND NOT Buy condition[1]
Long: Spring event
Long: Accumulation state AND LPS event
Long: SOS event
Long: close < open AND High-volume bar AND (high - close) / max(high - low, small positive constant) > wide-bar fraction AND close <= Range low * SC proximity factor
Short: Sell condition AND NOT Sell condition[1]
Short: Upthrust event
Short: Distribution state AND LPSY event
Short: SOW event
Short: close > open AND High-volume bar AND (close - low) / max(high - low, small positive constant) > wide-bar fraction AND close >= Range high * BC proximity factor