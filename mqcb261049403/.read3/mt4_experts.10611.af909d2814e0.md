Long: long trading enabled AND hour(datetime) = target hour AND minute(datetime) = target minute AND target second >= second(datetime)
Short: short trading enabled AND hour(datetime) = target hour AND minute(datetime) = target minute AND target second >= second(datetime)
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance