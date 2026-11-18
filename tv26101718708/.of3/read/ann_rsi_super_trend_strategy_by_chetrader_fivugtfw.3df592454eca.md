Calculation: Fractional change(x) = (x - x[1]) / x[1], using 0 when unavailable
Calculation: Band basis = SMA(close, band lookback)
Calculation: Band RMS = sqrt(SMA((close - EMA(close, max(2, band lookback)))^2, max(2, band lookback)))
Calculation: Upper band = Band basis + band deviation multiplier * Band RMS
Calculation: Lower band = Band basis - band deviation multiplier * Band RMS
Calculation: Model score = tanh(w_o · tanh(W_h · tanh([fractional change(volume), fractional change(Lower band), fractional change(Band basis), fractional change(Upper band), fractional change(RSI(close, feature RSI lookback)), fractional change(MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback))]) + b_h) + b_o), where W_h is an 8×6 matrix, b_h and w_o are 8-vectors, and all their entries and b_o are separate parameters
Calculation: Scaled RSI = stop RSI multiplier * RSI(Model score - ROC(close, 1), stop RSI lookback)
Calculation: Long stop = if (wicks enabled ? low[1] : close[1]) > nz(Long stop[1], HL2 - Scaled RSI) then max(HL2 - Scaled RSI, nz(Long stop[1], HL2 - Scaled RSI)) else HL2 - Scaled RSI
Calculation: Short stop = if (wicks enabled ? high[1] : close[1]) < nz(Short stop[1], HL2 + Scaled RSI) then min(HL2 + Scaled RSI, nz(Short stop[1], HL2 + Scaled RSI)) else HL2 + Scaled RSI
Calculation: Direction = if nz(Direction[1], 1) = -1 and (wicks enabled ? high : close) > nz(Short stop[1], HL2 + Scaled RSI) then 1 else if nz(Direction[1], 1) = 1 and (wicks enabled ? low : close) < nz(Long stop[1], HL2 - Scaled RSI) then -1 else nz(Direction[1], 1); initial value 1
Long: Direction = 1 AND Direction[1] = -1
Short: Direction = -1 AND Direction[1] = 1