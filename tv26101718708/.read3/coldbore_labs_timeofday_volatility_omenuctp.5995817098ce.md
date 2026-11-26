Calculation: TimeOfDayLean = average of SIGN(close - open) over the last N prior bars whose time of day, in the time zone parameter and floored to bucket width W, equals the current bar's time of day, and additionally the same weekday when the weekday option is on
Long: TimeOfDayLean > 0
Short: TimeOfDayLean < 0