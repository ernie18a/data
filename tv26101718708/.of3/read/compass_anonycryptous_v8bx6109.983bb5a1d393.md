Calculation: Stoch RSI K = SMA(Stochastic(RSI(stochastic source, stochastic RSI lookback), RSI(stochastic source, stochastic RSI lookback), RSI(stochastic source, stochastic RSI lookback), stochastic lookback), K smoothing)
Calculation: Stoch RSI D = SMA(Stoch RSI K, D smoothing)
Calculation: Dashboard RSI = RSI(RSI source, RSI lookback)
Calculation: PVSRA volume-spread = selected-source volume × (selected-source high - selected-source low), on chart bars with lookahead off
Calculation: PVSRA high-volume vector = selected-source volume >= SMA(selected-source volume, vector lookback) × green/red threshold OR (spread filter enabled AND PVSRA volume-spread >= Highest(PVSRA volume-spread, vector lookback))
Calculation: PVSRA elevated-volume vector = selected-source volume >= SMA(selected-source volume, vector lookback) × blue/violet threshold AND NOT PVSRA high-volume vector
Calculation: Open bullish FVG count = count of qualifying bullish FVGs not fully mitigated; a bullish FVG is fully mitigated when high > its bottom AND low < its top AND low <= its bottom
Calculation: Open bearish FVG count = count of qualifying bearish FVGs not fully mitigated; a bearish FVG is fully mitigated when low < its top AND high > its bottom AND high >= its top
Calculation: Weekly psychological high = highest chart-bar high during the selected weekly session, with session membership from the T1 bar still forming; update on chart bars and retain outside the session
Calculation: Weekly psychological low = lowest chart-bar low during the selected weekly session, with session membership from the T1 bar still forming; update on chart bars and retain outside the session
Long: EMA(cross source, fast EMA lookback) > EMA(cross source, slow EMA lookback)
Short: EMA(cross source, fast EMA lookback) < EMA(cross source, slow EMA lookback)
Long: EMA(cross source, fast EMA lookback) crosses above EMA(cross source, slow EMA lookback)
Short: EMA(cross source, fast EMA lookback) crosses below EMA(cross source, slow EMA lookback)
Long: close > EMA(close, long-term lookback)
Short: close <= EMA(close, long-term lookback)
Long: EMA(close, short-term lookback) > EMA(close, medium-term lookback) AND EMA(close, medium-term lookback) > EMA(close, long-term lookback)
Short: EMA(close, short-term lookback) < EMA(close, medium-term lookback) AND EMA(close, medium-term lookback) < EMA(close, long-term lookback)
Long: Stoch RSI K < lower band OR (Stoch RSI K > middle band AND Stoch RSI K <= upper band)
Short: Stoch RSI K > upper band OR (Stoch RSI K >= lower band AND Stoch RSI K <= middle band)
Long: Stoch RSI K crosses above Stoch RSI D AND (Stoch RSI K < middle band OR Stoch RSI D < middle band) OR Stoch RSI K crosses above Stoch RSI D AND (Stoch RSI K < lower band OR Stoch RSI D < lower band) OR Stoch RSI K crosses above lower band
Short: Stoch RSI K crosses below Stoch RSI D AND (Stoch RSI K > middle band OR Stoch RSI D > middle band) OR Stoch RSI K crosses below Stoch RSI D AND (Stoch RSI K > upper band OR Stoch RSI D > upper band) OR Stoch RSI K crosses below upper band
Long: Dashboard RSI >= RSI midline
Short: Dashboard RSI < RSI midline
Long: PivotLow(Dashboard RSI, divergence lookback, divergence lookback) > previous confirmed RSI pivot low AND low[divergence lookback] < low recorded at the previous confirmed RSI pivot low
Short: PivotHigh(Dashboard RSI, divergence lookback, divergence lookback) < previous confirmed RSI pivot high AND high[divergence lookback] > high recorded at the previous confirmed RSI pivot high
Long: PVSRA high-volume vector AND selected-source close >= selected-source open
Short: PVSRA high-volume vector AND selected-source close < selected-source open
Long: PVSRA elevated-volume vector AND selected-source close >= selected-source open
Short: PVSRA elevated-volume vector AND selected-source close < selected-source open
Long: (low - high[2]) > ATR(ATR lookback) × minimum gap-width multiplier AND low > high[2] AND close[1] > high[2] AND NOT (low > high[1] OR low[1] > high[2])
Short: (low[2] - high) > ATR(ATR lookback) × minimum gap-width multiplier AND high < low[2] AND close[1] < low[2] AND NOT (high < low[1] OR high[1] < low[2])
Long: Open bullish FVG count > open bearish FVG count
Short: Open bearish FVG count > open bullish FVG count
Long: close > open(T1 bar still forming, sampled on chart bars with lookahead off)
Short: close <= open(T1 bar still forming, sampled on chart bars with lookahead off)
Long: close > Pivot Point(high, low, close, T1, last completed bar)
Short: close < Pivot Point(high, low, close, T1, last completed bar)
Long: close > Weekly psychological high
Short: close < Weekly psychological low