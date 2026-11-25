Long: on each T1 bar, no position is open AND the last completed T1 bar's close < the forming T1 bar's open AND the forming T1 bar's close > its open
Short: on each T1 bar, no position is open AND the last completed T1 bar's close > the forming T1 bar's open AND the forming T1 bar's close < its open
Long: a long position is open AND the lowest long entry price − current ask ≥ grid-spacing parameter × point size
Short: a short position is open AND current bid − the highest short entry price ≥ grid-spacing parameter × point size
Calculation: volume-weighted average entry price = sum(entry price × position volume) / sum(position volume)
Calculation: trailing distance = (trailing-stop parameter + broker minimum stop level) × point size
Calculation: trailing step distance = (trailing-step parameter + broker minimum stop level) × point size
Calculation: long protective stop for the initial long position = entry price − stop-loss distance when enabled; with exactly one long position, set it to entry price + trailing distance when it is unset or below entry and current bid − entry price > trailing distance + trailing step distance; when it is above entry and current bid − stop > trailing distance + trailing step distance, update it to current bid − trailing distance; otherwise retain it
Calculation: short protective stop for the initial short position = entry price + stop-loss distance when enabled; with exactly one short position, set it to entry price − trailing distance when it is unset or above entry and entry price − current ask > trailing distance + trailing step distance; when it is below entry and stop − current ask > trailing distance + trailing step distance, update it to current ask + trailing distance; otherwise retain it
Exit: long, current bid ≤ the long protective stop
Exit: short, current ask ≥ the short protective stop
Exit: long, the initial long position has its initial take-profit and (fewer than two long positions OR average take-profit is disabled) AND current bid ≥ entry price + take-profit distance
Exit: short, the initial short position has its initial take-profit and (fewer than two short positions OR average take-profit is disabled) AND current ask ≤ entry price − take-profit distance
Exit: long, at least two long positions AND average take-profit is enabled AND current bid ≥ volume-weighted average long entry price + (average-target parameter + broker minimum stop level) × point size
Exit: short, at least two short positions AND average take-profit is enabled AND current ask ≤ volume-weighted average short entry price − (average-target parameter + broker minimum stop level) × point size