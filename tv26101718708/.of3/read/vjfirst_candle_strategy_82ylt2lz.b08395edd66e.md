Long: the day's first chart bar closes below its open AND the current bar is within the configured session
Short: the day's first chart bar closes above its open AND the current bar is within the configured session
Exit: long, low <= entry price * (1 - long stop-loss parameter) OR high >= entry price * (1 + long take-profit parameter) OR the current bar is outside the configured session
Exit: short, high >= entry price * (1 + short stop-loss parameter) OR low <= entry price * (1 - short take-profit parameter) OR the current bar is outside the configured session