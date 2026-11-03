Calculation: Bar Delta = volume when close > open, −volume when close < open, and 0 when close = open, using the selected table-timeframe bar (which may be higher or lower than the chart timeframe; use the current bar while it is forming, otherwise the latest completed bar)
Calculation: Session Delta = sum of Bar Delta from the start of the selected daily or Globex session through the current bar; reset at the session start and remain 0 outside Globex
Long: Bar Delta >= 0 OR Session Delta >= 0
Short: Bar Delta < 0 OR Session Delta < 0