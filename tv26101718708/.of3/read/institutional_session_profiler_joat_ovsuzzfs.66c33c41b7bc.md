Calculation: session delta = sum over completed T1 bars of the session of (buy volume - sell volume)
Calculation: value area = bins around session POC expanded until they hold value-area fraction of total session volume, using session volume profile of completed T1 bar volume over bin-count price bins
Calculation: VAH = highest price of value area
Calculation: VAL = lowest price of value area
Long: session delta(last completed Asia session) > 0 AND close > open at London session open bar
Long: session end AND session delta > strong-delta threshold AND ABS(close - VAH) <= proximity
Short: session end AND session delta < 0 AND ABS(close - VAL) <= proximity