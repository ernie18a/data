Calculation: Daily close-to-high percentage = (current, still-forming higher-timeframe daily close / current daily high − 1) × 100
Calculation: Daily close-to-low percentage = (current, still-forming higher-timeframe daily close / current daily low − 1) × 100
Calculation: Long-position weighted average entry = sum(long entry price × long size) / sum(long size)
Calculation: Short-position weighted average entry = sum(short entry price × short size) / sum(short size)
Long: No open positions AND previous completed chart-timeframe bar close > open AND daily close-to-high percentage ≥ −percentage threshold
Long: At least one open long and no open shorts AND bar low < lowest long entry price − take-profit distance − spread
Short: No open positions AND previous completed chart-timeframe bar close < open AND daily close-to-low percentage ≥ percentage threshold
Short: At least one open short and no open longs AND bar high > highest short entry price + take-profit distance − spread
Exit: Long, exactly one open long AND bar high ≥ long entry price + spread + take-profit distance
Exit: Short, exactly one open short AND bar low ≤ short entry price + spread − take-profit distance
Exit: Long, at least two open longs AND bar high ≥ long-position weighted average entry + correlation distance
Exit: Short, at least two open shorts AND bar low ≤ short-position weighted average entry − correlation distance