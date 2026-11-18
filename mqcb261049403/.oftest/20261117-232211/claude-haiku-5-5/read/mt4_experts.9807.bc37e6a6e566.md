Calculation: Os(n) = OsMA(close, T1, fast period, slow period, signal period) at n bars ago on T1 bars, where 0 is the bar still forming
Long: Os(k4) > Os(k3) AND Os(k3) < Os(k2) AND Os(k2) < Os(k1) AND position side is flat
Short: Os(k4) < Os(k3) AND Os(k3) > Os(k2) AND Os(k2) > Os(k1) AND position side is flat
Exit: long, low <= entry price - stop distance OR high >= entry price + target distance
Exit: short, high >= entry price + stop distance OR low <= entry price - target distance