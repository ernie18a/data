Long: current price > current daily bar's open AND current daily bar's open - low > a configurable point distance AND hour < long-entry cutoff AND no orders are open
Short: current price < current daily bar's open AND current daily bar's high - open > a configurable point distance AND hour < short-entry cutoff AND no orders are open
Exit: long, hour > market-close hour minus one
Exit: short, hour > market-close hour minus one