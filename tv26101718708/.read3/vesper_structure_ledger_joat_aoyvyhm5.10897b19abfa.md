Calculation: Most recent swing high = latest confirmed Pivot High(high, left lookback, right lookback) on chart bars, available after right lookback bars
Calculation: Most recent swing low = latest confirmed Pivot Low(low, left lookback, right lookback) on chart bars, available after right lookback bars
Calculation: ATR = ATR(lookback) on chart bars
Calculation: Bullish structure break = confirmed chart bar with close > most recent swing high and close[1] <= most recent swing high
Calculation: Bearish structure break = confirmed chart bar with close < most recent swing low and close[1] >= most recent swing low
Calculation: Bullish liquidity sweep = enabled sweep detection AND confirmed chart bar with most recent swing low age <= sweep lookback AND low < most recent swing low AND close > most recent swing low AND (most recent swing low - low) / max(ATR, tick size) >= sweep ATR buffer
Calculation: Bearish liquidity sweep = enabled sweep detection AND confirmed chart bar with most recent swing high age <= sweep lookback AND high > most recent swing high AND close < most recent swing high AND (high - most recent swing high) / max(ATR, tick size) >= sweep ATR buffer
Calculation: Fast context EMA = EMA(close, shorter lookback) on T1 bars, mapped to chart bars with lookahead off (forming T1 bar in real time; last completed T1 value historically)
Calculation: Slow context EMA = EMA(close, longer lookback) on T1 bars, mapped to chart bars with lookahead off (forming T1 bar in real time; last completed T1 value historically)
Calculation: KAMA = KAMA(source, efficiency lookback, fast smoothing period, slow smoothing period) on chart bars
Calculation: Bullish KAMA trend = close > KAMA AND KAMA >= KAMA[1]
Calculation: Bearish KAMA trend = close < KAMA AND KAMA <= KAMA[1]
Calculation: Strong impulse = at least two of volume > SMA(volume, volume lookback) * volume spike multiplier; abs(close - open) > ATR * displacement ATR multiplier; (Bullish KAMA trend AND Fast context EMA > Slow context EMA) OR (Bearish KAMA trend AND Fast context EMA < Slow context EMA)
Calculation: Close location = (close - low) / max(high - low, tick size)
Calculation: Bullish event = Bullish structure break OR Bullish liquidity sweep
Calculation: Bearish event = Bearish structure break OR Bearish liquidity sweep
Long: Bullish event
Short: Bearish event
Long: Bullish event AND (Fast context EMA >= Slow context EMA OR Strong impulse) AND Close location >= long close-location threshold
Short: Bearish event AND (Fast context EMA <= Slow context EMA OR Strong impulse) AND Close location <= short close-location threshold
Long: Bullish KAMA trend
Short: Bearish KAMA trend
Long: Fast context EMA > Slow context EMA
Short: Fast context EMA < Slow context EMA