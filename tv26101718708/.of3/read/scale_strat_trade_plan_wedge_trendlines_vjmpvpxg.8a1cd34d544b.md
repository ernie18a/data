Calculation: Candle body = abs(close - open)
Calculation: Upper wick = high - max(close, open)
Calculation: Lower wick = min(close, open) - low
Calculation: Doji = candle body <= (high - low) × doji-body fraction
Calculation: Hammer = lower wick >= candle body × dominant-wick/body ratio AND upper wick <= candle body
Calculation: Shooting-star candle = upper wick >= candle body × dominant-wick/body ratio AND lower wick <= candle body
Calculation: Bullish engulfing = close > open AND close[1] < open[1] AND close >= open[1] AND open <= close[1]
Calculation: Bearish engulfing = close < open AND close[1] > open[1] AND close <= open[1] AND open >= close[1]
Calculation: Upward 2 bar = high > high[1] AND low >= low[1]
Calculation: Downward 2 bar = low < low[1] AND high <= high[1]
Calculation: Inside bar = high <= high[1] AND low >= low[1]
Calculation: Outside bar = high > high[1] AND low < low[1]
Calculation: Bullish Strat reversal = current bar is an upward 2 bar AND (prior bar is a downward 2 bar OR (prior bar is an inside bar AND the bar two bars ago is a downward 2 bar OR an outside bar))
Calculation: Bearish Strat reversal = current bar is a downward 2 bar AND (prior bar is an upward 2 bar OR (prior bar is an inside bar AND the bar two bars ago is an upward 2 bar OR an outside bar))
Calculation: Latest confirmed swing high = most recent confirmed Pivot High(high, swing-strength lookback, swing-strength lookback), evaluated on chart bars
Calculation: Latest confirmed swing low = most recent confirmed Pivot Low(low, swing-strength lookback, swing-strength lookback), evaluated on chart bars
Calculation: Bullish break of structure = close > latest confirmed swing high AND close[1] <= that swing high
Calculation: Bearish break of structure = close < latest confirmed swing low AND close[1] >= that swing low
Calculation: Central pivot = (high + low + close) / 3 from the last completed T7 bar, with the value carried to chart bars
Calculation: First resistance pivot = twice the central pivot minus the last completed T7 low
Calculation: First support pivot = twice the central pivot minus the last completed T7 high
Calculation: Second resistance pivot = central pivot + (high - low) from the last completed T7 bar
Calculation: Second support pivot = central pivot - (high - low) from the last completed T7 bar
Calculation: Near support = chart close is within the level-proximity fraction of chart close from any of the first or second support pivots, latest confirmed swing low, last completed T2 low, or central pivot
Calculation: Near resistance = chart close is within the level-proximity fraction of chart close from any of the first or second resistance pivots, latest confirmed swing high, last completed T2 high, or central pivot
Calculation: Upward alignment = close > open on the current forming bars of T1, T2, and T3, calculated on each timeframe and carried to chart bars
Calculation: Downward alignment = close <= open on the current forming bars of T1, T2, and T3, calculated on each timeframe and carried to chart bars
Calculation: Momentum-up state at T = EMA(close, shorter momentum lookback, T, current forming bar) > EMA(close, longer momentum lookback, T, current forming bar), calculated on T bars and carried to chart bars
Calculation: Sniper-up state at T = EMA(close, shorter momentum lookback, T, current forming bar) > EMA(close, longer momentum lookback, T, current forming bar) OR close > EMA(close, longer momentum lookback, T, current forming bar), calculated on T bars and carried to chart bars
Calculation: Long setup score = one point for (near support OR near resistance), one for (doji OR hammer OR bullish engulfing), one for (upward alignment OR bullish Strat reversal OR hammer), one for (low < latest confirmed swing low AND close > that swing low OR bullish break of structure OR close inside the latest bullish fair-value gap, formed when low > high[2] with bounds high[2] to low), and one for (a shorter-over-longer EMA crossover on T1 within the recent-cross window measured in T1 bars OR (chart close > the current T1 longer EMA AND chart low <= that EMA × (1 + level-proximity fraction))); T1 EMA calculations use its current forming bar and are carried to chart bars
Calculation: Short setup score = one point for (near support OR near resistance), one for (doji OR shooting-star candle OR bearish engulfing), one for (downward alignment OR bearish Strat reversal OR shooting-star candle), one for (high > latest confirmed swing high AND close < that swing high OR bearish break of structure OR close inside the latest bearish fair-value gap, formed when high < low[2] with bounds high to low[2]), and one for (a longer-over-shorter EMA crossover on T1 within the recent-cross window measured in T1 bars OR (chart close < the current T1 longer EMA AND chart high >= that EMA × (1 - level-proximity fraction))); T1 EMA calculations use its current forming bar and are carried to chart bars
Calculation: Long common filter = (noise filter disabled OR (ATR(ATR lookback) / close <= maximum ATR-to-price fraction AND (volume filter disabled OR volume > SMA(volume, volume-average lookback)) AND close > open AND high - close <= (high - low) × maximum adverse-wick fraction AND close - open >= (high - low) × minimum body fraction)) AND (level-alignment filter disabled OR near support OR (bullish break of structure AND NOT near resistance))
Calculation: Short common filter = (noise filter disabled OR (ATR(ATR lookback) / close <= maximum ATR-to-price fraction AND (volume filter disabled OR volume > SMA(volume, volume-average lookback)) AND close < open AND close - low <= (high - low) × maximum adverse-wick fraction AND open - close >= (high - low) × minimum body fraction)) AND (level-alignment filter disabled OR near resistance OR (bearish break of structure AND NOT near support))
Calculation: Long entry filter = long common filter AND (sniper filter disabled OR sniper-up state at T4) AND (late-entry filter disabled OR hour(datetime in ET) < cutoff hour) AND high - low >= minimum reversal-size multiple × ATR(ATR lookback)
Calculation: Short entry filter = short common filter AND (sniper filter disabled OR NOT sniper-up state at T4) AND (late-entry filter disabled OR hour(datetime in ET) < cutoff hour) AND high - low >= minimum reversal-size multiple × ATR(ATR lookback)
Calculation: Qualifying long trigger = ((reversal-trigger mode AND bullish Strat reversal AND long setup score >= minimum score) OR (score-cross mode AND long setup score crosses up through minimum score)) AND long entry filter
Calculation: Qualifying short trigger = ((reversal-trigger mode AND bearish Strat reversal AND short setup score >= minimum score) OR (score-cross mode AND short setup score crosses up through minimum score)) AND short entry filter
Long: bullish Strat reversal
Short: bearish Strat reversal
Long: ((reversal-trigger mode AND bullish Strat reversal) OR (score-cross mode AND long setup score crosses up through minimum score)) AND long setup score >= watch score AND long setup score < minimum score AND long common filter
Short: ((reversal-trigger mode AND bearish Strat reversal) OR (score-cross mode AND short setup score crosses up through minimum score)) AND short setup score >= watch score AND short setup score < minimum score AND short common filter
Long: qualifying long trigger
Short: qualifying short trigger
Option: buy call, qualifying long trigger
Option: buy put, qualifying short trigger
Long: EMA(close, shorter chart/daily lookback) > EMA(close, longer chart/daily lookback) AND close > EMA(close, longer chart/daily lookback) on chart bars
Short: EMA(close, shorter chart/daily lookback) < EMA(close, longer chart/daily lookback) AND close < EMA(close, longer chart/daily lookback) on chart bars
Long: close > open on the current forming T1 bar, calculated on T1 bars and carried to chart bars
Short: close <= open on the current forming T1 bar, calculated on T1 bars and carried to chart bars
Long: close > open on the current forming T2 bar, calculated on T2 bars and carried to chart bars
Short: close <= open on the current forming T2 bar, calculated on T2 bars and carried to chart bars
Long: close > open on the current forming T3 bar, calculated on T3 bars and carried to chart bars
Short: close <= open on the current forming T3 bar, calculated on T3 bars and carried to chart bars
Long: close > open on the current forming T4 bar, calculated on T4 bars and carried to chart bars
Short: close <= open on the current forming T4 bar, calculated on T4 bars and carried to chart bars
Long: close > open on the current forming T5 bar, calculated on T5 bars and carried to chart bars
Short: close <= open on the current forming T5 bar, calculated on T5 bars and carried to chart bars
Long: close > open on the current forming T6 bar, calculated on T6 bars and carried to chart bars
Short: close <= open on the current forming T6 bar, calculated on T6 bars and carried to chart bars
Long: momentum-up state at T1
Short: EMA(close, shorter momentum lookback, T1, current forming bar) <= EMA(close, longer momentum lookback, T1, current forming bar), calculated on T1 bars and carried to chart bars
Long: momentum-up state at T2
Short: EMA(close, shorter momentum lookback, T2, current forming bar) <= EMA(close, longer momentum lookback, T2, current forming bar), calculated on T2 bars and carried to chart bars
Long: momentum-up state at T3
Short: EMA(close, shorter momentum lookback, T3, current forming bar) <= EMA(close, longer momentum lookback, T3, current forming bar), calculated on T3 bars and carried to chart bars
Long: momentum-up state at T4
Short: EMA(close, shorter momentum lookback, T4, current forming bar) <= EMA(close, longer momentum lookback, T4, current forming bar), calculated on T4 bars and carried to chart bars
Long: momentum-up state at T5
Short: EMA(close, shorter momentum lookback, T5, current forming bar) <= EMA(close, longer momentum lookback, T5, current forming bar), calculated on T5 bars and carried to chart bars
Long: momentum-up state at T6
Short: EMA(close, shorter momentum lookback, T6, current forming bar) <= EMA(close, longer momentum lookback, T6, current forming bar), calculated on T6 bars and carried to chart bars
Long: sniper-up state at T8
Short: EMA(close, shorter momentum lookback, T8, current forming bar) <= EMA(close, longer momentum lookback, T8, current forming bar) AND close <= EMA(close, longer momentum lookback, T8, current forming bar), calculated on T8 bars and carried to chart bars
Long: sniper-up state at T9
Short: EMA(close, shorter momentum lookback, T9, current forming bar) <= EMA(close, longer momentum lookback, T9, current forming bar) AND close <= EMA(close, longer momentum lookback, T9, current forming bar), calculated on T9 bars and carried to chart bars
Long: sniper-up state at T4
Short: EMA(close, shorter momentum lookback, T4, current forming bar) <= EMA(close, longer momentum lookback, T4, current forming bar) AND close <= EMA(close, longer momentum lookback, T4, current forming bar), calculated on T4 bars and carried to chart bars
Exit: long, (high >= entry-bar high + target multiple × ATR(ATR lookback) captured on the entry bar AND high[1] < that target) OR (low <= max(entry-bar low - stop-buffer multiple × ATR captured on the entry bar, entry price - stop-cap multiple × ATR captured on the entry bar) AND low[1] > that stop)
Exit: short, (low <= entry-bar low - target multiple × ATR(ATR lookback) captured on the entry bar AND low[1] > that target) OR (high >= min(entry-bar high + stop-buffer multiple × ATR captured on the entry bar, entry price + stop-cap multiple × ATR captured on the entry bar) AND high[1] < that stop)