Calculation: Safe division(a,b) = 0 if b=0, otherwise a/b
Calculation: Soft saturation(x) = (exp(clamp(saturation multiplier*x, -exponent limit, exponent limit))-1)/(exp(clamp(saturation multiplier*x, -exponent limit, exponent limit))+1)
Calculation: Signed efficiency = EMA((close-close[n])/max(sum(abs(close[i]-close[i+1]), i=0..n-1), path floor), DER smoothing lookback)
Calculation: Normalized efficiency = signed efficiency * (base confidence + persistence confidence * min(abs(persistence)/persistence scale, 1)); each bar persistence is zero if signed efficiency is zero, otherwise prior persistence plus its sign, capped at positive and negative persistence limits
Calculation: Volatility ratio = ATR(AMVS base lookback)/max(SMA(ATR(AMVS base lookback), volatility baseline lookback), volatility floor)
Calculation: Adaptive momentum = soft saturation((((selected RSI - RSI midpoint)/RSI half-range)/clamp(volatility ratio, volatility floor, volatility ceiling))*momentum scale), where selected RSI uses the short, middle, or long RSI lookback as volatility ratio exceeds the high or middle volatility threshold; short < middle < long
Calculation: Volatility regime index = soft saturation((ATR component weight * (2*safe division(ATR(VRI lookback)/close - its lowest value over the VRI lookback, max(its highest-minus-lowest range, normalization floor))-1) + ATR momentum weight * soft saturation(safe division(ATR(short ATR lookback)-ATR(long ATR lookback), max(ATR(long ATR lookback), ATR floor))*ATR momentum scale) + band-width weight * (2*safe division(Bollinger Band width - its lowest value over the VRI lookback, max(its highest-minus-lowest range, normalization floor))-1))*VRI scale); Bollinger Band width = (SMA(close, band lookback)+standard-deviation multiplier*StDev(close, band lookback) - (SMA(close, band lookback)-standard-deviation multiplier*StDev(close, band lookback)))/max(SMA(close, band lookback), band floor)
Calculation: Volume absorption = volume/max(SMA(volume, absorption-volume lookback), volume floor) > volume-spike threshold AND abs(close-open)/max(high-low, bar-range floor) < body-size threshold
Calculation: Order-flow proxy = EMA(flow-component weight*soft saturation(EMA(safe division(volume*close position-volume*(1-close position), max(volume, volume floor)), flow smoothing lookback)*flow scale) + price-component weight*soft saturation(((close-close[price-velocity lag])/max(close[price-velocity lag], price floor))*safe division(volume,SMA(volume, flow-volume lookback))*price-volume scale) + absorption-component weight*(if volume absorption then negative absorption amount when close>open, otherwise positive absorption amount; else zero), flow smoothing lookback); close position = safe division(close-low, max(high-low, bar-range floor))
Calculation: Market regime = coil if abs(signed efficiency)<coil-efficiency threshold AND volatility regime index<coil-volatility threshold AND abs(order-flow proxy)>flow-building threshold; otherwise bullish trend if signed efficiency>trend-efficiency threshold AND adaptive momentum>0 AND volatility regime index>trend-volatility floor; otherwise bearish trend if signed efficiency<negative trend-efficiency threshold AND adaptive momentum<0 AND volatility regime index>trend-volatility floor; otherwise range
Calculation: Current flux weights = regime-specific coil, trend, or range weights when adaptive weighting is enabled; otherwise the four manual component weights divided by their sum, treating a sum below the weight floor as one
Calculation: Current flux = (efficiency weight*normalized efficiency + momentum weight*adaptive momentum + volatility weight*volatility regime index + flow weight*order-flow proxy)*flux output scale
Calculation: T1 flux = chart bars taking values from the T1 calculation, which runs on T1 bars with lookahead off (the T1 bar still forming in real time and the completed T1 bar historically); it is the weighted sum times flux output scale of EMA(signed efficiency on T1, DER lookback, DER smoothing lookback), soft saturation(((RSI(close,T1 RSI lookback)-RSI midpoint)/RSI half-range)*T1 momentum scale), soft saturation(safe division(ATR(T1 short ATR lookback)-ATR(T1 long ATR lookback), max(ATR(T1 long ATR lookback), ATR floor))*T1 volatility scale), and soft saturation(EMA(close position*2-1, flow smoothing lookback)*T1 flow scale); use current flux weights when T1 adaptive weighting is enabled, otherwise equal component weights
Calculation: Flux = current flux*current-timeframe blend weight + T1 flux*(1-current-timeframe blend weight) when higher-timeframe blending is enabled; otherwise current flux
Calculation: Volume-adjusted flux = Flux/flux display scale, multiplied by 1+(min(volume/max(SMA(volume, flux-volume lookback), volume floor), volume cap)-1)*volume influence when volume weighting is enabled, or by 1 otherwise
Calculation: Flux moving average = EMA(volume-adjusted flux, flux moving-average lookback)
Calculation: Panel flux(TF) = chart bars taking values from the TF calculation, which runs on TF bars with lookahead off (the TF bar still forming in real time and the completed TF bar historically); it is the equal-weight average times flux output scale of signed efficiency on TF without EMA smoothing, soft saturation(((RSI(close, panel RSI lookback)-RSI midpoint)/RSI half-range)*panel momentum scale), soft saturation(safe division(ATR(panel short ATR lookback)-ATR(panel long ATR lookback), max(ATR(panel long ATR lookback), ATR floor))*panel volatility scale), and soft saturation(EMA(close position*2-1, flow smoothing lookback)*panel flow scale)
Long: Market regime is bullish trend
Short: Market regime is bearish trend
Long: Flux > 0
Short: Flux <= 0
Long: change(Flux, velocity lookback) > 0
Short: change(Flux, velocity lookback) <= 0
Long: change(change(Flux, velocity lookback), acceleration lookback) > 0
Short: change(change(Flux, velocity lookback), acceleration lookback) <= 0
Long: normalized efficiency > 0
Short: normalized efficiency <= 0
Long: adaptive momentum > 0
Short: adaptive momentum <= 0
Long: volatility regime index > 0
Short: volatility regime index <= 0
Long: order-flow proxy > 0
Short: order-flow proxy <= 0
Long: not volume absorption AND volume-adjusted flux > Flux moving average
Short: not volume absorption AND volume-adjusted flux <= Flux moving average
Long: volume-adjusted flux crosses above Flux moving average
Short: volume-adjusted flux crosses below Flux moving average
Long: EMA(volume-adjusted flux, fast cloud lookback) > EMA(volume-adjusted flux, middle cloud lookback) AND EMA(volume-adjusted flux, middle cloud lookback) > EMA(volume-adjusted flux, slow cloud lookback); fast < middle < slow
Short: EMA(volume-adjusted flux, fast cloud lookback) < EMA(volume-adjusted flux, middle cloud lookback) AND EMA(volume-adjusted flux, middle cloud lookback) < EMA(volume-adjusted flux, slow cloud lookback); fast < middle < slow
Long: a confirmed Flux pivot low is higher than the preceding confirmed Flux pivot low AND the price low at the current pivot is lower than the price low at the preceding pivot AND pivot spacing is within the divergence minimum and maximum AND the same regular-bullish signal spacing is met
Short: a confirmed Flux pivot high is lower than the preceding confirmed Flux pivot high AND the price high at the current pivot is higher than the price high at the preceding pivot AND pivot spacing is within the divergence minimum and maximum AND the same regular-bearish signal spacing is met
Long: a confirmed Flux pivot low is lower than the preceding confirmed Flux pivot low AND the price low at the current pivot is higher than the price low at the preceding pivot AND pivot spacing is within the divergence minimum and maximum AND the same hidden-bullish signal spacing is met
Short: a confirmed Flux pivot high is higher than the preceding confirmed Flux pivot high AND the price high at the current pivot is lower than the price high at the preceding pivot AND pivot spacing is within the divergence minimum and maximum AND the same hidden-bearish signal spacing is met
Long: two confirmed Flux pivot lows, using the separate trendline pivot lookbacks, form a line with slope no less than negative slope tolerance AND at least the minimum trendline touch count of retained confirmed Flux pivot lows lie within touch tolerance of the line
Short: two confirmed Flux pivot highs, using the separate trendline pivot lookbacks, form a line with slope no greater than positive slope tolerance AND at least the minimum trendline touch count of retained confirmed Flux pivot highs lie within touch tolerance of the line
Long: Panel flux(T2) > panel-state threshold
Short: Panel flux(T2) < negative panel-state threshold
Long: Panel flux(T3) > panel-state threshold
Short: Panel flux(T3) < negative panel-state threshold
Long: Panel flux(T4) > panel-state threshold
Short: Panel flux(T4) < negative panel-state threshold