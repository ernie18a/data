Calculation: Prior structure high/low = highest high / lowest low over the structure lookback, ending on the previous bar.
Calculation: Bullish zone bounds = high and low of the bar with the lowest low in the reaction-leg lookback, including the break bar.
Calculation: Bearish zone bounds = high and low of the bar with the highest high in the reaction-leg lookback, including the break bar.
Calculation: Bullish sweep = bullish zone low < the lowest low over the structure lookback shifted back by reaction-leg length + 1 bars.
Calculation: Bearish sweep = bearish zone high > the highest high over the structure lookback shifted back by reaction-leg length + 1 bars.
Calculation: Bullish FVG = current low > high 2 bars ago OR previous-bar low > high 3 bars ago.
Calculation: Bearish FVG = current high < low 2 bars ago OR previous-bar high < low 3 bars ago.
Calculation: Bullish OTE = bullish zone midpoint <= bullish equilibrium, where bullish equilibrium = bullish zone low + (current high − bullish zone low) / 2.
Calculation: Bearish OTE = bearish zone midpoint >= bearish equilibrium, where bearish equilibrium = bearish zone high − (bearish zone high − current low) / 2.
Calculation: Higher-timeframe EMA = 50-period EMA of close on a higher timeframe, using the bar still forming.
Calculation: Confluence score = count of true conditions among the side's sweep, FVG, OTE, and higher-timeframe alignment conditions; bullish alignment is chart close > higher-timeframe EMA, bearish alignment is chart close < higher-timeframe EMA.
Long: close crosses above prior structure high AND score >= minimum score AND (sweep filter disabled OR bullish sweep) AND (FVG filter disabled OR bullish FVG) AND (OTE filter disabled OR bullish OTE) AND (higher-timeframe filter disabled OR chart close > higher-timeframe EMA) AND (cooldown disabled OR bars since last bullish zone >= cooldown) OR low <= top of an existing, unmitigated, valid bullish zone AND high >= its bottom.
Short: close crosses below prior structure low AND score >= minimum score AND (sweep filter disabled OR bearish sweep) AND (FVG filter disabled OR bearish FVG) AND (OTE filter disabled OR bearish OTE) AND (higher-timeframe filter disabled OR chart close < higher-timeframe EMA) AND (cooldown disabled OR bars since last bearish zone >= cooldown) OR high >= bottom of an existing, unmitigated, valid bearish zone AND low <= its top.
Exit: long, close < bottom of an existing bullish zone.
Exit: short, close > top of an existing bearish zone.