Calculation: Long grid level = setup Ask - level index * grid spacing, with level index starting at 1
Calculation: Short grid level = setup Bid + level index * grid spacing, with level index starting at 1
Long: low <= Long grid level
Short: high >= Short grid level
Exit: long, high >= entry price + profit distance OR low <= entry price - stop distance
Exit: short, low <= entry price - profit distance OR high >= entry price + stop distance