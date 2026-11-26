Calculation: Side(C, P) = +1 if C is the base currency of pair P, -1 if C is the quote currency of pair P
Calculation: Vote(x) = +1 if x > neutral threshold, -1 if x < -neutral threshold, else 0
Calculation: Index(C) = product over pairs P containing C of close(P)^(Side(C, P) * ATR(P, ATR lookback)^weight exponent / sum over pairs Q containing C of ATR(Q, ATR lookback)^weight exponent)
Calculation: RawStrength(C) = EMA(ROC(Index(C), strength lookback), strength smoothing length)
Calculation: StrengthScore(C) = 100 * RawStrength(C) / max over all currencies D of abs(RawStrength(D))
Calculation: BreadthScore(C) = 100 * mean over pairs P containing C of Side(C, P) * Vote(ROC(close(P), strength lookback))
Calculation: EfficiencyScore(C) = 100 * (Index(C) - Index(C)[efficiency length]) / SUM(abs(Index(C) - Index(C)[1]), efficiency length)
Calculation: ImpulseScore(C) = clamp(impulse scale * (Index(C) - Index(C)[1]) / SMA(abs(Index(C) - Index(C)[1]), impulse length), -100, 100)
Calculation: PersistenceScore(C) = 100 * (SUM(Index(C) > Index(C)[1], persistence length) - SUM(Index(C) < Index(C)[1], persistence length)) / persistence length
Calculation: AccelerationScore(C) = clamp(100 * ((RawStrength(C) - RawStrength(C)[1]) - (RawStrength(C)[acceleration bars] - RawStrength(C)[acceleration bars + 1])) / acceleration cap, -100, 100)
Calculation: CompositeForce(C) = (w_strength * StrengthScore(C) + w_breadth * BreadthScore(C) + w_efficiency * EfficiencyScore(C) + w_impulse * ImpulseScore(C) + w_persistence * PersistenceScore(C) + w_acceleration * AccelerationScore(C)) / (w_strength + w_breadth + w_efficiency + w_impulse + w_persistence + w_acceleration)
Long: CompositeForce(base currency) - CompositeForce(quote currency) >= chart pair gap
Short: CompositeForce(base currency) - CompositeForce(quote currency) <= -chart pair gap
Long: CompositeForce(base currency) = max over all currencies D of CompositeForce(D) AND CompositeForce(quote currency) = min over all currencies D of CompositeForce(D) AND CompositeForce(base currency) - CompositeForce(quote currency) >= best pair gap
Short: CompositeForce(quote currency) = max over all currencies D of CompositeForce(D) AND CompositeForce(base currency) = min over all currencies D of CompositeForce(D) AND CompositeForce(quote currency) - CompositeForce(base currency) >= best pair gap