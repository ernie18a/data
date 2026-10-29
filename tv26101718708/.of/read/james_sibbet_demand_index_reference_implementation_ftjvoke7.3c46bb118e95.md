Calculation: P = high + low + 2 × close; Pprev = previous bar's P (use P if unavailable)
Calculation: N = highest(high, normalization length) − lowest(low, normalization length) or Wilder ATR(max(normalization length, 3)); replace values ≤ 0 with 0.0000001
Calculation: BP = selected MA(length) of (volume / selected MA(volume, length)) / exp(0.375 × ((P + Pprev) / N) × ((Pprev − P) / max(P, 0.0000001))) when P < Pprev; otherwise volume / selected MA(volume, length)
Calculation: SP = selected MA(length) of (volume / selected MA(volume, length)) / exp(0.375 × ((P + Pprev) / N) × ((P − Pprev) / max(Pprev, 0.0000001))) when P > Pprev; otherwise volume / selected MA(volume, length)
Long: BP >= SP
Short: SP > BP