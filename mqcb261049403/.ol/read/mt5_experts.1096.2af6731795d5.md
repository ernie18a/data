Calculation: Oscillator = shorter-period moving average of the selected OHLC-derived price minus longer-period moving average of the same price, using the same selectable smoothing method and smoothing parameters for both averages.
Calculation: Signal = selectable moving average of the oscillator, with its own smoothing method and parameters.
Calculation: Selected price = open, high, low, close, (high + low)/2, (high + low + close)/3, (high + low + 2 × close)/4, (open + close)/2, (open + high + low + close)/4, or, according to a selectable variant, high or (high + close)/2 when close > open, low or (low + close)/2 when close < open, and close otherwise.
Calculation: Indicator values for the trading decisions use a selectable indicator timeframe, which may be higher or lower than the chart timeframe or the chart timeframe itself; the selected bar may be the still-forming bar or a completed bar at a configurable lag. Previous values refer to preceding bars of that indicator timeframe. Indicator values for the marking decisions use the current and previous chart bars.
Long: Chart-timeframe oscillator > chart-timeframe oscillator on the previous bar AND chart-timeframe oscillator != 0.
Short: Chart-timeframe oscillator < chart-timeframe oscillator on the previous bar AND chart-timeframe oscillator != 0.
Long: Chart-timeframe oscillator > chart-timeframe signal on the previous bar.
Short: Chart-timeframe oscillator < chart-timeframe signal on the previous bar.
Long: Oscillator > 0 AND previous oscillator <= 0.
Short: Oscillator < 0 AND previous oscillator >= 0.
Long: Oscillator > previous oscillator AND previous oscillator < oscillator two bars ago.
Short: Oscillator < previous oscillator AND previous oscillator > oscillator two bars ago.
Long: Signal > previous signal AND previous signal < signal two bars ago.
Short: Signal < previous signal AND previous signal > signal two bars ago.
Long: Oscillator > signal AND previous oscillator <= previous signal.
Short: Oscillator < signal AND previous oscillator >= previous signal.
Exit: long, oscillator < 0 OR oscillator < previous oscillator OR signal < previous signal OR oscillator < signal.
Exit: short, oscillator > 0 OR oscillator > previous oscillator OR signal > previous signal OR oscillator > signal.
Exit: long, low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance.
Exit: short, high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance.