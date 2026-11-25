Calculation: Rng = max(high - low, tick)
Calculation: VWSD = sqrt(max(VWAP(src^2, anchor T1) - VWAP(src, anchor T1)^2, 0))
Calculation: Line(s, m) = VWAP(src, anchor T1) + s * m * VWSD, with s = -1 or +1; m = 0 gives VWAP
Calculation: Touch(tol) = true when, for some Line(s, m) with m = 0 or an enabled band multiplier, low - tol <= Line(s, m) <= high + tol on the same bar
Calculation: FVG(x) = bull if low[x] > high[x+2]; bear if high[x] < low[x+2]; none otherwise
Calculation: Gap(x) = for bull FVG bottom = high[x+2] and top = low[x]; for bear FVG bottom = high[x] and top = low[x+2]; a bar overlaps the gap when its high >= bottom and its low <= top
Calculation: MacroFVG(W) = first FVG on chart bars whose three bars all lie in macro window W and that has a breaker, meaning a candle at offset b with 2 <= b <= B inside W that is bearish for a bull FVG or bullish for a bear FVG; W is either macro window, each with its own start and end
Calculation: MacroFVG2(W) = first FVG on T2 bars, evaluated on the last completed T2 bar, whose three T2 bars all lie in macro window W
Calculation: BuyShare = (1 - w) * (a * (close - low) / Rng + (1 - a) * ((close - open) / Rng + 1) / 2) + w * (wD * clamp((close - close[1]) / Rng, -1, 1) + (1 - wD) * (min(open, close) - low - (high - max(open, close))) / Rng + 1) / 2
Calculation: DominancePct = abs(2 * BuyShare - 1) * 100
Calculation: BodyPct = abs(close - open) / Rng * 100
Calculation: BigThreshold = max(1, SMA(volume, N_bt) * M_bt)
Calculation: Doji = abs(close - open) / Rng <= D_R AND volume >= M_doji * SMA(volume, N_vol)
Calculation: TrendBar = Touch(tol_trend) AND abs(close - open) >= M_body * SMA(abs(close - open), N_body) AND volume >= M_vol * SMA(volume, N_vol) AND max(high - max(open, close), min(open, close) - low) <= R_wick * abs(close - open) AND bars since last TrendBar >= minSpacing; tol_trend = max(T_atr * ATR(N_atr), T_tick * tick)
Calculation: SellSweep = low < a swing low not yet swept, a swing low being a pivot low of strength P confirmed P bars later; the swept swing low is then removed
Calculation: BuySweep = high > a swing high not yet swept, a swing high being a pivot high of strength P confirmed P bars later; the swept swing high is then removed
Calculation: BullRun = open of the first bar of the current run of consecutive bars with close > open, na when the current bar is not bullish; BearRun = same with close < open
Calculation: UpArm = set on a bar where SellSweep holds, the bar is bearish, and BearRun is defined, provided no arm is active; stores Ref = BearRun of that bar; active until cleared by its Long trigger or N_c bars after its run start
Calculation: DownArm = set on a bar where BuySweep holds, the bar is bullish, and BullRun is defined, provided no arm is active; stores Ref = BullRun of that bar; active until cleared by its Short trigger or N_c bars after its run start
Calculation: ZoneHigh(k) = number of bars in bias window k up to this bar with close > Line(+1, m1); ZoneLow(k) = number of bars in bias window k up to this bar with close < Line(-1, m1)
Long: chart timeframe is not T2 AND bar in macro window W AND no entry earlier in W AND MacroFVG(W) found at or before this bar is bullish AND MacroFVG2(W) found at or before this bar AND (bar overlaps gap of MacroFVG(W) OR bar overlaps gap of MacroFVG2(W))
Short: chart timeframe is not T2 AND bar in macro window W AND no entry earlier in W AND MacroFVG(W) found at or before this bar is bearish AND MacroFVG2(W) found at or before this bar AND (bar overlaps gap of MacroFVG(W) OR bar overlaps gap of MacroFVG2(W))
Long: chart timeframe is not T2 AND MacroFVG(W) forms on this bar AND is bullish
Short: chart timeframe is not T2 AND MacroFVG(W) forms on this bar AND is bearish
Long: chart timeframe is not T2 AND MacroFVG2(W) forms on the newly completed T2 bar AND is bullish
Short: chart timeframe is not T2 AND MacroFVG2(W) forms on the newly completed T2 bar AND is bearish
Long: FVG(0) is bull AND Touch(tol_fvg) holds on bar 1
Short: FVG(0) is bear AND Touch(tol_fvg) holds on bar 1
Long: chart timeframe is not T2 AND FVG(0) on the newly completed T2 bar is bull AND Touch(tol_fvg) holds on the prior T2 bar, with VWAP and bands computed on T2 bars
Short: chart timeframe is not T2 AND FVG(0) on the newly completed T2 bar is bear AND Touch(tol_fvg) holds on the prior T2 bar, with VWAP and bands computed on T2 bars
Long: the most recent non-none FVG(1) on T1 bars, taken at the last completed T1 bar, is bull
Short: the most recent non-none FVG(1) on T1 bars, taken at the last completed T1 bar, is bear
Long: TrendBar AND close > open
Short: TrendBar AND close < open
Long: Doji AND close >= open
Short: Doji AND close < open
Long: UpArm is active AND close > open AND close > UpArm.Ref
Short: DownArm is active AND close < open AND close < DownArm.Ref
Long: BuyShare * volume >= BigThreshold AND DominancePct >= P_dom AND BodyPct >= P_body AND (close >= open OR BuyShare * 100 >= P_counter)
Short: (1 - BuyShare) * volume >= BigThreshold AND DominancePct >= P_dom AND BodyPct >= P_body AND (close <= open OR (1 - BuyShare) * 100 >= P_counter)
Long: bar in bias window 1 AND ZoneHigh(1) > ZoneLow(1)
Short: bar in bias window 1 AND ZoneLow(1) > ZoneHigh(1)
Long: bar in bias window 2 AND ZoneHigh(2) > ZoneLow(2)
Short: bar in bias window 2 AND ZoneLow(2) > ZoneHigh(2)
Long: bar in bias window 3 AND ZoneHigh(3) > ZoneLow(3)
Short: bar in bias window 3 AND ZoneLow(3) > ZoneHigh(3)
Long: count of bars since T1 start with close >= VWAP > count of bars since T1 start with close < VWAP
Short: count of bars since T1 start with close < VWAP > count of bars since T1 start with close >= VWAP