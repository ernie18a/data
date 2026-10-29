Calculation: HMA(x, n) = WMA(2 × WMA(x, n/2) − WMA(x, n), round(sqrt(n)))
Calculation: THMA(x, n) = 3 × (HMA(x, n) − HMA(HMA(x, n), n)) + HMA(HMA(HMA(x, n), n), n)
Calculation: po = 100 × (short-lookback SMA or EMA of close − long-lookback SMA or EMA of close) / long-lookback SMA or EMA of close; short lookback is shorter than long lookback
Long: THMA(Heikin-Ashi close) > THMA(Heikin-Ashi open) OR (THMA(Heikin-Ashi close) crosses above THMA(Heikin-Ashi open) AND RSI of Heikin-Ashi close > 50 AND (po > 0 OR po > its previous-bar value) AND po < 2
Short: THMA(Heikin-Ashi close) ≤ THMA(Heikin-Ashi open)
Exit: long, THMA(Heikin-Ashi close) crosses below THMA(Heikin-Ashi open) AND THMA(Heikin-Ashi close) < THMA(Heikin-Ashi open)