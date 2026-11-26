Calculation: Estimated buy share = clamp(intercept + close-location weight × ((close − low) / max(high − low, tick size)) + body-size weight × (abs(close − open) / max(high − low, tick size)) + bullish-bar weight when close >= open, lower share cap, upper share cap).
Calculation: Session profile = use active-session chart bars up to the session-bar limit; divide their high-low range into equal rows; allocate each bar's volume and estimated buy volume to the row containing its HLC3; POC is the center of the highest-volume row; expand value area from POC toward the higher-volume adjacent row until the target fraction of total volume is included, with VAL and VAH at the lowest and highest included row edges; profile skew = (total estimated buy volume − total estimated sell volume) / total volume; value width = (VAH − VAL) / ATR(lookback); for each row, intensity = row volume / maximum row volume and imbalance = abs(row buy fraction − neutral buy fraction) × imbalance scale; bid shelf power is the maximum positive row imbalance × intensity and ask shelf power is the maximum negative row imbalance × intensity.
Calculation: Session VWAP deviation and outer bands = square root of the active-session volume-weighted mean of HLC3 squared minus the squared active-session VWAP; outer bands are active-session VWAP ± deviation × outer-band multiplier.
Calculation: Session CVD = cumulative volume × (estimated buy share − estimated sell share), reset at active-session start.
Calculation: CVD impulse = when abs(slow EMA of session CVD) > zero, (fast EMA of session CVD − slow EMA of session CVD) / max(abs(slow EMA of session CVD), current volume), otherwise zero; the fast and slow EMA lookbacks are separate parameters.
Calculation: Confirmed CVD divergence = on a confirmed chart bar with simultaneous price and CVD pivots using separate left and right pivot lookbacks, bullish divergence when the new price pivot low is below the prior paired price pivot low and the new CVD pivot low is above the prior paired CVD pivot low; bearish divergence when the new price pivot high is above the prior paired price pivot high and the new CVD pivot high is below the prior paired CVD pivot high.
Calculation: Bid and ask quality scores = clamp(base points + location points + clamp(shelf power × shelf-score multiplier, zero, shelf-score cap) + clamp((directional CVD impulse − impulse threshold) × delta-score multiplier, zero, delta-score cap) + divergence points when matching divergence occurs + compression points based on value width / ATR + max(directional profile skew, zero) × skew-score multiplier, quality floor, quality cap); bid location points are VWAP-location points when close > session VWAP, otherwise POC-location points when close > POC, otherwise zero; ask location points are symmetric below VWAP and POC; compression points use separate tight and wide width thresholds and point values.
Calculation: Bid and ask auction bias = clamp(bias midpoint ± profile skew × skew-bias multiplier ± VWAP distance × VWAP-bias multiplier, bias floor, bias cap), where VWAP distance is clamp((close − session VWAP) / ATR(lookback), negative distance limit, positive distance limit), using plus signs for bid bias and minus signs for ask bias.
Calculation: Value tolerance = max(ATR(lookback) × ATR-proximity factor, tick size × tick-proximity count).
Long: signal-zone control enabled AND confirmed chart bar AND inside active session AND close > session VWAP AND close >= VAL AND close <= outer upper session VWAP band AND EMA(session CVD, fast lookback) > EMA(session CVD, slow lookback) AND CVD impulse > impulse threshold AND bid quality >= quality gate AND bid quality > ask quality AND (close > current POC AND close[1] <= current POC OR low <= VAL + value tolerance AND close > VAL AND close > open OR bullish CVD divergence OR bid shelf power > shelf gate) AND (no prior long or short signal OR current chart-bar index − most recent long or short signal bar > signal-cooldown bars).
Short: signal-zone control enabled AND confirmed chart bar AND inside active session AND close < session VWAP AND close <= VAH AND close >= outer lower session VWAP band AND EMA(session CVD, fast lookback) < EMA(session CVD, slow lookback) AND CVD impulse < negative impulse threshold AND ask quality >= quality gate AND ask quality > bid quality AND (close < current POC AND close[1] >= current POC OR high >= VAH − value tolerance AND close < VAH AND close < open OR bearish CVD divergence OR ask shelf power > shelf gate) AND (no prior long or short signal OR current chart-bar index − most recent long or short signal bar > signal-cooldown bars).
Exit: long, confirmed chart bar AND (bearish CVD divergence OR close < session VWAP OR close < POC).
Exit: short, confirmed chart bar AND (bullish CVD divergence OR close > session VWAP OR close > POC).
Long: bullish CVD divergence.
Short: bearish CVD divergence.
Long: close > session VWAP.
Short: close < session VWAP.
Long: a profile row's buy fraction > neutral buy fraction.
Short: a profile row's buy fraction < neutral buy fraction.
Long: a profile row's buy fraction >= neutral buy fraction AND row imbalance >= shelf gate AND row intensity >= minimum shelf-row intensity.
Short: a profile row's buy fraction < neutral buy fraction AND row imbalance >= shelf gate AND row intensity >= minimum shelf-row intensity.
Long: bid auction bias > ask auction bias.
Short: bid auction bias <= ask auction bias.
Long: bid quality > ask quality.
Short: bid quality <= ask quality.
Long: CVD impulse > zero.
Short: CVD impulse <= zero.
Long: bid shelf power > ask shelf power.
Short: bid shelf power <= ask shelf power.
Long: confirmed chart bar AND candle coloring enabled AND bid auction bias >= candle-color bias threshold.
Short: confirmed chart bar AND candle coloring enabled AND ask auction bias >= candle-color bias threshold.