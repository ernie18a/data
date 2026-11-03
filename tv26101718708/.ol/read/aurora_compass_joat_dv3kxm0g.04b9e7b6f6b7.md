Calculation: Current-interval volume profile = divide the price range from the lowest low to the highest high of the current higher-timeframe interval into equal bins; add each chart bar’s volume to every bin its high-low range overlaps. The higher-timeframe interval is still forming. POC is the midpoint of the bin with the greatest volume. VAH and VAL are the upper and lower edges of the smallest contiguous range around POC that contains at least the target share of total bin volume, expanding toward the adjacent bin with greater volume first. HVNs are the three bins with greatest volume.
Calculation: Profile imbalance = absolute difference between total volume assigned to positive-flow bins and total volume assigned to negative-flow bins, divided by their sum. For each bin, signed flow is the sum of each overlapping bar’s volume times its direction (+1 when close > open, otherwise −1) times its NVI weight; NVI weight = 1 + 0.3 × NVI change / max(absolute prior NVI, 1). Assign the bin’s full volume to positive or negative total according to the sign of its signed flow.
Calculation: Bias score = clamp((close − POC) / ATR, −3, 3).
Long: bullish liquidity sweep (low < bottom of any HVN AND close > top of that HVN) AND sweep detection enabled AND bar confirmed or historical
Long: POC > prior chart bar POC AND bar confirmed or historical
Long: positive-flow bin volume > negative-flow bin volume AND profile imbalance ≥ its threshold AND prior chart bar profile imbalance < its threshold AND bar confirmed or historical
Long: close > VAH AND prior chart bar close ≤ prior chart bar VAH AND bar confirmed or historical
Long: bias score > its bullish threshold
Short: bearish liquidity sweep (high > top of any HVN AND close < bottom of that HVN) AND sweep detection enabled AND bar confirmed or historical
Short: POC < prior chart bar POC AND bar confirmed or historical
Short: negative-flow bin volume > positive-flow bin volume AND profile imbalance ≥ its threshold AND prior chart bar profile imbalance < its threshold AND bar confirmed or historical
Short: close < VAL AND prior chart bar close ≥ prior chart bar VAL AND bar confirmed or historical
Short: bias score < its bearish threshold