Calculation: ZLEMA(n) = EMA(close + (close - close[floor((n-1)/2)]), n); Main = ZLEMA with longer length; Fast = ZLEMA with shorter length
Calculation: ATR = Wilder ATR; Bias = EMA(close) with length longer than Main's length
Calculation: BullTrend = close > Main AND Fast > Main AND (Main - Main[k bars ago]) > a1*ATR; BearTrend = close < Main AND Fast < Main AND (Main - Main[k bars ago]) < -a1*ATR
Calculation: BullMom = (Fast - Fast[1]) > 0 AND close > close[1]; BearMom = (Fast - Fast[1]) < 0 AND close < close[1]
Calculation: BullCandle = close > open AND close >= high - 0.35*(high-low); BearCandle = close < open AND close <= low + 0.35*(high-low)
Calculation: BodyStrong = |close-open| > a2*ATR
Calculation: BullExp = close > high[1] AND BullCandle AND BodyStrong; BearExp = close < low[1] AND BearCandle AND BodyStrong
Calculation: BullSep = Fast > Main AND |Fast-Main| > a3*ATR; BearSep = Fast < Main AND |Fast-Main| > a3*ATR
Calculation: NotChoppy = (highest high - lowest low over short lookback incl. current bar) > a4*ATR
Calculation: StretchOk = |close - Main| <= a5*ATR
Calculation: BullBreak = high > highest high of the previous L bars (excluding current); BearBreak = low < lowest low of the previous L bars (excluding current)
Calculation: BullTouch = low <= Fast OR low <= Main OR close <= Fast; RecentBullTouch = BullTouch true on current bar or any of previous w bars. BearTouch = high >= Fast OR high >= Main OR close >= Fast; RecentBearTouch likewise
Calculation: BullReclaim = (close > Fast AND close[1] <= Fast[1]) OR (Fast > Main AND Fast[1] <= Main[1]); BearReject = (close < Fast AND close[1] >= Fast[1]) OR (Fast < Main AND Fast[1] >= Main[1])
Calculation: BuyScore = count of true among {BullTrend, BullSep, close > Bias, BullExp, BullBreak, RecentBullTouch AND BullReclaim, NotChoppy, StretchOk, BullMom}; SellScore = same with {BearTrend, BearSep, close < Bias, BearExp, BearBreak, RecentBearTouch AND BearReject, NotChoppy, StretchOk, BearMom}
Calculation: RawBuy = (BullTrend AND BullSep AND BullExp AND close > Bias AND BullMom AND NotChoppy) OR (BullTrend AND RecentBullTouch AND BullReclaim AND BullCandle AND BodyStrong AND StretchOk AND BullMom AND NotChoppy) OR BuyScore >= score threshold; RawSell = mirror: (BearTrend AND BearSep AND BearExp AND close < Bias AND BearMom AND NotChoppy) OR (BearTrend AND RecentBearTouch AND BearReject AND BearCandle AND BodyStrong AND StretchOk AND BearMom AND NotChoppy) OR SellScore >= score threshold
Calculation: One-print-per-trend state: dir=0, printed=false initially. On each completed bar, in order: (1) if dir==0: dir=1 if BullTrend, else dir=-1 if BearTrend; (2) if BullTrend AND BullMom AND dir!=1 then dir=1, printed=false; else if BearTrend AND BearMom AND dir!=-1 then dir=-1, printed=false; (3) BuyAllowed = (dir==1 OR BullTrend) AND NOT printed; SellAllowed = (dir==-1 OR BearTrend) AND NOT printed; (4) after evaluating signals, if (RawBuy AND BuyAllowed) OR (RawSell AND SellAllowed) then printed=true
Long: RawBuy AND BuyAllowed AND close > Main AND BullCandle (evaluated on completed bars; entry price = this bar's close)
Short: RawSell AND SellAllowed AND close < Main AND BearCandle (evaluated on completed bars; entry price = this bar's close)
Exit: long, bar is after the entry bar AND high >= entry price + fixed price distance (take-profit, once per trade)
Exit: short, bar is after the entry bar AND low <= entry price - fixed price distance (take-profit, once per trade)