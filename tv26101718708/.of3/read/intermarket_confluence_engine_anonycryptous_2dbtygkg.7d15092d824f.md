Calculation: Ratio = Asset A close / Asset B close
Calculation: Momentum RSI = RSI of Ratio changes over the RSI lookback, weighting gains and losses by ((Asset A volume + Asset B volume) / 2) / SMA((Asset A volume + Asset B volume) / 2, volume-smoothing lookback) when volume weighting is enabled, and using unweighted gains and losses otherwise
Calculation: DXY rising = DXY feed enabled AND DXY close > EMA(DXY close, macro EMA lookback)
Calculation: DXY falling = DXY feed enabled AND DXY close < EMA(DXY close, macro EMA lookback)
Calculation: VIX elevated = VIX feed enabled AND VIX close > SMA(VIX close, VIX baseline lookback) AND VIX close > VIX level threshold
Calculation: VIX spike = VIX feed enabled AND VIX close > EMA(VIX close, macro EMA lookback) * VIX spike multiplier
Calculation: TNX rising = TNX feed enabled AND 10-year Treasury yield > EMA(10-year Treasury yield, macro EMA lookback)
Calculation: TNX falling = TNX feed enabled AND 10-year Treasury yield < EMA(10-year Treasury yield, macro EMA lookback)
Calculation: OBV slope = linear regression slope of OBV(Ratio, Asset A volume + Asset B volume) over the OBV slope lookback
Calculation: Relative-strength score = positive unit when Z-score(ROC(Asset A close, RS ROC lookback) - ROC(Asset B close, same lookback), RS Z-score lookback) > upper RS Z-score threshold AND Ratio > EMA(Ratio, RS EMA lookback); negative unit when that Z-score < lower RS Z-score threshold AND Ratio < that EMA; zero otherwise
Calculation: Trend score = positive unit when (EMA(Ratio, fast lookback) > EMA(Ratio, medium lookback) > EMA(Ratio, long lookback) OR (Ratio > EMA(Ratio, medium lookback) AND Ratio > EMA(Ratio, long lookback))) AND linear regression slope(Ratio, trend-slope lookback) > 0 AND (MTF filter disabled OR T1 data unavailable OR Asset A close > EMA(Asset A close, medium lookback) on the T1 current-forming bar, computed on T1 bars and sampled on chart bars); negative unit when (EMA(Ratio, fast lookback) < EMA(Ratio, medium lookback) < EMA(Ratio, long lookback) OR (Ratio < EMA(Ratio, medium lookback) AND Ratio < EMA(Ratio, long lookback))) AND that slope < 0 AND (MTF filter disabled OR T1 data unavailable OR Asset A close < that EMA on the T1 current-forming bar, computed on T1 bars and sampled on chart bars); zero otherwise; fast lookback < medium lookback < long lookback
Calculation: Momentum score = positive unit when Momentum RSI > upper momentum RSI threshold AND MACD histogram(Ratio, fast MACD lookback, slow MACD lookback, MACD signal lookback) > 0; negative unit when Momentum RSI < lower momentum RSI threshold AND that histogram < 0; zero otherwise; fast MACD lookback < slow MACD lookback
Calculation: Volatility score = positive unit when (Bollinger Band width(Ratio, BB lookback, BB multiplier) > SMA(Bollinger Band width, BB-width baseline lookback) AND percentile rank(ATR(Ratio, ATR lookback), ATR-percentile lookback) > ATR expansion threshold AND Ratio > Bollinger midline) OR (Bollinger Bands are not fully inside the Keltner Channel now, were fully inside it on the previous chart bar, and Ratio > Keltner basis); negative unit under the same expansion conditions with Ratio below the Bollinger midline, or the same release condition with Ratio below the Keltner basis; zero otherwise
Calculation: Statistical-extremes score = positive unit when Z-score(Ratio, statistical Z-score lookback) < -Z-score extreme threshold AND percentile rank(Ratio, historical percentile lookback) < lower percentile threshold; negative unit when that Z-score > Z-score extreme threshold AND that percentile rank > upper percentile threshold; zero otherwise
Calculation: Macro-regime score = for Gold/Silver, positive unit when at least the macro confirmation-count parameter of (VIX elevated OR VIX spike), TNX falling, and DXY falling are true; negative unit when at least that count of NOT (VIX elevated OR VIX spike), TNX rising, and DXY rising are true; for Crypto, positive unit when at least that count of DXY falling, TNX falling, and NOT VIX elevated are true, and negative unit when at least that count of DXY rising, TNX rising, and VIX elevated are true; for Forex, Indices, or Custom, positive unit when at least that count of NOT VIX elevated, DXY rising, and TNX rising are true, and negative unit when at least that count of VIX elevated, NOT DXY rising, and TNX falling are true; for Commodities, positive unit when DXY falling AND NOT VIX elevated, and negative unit when DXY rising; zero otherwise
Calculation: Liquidity score = for Forex, positive unit when EMA(ROC(10-year Treasury yield, yield ROC lookback), yield ROC smoothing lookback) > upper liquidity threshold and negative unit when it is < lower liquidity threshold; for other classes, positive unit when it is < lower liquidity threshold and negative unit when it is > upper liquidity threshold; zero otherwise
Calculation: Correlation score = rolling Pearson correlation of Ratio with enabled macro feeds over the correlation lookback: for Gold/Silver, positive unit when correlation(Ratio, VIX) > upper correlation threshold OR correlation(Ratio, DXY) < lower correlation threshold; otherwise negative unit when correlation(Ratio, VIX) < lower correlation threshold OR correlation(Ratio, DXY) > upper correlation threshold; for Crypto, positive unit when correlation(Ratio, DXY) < crypto lower correlation threshold and negative unit when it > crypto upper correlation threshold; for Indices, positive unit when correlation(Ratio, VIX) < indices lower correlation threshold and negative unit when it > indices upper correlation threshold; zero otherwise
Calculation: Volume-participation score = positive unit when OBV slope > 0 AND Ratio > EMA(Ratio, fast EMA lookback) AND (Asset A volume / SMA((Asset A volume + Asset B volume) / 2, volume-smoothing lookback) - Asset B volume / that SMA) > 0; negative unit when OBV slope < 0 AND Ratio < that EMA AND that volume difference < 0; zero otherwise, with the volume difference zero if its SMA denominator is zero
Calculation: Confluence score = confluence scale parameter * weighted sum of the nine engine scores / sum of their separate selected-class weights, or zero when the sum of weights is zero
Calculation: Bullish-marked divergence = at a confirmed pivot low, Ratio at the pivot > Ratio at the preceding pivot low AND Momentum RSI at the pivot < Momentum RSI at the preceding pivot low; use the pivot lookback on both sides
Calculation: Bearish-marked divergence = at a confirmed pivot high, Ratio at the pivot < Ratio at the preceding pivot high AND Momentum RSI at the pivot > Momentum RSI at the preceding pivot high; use the pivot lookback on both sides
Long: Relative-strength score > 0
Short: Relative-strength score < 0
Long: Trend score > 0
Short: Trend score < 0
Long: Momentum score > 0
Short: Momentum score < 0
Long: Volatility score > 0
Short: Volatility score < 0
Long: Statistical-extremes score > 0
Short: Statistical-extremes score < 0
Long: Macro-regime score > 0
Short: Macro-regime score < 0
Long: Liquidity score > 0
Short: Liquidity score < 0
Long: Correlation score > 0
Short: Correlation score < 0
Long: Volume-participation score > 0
Short: Volume-participation score < 0
Long: Confluence score > 0
Short: Confluence score < 0
Long: Confluence score >= strong signal threshold
Short: Confluence score <= -strong signal threshold
Long: Confluence score >= moderate signal threshold AND Confluence score < strong signal threshold
Short: Confluence score <= -moderate signal threshold AND Confluence score > -strong signal threshold
Long: Bullish-marked divergence AND Confluence score > 0
Short: Bearish-marked divergence AND Confluence score < 0
Long: linear regression slope(Ratio, trend-slope lookback) > 0
Short: linear regression slope(Ratio, trend-slope lookback) < 0
Long: Momentum RSI > upper RSI-color threshold
Short: Momentum RSI < lower RSI-color threshold
Long: Ratio > EMA(Ratio, medium EMA lookback)
Short: Ratio < EMA(Ratio, medium EMA lookback)
Long: OBV slope > 0
Short: OBV slope < 0