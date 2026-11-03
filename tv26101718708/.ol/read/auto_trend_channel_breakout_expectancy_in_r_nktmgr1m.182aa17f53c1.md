Calculation: Upper hull boundary = line through the last two vertices of the convex hull of recent confirmed pivot highs; pivot highs require bars on both sides to confirm. Use only when its downward slope is within the valid ATR-per-bar range and it has not already broken.
Calculation: Lower hull boundary = line through the last two vertices of the convex hull of recent confirmed pivot lows; pivot lows require bars on both sides to confirm. Use only when its upward slope is within the valid ATR-per-bar range and it has not already broken.
Calculation: ATR = average true range.
Calculation: Break displacement = bar range is at least the displacement threshold times ATR AND real body is at least half the bar range.
Calculation: Channel width = maximum deviation of the opposite-side confirmed pivots from the active hull boundary.
Calculation: Long stop = the lower of the entry-bar low and entry price minus the minimum stop distance in ATRs.
Calculation: Short stop = the higher of the entry-bar high and entry price plus the minimum stop distance in ATRs.
Calculation: Target distance = the smaller of channel width and the maximum target distance in ATRs; use the ATR fallback distance if channel width is unavailable.
Long: confirmed close > upper hull boundary + ATR break buffer AND break displacement AND (close − low) / bar range ≥ anti-wick threshold AND upper boundary has not already broken; OR, in retest entry mode, an eligible upward break has armed a setup, price has touched within the ATR retest tolerance of the boundary, the setup is not invalidated or expired, and confirmed close > boundary.
Short: confirmed close < lower hull boundary − ATR break buffer AND break displacement AND (high − close) / bar range ≥ anti-wick threshold AND lower boundary has not already broken; OR, in retest entry mode, an eligible downward break has armed a setup, price has touched within the ATR retest tolerance of the boundary, the setup is not invalidated or expired, and confirmed close < boundary.
Exit: long, high ≥ target OR low ≤ stop.
Exit: short, low ≤ target OR high ≥ stop.