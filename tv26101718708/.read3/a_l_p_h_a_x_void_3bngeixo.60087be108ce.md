Calculation: FVG midpoint = (FVG top + FVG bottom) / 2
Calculation: Bullish estimated volume = volume * (close - low) / (high - low), or volume / 2 when high = low
Calculation: Bearish estimated volume = volume - bullish estimated volume
Calculation: Volume delta = EMA(bullish estimated volume, volume lookback) - EMA(bearish estimated volume, volume lookback)
Calculation: Smoothed volume delta = EMA(volume delta, separate delta smoothing lookback)
Calculation: Bullish EMA ribbon = EMA(close, fast lookback) > EMA(close, slow lookback) AND EMA(close, slow lookback) > EMA(close, signal lookback) AND close > EMA(close, fast lookback)
Calculation: Bearish EMA ribbon = EMA(close, fast lookback) < EMA(close, slow lookback) AND EMA(close, slow lookback) < EMA(close, signal lookback) AND close < EMA(close, fast lookback)
Calculation: Bullish momentum = Squeeze Momentum(close, high, low, momentum lookback) > 0 AND Squeeze Momentum(close, high, low, momentum lookback) > Squeeze Momentum(close, high, low, momentum lookback)[1]
Calculation: Bearish momentum = Squeeze Momentum(close, high, low, momentum lookback) < 0 AND Squeeze Momentum(close, high, low, momentum lookback) < Squeeze Momentum(close, high, low, momentum lookback)[1]
Calculation: Bullish volume pressure = volume delta > 0 AND smoothed volume delta > 0 AND OBV(close, volume) > OBV(close, volume)[OBV lookback]
Calculation: Bearish volume pressure = volume delta < 0 AND smoothed volume delta < 0 AND OBV(close, volume) < OBV(close, volume)[OBV lookback]
Calculation: Bullish VWAP vote = VWAP filter disabled OR close > VWAP(hlc3, current session)
Calculation: Bearish VWAP vote = VWAP filter disabled OR close < VWAP(hlc3, current session)
Calculation: Bullish ADX vote = ADX filter disabled OR (ADX(ADX lookback) >= ADX minimum AND +DI(ADX lookback) > -DI(ADX lookback))
Calculation: Bearish ADX vote = ADX filter disabled OR (ADX(ADX lookback) >= ADX minimum AND -DI(ADX lookback) > +DI(ADX lookback))
Calculation: Bullish vote count = count of true conditions among bullish EMA ribbon, bullish momentum, bullish volume pressure, bullish VWAP vote, and bullish ADX vote
Calculation: Bearish vote count = count of true conditions among bearish EMA ribbon, bearish momentum, bearish volume pressure, bearish VWAP vote, and bearish ADX vote
Calculation: Bullish FVG retest = the current bar overlaps the most recently formed retained bullish FVG that remains unfilled, is within the maximum age measured from its first candle, closes above its open, and closes at or above its midpoint when CE rejection is enabled or its bottom otherwise; bullish FVGs become filled when a post-formation bar's low is at or below the bottom
Calculation: Bearish FVG retest = the current bar overlaps the most recently formed retained bearish FVG that remains unfilled, is within the maximum age measured from its first candle, closes below its open, and closes at or below its midpoint when CE rejection is enabled or its top otherwise; bearish FVGs become filled when a post-formation bar's high is at or above the top
Long: A confirmed bar has low > high[2], abs(close[1] - open[1]) >= SMA(abs(close - open), average body lookback) * displacement multiplier, and low - high[2] >= ATR(ATR lookback) * minimum gap multiplier
Short: A confirmed bar has high < low[2], abs(close[1] - open[1]) >= SMA(abs(close - open), average body lookback) * displacement multiplier, and low[2] - high >= ATR(ATR lookback) * minimum gap multiplier
Long: Bullish FVG retest
Short: Bearish FVG retest
Long: Bullish EMA ribbon
Short: Bearish EMA ribbon
Long: TTM Squeeze is off AND bullish momentum
Short: TTM Squeeze is off AND bearish momentum
Long: Bullish volume pressure
Short: Bearish volume pressure
Long: Bullish VWAP vote
Short: VWAP filter enabled AND close < VWAP(hlc3, current session)
Long: Bullish ADX vote
Short: ADX filter enabled AND ADX(ADX lookback) >= ADX minimum AND -DI(ADX lookback) > +DI(ADX lookback)
Long: Bullish vote count >= minimum layers required
Short: Bearish vote count >= minimum layers required
Long: Bullish FVG retest AND bullish vote count >= minimum layers required AND (ADX filter disabled OR ADX(ADX lookback) >= ADX minimum) AND (session filter disabled OR current bar is in the configured session) AND (EMA trend alignment disabled OR EMA(close, fast lookback) > EMA(close, slow lookback)) AND at least the cooldown number of chart bars since the previous long signal AND this entire setup was false on the previous chart bar
Short: Bearish FVG retest AND bearish vote count >= minimum layers required AND (ADX filter disabled OR ADX(ADX lookback) >= ADX minimum) AND (session filter disabled OR current bar is in the configured session) AND (EMA trend alignment disabled OR EMA(close, fast lookback) < EMA(close, slow lookback)) AND at least the cooldown number of chart bars since the previous short signal AND this entire setup was false on the previous chart bar
Calculation: Long stop base = selected retested FVG bottom when FVG-edge anchoring is enabled, otherwise signal-bar low
Calculation: Short stop base = selected retested FVG top when FVG-edge anchoring is enabled, otherwise signal-bar high
Calculation: Long trailing stop = maximum of (long stop base - ATR(signal bar, ATR lookback) * trail multiplier) and the maximum of (each post-signal chart bar's low - ATR(that bar, ATR lookback) * trail multiplier)
Calculation: Short trailing stop = minimum of (short stop base + ATR(signal bar, ATR lookback) * trail multiplier) and the minimum of (each post-signal chart bar's high + ATR(that bar, ATR lookback) * trail multiplier)
Exit: long, at least one chart bar since the signal AND low <= long stop base - ATR(signal bar, ATR lookback) * stop multiplier
Exit: long, at least one chart bar since the signal AND high >= signal-bar close + ATR(signal bar, ATR lookback) * first target multiplier
Exit: long, at least one chart bar since the signal AND high >= signal-bar close + ATR(signal bar, ATR lookback) * full target multiplier
Exit: long, trailing stop enabled AND at least two chart bars since the signal AND low <= long trailing stop
Exit: short, at least one chart bar since the signal AND high >= short stop base + ATR(signal bar, ATR lookback) * stop multiplier
Exit: short, at least one chart bar since the signal AND low <= signal-bar close - ATR(signal bar, ATR lookback) * first target multiplier
Exit: short, at least one chart bar since the signal AND low <= signal-bar close - ATR(signal bar, ATR lookback) * full target multiplier
Exit: short, trailing stop enabled AND at least two chart bars since the signal AND high >= short trailing stop