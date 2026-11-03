Calculation: Confirmed swing low = a low lower than the lows of the same number of bars before and after it, confirmed on the completed chart bar after the bars following it have completed
Calculation: Confirmed swing high = a high higher than the highs of the same number of bars before and after it, confirmed on the completed chart bar after the bars following it have completed
Calculation: Bar range = max(high − low, minimum price increment)
Calculation: Lower wick ratio = (min(open, close) − low) / bar range
Calculation: Upper wick ratio = (high − max(open, close)) / bar range
Long: confirmed swing low OR (low < lowest low of the preceding sweep window AND close > low + 0.35 × bar range AND lower wick ratio ≥ 0.45), evaluated on a completed chart bar
Short: confirmed swing high OR (high > highest high of the preceding sweep window AND close < high − 0.35 × bar range AND upper wick ratio ≥ 0.45), evaluated on a completed chart bar