Calculation: Floored ATR = max(ATR(ATR length), minimum tick)
Calculation: Floored range = max(high - low, minimum tick)
Calculation: Effort ratio = (SMA(volume, effort length) > 0 ? volume / SMA(volume, effort length) : 1) * volume weight + True Range / Floored ATR * (1 - volume weight)
Calculation: Effort index = min(Effort ratio / high effort threshold * 100, effort index cap)
Calculation: Progress sign = close > close[progress bars] ? 1 : close < close[progress bars] ? -1 : close >= open ? 1 : -1
Calculation: Close-direction score = (Progress sign = 1 ? (close - low) / Floored range : 1 - (close - low) / Floored range) * 100
Calculation: Result index = min(min(abs(close - close[progress bars]) / Floored ATR / strong progress ATR multiple * 100, progress index cap) * progress weight + Close-direction score * close location weight, 100)
Calculation: Wick imbalance = ((high - max(open, close)) - (min(open, close) - low)) / Floored range
Calculation: Failed-progress bar = bar index > max(effort length, ATR length) + progress bars AND Effort ratio >= high effort threshold AND Result index <= poor result threshold
Calculation: Ease-progress bar = bar index > max(effort length, ATR length) + progress bars AND Effort ratio <= low effort threshold AND Result index >= strong result threshold
Calculation: Event side = Failed-progress bar ? -(abs(Wick imbalance) >= wick imbalance threshold ? sign(Wick imbalance) : close > open ? 1 : close < open ? -1 : Progress sign) : Ease-progress bar ? Progress sign : 0
Calculation: Accepted reaction = (Failed-progress bar OR Ease-progress bar) AND (Failed-progress bar ? Effort index * failed effort weight + (100 - Result index) * failed result weight + abs(Wick imbalance) * 100 * failed wick weight : (100 - Effort index) * ease effort weight + Result index * ease result weight + Close-direction score * ease close weight) >= min event confidence AND (no earlier Accepted reaction OR bars since last Accepted reaction >= cooldown bars) AND bar is closed
Long: Accepted reaction AND Event side > 0
Short: Accepted reaction AND Event side < 0