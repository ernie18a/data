Calculation: Bull zone = [lowest low in the current and prior reaction-length chart bars, high on the bar of that low] (bottom, top)
Calculation: Bear zone = [low on the bar of the highest high in the current and prior reaction-length chart bars, highest high in those bars] (bottom, top)
Calculation: Bull liquidity sweep = bull zone bottom < lowest(low, structure lookback) from reaction-length-plus-one chart bars ago
Calculation: Bear liquidity sweep = bear zone top > highest(high, structure lookback) from reaction-length-plus-one chart bars ago
Calculation: Bull FVG = low > high[FVG lag A] OR low[FVG lag B] > high[FVG lag C]
Calculation: Bear FVG = high < low[FVG lag A] OR high[FVG lag B] < low[FVG lag C]
Calculation: Bull OTE = midpoint(bull zone bottom, bull zone top) <= midpoint(bull zone bottom, current high)
Calculation: Bear OTE = midpoint(bear zone bottom, bear zone top) >= midpoint(current low, bear zone top)
Calculation: Bull HTF alignment = chart-bar close > EMA(close, EMA lookback, T1, still-forming T1 bar), sampled on chart bars
Calculation: Bear HTF alignment = chart-bar close < EMA(close, EMA lookback, T1, still-forming T1 bar), sampled on chart bars
Calculation: Bull confluence score = count of true conditions among bull liquidity sweep, bull FVG, bull OTE, and bull HTF alignment
Calculation: Bear confluence score = count of true conditions among bear liquidity sweep, bear FVG, bear OTE, and bear HTF alignment
Long: close crosses above the prior chart bar's highest high over structure lookback AND (sweep filter off OR bull liquidity sweep) AND (FVG filter off OR bull FVG) AND (OTE filter off OR bull OTE) AND (HTF filter off OR bull HTF alignment) AND bull confluence score >= minimum confluence score AND (cooldown disabled OR no earlier bull zone OR chart bars since last accepted bull zone >= same-side cooldown)
Short: close crosses below the prior chart bar's lowest low over structure lookback AND (sweep filter off OR bear liquidity sweep) AND (FVG filter off OR bear FVG) AND (OTE filter off OR bear OTE) AND (HTF filter off OR bear HTF alignment) AND bear confluence score >= minimum confluence score AND (cooldown disabled OR no earlier bear zone OR chart bars since last accepted bear zone >= same-side cooldown)
Long: a bull zone created before the current bar was not already invalidated or mitigated at the start of this bar AND low <= its top AND high >= its bottom
Short: a bear zone created before the current bar was not already invalidated or mitigated at the start of this bar AND low <= its top AND high >= its bottom