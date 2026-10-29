Calculation: Fast, medium, slow, and long EMAs = EMA of close with progressively longer lookbacks
Long: Fast EMA > Medium EMA AND Medium EMA > Slow EMA AND Slow EMA > Long EMA AND the same EMA ordering was not true on the previous bar
Short: Fast EMA < Medium EMA AND Medium EMA < Slow EMA AND Slow EMA < Long EMA AND the same EMA ordering was not true on the previous bar
Exit: long, NOT (Fast EMA > Medium EMA AND Medium EMA > Slow EMA AND Slow EMA > Long EMA) AND the previous bar had that EMA ordering
Exit: short, NOT (Fast EMA < Medium EMA AND Medium EMA < Slow EMA AND Slow EMA < Long EMA) AND the previous bar had that EMA ordering