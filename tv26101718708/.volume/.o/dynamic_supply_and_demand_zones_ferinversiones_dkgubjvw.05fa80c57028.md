Calculation: Swing high/low = a bar whose high/low is the highest/lowest across equal lookback periods before and after it; confirm after the following lookback period completes.
Calculation: Buying-volume share = (pivot-bar close − low) / (high − low), or 0.5 when high = low; selling-volume share = 1 − buying-volume share.
Calculation: Supply zone = from the swing high down to swing high − ATR × zone-height multiplier × selling-volume share; create only if pivot-bar volume > its 20-bar volume SMA.
Calculation: Demand zone = from the swing low up to swing low + ATR × zone-height multiplier × buying-volume share; create only if pivot-bar volume > its 20-bar volume SMA.
Calculation: Active supply level = the lowest proximal boundary among active supply zones; remove a supply zone when close > its top.
Calculation: Active demand level = the highest proximal boundary among active demand zones; remove a demand zone when close < its bottom.
Long: an active demand level exists AND low crosses below it.
Short: an active supply level exists AND high crosses above it.