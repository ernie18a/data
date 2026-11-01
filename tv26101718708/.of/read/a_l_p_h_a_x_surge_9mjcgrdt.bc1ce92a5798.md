Calculation: Swing high/low = most recent confirmed pivot high/low, using the same number of bars on each side; update the level on its confirmation bar.
Calculation: Structure direction = initially neutral; set bullish when close > swing high and bearish when close < swing low, applying the bearish update last if both occur. A reversal break uses the direction before the update; a continuation break requires that direction already match the break.
Calculation: Bull sweep = low < swing low − ATR × sweep threshold AND close > swing low AND close > open. Bear sweep = high > swing high + ATR × sweep threshold AND close < swing high AND close < open.
Calculation: Equilibrium = (highest high + lowest low) / 2 over the same lookback.
Calculation: Higher-timeframe EMA bias = shorter-period EMA compared with longer-period EMA of higher-timeframe closes; on historical chart bars use the last completed higher-timeframe bar, and on a live bar use the higher-timeframe bar still forming.
Calculation: Momentum = linear regression endpoint of close − average of (the midpoint of the highest high and lowest low over the momentum lookback) and (SMA of close over that lookback), using the same lookback.
Calculation: Volume delta = EMA of estimated bull volume minus EMA of estimated bear volume, using the same period; estimated bull volume = volume × (close − low) / (high − low), or half of volume when high = low; estimated bear volume = volume − estimated bull volume. Smooth volume delta again with a separate EMA. OBV slope = OBV minus its value at a prior lookback.
Calculation: Bull score = count of true conditions: bull sweep on current or previous bar; current structure bullish; PD filter disabled OR close <= equilibrium; higher-timeframe filter disabled OR shorter EMA > longer EMA; momentum > 0 AND momentum > previous momentum; volume delta > 0 AND its EMA > 0 AND OBV slope > 0. Bear score uses bear sweep, bearish structure, close >= equilibrium, shorter EMA < longer EMA, and the opposite strict momentum and volume comparisons.
Calculation: Bull setup = bull sweep on current or previous bar AND (reversal setups enabled AND close > swing high AND previous structure bearish OR continuation setups enabled AND current structure bullish) AND bull score >= threshold AND (ADX filter disabled OR ADX >= threshold) AND (session filter disabled OR bar time is in configured session) AND bars since last bull entry signal >= cooldown AND (VWAP filter disabled OR close > session VWAP of typical price). Bear setup uses bear sweep, close < swing low with previous structure bullish, current structure bearish, bear score, last bear entry signal, and close < session VWAP. Session VWAP resets at the exchange session start. Evaluate cooldown before updating the last signal bar.
Calculation: Entry signal = setup true on this bar AND setup false on the preceding bar. Each entry signal resets the tracked position, entry bar and exit levels, even if a position is already active; process a short signal after a long signal if both occur on the same bar.
Calculation: Entry stop base = entry-bar swing low for a long or swing high for a short when sweep anchoring is enabled and that level exists; otherwise entry-bar low for a long or high for a short. Fixed stop = entry stop base minus entry-bar ATR × stop multiplier for a long, plus it for a short. Targets = entry price plus entry-bar ATR × target multiplier for a long, minus it for a short; the full-target multiplier is larger than the partial-target multiplier.
Calculation: Trailing stop = entry stop base minus entry-bar ATR × trail multiplier for a long, plus it for a short; on each subsequent bar with trailing enabled, update it to the maximum of its prior value and low − current ATR × trail multiplier for a long, or the minimum of its prior value and high + current ATR × trail multiplier for a short, before testing exits.
Long: bull sweep.
Short: bear sweep.
Long: close > swing high AND previous structure direction is bearish OR bullish.
Short: close < swing low AND previous structure direction is bullish OR bearish.
Long: short-period EMA > medium-period EMA AND medium-period EMA > long-period EMA AND close > short-period EMA.
Short: short-period EMA < medium-period EMA AND medium-period EMA < long-period EMA AND close < short-period EMA.
Long: shorter higher-timeframe EMA > longer higher-timeframe EMA.
Short: shorter higher-timeframe EMA < longer higher-timeframe EMA.
Long: close <= equilibrium.
Short: close >= equilibrium AND close > equilibrium.
Long: momentum > 0 AND momentum > previous momentum, when the Bollinger bands are not strictly inside the Keltner channel.
Short: momentum < 0 AND momentum < previous momentum, when the Bollinger bands are not strictly inside the Keltner channel.
Long: volume delta > 0 AND its EMA > 0 AND OBV slope > 0.
Short: volume delta < 0 AND its EMA < 0 AND OBV slope < 0.
Long: bull entry signal.
Short: bear entry signal.
Exit: long, bars since entry > 0 AND high >= partial target AND high < full target; exit half the position.
Exit: short, bars since entry > 0 AND low <= partial target AND low > full target; exit half the position.
Exit: long, bars since entry > 0 AND (low <= fixed stop OR high >= full target) OR bars since entry > 1 AND trailing enabled AND low <= trailing stop.
Exit: short, bars since entry > 0 AND (high >= fixed stop OR low <= full target) OR bars since entry > 1 AND trailing enabled AND high >= trailing stop.