Calculation: ATRband = Average True Range (smoothed true range) over a fixed lookback, computed on bars of a higher timeframe than the chart using the bar still forming, multiplied by a fixed multiplier
Long: calendar month of the bar is in a user-selected set of months AND bar year >= a start year AND no long position is open (so a new long is opened on the next bar after a stop or target exit within the same selected month)
Exit: long, calendar month of the bar is the month immediately following a selected month (December -> January wraps) AND a long opened in the preceding selected month is open
Exit: long, risk management enabled AND low <= entry price - ATRband
Exit: long, risk management enabled AND high >= entry price + ATRband