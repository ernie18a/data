Calculation: Small VWAP = sum(typical price × volume) / sum(volume) over the shorter rolling lookback; typical price = (high + low + close) / 3
Calculation: Big VWAP = sum(typical price × volume) / sum(volume) over a longer rolling lookback than the Small VWAP
Calculation: Mean VWAP = sum(typical price × volume) / sum(volume) over a rolling lookback longer than both the Small and Big VWAP lookbacks
Calculation: Slow lead line = average of the Tenkan midpoint and Kijun midpoint. Each midpoint is the average of the rolling lowest and highest VWAP values; the Tenkan VWAP uses the shorter slow lookback, and the Kijun VWAP uses the longer slow lookback
Calculation: Fast lead line = same calculation as the Slow lead line, using shorter lookbacks than the corresponding slow lookbacks
Calculation: Upper Bollinger Band = SMA of the average of the Fast and Slow lead lines, plus a configurable multiple of their rolling standard deviation; the SMA and standard deviation use the same lookback
Calculation: TSV = rolling sum of volume × (close − previous close) over the TSV lookback; use zero when close equals the previous close
Calculation: VIDYA = recursive moving average of the configured price source, with smoothing factor 2 / (length + 1) × absolute CMO; CMO = (sum of positive changes − sum of absolute negative changes) / (sum of positive changes + sum of absolute negative changes) over the same length
Long: Small VWAP crosses below Big VWAP × (1 − configured percentage below / 100) AND EMA of RSI is below the configured maximum AND close is below Mean VWAP AND timestamp is within the configured date range AND no long position is open
Long: Fast lead line > its previous-bar value AND Slow lead line > its previous-bar value AND TSV > 0 AND TSV > its EMA AND close > Upper Bollinger Band AND close > VIDYA AND timestamp is within the configured date range AND no long position is open
Exit: long, close > Mean VWAP OR timestamp is outside the configured date range
Exit: long, Fast lead line < its previous-bar value AND Slow lead line < its previous-bar value OR timestamp is outside the configured date range