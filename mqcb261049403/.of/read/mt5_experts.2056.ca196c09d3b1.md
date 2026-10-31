Calculation: Oscillator = 100 times the triple-smoothed selected price momentum divided by triple-smoothed absolute momentum, or 0 when the denominator is 0. Momentum is selected price minus its value momentum-period-minus-one bars ago. Apply the same selected smoothing method in sequence to both momentum series, using the same first, second, and third smoothing periods for each.
Calculation: Signal = the selected smoothing method applied to the oscillator using a separate signal period.
Calculation: Trading oscillator and trading signal = the same calculations on a configurable indicator timeframe, which may be the chart timeframe or a higher or lower timeframe; use the last completed indicator bar by default, or the forming indicator bar when configured. Previous values refer to preceding indicator-timeframe bars.
Long: Chart-timeframe oscillator > 0 AND oscillator > previous oscillator OR chart-timeframe oscillator < 0 AND oscillator > previous oscillator
Short: Chart-timeframe oscillator > 0 AND oscillator < previous oscillator OR chart-timeframe oscillator < 0 AND oscillator < previous oscillator
Long: Chart-timeframe oscillator > chart-timeframe signal
Short: Chart-timeframe oscillator < chart-timeframe signal
Long: Trading oscillator > 0 AND previous trading oscillator <= 0
Short: Trading oscillator < 0 AND previous trading oscillator >= 0
Long: Trading oscillator > previous trading oscillator AND previous trading oscillator < oscillator two indicator bars ago
Short: Trading oscillator < previous trading oscillator AND previous trading oscillator > oscillator two indicator bars ago
Long: Trading oscillator > trading signal AND previous trading oscillator <= previous trading signal
Short: Trading oscillator < trading signal AND previous trading oscillator >= previous trading signal
Exit: long, zero-crossing mode selected AND trading oscillator < 0 OR turning-point mode selected AND trading oscillator < previous trading oscillator OR signal-crossing mode selected AND trading oscillator < trading signal
Exit: short, zero-crossing mode selected AND trading oscillator > 0 OR turning-point mode selected AND trading oscillator > previous trading oscillator OR signal-crossing mode selected AND trading oscillator > trading signal
Exit: long, stop loss enabled AND low <= entry price minus stop distance OR take profit enabled AND high >= entry price plus profit distance
Exit: short, stop loss enabled AND high >= entry price plus stop distance OR take profit enabled AND low <= entry price minus profit distance