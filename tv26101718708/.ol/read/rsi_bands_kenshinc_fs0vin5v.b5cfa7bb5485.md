Calculation: RSI-level price for target RSI level L and RSI length N = let U be the EMA of max(close − previous close, 0) over 2N−1 bars and D the EMA of max(previous close − close, 0) over 2N−1 bars; let x = (N−1) × (D × L/(100−L) − U); price level = close + x when x ≥ 0, otherwise close + x × (100−L)/L
Calculation: First extended overbought level = configured overbought RSI level plus one configured extension increment
Calculation: First extended oversold level = configured oversold RSI level minus one configured extension increment
Long: low ≤ current first extended oversold price level AND previous bar low > previous first extended oversold price level
Short: high ≥ current first extended overbought price level AND previous bar high < previous first extended overbought price level