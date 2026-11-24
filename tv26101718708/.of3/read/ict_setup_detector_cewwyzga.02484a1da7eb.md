Calculation: StructBias(Tk, pk) = 1 if the last two confirmed pivot highs and the last two confirmed pivot lows of Tk bars (pk bars on each side) both rise, -1 if both fall, else 0; uses last completed Tk bar
Calculation: MomBias(Tk) = 1 if fastEMA > slowEMA AND close > fastEMA; -1 if fastEMA < slowEMA AND close < fastEMA; else 0; fastEMA = EMA(close, shorter lookback, Tk, last completed bar); slowEMA = EMA(close, longer lookback, Tk, last completed bar); close = close, Tk, last completed bar
Calculation: Bias1 = StructBias(T1, p1) if the T1 source selects structure, else MomBias(T1)
Calculation: Bias2 = StructBias(T2, p2) if the T2 source selects structure, else MomBias(T2)
Calculation: Bias3 = StructBias(T3, p3) if the T3 source selects structure, else MomBias(T3)
Calculation: GapState = 0 before the first-hour end time; from the first-hour end time on, 0 if the day's gap (RTH open - prior RTH close) was filled by a bar from RTH open time to first-hour end time (up-gap filled when low <= prior RTH close; down-gap filled when high >= prior RTH close), else sign(gap); prior RTH close = last close before RTH close time on the previous session
Calculation: LongsAllowed = NOT gate-enabled OR (any of Bias1, Bias2, Bias3 = 1 AND none of them = -1 AND (NOT gap-required OR GapState != -1))
Calculation: ShortsAllowed = NOT gate-enabled OR (any of Bias1, Bias2, Bias3 = -1 AND none of them = 1 AND (NOT gap-required OR GapState != 1))
Calculation: InKillzone = bar time (NY) is within any killzone window
Calculation: ONHigh = highest high from the latest overnight start time to the RTH open time (NY)
Calculation: ONLow = lowest low from the latest overnight start time to the RTH open time (NY)
Calculation: PDH = high[1] of T4 bars, last completed bar
Calculation: PDL = low[1] of T4 bars, last completed bar
Calculation: BSLSweep = OR over L in {ONHigh, PDH} of (L not yet swept since its reset AND bar not in overnight window AND max(high over last sweep breach window bars incl. current) > L AND close < L); ON levels reset at overnight start, PDH at NY midnight
Calculation: SSLSweep = OR over L in {ONLow, PDL} of (L not yet swept since its reset AND bar not in overnight window AND min(low over last sweep breach window bars incl. current) < L AND close > L); ON levels reset at overnight start, PDL at NY midnight
Calculation: RecentSweepDir = +1 if the latest bar with BSLSweep or SSLSweep (incl. current bar) is within the last sweep lookback bars and is a BSLSweep, -1 if it is an SSLSweep, else 0
Calculation: DispUp = close[1] > open[1] AND abs(close[1] - open[1]) >= ATR(ATR length) * displacement multiple AND (NOT volume-required OR volume[1] >= SMA(volume, volume length)[1] * volume multiple)
Calculation: DispDown = close[1] < open[1] AND abs(close[1] - open[1]) >= ATR(ATR length) * displacement multiple AND (NOT volume-required OR volume[1] >= SMA(volume, volume length)[1] * volume multiple)
Calculation: SBLongArm = InKillzone AND low > high[2] AND low - high[2] >= min FVG size AND DispUp AND RecentSweepDir = -1 AND LongsAllowed AND 0 < (low + high[2]) / 2 - (low[1] - stop buffer) <= max stop (SB/OB)
Calculation: SBShortArm = InKillzone AND high < low[2] AND low[2] - high >= min FVG size AND DispDown AND RecentSweepDir = 1 AND ShortsAllowed AND 0 < (high[1] + stop buffer) - (high + low[2]) / 2 <= max stop (SB/OB)
Calculation: OBLongArm = low > high[2] AND DispUp AND close[2] < open[2] AND LongsAllowed AND 0 < (open[2] + close[2]) / 2 - (low[2] - stop buffer) <= max stop (SB/OB)
Calculation: OBShortArm = high < low[2] AND DispDown AND close[2] > open[2] AND ShortsAllowed AND 0 < (high[2] + stop buffer) - (open[2] + close[2]) / 2 <= max stop (SB/OB)
Calculation: OTELongArm = pivot high confirmed at this bar (OTE pivot bars each side) AND a pivot low exists AND RecentSweepDir = -1 AND LongsAllowed AND 0 < (H - CE fraction * (H - L)) - (L - stop buffer) <= max stop (OTE), where H = that pivot high and L = latest confirmed pivot low
Calculation: OTEShortArm = pivot low confirmed at this bar (OTE pivot bars each side) AND a pivot high exists AND RecentSweepDir = 1 AND ShortsAllowed AND 0 < (H + stop buffer) - (L + CE fraction * (H - L)) <= max stop (OTE), where L = that pivot low and H = latest confirmed pivot high
Long: with a = earliest SBLongArm bar within the SB window bars before the current bar and CE(a) = (low + high[2]) / 2 at a, low <= CE(a) AND low > CE(a) on every bar between a and the current bar
Short: with a = earliest SBShortArm bar within the SB window bars before the current bar and CE(a) = (high + low[2]) / 2 at a, high >= CE(a) AND high < CE(a) on every bar between a and the current bar
Long: with a = earliest OBLongArm bar within the OB window bars before the current bar and CE(a) = (open[2] + close[2]) / 2 at a, low <= CE(a) AND low > CE(a) on every bar between a and the current bar
Short: with a = earliest OBShortArm bar within the OB window bars before the current bar and CE(a) = (open[2] + close[2]) / 2 at a, high >= CE(a) AND high < CE(a) on every bar between a and the current bar
Long: with a = earliest OTELongArm bar within the OTE window bars before the current bar, H and L = pivot high and low at a, low <= H - near zone fraction * (H - L) AND close >= H - far zone fraction * (H - L) AND close > open, AND no earlier bar after a met these conditions
Short: with a = earliest OTEShortArm bar within the OTE window bars before the current bar, H and L = pivot high and low at a, high >= L + near zone fraction * (H - L) AND close <= L + far zone fraction * (H - L) AND close < open, AND no earlier bar after a met these conditions
Long: SSLSweep AND (NOT SR killzone-required OR InKillzone) AND LongsAllowed AND 0 < close - (low - stop buffer) <= max stop (SR)
Short: BSLSweep AND (NOT SR killzone-required OR InKillzone) AND ShortsAllowed AND 0 < (high + stop buffer) - close <= max stop (SR)
Long: new T5 bar starts AND low[1] > high[3] on T5 bars at last completed bar AND low[1] - high[3] >= min T5 gap
Short: new T5 bar starts AND high[1] < low[3] on T5 bars at last completed bar AND low[3] - high[1] >= min T5 gap
Exit: long, high >= entry price + target distance OR low <= (low[1] - stop buffer) at the SB-long arm bar of the entry OR bars since entry >= time-stop bars
Exit: short, low <= entry price - target distance OR high >= (high[1] + stop buffer) at the SB-short arm bar of the entry OR bars since entry >= time-stop bars
Exit: long, high >= entry price + target distance OR low <= (low[2] - stop buffer) at the OB-long arm bar of the entry OR bars since entry >= time-stop bars
Exit: short, low <= entry price - target distance OR high >= (high[2] + stop buffer) at the OB-short arm bar of the entry OR bars since entry >= time-stop bars
Exit: long, high >= (H - CE fraction * (H - L)) + target distance OR low <= (L - stop buffer) OR bars since entry >= time-stop bars, with H and L the pivot high and low at the OTE-long arm bar of the entry
Exit: short, low <= (L + CE fraction * (H - L)) - target distance OR high >= (H + stop buffer) OR bars since entry >= time-stop bars, with H and L the pivot high and low at the OTE-short arm bar of the entry
Exit: long, high >= entry price + target distance OR low <= (low at entry bar - stop buffer) OR bars since entry >= time-stop bars
Exit: short, low <= entry price - target distance OR high >= (high at entry bar + stop buffer) OR bars since entry >= time-stop bars