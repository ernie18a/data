Calculation: Structure bars = bars on a timeframe equal to or higher than the chart timeframe; use the last completed structure bar and evaluate events only when its timestamp changes.
Calculation: Breakout references = the highest high and lowest low over a lookback of structure bars immediately preceding the last completed structure bar.
Calculation: Breakout strength = the absolute body of the last completed structure bar divided by the SMA of absolute structure-bar bodies through that bar.
Calculation: Bullish breakout = last completed structure close > upper breakout reference AND (strength filter disabled OR breakout strength >= strength threshold).
Calculation: Bearish breakout = last completed structure close < lower breakout reference AND (strength filter disabled OR breakout strength >= strength threshold).
Calculation: Active level = the reference broken by the most recent strength-qualified breakout, with its direction and creation structure-bar count; each new breakout replaces the previous level and resets its retested state. Process breakouts before retests on the same chart bar.
Calculation: Level validity = active level exists AND (validity window disabled OR structure bars elapsed since creation <= validity limit).
Calculation: Bullish retest = active level direction is bullish AND level validity is true AND level has not been retested AND last completed structure close > active level AND (wick-touch mode AND last completed structure low <= active level OR ATR-proximity mode AND absolute difference between last completed structure low and active level <= last completed structure ATR multiplied by proximity factor).
Calculation: Bearish retest = active level direction is bearish AND level validity is true AND level has not been retested AND last completed structure close < active level AND (wick-touch mode AND last completed structure high >= active level OR ATR-proximity mode AND absolute difference between last completed structure high and active level <= last completed structure ATR multiplied by proximity factor).
Calculation: Retested state = true after the first bullish or bearish retest, regardless of trend alignment; reset only when a new breakout replaces the active level.
Calculation: Trend averages = independently selected EMA or SMA of close for each layer, using the last completed bar of its timeframe; the structure layer is equal to or higher than the chart timeframe, the intermediate layer is higher than the structure layer, and the highest layer is higher than the intermediate layer. Each layer has a shorter and a longer lookback; the intermediate layer also has a short-lookback price average.
Long: On a new completed structure bar, bullish breakout OR bullish retest.
Short: On a new completed structure bar, bearish breakout OR bearish retest.
Long: Highest-layer shorter-lookback average > highest-layer longer-lookback average.
Short: Highest-layer shorter-lookback average < highest-layer longer-lookback average.
Long: Intermediate-layer shorter-lookback average > intermediate-layer longer-lookback average AND last completed intermediate close > intermediate-layer price average.
Short: Intermediate-layer shorter-lookback average < intermediate-layer longer-lookback average AND last completed intermediate close < intermediate-layer price average.
Long: Structure-layer shorter-lookback average > structure-layer longer-lookback average.
Short: Structure-layer shorter-lookback average < structure-layer longer-lookback average.