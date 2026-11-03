Calculation: Base high = highest high over the previous base lookback bars; base low = lowest low over those bars.
Calculation: Compact base = Base high − Base low ≤ ATR × base-range multiplier.
Calculation: Prior impulse = close[base lookback] − close[base lookback + impulse lookback]; rally = Prior impulse > ATR × impulse multiplier; drop = Prior impulse < −ATR × impulse multiplier.
Calculation: Upward base break = close > Base high AND previous close ≤ Base high; downward base break = close < Base low AND previous close ≥ Base low.
Calculation: Double bottom = two confirmed swing lows within the configured price tolerance and maximum separation, followed by close above the highest high over the neckline lookback captured when the second swing low is confirmed.
Calculation: Double top = two confirmed swing highs within the configured price tolerance and maximum separation, followed by close below the lowest low over the neckline lookback captured when the second swing high is confirmed.
Calculation: Long setup = (rally AND Compact base AND Upward base break) OR (drop AND Compact base AND Upward base break) OR Double bottom.
Calculation: Short setup = (drop AND Compact base AND Downward base break) OR (rally AND Compact base AND Downward base break) OR Double top.
Calculation: Long retest = within the configured wait bars after a Long setup, low ≤ its breakout level AND close ≥ that level AND close > open.
Calculation: Short retest = within the configured wait bars after a Short setup, high ≥ its breakout level AND close ≤ that level AND close < open.
Calculation: Fast, medium, and slow EMAs = exponential moving averages of close, with progressively longer lookbacks.
Calculation: Higher-timeframe EMA bias = close > EMA for bullish bias; close < EMA for bearish bias; use the higher timeframe bar available to the strategy.
Long: Long setup OR Long retest AND (close > medium EMA OR fast EMA > medium EMA AND medium EMA > slow EMA) AND higher-timeframe bullish bias AND within the configured trading session AND daily trade limits permit entry AND flat.
Short: Short setup OR Short retest AND (close < medium EMA OR fast EMA < medium EMA AND medium EMA < slow EMA) AND higher-timeframe bearish bias AND within the configured trading session AND daily trade limits permit entry AND flat.
Calculation: Initial stop distance = clamp((distance from entry close to the lowest low over the structure lookback, in ticks) + stop buffer, minimum stop, maximum stop) × tick size for longs; use the distance from entry close to the highest high for shorts.
Calculation: First and second target prices = entry price plus (long stop distance × respective reward multiple) for longs; entry price minus (short stop distance × respective reward multiple) for shorts.
Exit: Long, low ≤ initial stop OR high ≥ first target OR high ≥ second target; after the first target is reached, replace the stop with entry price plus the configured break-even offset.
Exit: Short, high ≥ initial stop OR low ≤ first target OR low ≤ second target; after the first target is reached, replace the stop with entry price minus the configured break-even offset.