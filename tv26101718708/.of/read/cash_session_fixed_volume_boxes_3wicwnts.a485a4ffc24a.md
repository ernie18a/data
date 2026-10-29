Calculation: Current box volume = sum of volume since the current box began; reset to zero when a box completes or the cash session ends.
Calculation: Current box open = open of the first bar in the current box; set to the current bar's open when a box completes or the cash session begins.
Long: During the cash session, current box volume >= the box volume target AND close > current box open
Short: During the cash session, current box volume >= the box volume target AND close < current box open