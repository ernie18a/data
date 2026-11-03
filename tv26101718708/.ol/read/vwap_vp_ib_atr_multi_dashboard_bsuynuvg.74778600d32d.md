Calculation: OHLC4 = (open + high + low + close) / 4
Calculation: Globex VWAP = cumulative volume-weighted average of OHLC4, reset at each daily boundary
Calculation: Session VWAP = cumulative volume-weighted average of OHLC4, reset at each configured session open and active only during a configured session
Calculation: Value Area High/Low = boundaries of the configured volume percentage around the point of control, expanding one adjacent price row at a time toward the row with greater volume; bar volume is allocated to rows in proportion to each row's overlap with the bar's high-low range
Calculation: Globex Value Area = Value Area High/Low from a volume profile reset at each daily boundary
Calculation: Session Value Area = Value Area High/Low from a volume profile reset at each configured session open and active only during a configured session
Calculation: Initial Balance High/Low = highest high and lowest low during the configured initial-balance window; levels are unavailable while the window is forming
Long: close >= Globex VWAP
Short: close < Globex VWAP
Long: session active AND close >= Session VWAP
Short: session active AND close < Session VWAP
Long: close > Globex Value Area High
Short: close < Globex Value Area Low
Long: session active AND close > Session Value Area High
Short: session active AND close < Session Value Area Low
Long: initial-balance window complete AND close > Initial Balance High
Short: initial-balance window complete AND close < Initial Balance Low