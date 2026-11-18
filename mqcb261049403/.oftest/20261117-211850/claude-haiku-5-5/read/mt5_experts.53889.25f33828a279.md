Calculation: Price = close of the bar still forming on the working timeframe
Calculation: RSI = Wilder relative strength index of close over RSI period bars on the working timeframe, at the operation-mode shift (0 = bar still forming)
Calculation: Middle band = simple average of close over band period bars on the working timeframe, ending at the operation-mode shift (0 = bar still forming)
Calculation: Upper band = Middle band + band deviation × population standard deviation of close over the same bars
Calculation: Lower band = Middle band − band deviation × population standard deviation of close over the same bars
Exit: long, Price > Upper band AND RSI > overbought level AND Price > entry price
Exit: short, Price < Lower band AND RSI < oversold level AND Price < entry price