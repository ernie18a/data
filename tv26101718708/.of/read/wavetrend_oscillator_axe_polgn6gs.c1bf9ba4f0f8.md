Calculation: Oscillator = let price be log(close), delta = price − EMA(price, channel length), deviation = EMA(abs(delta), channel length), and normalized = 0 if deviation = 0, otherwise delta / deviation. Apply an EMA of average length to normalized, then apply the two-pole Ehlers SuperSmoother of smoothing length. Initialize each EMA with its first available input; initialize the SuperSmoother with its input when its recurrence is unavailable. The SuperSmoother recurrence is y = c1 × (x + previous x) + c2 × previous y + c3 × y two bars ago, where a = exp(−π × sqrt(2) / smoothing length), c2 = 2 × a × cos(π × sqrt(2) / smoothing length), c3 = −a², and c1 = (1 − c2 − c3) / 2; use current x for an unavailable previous x and previous y for an unavailable y two bars ago.
Calculation: Trigger = SMA of oscillator over a separate trigger length.
Calculation: Bottom = trigger < overbought threshold AND oscillator crosses above trigger AND the previous bar's sum of oscillator over the turn lookback < the previous bar's sum of trigger over the same lookback.
Calculation: Top = trigger > oversold threshold AND oscillator crosses below trigger AND the previous bar's sum of oscillator over the turn lookback > the previous bar's sum of trigger over the same lookback.
Calculation: Bottom level = trigger at the latest bottom; bottom price = lowest low over the turn lookback at that bottom. Top level = trigger at the latest top; top price = highest high over the turn lookback at that top. Retain the preceding bottom and top levels and prices separately for divergence comparisons.
Calculation: Rising accumulation of a series with a gate = previous accumulation plus the series change when the series is greater than or equal to its previous value and the gate is true; otherwise zero. Falling accumulation = previous accumulation plus the decrease when the series is less than or equal to its previous value and the gate is true; otherwise zero. Initialize accumulation to zero.
Calculation: Hidden bullish strength = sqrt(falling accumulation of bottom level × rising accumulation of the lowest log(close) over the turn lookback, sampled and held at bottoms); hidden bearish strength = sqrt(rising accumulation of top level × falling accumulation of the highest log(close) over the turn lookback, sampled and held at tops). Both use an always-true gate. Normalize each strength by dividing it by one plus the other unnormalized strength.
Calculation: Bullish trend accumulation = rising accumulation of bottom level with gate oscillator < overbought threshold; bearish trend accumulation = falling accumulation of top level with gate oscillator > oversold threshold. Normalize each by dividing it by one plus the other unnormalized accumulation.
Long: Bottom.
Short: Top.
Long: Bottom AND bottom level > preceding bottom level AND bottom price < preceding bottom price.
Long: Bottom AND bottom level < preceding bottom level AND bottom price > preceding bottom price.
Short: Top AND top level < preceding top level AND top price > preceding top price.
Short: Top AND top level > preceding top level AND top price < preceding top price.
Long: Oscillator > trigger.
Short: Oscillator <= trigger.
Long: Oscillator <= oversold threshold.
Short: Oscillator >= overbought threshold.
Long: Bullish trend accumulation > bearish trend accumulation.
Short: Bearish trend accumulation > bullish trend accumulation.
Long: Oscillator > trigger on the chart timeframe AND on each of two higher timeframes, using each higher timeframe's last completed bar.
Short: Oscillator <= trigger on the chart timeframe AND on each of two higher timeframes, using each higher timeframe's last completed bar.