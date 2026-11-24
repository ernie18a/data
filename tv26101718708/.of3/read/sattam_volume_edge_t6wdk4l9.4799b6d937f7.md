Calculation: Trend band = band scale * (sensitivity + sensitivity offset) * ATR(band ATR length)
Calculation: Trend = up or down, the direction of SuperTrend(hl2, Trend band)
Calculation: Trailing trend = up or down, the direction of SuperTrend(hl2, trailing factor * ATR(trailing ATR length))
Calculation: In session = bar time lies within the session window, read at the session UTC offset
Calculation: Session high = high if In session AND NOT In session[1]; max(Session high[1], high) if In session; otherwise Session high[1]
Calculation: Session low = low if In session AND NOT In session[1]; min(Session low[1], low) if In session; otherwise Session low[1]
Calculation: Momentum = average(RSI(close, momentum length), MFI(hlc3, momentum length))
Calculation: Momentum regime = positive if Momentum crosses above upper threshold AND Momentum > lower threshold AND EMA(close, EMA length) > EMA(close, EMA length)[1]; negative if Momentum < lower threshold AND EMA(close, EMA length) < EMA(close, EMA length)[1]; otherwise Momentum regime[1]
Long: Trend = up AND Trend[1] = down
Long: Trend[1] = up
Short: Trend = down AND Trend[1] = up
Short: Trend[1] = down
Long: close > Session high AND no earlier bar since the latest session start has close > Session high
Short: close < Session low AND no earlier bar since the latest session start has close < Session low
Long: Momentum regime = positive AND Momentum regime[1] != positive
Long: Momentum regime = positive
Short: Momentum regime = negative AND Momentum regime[1] != negative
Short: Momentum regime != positive
Exit: long, Trailing trend = down
Exit: short, Trailing trend = up
Exit: long, high >= entry price + nearer target multiple * Trend band at entry
Exit: long, high >= entry price + farther target multiple * Trend band at entry
Exit: short, low <= entry price - nearer target multiple * Trend band at entry
Exit: short, low <= entry price - farther target multiple * Trend band at entry