Calculation: T1 current shortest EMA = EMA(source, T1 shortest lookback, T1, still-forming bar), sampled on chart bars
Calculation: T1 current middle EMA = EMA(source, T1 middle lookback, T1, still-forming bar), sampled on chart bars
Calculation: T1 current longer EMA = EMA(source, T1 longer lookback, T1, still-forming bar), sampled on chart bars
Calculation: T1 current longest EMA = EMA(source, T1 longest lookback, T1, still-forming bar), sampled on chart bars
Calculation: T1 current RSI = RSI(source, shared RSI lookback, T1, still-forming bar), sampled on chart bars
Calculation: T1 retest band = T1 current middle EMA × retest band fraction
Calculation: T1 last completed middle EMA = EMA(source, T1 middle lookback, T1, last completed bar), sampled on chart bars
Calculation: T1 last completed longest EMA = EMA(source, T1 longest lookback, T1, last completed bar), sampled on chart bars
Calculation: T1 bar-before-last-completed middle EMA = EMA(source, T1 middle lookback, T1, bar before the last completed bar), sampled on chart bars
Calculation: T1 last completed RSI = RSI(source, shared RSI lookback, T1, last completed bar), sampled on chart bars
Calculation: T1 bar-before-last-completed RSI = RSI(source, shared RSI lookback, T1, bar before the last completed bar), sampled on chart bars
Calculation: T1 last completed StochRSI = StochRSI(source, shared RSI lookback, shared StochRSI lookback, shared K smoothing, T1, last completed bar), sampled on chart bars
Calculation: T2 current shorter EMA = EMA(source, T2 shorter lookback, T2, still-forming bar), sampled on chart bars
Calculation: T2 current longer EMA = EMA(source, T2 longer lookback, T2, still-forming bar), sampled on chart bars
Calculation: T2 last completed shorter EMA = EMA(source, T2 shorter lookback, T2, last completed bar), sampled on chart bars
Calculation: T2 last completed longer EMA = EMA(source, T2 longer lookback, T2, last completed bar), sampled on chart bars
Calculation: T2 bar-before-last-completed shorter EMA = EMA(source, T2 shorter lookback, T2, bar before the last completed bar), sampled on chart bars
Calculation: T2 last completed RSI = RSI(source, shared RSI lookback, T2, last completed bar), sampled on chart bars
Calculation: T2 bar-before-last-completed RSI = RSI(source, shared RSI lookback, T2, bar before the last completed bar), sampled on chart bars
Calculation: T2 last completed StochRSI = StochRSI(source, shared RSI lookback, shared StochRSI lookback, shared K smoothing, T2, last completed bar), sampled on chart bars
Calculation: T3 current shortest EMA = EMA(source, T3 shortest lookback, T3, still-forming bar), sampled on chart bars
Calculation: T3 current middle EMA = EMA(source, T3 middle lookback, T3, still-forming bar), sampled on chart bars
Calculation: T3 current longest EMA = EMA(source, T3 longest lookback, T3, still-forming bar), sampled on chart bars
Calculation: T3 current long SMA = SMA(source, T3 long SMA lookback, T3, still-forming bar), sampled on chart bars
Calculation: T3 last completed middle EMA = EMA(source, T3 middle lookback, T3, last completed bar), sampled on chart bars
Calculation: T3 last completed longest EMA = EMA(source, T3 longest lookback, T3, last completed bar), sampled on chart bars
Calculation: T3 bar-before-last-completed middle EMA = EMA(source, T3 middle lookback, T3, bar before the last completed bar), sampled on chart bars
Calculation: T3 last completed RSI = RSI(source, shared RSI lookback, T3, last completed bar), sampled on chart bars
Calculation: T3 bar-before-last-completed RSI = RSI(source, shared RSI lookback, T3, bar before the last completed bar), sampled on chart bars
Calculation: T3 last completed StochRSI = StochRSI(source, shared RSI lookback, shared StochRSI lookback, shared K smoothing, T3, last completed bar), sampled on chart bars
Long: On chart bars, T1 current shortest EMA > T1 current middle EMA AND T1 current middle EMA > T1 current longer EMA
Short: On chart bars, T1 current shortest EMA < T1 current middle EMA AND T1 current middle EMA < T1 current longer EMA
Long: On chart bars, close of the still-forming T1 bar > T1 current middle EMA
Short: On chart bars, close of the still-forming T1 bar <= T1 current middle EMA
Long: On chart bars, close of the still-forming T1 bar > T1 current middle EMA AND close of the still-forming T1 bar < T1 current middle EMA + T1 retest band AND (close of the still-forming T1 bar <= T1 current shortest EMA OR T1 current RSI <= momentum midpoint)
Short: On chart bars, close of the still-forming T1 bar < T1 current middle EMA AND close of the still-forming T1 bar > T1 current middle EMA - T1 retest band AND (close of the still-forming T1 bar >= T1 current shortest EMA OR T1 current RSI >= momentum midpoint)
Long: On chart bars, close of the still-forming T1 bar > T1 current longest EMA
Short: On chart bars, close of the still-forming T1 bar < T1 current longest EMA
Long: On chart bars, close of the still-forming T2 bar > T2 current shorter EMA
Short: On chart bars, close of the still-forming T2 bar < T2 current shorter EMA
Long: On chart bars, close of the still-forming T2 bar > T2 current longer EMA
Short: On chart bars, close of the still-forming T2 bar < T2 current longer EMA
Long: On chart bars, close of the still-forming T3 bar > T3 current shortest EMA
Short: On chart bars, close of the still-forming T3 bar < T3 current shortest EMA
Long: On chart bars, close of the still-forming T3 bar > T3 current middle EMA
Short: On chart bars, close of the still-forming T3 bar < T3 current middle EMA
Long: On chart bars, close of the still-forming T3 bar > T3 current longest EMA
Short: On chart bars, close of the still-forming T3 bar < T3 current longest EMA
Long: On chart bars, close of the still-forming T3 bar > T3 current long SMA
Short: On chart bars, close of the still-forming T3 bar < T3 current long SMA
Long: On chart bars, close of the last completed T1 bar > T1 last completed middle EMA AND close of the last completed T1 bar > T1 last completed longest EMA
Short: On chart bars, close of the last completed T1 bar < T1 last completed middle EMA AND close of the last completed T1 bar < T1 last completed longest EMA
Long: On chart bars, close of the last completed T2 bar > T2 last completed shorter EMA AND close of the last completed T2 bar > T2 last completed longer EMA
Short: On chart bars, close of the last completed T2 bar < T2 last completed shorter EMA AND close of the last completed T2 bar < T2 last completed longer EMA
Long: On chart bars, close of the last completed T3 bar > T3 last completed middle EMA AND close of the last completed T3 bar > T3 last completed longest EMA
Short: On chart bars, close of the last completed T3 bar < T3 last completed middle EMA AND close of the last completed T3 bar < T3 last completed longest EMA
Long: On chart bars, T1 last completed middle EMA > T1 bar-before-last-completed middle EMA
Short: On chart bars, T1 last completed middle EMA <= T1 bar-before-last-completed middle EMA
Long: On chart bars, T2 last completed shorter EMA > T2 bar-before-last-completed shorter EMA
Short: On chart bars, T2 last completed shorter EMA <= T2 bar-before-last-completed shorter EMA
Long: On chart bars, T3 last completed middle EMA > T3 bar-before-last-completed middle EMA
Short: On chart bars, T3 last completed middle EMA <= T3 bar-before-last-completed middle EMA
Long: On chart bars, T1 last completed RSI > momentum midpoint AND T1 last completed StochRSI > momentum midpoint
Short: On chart bars, T1 last completed RSI < momentum midpoint AND T1 last completed StochRSI < momentum midpoint
Long: On chart bars, T2 last completed RSI > momentum midpoint AND T2 last completed StochRSI > momentum midpoint
Short: On chart bars, T2 last completed RSI < momentum midpoint AND T2 last completed StochRSI < momentum midpoint
Long: On chart bars, T3 last completed RSI > momentum midpoint AND T3 last completed StochRSI > momentum midpoint
Short: On chart bars, T3 last completed RSI < momentum midpoint AND T3 last completed StochRSI < momentum midpoint
Long: On chart bars, T1 last completed RSI > T1 bar-before-last-completed RSI
Short: On chart bars, T1 last completed RSI <= T1 bar-before-last-completed RSI
Long: On chart bars, T2 last completed RSI > T2 bar-before-last-completed RSI
Short: On chart bars, T2 last completed RSI <= T2 bar-before-last-completed RSI
Long: On chart bars, T3 last completed RSI > T3 bar-before-last-completed RSI
Short: On chart bars, T3 last completed RSI <= T3 bar-before-last-completed RSI