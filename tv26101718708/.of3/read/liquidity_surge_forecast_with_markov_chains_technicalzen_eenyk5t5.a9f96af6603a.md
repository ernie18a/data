Calculation: Projected(x) = x + ((x - x[n]) / n) * time span * forecast decay ^ time span, where n = min(slope lookback, time span)
Calculation: Momentum = clamp((HMA(X, momentum HMA length) - 50) * momentum scale, -100, 100), where X = MFI(typical price, momentum length) if momentum source is MFI, else RSI(close, momentum length)
Calculation: Oscillator = if oscillator type is Hull-VWMA then clamp(oscillator scale * 100 * (H - H[oscillator change lag]) / H[oscillator change lag], -100, 100), where H = HMA(VWMA(close, VWMA length), oscillator HMA length); otherwise clamp(HMA(ADX(ADX length) * direction, oscillator HMA length), -100, 100), where direction = 1 if +DI >= -DI else -1, from DMI(ADX length)
Calculation: Angle(src, len) = atan(((src - src[len]) / len) / stdev(src - src[1], len)), in degrees
Calculation: AngleRegime(src) = up if Angle(src, angle shorter lookback) >= angle trend threshold and Angle(src, angle longer lookback) >= angle trend threshold; down if both are <= -angle trend threshold; otherwise neither
Calculation: State = bull if at least two of AngleRegime(close), AngleRegime(high), AngleRegime(low) are up; bear if at least two are down; otherwise sideways
Calculation: CIChop = Choppiness Index(CI length) >= CI threshold
Calculation: Choppy = chop filter on and (CIChop or State = sideways)
Calculation: BullProj = Projected(Momentum) > 0 and Projected(Oscillator) > 0
Calculation: BearProj = Projected(Momentum) < 0 and Projected(Oscillator) < 0
Calculation: Duration = Duration[1] + 1 if State = State[1], else 1
Calculation: Matrix = short-duration if Duration < duration split, else long-duration
Calculation: Count(m, c, s) = count decay * Count[1](m, c, s) + 1 if m = Matrix[1] and c = (State[2], State[1]) and s = State, else count decay * Count[1](m, c, s)
Calculation: N = sum over the three states s of Count(Matrix, (State[1], State), s)
Calculation: NextProb(s) = (Count(Matrix, (State[1], State), s) + Laplace pseudocount) / (N + 3 * Laplace pseudocount)
Calculation: Confident = Markov enabled and N >= minimum sample size
Calculation: Vote = bull if NextProb(bull) >= NextProb(sideways) and NextProb(bull) >= NextProb(bear); else bear if NextProb(bear) >= NextProb(sideways); else sideways
Calculation: Hatch(d) = Confident and State = sideways and NextProb(d) >= hatch threshold, for d = bull or bear
Calculation: BullConf = BullProj and not Choppy
Calculation: BearConf = BearProj and not Choppy
Long: BullProj and not (Confident and Vote = bear) and not (chop filter on and (CIChop or (State = sideways and not Hatch(bull) and not Hatch(bear))))
Long: Hatch(bull) and not (chop filter on and CIChop) and not (BearProj and not (Confident and Vote = bull))
Long: BullConf and not BullConf[1]
Short: BearProj and not (Confident and Vote = bull) and not (chop filter on and (CIChop or (State = sideways and not Hatch(bull) and not Hatch(bear))))
Short: Hatch(bear) and not Hatch(bull) and not (chop filter on and CIChop) and not (BullProj and not (Confident and Vote = bear))
Short: BearConf and not BearConf[1]