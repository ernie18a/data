Long: Chart-timeframe close >= moving average of chart-timeframe lows
Short: Chart-timeframe close < moving average of chart-timeframe lows
Long: On the indicator timeframe, which may be higher or lower than the chart timeframe, the last completed bar's close >= its moving average of lows AND the preceding bar's close < its moving average of lows
Short: On the indicator timeframe, which may be higher or lower than the chart timeframe, the last completed bar's close < its moving average of lows AND the preceding bar's close >= its moving average of lows
Exit: long, the last completed indicator-timeframe bar's close < its moving average of lows OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, the last completed indicator-timeframe bar's close >= its moving average of lows OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance