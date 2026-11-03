Calculation: Confirmed pivot = a pivot high or low with equal numbers of bars on each side, identified when the right-side bars have completed. Use separate lookbacks for order blocks and structure levels.
Calculation: Bullish order block = the high-to-low range of a confirmed pivot-low bar when at least three of that bar and the next three bars have close > open. Bearish order block = the high-to-low range of a confirmed pivot-high bar when at least four of that bar and the next four bars have close < open. A new block may optionally delete all existing blocks whose ranges overlap its pivot bar. A bullish block starts a deletion countdown when close < its bottom; a bearish block starts one when close > its top. Delete immediately if the delay is zero; otherwise delete when the delay elapses, unless a bar overlaps the block before then, which cancels the countdown.
Calculation: Structure high or low = the most recent confirmed pivot high or low using the structure lookback. A new pivot replaces the corresponding level. Each level can be broken only once; an upward break occurs when close > the structure high, or high > it when wick breaks are selected. A downward break occurs when close < the structure low, or low < it when wick breaks are selected.
Calculation: Volume marking eligibility = a newly created block is eligible from its pivot bar onward; when a newer block of the same direction forms, surviving older blocks become ineligible until a bar overlaps them. An eligible block remains eligible until deleted or superseded by a newer block of the same direction. Volume markings for the bars from the pivot through confirmation are produced when the block is confirmed.
Long: A bullish order block is confirmed.
Long: A structure pivot high is confirmed.
Long: An unbroken structure high is broken upward.
Long: Volume marking eligibility exists for a surviving block of either direction AND close >= open.
Short: A bearish order block is confirmed.
Short: A structure pivot low is confirmed.
Short: An unbroken structure low is broken downward.
Short: Volume marking eligibility exists for a surviving block of either direction AND close < open.
Exit: long, close < the bottom of the bullish order block underlying the position.
Exit: short, close > the top of the bearish order block underlying the position.