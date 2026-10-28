Calculation: Confirmed pivot high/low = a high/low with the configured number of bars on both sides; use the latest confirmed pivot.
Calculation: Bullish FVG = current low > high two bars earlier by at least the configured minimum gap; bearish FVG = current high < low two bars earlier by at least the configured minimum gap.
Calculation: Bullish inverted FVG = an un-inverted bearish FVG whose close exceeds its upper boundary; bearish inverted FVG = an un-inverted bullish FVG whose close falls below its lower boundary. An inverted zone remains active until price crosses its opposite boundary.
Calculation: Bullish liquidity sweep = low below the latest confirmed pivot low, close above it, and lower wick greater than the configured fraction of the bar's range; bearish liquidity sweep = high above the latest confirmed pivot high, close below it, and upper wick greater than that fraction.
Calculation: Bullish SMT = the instrument makes a lower confirmed pivot low while either configured correlated instrument makes a higher low at the same pivot; bearish SMT = the instrument makes a higher confirmed pivot high while either correlated instrument makes a lower high. Compare successive pivots of the same kind; use same-timeframe bars without lookahead.
Calculation: Bullish CISD = two or three consecutive rising closes; bearish CISD = two or three consecutive falling closes. Emit only when direction differs from the previous CISD and the configured minimum bar spacing has elapsed.
Calculation: Bullish CHoCH = close above the latest confirmed pivot high when trend direction is not already bullish; bearish CHoCH = close below the latest confirmed pivot low when trend direction is not already bearish. Set trend direction to the triggered direction.
Calculation: Displacement = absolute body size > ATR(14) × configured multiplier; directional displacement also requires body direction to match the signal.
Calculation: In a bullish/bearish FVG or inverted FVG = current bar's range overlaps an active zone.
Calculation: Bullish/bearish order block marking = close above prior high / below prior low and bullish / bearish body size > ATR(14).
Calculation: Bullish/bearish confluence = confirmed bullish/bearish sweep or inverted-FVG trigger, plus one point each for a same-direction SMT within the configured recent-bar window, same-direction CHoCH or trend, overlap with a same-direction FVG or inverted FVG, and same-direction CISD. A trigger contributes one point.
Long: Bullish liquidity sweep and bullish candle and displacement.
Long: Bullish inverted FVG overlap and bullish candle and displacement.
Long: Bullish SMT.
Long: Bullish CISD.
Long: Bullish CHoCH.
Long: Bullish FVG created.
Long: Bearish FVG becomes bullish inverted FVG.
Long: Bullish order block marking.
Long: Low below latest confirmed pivot low.
Long: Active trading session and ATR(14) > ATR(50) × configured chop threshold and cooldown elapsed since the prior long setup and confirmed bullish trigger and bullish confluence >= configured minimum for B setups and bullish confluence < configured minimum for A++ setups.
Long: Active trading session and ATR(14) > ATR(50) × configured chop threshold and cooldown elapsed since the prior long setup and confirmed bullish trigger and bullish confluence >= configured minimum for A++ setups.
Long: Active trading session and ATR(14) > ATR(50) × configured chop threshold and cooldown elapsed since the prior early long marking and (low below latest confirmed pivot low or overlap with bullish inverted FVG or bullish SMT).
Short: Bearish liquidity sweep and bearish candle and displacement.
Short: Bearish inverted FVG overlap and bearish candle and displacement.
Short: Bearish SMT.
Short: Bearish CISD.
Short: Bearish CHoCH.
Short: Bearish FVG created.
Short: Bullish FVG becomes bearish inverted FVG.
Short: Bearish order block marking.
Short: High above latest confirmed pivot high.
Short: Active trading session and ATR(14) > ATR(50) × configured chop threshold and cooldown elapsed since the prior short setup and confirmed bearish trigger and bearish confluence >= configured minimum for B setups and bearish confluence < configured minimum for A++ setups.
Short: Active trading session and ATR(14) > ATR(50) × configured chop threshold and cooldown elapsed since the prior short setup and confirmed bearish trigger and bearish confluence >= configured minimum for A++ setups.
Short: Active trading session and ATR(14) > ATR(50) × configured chop threshold and cooldown elapsed since the prior early short marking and (high above latest confirmed pivot high or overlap with bearish inverted FVG or bearish SMT).