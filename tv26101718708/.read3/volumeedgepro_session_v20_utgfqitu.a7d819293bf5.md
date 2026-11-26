Calculation: SessionBars(X) = min(bars of series X since the current T1 period began + 1, MaxSessionBars)
Calculation: SessionHigh = highest(high, SessionBars(chart bars))
Calculation: SessionLow = lowest(low, SessionBars(chart bars))
Calculation: BinWidth = (SessionHigh - SessionLow) / PriceBins
Calculation: BinVolume(k) = total volume of the last SessionBars(chart bars) chart bars whose min(PriceBins, floor((close - SessionLow) / BinWidth)) equals k, for k from 0 to PriceBins
Calculation: EmptyBinsTop = number of consecutive bins with BinVolume = 0, counted down from bin PriceBins and stopping at the first bin with volume, examining bins PriceBins down to PriceBins - ScanBins
Calculation: EmptyBinsBottom = number of consecutive bins with BinVolume = 0, counted up from bin 0 and stopping at the first bin with volume, examining bins 0 to ScanBins - 1
Calculation: BuyTouch = a bar whose low <= SessionLow + TouchTicks * tick AND whose close > SessionLow AND EmptyBinsBottom >= MinEmptyBinsBottom, with SessionLow and EmptyBinsBottom taken at the current bar
Calculation: SellTouch = a bar whose high >= SessionHigh - TouchTicks * tick AND whose close < SessionHigh AND EmptyBinsTop >= MinEmptyBinsTop, with SessionHigh and EmptyBinsTop taken at the current bar
Calculation: VolOk = ATR(high, low, close, ATRLength) >= MinATR * 10 * tick
Calculation: DeadTimeFree = the bar's UTC hour is outside the window from DeadStartHour (inclusive) to DeadEndHour (exclusive), wrapping past midnight when DeadStartHour > DeadEndHour
Calculation: AlertTimeOk = the bar's hour in the alert time zone (UTC + AlertTZOffset) lies between the start and end hours of the bar's weekday (inclusive, wrapping past midnight when start > end) and that weekday is enabled
Calculation: Cooldown = BarsSince(colored chart label bar) < CooldownBars OR abs(close - entry price of that label) < ATR(high, low, close, ATRLength) * CooldownATRMult
Calculation: MaCrossUp = crosses above(MA(close, MAShortLength, MAType), MA(close, MALongLength, MAType))
Calculation: MaCrossDown = crosses below(MA(close, MAShortLength, MAType), MA(close, MALongLength, MAType))
Calculation: MaRecentUp = BarsSince(MaCrossUp) < MACrossLookback AND BarsSince(MaCrossUp) < BarsSince(MaCrossDown)
Calculation: MaRecentDown = BarsSince(MaCrossDown) < MACrossLookback AND BarsSince(MaCrossDown) < BarsSince(MaCrossUp)
Calculation: PC = close of the last completed T1 bar, evaluated on T1 bars and carried onto chart bars
Calculation: SessionPoc = POC of the volume profile over the last SessionBars(chart bars) chart bars with PriceBins bins
Calculation: D1Poc = POC of the volume profile over the last SessionBars(T2) completed T2 bars with PriceBins bins, evaluated on T2 bars and carried onto chart bars
Calculation: D1Vah = VAH of the same profile with ValueAreaPct
Calculation: D1Val = VAL of the same profile with ValueAreaPct
Calculation: D1LongLevel = min(D1Vah, D1Poc + LeanFraction * (D1Vah - D1Val))
Calculation: D1ShortLevel = max(D1Val, D1Poc - LeanFraction * (D1Vah - D1Val))
Long: BuyTouch AND VolOk AND NOT Cooldown AND DeadTimeFree
Long: BuyTouch AND DeadTimeFree AND AlertTimeOk
Long: BuyTouch AND MaRecentUp AND DeadTimeFree AND AlertTimeOk
Long: MaCrossUp AND BarsSince(BuyTouch) >= 1 AND BarsSince(BuyTouch) <= MACrossExpiry AND BarsSince(BuyTouch) < BarsSince(SellTouch) AND NOT MaRecentUp[BarsSince(BuyTouch)] AND DeadTimeFree[BarsSince(BuyTouch)] AND MaCrossUp is false on every bar strictly between that BuyTouch bar and this bar AND AlertTimeOk
Long: close >= PC + PCEntryBufferATR * ATR(high, low, close, ATRLength) AND BarsSince(BuyTouch) >= 1 AND BarsSince(BuyTouch) <= PCCrossExpiry AND BarsSince(BuyTouch) < BarsSince(SellTouch) AND close[BarsSince(BuyTouch)] < PC AND DeadTimeFree[BarsSince(BuyTouch)] AND close < PC + PCEntryBufferATR * ATR(high, low, close, ATRLength) on every bar strictly between that BuyTouch bar and this bar AND AlertTimeOk
Long: MaCrossUp
Long: close > SessionPoc + BinWidth
Long: VolOk AND close > SessionPoc + BinWidth AND close >= D1ShortLevel
Long: close > D1LongLevel
Long: close > VAH of the volume profile over the last SessionBars(T3) completed T3 bars with PriceBins bins and ValueAreaPct, evaluated on T3 bars and carried onto chart bars
Short: SellTouch AND VolOk AND NOT Cooldown AND DeadTimeFree
Short: SellTouch AND DeadTimeFree AND AlertTimeOk
Short: SellTouch AND MaRecentDown AND DeadTimeFree AND AlertTimeOk
Short: MaCrossDown AND BarsSince(SellTouch) >= 1 AND BarsSince(SellTouch) <= MACrossExpiry AND BarsSince(SellTouch) < BarsSince(BuyTouch) AND NOT MaRecentDown[BarsSince(SellTouch)] AND DeadTimeFree[BarsSince(SellTouch)] AND MaCrossDown is false on every bar strictly between that SellTouch bar and this bar AND AlertTimeOk
Short: close <= PC - PCEntryBufferATR * ATR(high, low, close, ATRLength) AND BarsSince(SellTouch) >= 1 AND BarsSince(SellTouch) <= PCCrossExpiry AND BarsSince(SellTouch) < BarsSince(BuyTouch) AND close[BarsSince(SellTouch)] > PC AND DeadTimeFree[BarsSince(SellTouch)] AND close > PC - PCEntryBufferATR * ATR(high, low, close, ATRLength) on every bar strictly between that SellTouch bar and this bar AND AlertTimeOk
Short: MaCrossDown
Short: close < SessionPoc - BinWidth
Short: VolOk AND close < SessionPoc - BinWidth AND close <= D1LongLevel
Short: close < D1ShortLevel
Short: close < VAL of the volume profile over the last SessionBars(T3) completed T3 bars with PriceBins bins and ValueAreaPct, evaluated on T3 bars and carried onto chart bars