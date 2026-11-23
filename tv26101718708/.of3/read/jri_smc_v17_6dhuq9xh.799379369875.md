Calculation: Swing high(k) = k-th most recent confirmed PivotHigh(high, swing length, swing length), k = 1 is newest
Calculation: Swing low(k) = k-th most recent confirmed PivotLow(low, swing length, swing length), k = 1 is newest
Calculation: Bullish structure = Swing high(1) > Swing high(2) > Swing high(3) AND Swing low(1) > Swing low(2) > Swing low(3)
Calculation: Bearish structure = Swing high(1) < Swing high(2) < Swing high(3) AND Swing low(1) < Swing low(2) < Swing low(3)
Calculation: Bullish break = close > Swing high(2) AND close[1] <= Swing high(2)
Calculation: Bearish break = close < Swing low(2) AND close[1] >= Swing low(2)
Calculation: Pending bullish break = Bullish break OR (Pending bullish break[1] AND NOT Bullish retest[1])
Calculation: Bullish retest = Pending bullish break AND low <= Swing high(2) * (1 + tolerance) AND close > Swing high(2)
Calculation: Pending bearish break = Bearish break OR (Pending bearish break[1] AND NOT Bearish retest[1])
Calculation: Bearish retest = Pending bearish break AND high >= Swing low(2) * (1 - tolerance) AND close < Swing low(2)
Calculation: Liquidity sweep = (high > Highest(high, liquidity lookback)[1] AND close < Highest(high, liquidity lookback)[1]) OR (low < Lowest(low, liquidity lookback)[1] AND close > Lowest(low, liquidity lookback)[1])
Calculation: High bands = price bands from confirmed swing highs, in confirmation order: a swing high joins the earliest existing band whose fixed bounds contain it (touch count + 1); otherwise it creates a band with touch count 1 and bounds swing high * (1 - tolerance) to swing high * (1 + tolerance)
Calculation: Low bands = High bands formed from confirmed swing lows instead of swing highs
Calculation: Scalp chart = chart timeframe is T2, T3, or T4
Calculation: Stop distance = ATR(ATR length) * point value * (scalp stop multiplier if Scalp chart, else stop multiplier)
Calculation: Entry gap = swing length * (scalp gap multiple if Scalp chart, else gap multiple)
Calculation: Session allowed = session filter disabled OR (bar time in New York time is a weekday within London open to London close, or a weekday within New York open to New York close)
Calculation: Stop-out = (long position AND low <= entry price - Stop distance(entry bar)) OR (short position AND high >= entry price + Stop distance(entry bar))
Calculation: Target hit = (long position AND high >= entry price + reward multiple * Stop distance(entry bar)) OR (short position AND low <= entry price - reward multiple * Stop distance(entry bar))
Calculation: Consecutive losses = 0 if day of month differs from previous bar; else Consecutive losses[1] + 1 if Stop-out; else 0 if Target hit; else Consecutive losses[1]
Calculation: Confirmation count = number of TRUE among: (Bullish structure OR Bearish structure); Liquidity sweep; abs(close - open) > SMA(abs(close - open), body lookback) * body multiple; (low > high[2] AND close[1] > high[2]) OR (high < low[2] AND close[1] < low[2]); (Bullish break OR Bearish break); (Bullish retest OR Bearish retest); (RSI value > RSI upper level AND Bullish structure) OR (RSI value < RSI lower level AND Bearish structure); close within bounds of a High or Low band with touch count >= minimum touches; Stop distance > 0
Calculation: Long entry signal = Confirmation count >= minimum score AND Bullish structure AND Bullish break AND NOT Long state[1] AND NOT Short state[1] AND Consecutive losses[1] < maximum losses AND Session allowed AND (no earlier long entry signal OR bars since most recent earlier long entry signal > Entry gap)
Calculation: Short entry signal = Confirmation count >= minimum score AND Bearish structure AND Bearish break AND NOT Short state[1] AND NOT Long state[1] AND Consecutive losses[1] < maximum losses AND Session allowed AND (no earlier short entry signal OR bars since most recent earlier short entry signal > Entry gap)
Calculation: Long state = Long entry signal OR (Long state[1] AND Confirmation count >= minimum score - score drop margin)
Calculation: Short state = Short entry signal OR (Short state[1] AND Confirmation count >= minimum score - score drop margin)
Calculation: RSI value = RSI(close, RSI length)
Calculation: Shorter EMA = EMA(close, shorter EMA length)
Calculation: Longer EMA = EMA(close, longer EMA length)
Calculation: Anchored VWAP = VWAP(hlc3, anchored at each T1 start)
Long: Long entry signal
Short: Short entry signal
Long: Bullish structure
Short: Bearish structure
Long: Bullish break
Short: Bearish break
Long: PivotHigh(high, swing length, swing length) confirmed on this bar AND Swing high(1) > Swing high(2)
Short: PivotHigh(high, swing length, swing length) confirmed on this bar AND Swing high(1) <= Swing high(2)
Long: PivotLow(low, swing length, swing length) confirmed on this bar AND Swing low(1) > Swing low(2)
Short: PivotLow(low, swing length, swing length) confirmed on this bar AND Swing low(1) <= Swing low(2)
Long: a Low band with touch count >= minimum touches exists
Short: a High band with touch count >= minimum touches exists
Long: Shorter EMA > Longer EMA
Short: Shorter EMA <= Longer EMA
Long: RSI value > RSI midline
Short: RSI value <= RSI midline
Long: close > Anchored VWAP
Short: close <= Anchored VWAP
Exit: long, low <= entry price - Stop distance(entry bar) OR high >= entry price + reward multiple * Stop distance(entry bar)
Exit: short, high >= entry price + Stop distance(entry bar) OR low <= entry price - reward multiple * Stop distance(entry bar)
Exit: long, Confirmation count < minimum score - score drop margin
Exit: short, Confirmation count < minimum score - score drop margin