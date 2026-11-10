Calculation: ATR trailing level = Let P be the previous trailing level, replaced by zero if unavailable, and D be a sensitivity multiplier times ATR. If close > P AND previous close > P, the level is max(P, close - D); otherwise, if close < P AND previous close < P, it is min(P, close + D); otherwise, if close > P, it is close - D; otherwise, it is close + D.
Calculation: Confirmed pivot high or low = A pivot high or low with equal numbers of bars on each side, available only when the right-hand bars have completed. Each newly confirmed pivot replaces the previous candidate of the same type and resets its broken state.
Long: Close crosses above the ATR trailing level.
Short: Close crosses below the ATR trailing level.
Long: Close > ATR trailing level.
Short: Close <= ATR trailing level.
Long: A pivot high is confirmed.
Short: A pivot low is confirmed.
Short: A pivot high is confirmed.
Long: A pivot low is confirmed.
Long: The latest confirmed pivot high is unbroken AND close > that pivot high, or, when wick breaks are selected, high > that pivot high; mark the candidate broken after this decision.
Short: The latest confirmed pivot low is unbroken AND close < that pivot low, or, when wick breaks are selected, low < that pivot low; mark the candidate broken after this decision.