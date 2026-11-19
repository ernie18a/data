Calculation: ensemble member lookbacks = shortest lookback + k × member step for k = 0 through max(1, trunc((longest lookback − shortest lookback) / member step) + 1) − 1
Calculation: each member state = 1 if PGO(selected source, member lookback, selected MA type) > upper displacement threshold, −1 if it is < lower displacement threshold, otherwise its previous state (initially 0); selected MA type is SMA, EMA, WMA, or VWMA, with VWMA falling back to SMA when window volume is zero
Calculation: ensemble score = sum of member states / member count
Calculation: regime state = previous regime state until chart bar index ≥ 2 × max(shortest lookback, longest lookback); thereafter 1 if ensemble score ≥ trend threshold, −1 if ensemble score ≤ −trend threshold, 0 if flat-on-split is enabled and the score is strictly between those thresholds, otherwise the previous regime state (initially 0)
Long: regime state = 1 AND previous regime state ≠ 1
Short: regime state = −1 AND previous regime state ≠ −1
Exit: long, previous regime state = 1 AND regime state = 0
Exit: short, previous regime state = −1 AND regime state = 0