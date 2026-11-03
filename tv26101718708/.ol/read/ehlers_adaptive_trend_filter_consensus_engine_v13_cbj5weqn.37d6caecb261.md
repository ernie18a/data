Calculation: Fast bullish state = 2-pole Ehlers SuperSmoother of close with a shorter lookback > 2-pole Ehlers SuperSmoother of that signal with a longer lookback
Calculation: Core bullish state = 3-pole Ehlers SuperSmoother of close with a shorter lookback > 2-pole Ehlers SuperSmoother of that signal with a longer lookback
Calculation: Adaptive bullish state = MAMA of close > FAMA of close
Calculation: Chart bullish state = the selected chart signal filter > its baseline; the signal uses a shorter lookback than the baseline, except in MAMA/FAMA mode, which compares MAMA with FAMA
Long: Chart bullish state OR at least one of Fast bullish state, Core bullish state, or Adaptive bullish state is true
Short: Chart bullish state is false AND Fast bullish state, Core bullish state, and Adaptive bullish state are all false