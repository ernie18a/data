Calculation: front-month basis = front-month futures close(T1, forming bar) - spot index close(T1, forming bar), using T1 values on chart bars
Calculation: second-month basis = second-month futures close(T1, forming bar) - spot index close(T1, forming bar), using T1 values on chart bars
Long: front-month basis > threshold AND second-month basis > threshold
Short: front-month basis < -threshold AND second-month basis < -threshold
Long: front-month VIX futures close at T1 - spot VIX close at T1 > threshold AND second-month VIX futures close at T1 - spot VIX close at T1 > threshold
Short: front-month VIX futures close at T1 - spot VIX close at T1 < -threshold AND second-month VIX futures close at T1 - spot VIX close at T1 < -threshold
Exit: long, front-month VIX futures close at T1 - spot VIX close at T1 < -threshold AND second-month VIX futures close at T1 - spot VIX close at T1 < -threshold