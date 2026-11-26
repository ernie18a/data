Calculation: RelativeCloseMove(n) = round(100 × abs(close[n−1] − close[n]) / mean absolute close change over the following reference-lookback bars), using chart-timeframe bars
Long: For any of the five displayed close moves, close[n−1] > close[n] AND RelativeCloseMove(n) ≥ the minimum-move threshold
Short: For any of the five displayed close moves, close[n−1] < close[n] AND RelativeCloseMove(n) ≥ the minimum-move threshold
Long: On chart bars taking values from each of T1–T7, for each of seven separately parameterized MA lookbacks that are successively longer, MA(close, lookback, method, T, current still-forming bar) > MA(close, lookback, method, T, preceding completed bar)
Short: On chart bars taking values from each of T1–T7, for each of seven separately parameterized MA lookbacks that are successively longer, MA(close, lookback, method, T, current still-forming bar) ≤ MA(close, lookback, method, T, preceding completed bar)
Long: On chart bars taking values from each of T1–T7, MA(close, trend-bar lookback, method, T, current still-forming bar) > MA(close, trend-bar lookback, method, T, preceding completed bar)
Short: On chart bars taking values from each of T1–T7, MA(close, trend-bar lookback, method, T, current still-forming bar) < MA(close, trend-bar lookback, method, T, preceding completed bar)
Long: On chart-timeframe bars, LWMA(close, shorter lookback) > SMA(close, longer lookback)
Short: On chart-timeframe bars, LWMA(close, shorter lookback) < SMA(close, longer lookback)
Long: On chart-timeframe bars, MACD main rises while ((1 if current and preceding MACD main are both nonzero, otherwise 0) differs from the current MACD signal line), OR MACD main crosses above its signal line, OR MACD main crosses above zero
Short: On chart-timeframe bars, MACD main falls while ((1 if current and preceding MACD main are both nonzero, otherwise 0) differs from the current MACD signal line), OR MACD main crosses below its signal line, OR MACD main crosses below zero
Long: On chart-timeframe bars, Parabolic SAR(current bar) < close(current bar)
Short: On chart-timeframe bars, Parabolic SAR(current bar) > close(current bar)
Exit: long, Parabolic SAR(current bar) > close(current bar)
Exit: short, Parabolic SAR(current bar) < close(current bar)
Long: On chart-timeframe bars, MA(close, trend-bar lookback, method, current bar) > MA(close, trend-bar lookback, method, preceding completed bar)
Short: On chart-timeframe bars, MA(close, trend-bar lookback, method, current bar) < MA(close, trend-bar lookback, method, preceding completed bar)
Long: On chart-timeframe bars, Stochastic %K(current bar) > Stochastic %K(preceding completed bar)
Short: On chart-timeframe bars, Stochastic %K(current bar) < Stochastic %K(preceding completed bar)
Long: On chart-timeframe bars, Williams %R(current bar) > its midpoint threshold
Short: On chart-timeframe bars, Williams %R(current bar) < its midpoint threshold
Long: On chart-timeframe bars, close(current bar) > close(preceding completed bar)
Short: On chart-timeframe bars, close(current bar) < close(preceding completed bar)
Long: Every enabled current-chart check among fast/slow MA order, MACD rising or crossing above its signal line, Parabolic SAR below close, MA rise, Stochastic %K rise, Williams %R above its midpoint, and close rise is true, AND every enabled T1–T7 MA check is rising
Short: Every enabled current-chart check among fast/slow MA order, MACD falling or crossing below its signal line, Parabolic SAR above close, MA fall, Stochastic %K fall, Williams %R below its midpoint, and close fall is true, AND every enabled T1–T7 MA check is falling
Long: On chart bars taking values from each of T1–T7, close(current still-forming T bar) < lower Bollinger Band(current T bar) AND close(current T bar) > close(preceding completed T bar)
Short: On chart bars taking values from each of T1–T7, close(current still-forming T bar) > upper Bollinger Band(current T bar) AND close(current T bar) < close(preceding completed T bar)
Long: On chart bars taking values from each of T1–T7, RSI(current T bar) ≤ its buy threshold AND RSI(current T bar) > RSI(preceding completed T bar)
Short: On chart bars taking values from each of T1–T7, RSI(current T bar) ≥ its sell threshold AND RSI(current T bar) < RSI(preceding completed T bar)
Long: On chart bars taking values from each of T1–T7, CCI(current T bar) ≤ its buy threshold AND CCI(current T bar) > CCI(preceding completed T bar)
Short: On chart bars taking values from each of T1–T7, CCI(current T bar) ≥ its sell threshold AND CCI(current T bar) < CCI(preceding completed T bar)
Long: On chart bars taking values from each of T1–T7, MFI(current T bar) ≤ its buy threshold AND MFI(current T bar) > MFI(preceding completed T bar)
Short: On chart bars taking values from each of T1–T7, MFI(current T bar) ≥ its sell threshold AND MFI(current T bar) < MFI(preceding completed T bar)
Long: On chart bars taking values from each of T1–T7, Williams %R(current T bar) ≤ its buy threshold AND Williams %R(current T bar) > Williams %R(preceding completed T bar)
Short: On chart bars taking values from each of T1–T7, Williams %R(current T bar) ≥ its sell threshold AND Williams %R(current T bar) < Williams %R(preceding completed T bar)
Long: On chart bars taking values from each of T1–T7, Stochastic %K(current T bar) ≤ its buy threshold AND %K(current T bar) > %K(preceding completed T bar) AND %K(current T bar) ≥ %D(current T bar)
Short: On chart bars taking values from each of T1–T7, Stochastic %K(current T bar) ≥ its sell threshold AND %K(current T bar) < %K(preceding completed T bar) AND %K(current T bar) ≤ %D(current T bar)
Long: On chart bars taking values from each of T1–T7, MACD main(current T bar) < 0 AND MACD main(current T bar) > MACD signal(current T bar) AND MACD main(preceding completed T bar) < MACD signal(preceding completed T bar)
Short: On chart bars taking values from each of T1–T7, MACD main(current T bar) > 0 AND MACD main(current T bar) < MACD signal(current T bar) AND MACD main(preceding completed T bar) > MACD signal(preceding completed T bar)