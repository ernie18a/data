Calculation: volume ratio = volume / SMA(volume, volume lookback)
Calculation: bullish EMA trend = EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback)
Calculation: bearish EMA trend = EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback)
Calculation: bullish pullback-breakout setup = bullish EMA trend AND low <= EMA(close, shorter EMA lookback) + ATR(ATR lookback) × A-plus pullback ATR multiple AND close > EMA(close, shorter EMA lookback) AND prior close <= prior EMA(close, shorter EMA lookback) AND close > open AND close > prior high AND volume ratio >= A-plus volume threshold
Calculation: bearish pullback-breakout setup = bearish EMA trend AND high >= EMA(close, shorter EMA lookback) − ATR(ATR lookback) × A-plus pullback ATR multiple AND close < EMA(close, shorter EMA lookback) AND prior close >= prior EMA(close, shorter EMA lookback) AND close < open AND close < prior low AND volume ratio >= A-plus volume threshold
Calculation: EMA-smoothed directional index = EMA(DX, ADX lookback), where DX = 100 × abs(positive DI − negative DI) / (positive DI + negative DI), positive DI = 100 × EMA(positive directional movement, ADX lookback) / ATR(ADX lookback), negative DI = 100 × EMA(negative directional movement, ADX lookback) / ATR(ADX lookback), positive directional movement = high − prior high when this exceeds prior low − low and is positive, otherwise zero, and negative directional movement = prior low − low when this exceeds high − prior high and is positive, otherwise zero
Calculation: range mode = EMA-smoothed directional index < ADX threshold AND ATR(ATR lookback) < SMA(ATR(ATR lookback), range lookback) × ATR compression threshold AND highest(high, range lookback) − lowest(low, range lookback) < ATR(ATR lookback) × range lookback × range tightness multiplier
Calculation: opening-range high(session, duration) = highest high of chart bars from session open through the duration, fixed when the duration ends; use the shorter duration T2 or the longer duration T3
Calculation: opening-range low(session, duration) = lowest low of chart bars from session open through the duration, fixed when the duration ends; use the shorter duration T2 or the longer duration T3
Long: bullish EMA trend
Short: bearish EMA trend
Long: bullish pullback-breakout setup
Short: bearish pullback-breakout setup
Long: bullish pullback-breakout setup AND high > low AND abs(close − open) / (high − low) >= minimum candle-body fraction AND ATR(ATR lookback) > SMA(ATR(ATR lookback), ATR-expansion smoothing lookback) AND volume ratio >= GO volume threshold AND (session filter is disabled OR time is within the configured NY, London UTC, or Asia UTC session window) AND NOT (a current-bar PivotHigh(high, GO left lookback, no right-side bars) exists AND abs(close − that pivot high) < ATR(ATR lookback) × pivot-proximity ATR multiple)
Short: bearish pullback-breakout setup AND high > low AND abs(close − open) / (high − low) >= minimum candle-body fraction AND ATR(ATR lookback) > SMA(ATR(ATR lookback), ATR-expansion smoothing lookback) AND volume ratio >= GO volume threshold AND (session filter is disabled OR time is within the configured NY, London UTC, or Asia UTC session window) AND NOT (a current-bar PivotLow(low, GO left lookback, no right-side bars) exists AND abs(close − that pivot low) < ATR(ATR lookback) × pivot-proximity ATR multiple)
Long: close from the still-forming T1 bar > EMA(close, T1 bias lookback, T1, still-forming bar), sampled on chart bars from the still-forming T1 bar
Short: close from the still-forming T1 bar <= EMA(close, T1 bias lookback, T1, still-forming bar), sampled on chart bars from the still-forming T1 bar
Long: a most recent confirmed PivotHigh(high, S/R lookback, same S/R lookback) exists AND prior close > that pivot high AND low <= that pivot high × (1 + long zone-retest proximity) AND close > that pivot high AND close > open
Short: a most recent confirmed PivotLow(low, S/R lookback, same S/R lookback) exists AND prior close < that pivot low AND high >= that pivot low × (1 − short zone-retest proximity) AND close < that pivot low AND close < open
Long: bullish EMA trend AND prior low > prior EMA(close, shorter EMA lookback) AND low <= EMA(close, shorter EMA lookback) × (1 + long EMA-retest proximity) AND close > EMA(close, shorter EMA lookback) AND close > open
Short: bearish EMA trend AND prior high < prior EMA(close, shorter EMA lookback) AND high >= EMA(close, shorter EMA lookback) × (1 − short EMA-retest proximity) AND close < EMA(close, shorter EMA lookback) AND close < open
Long: prior close < prior open AND close > open AND close − open > ATR(ATR lookback) × order-block body-strength multiple
Short: prior close > prior open AND close < open AND open − close > ATR(ATR lookback) × order-block body-strength multiple
Long: low > high[two bars ago]
Short: high < low[two bars ago]
Long: on chart bars, close crosses above a set opening-range high for NY, London, or Asia with duration T2 or T3; for NY, this direction has not previously broken that range on the current session date
Short: on chart bars, close crosses below a set opening-range low for NY, London, or Asia with duration T2 or T3; for NY, this direction has not previously broken that range on the current session date
Long: an upward break of a set NY, London, or Asia opening-range high with duration T2 or T3 has occurred since that range's current session-date reset
Short: a downward break of a set NY, London, or Asia opening-range low with duration T2 or T3 has occurred since that range's current session-date reset
Long: a most recent confirmed PivotLow(low, liquidity left lookback, liquidity right lookback) exists AND low < that pivot low AND close > that pivot low AND close > open
Short: a most recent confirmed PivotHigh(high, liquidity left lookback, liquidity right lookback) exists AND high > that pivot high AND close < that pivot high AND close < open
Long: a most recent confirmed PivotHigh(high, structure lookback, same structure lookback) exists AND close > that pivot high AND prior close <= the prior bar's most recent confirmed pivot high AND (bullish EMA trend OR bearish EMA trend)
Short: a most recent confirmed PivotLow(low, structure lookback, same structure lookback) exists AND close < that pivot low AND prior close >= the prior bar's most recent confirmed pivot low AND (bullish EMA trend OR bearish EMA trend)
Long: range mode AND low <= lowest(low, range lookback) × (1 + long range-boundary proximity) AND close > open AND close > lowest(low, range lookback) AND volume > SMA(volume, volume lookback)
Short: range mode AND high >= highest(high, range lookback) × (1 − short range-boundary proximity) AND close < open AND close < highest(high, range lookback) AND volume > SMA(volume, volume lookback)
Long: range mode on the prior bar AND close > highest(high, range lookback) AND volume > SMA(volume, volume lookback) × range-break volume multiple
Short: range mode on the prior bar AND close < lowest(low, range lookback) AND volume > SMA(volume, volume lookback) × range-break volume multiple