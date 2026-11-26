Calculation: Candle body = abs(close - open)
Calculation: Candle range = max(high - low, instrument minimum price increment)
Calculation: Upper wick = high - max(open, close)
Calculation: Lower wick = min(open, close) - low
Calculation: Average candle body = SMA(Candle body, average-body lookback)
Calculation: Bullish RSI divergence = RSI(close, RSI length) < RSI oversold threshold AND low < the stored low from the bar when RSI most recently made a running low AND RSI(close, RSI length) > that stored RSI; update the stored low and RSI when RSI makes a new running low, and reset the reference when its bar is more than the divergence lookback ago
Calculation: Bearish RSI divergence = RSI(close, RSI length) > RSI overbought threshold AND high > the stored high from the bar when RSI most recently made a running high AND RSI(close, RSI length) < that stored RSI; update the stored high and RSI when RSI makes a new running high, and reset the reference when its bar is more than the divergence lookback ago
Calculation: Bullish MFI divergence = MFI(high, low, close, volume, MFI length) < MFI oversold threshold AND low < the stored low from the bar when MFI most recently made a running low AND MFI > that stored MFI; update the stored low and MFI when MFI makes a new running low, and reset the reference when its bar is more than the divergence lookback ago
Calculation: Bearish MFI divergence = MFI(high, low, close, volume, MFI length) > MFI overbought threshold AND high > the stored high from the bar when MFI most recently made a running high AND MFI < that stored MFI; update the stored high and MFI when MFI makes a new running high, and reset the reference when its bar is more than the divergence lookback ago
Calculation: Strong bullish RSI divergence = Bullish RSI divergence AND the rolling count of Bullish RSI divergence over the divergence lookback >= divergence event-count threshold
Calculation: Strong bearish RSI divergence = Bearish RSI divergence AND the rolling count of Bearish RSI divergence over the divergence lookback >= divergence event-count threshold
Calculation: Bullish engulfing = close > open AND close[1] < open[1] AND close > open[1] AND open < close[1] AND Candle body > Candle body[1]
Calculation: Bearish engulfing = close < open AND close[1] > open[1] AND close < open[1] AND open > close[1] AND Candle body > Candle body[1]
Calculation: Bullish pin = Lower wick >= Candle body * long-wick-to-body ratio AND Upper wick <= Candle body * pin short-wick-to-body ratio AND close > low + Candle range * close-position fraction
Calculation: Bearish pin = Upper wick >= Candle body * long-wick-to-body ratio AND Lower wick <= Candle body * pin short-wick-to-body ratio AND close < high - Candle range * close-position fraction
Calculation: Hammer = close[1] < close[trend lookback] AND Lower wick >= Candle body * long-wick-to-body ratio AND Upper wick <= Candle body * hammer short-wick-to-body ratio AND close > low + Candle range * close-position fraction
Calculation: Shooting star = close[1] > close[trend lookback] AND Upper wick >= Candle body * long-wick-to-body ratio AND Lower wick <= Candle body * hammer short-wick-to-body ratio AND close < high - Candle range * close-position fraction
Calculation: Morning star = close[2] < open[2] AND abs(close[2] - open[2]) > Average candle body[2] * star long-body ratio AND abs(close[1] - open[1]) < abs(close[2] - open[2]) * star middle-body ratio AND close > open AND close > (open[2] + close[2]) / 2
Calculation: Evening star = close[2] > open[2] AND abs(close[2] - open[2]) > Average candle body[2] * star long-body ratio AND abs(close[1] - open[1]) < abs(close[2] - open[2]) * star middle-body ratio AND close < open AND close < (open[2] + close[2]) / 2
Calculation: Bullish inside-bar breakout = high[1] < high[2] AND low[1] > low[2] AND close > high[1]
Calculation: Bearish inside-bar breakout = high[1] < high[2] AND low[1] > low[2] AND close < low[1]
Calculation: Outside bar = high > high[1] AND low < low[1] AND Candle body > Candle body[1]
Calculation: Bullish marubozu = Candle body / Candle range >= marubozu body-range fraction AND Upper wick <= Candle range * marubozu wick-range fraction AND Lower wick <= Candle range * marubozu wick-range fraction AND close > open
Calculation: Bearish marubozu = Candle body / Candle range >= marubozu body-range fraction AND Upper wick <= Candle range * marubozu wick-range fraction AND Lower wick <= Candle range * marubozu wick-range fraction AND close < open
Calculation: Bullish candle pattern = Bullish engulfing OR Bullish pin OR Hammer OR Morning star OR Bullish inside-bar breakout OR (Outside bar AND close > open) OR Bullish marubozu
Calculation: Bearish candle pattern = Bearish engulfing OR Bearish pin OR Shooting star OR Evening star OR Bearish inside-bar breakout OR (Outside bar AND close < open) OR Bearish marubozu
Calculation: Bullish candle signal = candlestick combinations enabled AND ((engulfing enabled AND Bullish engulfing) OR (pin bars enabled AND (Bullish pin OR Hammer)) OR (stars enabled AND Morning star) OR (inside bars enabled AND Bullish inside-bar breakout) OR (outside bars enabled AND Outside bar AND close > open) OR (marubozu enabled AND Bullish marubozu))
Calculation: Bearish candle signal = candlestick combinations enabled AND ((engulfing enabled AND Bearish engulfing) OR (pin bars enabled AND (Bearish pin OR Shooting star)) OR (stars enabled AND Evening star) OR (inside bars enabled AND Bearish inside-bar breakout) OR (outside bars enabled AND Outside bar AND close < open) OR (marubozu enabled AND Bearish marubozu))
Calculation: For each configured timeframe T1, T2, T3, and T4, T RSI = RSI(close, RSI length) evaluated on T bars and sampled on chart bars using the current T bar in realtime and the latest completed T bar historically
Calculation: For each configured timeframe T1, T2, T3, and T4, T bullish RSI divergence = T RSI < RSI oversold threshold AND current T low < the low on the most recent earlier T bar where T RSI < RSI oversold threshold AND current T RSI > T RSI on that earlier bar; evaluate on T bars and sample on chart bars using the current T bar in realtime and the latest completed T bar historically
Calculation: For each configured timeframe T1, T2, T3, and T4, T bearish RSI divergence = T RSI > RSI overbought threshold AND current T high > the high on the most recent earlier T bar where T RSI > RSI overbought threshold AND current T RSI < T RSI on that earlier bar; evaluate on T bars and sample on chart bars using the current T bar in realtime and the latest completed T bar historically
Calculation: For each configured timeframe T1, T2, T3, and T4, T MFI = MFI(high, low, close, volume, MFI length) evaluated on T bars and sampled on chart bars using the current T bar in realtime and the latest completed T bar historically
Calculation: For each configured timeframe T1, T2, T3, and T4, T bullish MFI divergence = T MFI < MFI oversold threshold AND current T low < the low on the most recent earlier T bar where T MFI < MFI oversold threshold AND current T MFI > T MFI on that earlier bar; evaluate on T bars and sample on chart bars using the current T bar in realtime and the latest completed T bar historically
Calculation: For each configured timeframe T1, T2, T3, and T4, T bearish MFI divergence = T MFI > MFI overbought threshold AND current T high > the high on the most recent earlier T bar where T MFI > MFI overbought threshold AND current T MFI < T MFI on that earlier bar; evaluate on T bars and sample on chart bars using the current T bar in realtime and the latest completed T bar historically
Calculation: For each configured timeframe T1, T2, T3, and T4, T strong bullish RSI divergence = T bullish RSI divergence AND the rolling count of T bullish RSI divergence over the divergence lookback >= divergence event-count threshold, evaluated on T bars
Calculation: For each configured timeframe T1, T2, T3, and T4, T strong bearish RSI divergence = T bearish RSI divergence AND the rolling count of T bearish RSI divergence over the divergence lookback >= divergence event-count threshold, evaluated on T bars
Calculation: For each configured timeframe T1, T2, T3, and T4, T selected bullish RSI divergence = T strong bullish RSI divergence when strong-divergence-only is enabled, otherwise T bullish RSI divergence
Calculation: For each configured timeframe T1, T2, T3, and T4, T selected bearish RSI divergence = T strong bearish RSI divergence when strong-divergence-only is enabled, otherwise T bearish RSI divergence
Calculation: RSI overbought count = 1 if chart RSI > RSI overbought threshold, plus 1 for each enabled T1, T2, T3, or T4 whose current T RSI > RSI overbought threshold; T values are sampled on chart bars using the current T bar in realtime and the latest completed T bar historically
Calculation: RSI oversold count = 1 if chart RSI < RSI oversold threshold, plus 1 for each enabled T1, T2, T3, or T4 whose current T RSI < RSI oversold threshold; T values are sampled on chart bars using the current T bar in realtime and the latest completed T bar historically
Calculation: Chart bullish GEM condition = universal GEMs enabled AND RSI was oversold within the confirmation window AND the selected bullish RSI divergence was present within the confirmation window AND Bullish candle signal was present within the confirmation window
Calculation: Chart bearish GEM condition = universal GEMs enabled AND RSI was overbought within the confirmation window AND the selected bearish RSI divergence was present within the confirmation window AND Bearish candle signal was present within the confirmation window
Calculation: For each enabled T1, T2, T3, and T4, T RSI state = 1 when T RSI < RSI oversold threshold, -1 when T RSI > RSI overbought threshold, otherwise 0
Calculation: For each enabled T1, T2, T3, and T4, T RSI divergence state = 1 when T bullish RSI divergence, -1 when T bearish RSI divergence, otherwise 0
Calculation: For each enabled T1, T2, T3, and T4, T MFI state = 1 when T MFI < MFI oversold threshold, -1 when T MFI > MFI overbought threshold, otherwise 0
Calculation: For each enabled T1, T2, T3, and T4, T MFI divergence state = 1 when T bullish MFI divergence, -1 when T bearish MFI divergence, otherwise 0
Calculation: For each enabled T1, T2, T3, and T4, T candle state = 1 when the T bullish candle pattern, -1 when no T bullish candle pattern and the T bearish candle pattern, otherwise 0; calculate patterns on T bars and sample the state on chart bars
Calculation: For each enabled T1, T2, T3, and T4, T bullish GEM condition = universal GEMs enabled AND T RSI was oversold within the confirmation window AND T selected bullish RSI divergence was present within the confirmation window AND T bullish candle pattern was present within the confirmation window; calculate on T bars
Calculation: For each enabled T1, T2, T3, and T4, T bearish GEM condition = universal GEMs enabled AND T RSI was overbought within the confirmation window AND T selected bearish RSI divergence was present within the confirmation window AND T bearish candle pattern was present within the confirmation window; calculate on T bars
Calculation: For each enabled T1, T2, T3, and T4, T GEM state = 1 on the first T bar when T bullish GEM condition is true after being false, -1 on the first T bar when T bearish GEM condition is true after being false, otherwise 0; sample on chart bars
Calculation: For each enabled T1, T2, T3, and T4, T dashboard bias = T GEM state when nonzero, otherwise the sign of (T RSI state + T RSI divergence state + T MFI state + T MFI divergence state + T candle state + T GEM state)
Long: Strong bullish RSI divergence
Short: Strong bearish RSI divergence
Long: Bullish MFI divergence
Short: Bearish MFI divergence
Long: On a later chart bar within the signal-life window after the most recent Strong bullish RSI divergence, close > that setup bar's high, and no earlier intervening bar has had low < that setup bar's low
Short: On a later chart bar within the signal-life window after the most recent Strong bearish RSI divergence, close < that setup bar's low, and no earlier intervening bar has had high > that setup bar's high
Long: Bullish candle signal
Short: Bearish candle signal
Long: Chart bullish GEM condition is true on the current chart bar and was false on the previous chart bar
Short: Chart bearish GEM condition is true on the current chart bar and was false on the previous chart bar
Long: RSI fade enabled AND RSI oversold count > RSI overbought count
Short: RSI fade enabled AND RSI overbought count > RSI oversold count
Long: For any enabled T1, T2, T3, or T4 row, T RSI state = 1
Short: For any enabled T1, T2, T3, or T4 row, T RSI state = -1
Long: For any enabled T1, T2, T3, or T4 row, T RSI divergence state = 1
Short: For any enabled T1, T2, T3, or T4 row, T RSI divergence state = -1
Long: For any enabled T1, T2, T3, or T4 row, T MFI state = 1
Short: For any enabled T1, T2, T3, or T4 row, T MFI state = -1
Long: For any enabled T1, T2, T3, or T4 row, T MFI divergence state = 1
Short: For any enabled T1, T2, T3, or T4 row, T MFI divergence state = -1
Long: For any enabled T1, T2, T3, or T4 row, T candle state = 1
Short: For any enabled T1, T2, T3, or T4 row, T candle state = -1
Long: For any enabled T1, T2, T3, or T4 row, T GEM state = 1
Short: For any enabled T1, T2, T3, or T4 row, T GEM state = -1
Long: For any enabled T1, T2, T3, or T4 row, T dashboard bias > 0
Short: For any enabled T1, T2, T3, or T4 row, T dashboard bias < 0