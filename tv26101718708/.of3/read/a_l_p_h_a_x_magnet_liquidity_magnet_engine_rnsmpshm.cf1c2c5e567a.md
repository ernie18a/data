Calculation: pool tolerance = pool tolerance multiplier × ATR(ATR lookback)
Calculation: SSL pivot pool = level of the running cluster of confirmed pivot lows, where a new pivot low p (lowest low among pivot length bars on each side, known pivot length bars later) joins the cluster if |p − cluster level| ≤ pivot merge multiplier × pool tolerance (cluster level becomes the mean of its members, touches + 1), and otherwise, or when no cluster exists, starts a new cluster (level p, touches 1, start at p's bar); the level if touches ≥ min pivot touches AND bars since cluster start ≥ min pool age, else na
Calculation: SSL EQ level = L if at least min EQ touches of the last EQ lookback bars have |low − L| ≤ pool tolerance, else na, where L = lowest(low, EQ lookback)
Calculation: SSL pool = the nearer to close of SSL pivot pool and SSL EQ level, considering only levels below close (na if neither)
Calculation: BSL pivot pool = level of the running cluster of confirmed pivot highs, where a new pivot high p (highest high among pivot length bars on each side, known pivot length bars later) joins the cluster if |p − cluster level| ≤ pivot merge multiplier × pool tolerance (cluster level becomes the mean of its members, touches + 1), and otherwise, or when no cluster exists, starts a new cluster (level p, touches 1, start at p's bar); the level if touches ≥ min pivot touches AND bars since cluster start ≥ min pool age, else na
Calculation: BSL EQ level = H if at least min EQ touches of the last EQ lookback bars have |high − H| ≤ pool tolerance, else na, where H = highest(high, EQ lookback)
Calculation: BSL pool = the nearer to close of BSL pivot pool and BSL EQ level, considering only levels above close (na if neither)
Calculation: SSL sweep = low < SSL pool − sweep depth multiplier × ATR(ATR lookback)
Calculation: BSL sweep = high > BSL pool + sweep depth multiplier × ATR(ATR lookback)
Calculation: bars since SSL sweep = bars since the most recent bar where SSL sweep holds (0 on that bar; infinite before any)
Calculation: bars since BSL sweep = bars since the most recent bar where BSL sweep holds (0 on that bar; infinite before any)
Calculation: SSL sweep level = SSL pool on the most recent bar where SSL sweep holds (na before any)
Calculation: BSL sweep level = BSL pool on the most recent bar where BSL sweep holds (na before any)
Calculation: bull trigger = close > open AND |close − open| ≥ min body multiplier × ATR(ATR lookback) AND (close − low)/(high − low) > trigger close fraction
Calculation: bear trigger = close < open AND |close − open| ≥ min body multiplier × ATR(ATR lookback) AND (high − close)/(high − low) > trigger close fraction
Calculation: bull cascade = close > open AND |close − open| > cascade body multiplier × ATR(ATR lookback) AND close > EMA(close, shorter EMA lookback) AND EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback)
Calculation: bear cascade = close < open AND |close − open| > cascade body multiplier × ATR(ATR lookback) AND close < EMA(close, shorter EMA lookback) AND EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback)
Calculation: at SSL zone = SSL pool exists AND low ≤ SSL pool + pool tolerance
Calculation: at BSL zone = BSL pool exists AND high ≥ BSL pool − pool tolerance
Calculation: volume spike = volume ≥ SMA(volume, volume average lookback) × volume multiplier
Calculation: HTF bull = EMA(close, shorter HTF EMA lookback, T1, last completed bar) > EMA(close, longer HTF EMA lookback, T1, last completed bar) AND close(T1, last completed bar) > EMA(close, shorter HTF EMA lookback, T1, last completed bar)
Calculation: HTF bear = EMA(close, shorter HTF EMA lookback, T1, last completed bar) < EMA(close, longer HTF EMA lookback, T1, last completed bar) AND close(T1, last completed bar) < EMA(close, shorter HTF EMA lookback, T1, last completed bar)
Calculation: chop ok = chop filter disabled OR Choppiness Index(chop lookback) < chop threshold
Calculation: long layer points = (SSL pool exists) + (HTF layer enabled AND HTF bull) + (volume layer disabled OR volume spike) + (close > EMA(close, shorter EMA lookback) OR RSI(close, RSI lookback) > structure long RSI level) + (RSI(close, RSI lookback) < exhaustion long RSI level AND bars since SSL sweep ≤ reclaim window) + (chop ok) + (at SSL zone)
Calculation: short layer points = (BSL pool exists) + (HTF layer enabled AND HTF bear) + (volume layer disabled OR volume spike) + (close < EMA(close, shorter EMA lookback) OR RSI(close, RSI lookback) < structure short RSI level) + (RSI(close, RSI lookback) > exhaustion short RSI level AND bars since BSL sweep ≤ reclaim window) + (chop ok) + (at BSL zone)
Calculation: entry gate = chop ok AND (session filter disabled OR bar time within session window) AND (no earlier entry signal OR bars since last long or short entry signal ≥ cooldown bars)
Calculation: long stop = min(low at entry, SSL sweep level at entry if one exists, else SSL pool at entry) − SL buffer multiplier × ATR(ATR lookback) at entry
Calculation: short stop = max(high at entry, BSL sweep level at entry if one exists, else BSL pool at entry) + SL buffer multiplier × ATR(ATR lookback) at entry
Calculation: long target = BSL pool at entry if TP at opposing magnet enabled AND BSL pool exists at entry, else entry price + reward multiple × (entry price − long stop)
Calculation: short target = SSL pool at entry if TP at opposing magnet enabled AND SSL pool exists at entry, else entry price − reward multiple × (short stop − entry price)
Long: long sweep setup enabled AND SSL sweep AND close > SSL pool AND bull trigger AND NOT bear cascade AND primary setup points + long layer points ≥ min confluence score AND entry gate
Long: long reclaim setup enabled AND 1 ≤ bars since SSL sweep ≤ reclaim window AND close > SSL sweep level AND low ≤ SSL sweep level + pool tolerance AND bull trigger AND primary setup points + long layer points ≥ min confluence score AND entry gate
Long: long absorption setup enabled AND at SSL zone AND (min(open, close) − low)/(high − low) > pin wick fraction AND |close − open|/(high − low) < pin body fraction AND close > open AND volume spike AND close > SSL pool AND secondary setup points + long layer points ≥ min confluence score AND entry gate
Long: long FVG setup enabled AND low > high[2] AND high[2] ≤ SSL pool + pool tolerance AND low ≥ SSL pool − pool tolerance AND bull trigger AND secondary setup points + long layer points ≥ min confluence score AND entry gate
Short: short sweep setup enabled AND BSL sweep AND close < BSL pool AND bear trigger AND NOT bull cascade AND primary setup points + short layer points ≥ min confluence score AND entry gate
Short: short reclaim setup enabled AND 1 ≤ bars since BSL sweep ≤ reclaim window AND close < BSL sweep level AND high ≥ BSL sweep level − pool tolerance AND bear trigger AND primary setup points + short layer points ≥ min confluence score AND entry gate
Short: short absorption setup enabled AND at BSL zone AND (high − max(open, close))/(high − low) > pin wick fraction AND |close − open|/(high − low) < pin body fraction AND close < open AND volume spike AND close < BSL pool AND secondary setup points + short layer points ≥ min confluence score AND entry gate
Short: short FVG setup enabled AND high < low[2] AND high ≤ BSL pool + pool tolerance AND low[2] ≥ BSL pool − pool tolerance AND bear trigger AND secondary setup points + short layer points ≥ min confluence score AND entry gate
Exit: long, low ≤ long stop OR high ≥ long target
Exit: short, high ≥ short stop OR low ≤ short target