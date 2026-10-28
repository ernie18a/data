Calculation: Balance of Power = (close - open) / (high - low)
Calculation: Smoothed Balance of Power = arithmetic mean of Balance of Power and its EMAs with progressively longer lookbacks
Calculation: Projected Balance of Power = current Smoothed Balance of Power + the sum of its changes over each of the previous three one-bar intervals, each weighted by the volume at that interval’s earlier bar divided by the volume sum of the current and previous three bars
Long: current Projected Balance of Power > 0 AND previous Projected Balance of Power <= 0
Short: current Projected Balance of Power < 0 AND previous Projected Balance of Power >= 0
Exit: long, current Projected Balance of Power < 0 AND previous Projected Balance of Power >= 0
Exit: short, current Projected Balance of Power > 0 AND previous Projected Balance of Power <= 0