Calculation: POC = center price of the bin with the largest summed volume in the volume profile of the profile window, where the profile window is either the bars from the start of the current still-forming T1 period through the current bar (session mode) or the last profile lookback bars through the current bar (lookback mode), the profile divides the window's lowest low to highest high into profile rows equal bins, and each bar's volume is split across the bins its low-to-high range overlaps in proportion to the overlap
Long: close > VAH(profile window, profile rows, value area percent)
Long: close > POC
Short: close < VAL(profile window, profile rows, value area percent)
Short: close <= POC