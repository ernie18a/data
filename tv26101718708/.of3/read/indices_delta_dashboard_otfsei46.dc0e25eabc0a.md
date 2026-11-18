Calculation: Delta = if close(T1, still-forming bar) > open(T1, still-forming bar) then volume(T1, still-forming bar) else if close(T1, still-forming bar) < open(T1, still-forming bar) then -volume(T1, still-forming bar) else 0, using T1 values on chart bars
Calculation: Session Delta = cumulative sum of Delta since the start of the current trading day, on chart bars using T1 values
Long: Delta >= 0
Short: Delta < 0
Long: Session Delta >= 0
Short: Session Delta < 0