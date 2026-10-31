Calculation: Histogram = Hull moving average of close with a shorter period minus Hull moving average of close with a longer period. Calculate on a configurable timeframe that may be higher than, lower than, or equal to the chart timeframe; use a configurable signal bar, normally the last completed bar, or the still-forming bar if selected. Previous values refer to preceding bars of that timeframe.
Long: mode = zero-crossing AND histogram > 0 AND previous histogram <= 0
Long: mode = turning-point AND histogram > previous histogram AND previous histogram < histogram two bars ago
Short: mode = zero-crossing AND histogram < 0 AND previous histogram >= 0
Short: mode = turning-point AND histogram < previous histogram AND previous histogram > histogram two bars ago
Exit: long, mode = zero-crossing AND histogram < 0
Exit: long, mode = turning-point AND histogram < previous histogram
Exit: short, mode = zero-crossing AND histogram > 0
Exit: short, mode = turning-point AND histogram > previous histogram
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance