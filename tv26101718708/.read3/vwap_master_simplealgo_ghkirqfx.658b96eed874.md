Calculation: TP = (high + low + close) / 3
Calculation: Mean(x) = VWMA(x, volume, lookback) if rolling anchor, else anchored VWAP(x, volume) accumulated from the latest PeriodStart through this bar
Calculation: PeriodStart = NOT rolling anchor AND the T1 bar still forming at this chart bar differs from the T1 bar still forming at the previous chart bar
Calculation: VWAP = Mean(TP)
Calculation: RawSD = max(sqrt(max(Mean(TP^2) - VWAP^2, 0)), ATR(ATR length) * ATR factor)
Calculation: Dispersion = EMA(RawSD, smoothing length) if rolling anchor, else RawSD
Calculation: Z = (close - VWAP) / Dispersion
Calculation: VWAPDir = 1 if (VWAP - VWAP[trend lookback]) / Dispersion > trend threshold; -1 if (VWAP - VWAP[trend lookback]) / Dispersion < -trend threshold; else 0
Calculation: BarSide = 1 if Z > side buffer; -1 if Z < -side buffer; else BarSide[1]
Calculation: ConfirmedSide = BarSide if BarSide != 0 and BarSide is unchanged over the last side confirm bars including this bar; else 0 if PeriodStart; else ConfirmedSide[1]
Calculation: UpperVisitOpen = UpperVisit[1] AND NOT PeriodStart
Calculation: UpperVisit = Z >= band start OR (UpperVisitOpen AND Z > visit exit)
Calculation: UpPeak = max(UpPeak[1], Z) if UpperVisitOpen, else Z
Calculation: LowerVisitOpen = LowerVisit[1] AND NOT PeriodStart
Calculation: LowerVisit = Z <= -band start OR (LowerVisitOpen AND Z < -visit exit)
Calculation: DnPeak = max(DnPeak[1], -Z) if LowerVisitOpen, else -Z
Calculation: DownBounce = 1 if UpperVisitOpen AND Z < band start AND close < open AND Z[n] >= band start for some n in 1..bounce window AND UpPeak[1] >= band start + depth AND (no DownBounce earlier in this visit OR UpPeak[1] >= UpPeak at the latest earlier DownBounce in this visit + deeper step) AND (NOT trend filter enabled OR VWAPDir <= 0) AND DownBounce[n] = 0 for n in 1..min gap - 1, else 0
Calculation: UpBounce = 1 if LowerVisitOpen AND Z > -band start AND close > open AND Z[n] <= -band start for some n in 1..bounce window AND DnPeak[1] >= band start + depth AND (no UpBounce earlier in this visit OR DnPeak[1] >= DnPeak at the latest earlier UpBounce in this visit + deeper step) AND (NOT trend filter enabled OR VWAPDir >= 0) AND UpBounce[n] = 0 for n in 1..min gap - 1, else 0
Long: UpBounce = 1
Short: DownBounce = 1
Long: Z <= -(band start + depth) AND (NOT LowerVisitOpen OR DnPeak[1] < band start + depth)
Short: Z >= band start + depth AND (NOT UpperVisitOpen OR UpPeak[1] < band start + depth)
Long: ConfirmedSide = 1
Short: ConfirmedSide = -1
Long: close >= VWAP
Short: close < VWAP
Long: Z <= -band start
Short: Z >= band start
Long: VWAPDir = 1
Short: VWAPDir = -1