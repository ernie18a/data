Calculation: Fast and slow trailing values = each bar, move the previous value to the bar’s close minus its distance if it is below that level, to the close plus its distance if it is above that level, and otherwise leave it unchanged; the fast distance is shorter than the slow distance
Calculation: TrailCD = fast trailing value - slow trailing value
Long: TrailCD > 0
Short: TrailCD < 0