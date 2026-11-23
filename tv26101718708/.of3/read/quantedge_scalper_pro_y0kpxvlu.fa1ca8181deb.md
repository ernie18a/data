Calculation: Bullish trend alignment = close > EMA(close, fast lookback) AND close > EMA(close, slow lookback) AND EMA(close, fast lookback) > EMA(close, slow lookback)
Calculation: Bearish trend alignment = close < EMA(close, fast lookback) AND close < EMA(close, slow lookback) AND EMA(close, fast lookback) < EMA(close, slow lookback)
Calculation: Volume surge = volume > SMA(volume, volume lookback) × volume multiplier
Calculation: Volatility in range = ATR(ATR lookback) > SMA(ATR(ATR lookback), ATR lookback) × minimum volatility multiplier AND ATR(ATR lookback) < SMA(ATR(ATR lookback), ATR lookback) × maximum volatility multiplier
Calculation: Trend strength = ADX(high, low, close, ADX lookback) > ADX threshold AND abs(EMA(close, fast lookback) − EMA(close, slow lookback)) >= ATR(ATR lookback) × EMA compression multiplier
Calculation: Bullish sweep = liquidity-sweep detection enabled AND low < lowest(low, structure lookback)[1] AND close > lowest(low, structure lookback)[1] AND close > open
Calculation: Bearish sweep = liquidity-sweep detection enabled AND high > highest(high, structure lookback)[1] AND close < highest(high, structure lookback)[1] AND close < open
Calculation: Bullish break of structure = close > PivotHigh(high, structure lookback, structure lookback)[structure lookback]
Calculation: Bearish break of structure = close < PivotLow(low, structure lookback, structure lookback)[structure lookback]
Calculation: Bullish fair value gap = fair-value-gap detection enabled AND low > high[2] AND close[1] > high[2]
Calculation: Bearish fair value gap = fair-value-gap detection enabled AND high < low[2] AND close[1] < low[2]
Calculation: Bullish breakout = close > highest(high, range lookback)[1] AND Volume surge AND abs(close − open) > SMA(abs(close − open), candle-body lookback)
Calculation: Bearish breakout = close < lowest(low, range lookback)[1] AND Volume surge AND abs(close − open) > SMA(abs(close − open), candle-body lookback)
Calculation: Confirmed bullish breakout = Bullish breakout AND NOT (fake-breakout filter enabled AND Bullish breakout[1] AND close < highest(high, range lookback)[2])
Calculation: Confirmed bearish breakout = Bearish breakout AND NOT (fake-breakout filter enabled AND Bearish breakout[1] AND close > lowest(low, range lookback)[2])
Calculation: Higher-timeframe bullish bias = EMA(close, fast lookback) > EMA(close, slow lookback), evaluated on T1 bars and sampled on chart bars with lookahead_off, using the forming T1 bar in real time
Calculation: Higher-timeframe bearish bias = EMA(close, fast lookback) < EMA(close, slow lookback), evaluated on T1 bars and sampled on chart bars with lookahead_off, using the forming T1 bar in real time
Calculation: Long score = count of true conditions among {Bullish trend alignment; VWAP filter disabled OR close > VWAP(hlc3); false; Volume surge; Volatility in range; Trend strength; RSI filter disabled OR RSI(close, RSI lookback) > long RSI threshold; Bullish sweep OR Confirmed bullish breakout OR Bullish break of structure; close > high[1]; higher-timeframe filter disabled OR Higher-timeframe bullish bias; Bullish fair value gap[1] OR (order-block detection enabled AND close[1] < open[1] AND close > open AND abs(close − open) > SMA(abs(close − open), candle-body lookback) × order-block impulse multiplier)}
Calculation: Short score = count of true conditions among {Bearish trend alignment; VWAP filter disabled OR close < VWAP(hlc3); false; Volume surge; Volatility in range; Trend strength; RSI filter disabled OR RSI(close, RSI lookback) < short RSI threshold; Bearish sweep OR Confirmed bearish breakout OR Bearish break of structure; close < low[1]; higher-timeframe filter disabled OR Higher-timeframe bearish bias; Bearish fair value gap[1] OR (order-block detection enabled AND close[1] > open[1] AND close < open AND abs(close − open) > SMA(abs(close − open), candle-body lookback) × order-block impulse multiplier)}
Calculation: Long candidate = session filter disabled OR current chart bar is in the London session OR current chart bar is in the New York session; AND bars since the last final long signal, with its tracker initialized to zero, >= cooldown bars; AND (Long score >= strong score threshold OR (medium signals enabled AND Long score >= medium score threshold AND Long score < strong score threshold) OR (weak signals enabled AND Long score >= weak score threshold AND Long score < medium score threshold))
Calculation: Short candidate = session filter disabled OR current chart bar is in the London session OR current chart bar is in the New York session; AND bars since the last final short signal, with its tracker initialized to zero, >= cooldown bars; AND (Short score >= strong score threshold OR (medium signals enabled AND Short score >= medium score threshold AND Short score < strong score threshold) OR (weak signals enabled AND Short score >= weak score threshold AND Short score < medium score threshold))
Long: Bullish trend alignment
Short: Bearish trend alignment
Long: Bullish sweep
Short: Bearish sweep
Long: Bullish break of structure
Short: Bearish break of structure
Long: Bullish fair value gap
Short: Bearish fair value gap
Long: Long score >= strong score threshold
Long: Long score >= medium score threshold AND Long score < strong score threshold
Long: Long score >= weak score threshold AND Long score < medium score threshold
Short: Short score >= strong score threshold
Short: Short score >= medium score threshold AND Short score < strong score threshold
Short: Short score >= weak score threshold AND Short score < medium score threshold
Long: Long candidate AND NOT Short candidate
Short: Short candidate AND NOT Long candidate