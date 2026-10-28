Calculation: Chart-timeframe moving average = selected moving-average type (SMA, EMA, WMA, Hull, VWMA, RMA, TEMA, or Tilson T3) of close over lookback L, using the current chart bar.
Calculation: Daily moving average = the same type and lookback L applied to daily bars, using the latest available daily bar.
Long: Chart-timeframe moving average crosses below daily moving average AND bar time is within the configured entry session AND bar timestamp is within the configured date range.
Short: Chart-timeframe moving average crosses above daily moving average AND bar time is within the configured entry session AND bar timestamp is within the configured date range.
Exit: long, daily moving average / chart-timeframe moving average > configured distance threshold.
Exit: short, chart-timeframe moving average / daily moving average > configured distance threshold.