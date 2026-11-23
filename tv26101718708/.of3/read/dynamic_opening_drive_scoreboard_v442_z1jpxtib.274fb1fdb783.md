Calculation: RVOL = volume / SMA(volume, RVOL lookback)
Calculation: Range = high - low
Calculation: Close location = (close - low) / Range
Calculation: Above both = close > EMA(close, EMA lookback) AND close > VWAP
Calculation: Below both = close <= EMA(close, EMA lookback) AND close <= VWAP
Calculation: EMA distance = (close - EMA(close, EMA lookback)) / EMA(close, EMA lookback) * 100
Calculation: VWAP distance = (close - VWAP) / VWAP * 100
Calculation: New session = T1 period of bar != T1 period of bar[1]
Calculation: Setup expired = Bars since setup[1] > setup window AND Bars since entry[1] is undefined
Calculation: Reset = New session = true OR Below both = true OR Bars since entry > entry window OR Setup expired = true
Calculation: Bars since setup = bars since the first bar at or after the last reset where Above both = true AND RVOL >= setup RVOL threshold
Calculation: Trigger = close[Bars since setup] + trigger buffer
Calculation: Bars since entry = bars since the first bar at or after the last reset where Bars since setup >= 1 AND Bars since setup <= setup window AND high >= Trigger AND Above both = true AND RVOL >= entry RVOL threshold AND volume > volume[1]
Calculation: R multiple = (close - Trigger) / (ATR(ATR lookback) * ATR multiplier)
Long: Bars since entry = 0
Exit: long, Below both = true
Exit: long, New session = true
Exit: long, Bars since entry > entry window
Exit: long, close < open AND Close location <= weak close threshold AND Above both = false
Exit: long, Bars since entry >= 1 AND close < open AND (high - close) / Range * 100 >= giveback % threshold AND Range >= very wide range threshold
Exit: long, Bars since entry >= 1 AND close < open AND R multiple >= base-hit R threshold AND Above both = false
Exit: long, Bars since entry >= 1 AND close < open AND R multiple < weak R threshold AND Above both = false
Exit: long, Bars since entry >= 1 AND RVOL < weak RVOL threshold AND Above both = false
Exit: long, Bars since entry = 0 AND R multiple >= base-hit R threshold AND Above both = true
Exit: long, Bars since entry >= 1 AND EMA distance >= EMA exhaustion threshold AND VWAP distance >= VWAP exhaustion threshold
Exit: long, Bars since entry >= 1 AND Range >= very wide range threshold AND Range / close * 100 >= very wide range % threshold AND R multiple >= base-hit R threshold AND Above both = true
Exit: long, Bars since entry >= 1 AND Close location >= strong close threshold AND R multiple >= base-hit R threshold AND EMA distance >= EMA extended threshold AND Above both = true
Exit: long, Bars since entry >= 1 AND Close location >= strong close threshold AND R multiple >= base-hit R threshold AND VWAP distance >= VWAP extended threshold AND Above both = true
Exit: long, Bars since entry >= 1 AND Close location >= strong close threshold AND R multiple >= base-hit R threshold AND EMA distance >= EMA exhaustion threshold AND VWAP distance >= VWAP exhaustion threshold AND Above both = true