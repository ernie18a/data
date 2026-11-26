Calculation: MA(src, len, kind, T, off) = kind of src over len bars of T, taken at the last completed bar of T, shifted back off bars, rounded to tick; kind is SMA, EMA, WMA, DEMA, ZLEMA, HMA, or (highest high + lowest low) / 2 over len bars
Calculation: Envelope(X, p) = X + X * p / 100, rounded to tick
Calculation: Units(side) = round(abs(position size) / unit size of side) if position side is side, else 0
Calculation: Cap(side, U) = 4 if U is 4 or 5; 6 if U is 6; 8 if U is 9, or U is 8 and side is short; 7 if U is 8 and side is long; otherwise the Envelope 3 unit count of side
Calculation: InWindow = datetime > start AND datetime < end
Short: high >= Envelope(MA(src_so, len_so, kind_so, T1, off_so), pct_s1) AND (Units(short) = 0 OR Envelope(MA(src_sc, len_sc, kind_sc, T3, off_sc), dev_sc) > close) AND InWindow
Short: high >= Envelope(MA(src_so, len_so, kind_so, T1, off_so), pct_s2) AND (Units(short) <= Units(long)[1] + 1 OR Envelope(MA(src_sc, len_sc, kind_sc, T3, off_sc), dev_sc) > close) AND InWindow
Short: high >= Envelope(MA(src_so, len_so, kind_so, T1, off_so), pct_s3) AND (Units(short) <= Cap(short, Units(short)) OR Envelope(MA(src_sc, len_sc, kind_sc, T3, off_sc), dev_sc) > close) AND InWindow
Short: high >= Envelope(MA(src_so, len_so, kind_so, T1, off_so), pct_s4) AND (Units(short) <= Cap(short, Units(short)) + 1 OR Envelope(MA(src_sc, len_sc, kind_sc, T3, off_sc), dev_sc) > close) AND InWindow
Long: low <= Envelope(MA(src_lo, len_lo, kind_lo, T2, off_lo), pct_l1) AND (Units(long) = 0 OR Envelope(MA(src_lc, len_lc, kind_lc, T4, off_lc), dev_lc) < close) AND InWindow
Long: low <= Envelope(MA(src_lo, len_lo, kind_lo, T2, off_lo), pct_l2) AND (Units(long) <= Units(short)[1] + 1 OR Envelope(MA(src_lc, len_lc, kind_lc, T4, off_lc), dev_lc) < close) AND InWindow
Long: low <= Envelope(MA(src_lo, len_lo, kind_lo, T2, off_lo), pct_l3) AND (Units(long) <= Cap(long, Units(long)) OR Envelope(MA(src_lc, len_lc, kind_lc, T4, off_lc), dev_lc) < close) AND InWindow
Long: low <= Envelope(MA(src_lo, len_lo, kind_lo, T2, off_lo), pct_l4) AND (Units(long) <= Cap(long, Units(long)) + 1 OR Envelope(MA(src_lc, len_lc, kind_lc, T4, off_lc), dev_lc) < close) AND InWindow
Exit: short, Envelope(MA(src_sc, len_sc, kind_sc, T3, off_sc), dev_sc) > close AND InWindow
Exit: short, low <= Envelope(MA(src_sc, len_sc, kind_sc, T3, off_sc), dev_sc) AND InWindow
Exit: long, Envelope(MA(src_lc, len_lc, kind_lc, T4, off_lc), dev_lc) < close AND InWindow
Exit: long, high >= Envelope(MA(src_lc, len_lc, kind_lc, T4, off_lc), dev_lc) AND InWindow