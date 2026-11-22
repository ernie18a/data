Calculation: yield change(y) = SMA(close of y, smoothing length)[1] - SMA(close of y, smoothing length)[1 + observation horizon], for y in short-end yield, long-end yield, on T1 bars using last completed T1 bar
Calculation: level move = (yield change(short-end yield) + yield change(long-end yield)) / 2
Calculation: curve move = yield change(long-end yield) - yield change(short-end yield)
Calculation: observation count = number of T1 bars so far where level move and curve move are available
Calculation: observation weight = 1 if observation weighting is equal votes, otherwise SQRT(ABS(level move) * ABS(curve move))
Calculation: raw regime = Unclear if ABS(level move) < minimum average yield move OR ABS(curve move) < minimum curve move; otherwise Bull steepener if level move < 0 AND curve move > 0; Bull flattener if level move < 0 AND curve move < 0; Bear steepener if level move > 0 AND curve move > 0; Bear flattener if level move > 0 AND curve move < 0; otherwise Unclear
Calculation: regime share(r) = SUM of observation weight over last dominance window T1 bars where raw regime = r / SUM of observation weight over last dominance window T1 bars where raw regime != Unclear, for r in Bull steepener, Bull flattener, Bear steepener, Bear flattener
Calculation: candidate = Unclear if no last dominance window T1 bar has raw regime != Unclear; otherwise the regime with the largest regime share, earliest listed on ties, among Bull steepener, Bull flattener, Bear steepener, Bear flattener
Calculation: runner-up share = largest regime share among regimes other than candidate
Calculation: classified coverage = number of last dominance window T1 bars where raw regime != Unclear / MIN(dominance window, observation count)
Calculation: qualified regime = candidate if candidate != Unclear AND (NOT require complete dominance window OR observation count >= dominance window) AND classified coverage >= minimum classified coverage AND regime share(candidate) >= minimum dominant share AND regime share(candidate) - runner-up share >= minimum lead; otherwise Unclear
Calculation: pending count = 0 if qualified regime = Unclear OR qualified regime = stable regime[1]; otherwise pending count[1] + 1 if qualified regime = qualified regime[1]; otherwise 1
Calculation: stable regime = Unclear if qualified regime = Unclear AND hold previous regime when unclear is off; otherwise qualified regime if pending count >= confirmation bars; otherwise stable regime[1]; evaluated on T1 bars, chart bars take its value
Long: stable regime = Bull steepener OR stable regime = Bull flattener
Short: stable regime = Bear steepener OR stable regime = Bear flattener
Exit: long, stable regime = Unclear
Exit: short, stable regime = Unclear