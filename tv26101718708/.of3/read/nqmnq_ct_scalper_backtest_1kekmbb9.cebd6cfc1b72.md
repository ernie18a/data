Calculation: relative volume = volume / SMA(volume, lookback)
Calculation: trend efficiency = abs(close - close[lookback]) / SUM(abs(close - close[previous bar]), lookback)
Calculation: adaptive trend threshold = min(cap, base threshold × ATR / SMA(ATR, lookback))
Calculation: trending = trend efficiency > adaptive trend threshold; uptrend = trending AND close > close[lookback]; downtrend = trending AND close < close[lookback]; choppy = not trending AND ATR > SMA(ATR, lookback); consolidation = not trending AND ATR <= SMA(ATR, lookback)
Calculation: Hurst exponent = slope of the linear regression of log(segment length) against log(mean rescaled range) across segments of length n, n/2, n/4, and n/8 of close changes
Calculation: Hurst mean-reverting = Hurst exponent < base threshold + ADF shift; Hurst persistent = Hurst exponent > persistence threshold - ADF shift
Calculation: ADF statistic = t-statistic for the lagged-close coefficient in a rolling regression of close change on prior close, using the session-selected lookback
Calculation: ADF mean-reverting = ADF statistic < critical value adjusted by lookback; ADF trending = ADF statistic > threshold
Calculation: ADF shift = (ADF mean-reverting adjustment OR ADF trending adjustment) × session weight × regime weight × ADX weight
Calculation: Bollinger bands = Bollinger Bands(close, lookback, deviation parameter); Keltner bands = EMA(close, lookback) ± ATR(lookback) × channel multiplier; squeeze on = Bollinger bands inside Keltner bands; squeeze fired = squeeze was on at the previous bar AND is not on now
Calculation: squeeze momentum = LinearRegression(close - average((highest high + lowest low) / two, SMA(close, lookback)), lookback, current offset)
Calculation: momentum flips bullish when squeeze momentum crosses above zero and bearish when it crosses below zero; momentum decelerates bullish when positive momentum decreases across consecutive bars and bearish when negative momentum increases across consecutive bars
Calculation: Bollinger position = (close - lower Bollinger band) / Bollinger band width; free bar above = low > upper Bollinger band; free bar below = high < lower Bollinger band
Calculation: VWAP bands = VWAP(typical price) ± rolling standard deviation(close - VWAP, lookback) × band multipliers
Calculation: big upper wick = upper wick > body × adaptive wick/body threshold AND upper wick > ATR × adaptive wick/ATR threshold; big lower wick is the corresponding lower-wick condition
Calculation: relative-volume and ATR liquidity filter = relative volume >= minimum relative volume AND ATR >= minimum ATR
Calculation: footprint delta slope = daily-reset cumulative footprint delta - its value at the lookback bar; footprint delta is bullish when this is positive and bearish when negative
Calculation: footprint buy ratio = footprint buy volume / footprint sell volume; footprint sell ratio = footprint sell volume / footprint buy volume
Calculation: delta flip bullish = current footprint delta > adaptive ATR-scaled threshold AND prior footprint delta < negative threshold; delta flip bearish is the inverse
Calculation: absorption bullish = footprint total volume > SMA(volume, lookback) × adaptive volume threshold AND bar range < SMA(bar range, lookback) × adaptive range threshold AND abs(close - open) / bar range < adaptive body threshold AND close > open; absorption bearish uses close < open
Calculation: aggressive buy flow = footprint buy ratio >= adaptive ratio threshold AND relative volume >= adaptive volume threshold; aggressive sell flow uses footprint sell ratio
Calculation: bullish RSI divergence = price makes a lower pivot low while RSI makes a higher pivot low; bearish RSI divergence = price makes a higher pivot high while RSI makes a lower pivot high; use the same pivot lookback on price and RSI
Calculation: footprint bullish divergence = price makes a lower pivot low AND cumulative footprint delta rises over its lookback AND footprint total volume exceeds average volume times its adaptive threshold; footprint bearish divergence is the inverse
Calculation: strong bullish divergence = bullish RSI divergence AND footprint bullish divergence; strong bearish divergence is the inverse
Calculation: full bullish structure = the latest confirmed pivot high and pivot low are both higher than their preceding pivots; full bearish structure = both are lower
Calculation: bullish change of character = full bearish structure AND close > latest pivot high; bearish change of character = full bullish structure AND close < latest pivot low
Calculation: bullish SMT divergence = traded price makes a lower pivot low while S&P 500 futures make a higher or equal pivot low; bearish SMT divergence = traded price makes a higher pivot high while S&P 500 futures make a lower or equal pivot high; retain each signal for an adaptive number of chart bars
Calculation: relative performance divergence = traded price return over a lookback minus broad-market ETF return over the same chart bars; bullish when below negative adaptive threshold, bearish when above positive adaptive threshold
Calculation: bullish engulfing = bullish bar after bearish bar, current body > average body, close > prior open, and open <= prior close; bearish engulfing is the inverse; hammer and shooting star use lower and upper wick respectively exceeding the body by adaptive ratios
Calculation: doji = bar range > zero AND body < bar range × session-dependent body threshold
Calculation: trend higher-timeframe vote = sign(fast EMA - slow EMA) + sign(close - midpoint of highest high and lowest low) + sign(close - fast EMA), with separate weights for T1, T2, and T3; chart bars use values from the still-forming T1, T2, and T3 bars with lookahead off
Calculation: higher-timeframe score = weighted sum of T1, T2, and T3 votes; T4 fast and slow EMAs use chart bars taking values from the still-forming T4 bar with lookahead off
Calculation: prior-period pivots use HLC3, high, and low from the last completed T5 bar; central pivot = prior HLC3; first and second resistance/support levels add/subtract the corresponding prior-range fractions
Calculation: NYSE tick average = SMA(NYSE tick index, lookback), sampled on chart bars from the still-forming external-data bar with lookahead off
Calculation: volatility-index rise/fall = current volatility-index close >/< its chart-bar close at the lookback bar × adaptive ratio threshold, using current external-data bars with lookahead off
Calculation: session range = high - low of the applicable Asia, London, or overnight session; opening-range midpoint = average of locked opening-range high and low; premarket midpoint = average of premarket high and low
Calculation: long overextension score adds weighted points for downside EMA and VWAP distance in ATR units, bullish swing structure, oversold MFI, bearish NYSE tick, positive footprint flow, low relative volume, big lower wick, distance below the latest footprint volume-zone midpoint, free bar below, oversold RSI, lower VWAP-band breaches, and bullish SMT; EMA/VWAP distances receive stronger points beyond their larger adaptive thresholds
Calculation: short overextension score adds weighted points for upside EMA and VWAP distance in ATR units, bearish swing structure, overbought MFI, bullish NYSE tick, negative footprint flow, low relative volume, big upper wick, distance above the latest footprint volume-zone midpoint, free bar above, overbought RSI, upper VWAP-band breaches, and bearish SMT; EMA/VWAP distances receive stronger points beyond their larger adaptive thresholds
Calculation: long overextension threshold = clamp(long base threshold + ADX adjustment + Hurst adjustment + session adjustment + higher-timeframe adjustment + T4 EMA adjustment + regime adjustment, minimum, maximum); short threshold uses its separate base and reverses directional adjustments
Calculation: long overextension passes when long overextension score >= long overextension threshold; short overextension passes when short overextension score >= short overextension threshold
Calculation: long confidence score adds weighted points for excess long overextension (or lesser excess with bearish structure or proximity to second support), Hurst mean-reversion, footprint bullish divergence or relative-performance bullish divergence, oversold MFI, volume climax or volume climax with volatility-index rise, big lower wick or free bar below, low Bollinger position or lower VWAP-band breach, bearish higher-timeframe fading or bearish momentum deceleration or bullish momentum flip or bullish squeeze firing, bullish NYSE tick, bullish change of character, bullish SMT, and bullish engulfing or hammer
Calculation: short confidence score adds weighted points for excess short overextension (or lesser excess with bullish structure or proximity to second resistance), Hurst mean-reversion, footprint bearish divergence or relative-performance bearish divergence, overbought MFI, volume climax or volume climax with volatility-index movement, big upper wick or free bar above, high Bollinger position or upper VWAP-band breach, bullish higher-timeframe fading or bullish momentum deceleration or bearish momentum flip or bearish squeeze firing, bearish NYSE tick, bearish change of character, bearish SMT, and bearish engulfing or shooting star
Calculation: dynamic minimum confidence = clamp(base + session adjustment + strong-trend adjustment + Hurst adjustment + strongly aligned higher-timeframe adjustment, minimum, maximum)
Calculation: hidden bearish RSI divergence blocks longs, and hidden bullish RSI divergence blocks shorts, outside Asia and lunch when ADX >= the regime-dependent threshold
Calculation: common long entry gate = longs enabled AND liquidity filter passes AND downtrend AND long overextension passes AND long confidence score >= minimum long confidence AND hidden bearish divergence does not block AND higher-timeframe score > negative (veto threshold + long allowance) AND ADX >= minimum ADX
Calculation: common short entry gate = shorts enabled AND liquidity filter passes AND uptrend AND short overextension passes AND short confidence score >= dynamic minimum confidence AND hidden bullish divergence does not block AND higher-timeframe score < veto threshold AND ADX >= minimum ADX
Calculation: extra short confirmation = session confirmation boost + strong-trend confirmation boost; extra long confirmation = max(zero, strong-trend boost - long offset) + late-session or Asia boost
Calculation: long stop = ATR-clamped stop beyond the lower of latest swing low and nearby regular-session low, with session-range cap and adaptive ATR buffer; short stop mirrors this above the higher swing high or nearby session high
Calculation: long target candidates above close = EMA(short lookback), VWAP, central pivot, opening-range midpoint, premarket midpoint, footprint POC, footprint value-area low, first support, and EMA(long lookback); short candidates below close use the corresponding EMA, VWAP, pivot, midpoints, POC, value-area high, first resistance, and long-lookback EMA
Calculation: long raw target = closest valid candidate for low confidence, midpoint of closest and farthest candidates for medium confidence, or farthest candidate for high confidence; use the ATR fallback when no valid candidate exists; short raw target mirrors this
Calculation: target distance = max(distance to raw target × profit cap × overextension scale × session scale × ADX scale × relative-volume scale × regime scale × Hurst scale × higher-timeframe scale × footprint-flow scale × VWAP-band scale, ATR × minimum target distance); apply the result above close for longs and below close for shorts
Calculation: long fade confirmation counts big lower wick, bullish delta flip, bullish absorption, bearish-momentum deceleration, bullish momentum flip, bullish squeeze firing, free bar below, bullish engulfing or hammer, bullish change of character, and bullish SMT with session-dependent points; short fade confirmation mirrors these conditions
Calculation: momentum penalty increases with opposing squeeze-momentum magnitude when momentum is not decelerating; add a session penalty during thin sessions when this penalty is positive
Calculation: long DIV confirmation = footprint bullish divergence + strong bullish divergence + bullish delta flip + bearish-momentum deceleration; short DIV confirmation mirrors these terms
Calculation: long TRAP confirmation requires a bearish sweep and at least the required count of bullish footprint-delta direction, buy ratio above adaptive threshold, and bullish delta flip; short TRAP confirmation uses bullish sweep and bearish flow terms
Calculation: long AGG confirmation requires aggressive buy flow and at least the required count of bullish footprint-delta direction, bullish delta flip, and bearish-momentum deceleration; short AGG confirmation mirrors these terms
Calculation: volume-zone retest support = after price has first moved away from every footprint volume zone by the adaptive ATR distance, low <= a zone low + adaptive proximity and close > that zone low; resistance retest mirrors this at a zone high; a retest requires moving away again before another retest
Calculation: long volume-zone confirmation counts big lower wick, bullish delta flip, bullish absorption, bullish footprint-delta direction, and bullish momentum flip; short confirmation mirrors these terms
Calculation: long risk/reward passes when target distance >= minimum profit AND target distance >= stop distance × long risk/reward floor; short uses its separate floor
Long: bullish footprint divergence
Short: bearish footprint divergence
Long: bullish RSI divergence
Short: bearish RSI divergence
Long: bullish absorption AND long overextension passes
Short: bearish absorption AND short overextension passes
Long: support volume-zone retest AND long overextension passes AND long confidence score >= dynamic minimum confidence
Short: resistance volume-zone retest AND short overextension passes AND short confidence score >= dynamic minimum confidence
Long: bearish sweep AND long overextension passes AND long confidence score >= dynamic minimum confidence
Short: bullish sweep AND short overextension passes AND short confidence score >= dynamic minimum confidence
Long: bullish change of character becomes true AND relative volume >= marker threshold AND outside Asia
Short: bearish change of character becomes true AND relative volume >= marker threshold AND outside Asia
Long: bullish SMT becomes true AND relative volume >= marker threshold AND outside Asia
Short: bearish SMT becomes true AND relative volume >= marker threshold AND outside Asia
Long: squeeze fired AND squeeze momentum > zero
Short: squeeze fired AND squeeze momentum < zero
Long: bullish momentum flip AND abs(squeeze momentum) > marker threshold AND relative volume >= marker threshold AND outside Asia
Short: bearish momentum flip AND abs(squeeze momentum) > marker threshold AND relative volume >= marker threshold AND outside Asia
Long: long confidence score >= short confidence score
Short: long confidence score < short confidence score
Long: long overextension passes
Short: long overextension does not pass AND short overextension passes
Long: common long entry gate AND FADE enabled AND not Hurst persistent AND not doji AND long fade confirmation >= dynamic fade minimum + momentum penalty + thin-session penalty + extra long confirmation AND long risk/reward passes
Short: common short entry gate AND FADE enabled AND not Hurst persistent AND not doji AND short fade confirmation >= dynamic fade minimum + momentum penalty + thin-session penalty + extra short confirmation AND short risk/reward passes
Long: common long entry gate AND DIV enabled AND long DIV confirmation >= base DIV requirement + momentum penalty + thin-session penalty + extra long confirmation AND long risk/reward passes
Short: common short entry gate AND DIV enabled AND short DIV confirmation >= base DIV requirement + momentum penalty + thin-session penalty + extra short confirmation AND short risk/reward passes
Long: common long entry gate AND TRAP enabled AND long TRAP confirmation passes its flow-count requirement including momentum and thin-session penalties AND long risk/reward passes
Short: common short entry gate AND TRAP enabled AND short TRAP confirmation passes its flow-count requirement including momentum and thin-session penalties AND short risk/reward passes
Long: common long entry gate AND AGG enabled AND long AGG confirmation passes its flow-count requirement including momentum and thin-session penalties AND long risk/reward passes
Short: common short entry gate AND AGG enabled AND short AGG confirmation passes its flow-count requirement including momentum and thin-session penalties AND short risk/reward passes
Long: common long entry gate AND VRZ enabled AND support volume-zone retest AND long volume-zone confirmation >= dynamic minimum + momentum penalty + thin-session penalty + extra long confirmation AND long risk/reward passes
Short: common short entry gate AND VRZ enabled AND resistance volume-zone retest AND short volume-zone confirmation >= dynamic minimum + momentum penalty + thin-session penalty + extra short confirmation AND short risk/reward passes
Exit: long, on a bar after entry, low <= long stop OR high >= long target
Exit: short, on a bar after entry, high >= short stop OR low <= short target