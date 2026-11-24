Calculation: ClosePos = (close - low) / (high - low) if high > low, else 0.5
Calculation: KnotAsym = (lowWick - upWick) / (lowWick + upWick) if lowWick + upWick > 0, else 0, where lowWick = min(open, close) - low and upWick = high - max(open, close)
Calculation: Centroid = low + (high - low) * (0.5 + clamp(g1 * (2 * ClosePos - 1) + g2 * KnotAsym + g3 * sign(close - open), -gCap, gCap))
Calculation: FinalVol = max(volFloor, sqrt(max(0, 0.5 * ON^2 + 0.5 * IV))), where ON = 100 * ln(open / close[1]), IV = (max(0, GK) + max(0, RS)) / 2, GK = 0.5 * (100 * ln(EH / EL))^2 - (2 * ln(2) - 1) * (100 * ln(close / open))^2, RS = 100 * ln(EH / close) * 100 * ln(EH / open) + 100 * ln(EL / close) * 100 * ln(EL / open), EH = max(high, close[1]), EL = max(min(low, close[1]), 1e-8)
Calculation: DirWeight = NormCDF(100 * ln(close / ((open + close[1]) / 2)) / FinalVol)
Calculation: BuyForce = volume * ClosePos * DirWeight / (volume * (ClosePos * DirWeight + (1 - ClosePos) * (1 - DirWeight))), or 0.5 if the denominator is 0
Calculation: DynOff = offBase + offSlope * VolRegime[1]
Calculation: DynSig = sigBase + sigSlope * VolRegime[1]
Calculation: VWALMA(src, n, o, s) = sum over i = 0 to n-1 of src[i] * volume[i] * w[i], divided by sum over i = 0 to n-1 of volume[i] * w[i], where w[i] = exp(-(i - (1 - o) * (n - 1))^2 / (2 * (n / s)^2)) and i counts bars back from the current bar
Calculation: tfRatio = max(1, seconds(T1) / seconds(chart bar)) if mtfOn, else 1
Calculation: LongLen = round(tfRatio * (baseMult * maxBackstep if auto, else fixedLen))
Calculation: ShortLen = max(minShort, round(sqrt(LongLen)))
Calculation: LongAvg = VWALMA(Centroid, LongLen, DynOff, DynSig)
Calculation: FastAvg = VWALMA(Centroid, ShortLen, DynOff, DynSig)
Calculation: LongSpread = sqrt(sum over i < LongLen of (Centroid[i] - LongAvg)^2 * volume[i] * w[i] / max(1, sum over i < LongLen of volume[i] * w[i])), with w[i] as in VWALMA(Centroid, LongLen, DynOff, DynSig), or STDEV(Centroid, max(2, LongLen)) if this is 0
Calculation: CV = LongSpread / LongAvg * 100 * volume / max(1, ALMA(volume, LongLen, DynOff, DynSig))
Calculation: VolMean = sum over i < volWin of CV[i] * g[i] / sum over i < volWin of g[i], where g[i] = exp(-(i - m)^2 / (2 * s^2)), m = (volWin - 1) * (LongLen / 2) / volWin, s = volWin / volSig
Calculation: VolSd = STDEV(CV, volWin)
Calculation: VolRegime = 1 / (1 + exp(-(CV - VolMean) / VolSd))
Calculation: Skew = (sum over i < volWin of (CV[i] - VolMean)^3 / volWin) / VolSd^3
Calculation: Prob = 1 / (1 + exp(-a * (VolRegime - b))), where a = aMin + (aMax - aMin) * VolRegime * min(1, abs(Skew)) and b = clamp(bBase - kB * Skew, bLo, bHi)
Calculation: Backstep = max(1, round(maxBackstep * tfRatio - Prob * (maxBackstep - minBackstep) * tfRatio))
Calculation: Thr = LongSpread * (Prob if auto, else fixedZ)
Calculation: CanSwitch = (bar index - PivotBar[1]) >= Backstep
Calculation: LegDir = 1 if LegDir[1] != 1 AND NOT (LegDir[1] = -1 AND low < Pivot[1]) AND high > Pivot[1] + Thr AND CanSwitch AND (NOT mtfOn OR MtfTrend = 1); else -1 if LegDir[1] != -1 AND NOT (LegDir[1] = 1 AND high > Pivot[1]) AND low < Pivot[1] - Thr AND CanSwitch AND (NOT mtfOn OR MtfTrend = -1); else LegDir[1]
Calculation: LegSwitch = LegDir != LegDir[1]
Calculation: Pivot = high if LegSwitch and LegDir = 1; low if LegSwitch and LegDir = -1; high if not LegSwitch and LegDir = 1 and high > Pivot[1]; low if not LegSwitch and LegDir = -1 and low < Pivot[1]; else Pivot[1]
Calculation: PivotBar = bar index if LegSwitch or Pivot != Pivot[1], else PivotBar[1]
Calculation: SecondPivot = Pivot[1] if LegSwitch, else SecondPivot[1]
Calculation: SecondBar = PivotBar[1] if LegSwitch, else SecondBar[1]
Calculation: RawSpeed = abs(Pivot[1] - SecondPivot) / abs(SecondPivot) * 100 / max(1, PivotBar[1] - SecondBar)
Calculation: VolFactor = volume / max(1, ALMA(volume, max(normMin, round(normWin * tfRatio)), volAlmaOff, volAlmaSig))
Calculation: Momentum = max(momFloor, RawSpeed / max(1e-10, ALMA(Centroid, avgWin, DynOff, DynSig)) + 1)
Calculation: Weight = FinalVol * Momentum * min(vCap, max(vFloor2, VolFactor)) * wScale
Calculation: BuyAcc = BuyForce * Weight if LegSwitch, else BuyAcc[1] + BuyForce * Weight
Calculation: SellAcc = (1 - BuyForce) * Weight if LegSwitch, else SellAcc[1] + (1 - BuyForce) * Weight
Calculation: BuyPct = round(100 * BuyAcc / max(0.001, BuyAcc + SellAcc))
Calculation: MtfTrend = sign(ALMA(Centroid, fastLen, mtfOff, mtfSig) - ALMA(Centroid, slowLen, mtfOff, mtfSig)), with slowLen > fastLen, where Centroid and ALMA are computed on T1 bars using the last completed T1 bar, which each chart bar takes
Calculation: FastSmooth = ALMA(FastAvg, smoothLen, smoothOff, smoothSig)
Long: BuyPct > 50 AND FastAvg > FastAvg[1] AND (NOT mtfOn OR MtfTrend = 1)
Short: BuyPct < 50 AND FastAvg < FastAvg[1] AND (NOT mtfOn OR MtfTrend = -1)
Long: BuyPct > 50
Short: BuyPct < 50
Long: FastAvg > FastAvg[1]
Short: FastAvg < FastAvg[1]
Long: MtfTrend = 1
Short: MtfTrend = -1
Long: close > Centroid
Short: close <= Centroid
Long: FastSmooth > FastSmooth[1]
Short: FastSmooth <= FastSmooth[1]
Long: LegDir = 1
Short: LegDir != 1