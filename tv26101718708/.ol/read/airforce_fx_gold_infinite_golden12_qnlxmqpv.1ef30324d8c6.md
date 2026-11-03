Calculation: EMA gap = absolute difference between the shorter-lookback and longer-lookback EMA of close.
Calculation: Entry price = value of the touched EMA on the entry bar.
Calculation: Long target = entry price plus a fixed distance; long stop = entry price minus the same distance.
Calculation: Short target = entry price minus a fixed distance; short stop = entry price plus the same distance.
Long: bar is no more than one week old AND shorter-lookback EMA > longer-lookback EMA AND EMA gap >= minimum gap threshold AND ((no active position for the shorter-lookback EMA AND low <= shorter-lookback EMA) OR (no active position for the longer-lookback EMA AND low <= longer-lookback EMA))
Short: bar is no more than one week old AND shorter-lookback EMA < longer-lookback EMA AND EMA gap >= minimum gap threshold AND ((no active position for the shorter-lookback EMA AND high >= shorter-lookback EMA) OR (no active position for the longer-lookback EMA AND high >= longer-lookback EMA))
Exit: Long, high >= long target OR low <= long stop
Exit: Short, low <= short target OR high >= short stop