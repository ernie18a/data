Calculation: Confirmed cycle low = a pivot low with equal left and right lookbacks, confirmed on the current bar on or after the configurable anchor date; accept it if it is the first for its cycle or its pivot bar is at least that cycle's minimum spacing after the preceding accepted pivot bar. Use four cycles with progressively longer pivot lookbacks and minimum spacings.
Calculation: Confirmed cycle high = a pivot high with equal left and right lookbacks, confirmed on the current bar on or after the configurable anchor date; accept it if it is the first or its pivot bar is at least the minimum spacing after the preceding accepted high pivot bar.
Calculation: Expected cycle length = rounded average of the most recent accepted pivot-to-pivot spacings for that cycle, or its configured fallback length if none exist.
Calculation: Cycle progress = bars since the latest accepted cycle-low pivot bar divided by its expected cycle length.
Calculation: Bear regime = close below a longer-period SMA of close AND a shorter-period SMA of close below its value a configurable number of bars earlier.
Long: A cycle low is confirmed.
Long: The shorter cycle has a confirmed low AND, since that confirmation, close has been below its SMA AND close is now above that SMA AND no earlier close above that SMA has triggered this decision since the confirmation.
Long: The second-shortest cycle progress exceeds its overdue threshold AND bear regime is false.
Short: A confirmed low of any of the three shorter cycles is below the preceding accepted low of the same cycle AND bear regime is true.
Exit: long, close is below the latest accepted low of either of the two shortest cycles.
Exit: long, a confirmed low of any of the three shorter cycles is below the preceding accepted low of the same cycle AND bear regime is false.
Exit: long, a cycle's progress reaches a configurable profit-taking threshold.
Exit: long, a cycle high is confirmed.