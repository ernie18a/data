Calculation: Ribbon = six moving averages of the same selected type (EMA, SMA, WMA, RMA, or VWMA) applied to a selected price source, with strictly increasing lengths; VWMA falls back to SMA when unavailable.
Calculation: Tension = sum over adjacent ribbon pairs of max(direction × (faster MA − slower MA) / normalization, 0), where direction is +1 when the fastest MA >= the slowest MA and −1 otherwise; normalization is ATR, price source / 100, or 1. Tension is undefined when the selected normalization is not positive.
Calculation: Qualified peak = a pivot high of tension with the same configurable number of bars on each side, confirmed on the last bar of that window, and peak tension >= a configurable multiple of the SMA of tension at the peak. Associate each peak with its ribbon direction, the maximum high and minimum low in its pivot window, and its bar index. Compare each qualified peak with the immediately preceding qualified peak of the same direction, provided the ribbon direction has not changed between their peak bars and their distance is <= a configurable maximum; update the preceding peak even if no divergence occurs.
Long: fastest MA >= slowest MA.
Short: fastest MA < slowest MA.
Long: any faster MA in an adjacent ribbon pair >= its slower MA.
Short: any faster MA in an adjacent ribbon pair < its slower MA.
Long: a qualified peak in a bearish ribbon has a lower window minimum low AND lower tension than the preceding comparable peak.
Short: a qualified peak in a bullish ribbon has a higher window maximum high AND lower tension than the preceding comparable peak.
Long: a qualified peak in a bullish ribbon has a lower window maximum high AND higher tension than the preceding comparable peak.
Short: a qualified peak in a bearish ribbon has a higher window minimum low AND higher tension than the preceding comparable peak.