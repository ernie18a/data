Calculation: LastHighBar = index of the most recent bar (including the current bar) whose high is greater than or equal to the highest high over the trailing lookback window ending at that bar
Calculation: LastLowBar = index of the most recent bar (including the current bar) whose low is less than or equal to the lowest low over the trailing lookback window ending at that bar; same lookback length as LastHighBar
Long: LastHighBar > LastLowBar
Exit: long, LastHighBar <= LastLowBar