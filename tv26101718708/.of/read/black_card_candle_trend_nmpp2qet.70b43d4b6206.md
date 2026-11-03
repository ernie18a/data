Calculation: Signal-timeframe series = chart-timeframe series, or series calculated on a configurable higher timeframe using its last completed bar or its still-forming bar, or on a configurable lower timeframe using the last completed intrabar. For each raw signal, suppress it when the previous chart bar has the same raw signal; optionally require signal-timeframe confirmation.
Calculation: SSL line = moving average of highs when the SSL state is negative, otherwise moving average of lows; set the state to positive when close > moving average of highs, negative when close < moving average of lows, and otherwise retain its prior state, initially positive. The baseline and signal SSL lines have independently configurable moving-average types and lengths.
Calculation: Rapid Hull = WMA(2 × WMA(close, rounded half-length) − WMA(close, length), rounded square-root length).
Calculation: Adaptive Jurik line = Jurik filter of the selected price source with configurable phase and length equal to the integer part of base length × (1 + coefficient) / 2; coefficient = 1 − (ATR − lowest ATR) / (highest ATR − lowest ATR), or 0.5 when highest ATR equals lowest ATR. ATR and its high-low lookback use the same base length.
Long: Signal-timeframe configurable moving average > its previous value AND its previous value < its value two signal-timeframe bars ago.
Short: Signal-timeframe configurable moving average < its previous value AND its previous value > its value two signal-timeframe bars ago.
Long: Signal-timeframe moving average > its previous chart-bar value.
Short: Signal-timeframe moving average <= its previous chart-bar value.
Long: Signal-timeframe close crosses above the signal SSL line.
Short: Signal-timeframe close crosses below the signal SSL line.
Long: Chart close > signal-timeframe baseline SSL line.
Short: Chart close < signal-timeframe baseline SSL line.
Long: Signal-timeframe (previous Rapid Hull − 2 × current Rapid Hull) < its previous value AND its previous value >= its value two signal-timeframe bars ago.
Short: Signal-timeframe (2 × current Rapid Hull − previous Rapid Hull) < its previous value AND its previous value >= its value two signal-timeframe bars ago.
Long: Signal-timeframe adaptive Jurik line crosses above its previous value.
Short: Signal-timeframe adaptive Jurik line crosses below its previous value.
Long: Chart low > high two bars ago AND previous close > high two bars ago.
Short: Chart high < low two bars ago AND previous close < low two bars ago.
Long: A chart-timeframe pivot low is confirmed using equal numbers of bars before and after the pivot.
Short: A chart-timeframe pivot high is confirmed using equal numbers of bars before and after the pivot.