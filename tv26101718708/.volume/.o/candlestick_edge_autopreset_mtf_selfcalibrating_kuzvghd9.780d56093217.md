Calculation: Body = abs(close - open)
Calculation: Upper wick = high - max(open, close)
Calculation: Lower wick = min(open, close) - low
Calculation: Average body = simple moving average of Body over a lookback
Calculation: Bullish engulfing = previous candle closes below its open AND current candle closes above its open AND current close >= previous open AND current open <= previous close
Calculation: Bearish engulfing = previous candle closes above its open AND current candle closes below its open AND current open >= previous close AND current close <= previous open
Calculation: Bullish harami = previous candle closes below its open AND current body lies strictly inside previous body AND current Body < previous Body
Calculation: Bearish harami = previous candle closes above its open AND current body lies strictly inside previous body AND current Body < previous Body
Calculation: Hammer = Body > 0 AND Lower wick >= a multiple of Body AND Upper wick <= a multiple of Body
Calculation: Shooting star = Body > 0 AND Upper wick >= a multiple of Body AND Lower wick <= a multiple of Body
Calculation: Inverted hammer = same geometry as shooting star
Calculation: Black paper umbrella = current close < current open AND Body > 0 AND Lower wick >= a multiple of Body AND Upper wick <= a multiple of Body
Calculation: Bullish marubozu = close > open AND both wicks <= a fraction of Body AND Body > Average body
Calculation: Bearish marubozu = open > close AND both wicks <= a fraction of Body AND Body > Average body
Calculation: Morning star = candle two bars ago closes below its open AND its Body > Average body AND prior Body < a fraction of that Body AND current close > current open AND current close > midpoint of candle two bars ago
Calculation: Evening star = candle two bars ago closes above its open AND its Body > Average body AND prior Body < a fraction of that Body AND current close < current open AND current close < midpoint of candle two bars ago
Calculation: Piercing pattern = previous candle closes below its open AND current open < previous close AND current close > midpoint of previous candle AND current close < previous open
Calculation: Dark cloud pattern = previous candle closes above its open AND current open > previous close AND current close < midpoint of previous candle AND current close > previous open
Calculation: Rising window = current low > previous high
Calculation: Falling window = current high < previous low
Calculation: Three white soldiers = three consecutive up candles with strictly rising closes, each open within the preceding body, and current Body > a fraction of Average body
Calculation: Three black crows = three consecutive down candles with strictly falling closes, each open within the preceding body, and current Body > a fraction of Average body
Calculation: Bullish three-line strike = three declining down candles followed by an up candle whose open < previous close and close > the first candle's open
Calculation: Bearish three-line strike = three rising up candles followed by a down candle whose open > previous close and close < the first candle's open
Calculation: Bullish abandoned baby = candle two bars ago is down, previous candle Body <= a fraction of its range and is gapped below the candle two bars ago, and current low > previous high with current close > current open
Calculation: Bearish abandoned baby = candle two bars ago is up, previous candle Body <= a fraction of its range and is gapped above the candle two bars ago, and current high < previous low with current close < current open
Calculation: Two white gapping = candle two bars ago is followed by two up candles, the first with low > the earlier high and the current low > the previous low
Calculation: Two black gapping = candle two bars ago is followed by two down candles, the first with high < the earlier low and the current high < the previous high
Calculation: Bullish mat hold = candle four bars ago is up with Body > a multiple of Average body; the three following candles have bodies < a fraction of its Body and ranges inside its range; the last pullback close < its close; current candle is up, closes above its high, and Body > Average body
Calculation: Bearish mat hold = candle four bars ago is down with Body > a multiple of Average body; the three following candles have bodies < a fraction of its Body and ranges inside its range; the last pullback close > its close; current candle is down, closes below its low, and Body > Average body
Calculation: Developing session volume profile = reset bins each day; initialize the profile range around the first bar's open using a multiple of last completed daily ATR and divide it into equal bins; allocate each confirmed bar's volume evenly among bins intersecting its high-low range. POC is the highest-volume bin midpoint; VAH and VAL bound the contiguous expansion from POC toward the higher-volume adjacent bin until 70% of profile volume is included. HVN means current-close bin volume > a multiple of mean nonempty-bin volume; LVN means it is < a fraction of that mean.
Calculation: Prior session POC = previous session's developing profile POC; mark touched after any bar's range crosses it
Calculation: Bullish location = close near VAL OR close below VAL OR close near an untouched prior session POC OR a bullish liquidity sweep OR (HVN AND close <= POC)
Calculation: Bearish location = close near VAH OR close above VAH OR close near an untouched prior session POC OR a bearish liquidity sweep OR (HVN AND close >= POC)
Calculation: Bullish continuation location = (LVN OR close above VAH) AND NOT (HVN AND close < VAH)
Calculation: Bearish continuation location = (LVN OR close below VAL) AND NOT (HVN AND close > VAL)
Calculation: Bullish liquidity sweep = current low < last confirmed pivot low AND current close > that pivot low AND volume > a multiple of its 20-bar simple moving average
Calculation: Bearish liquidity sweep = current high > last confirmed pivot high AND current close < that pivot high AND volume > a multiple of its 20-bar simple moving average
Calculation: Delta = sum of lower-timeframe candle volume signed positive when its close > open and negative when its close < open; if unavailable, use volume times close-location value ((close-low)-(high-close))/(high-low), or zero when high=low
Calculation: Cumulative delta = daily-reset cumulative sum of Delta
Calculation: Bullish delta confirmation = Delta > 0 OR (current low <= its lookback-period lowest low AND current cumulative delta > cumulative delta at the start of that lookback)
Calculation: Bearish delta confirmation = Delta < 0 OR (current high >= its lookback-period highest high AND current cumulative delta < cumulative delta at the start of that lookback)
Calculation: Higher-timeframe bullish trend = last completed higher-timeframe close > its EMA AND (EMA slope filter disabled OR EMA >= its previous value)
Calculation: Higher-timeframe bearish trend = last completed higher-timeframe close < its EMA AND (EMA slope filter disabled OR EMA <= its previous value)
Calculation: Panic regime = current ATR percentile rank over a lookback >= a threshold; calm regime = NOT panic regime
Long: (Hammer OR Bullish engulfing OR Morning star OR Piercing pattern OR Bullish harami with close > previous high OR Three white soldiers OR Bullish three-line strike OR Bullish abandoned baby OR Black paper umbrella OR Inverted hammer) AND Higher-timeframe bullish trend AND Bullish location AND Bullish delta confirmation AND selected regime permits current regime
Long: (Rising window OR Bullish marubozu OR Two white gapping OR Bullish mat hold) AND Higher-timeframe bullish trend AND Bullish continuation location AND Delta > 0 AND selected regime permits current regime; for Bullish marubozu also require volume > a multiple of its 20-bar simple moving average
Short: (Shooting star OR Bearish engulfing OR Evening star OR Dark cloud pattern OR Three black crows OR Bearish three-line strike OR Bearish abandoned baby) AND Higher-timeframe bearish trend AND Bearish location AND Bearish delta confirmation AND selected regime permits current regime
Short: (Bearish harami with close < previous low OR Falling window OR Bearish marubozu OR Two black gapping OR Bearish mat hold) AND Higher-timeframe bearish trend AND Bearish continuation location AND Delta < 0 AND selected regime permits current regime; for Bearish marubozu also require volume > a multiple of its 20-bar simple moving average