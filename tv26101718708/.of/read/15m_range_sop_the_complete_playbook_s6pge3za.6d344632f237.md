Calculation: Reference range high/low = highest high / lowest low during the configured reference session, using chart-timeframe bars
Calculation: Prior swing high/low = highest high / lowest low over the configured lookback, ending on the bar before the reference session starts
Calculation: Long/short target midpoint = midpoint between the corresponding range boundary and prior swing high/low
Calculation: Volume delta = volume × (2 × (close − low) / (high − low) − 1); use 0 when high = low
Long: Within the active range projection AND a top sweep (high > reference range high AND close ≤ reference range high) and a bottom sweep (low < reference range low AND close ≥ reference range low) have both occurred AND close > reference range high AND volume delta > 0 AND no earlier long signal this session
Short: Within the active range projection AND a top sweep (high > reference range high AND close ≤ reference range high) and a bottom sweep (low < reference range low AND close ≥ reference range low) have both occurred AND close < reference range low AND volume delta < 0 AND no earlier short signal this session
Exit: long, a long signal has occurred AND high ≥ long target midpoint
Exit: long, a long signal has occurred AND high ≥ prior swing high
Exit: short, a short signal has occurred AND low ≤ short target midpoint
Exit: short, a short signal has occurred AND low ≤ prior swing low