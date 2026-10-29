Calculation: Session pivot = (highest high + lowest low of the previous completed daily session + its closing price) / 3
Calculation: Buy area 1 = Session pivot + configured offset; Sell area 1 = Session pivot − configured offset
Calculation: Buy area 2 = Session pivot + a larger configured offset than Buy area 1; Sell area 2 = Session pivot − a larger configured offset than Sell area 1
Calculation: Buy area 3 = Session pivot + a larger configured offset than Buy area 2; Sell area 3 = Session pivot − a larger configured offset than Sell area 2
Calculation: Extended buy target = Buy area 2 + configured offset; Extended sell target = Sell area 2 − configured offset
Long: high >= Buy area 1 OR high >= Buy area 2 OR low <= Sell area 2
Short: low <= Sell area 1 OR low <= Sell area 2 OR high >= Buy area 2
Exit: long, entry price = Buy area 1 AND (high >= Buy area 2 OR low <= Sell area 1) OR entry price = Buy area 2 AND (high >= Extended buy target OR low <= Buy area 1) OR entry price = Sell area 2 AND (high >= Buy area 1 OR low <= Sell area 3)
Exit: short, entry price = Sell area 1 AND (low <= Sell area 2 OR high >= Buy area 1) OR entry price = Sell area 2 AND (low <= Extended sell target OR high >= Sell area 1) OR entry price = Buy area 2 AND (low <= Sell area 1 OR high >= Buy area 3)