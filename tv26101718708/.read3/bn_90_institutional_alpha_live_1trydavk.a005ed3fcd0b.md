Calculation: Current P&L = (close - entry price) × price multiplier parameter × quantity parameter
Long: close > EMA(close, long-term lookback) AND EMA(close, shorter trend lookback) > EMA(close, longer trend lookback) AND VPT(volume, close) > SMA(VPT(volume, close), signal lookback) AND low > low[1] AND low[1] < low[2] AND close crosses above EMA(close, basis lookback) AND chart bar time is within either configured session window AND (position is flat OR prior bar position was flat)
Exit: Long, Current P&L >= profit target parameter
Exit: Long, after Current P&L has reached profit target parameter × break-even fraction parameter since entry, Current P&L <= break-even exit threshold parameter
Exit: Long, Current P&L <= -stop-loss parameter
Exit: Long, close crosses below EMA(close, longer trend lookback)
Exit: Long, prior bar position was long AND current position is flat AND Current P&L[1] >= profit target parameter
Exit: Long, prior bar position was long AND current position is flat AND Current P&L[1] <= -stop-loss parameter
Exit: Long, prior bar position was long AND current position is flat AND after Current P&L had reached profit target parameter × break-even fraction parameter since entry AND Current P&L[1] <= break-even label threshold parameter