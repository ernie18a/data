Calculation: Trend reference(T) = EMA(close, EMA lookback, T bars) if the trend-method parameter selects EMA; otherwise SMA(close, SMA lookback, T bars), using the still-forming T bar.
Calculation: Smoothed Stoch RSI(U) = SMA(Stoch RSI(close, RSI lookback, Stoch lookback, neutral fallback parameter when the RSI range is zero), signal lookback), computed on U bars using the still-forming U bar.
Calculation: Pivot-window length = pivot lookback × pivot-window multiplier + pivot-window offset.
Calculation: Price pivot low(U) = low(U, still-forming bar) equals lowest(low(U, still-forming bar), pivot-window length), evaluated on chart bars using U values.
Calculation: Price pivot high(U) = high(U, still-forming bar) equals highest(high(U, still-forming bar), pivot-window length), evaluated on chart bars using U values.
Long: For each of T1–T5, on chart bars, close of the still-forming T bar > Trend reference(T).
Short: For each of T1–T5, on chart bars, close of the still-forming T bar <= Trend reference(T).
Long: On chart bars, the count of T1–T5 whose still-forming close > Trend reference(T) exceeds the count whose still-forming close <= Trend reference(T).
Short: On chart bars, the count of T1–T5 whose still-forming close <= Trend reference(T) exceeds the count whose still-forming close > Trend reference(T).
Long: For each of U1–U5, on chart bars, Smoothed Stoch RSI(U) <= oversold threshold.
Short: For each of U1–U5, on chart bars, Smoothed Stoch RSI(U) >= overbought threshold.
Long: When divergence detection is enabled, for each of U1–U5 on chart bars, Price pivot low(U) AND low(U, still-forming bar) < valuewhen(Price pivot low(U), low(U, still-forming bar), previous occurrence) AND Smoothed Stoch RSI(U) > valuewhen(Price pivot low(U), Smoothed Stoch RSI(U), previous occurrence) AND Smoothed Stoch RSI(U) <= oversold threshold + divergence buffer.
Short: When divergence detection is enabled, for each of U1–U5 on chart bars, Price pivot high(U) AND high(U, still-forming bar) > valuewhen(Price pivot high(U), high(U, still-forming bar), previous occurrence) AND Smoothed Stoch RSI(U) < valuewhen(Price pivot high(U), Smoothed Stoch RSI(U), previous occurrence) AND Smoothed Stoch RSI(U) >= overbought threshold - divergence buffer.