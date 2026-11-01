Calculation: Fibonacci candle state = For each bar, calculate the highest high and lowest low over a lookback including that bar, and multiply their difference by a Fibonacci ratio. Initialize the trend state to neutral. If open > close, set trend to negative when the previous trend is negative AND close minus the lowest low > the multiplied range; otherwise set it to positive. If open <= close, set trend to positive when the previous trend is positive AND the highest high minus close > the multiplied range; otherwise set it to negative. The candle state is bearish when trend is positive AND open != close; otherwise it is bullish.
Long: On the chart timeframe, the selected candle state changes from bullish to bearish.
Short: On the chart timeframe, the selected candle state changes from bearish to bullish.
Long: On the configurable indicator timeframe, which may be higher or lower than the chart timeframe, the selected candle state changes from bearish to bullish.
Short: On the configurable indicator timeframe, which may be higher or lower than the chart timeframe, the selected candle state changes from bullish to bearish.
Calculation: Selected candle state = The state of a configurable signal bar: either the still-forming bar or a completed bar. For a completed indicator-timeframe bar, evaluate on the first update of each new indicator-timeframe bar; for the still-forming bar, evaluate as it updates.
Exit: long, the selected indicator-timeframe candle state is bearish.
Exit: short, the selected indicator-timeframe candle state is bullish.
Exit: long, low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance.
Exit: short, high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance.