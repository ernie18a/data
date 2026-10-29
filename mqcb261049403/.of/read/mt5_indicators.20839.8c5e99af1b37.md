Calculation: True range = the maximum of high − low, |high − previous close|, and |low − previous close|; weighted ATR = the linearly weighted average of true range over the lookback, with greater weight on more recent bars.
Calculation: BrainTrend2Stop direction = bullish when low crosses below the trailing extreme by less than the ATR threshold, and bearish when high crosses above the trailing extreme by more than the ATR threshold; flip direction when the opposing threshold is crossed. Update the trailing extreme to the running low while bullish and the running high while bearish.
Calculation: Bullish stop = low − an ATR-based offset, ratcheted so it cannot decrease while bullish; bearish stop = high + an ATR-based offset, ratcheted so it cannot increase while bearish.
Long: BrainTrend2Stop direction is bullish
Short: BrainTrend2Stop direction is bearish
Exit: long, low <= bullish stop
Exit: short, high >= bearish stop