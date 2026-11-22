Calculation: ADX value = ADX(DI length, ADX smoothing) if ADX variant is standard, otherwise Masanakamura ADX(DI length)
Calculation: trading window = (start-date filter disabled OR bar datetime >= start datetime) AND (end-date filter disabled OR bar datetime <= end datetime) AND (time-of-day filter disabled OR bar datetime converted to time zone is within time-of-day window)
Long: RSI(close, shorter lookback) crosses above long-entry level AND trading window AND trade direction allows long AND position side is not long AND (ADX filter disabled OR ADX value > ADX threshold) AND (EMA filter disabled OR EMA source > EMA(EMA source, EMA length))
Short: RSI(close, shorter lookback) crosses below short-entry level AND trading window AND trade direction allows short AND position side is not short AND (ADX filter disabled OR ADX value > ADX threshold) AND (EMA filter disabled OR EMA source < EMA(EMA source, EMA length))
Exit: long, RSI(close, longer lookback) crosses below long-exit level AND trading window
Exit: short, RSI(close, longer lookback) crosses above short-exit level AND trading window
Exit: long, close < entry price * (1 - stop-loss percent) AND trading window
Exit: short, close > entry price * (1 + stop-loss percent) AND trading window
Exit: long, (high >= entry price * (1 + take-profit 1 target) OR high >= entry price * (1 + take-profit 2 target) OR high >= entry price * (1 + take-profit 3 target) OR high >= entry price * (1 + take-profit 4 target)) AND trading window
Exit: short, (low <= entry price * (1 - take-profit 1 target) OR low <= entry price * (1 - take-profit 2 target) OR low <= entry price * (1 - take-profit 3 target) OR low <= entry price * (1 - take-profit 4 target)) AND trading window