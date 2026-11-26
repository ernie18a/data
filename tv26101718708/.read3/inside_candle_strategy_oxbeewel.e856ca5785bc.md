Calculation: Inside candle = high < high[1] AND low > low[1] on T1 bars, using the T1 bar still forming in real time
Long: On chart bars, close > high of the latest T1 inside candle AND chart-bar time is less than one T1 duration after the latest chart-bar T1 boundary where Inside candle is true
Short: On chart bars, close < low of the latest T1 inside candle AND chart-bar time is less than one T1 duration after the latest chart-bar T1 boundary where Inside candle is true
Exit: long, low <= low of the latest T1 inside candle OR high >= signal-bar close + (signal-bar close - low of the latest T1 inside candle) * RR
Exit: short, high >= high of the latest T1 inside candle OR low <= signal-bar close - (high of the latest T1 inside candle - signal-bar close) * RR