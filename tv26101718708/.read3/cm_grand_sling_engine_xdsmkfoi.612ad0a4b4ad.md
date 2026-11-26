Calculation: Side(L) = (Side(L)[1] == -1 AND close > Trail(L)[1]) ? 1 : (Side(L)[1] == 1 AND close < Trail(L)[1]) ? -1 : Side(L)[1]
Calculation: Trail(L) = Side(L) != Side(L)[1] ? LinReg(hl2, L, 0) - Side(L) * ATR(ATR length) * band multiplier : Side(L) == 1 ? max(Trail(L)[1], LinReg(hl2, L, 0) - ATR(ATR length) * band multiplier) : min(Trail(L)[1], LinReg(hl2, L, 0) + ATR(ATR length) * band multiplier)
Calculation: Norm(x) = x / SMA(|x|, vertex length), or 0 when that SMA is 0
Calculation: Vertex Score = clamp(Norm(ATR(vertex length) - ATR(vertex length)[vertex length]) + Norm(close - close[1]) + Norm(OBV - EMA(OBV, vertex length)) + Norm(ROC(close, vertex length)) + Norm(EMA(close, shorter EMA lookback) - EMA(close, longer EMA lookback)), -score cap, score cap)
Long: Trail(shorter rail lookback) >= Trail(longer rail lookback)
Short: Trail(shorter rail lookback) < Trail(longer rail lookback)
Long: Trail(shorter rail lookback) >= Trail(longer rail lookback) AND close[1] < Trail(shorter rail lookback)[1] AND close > Trail(shorter rail lookback)
Short: Trail(shorter rail lookback) < Trail(longer rail lookback) AND close[1] > Trail(shorter rail lookback)[1] AND close < Trail(shorter rail lookback)
Long: Trail(shorter rail lookback) >= Trail(longer rail lookback) AND close < Trail(shorter rail lookback)
Short: Trail(shorter rail lookback) < Trail(longer rail lookback) AND close > Trail(shorter rail lookback)
Long: Vertex Score >= bull level
Short: Vertex Score <= -bull level