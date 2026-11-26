Calculation: EffectiveVolatility(T) = slope_T × (ATR(T, ATR lookback_T, last completed T bar) / reference price_T × annualization factor_T × 100) + intercept_T; T1–T6 are source timeframes in READ's calculation order; reference price_T is the prior completed close for T1–T2 and the forming-bar open for T3–T6; each source has separate parameters.
Calculation: ZoneBounds(T, strength, side) = [round(P + side × distance − width/2), round(P + side × distance + width/2)], where P = round(open(T, forming bar)), σ = P × EffectiveVolatility(T) / (100 × sigma scale_T), distance = σ for strong or σ / weak-distance-divisor_T for weak, width = round(σ / strong-width-divisor_T) for strong or round(σ / weak-width-divisor_T) for weak, and side = −1 for demand or +1 for supply; levels use T values on chart bars.
Long: On chart bars, for any T in {T1,T2,T3,T4,T5,T6} and strength in {strong,weak}, low ≤ the upper edge of ZoneBounds(T,strength,demand) AND low[1] > that edge[1].
Short: On chart bars, for any T in {T1,T2,T3,T4,T5,T6} and strength in {strong,weak}, high ≥ the lower edge of ZoneBounds(T,strength,supply) AND high[1] < that edge[1].
Long: volume z-score(volume, lookback) ≥ spike threshold AND close > open.
Short: volume z-score(volume, lookback) ≥ spike threshold AND close ≤ open.
Long: low > high[2] AND low − high[2] > ATR(chart bars, gap ATR lookback) × gap sensitivity.
Short: high < low[2] AND low[2] − high > ATR(chart bars, gap ATR lookback) × gap sensitivity.
Long: close crosses above the latest confirmed pivot high not yet crossed, using equal left and right market-structure pivot lookbacks.
Short: close crosses below the latest confirmed pivot low not yet crossed, using equal left and right market-structure pivot lookbacks.
Long: a confirmed pivot low using liquidity left and right lookbacks differs from an earlier retained confirmed pivot low by at most the equality threshold percent of the earlier pivot price.
Short: a confirmed pivot high using liquidity left and right lookbacks differs from an earlier retained confirmed pivot high by at most the equality threshold percent of the earlier pivot price.