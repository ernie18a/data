Calculation: Straddle = (ceil(T1 high at first-hour close / S) * S + floor(T1 low at first-hour close / S) * S) / 2, where S = S1 for NIFTY and S2 for BANKNIFTY
Option: sell call, Time >= first-hour close AND Time <= EndTime AND |Price - Straddle| <= NearDistance
Option: sell put, Time >= first-hour close AND Time <= EndTime AND |Price - Straddle| <= NearDistance