Calculation: HannFIR(src, len) = sum(i=1..len) of src[i-1]*w_i / sum(i=1..len) of w_i, where w_i = 1 - cos(2*pi*i/(len+1))
Calculation: SwingHigh = high[1] if highest(high, S)[1] = high[1] and high < highest(high, S), else SwingHigh[1]
Calculation: SwingLow = low[1] if lowest(low, S)[1] = low[1] and low > lowest(low, S), else SwingLow[1]
Calculation: BullBreak = close > SwingHigh and SwingHigh != BullBreakLevel[1]
Calculation: BullBreakLevel = SwingHigh if BullBreak, else BullBreakLevel[1]
Calculation: BearBreak = close < SwingLow and SwingLow != BearBreakLevel[1]
Calculation: BearBreakLevel = SwingLow if BearBreak, else BearBreakLevel[1]
Calculation: Structure = -1 if BearBreak; 1 if BullBreak; -1 if SwingLow < SwingLow[1]; 1 if SwingHigh > SwingHigh[1]; else Structure[1] (0 at start)
Calculation: BullFVG = (bottom: high[2], top: low) if close[1] > open[1] and high[2] < low, else BullFVG[1]
Calculation: BearFVG = (bottom: high, top: low[2]) if close[1] < open[1] and low[2] > high, else BearFVG[1]
Calculation: NearBullFVG = BullFVG.bottom - ATR(N_ATR)*FVG_PROX < close < BullFVG.top + ATR(N_ATR)*FVG_PROX
Calculation: NearBearFVG = BearFVG.bottom - ATR(N_ATR)*FVG_PROX < close < BearFVG.top + ATR(N_ATR)*FVG_PROX
Calculation: ADXGate = ADX(N_ADX) >= ADX_MIN and ADX(N_ADX) <= ADX_MAX
Calculation: HannStackBull = HannFIR(close, N) > HannFIR(close, N+K) and HannFIR(close, N+K) > HannFIR(close, N+2*K)
Calculation: HannStackBear = HannFIR(close, N) < HannFIR(close, N+K) and HannFIR(close, N+K) < HannFIR(close, N+2*K)
Calculation: SessionGate = not SESSION_FILTER_ON or (GMT weekday is Monday to Friday and ((ASIA_ON and ASIA_FROM <= GMT hour < ASIA_TO) or (LON_ON and LON_FROM <= GMT hour < LON_TO) or (NY_ON and NY_FROM <= GMT hour < NY_TO)))
Long: (HannFIR(close, N) crosses above HannFIR(close, N+K) or (BullBreak and HannFIR(close, N) > HannFIR(close, N+2*K))) and Structure >= 0 and ADXGate and SessionGate and (not FVG_FILTER_ON or NearBullFVG) and position side is flat
Short: (HannFIR(close, N) crosses below HannFIR(close, N+K) or (BearBreak and HannFIR(close, N) < HannFIR(close, N+2*K))) and Structure <= 0 and ADXGate and SessionGate and (not FVG_FILTER_ON or NearBearFVG) and position side is flat
Long: HannFIR(close, N) crosses above HannFIR(close, N+K)
Long: BullBreak
Long: HannStackBull
Long: Structure = 1
Long: NearBullFVG
Short: HannFIR(close, N) crosses below HannFIR(close, N+K)
Short: BearBreak
Short: HannStackBear
Short: Structure = -1
Short: NearBearFVG and not NearBullFVG
Short: ADXGate and not HannStackBull
Exit: long, BearBreak
Exit: short, BullBreak