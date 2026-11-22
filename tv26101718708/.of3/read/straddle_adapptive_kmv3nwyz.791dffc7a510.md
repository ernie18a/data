Calculation: straddle close = call option close + put option close
Calculation: reference low = straddle close on the first bar of each calendar day and on each retracement exit; otherwise the lowest straddle close since then, updated only while no spike is active
Calculation: spike active = true after a long trigger; false after a retracement exit or on the first bar of a new calendar day
Calculation: VIX multiplier = multiplier 1 if VIX close < VIX threshold 1, otherwise multiplier 2 if VIX close < VIX threshold 2, otherwise multiplier 3 if VIX close < VIX threshold 3, otherwise multiplier 4; VIX threshold 1 < VIX threshold 2 < VIX threshold 3; multiplier 1 < multiplier 2 < multiplier 3 < multiplier 4
Calculation: dynamic threshold = VIX close × VIX multiplier
Calculation: spike trigger = reference low × (1 + dynamic threshold / 100)
Calculation: spike high = highest(straddle close, bars since current spike began + 1)
Calculation: retracement level = spike high - ((spike high - reference low) × retracement percentage / 100)
Long: (bar hour × 60 + bar minute) >= (start hour parameter × 60 + start minute parameter) AND not spike active AND straddle close >= spike trigger
Exit: long, spike active AND straddle close <= retracement level
Calculation: straddle premium = call option close + put option close
Calculation: reference low = first straddle premium of each T1 period, updated to the lower of the reference low and straddle premium on each eligible chart bar while no spike is active, and reset to straddle premium on a retrace sell
Calculation: VIX-adjusted trigger percentage = VIX close × (if VIX close < P4 then P7 else if VIX close < P5 then P8 else if VIX close < P6 then P9 else P10)
Calculation: retracement level = Highest(straddle premium, BarsSince(spike buy) + 1) − ((Highest(straddle premium, BarsSince(spike buy) + 1) − reference low) × (P3 / 100))
Option: buy call, chart time at or after P1:P2 AND no active spike AND straddle premium ≥ reference low × (1 + VIX-adjusted trigger percentage / 100)
Option: buy put, chart time at or after P1:P2 AND no active spike AND straddle premium ≥ reference low × (1 + VIX-adjusted trigger percentage / 100)
Option: sell call, active spike AND straddle premium ≤ retracement level
Option: sell put, active spike AND straddle premium ≤ retracement level