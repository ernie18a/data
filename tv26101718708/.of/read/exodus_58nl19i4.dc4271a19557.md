Calculation: Session momentum = during the configured session, ((close − close of the first bar outside the preceding session) × cumulative session volume − the same score a lookback number of chart bars ago, substituting zero if unavailable) / (ATR + a small positive constant); undefined outside the session or when ATR is not positive.
Calculation: Volume-weighted momentum = SMA of ((close − close a momentum lookback ago) × volume / max(SMA of volume, 1)).
Calculation: Velocity efficiency = SMA of (change over a momentum lookback in EMA((high − low) / max(volume, 1)) − EMA of the change over the same lookback in EMA(max(volume, 1) / max(high − low, minimum price increment × a small positive factor))); use the same EMA period throughout and substitute zero for unavailable lagged EMA values.
Calculation: Choppiness = 100 × log10(sum of true range over the lookback / (highest high − lowest low over the same lookback)) / log10(lookback); unavailable true ranges count as zero and the result is undefined if the high-low range is zero.
Calculation: Positive vote count = number of the three momentum calculations above their respective positive thresholds; unavailable calculations contribute zero.
Calculation: Negative vote count = number of the three momentum calculations below their respective negative thresholds; unavailable calculations contribute zero.
Long: Positive vote count = 3 AND ADX > its threshold AND ATR > a multiple of its SMA AND ATR > a multiple of its value a lookback ago AND choppiness < its threshold.
Short: Negative vote count = 3 AND ADX > its threshold AND ATR > a multiple of its SMA AND ATR > a multiple of its value a lookback ago AND choppiness < its threshold.
Long: Session momentum > its positive threshold AND the full long-entry condition is false.
Short: Session momentum < its negative threshold AND the full short-entry condition is false.
Exit: long, positive vote count < 2.
Exit: short, negative vote count < 2.
Exit: long, low ≤ prior completed bar's close − prior completed bar's ATR × stop multiplier OR high ≥ prior completed bar's close + prior completed bar's ATR × profit multiplier.
Exit: short, high ≥ prior completed bar's close + prior completed bar's ATR × stop multiplier OR low ≤ prior completed bar's close − prior completed bar's ATR × profit multiplier.