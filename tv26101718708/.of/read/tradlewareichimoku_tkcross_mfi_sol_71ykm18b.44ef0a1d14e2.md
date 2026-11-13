Calculation: Midpoint(n) = (highest high over last n bars + lowest low over last n bars) / 2
Calculation: Tenkan = Midpoint(short lookback); Kijun = Midpoint(medium lookback, longer than Tenkan's)
Calculation: Cloud = on the current bar, the Senkou values computed a number of bars ago equal to the Kijun lookback, where Senkou A = (Tenkan + Kijun) / 2 and Senkou B = Midpoint(longest lookback, longer than Kijun's). Cloud top = max(Senkou A, Senkou B). Cloud bottom = min(Senkou A, Senkou B).
Calculation: MFI = Money Flow Index on typical price (high+low+close)/3
Long: Tenkan crosses above Kijun on this bar AND close > cloud top AND MFI > a fixed threshold at the neutral midline (higher means stronger money flow)
Exit: long, close < Kijun OR (optional stop enabled AND low <= cloud bottom)