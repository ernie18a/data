Calculation: Swing high = highest high over a lookback; use the latest bar equal to that high.
Calculation: Swing low = lowest low over the same lookback; use the latest bar equal to that low.
Calculation: High age / low age = number of bars since the latest swing high / swing low.
Calculation: First projection point = swing high if high age < low age, otherwise swing low.
Calculation: Second projection point = if low age > high age, swing high − (swing high − swing low) × Fibonacci ratio; otherwise swing low + (swing high − swing low) × Fibonacci ratio.
Calculation: Third projection point = if low age < high age, second point − (second point − swing low) × Fibonacci ratio; otherwise second point + (swing high − second point) × Fibonacci ratio.
Calculation: Fourth projection point = if low age > high age, swing high − (swing high − swing low) × extension ratio; otherwise swing low + (swing high − swing low) × extension ratio.
Long: second projection point > first projection point OR third projection point > second projection point OR fourth projection point > third projection point
Short: second projection point < first projection point OR third projection point < second projection point OR fourth projection point < third projection point