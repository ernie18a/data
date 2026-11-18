Calculation: Stochastic = 3-period simple moving average of the stochastic oscillator, using a separately parameterized lookback.
Calculation: Relative strength = RSI of close, using its own lookback parameter.
Calculation: Money flow index = MFI of hlc3, using its own lookback parameter.
Calculation: MRFI = (MFI / relative strength) × ((relative strength + MFI) / 2), clipped to 0–100.
Calculation: Inverse MRFI = (relative strength / MFI) × ((relative strength + MFI) / 2), clipped to 0–100.
Calculation: SMMRFI = a simple moving average of the average of MRFI and inverse MRFI, using its own lookback parameter.
Calculation: SMMRFI line = a simple moving average of MRFI, using its own lookback parameter.
Calculation: ATR = average true range, using its own lookback parameter.
Calculation: Long stop = signal-bar low − ATR; long target = signal-bar close × a tunable multiplier.
Calculation: Short stop = signal-bar high + ATR; short target = signal-bar close × a separately tunable multiplier.
Long: Stochastic crosses above SMMRFI OR (Stochastic ≤ oversold threshold AND SMMRFI line < lower threshold).
Short: Stochastic crosses below SMMRFI OR (Stochastic ≥ overbought threshold AND SMMRFI line > upper threshold).
Exit: Long, low ≤ long stop OR high ≥ long target.
Exit: Short, high ≥ short stop OR low ≤ short target.
Exit: Long, SMMRFI line > upper threshold AND Stochastic > upper threshold.
Exit: Short, (SMMRFI line < lower threshold AND Stochastic < lower threshold) OR Stochastic ≤ exit threshold.