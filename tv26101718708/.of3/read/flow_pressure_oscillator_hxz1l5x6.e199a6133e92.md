Calculation: Safe ratio(numerator, denominator, fallback) = numerator / denominator if numerator and denominator are valid and denominator is nonzero; otherwise fallback
Calculation: Safe z-score(x, lookback) = (x - SMA(x, lookback)) / stdev(x, lookback) when the standard deviation is valid and nonzero; otherwise zero
Calculation: Compressed pressure(x) = pressure output scale × tanh(clamp(x / compression divisor, -tanh input limit, tanh input limit))
Calculation: Normalized trend reading = EMA(Safe ratio(close - EMA(close, trend EMA lookback), ATR(ATR lookback), zero) × trend distance weight + Safe ratio(EMA(close, trend EMA lookback) - EMA(close, trend EMA lookback)[1], ATR(ATR lookback), zero) × trend slope scale × trend slope weight, trend smoothing lookback)
Calculation: Trend strength = clamp(abs(normalized trend reading) / trend strength scale, zero, one)
Calculation: ATR ratio = Safe ratio(ATR(ATR lookback), EMA(ATR(ATR lookback), ATR normalization lookback), one)
Calculation: Bullish structure = EMA(hlc3, short EMA lookback) > EMA(hlc3, middle EMA lookback) AND EMA(hlc3, middle EMA lookback) > EMA(hlc3, long EMA lookback) AND close > EMA(close, trend EMA lookback)
Calculation: Bearish structure = EMA(hlc3, short EMA lookback) < EMA(hlc3, middle EMA lookback) AND EMA(hlc3, middle EMA lookback) < EMA(hlc3, long EMA lookback) AND close < EMA(close, trend EMA lookback)
Calculation: Structure pressure = one if bullish structure; negative one if bearish structure; otherwise zero
Calculation: ADX quality = clamp(Safe ratio(ADX(DMI lookback, ADX smoothing) - minimum ADX, maximum ADX - minimum ADX, zero), zero, one)
Calculation: Efficiency quality = clamp(Safe ratio(Efficiency ratio(hlc3, efficiency lookback) - minimum efficiency, maximum efficiency - minimum efficiency, zero), zero, one)
Calculation: Volatility quality = clamp(Safe ratio(ATR ratio - minimum ATR ratio, maximum ATR ratio - minimum ATR ratio, zero), zero, one)
Calculation: Volume z-score = Safe z-score(volume, ATR normalization lookback) if volume is valid and positive; otherwise zero
Calculation: Volume quality = clamp(Safe ratio(volume z-score + volume quality offset, volume quality scale, zero), zero, one) if volume is valid and positive; otherwise one
Calculation: Pressure quality = clamp(ADX quality × ADX quality weight + efficiency quality × efficiency quality weight + volatility quality × volatility quality weight + volume quality × volume quality weight, zero, one)
Calculation: Chop load = (one - ADX quality) × ADX chop weight + (one - efficiency quality) × efficiency chop weight + (one - volatility quality) × volatility chop weight + (one - volume quality) × volume chop weight
Calculation: Adaptive quality minimum = clamp(quality minimum base + chop load × chop adjustment - trend strength × trend adjustment, adaptive quality lower bound, adaptive quality upper bound)
Calculation: Quality gate = pressure quality >= adaptive quality minimum
Calculation: Quality multiplier = regime quality floor + (one - regime quality floor) × pressure quality
Calculation: Momentum base = Safe ratio(EMA(hlc3, short EMA lookback) - EMA(hlc3, middle EMA lookback), ATR(ATR lookback), zero) + Safe ratio(EMA(hlc3, middle EMA lookback) - EMA(hlc3, long EMA lookback), ATR(ATR lookback), zero)
Calculation: Price impulse = Safe z-score(ROC(hlc3, short EMA lookback), ATR normalization lookback)
Calculation: Fast impulse = Safe ratio(EMA(hlc3, short EMA lookback) - EMA(hlc3, middle EMA lookback), ATR(ATR lookback), zero)
Calculation: Slow impulse = Safe ratio(EMA(hlc3, middle EMA lookback) - EMA(hlc3, long EMA lookback), ATR(ATR lookback), zero)
Calculation: Range impulse = Safe ratio(close - EMA(hlc3, middle EMA lookback), ATR(ATR lookback), zero)
Calculation: Volume impulse = clamp(Volume z-score / volume impulse scale, negative one, one) × sign(Momentum base) if volume is valid and positive; otherwise zero
Calculation: Trend alignment weight = neutral alignment weight if sign(normalized trend reading) or sign(Momentum base) is zero; full alignment weight if their signs match; otherwise opposing alignment weight
Calculation: Raw pressure engine = Fast impulse × fast impulse weight + Slow impulse × slow impulse weight + Price impulse × price impulse weight + Range impulse × range impulse weight + normalized trend reading × trend impulse weight + Structure pressure × structure impulse weight + (ATR ratio - one) × sign(Momentum base) × volatility impulse weight + Volume impulse × volume impulse weight
Calculation: Pressure engine = Raw pressure engine × Trend alignment weight × Quality multiplier
Calculation: Pressure oscillator = Compressed pressure(EMA(Pressure engine, oscillator smoothing lookback))
Calculation: Signal base = EMA(Pressure oscillator, signal lookback)
Calculation: Pressure velocity = EMA(change(Pressure oscillator), velocity smoothing lookback)
Calculation: Pressure acceleration = EMA(change(Pressure velocity), acceleration smoothing lookback)
Calculation: Signal pressure = clamp(EMA(Signal base + Pressure velocity × velocity weight + Pressure acceleration × acceleration weight, signal smoothing lookback), lower pressure bound, upper pressure bound)
Calculation: Trend bias = zero if sign(normalized trend reading) is zero; Trend strength if its sign matches sign(Momentum base); otherwise negative Trend strength × opposing trend bias weight
Calculation: Pressure histogram = selected EMA of clamp((Pressure oscillator - Signal base) × oscillator difference weight + Pressure velocity × histogram velocity weight + Pressure acceleration × histogram acceleration weight + Compressed pressure(Pressure engine × histogram engine scale) × histogram engine weight + Trend bias × trend bias weight, lower pressure bound, upper pressure bound), using the short histogram smoothing lookback when pressure quality exceeds the high quality boundary, the middle histogram smoothing lookback when it exceeds the middle quality boundary, and the long histogram smoothing lookback otherwise; multiply the result by histogram base multiplier + pressure quality × histogram quality multiplier
Calculation: Histogram slope = Pressure histogram minus its prior bar value, or itself if the prior value is unavailable
Calculation: Bullish histogram momentum = (Pressure histogram > bullish strong histogram threshold AND Histogram slope > zero) OR (Pressure histogram > zero AND Histogram slope >= zero) OR (Pressure histogram > negative bullish histogram threshold AND Histogram slope > zero AND Pressure velocity > zero)
Calculation: Bearish histogram momentum = (Pressure histogram < negative bearish strong histogram threshold AND Histogram slope < zero) OR (Pressure histogram < zero AND Histogram slope <= zero) OR (Pressure histogram < bearish histogram threshold AND Histogram slope < zero AND Pressure velocity < zero)
Calculation: Band center = EMA(Pressure oscillator, band lookback)
Calculation: Band width = max(stdev(Pressure oscillator, band lookback) × standard deviation band weight + EMA(abs(Pressure oscillator - Band center), band lookback) × MAD conversion factor × MAD band weight, minimum band width)
Calculation: Upper inner band = clamp(Band center + Band width × inner band multiplier, lower pressure bound, upper pressure bound)
Calculation: Lower inner band = clamp(Band center - Band width × inner band multiplier, lower pressure bound, upper pressure bound)
Calculation: Upper outer band = clamp(Band center + Band width × outer band multiplier, lower pressure bound, upper pressure bound)
Calculation: Lower outer band = clamp(Band center - Band width × outer band multiplier, lower pressure bound, upper pressure bound)
Calculation: Bullish regime score = pressure quality × regime quality weight + bullish structure weight if Bullish structure + positive trend weight if normalized trend reading > zero + positive momentum weight if Momentum base > zero + positive oscillator weight if Pressure oscillator > zero
Calculation: Bearish regime score = pressure quality × regime quality weight + bearish structure weight if Bearish structure + negative trend weight if normalized trend reading < zero + negative momentum weight if Momentum base < zero + negative oscillator weight if Pressure oscillator < zero
Calculation: Bullish regime candidate = Quality gate AND Bullish regime score >= regime activation threshold AND Bullish regime score > Bearish regime score + regime edge
Calculation: Bearish regime candidate = Quality gate AND Bearish regime score >= regime activation threshold AND Bearish regime score > Bullish regime score + regime edge
Calculation: Bullish regime invalidation = close < EMA(hlc3, long EMA lookback) OR normalized trend reading < negative trend invalidation threshold OR EMA(hlc3, short EMA lookback) < EMA(hlc3, middle EMA lookback) AND EMA(hlc3, middle EMA lookback) < EMA(hlc3, long EMA lookback)
Calculation: Bearish regime invalidation = close > EMA(hlc3, long EMA lookback) OR normalized trend reading > trend invalidation threshold OR EMA(hlc3, short EMA lookback) > EMA(hlc3, middle EMA lookback) AND EMA(hlc3, middle EMA lookback) > EMA(hlc3, long EMA lookback)
Calculation: Regime state = bullish if Bullish regime candidate; otherwise bearish if Bearish regime candidate; otherwise neutral if the prior state was bullish and (Bullish regime invalidation or Bullish regime score < regime deactivation threshold), or if the prior state was bearish and (Bearish regime invalidation or Bearish regime score < regime deactivation threshold); otherwise retain the prior state
Calculation: Bullish regime = Regime state is bullish
Calculation: Bearish regime = Regime state is bearish
Calculation: Neutral regime = Regime state is neutral
Calculation: Upward persistence = Bullish regime AND Quality gate AND Pressure oscillator > zero AND Pressure oscillator > Signal base AND Signal pressure > negative signal threshold AND Bullish histogram momentum
Calculation: Downward persistence = Bearish regime AND Quality gate AND Pressure oscillator < zero AND Pressure oscillator < Signal base AND Signal pressure < signal threshold AND Bearish histogram momentum
Calculation: Upward expansion = Upward persistence AND Pressure oscillator > Upper inner band AND Pressure velocity > zero AND Pressure histogram > bullish strong histogram threshold AND Histogram slope > zero
Calculation: Downward expansion = Downward persistence AND Pressure oscillator < Lower inner band AND Pressure velocity < zero AND Pressure histogram < negative bearish strong histogram threshold AND Histogram slope < zero
Calculation: Upward reload = Bullish regime AND Quality gate AND Pressure oscillator > negative reload zone AND Pressure oscillator < Signal base AND Pressure histogram > negative reload histogram threshold AND Histogram slope > zero AND Pressure velocity > its prior bar value
Calculation: Downward reload = Bearish regime AND Quality gate AND Pressure oscillator < reload zone AND Pressure oscillator > Signal base AND Pressure histogram < reload histogram threshold AND Histogram slope < zero AND Pressure velocity < its prior bar value
Calculation: Bullish swing exhaustion = Bullish regime AND ((Pressure oscillator > bullish exhaustion threshold AND Pressure velocity < zero AND Histogram slope < zero) OR (Pressure oscillator > Upper outer band AND Pressure velocity < its prior bar value AND Histogram slope < zero))
Calculation: Bearish swing exhaustion = Bearish regime AND ((Pressure oscillator < negative bearish exhaustion threshold AND Pressure velocity > zero AND Histogram slope > zero) OR (Pressure oscillator < Lower outer band AND Pressure velocity > its prior bar value AND Histogram slope > zero))
Calculation: Neutral upper exhaustion = Neutral regime AND Pressure oscillator > neutral exhaustion threshold AND Pressure velocity < zero AND Histogram slope < zero
Calculation: Neutral lower exhaustion = Neutral regime AND Pressure oscillator < negative neutral exhaustion threshold AND Pressure velocity > zero AND Histogram slope > zero
Calculation: Exhaustion = Bullish swing exhaustion OR Bearish swing exhaustion OR Neutral upper exhaustion OR Neutral lower exhaustion
Calculation: Reload strength = clamp((reload zone - abs(Pressure oscillator)) / reload zone, zero, one) × pressure quality for Upward reload; the negative of that value for Downward reload; otherwise zero
Calculation: Reload line = EMA(Reload strength × reload line scale, reload line smoothing lookback)
Calculation: Raw flow trail = Pressure oscillator × flow oscillator weight + Pressure histogram × flow histogram weight + Pressure velocity × flow velocity weight + Pressure acceleration × flow acceleration weight + normalized trend reading × flow trend weight
Calculation: Flow trail = selected EMA of clamp(Raw flow trail, lower pressure bound, upper pressure bound), using the short flow smoothing lookback when pressure quality exceeds the high quality boundary, the middle flow smoothing lookback when it exceeds the middle quality boundary, and the long flow smoothing lookback otherwise
Calculation: Flow trail slope = Flow trail minus its prior bar value, or itself if the prior value is unavailable
Calculation: Upper reversal pressure = Flow trail >= flow reversal threshold AND (Flow trail slope < zero OR Pressure velocity < zero OR Histogram slope < zero OR Pressure acceleration < zero OR Exhaustion)
Calculation: Lower reversal pressure = Flow trail <= negative flow reversal threshold AND (Flow trail slope > zero OR Pressure velocity > zero OR Histogram slope > zero OR Pressure acceleration > zero OR Exhaustion)
Calculation: Upper extreme potential = Flow trail >= flow extreme threshold AND (Flow trail slope < zero OR Pressure velocity < zero OR Histogram slope < zero OR Pressure acceleration < zero OR Exhaustion)
Calculation: Lower extreme potential = Flow trail <= negative flow extreme threshold AND (Flow trail slope > zero OR Pressure velocity > zero OR Histogram slope > zero OR Pressure acceleration > zero OR Exhaustion)
Calculation: Extreme pressure = Upper extreme potential OR Lower extreme potential OR Upper reversal pressure OR Lower reversal pressure OR Exhaustion OR Upward expansion OR Downward expansion
Long: Bullish regime OR Reload line > zero OR (Quality gate AND NOT Extreme pressure AND Flow trail > zero) OR (Upward persistence AND NOT Upward persistence[1]) OR (Upward reload AND NOT Upward reload[1]) OR (Upward expansion AND NOT Upward expansion[1]) OR (Lower extreme potential AND NOT Lower extreme potential[1])
Short: Bearish regime OR Reload line < zero OR (Quality gate AND NOT Extreme pressure AND Flow trail < zero) OR (Downward persistence AND NOT Downward persistence[1]) OR (Downward reload AND NOT Downward reload[1]) OR (Downward expansion AND NOT Downward expansion[1]) OR (Upper extreme potential AND NOT Upper extreme potential[1])