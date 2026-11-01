Calculation: Price unit = (high - low) / volume; use 1 when this quotient is zero.
Calculation: Swing = (high - low + abs(open - close)) / (2 * price unit).
Calculation: Down-bar pressure = swing + max(open - close, 0) / price unit.
Calculation: Up-bar pressure = swing + max(close - open, 0) / price unit.
Calculation: Smoothed down-bar pressure and smoothed up-bar pressure = the same selected moving-average method and length applied separately to down-bar pressure and up-bar pressure.
Long: Previous smoothed down-bar pressure >= previous smoothed up-bar pressure AND current smoothed down-bar pressure < current smoothed up-bar pressure.
Short: Previous smoothed down-bar pressure <= previous smoothed up-bar pressure AND current smoothed down-bar pressure > current smoothed up-bar pressure.