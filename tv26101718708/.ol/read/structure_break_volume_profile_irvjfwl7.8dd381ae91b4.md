Calculation: Confirmed swing high/low = highest high/lowest low in an odd-length chart-bar window centered on a candidate bar, confirmed after the window’s right half has completed.
Calculation: Unbroken pivot high/low = most recently confirmed swing high/low not yet broken; a newer confirmed pivot replaces the level.
Calculation: Structure direction = direction of the latest break, initially neutral.
Calculation: Previous structure range = highest and lowest confirmed pivots of the active structure, from the earlier pivot bar through the bar before the opposing break.
Calculation: Previous-structure POC = midpoint of the equal-width price row with the greatest volume allocated from bars in the previous structure range; allocate each bar’s volume to rows in proportion to its high-low overlap with the range, or to its close’s row if its range is zero; use volume 1 when volume is absent or nonpositive.
Long: Close > unbroken pivot high when close confirmation is selected, or high > unbroken pivot high when wick confirmation is selected
Long: Latest CHoCH is bullish AND high >= previous-structure POC AND low <= previous-structure POC AND the preceding bar did not touch that POC after the CHoCH
Short: Close < unbroken pivot low when close confirmation is selected, or low < unbroken pivot low when wick confirmation is selected
Short: Latest CHoCH is bearish AND high >= previous-structure POC AND low <= previous-structure POC AND the preceding bar did not touch that POC after the CHoCH