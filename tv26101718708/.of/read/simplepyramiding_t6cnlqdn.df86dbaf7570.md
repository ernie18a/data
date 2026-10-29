Calculation: Session timestamp = opening time of the configured session’s higher-timeframe daily bar, using the bar still forming
Calculation: Session start = current session timestamp is non-null and the prior bar’s timestamp is null or earlier
Calculation: Session end = current session timestamp is null and the prior bar’s timestamp is non-null, or the prior bar’s timestamp is earlier than the current timestamp
Long: Session start AND datetime is within the configured backtest window AND open entry count is less than the configured maximum
Exit: Long, high >= entry price + close × configured take-profit percentage OR (stop loss enabled AND low <= entry price − close × configured stop-loss percentage) OR (exit-at-session-end enabled AND Session end)