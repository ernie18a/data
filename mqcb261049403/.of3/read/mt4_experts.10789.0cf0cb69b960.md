Calculation: lowest long entry price = minimum entry price of open long positions
Calculation: highest short entry price = maximum entry price of open short positions
Calculation: lot-weighted mean entry price(side) = sum(entry price × lots) / sum(lots) over open positions on that side
Long: no open positions AND −percentage threshold ≤ round(100 × close(T1, still-forming bar, sampled on chart bars) / high(T1, still-forming bar, sampled on chart bars) − 100, 2) AND close(chart, previous completed bar) > open(chart, previous completed bar)
Long: at least one open long position AND no open short positions AND current ask < lowest long entry price − distance parameter × point size + spread
Short: no open positions AND percentage threshold ≥ round(100 × close(T1, still-forming bar, sampled on chart bars) / low(T1, still-forming bar, sampled on chart bars) − 100, 2) AND close(chart, previous completed bar) < open(chart, previous completed bar)
Short: at least one open short position AND no open long positions AND current bid > highest short entry price + distance parameter × point size + spread
Exit: long, exactly one open long position AND bid ≥ entry price + spread + single-position profit target parameter × point size
Exit: long, at least two open long positions AND bid ≥ lot-weighted mean entry price(long) + basket profit offset parameter × point size
Exit: short, exactly one open short position AND ask ≤ entry price − spread − single-position profit target parameter × point size
Exit: short, at least two open short positions AND ask ≤ lot-weighted mean entry price(short) − basket profit offset parameter × point size