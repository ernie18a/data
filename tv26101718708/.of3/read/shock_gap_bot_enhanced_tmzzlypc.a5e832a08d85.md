Calculation: Opening-range high = high of the New York session-opening chart bar
Calculation: Opening-range low = low of the New York session-opening chart bar
Calculation: Opening-range open = open of the New York session-opening chart bar
Calculation: Gap percentage = 100 × (opening-range open − close of the last completed T1 bar) / close of the last completed T1 bar, computed on chart bars
Long: position is flat AND Gap percentage >= minimum gap percentage AND Gap percentage <= maximum gap percentage AND (RSI filter is disabled OR RSI(close, RSI length) on the last completed T1 bar, sampled onto chart bars, < oversold RSI threshold) AND high >= opening-range high + entry buffer
Short: position is flat AND Gap percentage <= −minimum gap percentage AND Gap percentage >= −maximum gap percentage AND (RSI filter is disabled OR RSI(close, RSI length) on the last completed T1 bar, sampled onto chart bars, > overbought RSI threshold) AND low <= opening-range low − entry buffer
Exit: long, low <= opening-range low − stop-loss buffer OR chart bar time is within the end-of-day close window in New York time
Exit: short, high >= opening-range high + stop-loss buffer OR chart bar time is within the end-of-day close window in New York time