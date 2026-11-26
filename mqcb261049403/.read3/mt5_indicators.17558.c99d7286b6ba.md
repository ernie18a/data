Calculation: reversal state = initialize neutral with reference equal to the first processed close; if state >= 0, set reference to the greater of its previous value and close, then if close < reference set state negative and reference to close; else if state <= 0, set reference to the lesser of its previous value and close, then if close > reference set state positive and reference to close; otherwise retain state
Long: reversal state > 0
Short: reversal state < 0
Long: previous reversal state < 0 AND reversal state > 0
Short: previous reversal state > 0 AND reversal state < 0