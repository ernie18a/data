Calculation: Amihud illiquidity ratio = absolute change in close from previous bar / max(volume, 1)
Calculation: Illiquidity z-score = (Amihud illiquidity ratio - its rolling mean) / its rolling standard deviation
Long: Illiquidity z-score >= surge threshold AND close crosses above EMA AND position side is flat or short AND bars since last signal >= cooldown AND current bar is complete
Short: Illiquidity z-score >= surge threshold AND close crosses below EMA AND position side is flat or long AND bars since last signal >= cooldown AND current bar is complete