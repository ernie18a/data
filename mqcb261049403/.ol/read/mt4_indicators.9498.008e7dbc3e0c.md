Calculation: Renko box boundaries = initialize a fixed-size grid at floor(first chart-bar close / box size) × box size + offset; advance the current upper and lower boundaries by one box for each completed box
Long: chart-bar high >= current upper boundary + one box size
Short: chart-bar low <= current lower boundary - one box size