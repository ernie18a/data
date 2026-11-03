Calculation: Session VWAP = cumulative volume-weighted average of HLC3, reset at the start of each session
Calculation: Long stop = Session VWAP on the signal bar
Calculation: Long target = signal-bar close + (signal-bar close − Long stop) × configured risk-reward ratio
Calculation: Short stop = Session VWAP on the signal bar
Calculation: Short target = signal-bar close − (Short stop − signal-bar close) × configured risk-reward ratio
Long: previous bar close > previous bar open AND current bar close > current bar open AND current volume ≥ configured multiple of previous bar volume AND current bar low > Session VWAP AND current bar body > configured doji fraction × (current bar high − current bar low) AND monitoring session is active AND current weekday is enabled AND position is flat AND closed trades today = 0 OR closed trades today = 1 AND the first closed trade today had negative profit
Short: previous bar close < previous bar open AND current bar close < current bar open AND current volume ≥ configured multiple of previous bar volume AND current bar high < Session VWAP AND current bar body > configured doji fraction × (current bar high − current bar low) AND monitoring session is active AND current weekday is enabled AND position is flat AND closed trades today = 0 OR closed trades today = 1 AND the first closed trade today had negative profit
Exit: Long, current bar low ≤ Long stop OR current bar high ≥ Long target
Exit: Short, current bar high ≥ Short stop OR current bar low ≤ Short target