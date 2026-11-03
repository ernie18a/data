Calculation: Stochastic = moving average of the close’s position within the recent high-low range
Calculation: MRFI = min(100, (MFI / RSI(close)) × ((RSI(close) + MFI) / 2)), where MFI is the ratio of rolling positive to negative volume-weighted typical-price flows
Calculation: Inverse MRFI = 100 if the uncapped MRFI exceeds 100; otherwise (RSI(close) / MFI) × ((RSI(close) + MFI) / 2)
Calculation: SMMRFI = moving average of the average of MRFI and Inverse MRFI
Calculation: SMMRFI line = moving average of MRFI
Calculation: Long stop = entry-signal bar low minus ATR
Calculation: Long target = entry-signal bar close × take-profit factor
Calculation: Short stop = entry-signal bar high plus ATR
Calculation: Short target = entry-signal bar close × take-profit factor
Long: Stochastic crosses above SMMRFI OR (Stochastic ≤ oversold threshold AND SMMRFI line < lower threshold)
Short: Stochastic crosses below SMMRFI OR (Stochastic ≥ overbought threshold AND SMMRFI line > upper threshold)
Exit: long, low ≤ Long stop OR high ≥ Long target OR (SMMRFI line > exit threshold AND Stochastic > exit threshold)
Exit: short, high ≥ Short stop OR low ≤ Short target OR (SMMRFI line < exit threshold AND Stochastic < exit threshold) OR Stochastic ≤ exit threshold