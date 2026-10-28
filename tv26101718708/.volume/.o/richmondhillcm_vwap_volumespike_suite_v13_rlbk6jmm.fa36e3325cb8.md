Calculation: Monthly anchored VWAP = cumulative sum of (hlc3 × volume) divided by cumulative volume since the start of the current month, including the current bar.
Long: volume > its simple moving average × threshold AND close > monthly anchored VWAP
Short: volume > its simple moving average × threshold AND close < monthly anchored VWAP
Long: Current close > monthly anchored VWAP AND previous close ≤ previous monthly anchored VWAP
Short: Current close < monthly anchored VWAP AND previous close ≥ previous monthly anchored VWAP