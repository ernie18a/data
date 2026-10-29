Calculation: Footprint delta = aggressive buy volume minus aggressive sell volume at the bid and ask, respectively
Calculation: Active supply levels = highs of trapped-buyer bars that have not been reached or exceeded by a later bar's high
Calculation: Active demand levels = lows of trapped-seller bars that have not been reached or fallen below by a later bar's low
Calculation: Nearest supply = lowest active supply level above close; nearest demand = highest active demand level below close
Calculation: ATR = average true range
Long: (volume > volume SMA × volume-spike multiplier AND lower wick > abs(close − open) AND close > open AND footprint delta < 0 AND (timeline filter disabled OR datetime is within its configured range)) OR (nearest demand exists AND close − nearest demand < ATR × proximity multiplier)
Short: (volume > volume SMA × volume-spike multiplier AND upper wick > abs(close − open) AND close < open AND footprint delta > 0 AND (timeline filter disabled OR datetime is within its configured range)) OR (nearest supply exists AND nearest supply − close < ATR × proximity multiplier)