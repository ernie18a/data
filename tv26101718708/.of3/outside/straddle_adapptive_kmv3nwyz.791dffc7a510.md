Calculation: straddle premium = call option close + put option close
Calculation: reference low = first straddle premium of each T1 period, updated to the lower of the reference low and straddle premium on each eligible chart bar while no spike is active, and reset to straddle premium on a retrace sell
Calculation: VIX-adjusted trigger percentage = VIX close × (if VIX close < P4 then P7 else if VIX close < P5 then P8 else if VIX close < P6 then P9 else P10)
Calculation: retracement level = Highest(straddle premium, BarsSince(spike buy) + 1) − ((Highest(straddle premium, BarsSince(spike buy) + 1) − reference low) × (P3 / 100))
Option: buy call, chart time at or after P1:P2 AND no active spike AND straddle premium ≥ reference low × (1 + VIX-adjusted trigger percentage / 100)
Option: buy put, chart time at or after P1:P2 AND no active spike AND straddle premium ≥ reference low × (1 + VIX-adjusted trigger percentage / 100)
Option: sell call, active spike AND straddle premium ≤ retracement level
Option: sell put, active spike AND straddle premium ≤ retracement level