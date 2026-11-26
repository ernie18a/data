Calculation: Session VWAP RSI = RSI(session VWAP, RSI lookback)
Short: (Session VWAP RSI crosses below oversold level OR RSI(VWAP(T1, still-forming T1 bar), RSI lookback), evaluated on chart bars using T1 values, crosses below overbought level) AND ((VIX filter disabled AND session VWAP < EMA(close, long-term lookback)) OR (VIX filter enabled AND RSI(hlc3 from external volatility series, volatility RSI lookback), evaluated on chart bars, crosses above volatility RSI level))
Exit: short, partial-exit setting enabled AND close < entry price AND Session VWAP RSI crosses above oversold level
Exit: short, Session VWAP RSI crosses above overbought level
Exit: short, close > entry price * (1 + stop-loss percentage / 100)
Short: VIX RSI(P1) crosses above P2 AND (VWAP RSI(P3) crosses below P4 OR T1 VWAP RSI(P3) crosses below P5)