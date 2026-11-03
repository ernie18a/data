Calculation: Reference = EMA of close, or, if adaptive mode is enabled, EMA of close minus a deviation multiplier times the standard deviation of close when close >= EMA, otherwise EMA plus that deviation adjustment.
Calculation: Ledger imbalance = (rolling sum of volume on bars with close >= open minus rolling sum of volume on bars with close < open) / max(rolling sum of volume, a positive volume floor).
Calculation: Shelf bins = divide the rolling range from lowest low to highest high into equal-width bins; assign each bar's entire volume to the bin containing (high + low + close) / 3, clamping the index to the first or last bin. Shelf strength is bin volume divided by the maximum bin volume, or zero when that maximum is zero. A shelf's price is its bin midpoint.
Calculation: Point of control = midpoint of the first shelf bin with the maximum bin volume.
Calculation: Reference range share = (reference - rolling lowest low) / max(rolling highest high - rolling lowest low, a positive price floor).
Long: Close >= reference.
Short: Close < reference.
Long: Ledger imbalance >= 0.
Short: Ledger imbalance < 0.
Long: Ledger imbalance > a positive threshold AND close >= reference.
Short: Ledger imbalance < the negative of that threshold AND close <= reference.
Long: Shelf strength >= minimum strength AND shelf midpoint < reference AND rolling highest high > rolling lowest low.
Short: Shelf strength >= minimum strength AND shelf midpoint >= reference AND rolling highest high > rolling lowest low.
Long: Point of control < reference AND rolling highest high > rolling lowest low.
Short: Point of control >= reference AND rolling highest high > rolling lowest low.
Long: Close >= point of control AND rolling highest high > rolling lowest low.
Short: Close < point of control AND rolling highest high > rolling lowest low.
Long: Reference range share < one half.
Short: Reference range share >= one half.