Calculation: MF(T) = if MA lookback > 1, SMA(((Heikin-Ashi close - Heikin-Ashi open) / (Heikin-Ashi high - Heikin-Ashi low)) * (multiplier + 1), MA lookback); otherwise ((Heikin-Ashi close - Heikin-Ashi open) / (Heikin-Ashi high - Heikin-Ashi low)) * (multiplier + 1). Compute on T bars using the still-forming bar and project values to chart bars; T1 through T8 are progressively shorter timeframes.
Long: MF(chart timeframe) > 0
Short: MF(chart timeframe) <= 0
Long: MF(T1) > 0 OR MF(T2) > 0 OR MF(T3) > 0 OR MF(T4) > 0 OR MF(T5) > 0 OR MF(T6) > 0 OR MF(T7) > 0 OR MF(T8) > 0
Short: MF(T1) <= 0 OR MF(T2) <= 0 OR MF(T3) <= 0 OR MF(T4) <= 0 OR MF(T5) <= 0 OR MF(T6) <= 0 OR MF(T7) <= 0 OR MF(T8) <= 0
Long: MF(chart timeframe) > 0 AND MF(chart timeframe)[1] < 0
Short: MF(chart timeframe) < 0 AND MF(chart timeframe)[1] > 0
Long: (MF(T1) > 0 AND MF(T2) > 0 AND MF(T3) > 0) OR (MF(T2) > 0 AND MF(T3) > 0 AND MF(T4) > 0) OR (MF(T3) > 0 AND MF(T4) > 0 AND MF(T5) > 0) OR (MF(T4) > 0 AND MF(T5) > 0 AND MF(T6) > 0) OR (MF(T5) > 0 AND MF(T6) > 0 AND MF(T7) > 0) OR (MF(T6) > 0 AND MF(T7) > 0 AND MF(T8) > 0)
Short: (MF(T1) <= 0 AND MF(T2) <= 0 AND MF(T3) <= 0) OR (MF(T2) <= 0 AND MF(T3) <= 0 AND MF(T4) <= 0) OR (MF(T3) <= 0 AND MF(T4) <= 0 AND MF(T5) <= 0) OR (MF(T4) <= 0 AND MF(T5) <= 0 AND MF(T6) <= 0) OR (MF(T5) <= 0 AND MF(T6) <= 0 AND MF(T7) <= 0) OR (MF(T6) <= 0 AND MF(T7) <= 0 AND MF(T8) <= 0)