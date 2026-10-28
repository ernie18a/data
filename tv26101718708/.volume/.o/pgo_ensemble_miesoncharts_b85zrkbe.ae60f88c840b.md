Calculation: Member PGO = (selected price source − selected moving average over that member’s length) / Wilder ATR over the same length; calculate members at lengths spanning shorter to longer lookbacks.
Calculation: Member state = +1 when its PGO > upper threshold, −1 when its PGO < lower threshold, otherwise retain its prior state; initialize at 0.
Calculation: Ensemble score = mean of all member states, including neutral states as 0.
Calculation: Regime = +1 when ensemble score ≥ trend threshold, −1 when ensemble score ≤ −trend threshold; otherwise retain the prior regime, or set to 0 when flat-when-split is enabled; initialize at 0 and update only when current bar index ≥ 2 × longest member length.
Long: current bar index ≥ 2 × longest member length AND ensemble score ≥ trend threshold AND prior regime ≠ +1
Short: current bar index ≥ 2 × longest member length AND ensemble score ≤ −trend threshold AND prior regime ≠ −1