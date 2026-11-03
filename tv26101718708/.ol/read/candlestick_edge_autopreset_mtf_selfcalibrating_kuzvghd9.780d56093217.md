Calculation: Body = |close − open|; upper wick = high − max(open, close); lower wick = min(open, close) − low
Calculation: Average body = simple moving average of body over a lookback
Calculation: Bullish hammer = body > 0 AND lower wick ≥ a multiple of body AND upper wick ≤ a smaller multiple of body
Calculation: Shooting star or inverted hammer = body > 0 AND upper wick ≥ a multiple of body AND lower wick ≤ a smaller multiple of body
Calculation: Bullish engulfing = prior candle bearish AND current candle bullish AND current close ≥ prior open AND current open ≤ prior close
Calculation: Bearish engulfing = prior candle bullish AND current candle bearish AND current open ≥ prior close AND current close ≤ prior open
Calculation: Morning star = candle two bars ago bearish with body > average body AND prior body < a fraction of that body AND current candle bullish AND current close > midpoint of candle two bars ago
Calculation: Evening star = candle two bars ago bullish with body > average body AND prior body < a fraction of that body AND current candle bearish AND current close < midpoint of candle two bars ago
Calculation: Piercing pattern = prior candle bearish AND current open < prior close AND current close > prior candle midpoint AND current close < prior open
Calculation: Dark cloud cover = prior candle bullish AND current open > prior close AND current close < prior candle midpoint AND current close > prior open
Calculation: Bullish harami = prior candle bearish AND current candle's body lies strictly inside prior body AND current body < prior body
Calculation: Bearish harami = prior candle bullish AND current candle's body lies strictly inside prior body AND current body < prior body
Calculation: Rising window = current low > prior high
Calculation: Falling window = current high < prior low
Calculation: Bullish marubozu = close > open AND both wicks ≤ a small fraction of body AND body > average body
Calculation: Bearish marubozu = open > close AND both wicks ≤ a small fraction of body AND body > average body
Calculation: Three white soldiers = three bullish candles with successively higher closes and each open within the preceding body; current body > a fraction of average body
Calculation: Three black crows = three bearish candles with successively lower closes and each open within the preceding body; current body > a fraction of average body
Calculation: Bullish three-line strike = three successively lower-closing bearish candles followed by a bullish candle opening below the prior close and closing above the first candle's open
Calculation: Bearish three-line strike = three successively higher-closing bullish candles followed by a bearish candle opening above the prior close and closing below the first candle's open
Calculation: Bullish abandoned baby = bearish candle, then a doji gapped below its low, then a bullish candle gapped above the doji high
Calculation: Bearish abandoned baby = bullish candle, then a doji gapped above its high, then a bearish candle gapped below the doji low
Calculation: Two white gapping = two bullish candles, with the first gapped above the high two bars earlier and the current low above the prior low
Calculation: Two black gapping = two bearish candles, with the first gapped below the low two bars earlier and the current high below the prior high
Calculation: Bullish mat hold = bullish candle four bars earlier with body > 1.2 × average body; the next three bodies each < 0.6 × that body and their ranges lie inside its range; current bullish candle closes above its high with body > average body
Calculation: Bearish mat hold = bearish candle four bars earlier with body > 1.2 × average body; the next three bodies each < 0.6 × that body and their ranges lie inside its range; current bearish candle closes below its low with body > average body
Calculation: Black paper umbrella = bearish candle with body > 0, lower wick ≥ a multiple of body, and upper wick ≤ a smaller multiple of body
Calculation: ATR = average true range
Calculation: Higher-timeframe trend = last completed higher-timeframe close above its EMA for bullish trend, below its EMA for bearish trend; EMA slope must agree (bullish: current EMA ≥ previous EMA; bearish: current EMA ≤ previous EMA). EMA lookback is longer than the pattern lookbacks.
Calculation: Volume profile = developing session profile: divide the range centered on session open, with half-span scaled by daily ATR, into equal price bins; allocate each chart bar's volume equally across bins it spans. POC is the fullest bin; value area expands from POC toward the fuller adjacent bin until it contains 70% of volume. HVN/LVN means current-close bin volume above/below a multiple of mean nonempty-bin volume. Previous-session POC is naked until touched.
Calculation: Profile reversal location, bullish = close near/below value area low OR near untouched prior POC OR swept low OR HVN at/below POC; bearish = close near/above value area high OR near untouched prior POC OR swept high OR HVN at/above POC. Near means within an ATR-scaled tolerance.
Calculation: Profile continuation location, bullish = LVN OR close above value area high, excluding HVN below value area high; bearish = LVN OR close below value area low, excluding HVN above value area low
Calculation: Volume spike = volume > a multiple of 20-bar average volume
Calculation: Delta = sum over confirmed lower-timeframe bars of volume signed positive when close > open and negative when close < open; if unavailable, use volume × ((close − low) − (high − close)) / (high − low), or zero when high = low
Calculation: Cumulative delta = running sum of delta reset each session
Calculation: Bullish order-flow confirmation = delta > 0 OR current low ≤ the lowest low over a lookback and cumulative delta > its value that many bars earlier
Calculation: Bearish order-flow confirmation = delta < 0 OR current high ≥ the highest high over a lookback and cumulative delta < its value that many bars earlier
Calculation: Swept low = low below latest confirmed pivot low AND close above it AND volume spike; swept high = high above latest confirmed pivot high AND close below it AND volume spike
Long: bullish hammer OR inverted hammer OR bullish engulfing OR morning star OR piercing pattern OR bullish harami (current close > prior high) OR rising window OR bullish marubozu OR three white soldiers OR bullish three-line strike OR bullish abandoned baby OR two white gapping OR bullish mat hold OR black paper umbrella; AND higher-timeframe trend bullish AND (bullish profile reversal location for reversal patterns, profile continuation location for continuation patterns, or prior bar at POC/HVN for harami) AND (bullish order-flow confirmation for reversal patterns and harami; delta > 0 for continuation patterns; or delta > 0 AND volume spike for marubozu)
Short: shooting star OR bearish engulfing OR evening star OR dark cloud cover OR bearish harami (current close < prior low) OR falling window OR bearish marubozu OR three black crows OR bearish three-line strike OR bearish abandoned baby OR two black gapping OR bearish mat hold; AND higher-timeframe trend bearish AND (bearish profile reversal location for reversal patterns, profile continuation location for continuation patterns, or prior bar at POC/HVN for harami) AND (bearish order-flow confirmation for reversal patterns and harami; delta < 0 for continuation patterns; or delta < 0 AND volume spike for marubozu)