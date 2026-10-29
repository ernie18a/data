Calculation: Opening range high = highest high during the configured session’s opening range, finalized when that range ends
Calculation: Opening range low = lowest low during the configured session’s opening range, finalized when that range ends
Calculation: Long breakout level = opening range high + configured entry buffer
Calculation: Short breakout level = opening range low − configured entry buffer
Calculation: Initial long stop = the lower of (opening range low + (1 − configured stop fraction) × opening range range − configured stop buffer) and (long breakout level − minimum price increment)
Calculation: Initial short stop = the higher of (opening range high − (1 − configured stop fraction) × opening range range + configured stop buffer) and (short breakout level + minimum price increment)
Calculation: Initial long target = long breakout level + configured reward-to-risk multiple × absolute difference between long breakout level and initial long stop
Calculation: Initial short target = short breakout level − configured reward-to-risk multiple × absolute difference between short breakout level and initial short stop
Calculation: Long stop = initial long stop, raised to at least the entry price after the bar high reaches entry price + initial risk if break-even movement is enabled; initial risk is the absolute difference between entry price and initial long stop
Calculation: Short stop = initial short stop, lowered to at most the entry price after the bar low reaches entry price − initial risk if break-even movement is enabled; initial risk is the absolute difference between entry price and initial short stop
Long: close > long breakout level AND previous close ≤ previous long breakout level AND weekday is enabled AND no position is open AND no breakout has already triggered this session AND the opening range has ended AND entries are not blocked by the session or configured first-hour restriction
Short: close < short breakout level AND previous close ≥ previous short breakout level AND weekday is enabled AND no position is open AND no breakout has already triggered this session AND the opening range has ended AND entries are not blocked by the session or configured first-hour restriction
Exit: long, low ≤ long stop OR high ≥ initial long target
Exit: short, high ≥ short stop OR low ≤ initial short target