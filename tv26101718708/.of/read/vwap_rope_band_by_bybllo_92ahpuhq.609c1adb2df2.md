Calculation: VWAP = cumulative sum of ((high + low + close) / 3) * volume divided by cumulative volume, reset at the start of each session.
Calculation: Threshold = rolling population standard deviation of close minus VWAP, multiplied by a configurable multiplier; use zero until the standard deviation is available.
Calculation: Rope = previous rope + max(abs(close - previous rope) - threshold, 0) * sign(close - previous rope); initialize the rope to the first close.
Calculation: Last movement direction = direction of the most recent nonzero change in the rope; initialize to none.
Calculation: Transition = a state initially false; set it true when the rope moves opposite to its previous nonzero movement direction, set it false when a subsequent rope movement continues in the same direction as the preceding movement, and set it false when its consecutive-bar counter exceeds a configurable limit. Increment the counter on each bar in transition and reset it to zero otherwise.
Long: Rope moves up AND the previous nonzero rope movement was down.
Long: Transition is false AND last movement direction is up or none.
Short: Rope moves down AND the previous nonzero rope movement was up.
Short: Transition is true OR last movement direction is down or none.