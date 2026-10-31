Calculation: Momentum input = max(high[t] - high[t - (momentum period - 1)], 0) - max(low[t - (momentum period - 1)] - low[t], 0).
Calculation: Oscillator = momentum input smoothed sequentially three times with the same selected moving-average method and independently adjustable periods; the first period is longer than the second, which is longer than the third.
Calculation: Signal = oscillator smoothed with the same moving-average method and an independently adjustable period.
Calculation: Trading oscillator and trading signal = oscillator and signal calculated on a configurable higher timeframe, using the last completed bar or the still-forming bar according to the signal-bar setting; previous values refer to preceding bars of that timeframe.
Long: Chart-timeframe oscillator > 0 AND oscillator > previous oscillator OR oscillator < 0 AND oscillator > previous oscillator.
Short: Chart-timeframe oscillator > 0 AND oscillator < previous oscillator OR oscillator < 0 AND oscillator < previous oscillator.
Long: Chart-timeframe oscillator > signal.
Short: Chart-timeframe oscillator < signal.
Long: Trading oscillator > 0 AND previous trading oscillator <= 0.
Short: Trading oscillator < 0 AND previous trading oscillator >= 0.
Long: Trading oscillator > previous trading oscillator AND previous trading oscillator < trading oscillator two bars ago.
Short: Trading oscillator < previous trading oscillator AND previous trading oscillator > trading oscillator two bars ago.
Long: Trading oscillator > trading signal AND previous trading oscillator <= previous trading signal.
Short: Trading oscillator < trading signal AND previous trading oscillator >= previous trading signal.
Exit: long, trading oscillator < 0.
Exit: short, trading oscillator > 0.
Exit: long, trading oscillator < previous trading oscillator.
Exit: short, trading oscillator > previous trading oscillator.
Exit: long, trading oscillator < trading signal.
Exit: short, trading oscillator > trading signal.
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.