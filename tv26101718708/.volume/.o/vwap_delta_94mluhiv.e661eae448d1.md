Calculation: VWAP delta close = close minus the current session’s VWAP; optionally apply a Hull moving average.
Calculation: VWAP delta open = open minus the current session’s VWAP; optionally apply the same Hull moving average as for VWAP delta close.
Calculation: VWAP delta baseline = exponential moving average of VWAP delta close.
Long: VWAP delta close > VWAP delta baseline OR VWAP delta close > VWAP delta open
Short: VWAP delta close <= VWAP delta baseline OR VWAP delta close <= VWAP delta open