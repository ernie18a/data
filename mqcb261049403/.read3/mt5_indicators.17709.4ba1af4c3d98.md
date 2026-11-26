Calculation: chart centered RSI = RSI(close, chart lookback) - 50
Calculation: T1 centered RSI = RSI(close, T1 lookback, T1, bar still forming) - 50, calculated on T1 bars and mapped to chart bars
Long: chart coloring method is direct AND chart centered RSI > chart centered RSI one chart bar ago AND chart centered RSI ≠ chart middle level
Short: chart coloring method is direct AND chart centered RSI < chart centered RSI one chart bar ago AND chart centered RSI ≠ chart middle level
Long: chart coloring method is level-based AND (chart centered RSI > chart upper level OR (chart centered RSI ≤ chart upper level AND chart centered RSI > chart middle level))
Short: chart coloring method is level-based AND chart centered RSI ≤ chart upper level AND chart centered RSI < chart middle level
Long: T1 coloring method is direct AND T1 centered RSI > T1 centered RSI one T1 bar ago AND T1 centered RSI ≠ T1 middle level
Short: T1 coloring method is direct AND T1 centered RSI < T1 centered RSI one T1 bar ago AND T1 centered RSI ≠ T1 middle level
Long: T1 coloring method is level-based AND (T1 centered RSI > T1 upper level OR (T1 centered RSI ≤ T1 upper level AND T1 centered RSI > T1 middle level))
Short: T1 coloring method is level-based AND T1 centered RSI ≤ T1 upper level AND T1 centered RSI < T1 middle level