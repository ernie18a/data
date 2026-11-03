Calculation: Symmetric weighted moving average = four-bar weighted average of close with weights 1, 2, 2, 1
Calculation: Session VWAP = session cumulative volume-weighted average of close
Calculation: Long setup active = true when close is above session VWAP, prior close was at or below prior session VWAP, and current and prior closes were at or below their respective symmetric weighted moving averages; while active, remains true as long as close is above session VWAP, otherwise becomes false
Long: Long setup active AND close > symmetric weighted moving average AND previous bar did not trigger a long entry
Calculation: Long profit target = entry price + configured stop-loss distance in ticks
Calculation: Long stop price = entry price - 10 × configured stop-loss distance in ticks
Exit: long, high >= long profit target OR low <= long stop price