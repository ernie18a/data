Calculation: Bullish sweep = current low < previous completed daily low, current Asia-session low, or the lowest low of the prior shorter-lookback bars, AND current close > that level
Calculation: Bearish sweep = current high > previous completed daily high, current Asia-session high, or the highest high of the prior shorter-lookback bars, AND current close < that level
Calculation: Recent bullish/bearish sweep = corresponding sweep occurred within the longer recent-bars lookback
Calculation: Bullish structure break = confirmed close > highest high of prior shorter-lookback bars; bearish structure break = confirmed close < lowest low of prior shorter-lookback bars
Calculation: Bullish displacement = confirmed bullish candle body > ATR × threshold; bearish displacement = confirmed bearish candle body > ATR × threshold
Calculation: Bullish FVG = confirmed low > high two bars earlier; bearish FVG = confirmed high < low two bars earlier
Calculation: Bullish order block = prior bar bearish AND current close > prior high; bearish order block = prior bar bullish AND current close < prior low
Calculation: Bullish retest = close is within the latest bullish FVG or order-block bounds, OR low reaches its upper bound while close remains above its lower bound; bearish retest = close is within the latest bearish FVG or order-block bounds, OR high reaches its lower bound while close remains below its upper bound
Calculation: Bullish trend = current-timeframe close > EMA AND still-forming 15-minute close > EMA; bearish trend = current-timeframe close < EMA AND still-forming 15-minute close < EMA; use the same EMA lookback on all timeframes
Calculation: Bullish trend score and bearish trend score = weighted counts of the corresponding trend alignment, recent sweep, structure break/CISD, FVG/order block, retest, session, premium/discount, footprint, and SMT conditions
Calculation: Bullish entry model = any of: recent bullish sweep AND bullish CISD AND bullish retest AND not extended; recent bullish sweep AND (bullish structure break OR bullish CISD) AND bullish FVG AND bullish order block AND bullish retest AND not extended; recent bullish sweep AND bullish CISD AND bullish displacement AND (bullish FVG OR bullish order block) AND no bullish retest AND not extended; session-window bullish sweep/CISD/retest setup; or silver-window bullish sweep/CISD/POI/retest setup. Bullish CISD = recent bullish sweep AND bullish structure break AND bullish displacement
Calculation: Bearish entry model = corresponding bearish conditions: recent bearish sweep AND bearish CISD AND bearish retest AND not extended; recent bearish sweep AND (bearish structure break OR bearish CISD) AND bearish FVG AND bearish order block AND bearish retest AND not extended; recent bearish sweep AND bearish CISD AND bearish displacement AND (bearish FVG OR bearish order block) AND no bearish retest AND not extended; session-window bearish sweep/CISD/retest setup; or silver-window bearish sweep/CISD/POI/retest setup. Bearish CISD = recent bearish sweep AND bearish structure break AND bearish displacement
Calculation: Extended = close is more than an ATR-based threshold beyond the midpoint of the latest corresponding POI
Calculation: Long stop = min(low, lowest low of prior shorter-lookback bars) minus an ATR-based buffer; short stop = max(high, highest high of prior shorter-lookback bars) plus an ATR-based buffer
Calculation: Long targets = entry price + (entry price − long stop) × target multiple; short targets = entry price − (short stop − entry price) × target multiple
Long: confirmed bar AND no active position AND cooldown and daily trade limits permit AND no news block AND bullish entry model AND bullish score ≥ minimum trade score AND bullish score ≥ bearish score
Short: confirmed bar AND no active position AND cooldown and daily trade limits permit AND no news block AND bearish entry model AND bearish score ≥ minimum trade score AND bearish score > bullish score
Long: bullish score > bearish score
Short: bearish score > bullish score
Long: confirmed bullish sweep
Short: confirmed bearish sweep
Long: confirmed bullish structure break
Short: confirmed bearish structure break
Exit: long, high ≥ third long target OR low ≤ long stop OR setup age exceeds expiry limit
Exit: short, low ≤ third short target OR high ≥ short stop OR setup age exceeds expiry limit