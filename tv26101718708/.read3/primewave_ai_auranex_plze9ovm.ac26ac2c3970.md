Calculation: Adaptive lookback(base) = clamp(round(base × (1 + adaptation strength × (1 − volatility-rank span × volatility rank))), max(minimum lookback, round(base × (1 − adaptation strength))), round(base × (1 + adaptation strength)))
Calculation: Volatility rank = (ATR(ATR lookback) − lowest(ATR(ATR lookback), adaptation lookback)) / (highest(ATR(ATR lookback), adaptation lookback) − lowest(ATR(ATR lookback), adaptation lookback)), clamped to its normalized range; use the range midpoint when the denominator is zero
Calculation: Tenkan-Sen = Ichimoku conversion line(high, low, conversion lookback), using the base lookback in Classic mode or adaptive lookback(conversion base lookback) in Adaptive mode
Calculation: Kijun-Sen = Ichimoku base line(high, low, base-line lookback), using the base lookback in Classic mode or adaptive lookback(base-line base lookback) in Adaptive mode
Calculation: Senkou Span A = average(Tenkan-Sen, Kijun-Sen)
Calculation: Senkou Span B = Ichimoku leading span B(high, low, Span B lookback), using the base lookback in Classic mode or adaptive lookback(Span B base lookback) in Adaptive mode
Calculation: Kumo top = max(Senkou Span A[displacement minus one bars ago], Senkou Span B[displacement minus one bars ago])
Calculation: Kumo bottom = min(Senkou Span A[displacement minus one bars ago], Senkou Span B[displacement minus one bars ago])
Calculation: Kumo thickness = Kumo top − Kumo bottom
Calculation: Thin-cloud condition = Kumo thickness < SMA(Kumo thickness, cloud-thickness average lookback) × thin-cloud fraction
Calculation: Volume confirmation = volume <= 0 OR volume > SMA(volume, volume-average lookback) × volume-confirmation multiplier
Calculation: Momentum = EMA(clamp((normalized Tenkan-Sen minus Kijun-Sen spread × spread weight) + (change in that normalized spread over the spread-acceleration lookback × acceleration weight) + (((Senkou Span A − Senkou Span A[momentum cloud-slope lookback ago]) − (Senkou Span B − Senkou Span B[momentum cloud-slope lookback ago])) / ATR(ATR lookback) × cloud-slope weight), −momentum cap, momentum cap), momentum-smoothing lookback); normalize the spread and cloud slope by ATR(ATR lookback), using zero when ATR is zero
Calculation: Confluence score(side) = min(score ceiling, the sum of side-specific weights for cloud position (full when beyond the cloud on that side, partial when inside, zero otherwise), Tenkan-Sen/Kijun-Sen alignment, Chikou alignment, cloud direction, cloud thickness (separate weights for thick and thin), volume confirmation, momentum alignment (separate strong and weak weights), and momentum acceleration); cloud direction is bullish when (Senkou Span A − Senkou Span A[future-cloud lookback ago]) > (Senkou Span B − Senkou Span B[future-cloud lookback ago]), bearish otherwise; strong momentum is beyond the side-specific momentum threshold, weak momentum is between that threshold and zero; bullish acceleration is Momentum > Momentum[one bar ago] AND Momentum > 0, bearish acceleration is Momentum < Momentum[one bar ago] AND Momentum < 0; use the same weights for either side
Calculation: Exit levels(side, entry price) = stop at the corresponding Kumo edge or Kijun-Sen plus/minus ATR(ATR lookback) × stop buffer, or at entry price minus/plus ATR(ATR lookback) × ATR-stop multiple; target three is entry price plus/minus max(abs(entry price − stop), ATR(ATR lookback) × minimum-risk multiple) × third-target reward multiple
Long: crosses above(Ichimoku conversion line(high, low, shorter conversion lookback), Ichimoku base line(high, low, longer base-line lookback)) AND (thickness filter disabled OR NOT thin-cloud condition) AND (volume filter disabled OR Volume confirmation) AND (Chikou filter disabled OR selected price source > selected price source[displacement ago]) AND Confluence score(long) >= minimum score AND chart bar confirmed AND bar count >= max(Span B base lookback + displacement, warm-up floor)
Short: crosses below(Ichimoku conversion line(high, low, shorter conversion lookback), Ichimoku base line(high, low, longer base-line lookback)) AND (thickness filter disabled OR NOT thin-cloud condition) AND (volume filter disabled OR Volume confirmation) AND (Chikou filter disabled OR selected price source < selected price source[displacement ago]) AND Confluence score(short) >= minimum score AND chart bar confirmed AND bar count >= max(Span B base lookback + displacement, warm-up floor)
Long: close > Kumo top AND close[one bar ago] <= Kumo top[one bar ago] AND (volume <= 0 OR volume > SMA(volume, volume-average lookback) × breakout-volume multiplier) AND chart bar confirmed AND bar count >= max(Span B base lookback + displacement, warm-up floor)
Short: close < Kumo bottom AND close[one bar ago] >= Kumo bottom[one bar ago] AND (volume <= 0 OR volume > SMA(volume, volume-average lookback) × breakout-volume multiplier) AND chart bar confirmed AND bar count >= max(Span B base lookback + displacement, warm-up floor)
Long: low <= Kumo top AND close > Kumo top AND bars since the latest bullish Kumo breakout > retest-delay floor AND <= retest-window maximum AND chart bar confirmed AND bar count >= max(Span B base lookback + displacement, warm-up floor)
Short: high >= Kumo bottom AND close < Kumo bottom AND bars since the latest bearish Kumo breakout > retest-delay floor AND <= retest-window maximum AND chart bar confirmed AND bar count >= max(Span B base lookback + displacement, warm-up floor)
Long: close > Kumo top AND Tenkan-Sen > Kijun-Sen
Short: close < Kumo bottom AND Tenkan-Sen < Kijun-Sen
Long: close > Kumo top
Short: close < Kumo bottom
Long: Senkou Span A > Senkou Span B
Short: Senkou Span A <= Senkou Span B
Long: Momentum > 0
Short: Momentum < 0
Long: on each of T1, T2, and T3, using the last completed bar calculated on that timeframe with Classic Ichimoku lookbacks, close > max(Senkou Span A, Senkou Span B) AND Tenkan-Sen > Kijun-Sen
Short: on each of T1, T2, and T3, using the last completed bar calculated on that timeframe with Classic Ichimoku lookbacks, close < min(Senkou Span A, Senkou Span B) AND Tenkan-Sen < Kijun-Sen
Long: the T1, T2, and T3 states are all bullish
Short: the T1, T2, and T3 states are all bearish
Exit: long, low <= stop from Exit levels(long, entry price) OR high >= third target from Exit levels(long, entry price)
Exit: short, high >= stop from Exit levels(short, entry price) OR low <= third target from Exit levels(short, entry price)