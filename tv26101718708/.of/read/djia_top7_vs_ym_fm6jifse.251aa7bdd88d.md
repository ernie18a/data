Calculation: Top-7 points = sum of each component’s (current price − configured reference price) divided by the Dow divisor; the reference is session open or prior session close.
Calculation: VWAP balance = 100 × (sum of reference-price weights for components trading above session VWAP − sum of weights for components trading below session VWAP); each weight is reference price divided by the sum of reference prices.
Calculation: Open move (%) = 100 × (current component price − session open) / session open.
Calculation: Gap (%) = 100 × (session open − prior session close) / prior session close.
Long: Smoothed Top-7 points > 0 AND VWAP balance > 0
Short: Smoothed Top-7 points < 0 AND VWAP balance < 0
Long: Component open move ≥ threshold AND component gap ≥ −threshold
Long: Component open move ≥ threshold AND component gap < −threshold
Short: Component open move ≤ −threshold AND component gap ≤ threshold
Short: Component open move ≤ −threshold AND component gap > threshold