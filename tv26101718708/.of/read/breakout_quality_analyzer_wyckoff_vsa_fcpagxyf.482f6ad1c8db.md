Calculation: Average volume = simple moving average of volume over a configurable lookback; long-term and short-term averages use longer and shorter lookbacks respectively
Calculation: Average spread = simple moving average of high minus low over the long-term lookback
Calculation: Close position = (close - low) / (high - low), or 0.5 when high equals low
Calculation: Breakout level = highest high of the prior breakout-lookback bars, excluding the current bar
Calculation: Breakout = close > breakout level AND prior close <= breakout level AND volume > average volume × minimum breakout-volume multiple
Calculation: Breakout quality score = sum of: effort-result score (spread / average spread ÷ (volume / average volume): 3 if >1.2, 2 if >0.9, 1 if >0.6, else 0); close-position score (3 if >0.75, 2 if >0.60, 1 if >0.40, else 0); absorption score (one point each if prior-window average volume / long-term average volume <0.85, prior-window average spread / long-term average spread <0.85, and up-days with above-average volume outnumber down-days with above-average volume); volume-change score (breakout volume / prior-window average volume: 3 if >2.5, 2 if >1.8, 1 if >1.3, else 0); volume-rank score (2 if current volume is at least the highest in the breakout lookback, else 1 if greater than the prior 10-bar highest volume, else 0); spread score (spread / average spread: 2 if >1.5, 1 if >1, else 0); CVD score (2 if CVD and price both rose over the configurable short lookback, 0 if CVD fell while price rose, else 1, plus 1 if CVD rose over the five prior bars while price was flat or fell); hidden-flow score (3 if close position >0.65, 2 if >0.55, 1 if >0.45, else 0); and VSA score (2 for No Supply, plus 3 for Shakeout, minus 2 for No Demand, minus 3 for Upthrust; floor at -5). CVD is cumulative volume × ((close - low) - (high - close)) / (high - low), using half volume for each side when range is zero. Clamp total score to at least zero.
Calculation: Volume delta = volume × (2 × close position - 1), using zero when range is zero; cumulative volume delta = running sum of volume delta
Calculation: True range average = average true range over a configurable lookback
Calculation: Gap-aware VSA spread = high - low + abs(open - prior close); gap-aware close position = (close - min(low, prior close)) / (max(high, prior close) - min(low, prior close)), or ordinary close position if the denominator is zero
Calculation: Bar volume ratio = volume / average volume; spread-to-ATR ratio = high-low / true range average
Calculation: Prior support and resistance = lowest low and highest high over the prior support/resistance lookback bars, excluding the current bar
Calculation: Buying Climax context = any of the prior weakness-lookback bars is an up bar with volume > 2 × its average volume, spread / its ATR >1.2, and close position <0.40
Calculation: End-of-Rising context = any of the prior weakness-lookback bars is an up bar with volume >1.5 × its average volume, spread smaller than the preceding bar's spread, and close position <0.50
Calculation: No Supply = down bar AND bar volume ratio < low-volume threshold AND spread-to-ATR ratio < narrow-spread threshold AND close position >= close-high threshold
Calculation: Shakeout = low < prior support AND close > prior support AND bar volume ratio > high-volume threshold AND close position >= close-high threshold AND spread-to-ATR ratio > wide-spread threshold
Calculation: No Demand = close >= open AND bar volume ratio < low-volume threshold AND spread-to-ATR ratio < narrow-spread threshold AND close position <= close-low threshold AND (Buying Climax context OR End-of-Rising context)
Calculation: Upthrust = high > prior resistance AND close < prior resistance AND close position <= close-low threshold AND spread-to-ATR ratio > wide-spread threshold
Calculation: Hidden Buy = close < open AND close position > hidden-buy threshold
Calculation: Hidden Sell = close > open AND close position < hidden-sell threshold
Calculation: Selling Climax = down bar AND volume >1.3 × average volume AND gap-aware spread / ATR >0.9 AND gap-aware close position >0.55
Calculation: Stopping Volume = three consecutive down bars AND their spreads decrease successively AND their volumes increase successively AND current gap-aware close position >0.40 AND no Selling Climax on current bar
Calculation: Bottom Reversal = down bar AND volume >1.1 × average volume AND gap-aware close position >0.60 AND no Selling Climax or Stopping Volume on current bar
Calculation: Prior Flush = prior bar is down AND prior volume >1.3 × its average volume AND prior close position >0.40
Calculation: Bag Holding = close >= open AND volume >1.2 × average volume AND gap-aware close position >0.60 AND Prior Flush
Calculation: Supply Absorption = close >= open AND volume >1.3 × average volume AND gap-aware spread / ATR <1.1 AND gap-aware close position between 0.30 and 0.80 inclusive
Calculation: Buying Climax = close >= open AND volume >1.3 × average volume AND gap-aware spread / ATR >0.9 AND gap-aware close position <0.45
Calculation: End of Rising = close >= open AND volume >1.3 × average volume AND gap-aware spread is less than the prior bar's gap-aware spread AND gap-aware close position <0.50 AND no Buying Climax on current bar
Calculation: Top Reversal = close >= open AND volume >1.1 × average volume AND gap-aware close position <0.40 AND no Buying Climax or End of Rising on current bar
Calculation: Supply over Demand = down bar AND volume >1.1 × prior volume AND prior bar is up or unchanged AND gap-aware close position <0.40
Calculation: Demand Absorption = down bar AND volume >1.3 × average volume AND gap-aware spread / ATR <1.1 AND gap-aware close position between 0.20 and 0.70 inclusive
Calculation: Recent bullish VSA = any of Selling Climax, Stopping Volume, Bottom Reversal, Bag Holding, Supply Absorption, No Supply, or Shakeout occurred within the last five bars, including the current bar
Calculation: Recent bearish VSA = any of Buying Climax, End of Rising, Top Reversal, Supply over Demand, Demand Absorption, Upthrust, or No Demand occurred within the last five bars, including the current bar
Calculation: Bull bias = Recent bullish VSA AND NOT Recent bearish VSA; bear bias = Recent bearish VSA AND NOT Recent bullish VSA
Calculation: Follow-through score = count of these true conditions: close > breakout level, volume >0.8 × average volume, close position >0.50
Long: Breakout AND breakout quality score / 28 >= 0.50
Long: No Supply OR Shakeout OR Hidden Buy OR Selling Climax OR Stopping Volume OR Bottom Reversal OR Bag Holding OR Supply Absorption
Short: No Demand OR Upthrust OR Hidden Sell OR Buying Climax OR End of Rising OR Top Reversal OR Supply over Demand OR Demand Absorption
Exit: long, End of Rising occurred on a prior bar AND No Demand occurs now
Exit: long, bear bias now AND bull bias on the prior bar
Exit: long, within the configured follow-through period after a breakout AND follow-through score = 0