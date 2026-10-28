Calculation: Session VWAP = session-reset, volume-weighted average of close
Long: position is flat AND close < Session VWAP AND RSI < its threshold AND ADX < its threshold
Short: position is flat AND close > Session VWAP AND RSI > its threshold AND ADX < its threshold
Exit: long, low <= entry price - entry ATR × stop multiple OR high >= entry price + entry ATR × target multiple OR high >= entry price + entry ATR × trail activation multiple and low <= highest high since activation - entry ATR × trail offset multiple
Exit: short, high >= entry price + entry ATR × stop multiple OR low <= entry price - entry ATR × target multiple OR low <= entry price - entry ATR × trail activation multiple and high >= lowest low since activation + entry ATR × trail offset multiple