Calculation: Session VWAP = session-anchored VWAP of the selected source
Calculation: VWAP deviation = rolling standard deviation of selected source minus session VWAP
Calculation: No-trade zone = close is between session VWAP plus/minus the configured multiple of VWAP deviation
Calculation: Zone exit = previous bar was in the no-trade zone AND current bar is outside it
Calculation: Trend average = selected SMA or EMA of close
Calculation: Uptrend = close > trend average; downtrend = close < trend average
Calculation: Body = absolute close minus open; range = high minus low; upper shadow = high minus max(open, close); lower shadow = min(open, close) minus low; body midpoint = (open + close) / 2
Calculation: Long-body bar = body as a percentage of close, range, and ATR each exceeds its configured threshold; short-body bar = body as a percentage of range is below its configured threshold
Calculation: Bullish engulfing = previous bar bearish AND current bar bullish AND current open <= previous close AND current close > previous open AND current body exceeds previous body by its configured threshold AND previous bar is in a downtrend
Calculation: Bearish engulfing = previous bar bullish AND current bar bearish AND current open >= previous close AND current close < previous open AND current body exceeds previous body by its configured threshold AND previous bar is in an uptrend
Calculation: Bullish harami = previous bar bearish AND current bar bullish AND current open > previous close AND current close < previous open AND current body is below its configured fraction of previous body AND previous bar is a long-body bar in a downtrend
Calculation: Bearish harami = previous bar bullish AND current bar bearish AND current open < previous close AND current close > previous open AND current body is below its configured fraction of previous body AND previous bar is a long-body bar in an uptrend
Calculation: Hammer shape = lower shadow exceeds body by its configured ratio AND upper shadow is below its configured fraction of range AND range exceeds its configured fraction of ATR AND body > 0; inverted hammer shape = same conditions with upper and lower shadows exchanged
Calculation: Morning star = bar two bars ago bearish with body > its ATR AND previous bar short-bodied with close below the bar two bars ago close AND current bar bullish with close > previous close AND bar two bars ago in a downtrend
Calculation: Evening star = bar two bars ago bullish with body > its ATR AND previous bar short-bodied with close above the bar two bars ago close AND current bar bearish with close < previous close AND bar two bars ago in an uptrend
Calculation: Piercing line = previous bar bearish with body > its ATR by the configured fraction AND current bar bullish with open < previous close AND close above previous body midpoint but below previous open AND previous bar in a downtrend
Calculation: Dark cloud = previous bar bullish with body > its ATR by the configured fraction AND current bar bearish with open > previous close AND close below previous body midpoint but above previous open AND previous bar in an uptrend
Calculation: Bullish REB = current range exceeds its rolling average by the configured multiple AND current bar bullish AND close is in the upper third of its range AND current bar in an uptrend; bearish REB = same range condition AND current bar bearish AND close is in the lower third of its range AND current bar in a downtrend
Calculation: Bullish sweep = current low < lowest low of the configured number of preceding bars AND close > that low AND current bar bullish AND current bar in a downtrend; bearish sweep = current high > highest high of preceding bars AND close < that high AND current bar bearish AND current bar in an uptrend
Calculation: Bullish body dominance = current bar bullish AND body as a percentage of range exceeds its configured threshold; bearish body dominance = same with current bar bearish
Calculation: Bullish pattern = bullish engulfing OR bullish harami OR hammer shape in a downtrend OR inverted hammer shape in a downtrend OR morning star OR piercing line OR bullish REB OR bullish sweep OR bullish body dominance
Calculation: Bearish pattern = bearish engulfing OR bearish harami OR hammer shape in an uptrend OR inverted hammer shape in an uptrend OR evening star OR dark cloud OR bearish REB OR bearish sweep OR bearish body dominance
Long: zone exit AND bullish pattern AND close > trend average
Short: zone exit AND bearish pattern AND close < trend average