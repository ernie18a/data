Calculation: Previous-day pivot P = (previous completed day's high + low + close) / 3
Calculation: R1 = 2 × P − previous completed day's low
Calculation: R2 = P + (previous completed day's high − low)
Calculation: R3 = previous completed day's high + 2 × (P − previous completed day's low)
Calculation: S1 = 2 × P − previous completed day's high
Calculation: S2 = P − (previous completed day's high − low)
Calculation: S3 = previous completed day's low − 2 × (previous completed day's high − P)
Calculation: R4 = R3 + (R1 − S1)
Calculation: R5 = R4 + (R1 − S1)
Calculation: S4 = S3 − (R1 − S1)
Calculation: S5 = S4 − (R1 − S1)
Calculation: Session VWAP = cumulative (typical price × volume) / cumulative volume, resetting at the start of each market session; typical price = (high + low + close) / 3
Long: flat position AND within the configured trading window AND daily entry count below its limit AND session VWAP is available AND (for any of P, R1–R5, S1–S5: low < level AND low < session VWAP AND close > level AND close > session VWAP)
Short: flat position AND within the configured trading window AND daily entry count below its limit AND session VWAP is available AND (for any of P, R1–R5, S1–S5: high > level AND high > session VWAP AND close < level AND close < session VWAP)
Exit: long, session VWAP is available AND consecutive closes are below session VWAP
Exit: short, session VWAP is available AND consecutive closes are above session VWAP