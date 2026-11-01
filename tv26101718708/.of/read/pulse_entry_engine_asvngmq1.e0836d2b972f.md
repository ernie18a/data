Calculation: Momentum engine and signal = TradingView Special K applied to a selectable OHLC-derived price source with independently selectable primary and secondary lengths; the higher-timeframe version uses close and the same lengths.
Calculation: Distance ratio = absolute difference between momentum engine and signal divided by its simple moving average; use zero when the average is not positive.
Calculation: Qualified setup score = 60 + 40 × min(distance ratio / extreme-stretch threshold, 1).
Calculation: Signal state = initially neutral; set to long or short when the corresponding pulse is emitted. If weak-distance reset is enabled, reset to neutral when the distance ratio is at or below the reset threshold and neither qualified long nor qualified short setup is present.
Calculation: Qualified long setup = momentum engine < signal AND distance ratio >= mode-specific strong-stretch threshold AND qualified setup score >= mode-specific minimum score AND (zero filter disabled OR momentum engine < 0) AND (EMA filter disabled OR close < EMA of close) AND (higher-timeframe filter disabled OR selected higher-timeframe bias >= 0). Force the zero and EMA filters on in the stricter modes.
Calculation: Qualified short setup = momentum engine > signal AND distance ratio >= mode-specific strong-stretch threshold AND qualified setup score >= mode-specific minimum score AND (zero filter disabled OR momentum engine > 0) AND (EMA filter disabled OR close > EMA of close) AND (higher-timeframe filter disabled OR selected higher-timeframe bias <= 0). Force the zero and EMA filters on in the stricter modes.
Calculation: Higher-timeframe bias = sign of higher-timeframe close minus its selected EMA, or sign of higher-timeframe momentum engine minus its signal. The alternative EMA choices use shorter and longer lookbacks. Use the last completed higher-timeframe bar on historical bars, updating on the bar that completes it; use the still-forming higher-timeframe bar in live calculation.
Calculation: Projection levels = entry-bar close plus or minus risk distance, where risk distance is entry-bar ATR multiplied by a stop multiplier. The final target distance is risk distance multiplied by a reward-to-risk multiplier; the first and second targets are respectively one quarter and one half of that final distance. Long targets are above entry and the stop is below; short targets are below entry and the stop is above. Check targets and stops only after the entry bar.
Calculation: Projection progress = highest target reached since entry, updated before testing a new pulse. If a target and stop are both touched on the same bar, close the projection using either the previously reached target or stop, or the higher of the previously reached target and the first target, according to the selected same-bar rule.
Long: qualified long setup AND signal state != long AND (projection tracking disabled OR no active projection has failed to reach its first target).
Short: qualified short setup AND signal state != short AND (projection tracking disabled OR no active projection has failed to reach its first target).
Long: momentum engine < signal AND distance ratio >= mode-specific extreme-stretch threshold.
Short: momentum engine > signal AND distance ratio >= mode-specific extreme-stretch threshold.
Long: close < EMA of close.
Short: close > EMA of close.
Long: momentum engine < 0.
Short: momentum engine > 0.
Long: momentum engine - signal >= 0.
Short: momentum engine - signal < 0.
Long: EMA of momentum engine >= EMA of signal, using equal smoothing lengths.
Short: EMA of momentum engine < EMA of signal, using equal smoothing lengths.
Exit: long, projection tracking enabled AND bar after entry AND (low <= stop OR high >= final target OR (projection progress >= first target AND a new long or short pulse occurs)).
Exit: short, projection tracking enabled AND bar after entry AND (high >= stop OR low <= final target OR (projection progress >= first target AND a new long or short pulse occurs)).