Calculation: MACD line = EMA of the selected OHLC-derived price with a shorter lookback minus its EMA with a longer lookback; calculate on the configurable indicator timeframe, which may be higher or lower than the chart timeframe, using a configurable bar that may be the last completed bar, an earlier completed bar, or the bar still forming. Previous values refer to preceding indicator-timeframe bars.
Calculation: MACD signal line = simple moving average of the MACD line over a separate signal lookback.
Calculation: MACD difference = MACD line minus MACD signal line.
Long: histogram mode selected AND MACD difference > previous MACD difference AND previous MACD difference < MACD difference two bars ago.
Short: histogram mode selected AND MACD difference < previous MACD difference AND previous MACD difference > MACD difference two bars ago.
Exit: short, histogram mode selected AND MACD difference > previous MACD difference.
Exit: long, histogram mode selected AND MACD difference < previous MACD difference.
Long: cloud mode selected AND MACD line > MACD signal line AND previous MACD line < previous MACD signal line.
Short: cloud mode selected AND MACD line < MACD signal line AND previous MACD line > previous MACD signal line.
Exit: short, cloud mode selected AND MACD line > MACD signal line.
Exit: long, cloud mode selected AND MACD line < MACD signal line.
Long: zero mode selected AND MACD difference > 0 AND previous MACD difference <= 0.
Short: zero mode selected AND MACD difference < 0 AND previous MACD difference >= 0.
Exit: short, zero mode selected AND MACD difference > 0.
Exit: long, zero mode selected AND MACD difference < 0.
Exit: long, stop loss enabled AND low <= entry price minus stop-loss distance.
Exit: long, take profit enabled AND high >= entry price plus take-profit distance.
Exit: short, stop loss enabled AND high >= entry price plus stop-loss distance.
Exit: short, take profit enabled AND low <= entry price minus take-profit distance.