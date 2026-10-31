Calculation: Oscillator = Jurik moving average of the moving average of (close − first moving average − second moving average), where the first moving average is of close and the second is of (close − first moving average); all three moving averages use the same method and period. The oscillator uses the chart timeframe or a configurable higher or lower timeframe, with the last completed bar by default or the still-forming bar if configured.
Long: Oscillator > previous oscillator
Long: Oscillator > previous oscillator AND previous oscillator < oscillator two bars ago
Short: Oscillator < previous oscillator
Short: Oscillator < previous oscillator AND previous oscillator > oscillator two bars ago
Exit: long, oscillator < previous oscillator OR low <= entry price − stop-loss distance OR high >= entry price + take-profit distance
Exit: short, oscillator > previous oscillator OR high >= entry price + stop-loss distance OR low <= entry price − take-profit distance