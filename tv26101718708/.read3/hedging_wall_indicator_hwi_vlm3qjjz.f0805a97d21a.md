Calculation: Volume or 1 = volume if nonzero else 1
Calculation: Volume wall levels = row mid prices of up to maximum volume walls rows with the highest volume, taken among local peak rows of Volume Profile(Volume or 1, high, low, profile lookback, profile rows) whose volume exceeds HVN multiple * mean row volume
Calculation: Pivot cluster levels = for each pivot price of Pivot High(high, pivot length, pivot length) or Pivot Low(low, pivot length, pivot length) that has at least minimum touches pivot prices within pivot tolerance multiple * ATR(high, low, close, ATR length) of it, the average of those pivot prices
Calculation: Wall levels = Volume wall levels, Pivot cluster levels, and each of call open-interest strike, put open-interest strike, gamma flip level, and max pain strike that is greater than 0
Calculation: Upper wall = lowest Wall levels value greater than close
Calculation: Lower wall = highest Wall levels value less than close
Long: close > Upper wall[1] AND close[1] <= Upper wall[1]
Long: low <= Lower wall[1] AND close > Lower wall[1]
Long: Upper wall - close <= near-wall multiple * ATR(high, low, close, ATR length) AND CMF(Volume or 1, flow lookback) > flow threshold
Long: NOT (Upper wall - close <= near-wall multiple * ATR(high, low, close, ATR length)) AND close - Lower wall <= near-wall multiple * ATR(high, low, close, ATR length) AND NOT (CMF(Volume or 1, flow lookback) < -flow threshold)
Short: close < Lower wall[1] AND close[1] >= Lower wall[1]
Short: high >= Upper wall[1] AND close < Upper wall[1]
Short: Upper wall - close <= near-wall multiple * ATR(high, low, close, ATR length) AND NOT (CMF(Volume or 1, flow lookback) > flow threshold)
Short: NOT (Upper wall - close <= near-wall multiple * ATR(high, low, close, ATR length)) AND close - Lower wall <= near-wall multiple * ATR(high, low, close, ATR length) AND CMF(Volume or 1, flow lookback) < -flow threshold