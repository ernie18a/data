Calculation: Range baseline = cumulative EMA of high − low, with update weight 2/(bar count + 1), initialized at 0.
Calculation: Streak angle = absolute degrees of atan((current close − close before the streak) / range baseline).
Calculation: Candle range threshold = EMA of average(high − low, |open − close|), using a lookback capped at the available bar count and configured maximum, divided by 4.
Long: On a confirmed bar, open < close for at least the minimum consecutive-bar count AND streak angle ≥ minimum angle AND no long mark has occurred in this uninterrupted streak.
Short: On a confirmed bar, open ≥ close for at least the minimum consecutive-bar count AND streak angle ≥ minimum angle AND no short mark has occurred in this uninterrupted streak.