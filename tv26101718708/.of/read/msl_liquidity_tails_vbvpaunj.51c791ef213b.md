Calculation: Upper wick = high - max(open, close)
Calculation: Lower wick = min(open, close) - low
Calculation: Body size = max(abs(close - open), minimum price increment parameter)
Calculation: Signal gap = current zero-based bar index minus the bar index of the most recent long or short signal, initialized to zero before the first signal
Long: Lower wick >= ATR multiplier parameter * ATR AND lower wick >= wick-to-body ratio parameter * body size AND lower wick > upper wick * wick dominance parameter AND signal gap > minimum gap parameter
Short: Upper wick >= ATR multiplier parameter * ATR AND upper wick >= wick-to-body ratio parameter * body size AND upper wick > lower wick * wick dominance parameter AND signal gap > minimum gap parameter