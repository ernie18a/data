Calculation: Body = ABS(close - open)
Calculation: Upper wick = high - MAX(open, close)
Calculation: Lower wick = MIN(open, close) - low
Calculation: Body percent = IF(high - low > 0, Body / (high - low), 0)
Calculation: Volume qualified = volume >= SMA(volume, volume lookback) * volume multiple AND volume > volume[1] AND volume[1] > volume[2]
Calculation: Bullish EMA stack = EMA(close, shortest lookback) > EMA(close, middle lookback) AND EMA(close, middle lookback) > EMA(close, longest lookback)
Calculation: Bearish EMA stack = EMA(close, shortest lookback) < EMA(close, middle lookback) AND EMA(close, middle lookback) < EMA(close, longest lookback)
Calculation: Bullish HTF stack = EMA(close, shortest lookback, T1, last completed bar) > EMA(close, middle lookback, T1, last completed bar) AND EMA(close, middle lookback, T1, last completed bar) > EMA(close, longest lookback, T1, last completed bar)
Calculation: Bearish HTF stack = EMA(close, shortest lookback, T1, last completed bar) < EMA(close, middle lookback, T1, last completed bar) AND EMA(close, middle lookback, T1, last completed bar) < EMA(close, longest lookback, T1, last completed bar)
Calculation: Above VWAP = close > VWAP(hlc3)
Calculation: Below VWAP = close < VWAP(hlc3)
Calculation: Bull score = count of true among: Bullish EMA stack; Above VWAP AND VWAP(hlc3) > VWAP(hlc3)[VWAP lag]; Bullish HTF stack; RSI(close, RSI lookback) between RSI bull low and RSI bull high; MACD(close, MACD shorter lookback, MACD longer lookback, MACD signal lookback) line > signal line AND MACD histogram > MACD histogram[1]; Volume qualified
Calculation: Bear score = count of true among: Bearish EMA stack; Below VWAP AND VWAP(hlc3) < VWAP(hlc3)[VWAP lag]; Bearish HTF stack; RSI(close, RSI lookback) between RSI bear low and RSI bear high; MACD(close, MACD shorter lookback, MACD longer lookback, MACD signal lookback) line < signal line AND MACD histogram < MACD histogram[1]; Volume qualified
Calculation: Bull trend = (count of true among Bullish EMA stack, Above VWAP, Bullish HTF stack) >= trend count
Calculation: Bear trend = (count of true among Bearish EMA stack, Below VWAP, Bearish HTF stack) >= trend count
Calculation: Good time window = bar time is not within the opening block window, the lunch block window, or the late-afternoon block window
Calculation: MOC window = bar time is within the MOC session window
Calculation: Bullish engulfing = close[1] < open[1] AND close > open AND close > open[1] AND open <= close[1] AND Body > Body[1]
Calculation: Bearish engulfing = close[1] > open[1] AND close < open AND close < open[1] AND open >= close[1] AND Body > Body[1]
Calculation: Hammer = Lower wick > Body * wick multiple AND Upper wick < Body * opposite wick fraction AND Body percent < small body fraction AND close >= open
Calculation: Shooting star = Upper wick > Body * wick multiple AND Lower wick < Body * opposite wick fraction AND Body percent < small body fraction AND close <= open
Calculation: Breakout = close > Highest(high[1], breakout lookback) AND close > open AND Body percent > breakout body fraction
Calculation: Breakdown = close < Lowest(low[1], breakout lookback) AND close < open AND Body percent > breakout body fraction
Calculation: Touched support = low within +/- proximity percent of any of: low(T2, last completed bar), close(T2, last completed bar), low(T2, forming bar, so far), EMA(close, middle lookback), VWAP(hlc3), low(T3, last completed bar), pre-market low, opening-range low, last pivot low with swing length bars on each side
Calculation: Touched resistance = high within +/- proximity percent of any of: high(T2, last completed bar), close(T2, last completed bar), high(T2, forming bar, so far), EMA(close, middle lookback), VWAP(hlc3), high(T3, last completed bar), pre-market high, opening-range high, last pivot high with swing length bars on each side
Calculation: Bounce = Touched support AND close > open AND Body percent > bounce body fraction AND close > (high + low) / 2
Calculation: Rejection = Touched resistance AND close < open AND Body percent > bounce body fraction AND close < (high + low) / 2
Calculation: Spring sweep pending = a bar with low < Lowest(low[1], Wyckoff lookback) starts a sweep when no sweep is pending, with sweep level = Lowest(low[1], Wyckoff lookback) at that bar; the sweep stays pending through the bar of a Spring or until bars since the sweep exceed sweep window length
Calculation: Spring = Spring sweep pending AND bars since sweep <= sweep window length AND close > sweep level AND close > open AND Volume qualified
Calculation: Upthrust sweep pending = a bar with high > Highest(high[1], Wyckoff lookback) starts a sweep when no sweep is pending, with sweep level = Highest(high[1], Wyckoff lookback) at that bar; the sweep stays pending through the bar of an Upthrust or until bars since the sweep exceed sweep window length
Calculation: Upthrust = Upthrust sweep pending AND bars since sweep <= sweep window length AND close < sweep level AND close < open AND Volume qualified
Calculation: Bull pattern = Bullish engulfing OR Hammer OR Breakout OR Bounce OR Spring
Calculation: Bear pattern = Bearish engulfing OR Shooting star OR Breakdown OR Rejection OR Upthrust
Calculation: Entry risk = ATR(ATR lookback) at the entry bar * ATR stop multiple
Calculation: Long stop level = entry price if high >= entry price + Entry risk * TP1 multiple on any bar since entry, otherwise entry price - Entry risk
Calculation: Short stop level = entry price if low <= entry price - Entry risk * TP1 multiple on any bar since entry, otherwise entry price + Entry risk
Option: buy call, Bull score = A score AND Bull pattern AND Bull trend AND Good time window AND NOT MOC window AND bars since last A or B call signal >= cooldown bars AND no open long position
Option: buy call, B minimum score <= Bull score AND Bull score < A score AND Bull pattern AND Bull trend AND Good time window AND NOT MOC window AND bars since last A or B call signal >= cooldown bars AND no open long position
Option: buy call, MOC window AND Bull score >= MOC minimum score AND Bull pattern AND Bull trend AND Volume qualified AND close < high(T2, last completed bar) * (1 - clearance percent) AND bars since last MOC signal >= cooldown bars AND no open long position
Option: buy put, Bear score = A score AND Bear pattern AND Bear trend AND Good time window AND NOT MOC window AND bars since last A or B put signal >= cooldown bars AND no open short position
Option: buy put, B minimum score <= Bear score AND Bear score < A score AND Bear pattern AND Bear trend AND Good time window AND NOT MOC window AND bars since last A or B put signal >= cooldown bars AND no open short position
Option: buy put, MOC window AND Bear score >= MOC minimum score AND Bear pattern AND Bear trend AND Volume qualified AND close > low(T2, last completed bar) * (1 + clearance percent) AND bars since last MOC signal >= cooldown bars AND no open short position
Exit: long, high >= entry price + Entry risk * TP2 multiple OR low <= Long stop level OR (Bearish EMA stack AND Below VWAP AND Bear pattern) OR bars since entry >= time stop bars
Exit: long, Bear score >= reversal minimum score AND Bear pattern AND (Below VWAP OR Bearish EMA stack)
Exit: short, low <= entry price - Entry risk * TP2 multiple OR high >= Short stop level OR (Bullish EMA stack AND Above VWAP AND Bull pattern) OR bars since entry >= time stop bars
Exit: short, Bull score >= reversal minimum score AND Bull pattern AND (Above VWAP OR Bullish EMA stack)
Long: Spring
Short: Upthrust
Long: no open position AND bars since last A or B put signal < zone lookback AND Bull score >= reversal minimum score AND Bull pattern AND Bull trend AND Good time window
Short: no open position AND bars since last A or B call signal < zone lookback AND Bear score >= reversal minimum score AND Bear pattern AND Bear trend AND Good time window