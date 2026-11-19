Calculation: PPO histogram = PPO(close, fast lookback, slow lookback) − EMA(PPO(close, fast lookback, slow lookback), signal lookback), on chart bars.
Calculation: RawPhase(T) = On chart bars, use PPO and EMA(PPO, signal lookback) from the last completed T bar, calculated on T bars with the shared fast and slow lookbacks; use PPO from the last completed Tslow bar for the slow regime. Return Chop if required values are unavailable or |PPO| < chop threshold. Otherwise, if PPO > 0: return Established Bull when PPO > signal and PPO(Tslow) > 0; Emerging Bull when PPO > signal and PPO(Tslow) ≤ 0; Weakening Bull when PPO ≤ signal and the latest of the two latest completed maxima from consecutive PPO > signal runs is lower than the previous maximum; otherwise Bull Pullback. If PPO ≤ 0: return Established Bear when PPO ≤ signal and PPO(Tslow) ≤ 0; Emerging Bear when PPO ≤ signal and PPO(Tslow) > 0; Weakening Bear when PPO > signal and the latest of the two latest completed minima from consecutive PPO ≤ signal runs is higher than the previous minimum; otherwise Bear Rally.
Calculation: CommittedPhase = RawPhase(Tmid), committed on chart bars only after a new raw phase persists for N consecutive chart bars; initially Chop.
Calculation: WeightedConsensus = 0 when W1 + W2 + W3 + W4 = 0; otherwise 100 × (W1 × Score(RawPhase(T1)) + W2 × Score(RawPhase(T2)) + W3 × Score(RawPhase(T3)) + W4 × Score(RawPhase(T4))) / (W1 + W2 + W3 + W4), using the last completed bar of each T and Score(Established Bull/Bear) = ±1, Score(Bull Pullback/Bear Rally) = ±0.75, Score(Emerging Bull/Bear) = ±0.5, Score(Weakening Bull/Bear) = ±0.25, Score(Chop) = 0; positive for bull, negative for bear.
Long: RawPhase(T1) is Established Bull, Emerging Bull, or Bull Pullback.
Long: RawPhase(T2) is Established Bull, Emerging Bull, or Bull Pullback.
Long: RawPhase(T3) is Established Bull, Emerging Bull, or Bull Pullback.
Long: RawPhase(T4) is Established Bull, Emerging Bull, or Bull Pullback.
Short: RawPhase(T1) is Established Bear, Emerging Bear, or Bear Rally.
Short: RawPhase(T2) is Established Bear, Emerging Bear, or Bear Rally.
Short: RawPhase(T3) is Established Bear, Emerging Bear, or Bear Rally.
Short: RawPhase(T4) is Established Bear, Emerging Bear, or Bear Rally.
Long: WeightedConsensus ≥ bias threshold.
Short: WeightedConsensus < bias threshold AND WeightedConsensus ≤ −bias threshold.
Long: CommittedPhase is Bull Pullback AND PPO histogram > PPO histogram[1] AND PPO histogram[1] < PPO histogram[2].
Short: CommittedPhase is Bear Rally AND PPO histogram < PPO histogram[1] AND PPO histogram[1] > PPO histogram[2].