Calculation: Oscillator = shorter-period moving average of a selected OHLC-derived price minus longer-period moving average of the same price, using the same smoothing method and smoothing parameter for both averages.
Calculation: Signal = moving average of the oscillator, with independently selected smoothing method, period, and smoothing parameter.
Long: Chart-timeframe oscillator != 0 AND oscillator > previous bar's oscillator.
Short: Chart-timeframe oscillator != 0 AND oscillator < previous bar's oscillator.
Long: Chart-timeframe oscillator > previous bar's signal.
Short: Chart-timeframe oscillator < previous bar's signal.
Long: On the first chart bar of a higher-timeframe bar, the still-forming higher-timeframe oscillator != 0 AND oscillator > previous higher-timeframe bar's oscillator.
Short: On the first chart bar of a higher-timeframe bar, the still-forming higher-timeframe oscillator != 0 AND oscillator < previous higher-timeframe bar's oscillator.
Long: On the first chart bar of a higher-timeframe bar, the still-forming higher-timeframe oscillator > its signal.
Short: On the first chart bar of a higher-timeframe bar, the still-forming higher-timeframe oscillator < its signal.