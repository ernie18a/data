Calculation: CloseMA = selected MA(close, shared MA lookback, selected MA type and applicable type-specific parameters) on T1, sampled on chart bars from the still-forming or last completed T1 bar as selected by the non-repainting setting, with its configured chart-bar delay
Calculation: OpenMA = selected MA(open, the same lookback, type, and type-specific parameters) on T1, sampled on chart bars from the still-forming or last completed T1 bar as selected by the non-repainting setting, with its configured chart-bar delay
Calculation: ATR = ATR(ATR lookback) on chart bars
Calculation: Active date window = (start filter disabled OR time > configured start time) AND (end filter disabled OR time < configured end time)
Calculation: ScreenTrend = 1 when selected MA(screened instrument close, shared MA lookback and type-specific parameters)[1] > selected MA(screened instrument open, same parameters)[1] + sensitivity * ATR(ATR lookback, T1); -1 when the close MA is below the open MA minus that threshold; otherwise 0; computed on T1 bars and carried to chart bars using the last completed T1 bar historically and the still-forming T1 bar in realtime
Calculation: ScreenPosition = ScreenTrend when ScreenTrend is nonzero, otherwise the previous ScreenPosition
Calculation: Long trailing stop = max(close * (1 - long trailing percentage), previous long trailing stop) while long; reset while flat
Calculation: Short trailing stop = min(close * (1 + short trailing percentage), previous short trailing stop) while short; reset while flat
Long: Active date window AND trade mode permits long entries AND CloseMA crosses above OpenMA + sensitivity * ATR
Short: Active date window AND trade mode permits short entries AND CloseMA crosses below OpenMA - sensitivity * ATR
Exit: long, Active date window AND trade mode permits only long entries AND CloseMA crosses below OpenMA - sensitivity * ATR
Exit: short, Active date window AND trade mode permits only short entries AND CloseMA crosses above OpenMA + sensitivity * ATR
Exit: long, Active date window AND trade mode is not NONE AND long trailing percentage is nonzero AND low <= Long trailing stop
Exit: short, Active date window AND trade mode is not NONE AND short trailing percentage is nonzero AND high >= Short trailing stop
Long: Active date window AND CloseMA > OpenMA
Short: Active date window AND CloseMA <= OpenMA
Long: Active date window AND CloseMA > OpenMA + sensitivity * ATR
Short: Active date window AND CloseMA < OpenMA - sensitivity * ATR
Long: ScreenTrend = 1
Short: ScreenTrend = -1
Long: ScreenTrend = 1 AND ScreenPosition != ScreenPosition[1]
Short: ScreenTrend = -1 AND ScreenPosition != ScreenPosition[1]