Calculation: Relative strength = if STDEV(EMA(sector close / benchmark close × 100, P1), P2) ≠ 0 then P4 + (EMA(sector close / benchmark close × 100, P1) − SMA(EMA(sector close / benchmark close × 100, P1), P2)) / STDEV(EMA(sector close / benchmark close × 100, P1), P2) else P4
Calculation: Relative momentum = if STDEV(ROC(EMA(sector close / benchmark close × 100, P1), P3), P2) ≠ 0 then P4 + (ROC(EMA(sector close / benchmark close × 100, P1), P3) − SMA(ROC(EMA(sector close / benchmark close × 100, P1), P3), P2)) / STDEV(ROC(EMA(sector close / benchmark close × 100, P1), P3), P2) else P4
Long: Relative strength ≥ P4 AND Relative momentum ≥ P4
Short: Relative strength < P4 AND Relative momentum < P4
Exit: long, Relative strength ≥ P4 AND Relative momentum < P4