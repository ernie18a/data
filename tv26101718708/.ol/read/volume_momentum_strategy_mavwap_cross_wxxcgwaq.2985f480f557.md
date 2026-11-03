Calculation: Selected moving average = selected SMA, EMA, RMA, WMA, or Hull moving average of close
Calculation: Session VWAP = session cumulative sum of (HLC3 × volume) divided by session cumulative volume
Long: Selected moving average crosses above session VWAP AND bar time is within the configured trading window AND long trades are allowed AND position is flat
Short: Selected moving average crosses below session VWAP AND bar time is within the configured trading window AND short trades are allowed AND position is flat
Exit: Long, bar low ≤ entry-based stop-loss level OR bar high ≥ entry-based take-profit level OR bar time ≥ configured close-all time OR a short entry condition occurs
Exit: Short, bar high ≥ entry-based stop-loss level OR bar low ≤ entry-based take-profit level OR bar time ≥ configured close-all time OR a long entry condition occurs