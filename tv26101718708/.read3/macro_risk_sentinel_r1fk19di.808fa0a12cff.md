Calculation: VIX ratio = VIX close / VIX3M close
Exit: long, (ROC(HY bond close / Treasury close, P1) < P2 OR VIX ratio > P3) AND previous bar ROC(HY bond close / Treasury close, P1) >= P2 AND previous bar VIX ratio <= P3
Long: prior bar in lockdown AND close > EMA(close, P4) AND VIX ratio < P5 AND ROC(HY bond close / Treasury close, P1) >= P2 AND VIX ratio <= P3