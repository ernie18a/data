Calculation: MACD diff(T) = MACD main line minus its signal line on bars of timeframe T, where main = EMA(close, fast) - EMA(close, slow) with fast lookback shorter than slow, and signal = SMA of main over a separate signal lookback; always use the still-forming bar of T (not the last completed one). T comes from a fixed ascending ladder of nine timeframes T1<T2<...<T9, independent of the chart timeframe and aggregated from the base bars.
Long: MACD diff(T1) > 0 AND MACD diff(T2) > 0 (two shortest timeframes)
Long: at least two of MACD diff(T3), MACD diff(T4), MACD diff(T5) are > 0 AND none of the three equals 0 (three middle timeframes, higher than T1 and T2; T6 is ignored)
Long: MACD diff(Tk) > 0 for any single k in T1..T9 (per-timeframe bullish marking)
Short: MACD diff(T1) < 0 AND MACD diff(T2) < 0
Short: at least two of MACD diff(T3), MACD diff(T4), MACD diff(T5) are < 0 AND none of the three equals 0
Short: MACD diff(Tk) < 0 for any single k in T1..T9 (per-timeframe bearish marking)