Calculation: ShortStop5 = high[1] at the entry bar + X5
Calculation: LongStop5 = low[1] at the entry bar - X5
Calculation: ShortStopB = high[1] at the entry bar + XB
Calculation: LongStopB = low[1] at the entry bar - XB
Calculation: ShortStopC = high[1] at the entry bar + XC
Calculation: LongStopC = low[1] at the entry bar - XC
Short: position side is not short AND time is before C AND low[1] > EMA(close, L)[1] AND low < low[1]
Short: position side is not short AND time is before C AND low[1] > EMA(close, L)[1] AND low < low[1] AND close < close[1]
Short: position side is not short AND low[1] > BollingerUpper(close, N, K)[1] AND low < low[1]
Short: position side is not short AND low[1] > BollingerUpper(close, N, K)[1] AND low < low[1] AND close < close[1]
Short: position side is not short AND low[1] > BollingerUpper(close, N, K)[1] AND low[1] > EMA(close, L)[1] AND low < low[1]
Short: position side is not short AND low[1] > BollingerUpper(close, N, K)[1] AND low[1] > EMA(close, L)[1] AND low < low[1] AND close < close[1]
Long: position side is not long AND time is before C AND high[1] < EMA(close, L)[1] AND high > high[1]
Long: position side is not long AND time is before C AND high[1] < EMA(close, L)[1] AND high > high[1] AND close > close[1]
Long: position side is not long AND high[1] < BollingerLower(close, N, K)[1] AND high > high[1]
Long: position side is not long AND high[1] < BollingerLower(close, N, K)[1] AND high > high[1] AND close > close[1]
Long: position side is not long AND high[1] < BollingerLower(close, N, K)[1] AND high[1] < EMA(close, L)[1] AND high > high[1]
Long: position side is not long AND high[1] < BollingerLower(close, N, K)[1] AND high[1] < EMA(close, L)[1] AND high > high[1] AND close > close[1]
Exit: short, high > ShortStop5 OR low < entry price - R5 * (ShortStop5 - entry price)
Exit: long, low < LongStop5 OR high > entry price + R5 * (entry price - LongStop5)
Exit: short, high > ShortStopB OR low < entry price - RB * (ShortStopB - entry price)
Exit: long, low < LongStopB OR high > entry price + RB * (entry price - LongStopB)
Exit: short, high > ShortStopC OR low < entry price - RC * (ShortStopC - entry price)
Exit: long, low < LongStopC OR high > entry price + RC * (entry price - LongStopC)
Option: buy put, position side is not short AND time is before C AND low[1] > EMA(close, L)[1] AND low < low[1]
Option: sell call, position side is not short AND time is before C AND low[1] > EMA(close, L)[1] AND low < low[1]
Option: buy call, position side is not long AND time is before C AND high[1] < EMA(close, L)[1] AND high > high[1]
Option: sell put, position side is not long AND time is before C AND high[1] < EMA(close, L)[1] AND high > high[1]
Option: buy put, position side is not short AND low[1] > BollingerUpper(close, N, K)[1] AND low < low[1]
Option: buy call, position side is not long AND high[1] < BollingerLower(close, N, K)[1] AND high > high[1]