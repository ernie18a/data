Long: long-entry switch enabled AND position is flat or short AND datetime is after the configured start-date boundary and before the configured end-date boundary AND low <= round(VWAP(hlc3) * (1 + long offset parameter / 100) / minimum tick) * minimum tick
Short: short-entry switch enabled AND position is flat or long AND datetime is after the configured start-date boundary and before the configured end-date boundary AND high >= round(VWAP(hlc3) * (1 + short offset parameter / 100) / minimum tick) * minimum tick
Exit: long, high >= VWAP(hlc3)
Exit: short, low <= VWAP(hlc3)
Exit: long, datetime > configured end-date cutoff
Exit: short, datetime > configured end-date cutoff