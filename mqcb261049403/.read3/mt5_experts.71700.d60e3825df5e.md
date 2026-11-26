Calculation: grid step = min(base grid step, maximum grid step) when grid multiplier ≤ 1 or same-side position count ≤ 1; otherwise min((same-side position count − 1) × grid multiplier × base grid step, maximum grid step)
Calculation: long basket break-even = bid − (sum of long-position profit and swap ÷ (tick value × sum of long-position lots) × point)
Calculation: short basket break-even = ask + (sum of short-position profit and swap ÷ (tick value × sum of short-position lots) × point)
Long: RSI(close, RSI lookback, T1, last completed T1 bar) ≤ lower RSI level AND no long position is open AND long trading is enabled AND no long close is pending
Short: RSI(close, RSI lookback, T1, last completed T1 bar) ≥ upper RSI level AND no short position is open AND short trading is enabled AND no short close is pending
Long: ask ≥ ask at the most recent timer reset + entry distance × point − point AND no long position is open AND long trading is enabled AND no long close is pending
Short: bid ≤ bid at the most recent timer reset − entry distance × point + point AND no short position is open AND short trading is enabled AND no short close is pending
Long: a long position is open AND ask ≤ last long entry price − grid step × point AND neither a long close nor an all-position close is pending
Short: a short position is open AND bid ≥ last short entry price + grid step × point AND neither a short close nor an all-position close is pending
Exit: long, take-profit distance > 0 AND bid ≥ long basket break-even + take-profit distance × point OR stop-loss distance > 0 AND bid ≤ long basket break-even − stop-loss distance × point
Exit: short, take-profit distance > 0 AND ask ≤ short basket break-even − take-profit distance × point OR stop-loss distance > 0 AND ask ≥ short basket break-even + stop-loss distance × point
Calculation: long breakeven level = long basket break-even + breakeven step × point, set when bid ≥ long basket break-even + (breakeven activation distance + breakeven step) × point
Calculation: short breakeven level = short basket break-even − breakeven step × point, set when ask ≤ short basket break-even − (breakeven activation distance + breakeven step) × point
Exit: long, breakeven stop is enabled AND long breakeven level is set AND bid ≤ long breakeven level
Exit: short, breakeven stop is enabled AND short breakeven level is set AND ask ≥ short breakeven level
Calculation: long trailing level = bid − trailing-step distance × point, updated when bid ≥ long basket break-even + (trailing-stop distance + trailing-step distance) × point AND (long trailing level is unset OR bid − (trailing-stop distance + trailing-step distance) × point ≥ previous long trailing level)
Calculation: short trailing level = ask + trailing-step distance × point, updated when ask ≤ short basket break-even − (trailing-stop distance + trailing-step distance) × point AND (short trailing level is unset OR ask + (trailing-stop distance + trailing-step distance) × point ≤ previous short trailing level)
Exit: long, trailing stop is enabled AND long trailing level > 0 AND bid ≤ long trailing level
Exit: short, trailing stop is enabled AND short trailing level > 0 AND ask ≥ short trailing level
Calculation: overlap net lots = winner lots + loser lots when the selected profitable and losing positions share a side; otherwise abs(winner lots − loser lots)
Calculation: overlap side = shared side when the selected profitable and losing positions share a side; otherwise the side of the position with larger lots
Calculation: overlap break-even = bid − ((winner profit + loser profit) ÷ (tick value × overlap net lots) × point) for long overlap side; ask + ((winner profit + loser profit) ÷ (tick value × overlap net lots) × point) for short overlap side
Exit: long, open position count ≥ overlap order threshold AND a profitable position and a losing position exist AND overlap side is long AND overlap net lots > 0 AND bid ≥ overlap break-even + overlap distance × point
Exit: short, open position count ≥ overlap order threshold AND a profitable position and a losing position exist AND overlap side is short AND overlap net lots > 0 AND ask ≤ overlap break-even − overlap distance × point