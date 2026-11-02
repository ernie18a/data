Calculation: Session open = open of the first chart bar in the configured session, held until the next session begins.
Calculation: Period open = open of the first chart bar in the configured calendar period, held until the next period begins.
Calculation: Session cumulative delta = sum of volume on chart bars with close >= open minus sum of volume on chart bars with close < open, reset at the start of the configured session and accumulated only during its included sessions.
Long: close >= session open, for either configured session.
Short: close < session open, for either configured session.
Long: close >= period open.
Short: close < period open.
Long: current bar is in an included session AND session cumulative delta >= 0, for either configured session.
Short: current bar is in an included session AND session cumulative delta < 0, for either configured session.