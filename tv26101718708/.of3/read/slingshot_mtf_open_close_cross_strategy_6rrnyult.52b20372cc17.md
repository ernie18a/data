Long: EMA(close, shorter lookback) > EMA(close, longer lookback)
Short: EMA(close, shorter lookback) < EMA(close, longer lookback)
Long: EMA(close, shorter lookback) crosses above EMA(close, longer lookback)
Short: EMA(close, shorter lookback) crosses below EMA(close, longer lookback)
Calculation: open/close series = selected MA(open or close, basis lookback, basis type) on T2 bars, mapped to chart bars from the still-forming T2 bar, when MA is enabled; otherwise raw open or close from the still-forming T2 bar, mapped to chart bars; use chart timeframe when alternate resolution is disabled
Calculation: open/close trend state = long when close series > open series, short when close series < open series, otherwise retain the previous state
Long: close series > open series
Short: close series < open series
Long: open/close trend state is long
Short: open/close trend state is short
Long: selected MA(close, first-MA lookback, first-MA type, T1), calculated on the still-forming T1 bar and mapped to chart bars, >= its value the color-smoothing lookback in chart bars ago
Short: selected MA(close, first-MA lookback, first-MA type, T1), calculated on the still-forming T1 bar and mapped to chart bars, < its value the color-smoothing lookback in chart bars ago
Long: chart open < selected MA(close, first-MA lookback, first-MA type, T1), calculated on the still-forming T1 bar and mapped to chart bars AND chart close > the same value
Short: chart open > selected MA(close, first-MA lookback, first-MA type, T1), calculated on the still-forming T1 bar and mapped to chart bars AND chart close < the same value
Long: chart open < selected MA(close, second-MA lookback, second-MA type, T1), calculated on the still-forming T1 bar and mapped to chart bars AND chart close > the same value
Short: chart open > selected MA(close, second-MA lookback, second-MA type, T1), calculated on the still-forming T1 bar and mapped to chart bars AND chart close < the same value
Short: EMA(close, shorter lookback) > EMA(close, longer lookback) AND selected MA(close, first-MA lookback, first-MA type, T1), calculated on the still-forming T1 bar and mapped to chart bars, < its value the color-smoothing lookback in chart bars ago AND open/close trend state is short
Exit: long, trailing stop enabled AND high since entry >= entry price + activation-distance parameter AND current low <= highest high since activation minus trailing-distance parameter
Exit: short, trailing stop enabled AND low since entry <= entry price minus activation-distance parameter AND current high >= lowest low since activation plus trailing-distance parameter