Calculation: DI+ = 100*RMA(max(high - previous high, 0), n)/RMA(TR, n); DI- = 100*RMA(max(previous low - low, 0), n)/RMA(TR, n)
Calculation: DCX = 100*sqrt((DX/100)*mix); DX = 100*|DI+ - DI-|/(DI+ + DI-); mix = (1-w)*eff + w*conv with fixed w in 0..1; eff = clamp(|close - close[n]|/sum(|close change|, n), small positive floor, 1); conv = 0.5*(1 + (P - N)/(P + N)); P = RMA(max(acc,0), n); N = RMA(max(-acc,0), n); acc = change(change(close)); all lookbacks n are the same
Calculation: Heat = clamp(DCX/100, 0, 1)
Calculation: Upper = MA(hlc3, m) + M*V; Lower = MA(hlc3, m) - M*V; MA = one of ALMA/HMA/EMA; M = base*(1 + adapt*(Heat - 0.5)*2); V = k*Q + (1-k)*ATR(m); Q = high-percentile (linear interpolation) of TR over m bars; k = clamp((stdev(TR, m)/EMA(TR, m))/ref, 0, 1); m is longer than n
Calculation: WeeklyATR = ATR on bars of a timeframe higher than the chart, using the bar still forming
Long: close > Upper AND DCX > threshold AND DCX > highest DCX of previous r bars (rising) AND DI+ > DI-
Short: close < Lower AND DCX > threshold AND DCX < lowest DCX of previous r bars (falling) AND DI- > DI+
Exit: long, Short condition true OR low <= stop OR high >= target; stop = min(Lower, entry - sm*WeeklyATR) and target = entry + R*(entry - stop), both fixed at entry using Lower at entry
Exit: short, Long condition true OR high >= stop OR low <= target; stop = max(Upper, entry + sm*WeeklyATR) and target = entry - R*(stop - entry), both fixed at entry using Upper at entry
Exit: long, (optional trailing) low <= max(Lower, entry - WeeklyATR) using current Lower
Exit: short, (optional trailing) high >= min(Upper, entry + WeeklyATR) using current Upper