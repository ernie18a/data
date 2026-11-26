Calculation: M(T) = MACD(close, fast EMA lookback, slow EMA lookback, signal SMA lookback) calculated on T bars using the bar still forming
Long: M(T1).main > M(T1).signal
Short: M(T1).main < M(T1).signal
Long: M(T2).main > M(T2).signal
Short: M(T2).main < M(T2).signal
Long: M(T3).main > M(T3).signal
Short: M(T3).main < M(T3).signal
Long: M(T4).main > M(T4).signal
Short: M(T4).main < M(T4).signal
Long: M(T5).main > M(T5).signal
Short: M(T5).main < M(T5).signal
Long: M(T6).main > M(T6).signal
Short: M(T6).main < M(T6).signal
Long: M(T7).main > M(T7).signal
Short: M(T7).main < M(T7).signal
Long: M(T8).main > M(T8).signal
Short: M(T8).main < M(T8).signal
Long: M(T9).main > M(T9).signal
Short: M(T9).main < M(T9).signal
Long: M(T1).main > M(T1).signal AND M(T2).main > M(T2).signal
Short: M(T1).main < M(T1).signal AND M(T2).main < M(T2).signal
Long: (M(T3).main < M(T3).signal AND M(T4).main > M(T4).signal AND M(T5).main > M(T5).signal) OR (M(T3).main > M(T3).signal AND M(T4).main > M(T4).signal AND M(T5).main < M(T5).signal) OR (M(T3).main > M(T3).signal AND M(T4).main < M(T4).signal AND M(T5).main > M(T5).signal) OR (M(T3).main > M(T3).signal AND M(T4).main > M(T4).signal AND M(T5).main > M(T5).signal AND (M(T6).main > M(T6).signal OR M(T6).main < M(T6).signal))
Short: (M(T3).main > M(T3).signal AND M(T4).main < M(T4).signal AND M(T5).main < M(T5).signal) OR (M(T3).main < M(T3).signal AND M(T4).main < M(T4).signal AND M(T5).main > M(T5).signal) OR (M(T3).main < M(T3).signal AND M(T4).main > M(T4).signal AND M(T5).main < M(T5).signal) OR (M(T3).main < M(T3).signal AND M(T4).main < M(T4).signal AND M(T5).main < M(T5).signal AND (M(T6).main > M(T6).signal OR M(T6).main < M(T6).signal))
Long: M(T6).main > M(T6).signal AND M(T7).main > M(T7).signal OR M(T6).main < M(T6).signal AND M(T7).main > M(T7).signal
Short: M(T6).main > M(T6).signal AND M(T7).main < M(T7).signal OR M(T6).main < M(T6).signal AND M(T7).main < M(T7).signal
Long: M(T7).main > M(T7).signal AND ((M(T6).main > M(T6).signal AND (M(T5).signal > 0 OR M(T5).signal < 0) AND M(T5).main > M(T5).signal) OR (M(T6).main < M(T6).signal AND ((M(T5).signal < 0 AND (M(T5).main < M(T5).signal OR M(T5).main > M(T5).signal)) OR (M(T5).signal > 0 AND M(T5).main > M(T5).signal))))
Short: M(T7).main < M(T7).signal AND ((M(T6).main < M(T6).signal AND (M(T5).signal < 0 OR M(T5).signal > 0) AND M(T5).main < M(T5).signal) OR (M(T6).main > M(T6).signal AND ((M(T5).signal > 0 AND (M(T5).main > M(T5).signal OR M(T5).main < M(T5).signal)) OR (M(T5).signal < 0 AND M(T5).main < M(T5).signal))))