Calculation: Momentum = (RSI of close + MFI of (high + low + close) / 3) / 2; RSI and MFI use the same lookback.
Calculation: Regime = initially neutral; on each completed bar, set to bullish if momentum > bullish threshold AND EMA of close > previous bar's EMA, else set to bearish if momentum < bearish threshold AND EMA of close < previous bar's EMA, else retain the previous regime. The bearish threshold is below the bullish threshold.
Long: Regime = bullish.
Short: Regime = bearish.
Long: Regime = bullish AND previous bar's regime != bullish AND (signal window = all day OR bar opening time is within the configured session in America/New_York time).
Short: Regime = bearish AND previous bar's regime != bearish AND (signal window = all day OR bar opening time is within the configured session in America/New_York time).