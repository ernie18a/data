Calculation: first-hour high = high of the T1 bar that ends at first-hour close time
Calculation: first-hour low = low of the T1 bar that ends at first-hour close time
Calculation: straddle = (ceiling(first-hour high / step) * step + floor(first-hour low / step) * step) / 2, where step = NIFTY strike step if underlying is NIFTY, BANKNIFTY strike step if underlying is BANKNIFTY
Option: sell call, time is from first-hour close time to window end time AND absolute(underlying price - straddle) <= proximity
Option: sell put, time is from first-hour close time to window end time AND absolute(underlying price - straddle) <= proximity
Option: sell call, time is from first-hour close time to window end time AND absolute(underlying price - straddle) <= proximity AND first-hour high - first-hour low >= range threshold
Option: sell put, time is from first-hour close time to window end time AND absolute(underlying price - straddle) <= proximity AND first-hour high - first-hour low >= range threshold