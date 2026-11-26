Calculation: ATR floor = max(ATR(risk lookback), minimum tick size), using minimum tick size when ATR is unavailable
Calculation: Bullish ribbon = EMA(source, fast lookback) > EMA(source, mid lookback) > EMA(source, slow lookback) > EMA(source, base lookback), with fast, mid, slow, and base lookbacks in ascending order
Calculation: Bearish ribbon = EMA(source, fast lookback) < EMA(source, mid lookback) < EMA(source, slow lookback) < EMA(source, base lookback), with fast, mid, slow, and base lookbacks in ascending order
Calculation: Bullish HTF T1 = ZLEMA(source, ZLEMA lookback) > EMA(source, slow lookback) AND EMA(source, fast lookback) > EMA(source, slow lookback) AND ZLEMA(source, ZLEMA lookback) > EMA(source, fast lookback), calculated on T1 bars and mapped to chart bars with lookahead off and gaps off, using the still-forming T1 bar in realtime
Calculation: Bearish HTF T1 = ZLEMA(source, ZLEMA lookback) < EMA(source, slow lookback) AND EMA(source, fast lookback) < EMA(source, slow lookback) AND ZLEMA(source, ZLEMA lookback) < EMA(source, fast lookback), calculated on T1 bars and mapped to chart bars with lookahead off and gaps off, using the still-forming T1 bar in realtime
Calculation: Bullish HTF T2 = ZLEMA(source, ZLEMA lookback) > EMA(source, slow lookback) AND EMA(source, fast lookback) > EMA(source, slow lookback) AND ZLEMA(source, ZLEMA lookback) > EMA(source, fast lookback), calculated on T2 bars and mapped to chart bars with lookahead off and gaps off, using the still-forming T2 bar in realtime
Calculation: Bearish HTF T2 = ZLEMA(source, ZLEMA lookback) < EMA(source, slow lookback) AND EMA(source, fast lookback) < EMA(source, slow lookback) AND ZLEMA(source, ZLEMA lookback) < EMA(source, fast lookback), calculated on T2 bars and mapped to chart bars with lookahead off and gaps off, using the still-forming T2 bar in realtime
Calculation: Bullish HTF T3 = ZLEMA(source, ZLEMA lookback) > EMA(source, slow lookback) AND EMA(source, fast lookback) > EMA(source, slow lookback) AND ZLEMA(source, ZLEMA lookback) > EMA(source, fast lookback), calculated on T3 bars and mapped to chart bars with lookahead off and gaps off, using the still-forming T3 bar in realtime
Calculation: Bearish HTF T3 = ZLEMA(source, ZLEMA lookback) < EMA(source, slow lookback) AND EMA(source, fast lookback) < EMA(source, slow lookback) AND ZLEMA(source, ZLEMA lookback) < EMA(source, fast lookback), calculated on T3 bars and mapped to chart bars with lookahead off and gaps off, using the still-forming T3 bar in realtime
Calculation: Local bullish state = close > SuperTrend(SuperTrend factor, SuperTrend ATR lookback) AND ZLEMA(source, ZLEMA lookback) > EMA(source, slow lookback) AND bullish ribbon AND ZLEMA(source, ZLEMA lookback) > ZLEMA(source, ZLEMA lookback)[1] AND EMA(source, fast lookback) > EMA(source, fast lookback)[1]
Calculation: Local bearish state = close < SuperTrend(SuperTrend factor, SuperTrend ATR lookback) AND ZLEMA(source, ZLEMA lookback) < EMA(source, slow lookback) AND bearish ribbon AND ZLEMA(source, ZLEMA lookback) < ZLEMA(source, ZLEMA lookback)[1] AND EMA(source, fast lookback) < EMA(source, fast lookback)[1]
Calculation: Vote(bull condition, bear condition) = 1 when bull condition, -1 when bear condition, otherwise 0
Calculation: Total vote = Vote(local bullish state, local bearish state) + Vote(bullish HTF T1, bearish HTF T1) + Vote(bullish HTF T2, bearish HTF T2) + Vote(bullish HTF T3, bearish HTF T3) + Vote(close > SuperTrend(SuperTrend factor, SuperTrend ATR lookback), close < SuperTrend(SuperTrend factor, SuperTrend ATR lookback)) + Vote(bullish ribbon, bearish ribbon) + Vote(ZLEMA(source, ZLEMA lookback) > ZLEMA(source, ZLEMA lookback)[1] AND close > ZLEMA(source, ZLEMA lookback), ZLEMA(source, ZLEMA lookback) < ZLEMA(source, ZLEMA lookback)[1] AND close < ZLEMA(source, ZLEMA lookback))
Calculation: Bullish regime = confirmed chart bar AND total vote >= minimum confluence votes AND total vote > 0
Calculation: Bearish regime = confirmed chart bar AND total vote <= -minimum confluence votes AND total vote < 0
Calculation: Predicted ZLEMA = ZLEMA(source, ZLEMA lookback) + EMA(ZLEMA(source, ZLEMA lookback) - ZLEMA(source, ZLEMA lookback)[1], prediction lookback) + prediction acceleration weight * (EMA(ZLEMA(source, ZLEMA lookback) - ZLEMA(source, ZLEMA lookback)[1], prediction lookback) - EMA(ZLEMA(source, ZLEMA lookback) - ZLEMA(source, ZLEMA lookback)[1], prediction lookback)[1])
Calculation: Confluence score = clamp(confluence score baseline + total vote * vote score weight + clamp((ZLEMA(source, ZLEMA lookback) - EMA(source, slow lookback)) / ATR floor, normalized lower bound, normalized upper bound) * separation score weight, score lower bound, score upper bound)
Calculation: Proximity score = max(clamp(1 - abs(close - ZLEMA(source, ZLEMA lookback)) / max(ATR floor * proximity distance multiplier, minimum tick size), 0, 1), clamp(1 - abs(close - SuperTrend(SuperTrend factor, SuperTrend ATR lookback)) / max(ATR floor * proximity distance multiplier, minimum tick size), 0, 1))
Calculation: Relay pressure = clamp(relay price weight * clamp((close - ZLEMA(source, ZLEMA lookback)) / ATR floor, normalized lower bound, normalized upper bound) + relay prediction weight * clamp((predicted ZLEMA - ZLEMA(source, ZLEMA lookback)) / ATR floor, normalized lower bound, normalized upper bound), normalized lower bound, normalized upper bound)
Calculation: Risk anchor = mean(ZLEMA(source, ZLEMA lookback), SuperTrend(SuperTrend factor, SuperTrend ATR lookback))
Calculation: Long ladder stop = min(if bullish regime then risk anchor - ATR floor * stop ATR multiplier else signal-bar low - ATR floor * stop ATR multiplier, signal-bar low - ATR floor * ladder candle buffer multiplier), captured at ladder initialization
Calculation: Short ladder stop = max(if bearish regime then risk anchor + ATR floor * stop ATR multiplier else signal-bar high + ATR floor * stop ATR multiplier, signal-bar high + ATR floor * ladder candle buffer multiplier), captured at ladder initialization
Calculation: Ladder risk = max(abs(entry price - ladder stop for position side), ATR floor at ladder initialization * minimum ladder risk multiplier)
Calculation: Ladder target 3 = entry price + position-side direction * ladder risk * third target risk multiple, captured at ladder initialization
Calculation: Live ladder = a confirmed bar with the risk ladder enabled and a relay or reclaim signal initializes its side; it remains live until a confirmed bar reaches that side's stop or target 3, and a newer signal resets it
Long: confirmed chart bar AND total vote >= minimum confluence votes AND total vote > 0
Short: confirmed chart bar AND total vote <= -minimum confluence votes AND total vote < 0
Long: total vote > 0
Short: total vote < 0
Long: bullish HTF T1
Short: bearish HTF T1
Long: bullish HTF T2
Short: bearish HTF T2
Long: bullish HTF T3
Short: bearish HTF T3
Long: bullish ribbon
Short: bearish ribbon
Long: close >= SuperTrend(SuperTrend factor, SuperTrend ATR lookback)
Short: close < SuperTrend(SuperTrend factor, SuperTrend ATR lookback)
Long: predicted ZLEMA >= ZLEMA(source, ZLEMA lookback)
Short: predicted ZLEMA < ZLEMA(source, ZLEMA lookback)
Long: relay pressure > relay pressure threshold
Short: relay pressure < -relay pressure threshold
Long: confluence score >= bullish score color threshold
Short: confluence score < bearish score color threshold
Long: bullish regime AND confluence score > confluence color scale midpoint
Short: bearish regime AND confluence score < confluence color scale midpoint
Long: bullish regime AND close > ZLEMA(source, ZLEMA lookback) AND close > SuperTrend(SuperTrend factor, SuperTrend ATR lookback) AND bullish ribbon
Short: bearish regime AND close < ZLEMA(source, ZLEMA lookback) AND close < SuperTrend(SuperTrend factor, SuperTrend ATR lookback) AND bearish ribbon
Long: confirmed chart bar AND crosses above(close, ZLEMA(source, ZLEMA lookback)) AND total vote >= minimum confluence votes - one
Short: confirmed chart bar AND crosses below(close, ZLEMA(source, ZLEMA lookback)) AND total vote <= -(minimum confluence votes - one)
Long: confirmed chart bar AND proximity score > proximity warning threshold AND total vote > 0 AND close >= ZLEMA(source, ZLEMA lookback)
Short: confirmed chart bar AND proximity score > proximity warning threshold AND total vote < 0 AND close <= ZLEMA(source, ZLEMA lookback)
Exit: long, confirmed chart bar AND live ladder is long AND (low <= long ladder stop OR high >= long ladder target 3)
Exit: short, confirmed chart bar AND live ladder is short AND (high >= short ladder stop OR low <= short ladder target 3)