Calculation: Stochastic RSI K = SMA(Stochastic(RSI(close, shared RSI and stochastic lookback parameter), same shared lookback parameter), K smoothing parameter)
Calculation: Stochastic RSI D = SMA(Stochastic RSI K, D smoothing parameter)
Calculation: Initial long stop = signal-bar close − ATR(ATR lookback parameter) × ATR stop-multiplier parameter
Calculation: Long stop = initial long stop on entry; on subsequent chart bars, max(previous long stop, previous chart-bar low) when trailing is enabled, otherwise previous long stop
Calculation: Long target = signal-bar close + (signal-bar close − initial long stop) × reward/risk parameter
Calculation: Initial short stop = signal-bar close + ATR(ATR lookback parameter) × ATR stop-multiplier parameter
Calculation: Short stop = initial short stop on entry; on subsequent chart bars, min(previous short stop, previous chart-bar high) when trailing is enabled, otherwise previous short stop
Calculation: Short target = signal-bar close − (initial short stop − signal-bar close) × reward/risk parameter
Long: Stochastic RSI K crosses above Stochastic RSI D AND close > VWAP(hlc3) AND chart-bar opening datetime is within the entry-session parameter in the timezone parameter AND long-entry-enabled parameter = true AND position is flat
Short: Stochastic RSI K crosses below Stochastic RSI D AND close < VWAP(hlc3) AND chart-bar opening datetime is within the entry-session parameter in the timezone parameter AND short-entry-enabled parameter = true AND position is flat
Exit: Long, low <= long stop OR high >= long target OR chart-bar opening HHMM in the timezone parameter >= forced-exit-time parameter
Exit: Short, high >= short stop OR low <= short target OR chart-bar opening HHMM in the timezone parameter >= forced-exit-time parameter