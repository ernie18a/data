Calculation: Opening-range high = highest high during the configured opening-range window, using current chart bars
Calculation: Opening-range low = lowest low during the configured opening-range window, using current chart bars
Calculation: Opening-range midpoint = (opening-range high + opening-range low) / 2
Calculation: Average volume = simple moving average of volume over the configured lookback
Calculation: Long stop = opening-range low − ATR × configured buffer
Calculation: Short stop = opening-range high + ATR × configured buffer
Calculation: Risk distance = entry price − long stop for a long; short stop − entry price for a short
Calculation: Take-profit levels = entry price ± risk distance × each enabled risk/reward multiple, adding for long and subtracting for short; final target is the highest enabled multiple
Long: opening range is formed AND no confirmed breakout has occurred this session AND close > opening-range high AND volume ≥ average volume × configured breakout multiplier
Long: breakout direction is bullish AND the setup has not expired AND the configured active window is open AND (configured mode is Immediate AND (this is the confirmed breakout bar or the first active-window bar after a breakout during the wait period) OR configured mode is Midpoint Retest AND retest status is waiting AND this bar is after the breakout bar AND low ≤ opening-range midpoint AND close > opening-range midpoint OR configured mode is Breakout Retest AND retest status is waiting AND this bar is after the breakout bar AND low ≤ opening-range high AND high ≥ opening-range high AND close > opening-range high)
Short: opening range is formed AND no confirmed breakout has occurred this session AND close < opening-range low AND volume ≥ average volume × configured breakout multiplier
Short: breakout direction is bearish AND the setup has not expired AND the configured active window is open AND (configured mode is Immediate AND (this is the confirmed breakout bar or the first active-window bar after a breakout during the wait period) OR configured mode is Midpoint Retest AND retest status is waiting AND this bar is after the breakout bar AND high ≥ opening-range midpoint AND close < opening-range midpoint OR configured mode is Breakout Retest AND retest status is waiting AND this bar is after the breakout bar AND low ≤ opening-range low AND high ≥ opening-range low AND close < opening-range low)
Exit: long, low ≤ long stop OR high ≥ final take-profit level
Exit: short, high ≥ short stop OR low ≤ final take-profit level