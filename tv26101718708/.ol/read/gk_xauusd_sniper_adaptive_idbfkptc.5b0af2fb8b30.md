Calculation: Main ZLEMA = EMA(close + (close - close[ floor((lookback - 1) / 2) ]), lookback); its lookback is longer than the Fast ZLEMA lookback
Calculation: Fast ZLEMA = EMA(close + (close - close[ floor((lookback - 1) / 2) ]), lookback)
Calculation: Long-term EMA bias = EMA(close, lookback)
Calculation: Main ZLEMA slope = Main ZLEMA - its value from a longer lookback ago
Calculation: Fast ZLEMA slope = Fast ZLEMA - its previous-bar value
Calculation: Bullish trend = close > Main ZLEMA AND Fast ZLEMA > Main ZLEMA AND Main ZLEMA slope > ATR × slope threshold
Calculation: Bearish trend = close < Main ZLEMA AND Fast ZLEMA < Main ZLEMA AND Main ZLEMA slope < -ATR × slope threshold
Calculation: Bullish separation = Fast ZLEMA > Main ZLEMA AND abs(Fast ZLEMA - Main ZLEMA) > ATR × separation threshold
Calculation: Bearish separation = Fast ZLEMA < Main ZLEMA AND abs(Fast ZLEMA - Main ZLEMA) > ATR × separation threshold
Calculation: Strong body = abs(close - open) > ATR × minimum body threshold
Calculation: Bullish candle = close > open AND close >= high - (high - low) × 0.35
Calculation: Bearish candle = close < open AND close <= low + (high - low) × 0.35
Calculation: Bullish expansion = close > previous high AND Bullish candle AND Strong body
Calculation: Bearish expansion = close < previous low AND Bearish candle AND Strong body
Calculation: Bullish structure break = close > the highest high over the structure lookback, excluding the current bar OR high > that level
Calculation: Bearish structure break = close < the lowest low over the structure lookback, excluding the current bar OR low < that level
Calculation: Recent bullish pullback = at least one bar in the pullback window has low <= Fast ZLEMA OR low <= Main ZLEMA OR close <= Fast ZLEMA
Calculation: Recent bearish pullback = at least one bar in the pullback window has high >= Fast ZLEMA OR high >= Main ZLEMA OR close >= Fast ZLEMA
Calculation: Bullish reclaim = close crosses above Fast ZLEMA OR (close > Fast ZLEMA AND previous close <= previous Fast ZLEMA) OR Fast ZLEMA crosses above Main ZLEMA
Calculation: Bearish rejection = close crosses below Fast ZLEMA OR (close < Fast ZLEMA AND previous close >= previous Fast ZLEMA) OR Fast ZLEMA crosses below Main ZLEMA
Calculation: Not choppy = highest high minus lowest low over the last 5 bars > ATR × chop threshold
Calculation: Within stretch limit = abs(close - Main ZLEMA) <= ATR × maximum stretch threshold
Calculation: Bullish momentum = Fast ZLEMA slope > 0 AND close > previous close
Calculation: Bearish momentum = Fast ZLEMA slope < 0 AND close < previous close
Calculation: Bull score = count of these true conditions: Bullish trend; Bullish separation; close > long-term EMA bias; Bullish expansion; Bullish structure break; Recent bullish pullback AND Bullish reclaim; Not choppy; Within stretch limit; Bullish momentum
Calculation: Bear score = count of these true conditions: Bearish trend; Bearish separation; close < long-term EMA bias; Bearish expansion; Bearish structure break; Recent bearish pullback AND Bearish rejection; Not choppy; Within stretch limit; Bearish momentum
Calculation: Bull raw signal = (Bullish trend AND Bullish separation AND Bullish expansion AND close > long-term EMA bias AND Bullish momentum AND Not choppy) OR (Bullish trend AND Recent bullish pullback AND Bullish reclaim AND Bullish candle AND Strong body AND Within stretch limit AND Bullish momentum AND Not choppy) OR (Bull score >= score threshold)
Calculation: Bear raw signal = (Bearish trend AND Bearish separation AND Bearish expansion AND close < long-term EMA bias AND Bearish momentum AND Not choppy) OR (Bearish trend AND Recent bearish pullback AND Bearish rejection AND Bearish candle AND Strong body AND Within stretch limit AND Bearish momentum AND Not choppy) OR (Bear score >= score threshold)
Calculation: Trend-print gate = direction starts neutral; set it bullish on the first bullish trend, bearish on the first bearish trend; change it to bullish when Bullish trend AND Bullish momentum and direction is not bullish, or bearish when Bearish trend AND Bearish momentum and direction is not bearish. Reset the printed flag on either change. A side is allowed when direction matches that side OR its trend condition is true, and the printed flag is false. Set the printed flag true after either confirmed entry signal.
Long: Bull raw signal AND bullish side allowed by Trend-print gate AND close > Main ZLEMA AND Bullish candle
Short: Bear raw signal AND bearish side allowed by Trend-print gate AND close < Main ZLEMA AND Bearish candle
Exit: Long position, bar is after the entry bar AND target has not already been reached AND high >= entry price + target distance
Exit: Short position, bar is after the entry bar AND target has not already been reached AND low <= entry price - target distance