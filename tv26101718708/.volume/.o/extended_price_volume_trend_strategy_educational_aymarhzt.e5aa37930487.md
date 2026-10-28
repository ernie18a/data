Calculation: EPVT zero-cross price = the close of the most recent bar where cumulative sum of ((close − prior close) / prior close × volume) minus the midpoint of its lookback high and low crossed zero
Calculation: Long take-profit levels = EPVT zero-cross price × (1 + each of three increasing percentage offsets)
Calculation: Short take-profit levels = EPVT zero-cross price × (1 − each of three increasing percentage offsets)
Long: close crosses above EPVT zero-cross price
Short: close crosses below EPVT zero-cross price
Exit: long, close crosses below EPVT zero-cross price OR EMA(close, 2) crosses below any long take-profit level
Exit: short, close crosses above EPVT zero-cross price OR EMA(close, 2) crosses above any short take-profit level