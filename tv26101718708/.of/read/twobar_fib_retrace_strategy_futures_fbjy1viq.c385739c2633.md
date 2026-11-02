Calculation: Bar 1 and bar 2 = the chart bars two bars ago and one bar ago, respectively; the current bar is the decision bar.
Calculation: Body fraction = absolute value of close minus open divided by high minus low; use zero when high equals low.
Calculation: Bull impulse = bar 1 and bar 2 body fractions are each at least the body threshold AND bar 2 volume > bar 1 volume AND ((bar 1 close > bar 1 open AND bar 2 close > bar 2 open) OR (NOT (bar 1 close > bar 1 open AND bar 2 close > bar 2 open) AND bar 2 close > bar 1 high)).
Calculation: Bear impulse = bar 1 and bar 2 body fractions are each at least the body threshold AND bar 2 volume > bar 1 volume AND ((bar 1 close < bar 1 open AND bar 2 close < bar 2 open) OR (NOT (bar 1 close < bar 1 open AND bar 2 close < bar 2 open) AND bar 2 close < bar 1 low)).
Calculation: Bull retracement bounds = bar 2 high minus the larger retracement fraction times bar 2 range, and bar 2 high minus the smaller retracement fraction times bar 2 range.
Calculation: Bear retracement bounds = bar 2 low plus the smaller retracement fraction times bar 2 range, and bar 2 low plus the larger retracement fraction times bar 2 range.
Calculation: Long entry condition = bull impulse AND (VWAP filter disabled OR current close > session VWAP of typical price) AND current low >= lower bull retracement bound AND current low <= upper bull retracement bound.
Calculation: Short entry condition = bear impulse AND (VWAP filter disabled OR current close < session VWAP of typical price) AND current high >= lower bear retracement bound AND current high <= upper bear retracement bound.
Calculation: Long stop = bar 2 low minus the stop offset at the most recent long entry condition; replace it whenever another long entry condition occurs.
Calculation: Short stop = bar 2 high plus the stop offset at the most recent short entry condition; replace it whenever another short entry condition occurs.
Long: bull impulse = true.
Long: long entry condition = true.
Short: bear impulse = true AND bull impulse = false.
Short: bear impulse = true AND (VWAP filter disabled OR current close < session VWAP of typical price) AND previous bar's VWAP-filtered bear impulse = false.
Short: short entry condition = true.
Exit: long, current low <= long stop OR short entry condition = true.
Exit: short, current high >= short stop OR long entry condition = true.