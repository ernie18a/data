Calculation: MACD line = EMA(close, shorter lookback) - EMA(close, longer lookback)
Calculation: MACD histogram = MACD line - EMA(MACD line, signal lookback)
Calculation: SMMA shortest = SMMA(hl2, shortest lookback)
Calculation: SMMA middle = SMMA(hl2, middle lookback)
Calculation: SMMA longest = SMMA(hl2, longest lookback)
Calculation: Anchored VWAP = VWAP(hlc3) on chart bars, reset at each T1 change
Calculation: In session = time-of-day(datetime) >= session start AND time-of-day(datetime) < session end
Calculation: Range Filter line = Range Filter(close, sampling period, range multiplier)
Calculation: Rising run = Range Filter line > Range Filter line[1] ? Rising run[1] + 1 : (Range Filter line < Range Filter line[1] ? 0 : Rising run[1])
Calculation: Falling run = Range Filter line < Range Filter line[1] ? Falling run[1] + 1 : (Range Filter line > Range Filter line[1] ? 0 : Falling run[1])
Calculation: Trail stop = Trail price - ATR(stop ATR length) * stop ATR multiplier, where Trail price is lowest(low, trail lookback), close, or open, selected by trail type
Calculation: UT Bot stop = UT Bot trailing stop(close, UT ATR length, UT key value)
Calculation: Opening range high = high of the first bar of each T1 period, on T2 bars, read from the last completed T2 bar
Calculation: Opening range low = low of the first bar of each T1 period, on T2 bars, read from the last completed T2 bar
Long: MACD histogram > 0 AND close > SMMA shortest AND open > SMMA shortest AND In session AND Anchored VWAP < close AND Rising run > 0 AND high > SMMA middle AND SMMA shortest > SMMA longest AND close[1] - open[1] < rejection limit
Long: close > Range Filter line AND close != close[1] AND Rising run > 0
Long: close > SMMA middle AND close > Opening range high AND Highest(close, breakout lookback)[1] < Opening range high AND In session
Long: close > UT Bot stop
Short: MACD histogram < 0 AND close < SMMA shortest AND open < SMMA shortest AND In session AND Anchored VWAP > close AND Falling run > 0 AND high < SMMA middle AND SMMA shortest < SMMA longest AND open[1] - close[1] < rejection limit
Short: close < Range Filter line AND close != close[1] AND Falling run > 0
Short: close < SMMA middle AND close < Opening range low AND Lowest(close, breakout lookback)[1] > Opening range low AND In session
Short: close <= UT Bot stop
Exit: long, close < SMMA shortest AND MACD histogram < -histogram threshold
Exit: long, high > entry price + take-profit distance AND open < entry price + take-profit distance
Exit: long, close[1] < SMMA middle[1] AND close[1] < entry price AND SMMA middle[1] <= Trail stop[1]
Exit: long, high > SMMA middle AND low < SMMA middle AND close < SMMA middle AND close[1] > SMMA middle[1]
Exit: short, close > SMMA shortest AND MACD histogram > histogram threshold
Exit: short, low < entry price - take-profit distance AND open > entry price - take-profit distance
Exit: short, close[1] > SMMA middle[1] AND close[1] > entry price AND SMMA middle[1] <= Trail stop[1]
Exit: short, high > SMMA middle AND low < SMMA middle AND close > SMMA middle AND close[1] < SMMA middle[1]
Option: buy call, MACD histogram > 0 AND close > SMMA shortest AND open > SMMA shortest AND In session AND Anchored VWAP < close AND Rising run > 0 AND high > SMMA middle AND SMMA shortest > SMMA longest AND close[1] - open[1] < rejection limit
Option: buy put, MACD histogram < 0 AND close < SMMA shortest AND open < SMMA shortest AND In session AND Anchored VWAP > close AND Falling run > 0 AND high < SMMA middle AND SMMA shortest < SMMA longest AND open[1] - close[1] < rejection limit
Option: sell call, close < SMMA shortest AND MACD histogram < -histogram threshold
Option: sell put, close > SMMA shortest AND MACD histogram > histogram threshold
Option: sell call, high > entry price + take-profit distance AND open < entry price + take-profit distance
Option: sell call, close[1] < SMMA middle[1] AND close[1] < entry price AND SMMA middle[1] <= Trail stop[1]
Option: sell put, low < entry price - take-profit distance AND open > entry price - take-profit distance
Option: sell put, close[1] > SMMA middle[1] AND close[1] > entry price AND SMMA middle[1] <= Trail stop[1]