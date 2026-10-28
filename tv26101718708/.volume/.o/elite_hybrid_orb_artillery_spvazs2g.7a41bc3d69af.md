Calculation: Opening range high = highest high during the selected session’s initial range-building period, available after that period completes
Calculation: Opening range low = lowest low during the selected session’s initial range-building period, available after that period completes
Calculation: Opening range width = opening range high − opening range low
Calculation: Opening range buffer = opening range width × configured buffer percentage
Long: close > opening range high + opening range buffer AND opening range width is within the configured valid tick range AND time is after range completion and before the pre-close flatten window AND session trade count < configured maximum AND position is flat
Short: close < opening range low − opening range buffer AND opening range width is within the configured valid tick range AND time is after range completion and before the pre-close flatten window AND session trade count < configured maximum AND position is flat AND long-only mode is disabled
Exit: long, low <= opening range low OR high >= entry price + opening range width × configured target multiple OR time is in the pre-close flatten window
Exit: short, high >= opening range high OR low <= entry price − opening range width × configured target multiple OR time is in the pre-close flatten window