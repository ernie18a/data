Calculation: MedTop = RMA(close, N) shifted back floor(N/2) bars (use close where unavailable) + M * ATR(N); RMA and Wilder ATR share the same length N, M is a multiplier
Calculation: MedBottom = RMA(close, N) shifted back floor(N/2) bars (use close where unavailable) - M * ATR(N), same N and M as MedTop
Calculation: ST1 = Supertrend on hl2 with Wilder ATR length A1 and factor F1; trend is up if close > previous lower (support) band, down if close < previous upper (resistance) band, otherwise unchanged; line value = support band when trend is up, resistance band when trend is down
Calculation: ST2 = same Supertrend as ST1 with a longer ATR length and larger factor than ST1
Calculation: LongStop = ST1 line - D; ShortStop = ST1 line + D; D is a fixed positive price distance
Calculation: HighSinceEntry = highest high from the entry bar to the current bar; LowSinceEntry = lowest low from the entry bar to the current bar
Long: close crosses above (MedTop + P1), where P1 is a fixed positive price offset, OR (ST1 trend is up AND ST2 trend is up)
Short: close crosses below (MedBottom - P2), where P2 is a fixed positive price offset, OR (ST1 trend is down AND ST2 trend is down)
Exit: long, close crosses below LongStop
Exit: short, close crosses above ShortStop
Exit: long, close >= LongStop
Exit: short, close >= ShortStop
Exit: long, low <= HighSinceEntry - H, where H is a fixed positive price distance
Exit: short, high >= LowSinceEntry + H