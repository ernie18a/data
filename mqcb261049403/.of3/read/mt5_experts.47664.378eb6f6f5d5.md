Long: datetime hour is within the start-time/end-time interval (start inclusive, end exclusive, wrapping midnight when start exceeds end) AND high >= entry price
Short: datetime hour is within the start-time/end-time interval (start inclusive, end exclusive, wrapping midnight when start exceeds end) AND low <= entry price
Exit: long, low <= entry price - stop-loss distance OR datetime hour is outside the start-time/end-time interval
Exit: short, high >= entry price + stop-loss distance OR datetime hour is outside the start-time/end-time interval