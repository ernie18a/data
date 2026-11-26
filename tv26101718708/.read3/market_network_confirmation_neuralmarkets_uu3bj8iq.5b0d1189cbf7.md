Calculation: Rate of change(price series, lookback) = current price series value / price series value lookback bars earlier - 1
Calculation: Sector participation = share of the eleven sector price series whose Rate of change(sector price series, P1) has the same nonzero sign as Rate of change(broad-market index price, P1)
Calculation: Sector correlation matrix = for each pair of sector price series, Pearson correlation over P3 bars of their one-bar log returns ln(price / previous price), with diagonal entries equal to 1
Calculation: Degree centralization = Freeman degree centralization of the Sector correlation matrix
Calculation: Connected components count = number of connected components of the graph of sector pairs whose Sector correlation matrix entry is at or above P4
Calculation: Sector network health = min(100, max(0, 100 * (P6 * mean absolute correlation + P7 * graph density at threshold P4 + P8 * average clustering coefficient at threshold P4 + P9 * minimum-spanning-tree compactness + P10 * strength entropy + P11 * (1 - Degree centralization) + P12 * (1 - (Connected components count - 1) / (sector count - 1)))))
Calculation: Market state = internal divergence if Rate of change(broad-market index price, P2) > 0 AND change in Sector network health over P2 bars <= -P5; else recovery broadening if Rate of change(broad-market index price, P2) < 0 AND change in Sector network health over P2 bars >= P5; else fragmentation if Sector network health < P13 OR Connected components count >= P14; else broad confirmation if Rate of change(broad-market index price, P1) > 0 AND Sector participation >= P16 AND Sector network health >= P15 AND Degree centralization <= P17; else broad selling confirmation if Rate of change(broad-market index price, P1) < 0 AND Sector participation >= P16 AND Sector network health >= P15; else distribution if Rate of change(broad-market index price, P1) < 0 AND Sector participation >= P18 AND Sector network health < P19
Long: Market state = broad confirmation
Long: Market state = recovery broadening
Short: Market state = broad selling confirmation
Short: Market state = distribution
Exit: long, Market state = internal divergence