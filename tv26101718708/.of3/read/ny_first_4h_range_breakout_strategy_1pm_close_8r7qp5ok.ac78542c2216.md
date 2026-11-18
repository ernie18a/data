Calculation: Opening-session high = highest high of chart bars in the configured session, reset daily and fixed after the session ends
Calculation: Opening-session low = lowest low of chart bars in the configured session, reset daily and fixed after the session ends
Calculation: Opening-session range size = opening-session high minus opening-session low
Long: after the opening-session range is fixed, close > opening-session high
Short: after the opening-session range is fixed, close < opening-session low
Calculation: Long stop price = opening-session low at the long signal if the range-stop setting is enabled, otherwise long-signal-bar close minus opening-session range size at the signal
Calculation: Long target price = long-signal-bar close + (long-signal-bar close - long stop price) * risk/reward parameter
Calculation: Short stop price = opening-session high at the short signal if the range-stop setting is enabled, otherwise short-signal-bar close plus opening-session range size at the signal
Calculation: Short target price = short-signal-bar close - (short stop price - short-signal-bar close) * risk/reward parameter
Exit: long, low <= long stop price OR high >= long target price
Exit: short, high >= short stop price OR low <= short target price