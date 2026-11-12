Calculation: clamp01(x) = min(1, max(0, x))
Calculation: fastEMA, slowEMA = EMA of close; fastEMA has the shorter lookback than slowEMA
Calculation: RSI of close
Calculation: chg = close - close[n bars ago]; ER = abs(chg) / sum(abs(close - close[1]) over the same n bars), ER = 0 if the sum is 0
Calculation: ATR; atrPct = percent rank of the current ATR within its own history over a long lookback (default 50 if unavailable)
Calculation: relVol = volume / SMA(volume); hasVol = SMA(volume) > 0
Calculation: trendL = 10*(close > slowEMA) + 10*(fastEMA > slowEMA); trendS = 10*(close < slowEMA) + 10*(fastEMA < slowEMA)
Calculation: momL = 20*clamp01((RSI - 50) / (overbought level - 50)); momS = 20*clamp01((50 - RSI) / (50 - oversold level)); the two levels are symmetric around 50
Calculation: effL = 20*clamp01(ER / fullEfficiencyRatio) if chg > 0, else 0; effS = same if chg < 0, else 0
Calculation: volReg (same for long and short) = 20*atrPct/floor if atrPct < floor; 20*clamp01((100 - atrPct) / (100 - ceiling)) if atrPct > ceiling; otherwise 20; floor < ceiling
Calculation: partL = 10 if not hasVol; else 20*clamp01(relVol - 0.5) if close > open, else 0; partS = 10 if not hasVol; else 20*clamp01(relVol - 0.5) if close < open, else 0
Calculation: scoreL = trendL + momL + effL + volReg + partL; scoreS = trendS + momS + effS + volReg + partS (each 0-100), evaluated on closed bars after indicator warm-up
Calculation: trailing stop for a long = at entry bar close - k*ATR; on each later bar close, stop = max(previous stop, close - k*ATR); the stop is tested from the next bar on. For a short, mirror it: entry close + k*ATR, then stop = min(previous stop, close + k*ATR)
Long: flat AND scoreL >= entryThreshold AND previous bar scoreL < entryThreshold (enter at next bar open)
Short: flat AND scoreS >= entryThreshold AND previous bar scoreS < entryThreshold AND no long signal on the same bar (enter at next bar open)
Exit: long, scoreL < exitThreshold (on bar close; exitThreshold is lower than entryThreshold) OR low <= trailing stop
Exit: short, scoreS < exitThreshold (on bar close; exitThreshold is lower than entryThreshold) OR high >= trailing stop