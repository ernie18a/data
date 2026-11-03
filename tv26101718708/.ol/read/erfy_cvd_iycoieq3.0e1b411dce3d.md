Calculation: Estimated delta = volume × (2 × close − high − low) / (high − low), or 0 when high = low
Calculation: Estimated CVD = cumulative sum of estimated delta, reset at each configured session boundary when session reset is enabled; otherwise cumulative continuously
Calculation: Confirmed pivot low = a low lower than the lows of the configured number of bars before and after it, confirmed after those later bars
Calculation: Confirmed pivot high = a high higher than the highs of the configured number of bars before and after it, confirmed after those later bars
Long: Current confirmed pivot low < previous confirmed pivot low AND estimated CVD at current pivot low > estimated CVD at previous pivot low
Short: Current confirmed pivot high > previous confirmed pivot high AND estimated CVD at current pivot high < estimated CVD at previous pivot high