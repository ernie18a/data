Calculation: Swing high = latest confirmed pivot high on chart bars
Calculation: Swing low = latest confirmed pivot low on chart bars
Long: low < swing low AND close > swing low AND close > EMA(close, long lookback) AND within configured session AND trades today < daily trade limit AND daily P&L > daily loss limit
Short: high > swing high AND close < swing high AND close < EMA(close, long lookback) AND within configured session AND trades today < daily trade limit AND daily P&L > daily loss limit
Exit: long, low <= swing low at entry OR high >= entry signal close + (entry signal close - swing low at entry) * first target multiple OR high >= entry signal close + (entry signal close - swing low at entry) * runner target multiple
Exit: short, high >= swing high at entry OR low <= entry signal close - (swing high at entry - entry signal close) * first target multiple OR low <= entry signal close - (swing high at entry - entry signal close) * runner target multiple