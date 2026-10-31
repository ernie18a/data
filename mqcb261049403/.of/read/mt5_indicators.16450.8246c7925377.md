Calculation: Oscillator = a configurable moving average of the FATL filter of a configurable OHLC-derived price minus a separately configurable moving average of the SATL filter of the same price; calculate on the chart timeframe or on the still-forming bar of a higher timeframe.
Calculation: Signal = a separately configurable moving average of the oscillator on the same timeframe as the oscillator.
Long: Oscillator > 0 AND oscillator > previous oscillator
Long: Oscillator > 0 AND oscillator < previous oscillator
Long: Oscillator > signal AND oscillator != 0 AND signal != 0
Short: Oscillator < 0 AND oscillator < previous oscillator
Short: Oscillator < 0 AND oscillator > previous oscillator
Short: Oscillator < signal AND oscillator != 0 AND signal != 0