Calculation: Risk distance = absolute difference between the signal-bar close and the selected initial long stop
Calculation: ATR-based long stop = signal-bar low minus ATR (RMA of True Range over the configured lookback) multiplied by the configured factor
Calculation: Lowest-low stop = lowest low over the configured lookback
Calculation: VWAP-based long stop = signal-bar low minus the absolute value of (rolling sum of True Range VWAP × current volume / rolling sum of volume) multiplied by the configured factor
Calculation: Fixed long stop = signal-bar close × (1 − configured stop percentage)
Calculation: Initial long target = signal-bar close plus configured risk/reward multiple × risk distance, or signal-bar close × (1 + configured target percentage) in fixed-target mode
Calculation: Break-even trigger = signal-bar close plus configured break-even risk/reward multiple × risk distance
Calculation: Active long stop = initial long stop until the break-even trigger is reached (bar high or close reaches it); thereafter, position average entry price × (1 + configured profit percentage)
Long: External indicator value equals configured signal value AND position is flat AND (date-range filter is disabled OR datetime is within the configured date range)
Exit: Long, bar high reaches the initial long target OR bar low reaches the active long stop