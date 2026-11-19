Calculation: RowStep(chart bar) = tick size * (automatic row-size mode ? max(minimum ticks per row parameter, round(ATR(chart bars, ATR lookback parameter) / (target row count parameter * tick size))) : manual ticks per row parameter)
Calculation: AskVolume(row, chart bar) = sum over T1 bars within the chart bar, including a T1 bar still forming, of T1 volume / (round((T1 high - T1 low) / tick size) + 1) for each row index from round((T1 low - chart bar low) / RowStep) through round((T1 high - chart bar low) / RowStep) when T1 close > T1 open, and half that amount when T1 close = T1 open
Calculation: BidVolume(row, chart bar) = sum over T1 bars within the chart bar, including a T1 bar still forming, of T1 volume / (round((T1 high - T1 low) / tick size) + 1) for each row index from round((T1 low - chart bar low) / RowStep) through round((T1 high - chart bar low) / RowStep) when T1 close < T1 open, and half that amount when T1 close = T1 open
Calculation: RowDelta(row, chart bar) = AskVolume(row, chart bar) - BidVolume(row, chart bar)
Calculation: ChartBarAskVolume = sum of AskVolume over all rows in the chart bar
Calculation: ChartBarBidVolume = sum of BidVolume over all rows in the chart bar
Long: Chart bar is within the configured lookback AND row is not POC AND RowDelta(row, chart bar) > 0
Short: Chart bar is within the configured lookback AND row is not POC AND RowDelta(row, chart bar) < 0
Long: Chart bar is within the configured lookback AND ChartBarAskVolume > ChartBarBidVolume
Short: Chart bar is within the configured lookback AND ChartBarAskVolume + ChartBarBidVolume > 0 AND ChartBarAskVolume <= ChartBarBidVolume