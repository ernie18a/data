Calculation: Rolling VWAP_i = VWAP(hlc3, volume) on chart bars from the anchor selected by that rung’s separate lookback in T1 bars through the current chart bar; in confirmed-only mode, shift the anchor back one T1 bar and end at the last chart bar of the last completed T1 bar.
Calculation: Price position score = count(reference close > each enabled Rolling VWAP_i) / enabled rung count; reference close is the current chart close, or the last included chart close in confirmed-only mode; valid only with at least one enabled rung, a VWAP for every enabled rung, and distinct enabled lookbacks.
Calculation: Stack score = (signed adjacent-pair total − its minimum possible total) / (its maximum possible total − its minimum possible total); sort enabled rungs by increasing lookback, adding one for each shorter-lookback VWAP above the next longer-lookback VWAP by more than the tolerance, subtracting one when below by more than the tolerance, and adding zero otherwise; tolerance = T1 ATR × stack-tolerance parameter; calculate ATR on T1 bars and sample it on chart bars, using the forming T1 bar or last completed T1 bar in confirmed-only mode, with chart-bar ATR as fallback; valid only with at least two enabled rungs, a VWAP for every enabled rung, and distinct enabled lookbacks.
Calculation: Structure score = mean of Price position score and Stack score; valid only when both are valid.
Long: Price position score ≥ bullish-bias threshold
Short: Price position score < bearish-bias threshold
Long: Stack score ≥ bullish-bias threshold
Short: Stack score < bearish-bias threshold
Long: Structure score ≥ bullish-bias threshold
Short: Structure score < bearish-bias threshold