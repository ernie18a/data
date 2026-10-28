Calculation: Previous-day high/low = high/low of the last completed daily bar
Long: Low < previous-day low AND close > previous-day low AND close > VWAP AND close > EMA AND no open position AND configured session and daily trade limit permit trading
Short: High > previous-day high AND close < previous-day high AND close < VWAP AND close < EMA AND no open position AND configured session and daily trade limit permit trading
Exit: Long, low <= entry price - stop-loss ATR multiple × ATR OR high >= entry price + take-profit ATR multiple × ATR
Exit: Short, high >= entry price + stop-loss ATR multiple × ATR OR low <= entry price - take-profit ATR multiple × ATR