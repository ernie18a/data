Calculation: Structure pivots = switch leg to high when high[lookback] > highest(high, lookback), otherwise switch to low when low[lookback] < lowest(low, lookback); on a 1-to-0 leg change confirm a swing high at high[lookback], and on a 0-to-1 change confirm a swing low at low[lookback].
Calculation: Market-structure bias = initialize bullish; change to bullish when close crosses above the latest confirmed swing high, or bearish when close crosses below the latest confirmed swing low; reset each level after its break.
Calculation: Upward structure break = on a confirmed chart bar, the first cross above the latest unbroken swing high using close when close-break is enabled, otherwise high; if an upward and downward break coincide, count upward only when close >= open.
Calculation: Downward structure break = on a confirmed chart bar, the first cross below the latest unbroken swing low using close when close-break is enabled, otherwise low; if an upward and downward break coincide, count downward only when close < open.
Calculation: Active CHoCH direction = direction of the latest change-of-character break on chart bars, initially neutral.
Calculation: Bullish FVG event = on a confirmed chart bar, low[1] > high[3] AND close[2] > low[2] + ATR(200)[2] × displacement threshold.
Calculation: Bearish FVG event = on a confirmed chart bar, low[3] > high[1] AND close[2] < high[2] - ATR(200)[2] × displacement threshold.
Long: upward structure break AND prior market-structure direction bearish.
Long: upward structure break AND prior market-structure direction bullish.
Short: downward structure break AND prior market-structure direction bullish.
Short: downward structure break AND prior market-structure direction bearish.
Long: market-structure bias calculated on T1 bars is bullish; use the T1 bar still forming.
Short: market-structure bias calculated on T1 bars is bearish; use the T1 bar still forming.
Long: active CHoCH direction is bullish.
Short: active CHoCH direction is bearish.
Long: close >= the latest completed T1 period's volume-profile POC.
Short: close < the latest completed T1 period's volume-profile POC.
Long: the selected correlation asset's chart-timeframe market-structure bias is bullish, or bearish when the inverse-correlation parameter is enabled.
Short: the selected correlation asset's chart-timeframe market-structure bias is bearish, or bullish when the inverse-correlation parameter is enabled.
Long: current T1 close >= current T1 open; use the T1 bar still forming.
Short: current T1 close < current T1 open; use the T1 bar still forming.
Long: previous completed T1 close >= previous completed T1 open.
Short: previous completed T1 close < previous completed T1 open.
Long: confirmed pivot low using the BOSS swing lookback, independent of the structure lookback.
Short: confirmed pivot high using the BOSS swing lookback, independent of the structure lookback.
Long: bullish FVG event.
Short: bearish FVG event.
Long: active CHoCH direction is bullish AND close > open AND low < low[1] AND the bar overlaps an active, unmitigated, non-breaker bullish FVG.
Short: active CHoCH direction is bearish AND close < open AND high > high[1] AND the bar overlaps an active, unmitigated, non-breaker bearish FVG.
Long: after a bullish CHoCH, sequence stage <= 1, and a confirmed pivot low formed after that CHoCH has range > 0, lower wick / range >= minimum-wick-percent parameter, and lower wick >= ATR(RB lookback)[pivot lookback] × minimum-wick-ATR parameter, unless that parameter is zero.
Short: after a bearish CHoCH, sequence stage <= 1, and a confirmed pivot high formed after that CHoCH has range > 0, upper wick / range >= minimum-wick-percent parameter, and upper wick >= ATR(RB lookback)[pivot lookback] × minimum-wick-ATR parameter, unless that parameter is zero.
Long: a valid bullish rejected block has been confirmed, a later bar has low > its top to arm the retest, and a subsequent bar has low <= its top AND high >= its bottom.
Short: a valid bearish rejected block has been confirmed, a later bar has high < its bottom to arm the retest, and a subsequent bar has high >= its bottom AND low <= its top.
Long: after a bullish rejected-block retest, a bullish BOS and bullish FVG event occur within the FVG/BOS window.
Short: after a bearish rejected-block retest, a bearish BOS and bearish FVG event occur within the FVG/BOS window.
Long: after the later of the associated bullish BOS and FVG bars, the final bullish FVG is not invalidated under the selected mitigation rule AND low < its top.
Short: after the later of the associated bearish BOS and FVG bars, the final bearish FVG is not invalidated under the selected mitigation rule AND high > its bottom.
Long: after a bullish CHoCH, price has touched its 0.382–0.618 retracement zone and a later confirmed close is above that zone.
Short: after a bearish CHoCH, price has touched its 0.382–0.618 retracement zone and a later confirmed close is below that zone.
Calculation: CHoCH trend line = line through the completed regime's low and first later confirmed higher pivot low after a bullish CHoCH, or through the completed regime's high and first later confirmed lower pivot high after a bearish CHoCH.
Long: after a bearish CHoCH trend line is validated, its first subsequent confirmed break is above the line using close when close-break is enabled, otherwise high.
Short: after a bullish CHoCH trend line is validated, its first subsequent confirmed break is below the line using close when close-break is enabled, otherwise low.