Calculation: Oscillator = On the chart timeframe or a selectable higher timeframe, smooth a selectable OHLC-derived price with a selectable moving average of length N; subtract its value a selectable momentum lookback earlier. On each bar, sum the positive momentum values and the absolute negative momentum values separately over N bars. Starting both accumulators at zero, update each as (previous accumulator * (N - 1) + corresponding rolling sum) / N. If the negative accumulator is nonzero, the oscillator is 50 - 100 / (1 + positive accumulator / negative accumulator); otherwise it is zero. For higher-timeframe calculations use the last completed bar, or the still-forming bar when the selectable signal-bar offset is zero; otherwise use the completed bar at the selectable offset. Previous values refer to preceding bars of that same timeframe.
Calculation: State index = 4 if oscillator > upper level; 3 if oscillator > middle level AND oscillator <= upper level; 0 if oscillator < lower level; 1 if oscillator < middle level AND oscillator >= lower level; otherwise 2. Use the same timeframe and signal-bar offset as the oscillator.
Long: Oscillator > upper level AND previous oscillator <= upper level.
Short: Oscillator < lower level AND previous oscillator >= lower level.
Exit: short, oscillator > upper level.
Exit: long, oscillator < lower level.
Long: Oscillator > previous oscillator AND previous oscillator < oscillator two bars ago.
Short: Oscillator < previous oscillator AND previous oscillator > oscillator two bars ago.
Exit: short, oscillator > previous oscillator.
Exit: long, oscillator < previous oscillator.
Long: State index > previous state index AND previous state index < state index two bars ago.
Short: State index < previous state index AND previous state index > state index two bars ago.
Exit: short, state index > previous state index.
Exit: long, state index < previous state index.
Long: Oscillator > state index AND previous oscillator <= previous state index.
Short: Oscillator < state index AND previous oscillator >= previous state index.
Exit: short, oscillator > state index.
Exit: long, oscillator < state index.
Long: Oscillator > middle level.
Short: Oscillator < middle level.
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.