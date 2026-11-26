Calculation: Latest confirmed swing high = most recent confirmed PivotHigh(high, swing pivot lookback, swing pivot lookback) on chart bars
Calculation: Previous confirmed swing high = confirmed PivotHigh(high, swing pivot lookback, swing pivot lookback) preceding the latest confirmed swing high
Calculation: Latest confirmed swing low = most recent confirmed PivotLow(low, swing pivot lookback, swing pivot lookback) on chart bars
Calculation: Previous confirmed swing low = confirmed PivotLow(low, swing pivot lookback, swing pivot lookback) preceding the latest confirmed swing low
Calculation: Bull structure points = structure weight if (latest confirmed swing high > previous confirmed swing high OR latest confirmed swing low > previous confirmed swing low) AND close > latest confirmed swing low; otherwise zero
Calculation: Bear structure points = structure weight if (latest confirmed swing low < previous confirmed swing low OR latest confirmed swing high < previous confirmed swing high) AND close < latest confirmed swing high; otherwise zero
Calculation: Bull volume points = volume weight if the linear regression slope of OBV over the OBV slope lookback is positive; otherwise zero
Calculation: Bear volume points = volume weight if the linear regression slope of OBV over the OBV slope lookback is negative; otherwise zero
Calculation: Bull aligned momentum reads = count of close > KAMA(close, KAMA efficiency lookback, fast smoothing period, slow smoothing period), RSI(close, RSI lookback) > RSI midpoint, and Williams %R(high, low, close, Williams %R lookback) > bullish Williams %R threshold
Calculation: Bear aligned momentum reads = count of close < KAMA(close, KAMA efficiency lookback, fast smoothing period, slow smoothing period), RSI(close, RSI lookback) < RSI midpoint, and Williams %R(high, low, close, Williams %R lookback) < bearish Williams %R threshold
Calculation: Bull momentum points = momentum weight × bull aligned momentum reads / total momentum read count
Calculation: Bear momentum points = momentum weight × bear aligned momentum reads / total momentum read count
Calculation: Bull liquidity points = liquidity weight if low < latest confirmed swing low AND close > latest confirmed swing low; otherwise zero
Calculation: Bear liquidity points = liquidity weight if high > latest confirmed swing high AND close < latest confirmed swing high; otherwise zero
Calculation: ATR ratio = ATR(ATR lookback) / SMA(ATR(ATR lookback), ATR average lookback) on chart bars
Calculation: Bull volatility points = volatility weight if ATR ratio > lower volatility limit AND ATR ratio < upper volatility limit AND bull momentum points > bear momentum points AND bull aligned momentum reads >= minimum aligned momentum reads; otherwise zero
Calculation: Bear volatility points = volatility weight if ATR ratio > lower volatility limit AND ATR ratio < upper volatility limit AND bear momentum points > bull momentum points AND bear aligned momentum reads >= minimum aligned momentum reads; otherwise zero
Calculation: Developing T1 high = highest chart-bar high since the start of the current T1 period, including the current chart bar
Calculation: Developing T1 low = lowest chart-bar low since the start of the current T1 period, including the current chart bar
Calculation: T1 range position = normalized percentage of chart close relative to the midpoint of the developing T1 high-low range, or zero when the range is zero
Calculation: Bull session points = minimum of session weight and absolute T1 range position × session weight / session scoring scale if session scoring is enabled AND T1 range position < 0; otherwise zero
Calculation: Bear session points = minimum of session weight and absolute T1 range position × session weight / session scoring scale if session scoring is enabled AND T1 range position > 0; otherwise zero
Calculation: HTF EMA = EMA(close, HTF EMA lookback) calculated on T2 bars and sampled on chart bars; use the latest available T2 value, which is the still-forming T2 bar in realtime and the latest confirmed value on historical bars
Calculation: Bull HTF points = HTF weight if MTF scoring is enabled AND chart close > HTF EMA; otherwise zero
Calculation: Bear HTF points = HTF weight if MTF scoring is enabled AND chart close < HTF EMA; otherwise zero
Calculation: Bull score = bull structure points + bull volume points + bull momentum points + bull liquidity points + bull volatility points + bull session points + bull HTF points
Calculation: Bear score = bear structure points + bear volume points + bear momentum points + bear liquidity points + bear volatility points + bear session points + bear HTF points
Calculation: Long signal = bull score >= signal threshold AND bull score - bear score >= directional gap AND (session filter disabled OR current chart bar is within the configured UTC session) AND (ADX filter disabled OR ADX(DMI lookback, ADX smoothing lookback) >= minimum ADX) AND (VWMA filter disabled OR close > VWMA(close, VWMA lookback)) AND (Supertrend filter disabled OR Supertrend direction is bullish) AND (ribbon filter disabled OR fastest ribbon HMA > slowest ribbon HMA)
Calculation: Short signal = bear score >= signal threshold AND bear score - bull score >= directional gap AND (session filter disabled OR current chart bar is within the configured UTC session) AND (ADX filter disabled OR ADX(DMI lookback, ADX smoothing lookback) >= minimum ADX) AND (VWMA filter disabled OR close < VWMA(close, VWMA lookback)) AND (Supertrend filter disabled OR Supertrend direction is bearish) AND (ribbon filter disabled OR fastest ribbon HMA < slowest ribbon HMA)
Calculation: Fastest ribbon HMA = HMA(close, ribbon base length)
Calculation: Slowest ribbon HMA = HMA(close, ribbon base length + ribbon length step × (ribbon layer count - one))
Calculation: ADX regime = lower regime if ADX(DMI lookback, ADX smoothing lookback) < lower ADX regime boundary; middle regime if it is >= the lower boundary AND < the upper ADX regime boundary; otherwise upper regime
Calculation: Long stop level at entry = latest confirmed swing low if stop mode selects pivot and a swing low exists; otherwise, for pivot or ATR stop mode, entry price - ATR(ATR lookback) × stop multiple selected for the entry ADX regime; for Supertrend mode, Supertrend level at entry; for ribbon mode, slowest ribbon HMA at entry
Calculation: Short stop level at entry = latest confirmed swing high if stop mode selects pivot and a swing high exists; otherwise, for pivot or ATR stop mode, entry price + ATR(ATR lookback) × stop multiple selected for the entry ADX regime; for Supertrend mode, Supertrend level at entry; for ribbon mode, slowest ribbon HMA at entry
Calculation: Long target price at entry = entry price + ATR(ATR lookback) × target multiple selected for the entry ADX regime
Calculation: Short target price at entry = entry price - ATR(ATR lookback) × target multiple selected for the entry ADX regime
Long: Long signal
Long: Long signal AND NOT Long signal on the previous chart bar
Long: Long signal AND bull score >= extreme score threshold
Long: bull structure points > bear structure points
Short: bear structure points > bull structure points
Long: bull volume points > bear volume points
Short: bear volume points > bull volume points
Long: bull momentum points > bear momentum points
Short: bear momentum points > bull momentum points
Long: bull liquidity points > bear liquidity points
Short: bear liquidity points > bull liquidity points
Long: bull volatility points > bear volatility points
Short: bear volatility points > bull volatility points
Long: bull session points > bear session points
Short: bear session points > bull session points
Long: bull HTF points > bear HTF points
Short: bear HTF points > bull HTF points
Long: bull score > bear score
Short: bear score >= bull score
Long: Supertrend direction is bullish
Short: Supertrend direction is bearish
Long: fastest ribbon HMA > slowest ribbon HMA
Short: fastest ribbon HMA < slowest ribbon HMA
Short: Short signal
Short: Short signal AND NOT Short signal on the previous chart bar
Short: Short signal AND bear score >= extreme score threshold
Exit: long, high >= long target price OR low <= long stop level
Exit: short, low <= short target price OR high >= short stop level