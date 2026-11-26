Long: close[1] < open[1] AND close > open AND close >= open[1] AND open <= close[1] AND T1 close > EMA(close, major trend EMA lookback) evaluated on T1 bars, using the last completed T1 bar historically and the still-forming T1 bar in real time, with values mapped to chart bars
Short: close[1] > open[1] AND close < open AND close <= open[1] AND open >= close[1] AND T1 close < EMA(close, major trend EMA lookback) evaluated on T1 bars, using the last completed T1 bar historically and the still-forming T1 bar in real time, with values mapped to chart bars
Long: low > high[2] AND close[1] > high[2]
Short: high < low[2] AND close[1] < low[2]
Long: RSI(close, shared RSI lookback, T1 bars) > shared RSI threshold, using the last completed T1 bar historically and the still-forming T1 bar in real time, with values mapped to chart bars
Short: RSI(close, shared RSI lookback, T1 bars) <= shared RSI threshold, using the last completed T1 bar historically and the still-forming T1 bar in real time, with values mapped to chart bars
Long: RSI(close, shared RSI lookback, T2 bars) > shared RSI threshold, using the last completed T2 bar historically and the still-forming T2 bar in real time, with values mapped to chart bars
Short: RSI(close, shared RSI lookback, T2 bars) <= shared RSI threshold, using the last completed T2 bar historically and the still-forming T2 bar in real time, with values mapped to chart bars
Long: RSI(close, shared RSI lookback, T3 bars) > shared RSI threshold, using the last completed T3 bar historically and the still-forming T3 bar in real time, with values mapped to chart bars
Short: RSI(close, shared RSI lookback, T3 bars) <= shared RSI threshold, using the last completed T3 bar historically and the still-forming T3 bar in real time, with values mapped to chart bars
Long: RSI(close, shared RSI lookback, T4 bars) > shared RSI threshold, using the last completed T4 bar historically and the still-forming T4 bar in real time, with values mapped to chart bars
Short: RSI(close, shared RSI lookback, T4 bars) <= shared RSI threshold, using the last completed T4 bar historically and the still-forming T4 bar in real time, with values mapped to chart bars
Long: RSI(close, shared RSI lookback, T5 bars) > shared RSI threshold, using the last completed T5 bar historically and the still-forming T5 bar in real time, with values mapped to chart bars
Short: RSI(close, shared RSI lookback, T5 bars) <= shared RSI threshold, using the last completed T5 bar historically and the still-forming T5 bar in real time, with values mapped to chart bars
Long: RSI(close, shared RSI lookback, T6 bars) > shared RSI threshold, using the last completed T6 bar historically and the still-forming T6 bar in real time, with values mapped to chart bars
Short: RSI(close, shared RSI lookback, T6 bars) <= shared RSI threshold, using the last completed T6 bar historically and the still-forming T6 bar in real time, with values mapped to chart bars