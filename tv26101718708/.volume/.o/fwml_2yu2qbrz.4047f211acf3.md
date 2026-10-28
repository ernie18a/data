Calculation: Previous day high = high of the last completed daily bar.
Calculation: Previous day low = low of the last completed daily bar.
Calculation: Previous week high = high of the last completed weekly bar.
Calculation: Previous week low = low of the last completed weekly bar.
Calculation: Premarket high = highest high during the current 4:00–9:30 a.m. Eastern premarket session, updating while that session forms.
Calculation: Premarket low = lowest low during the current 4:00–9:30 a.m. Eastern premarket session, updating while that session forms.
Calculation: Opening 5-minute high = high of the 9:30–9:35 a.m. Eastern 5-minute bar, after it completes.
Calculation: Opening 5-minute low = low of the 9:30–9:35 a.m. Eastern 5-minute bar, after it completes.
Calculation: VWAP = current session’s cumulative volume-weighted average of (high + low + close) / 3, updating as bars form.
Calculation: 1-minute 9 EMA = 9-period exponential moving average of 1-minute closes, using the latest available 1-minute bar.
Calculation: Bullish score = count of these six true conditions: close > previous day high; close > premarket high; close > previous week high; close > opening 5-minute high; close > VWAP; close > 1-minute 9 EMA.
Calculation: Bearish score = count of these six true conditions: close < previous day low; close < premarket low; close < previous week low; close < opening 5-minute low; close < VWAP; close < 1-minute 9 EMA.
Long: close > previous day high OR close > premarket high OR close > previous week high OR close > opening 5-minute high OR close > VWAP OR close > 1-minute 9 EMA OR bullish score > bearish score
Short: close < previous day low OR close < premarket low OR close < previous week low OR close < opening 5-minute low OR close < VWAP OR close < 1-minute 9 EMA OR bearish score > bullish score