Calculation: A(x) = indicator x on the chart timeframe, or optionally on a higher-timeframe bar still forming; applies to EMA1..EMA5, SMA_s, SMA_l, StochK, RSI and ADX. NearMA, Touch200 and the warnings use chart-timeframe values.
Calculation: EMA1..EMA5 = EMAs of close with strictly increasing lookbacks (EMA1 shortest); SMA_s and SMA_l = SMAs of close, shorter and longer lookback
Calculation: StochK = SMA (short smoothing) of the raw stochastic %K of close over high/low lookback
Calculation: RSI = RSI of close with a very short lookback; ADX = ADX from DMI; ATR = average true range
Calculation: BullRetr = A(StochK) <= low level; BearRetr = A(StochK) >= high level (low level < high level)
Calculation: BullRainbow = A(EMA1) > A(EMA2) > A(EMA3) > A(EMA4) > A(EMA5); BearRainbow = A(EMA1) < A(EMA2) < A(EMA3) < A(EMA4) < A(EMA5)
Calculation: NearMA = for any of EMA1, EMA2, EMA3, SMA_s (chart timeframe), abs(close - MA)/close*100 <= a small percent
Calculation: Touch200 = high >= SMA_l AND low <= SMA_l (chart timeframe)
Calculation: BullWarn (optional filter, default on) = (abs(close-open) > k*ATR AND close < open) OR open < previous low - f*ATR; BearWarn = (abs(close-open) > k*ATR AND close > open) OR open > previous high + f*ATR (f is a fraction below 1)
Calculation: BullLevel = high of the most recent bar (including the current bar) where BullRetr is true; BearLevel = low of the most recent bar (including the current bar) where BearRetr is true
Calculation: BullTrig = (close > BullLevel AND previous close <= BullLevel) OR (optional, default on) A(RSI) crosses above a low threshold; BearTrig = close < BearLevel AND previous close >= BearLevel
Long: BullRainbow AND BullRetr AND A(ADX) >= minimum AND NearMA AND NOT BullWarn (setup marking)
Long: A(SMA_s) > A(SMA_l) AND Touch200 AND BullRetr AND NOT BullWarn (setup marking)
Long: BullTrig AND (BullRainbow AND BullRetr AND A(ADX) >= minimum AND NearMA AND NOT BullWarn) (entry)
Long: BullTrig AND (A(SMA_s) > A(SMA_l) AND Touch200 AND BullRetr AND NOT BullWarn) (entry)
Short: BearRainbow AND BearRetr AND A(ADX) >= minimum AND NearMA AND NOT BearWarn (setup marking)
Short: A(SMA_s) < A(SMA_l) AND Touch200 AND BearRetr AND NOT BearWarn (setup marking)
Short: BearTrig AND (BearRainbow AND BearRetr AND A(ADX) >= minimum AND NearMA AND NOT BearWarn) (entry)
Short: BearTrig AND (A(SMA_s) < A(SMA_l) AND Touch200 AND BearRetr AND NOT BearWarn) (entry)