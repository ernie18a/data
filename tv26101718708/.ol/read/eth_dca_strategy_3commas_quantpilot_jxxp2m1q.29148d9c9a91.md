Long: position is flat AND 14-period RSI of close on the chart timeframe, using the completed bar, is below the entry threshold AND datetime is within the configured backtest window
Calculation: Safety-order trigger price = original base entry price × (1 − rung deviation); rung deviations increase from one order to the next
Long: position is long AND datetime is within the configured backtest window AND close <= trigger price of the next unfilled safety order
Exit: long, close >= average entry price × (1 + take-profit percentage)