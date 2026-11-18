Calculation: VolRegPrice(regLen) = SMA(close, regLen) + (volume - SMA(volume, regLen)) * (SUM(i = 0..regLen-1 of (volume[i] - SMA(volume, regLen)) * (close[i] - SMA(close, regLen)))) / (SUM(i = 0..regLen-1 of (volume[i] - SMA(volume, regLen))^2))
Calculation: MACDLine(regLen, fastLen, slowLen) = EMA(VolRegPrice(regLen), fastLen) - EMA(VolRegPrice(regLen), slowLen), with fastLen < slowLen
Calculation: MACDSignal(regLen, fastLen, slowLen, sigLen) = EMA(MACDLine(regLen, fastLen, slowLen), sigLen)
Long: VolRegPrice(regLen) crosses above close
Long: VolRegPrice(regLen) crosses above WMA(VolRegPrice(regLen), wmaLen) AND MACDSignal(regLen, fastLen, slowLen, sigLen) < MACDLine(regLen, fastLen, slowLen) AND MACDLine(regLen, fastLen, slowLen) > MACDLine(regLen, fastLen, slowLen)[1] AND MACDLine(regLen, fastLen, slowLen)[1] > MACDLine(regLen, fastLen, slowLen)[2]
Short: VolRegPrice(regLen) crosses below close
Short: MACDLine(regLen, fastLen, slowLen) < MACDSignal(regLen, fastLen, slowLen, sigLen) AND MACDLine(regLen, fastLen, slowLen) < MACDLine(regLen, fastLen, slowLen)[1] AND low < low[1] AND low[1] < low[2]