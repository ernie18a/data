Calculation: Mayer Multiple = close / SMA(close, lookback), computed on T1 bars and mapped to chart bars using the current T1 bar (still forming in real time, lookahead off)
Long: Mayer Multiple <= deep-value threshold AND Mayer Multiple one chart bar ago > deep-value threshold
Long: Mayer Multiple <= accumulation threshold AND Mayer Multiple one chart bar ago > accumulation threshold AND Mayer Multiple > deep-value threshold
Short: Mayer Multiple >= overheated threshold AND Mayer Multiple one chart bar ago < overheated threshold
Short: Mayer Multiple >= extreme-overheated threshold AND Mayer Multiple one chart bar ago < extreme-overheated threshold