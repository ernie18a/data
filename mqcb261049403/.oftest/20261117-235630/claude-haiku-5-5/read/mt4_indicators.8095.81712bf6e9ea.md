Calculation: MacdChange = (MACD(close, fast, slow, signal) at T1 bar 0 - MACD(close, fast, slow, signal) at T1 bar 1) * sensitivity, where T1 bar 0 is the still-forming T1 bar containing the current chart bar and [n] counts n T1 bars back
Calculation: BandWidth = BollingerUpper(close, length, deviation) - BollingerLower(close, length, deviation), on the same T1 bars as MacdChange
Calculation: DeadZone = tickSize * deadZonePips
Long: MacdChange > BandWidth AND BandWidth > DeadZone AND BandWidth > BandWidth[1] AND MacdChange > MacdChange[2]
Short: MacdChange < 0 AND Abs(MacdChange) > BandWidth AND BandWidth > DeadZone AND BandWidth > BandWidth[1] AND Abs(MacdChange) > Abs(MacdChange[2])
Exit: Long, MacdChange > DeadZone AND MacdChange < BandWidth AND MacdChange < MacdChange[2] AND MacdChange[2] > BandWidth[1] AND BandWidth > DeadZone
Exit: Short, MacdChange < 0 AND Abs(MacdChange) < BandWidth AND Abs(MacdChange) < Abs(MacdChange[2]) AND Abs(MacdChange[2]) > BandWidth[1] AND MacdChange > DeadZone AND BandWidth > DeadZone