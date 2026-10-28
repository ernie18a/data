Calculation: Volume average = moving average of volume over a configurable lookback; longer lookback for the baseline and shorter lookback for the pre-breakout window
Calculation: Average spread = moving average of high − low over the volume-average lookback
Calculation: Close position = (close − low) / (high − low); use 0.5 if the spread is zero
Calculation: True range average = average true range over a configurable lookback
Calculation: Breakout level = highest high over the breakout lookback, excluding the current bar
Calculation: Cumulative volume delta = cumulative sum of volume × (2 × close − high − low) / (high − low); use zero delta if the spread is zero
Calculation: Dollar-volume buy ratio = (close − low) / (high − low); use 0.5 if the spread is zero
Calculation: Effort/result score = score the current bar’s spread divided by average spread, then divided by current volume divided by volume average; higher ratios score more, using configurable thresholds
Calculation: Close-position score = score close position; higher positions score more, using configurable thresholds
Calculation: Pre-breakout absorption score = count of: prior-window average volume below the baseline average times a configurable factor; prior-window average spread below baseline average spread times a configurable factor; up-closes on above-average volume outnumber down-closes on above-average volume in the prior window
Calculation: Volume-character score = score current volume divided by average volume in the prior pre-breakout window; higher ratios score more, using configurable thresholds
Calculation: Volume-rank score = highest current volume in the breakout lookback scores more than volume exceeding the prior shorter-window maximum; otherwise zero
Calculation: Spread-quality score = score current spread divided by average spread; higher ratios score more, using configurable thresholds
Calculation: CVD score = rising cumulative volume delta and rising close over the configurable slope lookback scores more; falling delta and rising close scores zero; otherwise score neutral. Add a bonus when delta rose over the pre-breakout window while close was flat or lower
Calculation: Hidden-signal score = score the dollar-volume buy ratio; higher ratios score more, using configurable thresholds
Calculation: No Supply = close < open AND volume / volume average is below the low-volume threshold AND current spread / true range average is below the narrow-spread threshold AND close position is above the near-high threshold
Calculation: Shakeout = low < prior-window lowest low AND close > that low AND volume / volume average is above the high-volume threshold AND current spread / true range average is above the wide-spread threshold AND close position is above the near-high threshold
Calculation: Buying Climax = prior bar is an up bar AND its volume exceeds its volume average by the configured climax multiplier AND its spread / true range average exceeds the configured wide-spread threshold AND its close position is below the configured low-close threshold
Calculation: End of Rising = prior bar is an up bar AND its volume exceeds its volume average by the configured weakness multiplier AND its spread is narrower than the preceding bar’s spread AND its close position is below the configured low-close threshold
Calculation: No Demand = close >= open AND volume / volume average is below the low-volume threshold AND current spread / true range average is below the narrow-spread threshold AND close position is below the near-low threshold AND a Buying Climax or End of Rising occurred within the prior weakness lookback
Calculation: Upthrust = high > prior-window highest high AND close < that high AND close position is below the near-low threshold AND current spread / true range average is above the wide-spread threshold
Calculation: Tom Williams score = 2 × No Supply + 3 × Shakeout − 2 × No Demand − 3 × Upthrust, floored at −5
Calculation: Breakout quality score = sum of effort/result, close-position, pre-breakout absorption, volume-character, volume-rank, spread-quality, CVD, hidden-signal, and Tom Williams scores; floor at zero and divide by the maximum score
Calculation: Breakout bar = close > breakout level AND prior close <= breakout level AND current volume > volume average × minimum breakout-volume multiplier
Calculation: Follow-through score = count of: close > breakout level; volume > volume average × configurable fraction; close position > 0.5
Calculation: Bullish VSA mark = any of: Hidden Buy; No Supply; Shakeout; Selling Climax; Stopping Volume; Bottom Reversal; Bag Holding; Supply Absorption
Calculation: Hidden Buy = close < open AND dollar-volume buy ratio > hidden-buy threshold
Calculation: Hidden Sell = close > open AND dollar-volume buy ratio < hidden-sell threshold
Calculation: Selling Climax = close < open AND volume / volume average > configured threshold AND gap-aware spread / true range average > configured threshold AND gap-aware close position > configured threshold
Calculation: Stopping Volume = three consecutive down bars with successively smaller high-low spreads and successively larger volume, and current gap-aware close position > configured threshold, unless Selling Climax
Calculation: Bottom Reversal = close < open AND volume / volume average > configured threshold AND gap-aware close position > configured threshold, unless Selling Climax or Stopping Volume
Calculation: Bag Holding = close >= open AND volume / volume average > configured threshold AND gap-aware close position > configured threshold AND prior bar is a down bar with above-average volume and close position > configured threshold
Calculation: Supply Absorption = close >= open AND volume / volume average > configured threshold AND gap-aware spread / true range average < configured threshold AND gap-aware close position is within its configured bounds
Calculation: Bearish VSA mark = any of: Hidden Sell; Buying Climax; End of Rising; Top Reversal; Supply over Demand; Demand Absorption; No Demand; Upthrust
Calculation: Top Reversal = close >= open AND volume / volume average > configured threshold AND gap-aware close position < configured threshold, unless Buying Climax or End of Rising
Calculation: Supply over Demand = close < open AND volume > prior volume × configured multiplier AND prior bar is an up bar AND gap-aware close position < configured threshold
Calculation: Demand Absorption = close < open AND volume / volume average > configured threshold AND gap-aware spread / true range average < configured threshold AND gap-aware close position is within its configured bounds
Long: Breakout bar AND breakout quality score meets the likely-accumulation threshold AND NOT Upthrust
Long: Bullish VSA mark
Short: Bearish VSA mark
Exit: Long, current bar is a Buying Climax
Exit: Long, current bar is No Demand AND End of Rising occurred within the prior weakness lookback
Exit: Long, a bullish VSA mark was the most recent VSA mark within the recent-signal window and a bearish VSA mark is now the most recent within that window
Exit: Long, within the follow-through window after a breakout, follow-through score = 0