Calculation: VIDYA = recursive moving average of applied price, using smoothing factor [2 / (EMA smoothing period + 1)] × absolute Chande Momentum Oscillator(longer CMO lookback) / 100; calculate on the selected working timeframe.
Long: On the last completed working-timeframe bar, open < VIDYA AND close > VIDYA
Short: On the last completed working-timeframe bar, open > VIDYA AND close < VIDYA
Exit: Long, bar low ≤ entry price − stop-loss distance OR bar high ≥ entry price + take-profit distance OR short condition
Exit: Short, bar high ≥ entry price + stop-loss distance OR bar low ≤ entry price − take-profit distance OR long condition