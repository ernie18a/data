Calculation: Session range high/low = highest high and lowest low of the chart-timeframe bars whose time-of-day is within the range window (start inclusive, end exclusive) of the current day; the range is final only once time-of-day reaches the window end
Calculation: Range width = session range high - session range low
Calculation: Buffer = fixed price offset
Long: time-of-day is at or after the range window end AND at or before the trade window end AND range width is between a lower bound and an upper bound AND close > session range high + buffer AND no long breakout signal has already fired today AND no trade has been entered today
Short: time-of-day is at or after the range window end AND at or before the trade window end AND range width is between a lower bound and an upper bound AND close < session range low - buffer AND no short breakout signal has already fired today AND no trade has been entered today
Exit: long, low <= session range low (opposite boundary stop) OR high >= entry price + a fixed multiple of range width (take profit)
Exit: short, high >= session range high (opposite boundary stop) OR low <= entry price - a fixed multiple of range width (take profit)