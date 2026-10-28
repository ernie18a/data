Calculation: Globex VWAP = volume-weighted average of (open + high + low + close) / 4 from the start of the current day through the current bar
Calculation: Handoff VWAP = volume-weighted average of the selected source price from the latest bar today whose range contains the Globex VWAP through the current bar; undefined if no such bar exists today
Long: close >= Handoff VWAP
Short: close < Handoff VWAP