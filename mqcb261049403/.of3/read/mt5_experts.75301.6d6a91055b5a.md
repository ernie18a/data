Calculation: opening-gap percentage = 100 × (session open / previous cash-session close − 1)
Calculation: opening-gap midpoint = previous cash-session close + gap-fill fraction × (session open − previous cash-session close)
Calculation: opening-range high = highest(high, opening-range duration, T1, completed bars from session open)
Calculation: opening-range low = lowest(low, opening-range duration, T1, completed bars from session open)
Calculation: spread in points = (current ask − current bid) / point
Calculation: long stop = min(opening-range low − stop-buffer points × point, entry-time bid − broker minimum stop distance)
Calculation: short stop = max(opening-range high + stop-buffer points × point, entry-time ask + broker minimum stop distance)
Calculation: initial risk = abs(entry price − stop price)
Long: long-gap setup enabled AND opening-gap percentage >= long minimum gap AND datetime >= session open + opening-range duration AND datetime <= session open + entry-window duration AND lowest(low, from session open through current time, T1 including forming bar) > opening-gap midpoint AND current bid > opening-range high AND current bid > VWAP(hlc3, volume, current session, T1 including forming bar) AND long stop distance > 0 AND (spread filter disabled OR spread in points <= maximum spread points) AND (spread-to-stop filter disabled OR 100 × spread / long stop distance <= maximum spread-to-stop percentage)
Short: short-gap setup enabled AND opening-gap percentage <= −short minimum gap AND datetime >= session open + opening-range duration AND datetime <= session open + entry-window duration AND highest(high, from session open through current time, T1 including forming bar) < opening-gap midpoint AND current ask < opening-range low AND current ask < VWAP(hlc3, volume, current session, T1 including forming bar) AND short stop distance > 0 AND (spread filter disabled OR spread in points <= maximum spread points) AND (spread-to-stop filter disabled OR 100 × spread / short stop distance <= maximum spread-to-stop percentage)
Exit: long, current bid <= long stop OR current bid >= entry price + final-target R × initial risk OR datetime < session open OR datetime >= session close − forced-exit duration
Exit: long, partial close not yet done AND current bid >= entry price + partial-target R × initial risk
Exit: long, break-even stop enabled AND partial close done AND current bid <= entry price
Exit: short, current ask >= short stop OR current ask <= entry price − final-target R × initial risk OR datetime < session open OR datetime >= session close − forced-exit duration
Exit: short, partial close not yet done AND current ask <= entry price − partial-target R × initial risk
Exit: short, break-even stop enabled AND partial close done AND current ask >= entry price