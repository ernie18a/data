Calculation: Prior range high and low = highest high and lowest low over a configurable lookback, including the current bar; an offset refers to the value calculated that many bars earlier.
Calculation: Confirmed pivot high or low = a high or low that is respectively the maximum or minimum over equal configurable numbers of bars before and after it; confirm it only after the later bars have completed. Keep the latest confirmed pivot and its bar index separately for each pivot lookback and side.
Calculation: Displacement = absolute close-to-open body size > a configurable multiple of its simple moving average, including the current bar.
Calculation: Volume confirmation = volume > a configurable multiple of its simple moving average, including the current bar; alternatively, this filter can be disabled.
Calculation: Trend confirmation = close > EMA of close for long decisions or close < that EMA for short decisions, calculated on a higher timeframe using its last completed bar in historical data and its forming bar in real time; alternatively, this filter can be disabled.
Calculation: Session confirmation = the bar's exchange-time hour is within either of two configurable sessions; alternatively, this filter can be disabled.
Calculation: Long manipulation = low < prior range low at a configurable offset AND close > current prior range low AND close > open AND absolute close-to-open body size > a configurable multiple of ATR AND volume confirmation AND session confirmation.
Calculation: Short manipulation = high > prior range high at a configurable offset AND close < current prior range high AND close < open AND absolute close-to-open body size > a configurable multiple of ATR AND volume confirmation AND session confirmation.
Long: Long manipulation AND long trend confirmation AND close > previous high AND absolute close-to-open body size > a configurable multiple of ATR.
Short: Short manipulation AND short trend confirmation AND close < previous low AND absolute close-to-open body size > a configurable multiple of ATR.
Long: Low > high two bars ago AND low - high two bars ago > a configurable multiple of ATR AND close > open AND close > previous high AND displacement AND volume confirmation AND long trend confirmation AND session confirmation.
Short: High < low two bars ago AND low two bars ago - high > a configurable multiple of ATR AND close < open AND close < previous low AND displacement AND volume confirmation AND short trend confirmation AND session confirmation.
Long: Previous close < previous open AND close > previous high AND close > open AND close - open > a configurable multiple of ATR AND long trend confirmation AND volume confirmation.
Short: Previous close > previous open AND close < previous low AND close < open AND open - close > a configurable multiple of ATR AND short trend confirmation AND volume confirmation.
Long: Low < latest confirmed sweep pivot low AND close > that pivot low.
Short: High > latest confirmed sweep pivot high AND close < that pivot high.
Long: Close > latest confirmed change-of-character pivot high AND previous close <= that same pivot high AND that pivot's bar index differs from the last marked long change-of-character pivot index, with an undefined last index making the comparison false.
Short: Close < latest confirmed change-of-character pivot low AND previous close >= that same pivot low AND that pivot's bar index differs from the last marked short change-of-character pivot index, with an undefined last index making the comparison false.
Long: Close > latest confirmed break-of-structure pivot high AND previous close <= that same pivot high AND close > open AND close > previous high AND displacement AND volume confirmation AND that pivot's bar index differs from the last marked long break-of-structure pivot index, with an undefined last index making the comparison false.
Short: Close < latest confirmed break-of-structure pivot low AND previous close >= that same pivot low AND close < open AND close < previous low AND displacement AND volume confirmation AND that pivot's bar index differs from the last marked short break-of-structure pivot index, with an undefined last index making the comparison false.
Long: A newly confirmed structure pivot low > the preceding confirmed structure pivot low.
Short: A newly confirmed structure pivot high > the preceding confirmed structure pivot high.
Short: A newly confirmed structure pivot high < the preceding confirmed structure pivot high.
Short: A newly confirmed structure pivot low < the preceding confirmed structure pivot low.