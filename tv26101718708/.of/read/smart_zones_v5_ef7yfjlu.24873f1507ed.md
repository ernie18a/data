Calculation: Bullish engulfing = absolute(close − open) ≥ ATR × displacement multiplier AND close > open AND (close − low) / (high − low) ≥ 0.65 AND close > prior open AND open < prior close AND volume ≥ volume moving average × volume multiplier; when high = low, close position ratio = 0.5
Calculation: Bearish engulfing = absolute(close − open) ≥ ATR × displacement multiplier AND close < open AND (close − low) / (high − low) ≤ 0.35 AND close < prior open AND open > prior close AND volume ≥ volume moving average × volume multiplier; when high = low, close position ratio = 0.5
Calculation: Low sweep = prior low ≤ highest low over the preceding liquidity lookback bars AND close > that preceding lowest low
Calculation: High sweep = prior high ≥ lowest high over the preceding liquidity lookback bars AND close < that preceding highest high
Calculation: Bullish structure flip = bullish engulfing AND close is within ATR-scaled proximity of prior-day low, weekly open, daily open, latest bullish 1-hour FVG midpoint, or latest bullish daily FVG midpoint
Calculation: Bearish structure flip = bearish engulfing AND close is within ATR-scaled proximity of prior-day high, weekly open, daily open, latest bearish 1-hour FVG midpoint, or latest bearish daily FVG midpoint
Calculation: Bullish FVG entry = a bullish FVG formed within the previous 50 chart bars, close is within its zone, and bullish engulfing
Calculation: Bearish FVG entry = a bearish FVG formed within the previous 50 chart bars, close is within its zone, and bearish engulfing
Calculation: Bullish box break = consolidation is active AND close > range high AND open < range high AND candle body ≥ 0.5 ATR
Calculation: Bearish box break = consolidation is active AND close < range low AND open > range low AND candle body ≥ 0.5 ATR
Calculation: Consolidation = highest high minus lowest low over the box lookback ≤ ATR × box-height multiplier
Calculation: 1-hour bullish FVG = low of the last completed 1-hour bar > high from two completed 1-hour bars ago, with gap size ≥ close × minimum FVG percentage
Calculation: 1-hour bearish FVG = high of the last completed 1-hour bar < low from two completed 1-hour bars ago, with gap size ≥ close × minimum FVG percentage
Calculation: Daily bullish FVG = low of the last completed daily bar > high from two completed daily bars ago, with gap size ≥ close × minimum FVG percentage
Calculation: Daily bearish FVG = high of the last completed daily bar < low from two completed daily bars ago, with gap size ≥ close × minimum FVG percentage
Calculation: Long score = min(10, sum of: 1 if higher-timeframe bias is bullish; 1 if within enabled London or New York session; 1 if volume spike; 1 if correlation instrument low sweep; 1 if chart return over relative-strength lookback exceeds correlation-instrument return; 1 if 1-hour bullish FVG is not killed by a sufficiently larger nearby daily bearish FVG; 1 if daily bullish FVG; 1 if near prior-day low; 1 if enabled daily VIX is falling; 1 if at least two consecutive low sweeps; 1 if at long structure; 2 if bullish structure flip; 2 if bullish FVG entry)
Calculation: Short score = min(10, sum of: 1 if higher-timeframe bias is bearish; 1 if within enabled London or New York session; 1 if volume spike; 1 if correlation instrument high sweep; 1 if chart return over relative-strength lookback is below correlation-instrument return; 1 if 1-hour bearish FVG is not killed by a sufficiently larger nearby daily bullish FVG; 1 if daily bearish FVG; 1 if near prior-day high; 1 if enabled daily VIX is rising; 1 if at least two consecutive high sweeps; 1 if at short structure; 2 if bearish structure flip; 2 if bearish FVG entry)
Calculation: Long BOS confirmation = after a low sweep, close > highest high of the preceding 10 chart bars
Calculation: Short BOS confirmation = after a high sweep, close < lowest low of the preceding 10 chart bars
Calculation: Worth calling = dominant score ≥ 6 OR (dominant score ≥ 4 AND score difference ≥ 2)
Calculation: Bullish setup stop = lowest low over liquidity lookback bars − ATR × stop multiplier, captured on low sweep
Calculation: Bearish setup stop = highest high over liquidity lookback bars + ATR × stop multiplier, captured on high sweep
Calculation: Long target = highest high over the preceding 30 chart bars, captured on low sweep
Calculation: Short target = lowest low over the preceding 30 chart bars, captured on high sweep
Long: bullish engulfing OR low sweep OR bullish structure flip OR bullish FVG entry OR bullish box break AND volume spike OR long BOS confirmation OR (low sweep AND long score ≥ minimum score) OR (long score ≥ 8) OR (long score ≤ 3 AND short score ≥ 5) OR (high sweep AND long score ≥ 5 AND long score > short score) OR (low sweep AND long score > short score AND worth calling)
Short: bearish engulfing OR high sweep OR bearish structure flip OR bearish FVG entry OR bearish box break AND volume spike OR short BOS confirmation OR (high sweep AND short score ≥ minimum score) OR (short score ≥ 8) OR (short score ≤ 3 AND long score ≥ 5) OR (low sweep AND short score ≥ 5 AND short score > long score) OR (high sweep AND short score > long score AND worth calling)
Exit: long, close < captured bullish setup stop OR high ≥ captured long target
Exit: short, close > captured bearish setup stop OR low ≤ captured short target