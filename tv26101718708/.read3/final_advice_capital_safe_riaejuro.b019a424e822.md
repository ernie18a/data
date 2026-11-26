Calculation: current session open = open of the first chart bar in the current session
Calculation: current session high = highest high from the start of the current session through the current chart bar
Calculation: current session low = lowest low from the start of the current session through the current chart bar
Calculation: session range midpoint = (current session high + current session low) / 2
Calculation: session body midpoint = (max(current session open, close) + min(current session open, close)) / 2
Long: close > current session open AND close > session range midpoint AND close[1] > session range midpoint AND close > session body midpoint
Short: close < current session open AND close < session range midpoint AND close[1] < session range midpoint AND close < session body midpoint
Exit: long, low <= current session low at the long-entry signal OR high >= long-entry signal close + ((long-entry signal close - current session low at the long-entry signal) * risk/reward parameter)
Exit: short, high >= current session high at the short-entry signal OR low <= short-entry signal close - ((current session high at the short-entry signal - short-entry signal close) * risk/reward parameter)