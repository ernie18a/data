Calculation: Previous-day high = high of the last completed bar aggregated on a higher timeframe than the chart timeframe
Calculation: Previous-day low = low of the last completed bar aggregated on a higher timeframe than the chart timeframe
Long: position is flat AND low < Previous-day low AND close > Previous-day low AND close > VWAP AND close > EMA AND (session filter is disabled OR bar time is within the configured session) AND (daily trade limit is disabled OR no trade has occurred today)
Short: position is flat AND high > Previous-day high AND close < Previous-day high AND close < VWAP AND close < EMA AND (session filter is disabled OR bar time is within the configured session) AND (daily trade limit is disabled OR no trade has occurred today)
Exit: long, low <= entry price - stop-loss ATR multiple × ATR OR high >= entry price + take-profit ATR multiple × ATR
Exit: short, high >= entry price + stop-loss ATR multiple × ATR OR low <= entry price - take-profit ATR multiple × ATR