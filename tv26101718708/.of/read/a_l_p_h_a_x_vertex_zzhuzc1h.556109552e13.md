Calculation: Bollinger bands = SMA of close plus and minus a configurable multiple of the standard deviation of close.
Calculation: Keltner bands = EMA of close plus and minus a configurable multiple of ATR using the EMA's lookback.
Calculation: Coil = Bollinger lower band > Keltner lower band AND Bollinger upper band < Keltner upper band.
Calculation: Release = coil is false on the current bar AND coil was true for at least a configurable number of consecutive bars immediately before the current bar.
Calculation: Higher-timeframe regime values = close and EMA of close from the last completed higher-timeframe bar, with the EMA also sampled a configurable number of higher-timeframe bars earlier.
Calculation: Long RSI point = RSI > bullish threshold AND (RSI hook is disabled OR RSI crossed above the bullish threshold on the current bar OR RSI > previous RSI AND previous RSI > RSI two bars ago).
Calculation: Short RSI point = RSI < bearish threshold AND (RSI hook is disabled OR RSI crossed below the bearish threshold on the current bar OR RSI < previous RSI AND previous RSI < RSI two bars ago).
Calculation: Long MACD point = MACD confirmation is disabled OR MACD histogram > 0 OR MACD histogram > previous histogram. MACD uses a shorter and a longer EMA of close and an EMA signal line.
Calculation: Short MACD point = MACD confirmation is disabled OR MACD histogram < 0 OR MACD histogram < previous histogram. MACD uses the same parameters as the long MACD point.
Calculation: Volume point = volume confirmation is disabled OR volume is unavailable OR its SMA is unavailable OR its SMA = 0 OR volume >= its SMA multiplied by a configurable factor.
Calculation: Directional confluence score = sum of the corresponding RSI point, corresponding MACD point, and volume point, each counted as one when true and zero otherwise.
Calculation: Session pass = session gate is disabled OR the bar's opening time in UTC is within any enabled session window, inclusive of the start and exclusive of the end.
Calculation: Cooldown pass = no prior signal exists OR the number of chart bars since the most recent emitted long or short signal >= the configured cooldown.
Calculation: Long candidate = release AND close >= Keltner basis AND session pass AND (higher-timeframe filter is disabled OR higher-timeframe close > higher-timeframe EMA AND higher-timeframe EMA > its earlier value) AND (ADX gate is disabled OR ADX >= its threshold) AND (DI gate is disabled OR +DI > -DI) AND long confluence score >= its threshold AND cooldown pass.
Calculation: Short candidate = release AND close <= Keltner basis AND session pass AND (higher-timeframe filter is disabled OR higher-timeframe close < higher-timeframe EMA AND higher-timeframe EMA < its earlier value) AND (ADX gate is disabled OR ADX >= its threshold) AND (DI gate is disabled OR -DI > +DI) AND short confluence score >= its threshold AND cooldown pass.
Long: long candidate is true AND short candidate is false.
Short: short candidate is true AND long candidate is false.