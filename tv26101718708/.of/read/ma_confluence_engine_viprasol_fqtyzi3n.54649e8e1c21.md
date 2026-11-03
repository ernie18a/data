Calculation: MA ribbon = 15 moving averages of a selected price source, all using the same selected MA type and parameters, with lengths increasing by a constant step from shortest to longest; Laguerre and Kalman ignore length.
Calculation: Consensus = 100 × (number of ribbon averages below the close + number of ribbon averages greater than their previous-bar values) / (2 × number of ribbon averages); an unavailable previous value counts as not rising.
Calculation: Ribbon width = (maximum ribbon average − minimum ribbon average) / ATR; use zero when ATR is not positive.
Calculation: Efficiency ratio = absolute change in close over its lookback / sum of absolute one-bar close changes over that lookback; use zero when the sum is zero.
Long: Consensus crosses above the bullish threshold AND (ribbon-width filter disabled OR ribbon width ≥ minimum) AND (efficiency filter disabled OR efficiency ratio ≥ minimum).
Short: Consensus crosses below the bearish threshold AND (ribbon-width filter disabled OR ribbon width ≥ minimum) AND (efficiency filter disabled OR efficiency ratio ≥ minimum).
Long: Consensus ≥ midpoint of its range.
Short: Consensus < midpoint of its range.