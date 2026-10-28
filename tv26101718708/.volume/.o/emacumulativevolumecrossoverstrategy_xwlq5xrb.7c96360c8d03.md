Calculation: rolling VWAP = sum(typical price × volume over the lookback) / sum(volume over the lookback), where typical price = (high + low + close) / 3
Long: EMA crosses above rolling VWAP
Short: close < rolling VWAP AND close < open AND previous close < previous rolling VWAP AND previous close < previous open AND close < previous close AND EMA >= rolling VWAP
Exit: long, EMA crosses below rolling VWAP OR close < entry price × (1 − stop-loss percentage) OR close > entry price × (1 + stop-loss percentage) AND close crosses below EMA
Exit: short, (EMA < rolling VWAP AND close > rolling VWAP AND open > rolling VWAP AND close > open) OR EMA crosses above rolling VWAP OR close > entry price × (1 + stop-loss percentage) OR close < entry price × (1 − stop-loss percentage)