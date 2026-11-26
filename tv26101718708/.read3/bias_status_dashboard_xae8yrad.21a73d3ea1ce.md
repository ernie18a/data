Calculation: timeframe bias(T) = on T bars, let the three bullish conditions be selected MA(close, shorter lookback) > selected MA(close, middle lookback) > selected MA(close, longer lookback), RSI(close, RSI lookback) >= bullish RSI threshold, and StochRSI K > StochRSI D and K > midpoint; let the bearish conditions use the reverse comparisons and bearish RSI threshold; return bullish when at least two bullish conditions are true and their count exceeds the bearish count, bearish when at least two bearish conditions are true and their count exceeds the bullish count, otherwise neutral; chart bars take the current T result, using the forming T bar in realtime and the last completed T bar historically
Calculation: bullish timeframe count = count of T1 through T8 whose timeframe bias is bullish
Calculation: bearish timeframe count = count of T1 through T8 whose timeframe bias is bearish
Calculation: momentum direction = bullish when the count of RSI(close, RSI lookback) >= bullish RSI threshold and StochRSI K > StochRSI D and K > midpoint exceeds the count of RSI(close, RSI lookback) <= bearish RSI threshold and StochRSI K < StochRSI D and K < midpoint; bearish when the bearish count exceeds the bullish count; otherwise neutral
Calculation: structure direction = bullish after close exceeds the latest confirmed PivotHigh(high, swing lookback, swing lookback), bearish after close falls below the latest confirmed PivotLow(low, swing lookback, swing lookback), otherwise retain the previous direction; initially neutral
Calculation: session sweep direction = reset to neutral at the start of the configured Asia window when the reset setting is enabled; with the Asia source, outside that window set bearish when high exceeds the Asia-window high and then set bullish when low falls below the Asia-window low; with the active-session source, during a configured active-session window set bearish when high exceeds the prior bar's accumulated active-session high and then set bullish when low falls below the prior bar's accumulated active-session low; otherwise retain the previous direction
Calculation: enabled-source directional score = sum of the directions of enabled trend, VWAP, momentum, structure, multi-timeframe, and session sources, where bullish is 1, bearish is -1, and neutral is 0
Calculation: selected bias direction = in hybrid mode, bullish when enabled-source directional score >= minimum directional score and bearish when it <= negative minimum directional score; in single-source mode, the selected source's direction; in manual mode, the configured manual side or neutral
Long: selected MA(close, shorter lookback) > selected MA(close, middle lookback) > selected MA(close, longer lookback)
Short: selected MA(close, shorter lookback) < selected MA(close, middle lookback) < selected MA(close, longer lookback)
Long: close > VWAP(hlc3) + ATR(ATR lookback) * VWAP neutral-band percentage
Short: close < VWAP(hlc3) - ATR(ATR lookback) * VWAP neutral-band percentage
Long: RSI(close, RSI lookback) >= bullish RSI threshold
Short: RSI(close, RSI lookback) <= bearish RSI threshold
Long: StochRSI K > StochRSI D and StochRSI K > midpoint
Short: StochRSI K < StochRSI D and StochRSI K < midpoint
Long: momentum direction is bullish
Short: momentum direction is bearish
Long: volume > SMA(volume, volume-average lookback)
Long: structure direction is bullish
Short: structure direction is bearish
Long: session sweep direction is bullish
Short: session sweep direction is bearish
Long: timeframe bias(T1) is bullish
Short: timeframe bias(T1) is bearish
Long: timeframe bias(T2) is bullish
Short: timeframe bias(T2) is bearish
Long: timeframe bias(T3) is bullish
Short: timeframe bias(T3) is bearish
Long: timeframe bias(T4) is bullish
Short: timeframe bias(T4) is bearish
Long: timeframe bias(T5) is bullish
Short: timeframe bias(T5) is bearish
Long: timeframe bias(T6) is bullish
Short: timeframe bias(T6) is bearish
Long: timeframe bias(T7) is bullish
Short: timeframe bias(T7) is bearish
Long: timeframe bias(T8) is bullish
Short: timeframe bias(T8) is bearish
Long: bullish timeframe count >= minimum timeframe agreement and bullish timeframe count > bearish timeframe count
Short: bearish timeframe count >= minimum timeframe agreement and bearish timeframe count > bullish timeframe count
Long: selected bias direction is bullish
Short: selected bias direction is bearish