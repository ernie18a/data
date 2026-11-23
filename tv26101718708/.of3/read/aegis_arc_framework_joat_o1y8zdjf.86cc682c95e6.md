Calculation: Atr = ATR(high, low, close, ATR length)
Calculation: Band = max(Atr * trail multiplier, minimum tick multiple * tick size)
Calculation: Vwap(T) = VWAP(hl2, volume) on chart bars since the start of the current, still-forming T bar, for T in {T1, T2, T3} with T1 shorter than T2 and T2 shorter than T3
Calculation: Ref = Vwap(primary anchor)
Calculation: Ext = clamp(abs(close - Ref) / (Atr * extension scale), 0, 1)
Calculation: Vel = reset velocity if Long or Short, else clamp(Vel[1] * velocity decay + base acceleration * (1 + (extension boost - 1) * Ext) * (1 + min(RunBars[1] / run window, run-age cap) * run-age weight), 0, velocity cap); Vel[1] = reset velocity when undefined
Calculation: RunBars = 0 if Long or Short, else RunBars[1] + 1; RunBars[1] = 0 when undefined
Calculation: Since = 0 if Long or Short, else Since[1] + 1; Since[1] = infinity when undefined
Calculation: Chase = clamp(minimum chase + Vel * velocity chase weight + Ext * extension chase weight, minimum chase, maximum chase)
Calculation: Trend = Long on a Long bar, Short on a Short bar, otherwise Trend[1]; on the first bar with Atr defined, Trend = Long if close >= Ref, otherwise Short
Calculation: Arc = Low - Band if Long; High + Band if Short; otherwise min(Arc[1] + max(Low - Band - Arc[1], 0) * Chase, Low - tick size) if Trend is Long, else max(Arc[1] + min(High + Band - Arc[1], 0) * Chase, High + tick size); on the first bar with Atr defined, Arc = Low - max(Band, tick size) if Trend is Long, else High + max(Band, tick size)
Long: Trend[1] = Short AND close > Arc[1] AND number of regime anchors T with close >= Vwap(T) is at least regime requirement AND Since[1] >= minimum flip gap
Short: Trend[1] = Long AND close < Arc[1] AND number of regime anchors T with close < Vwap(T) is at least regime requirement AND Since[1] >= minimum flip gap