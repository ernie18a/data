Calculation: PH = high of the last completed T1 bar, taking values on chart bars
Calculation: PL = low of the last completed T1 bar, taking values on chart bars
Calculation: RNG = PH - PL
Calculation: AWR(n) = average of (high - low) over the last n completed T1 bars, taking values on chart bars; zoneLen and scoreLen are independent parameters
Calculation: UpperState = 2 if close > PH + acceptOffset*AWR(zoneLen); else 3 if UpperState[1] = 2 AND close < PH; else 1 if UpperState[1] = 0 AND high >= PH + sweepOffset*AWR(zoneLen) AND close < PH; else UpperState[1]; UpperState[1] is 0 on the first chart bar of each T1 period
Calculation: LowerState = 2 if close < PL - acceptOffset*AWR(zoneLen); else 3 if LowerState[1] = 2 AND close > PL; else 1 if LowerState[1] = 0 AND low <= PL - sweepOffset*AWR(zoneLen) AND close > PL; else LowerState[1]; LowerState[1] is 0 on the first chart bar of each T1 period
Calculation: GPlow = PL + RNG*(gpLoFrac+gpHiFrac)/2 - zoneHeight*AWR(zoneLen)/2
Calculation: GPhigh = PL + RNG*(gpLoFrac+gpHiFrac)/2 + zoneHeight*AWR(zoneLen)/2
Calculation: UpperScore = 10*(w_vol*c_vol + w_rng*c_rng + w_rej*c_rej + w_rnd*c_rnd + w_conf*c_conf + w_fail*c_fail + w_body*c_body)/(w_vol + w_rng + w_rej + w_rnd + w_conf + w_fail + w_body), where PC = close of the last completed T1 bar; PH2 = high of the completed T1 bar before the last completed T1 bar; PBT = highest of max(open, close) over the chart bars of the last completed T1 bar; c_vol = min(PV/SMA(T1 volume, scoreLen)/volFull, 1) with PV = volume of the last completed T1 bar and SMA over the last scoreLen completed T1 bars; c_rng = min(RNG/AWR(scoreLen)/rngFull, 1); c_rej = min((PH - PC)/RNG/rejFull, 1); c_rnd = min(d/rndFull, 1) with d = distance from PH to the nearest multiple of roundStep, in roundStep units, where roundStep = roundStepInput if above 0 else 10^(floor(log10(PC)) - 2); c_conf = 1 - min(M/confCap, 1) with M = number of the confLookback completed T1 highs before the last completed T1 bar that lie within confTol*AWR(scoreLen) of PH; c_fail = 1 if PH > PH2 and PC < PH2, failMid if PH > PH2 and PC >= PH2, failNeutral if PH <= PH2; c_body = 1 - min(max(PH - PBT, 0)/(RNG*bodyNorm), 1)
Calculation: LowerScore = UpperScore with every high-side term replaced by its low-side counterpart (PL, PL2 = low of the completed T1 bar before the last completed T1 bar, PBB = lowest of min(open, close) over the chart bars of the last completed T1 bar, low) and every distance measured in the opposite direction
Calculation: VirginHighs = set of high(j) over completed T1 bars j whose following T1 bar's range does not overlap [high(j) - zoneHeight*AWR(zoneLen)/2, high(j) + zoneHeight*AWR(zoneLen)/2]; a member starts on the first chart bar of the T1 bar after that following bar and is removed on the first chart bar whose range includes high(j)
Calculation: VirginLows = same as VirginHighs with low(j) in place of high(j)
Long: LowerScore >= strongScore AND LowerState[1] = 0 AND LowerState = 1
Long: LowerState[1] = 2 AND LowerState = 3
Long: UpperScore < strongScore AND UpperState[1] != 2 AND UpperState = 2
Long: UpperScore < strongScore AND UpperState = 2 AND low <= PH
Short: UpperScore >= strongScore AND UpperState[1] = 0 AND UpperState = 1
Short: UpperState[1] = 2 AND UpperState = 3
Short: LowerScore < strongScore AND LowerState[1] != 2 AND LowerState = 2
Short: LowerScore < strongScore AND LowerState = 2 AND high >= PL
Exit: short, UpperScore >= strongScore AND close > PH + acceptOffset*AWR(zoneLen)
Exit: short, UpperScore >= strongScore AND (low <= GPhigh OR low <= PL + eqFrac*RNG OR low <= PL)
Exit: long, LowerScore >= strongScore AND close < PL - acceptOffset*AWR(zoneLen)
Exit: long, LowerScore >= strongScore AND (high >= GPlow OR high >= PL + eqFrac*RNG OR high >= PH)
Exit: long, UpperScore < strongScore AND UpperState = 2 AND low <= GPlow
Exit: long, UpperScore < strongScore AND UpperState = 2 AND high >= PH + extFrac*RNG
Exit: short, LowerScore < strongScore AND LowerState = 2 AND high >= GPhigh
Exit: short, LowerScore < strongScore AND LowerState = 2 AND low <= PL - extFrac*RNG
Exit: long, low <= v <= high for some v in VirginHighs
Exit: short, low <= v <= high for some v in VirginLows