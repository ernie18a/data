Calculation: Squeeze momentum = linear regression endpoint of close minus the average of (highest high plus lowest low) / 2 and SMA of close, using a momentum lookback; the highest, lowest, and SMA use a separate common lookback.
Calculation: Smoothed RSI = EMA of RSI of close.
Calculation: RSI trailing line = initially smoothed RSI; thereafter, let band = a factor times EMA of the absolute change in smoothed RSI, with EMA length twice the RSI length minus one. If smoothed RSI > previous trailing line + band, use smoothed RSI - band; otherwise, if smoothed RSI < previous trailing line - band, use smoothed RSI + band; otherwise retain the previous trailing line.
Calculation: Filtered-price oscillator = shorter EMA of filtered close minus longer EMA of filtered close, where filtered close starts at close and subsequently equals previous filtered close + gain × (close - previous filtered close).
Calculation: Normalized filtered-price oscillator = oscillator's position between its rolling minimum and maximum, expressed as a percentage; use the midpoint when the range is zero.
Calculation: Wave trend = EMA of (typical price - EMA of typical price) divided by a scaling factor times EMA of the absolute deviation of typical price from that EMA; both inner EMAs use the same length, and the outer EMA uses a separate length. Use zero for the divided expression when its denominator is zero. Its signal is an SMA of wave trend.
Calculation: Stochastic RSI = stochastic of RSI using RSI as the high, low, and close inputs; its K line is an SMA of that stochastic and its D line is an SMA of K.
Calculation: Confluence total = sum the following components: EMA stack contributes double positive weight when the four close EMAs are strictly ordered shortest > shorter > longer > longest, double negative weight for the reverse, otherwise zero; Supertrend contributes double positive weight in its bullish state and double negative weight otherwise; RSI contributes positive weight above its bullish threshold, negative weight below its bearish threshold, otherwise zero; stochastic RSI contributes positive weight when K > D and negative weight otherwise; MACD contributes positive weight when its line > signal and negative weight otherwise; ADX contributes positive weight when ADX > its strength threshold AND positive DI > negative DI, negative weight when ADX > the threshold AND negative DI > positive DI, otherwise zero; close versus session VWAP, OBV versus its EMA, volume versus a multiple of its SMA, other-timeframe MACD histogram versus its signal, and smoothed RSI versus its trailing line each contribute positive weight when the first value > the second and negative weight otherwise; squeeze momentum contributes positive weight when > zero AND > its previous value, negative weight when < zero AND < its previous value, otherwise zero; normalized filtered-price oscillator contributes positive weight when > its upper threshold AND its oscillator > its previous value, negative weight when < its lower threshold AND its oscillator < its previous value, otherwise zero; wave trend contributes positive weight when > its signal AND < its upper threshold, negative weight when < its signal AND > its lower threshold, otherwise zero. For each of five ordered other timeframes, compare the same shorter, longer, and longest close EMAs: contribute positive weight for shorter > longer > longest, negative weight for shorter < longer < longest, otherwise zero; use double weight for the three shorter timeframes and triple weight for the two longer timeframes. For other-timeframe calculations, when the requested timeframe is higher than the chart timeframe, use the last completed bar on historical data and the forming bar in real time; when lower, use the last available lower-timeframe bar within the chart bar.
Calculation: Confluence score = round the confluence total after adding a fixed positive offset and scaling it to a percentage, then clamp it to the percentage range.
Long: Shortest close EMA > shorter close EMA AND shorter close EMA > longer close EMA AND longer close EMA > longest close EMA.
Short: Shortest close EMA < shorter close EMA AND shorter close EMA < longer close EMA AND longer close EMA < longest close EMA.
Long: Supertrend is bullish.
Short: Supertrend is bearish.
Long: RSI > bullish threshold.
Short: RSI < bearish threshold.
Long: Stochastic RSI K > D.
Short: Stochastic RSI K <= D.
Long: MACD line > MACD signal.
Short: MACD line <= MACD signal.
Long: ADX >= strength threshold AND positive DI > negative DI.
Short: ADX >= strength threshold AND positive DI <= negative DI.
Long: Close > session VWAP of typical price.
Short: Close <= session VWAP of typical price.
Long: OBV > EMA of OBV.
Short: OBV <= EMA of OBV.
Long: Volume > a multiplier times SMA of volume.
Long: Other-timeframe MACD histogram > other-timeframe MACD signal, using the same other-timeframe bar selection as the confluence total.
Short: Other-timeframe MACD histogram <= other-timeframe MACD signal, using the same other-timeframe bar selection as the confluence total.
Long: Squeeze momentum > zero AND squeeze momentum > its previous value.
Short: Squeeze momentum < zero AND squeeze momentum < its previous value.
Long: Smoothed RSI > RSI trailing line.
Short: Smoothed RSI <= RSI trailing line.
Long: Normalized filtered-price oscillator > upper threshold AND filtered-price oscillator > its previous value.
Short: Normalized filtered-price oscillator < lower threshold AND filtered-price oscillator < its previous value.
Long: Wave trend > its signal AND wave trend < upper threshold.
Short: Wave trend < its signal AND wave trend > lower threshold.
Long: On any of the five other timeframes, shorter close EMA > longer close EMA AND longer close EMA > longest close EMA, using the same other-timeframe bar selection as the confluence total.
Short: On any of the five other timeframes, shorter close EMA < longer close EMA AND longer close EMA < longest close EMA, using the same other-timeframe bar selection as the confluence total.
Long: Confluence score >= uptrend threshold.
Short: Confluence score < neutral threshold, where the neutral threshold is below the uptrend threshold.
Long: Confluence score >= buy-alert threshold, where the buy-alert threshold is above the uptrend threshold.
Long: Confluence score >= strong-buy-alert threshold, where the strong-buy-alert threshold is above the buy-alert threshold.
Short: Confluence score <= sell-alert threshold, where the sell-alert threshold is below the neutral threshold.
Short: Confluence score <= strong-sell-alert threshold, where the strong-sell-alert threshold is below the sell-alert threshold.
Long: Percentage distance of close above the mid-length close EMA > stretch threshold AND RSI <= overbought threshold AND RSI >= oversold threshold.
Short: Percentage distance of close above the mid-length close EMA < negative stretch threshold AND RSI <= overbought threshold AND RSI >= oversold threshold.