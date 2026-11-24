Calculation: Per-bar consolidation score = score scale × (trend weight × clamp(1 − normalized PercentRank(ADX(ADX lookback), squeeze lookback), unit interval) + squeeze weight × clamp((highest(Bollinger Band Width(Bollinger length, Bollinger deviations), squeeze lookback) − current Bollinger Band Width) ÷ (highest − lowest Bollinger Band Width over the squeeze lookback), unit interval) + tightness weight × clamp(1 − normalized PercentRank(highest(high, Bollinger length) − lowest(low, Bollinger length), squeeze lookback), unit interval) + volume weight × (volume > 0 ? clamp(1 − normalized PercentRank(volume, squeeze lookback), unit interval) : neutral volume score) + balance weight × clamp(1 − abs(RSI(close, RSI lookback) − RSI center) ÷ RSI balance span, unit interval)) ÷ sum of weights; use zero for the squeeze score if its denominator is zero
Calculation: Zone score = highest per-bar consolidation score since zone start
Calculation: Active zone = starts on the latest bar of a run of the required consecutive confirmed chart bars whose per-bar consolidation score meets the minimum-score parameter; starts with that bar's high and low; extends its high, low, and zone score on qualifying bars that remain inside the buffered stop levels and before the maximum zone span; ends on breakout or maximum span
Calculation: Breakout buffer = max(zone height × buffer percentage, minimum tick × tick-buffer multiple)
Calculation: Buy stop = zone high + breakout buffer
Calculation: Sell stop = zone low − breakout buffer
Calculation: Bullish probability = rounded probability scale × bullish subtotal ÷ (bullish subtotal + bearish subtotal); bullish subtotal = position weight × range position + upper-time weight × upper-time share + top-touch weight × top-touch share + momentum weight × max(RSI lean, zero); bearish subtotal = position weight × (one − range position) + upper-time weight × (one − upper-time share) + top-touch weight × (one − top-touch share) + momentum weight × max(−RSI lean, zero); range position = (close − zone low) ÷ max(zone height, minimum range floor); upper-time share = upper-half bar count ÷ max(upper-half plus lower-half bar count, one); top-touch share = top-touch count ÷ max(top-touch plus bottom-touch count, one); RSI lean = clamp((RSI(close, RSI lookback) − RSI center) ÷ RSI momentum span, negative one to positive one); use neutral probability if the subtotals sum to zero
Long: active zone and bullish probability ≥ neutral probability
Short: active zone and bullish probability < neutral probability
Long: active zone and (close > buy stop when confirmation mode is close, or high > buy stop when confirmation mode is wick)
Short: active zone and (close < sell stop when confirmation mode is close, or low < sell stop when confirmation mode is wick)
Long: active zone and zone score ≥ strong-zone threshold and bullish probability ≥ neutral probability and confirmed close > buy stop
Short: active zone and zone score ≥ strong-zone threshold and bullish probability < neutral probability and confirmed close < sell stop
Long: zone score < strong-zone threshold or (zone score ≥ strong-zone threshold and bearish bias), and low < zone low and close > zone low
Short: zone score < strong-zone threshold or (zone score ≥ strong-zone threshold and bullish bias), and high > zone high and close < zone high
Calculation: Risk distance = max(selected stop-basis distance (opposite zone edge, zone midpoint, or ATR(ATR lookback) × stop ATR multiple), ATR(ATR lookback) × minimum risk fraction)
Calculation: Long stop = entry price − risk distance
Calculation: Short stop = entry price + risk distance
Calculation: Long first target = entry price + risk distance × first reward multiple
Calculation: Short first target = entry price − risk distance × first reward multiple
Exit: long, low ≤ long stop or high ≥ long first target
Exit: short, high ≥ short stop or low ≤ short first target