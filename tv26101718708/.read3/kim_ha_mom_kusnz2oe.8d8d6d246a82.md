Calculation: Session CVD = cumulative T1 regular-bar volume for close > open minus volume for close < open, reset at each named session start and calendar-day boundary in the configured timezone; aggregate current T1 intrabars on chart bars, including a forming T1 bar when available
Calculation: Active-session CVD = New York session CVD when in that session, otherwise London session CVD, otherwise Asia session CVD, otherwise unavailable
Calculation: Stored swing high = latest confirmed PivotHigh of Heikin Ashi high from T2, using equal left and right swing lookbacks, evaluated on chart bars from the current requested T2 value (not a shifted completed bar); replace on a new confirmed pivot and clear after a bullish structure break
Calculation: Stored swing low = latest confirmed PivotLow of Heikin Ashi low from T2, using equal left and right swing lookbacks, evaluated on chart bars from the current requested T2 value (not a shifted completed bar); replace on a new confirmed pivot and clear after a bearish structure break
Calculation: Low sweep = stored swing low is available AND low < stored swing low AND close > stored swing low
Calculation: High sweep = stored swing high is available AND high > stored swing high AND close < stored swing high
Calculation: Low-sweep state = false initially; set true on a low sweep or bearish CHoCH, clear on bullish CHoCH, otherwise persist
Calculation: High-sweep state = false initially; set true on a high sweep or bullish CHoCH, clear on bearish CHoCH, otherwise persist
Calculation: Bullish structure break = stored swing high is available AND close > stored swing high AND previous chart-bar close <= the current stored swing high
Calculation: Bearish structure break = stored swing low is available AND close < stored swing low AND previous chart-bar close >= the current stored swing low
Calculation: Bullish CHoCH = bullish structure break AND low-sweep state; bullish BOS = bullish structure break AND NOT low-sweep state
Calculation: Bearish CHoCH = bearish structure break AND high-sweep state; bearish BOS = bearish structure break AND NOT high-sweep state
Calculation: Bullish entry setup = activated or restarted by bullish CHoCH or BOS when close > VWAP(OHLC4, volume, calendar-day reset in configured timezone); becomes eligible when Heikin Ashi close < open within the pullback window; canceled by a bearish CHoCH or BOS, by no pullback within the pullback window, after the setup expiration, or on entry
Calculation: Bearish entry setup = activated or restarted by bearish CHoCH or BOS when close <= VWAP(OHLC4, volume, calendar-day reset in configured timezone); becomes eligible when Heikin Ashi close > open within the pullback window; canceled by a bullish CHoCH or BOS, by no pullback within the pullback window, after the setup expiration, or on entry
Calculation: Momentum score = mean over the momentum lookback of signed body ratio multiplied by close-position ratio; signed body ratio is abs(close-open)/(high-low), positive when close >= open and negative otherwise; close-position ratio is (close-low)/(high-low) when close >= open and (high-close)/(high-low) otherwise; contribution is zero when high = low
Calculation: EMA spread ratio = abs(EMA(close, shorter fast lookback) - EMA(close, longer slow lookback)) / ATR(ATR lookback), or zero when ATR is not positive
Calculation: Bullish ROC push = ROC(VWAP(OHLC4, volume, calendar-day reset in configured timezone), ROC lookback) crossed above the lower positive ROC level within the current or preceding ROC push-window chart bars, after the ROC lookback has elapsed since the day boundary
Calculation: Bearish ROC push = ROC(VWAP(OHLC4, volume, calendar-day reset in configured timezone), ROC lookback) crossed below the negative lower ROC level within the current or preceding ROC push-window chart bars, after the ROC lookback has elapsed since the day boundary
Calculation: Active momentum side = long when EMA spread ratio crosses above the higher start threshold while the fast EMA exceeds the slow EMA; short when it crosses above the start threshold while the fast EMA is below the slow EMA; replace the side on an opposite start and clear it when the ratio crosses below the lower end threshold
Long: close > VWAP(OHLC4, volume, calendar-day reset in configured timezone)
Short: close <= VWAP(OHLC4, volume, calendar-day reset in configured timezone)
Long: close > VWAP(OHLC4, volume, calendar-day reset in configured timezone) AND the CVD of each named Asia, London, or New York session > 0
Short: close <= VWAP(OHLC4, volume, calendar-day reset in configured timezone) AND the CVD of each named Asia, London, or New York session < 0
Long: bullish CHoCH OR bullish BOS
Short: bearish CHoCH OR bearish BOS
Long: bullish CHoCH AND close > VWAP(OHLC4, volume, calendar-day reset in configured timezone)
Short: bearish CHoCH AND close <= VWAP(OHLC4, volume, calendar-day reset in configured timezone)
Long: low sweep AND close > VWAP(OHLC4, volume, calendar-day reset in configured timezone)
Short: high sweep AND close <= VWAP(OHLC4, volume, calendar-day reset in configured timezone)
Long: bullish structure break AND a bearish regular candle exists among prior chart bars within the order-block lookback
Short: bearish structure break AND a bullish regular candle exists among prior chart bars within the order-block lookback
Long: ROC(VWAP(OHLC4, volume, calendar-day reset in configured timezone), ROC lookback) crosses above the lower positive ROC level OR the higher positive ROC level, after the ROC lookback has elapsed since the day boundary
Short: ROC(VWAP(OHLC4, volume, calendar-day reset in configured timezone), ROC lookback) crosses below the negative lower ROC level OR the negative higher ROC level, after the ROC lookback has elapsed since the day boundary
Long: Heikin Ashi close >= Heikin Ashi open
Short: Heikin Ashi close < Heikin Ashi open
Long: Momentum score >= the higher strong-momentum threshold
Long: Momentum score >= the lower moderate-momentum threshold AND Momentum score < the strong-momentum threshold
Short: Momentum score <= the negative strong-momentum threshold
Short: Momentum score <= the negative moderate-momentum threshold AND Momentum score > the negative strong-momentum threshold
Long: NOT bearish ROC push AND (bullish ROC push OR EMA(close, shorter fast lookback) > EMA(close, longer slow lookback))
Short: bearish ROC push OR (NOT bullish ROC push AND EMA(close, shorter fast lookback) <= EMA(close, longer slow lookback))
Long: bullish entry setup is eligible AND Heikin Ashi close > Heikin Ashi open AND close > VWAP(OHLC4, volume, calendar-day reset in configured timezone) AND active-session CVD is available AND active-session CVD > its previous chart-bar value AND high > low AND abs(close-open)/(high-low) >= the minimum entry body ratio
Short: bearish entry setup is eligible AND Heikin Ashi close < Heikin Ashi open AND close <= VWAP(OHLC4, volume, calendar-day reset in configured timezone) AND active-session CVD is available AND active-session CVD < its previous chart-bar value AND high > low AND abs(close-open)/(high-low) >= the minimum entry body ratio
Long: EMA spread ratio crosses above the higher start threshold AND EMA(close, shorter fast lookback) > EMA(close, longer slow lookback)
Short: EMA spread ratio crosses above the higher start threshold AND EMA(close, shorter fast lookback) < EMA(close, longer slow lookback)
Exit: long, EMA spread ratio crosses below the lower end threshold AND active momentum side is long
Exit: short, EMA spread ratio crosses below the lower end threshold AND active momentum side is short