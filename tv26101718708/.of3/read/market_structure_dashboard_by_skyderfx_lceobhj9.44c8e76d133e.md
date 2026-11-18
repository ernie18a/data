Calculation: Structure(T) = on each T bar, initialize trend as neutral and swing types as 0; on each confirmed Pivot high(high, P, P) or Pivot low(low, P, P), store the pivot, set its type to higher/lower than the previous confirmed pivot (first type is 0), and reset its broken flag; if close-only is enabled, use close for both break sources, otherwise use high for upward breaks and low for downward breaks; a break source above the latest unbroken pivot high sets raw trend bullish and marks that high broken, then a break source below the latest unbroken pivot low sets raw trend bearish and marks that low broken; trend persists until an opposite break, and a downward break sets the final trend bearish if both breaks occur on one bar; direction is neutral if raw trend is neutral or the mixed-swing filter is enabled and both swing types are nonzero and unequal, otherwise direction equals raw trend. Use the last completed T bar for T1–T4, calculating on T bars and sampling onto chart bars; for T0, use current chart-bar values when the chart timeframe equals T0, otherwise use the last completed T0 bar sampled onto chart bars.
Calculation: Higher-timeframe score = direction(T1) + direction(T2) + direction(T3) + direction(T4).
Long: direction(T0) is bullish AND the T0 dashboard row is enabled
Short: direction(T0) is bearish AND the T0 dashboard row is enabled
Long: direction(T1) is bullish
Short: direction(T1) is bearish
Long: direction(T2) is bullish
Short: direction(T2) is bearish
Long: direction(T3) is bullish
Short: direction(T3) is bearish
Long: direction(T4) is bullish
Short: direction(T4) is bearish
Long: higher-timeframe score > 0
Short: higher-timeframe score < 0
Long: structure-flip alerts are enabled AND raw trend(T1) is bullish AND raw trend(T1) on the previous chart bar is bearish
Short: structure-flip alerts are enabled AND raw trend(T1) is bearish AND raw trend(T1) on the previous chart bar is bullish
Long: structure-flip alerts are enabled AND raw trend(T2) is bullish AND raw trend(T2) on the previous chart bar is bearish
Short: structure-flip alerts are enabled AND raw trend(T2) is bearish AND raw trend(T2) on the previous chart bar is bullish
Long: structure-flip alerts are enabled AND raw trend(T3) is bullish AND raw trend(T3) on the previous chart bar is bearish
Short: structure-flip alerts are enabled AND raw trend(T3) is bearish AND raw trend(T3) on the previous chart bar is bullish
Long: structure-flip alerts are enabled AND raw trend(T4) is bullish AND raw trend(T4) on the previous chart bar is bearish
Short: structure-flip alerts are enabled AND raw trend(T4) is bearish AND raw trend(T4) on the previous chart bar is bullish