Calculation: Prior-range ceiling = highest high over the lookback, excluding the current bar
Calculation: Prior-range floor = lowest low over the lookback, excluding the current bar
Calculation: Chandelier Exit = highest high over its lookback, including the current bar, minus a multiplier times ATR
Calculation: Entry stop = close minus twice ATR if Chandelier Exit is at or above close; otherwise Chandelier Exit
Calculation: Entry target = close plus twice the difference between close and entry stop; freeze stop and target at entry
Long: close > prior-range floor + 0.65 × (prior-range ceiling − prior-range floor) AND close <= prior-range ceiling AND volume > previous volume AND previous volume > volume two bars earlier AND volume > its moving average × a multiplier AND shorter-period EMA > longer-period EMA AND close > long-period SMA AND close > entry stop AND no open position
Exit: long, low <= frozen stop OR high >= frozen target