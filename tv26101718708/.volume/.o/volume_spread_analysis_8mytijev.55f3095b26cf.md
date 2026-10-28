Calculation: Bar spread = high − low
Calculation: Average spread = simple moving average of bar spread over a lookback
Calculation: Widerange bar = bar spread > 1.5 × average spread
Calculation: Narrowrange bar = bar spread < 0.7 × average spread
Calculation: Low volume = volume < prior-bar volume AND volume < volume two bars earlier
Calculation: High volume = volume > prior-bar volume AND prior-bar volume > volume two bars earlier
Calculation: Close position = (high − low) / (close − low); when close = low, use average spread
Calculation: Very high close = close position < 1.35
Calculation: Up close = close ≥ low + 0.7 × bar spread
Calculation: Down close = close ≤ low + 0.3 × bar spread
Calculation: Mid close = close > low + 0.3 × bar spread AND close < low + 0.7 × bar spread
Calculation: Close category = 1 if close ≤ low + 0.2 × bar spread; else 2 if close ≤ low + 0.4 × bar spread; else 3 if close ≤ low + 0.6 × bar spread; else 4 if close ≤ low + 0.8 × bar spread; else 5
Calculation: Volume category = 1 if volume > 2 × average volume; else 2 if volume > 1.3 × average volume; else 3 if volume > average volume; else 4 if volume > 0.7 × average volume; else 5. Average volume is the simple moving average of volume over a lookback.
Calculation: Short-term upward strength = maximum of (current high − low from each of two short lookbacks ago) / (ATR over that lookback × square root of that lookback); the short lookbacks have a shorter range than the long-term lookbacks
Calculation: Short-term downward strength = maximum of (high from each of two short lookbacks ago − current low) / (ATR over that lookback × square root of that lookback)
Calculation: Long-term upward strength = maximum of (current high − low from each of two long lookbacks ago) / (ATR over that lookback × square root of that lookback); the long lookbacks are longer than the short-term lookbacks
Calculation: Long-term downward strength = maximum of (high from each of two long lookbacks ago − current low) / (ATR over that lookback × square root of that lookback)
Calculation: Major trend measure = long-term upward strength − long-term downward strength
Calculation: Minor upward trend = 1 if long-term upward strength > 1, else −1
Calculation: Upward minor trend measure = short-term upward strength − short-term downward strength
Calculation: Upward minor trend state = 1 if upward minor trend measure > 1, else −1
Calculation: Upward trend state = 1 if short-term upward strength > 1, else 0
Calculation: Reversal upthrust = major trend measure < −1 AND close > prior close AND up close AND volume > prior-bar volume AND volume > average volume AND widerange bar AND prior bar closed below its 30% level AND minor trend < 0
Calculation: Low-volume test = current low equals the lowest low over a lookback AND up close AND low volume
Calculation: Upthrust bar = widerange bar AND close category is 1 or 2 AND minor trend > 0 AND high > prior high AND (upward trend state > 0 OR major trend state > 0) AND volume category < 4; major trend state is 1 if major trend measure > 1, −1 if it is < −1, else 0
Calculation: True upthrust bar = widerange bar AND close category = 1 AND major trend measure > 1 AND high > prior high AND volume category < 4
Calculation: Trend change = prior bar closed above its prior close AND current high equals the highest high over a lookback AND current close < prior close AND (down close OR mid close) AND volume > average volume AND major trend measure > 1 AND upward trend state > 0 AND not widerange bar AND not reversal upthrust
Calculation: Effort up = high > prior high AND low > prior low AND close > prior close AND close ≥ low + 0.7 × bar spread AND bar spread > average spread AND volume category < 4
Calculation: Effort up failure = prior bar was effort up AND (upthrust bar OR prior-bar upthrust confirmation OR current upthrust confirmation OR current volume category = 1 OR (close < prior close AND bar spread > average spread))
Calculation: Effort down = high < prior high AND low < prior low AND close < prior close AND close ≤ low + 0.25 × bar spread AND widerange bar AND volume > prior-bar volume
Calculation: Effort down failure = prior bar was effort down AND ((close > prior close AND bar spread > average spread) OR reversal upthrust OR strength after downtrend)
Calculation: Strength after downtrend = volume category < 4 AND prior bar closed below its prior close AND close > prior close AND close category > 3 AND upward trend state ≤ 0 AND minor trend < 0
Calculation: Long-entry test confirmation = prior bar was a low-volume test AND close > prior close AND up close
Long: (close > prior close AND prior bar was reversal upthrust) OR long-entry test confirmation OR reversal upthrust OR low-volume test OR effort up OR effort down failure
Short: upthrust bar OR true upthrust bar OR trend change OR effort up failure OR effort down
Exit: long, true upthrust bar