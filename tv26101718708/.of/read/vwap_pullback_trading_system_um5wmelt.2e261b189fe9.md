Calculation: VWAP = cumulative(hlc3*volume)/cumulative(volume) on chart-timeframe bars, reset at the start of each trading session
Calculation: Dist% = (close - VWAP)/VWAP*100
Calculation: Touch (per bar) = |low - VWAP|/VWAP*100 <= tolerance% OR low <= VWAP
Calculation: Cycle = starts at a bar with close > VWAP AND Dist% <= max extension% AND Touch; ends at the next bar with close < VWAP OR Dist% > max extension%; at most one Long per cycle
Calculation: Confirm = OR of the enabled conditions: (a) close > open; (b) engulfing: close > open AND previous close < previous open AND close >= previous open AND open <= previous close; (c) wick rejection: high > low AND (min(open,close) - low)/(high - low) >= 0.5 AND low <= VWAP*(1 + tolerance%/100) AND close > open; (d) higher low: low > lowest low of the previous N bars (excluding current bar) AND close > open; if none enabled, use (a)
Calculation: Stop = min(lowest low of last N bars including the entry bar, VWAP at the entry bar) * (1 - buffer%/100), fixed at entry
Calculation: Risk = entry price - Stop
Long: close > VWAP AND Dist% <= max extension% AND a Cycle is active at this bar (current bar included) AND no Long has fired yet in this Cycle AND Confirm; entry price = this bar's close
Exit: long, low <= Stop
Exit: long, high >= entry price + Risk * multiple (use the largest of the target multiples as the final target)