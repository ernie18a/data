Calculation: First-hour high = high of T1 bar at time P1
Calculation: First-hour low = low of T1 bar at time P1
Calculation: Strike step = P2 if instrument is NIFTY, P3 if instrument is BANKNIFTY
Calculation: Straddle = (ceiling(First-hour high / Strike step) * Strike step + floor(First-hour low / Strike step) * Strike step) / 2
Option: sell call, abs(Price - Straddle) <= P4
Option: sell put, abs(Price - Straddle) <= P4
Option: sell call, abs(Price - Straddle) <= P4 AND First-hour high - First-hour low >= P5
Option: sell put, abs(Price - Straddle) <= P4 AND First-hour high - First-hour low >= P5