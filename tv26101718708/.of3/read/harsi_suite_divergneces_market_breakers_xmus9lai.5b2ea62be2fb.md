Calculation: WTLine = WaveTrend(hlc3, channel lookback, average lookback)
Calculation: WTSignal = SMA(WTLine, signal lookback)
Calculation: GateValue = EMA(RSI(ohlc4, gate lookback) - 50, gate smoothing lookback)
Calculation: ZoneTop = FractalTop(WTSignal)[2] AND WTSignal[2] >= divergence overbought level
Calculation: ZoneBottom = FractalBottom(WTSignal)[2] AND WTSignal[2] <= divergence oversold level
Calculation: PrevZoneTopHigh = ValueWhen(ZoneTop, High[2], 1)
Calculation: PrevZoneTopWT = ValueWhen(ZoneTop, WTSignal[2], 1)
Calculation: PrevZoneBottomLow = ValueWhen(ZoneBottom, Low[2], 1)
Calculation: PrevZoneBottomWT = ValueWhen(ZoneBottom, WTSignal[2], 1)
Calculation: ZZ = pivot confirmed on this bar by ZigZag(HARSI high(structure lookback, structure smoothing), HARSI low(structure lookback, structure smoothing), left lookback, right lookback)
Calculation: HighBeforeLastLow = value of the most recent ZZ high pivot before the most recent ZZ low pivot
Calculation: LowBeforeLastHigh = value of the most recent ZZ low pivot before the most recent ZZ high pivot
Calculation: CandleOpen = HARSI open(display lookback, display smoothing) at the first chart bar of each T1 bar
Calculation: CandleClose = HARSI close(display lookback, display smoothing) at the last chart bar of each T1 bar
Long: GateValue[1] < -gate level AND (WTLine crosses above WTSignal)[2] AND WTSignal[2] <= oversold level
Short: GateValue[1] > gate level AND (WTLine crosses below WTSignal)[2] AND WTSignal[2] >= overbought level
Long: ZoneBottom AND Low[2] < PrevZoneBottomLow AND WTSignal[2] > PrevZoneBottomWT
Long: ZoneBottom AND Low[2] > PrevZoneBottomLow AND WTSignal[2] < PrevZoneBottomWT
Short: ZoneTop AND High[2] > PrevZoneTopHigh AND WTSignal[2] < PrevZoneTopWT
Short: ZoneTop AND High[2] < PrevZoneTopHigh AND WTSignal[2] > PrevZoneTopWT
Long: ZZ is high pivot AND ZZ > HighBeforeLastLow
Short: ZZ is low pivot AND ZZ < LowBeforeLastHigh
Long: CandleClose(last completed T1 bar) > CandleOpen(last completed T1 bar)
Short: CandleClose(last completed T1 bar) <= CandleOpen(last completed T1 bar)
Long: CandleClose(forming T1 bar) > CandleOpen(forming T1 bar)
Short: CandleClose(forming T1 bar) <= CandleOpen(forming T1 bar)