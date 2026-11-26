Calculation: Strong candle = abs(close - open) / max(high - low, minimum price tick) >= minimum body fraction on the current chart bar.
Calculation: Consolidation = on chart bars using the last three completed T2 bars, (abs(high[1] - high[2]) < consolidation tolerance AND abs(high[2] - high[3]) < consolidation tolerance) OR (abs(low[1] - low[2]) < consolidation tolerance AND abs(low[2] - low[3]) < consolidation tolerance).
Calculation: Bullish trend = on chart bars using completed bars from T2, T3, and T4, the latest completed close on each timeframe exceeds its preceding completed close.
Calculation: Bearish trend = on chart bars using completed bars from T2, T3, and T4, the latest completed close on each timeframe is below its preceding completed close.
Calculation: Bullish structure = on chart bars using completed T3 and T2 bars, the latest completed close on each timeframe exceeds the highest high over the HTF swing lookback ending two completed bars ago on that timeframe.
Calculation: Bearish structure = on chart bars using completed T3 and T2 bars, the latest completed close on each timeframe is below the lowest low over the HTF swing lookback ending two completed bars ago on that timeframe.
Calculation: ICC band = high and low from the configured bars-back offset on completed T1 bars, sampled on chart bars; midpoint = (high + low) / 2.
Calculation: PO3 accumulation range = highest high and lowest low of the current PO3 accumulation phase, frozen when that phase ends.
Calculation: Asia session range = highest high and lowest low of the current Asia session.
Calculation: NY opening range = highest high and lowest low during the configured NY opening-range window, frozen when that window ends.
Calculation: Asia opening range = highest high and lowest low during the configured Asia opening-range window, frozen when that window ends.
Calculation: Active bullish BOS level = the local swing high crossed above by close, updated on each bullish break and active until a later bearish break or close falls below the level by twice the BOS invalidation distance; the local swing high is the highest high over the local swing lookback ending one chart bar ago.
Calculation: Active bearish BOS level = the local swing low crossed below by close, updated on each bearish break and active until a later bullish break or close rises above the level by twice the BOS invalidation distance; the local swing low is the lowest low over the local swing lookback ending one chart bar ago.
Calculation: Active bullish FVG zone = the latest three-bar bullish fair value gap formed while a bullish BOS is active, with bounds from high two chart bars ago to the current low; clear it when low falls below its lower bound or the bullish BOS becomes inactive.
Calculation: Active bearish FVG zone = the latest three-bar bearish fair value gap formed while a bearish BOS is active, with bounds from the current high to low two chart bars ago; clear it when high rises above its upper bound or the bearish BOS becomes inactive.
Long: bullish trend.
Short: bearish trend.
Long: bullish structure.
Short: bearish structure.
Long: an active bullish BOS.
Short: an active bearish BOS.
Long: bullish trend AND close crosses above the highest high over the local swing lookback ending one chart bar ago.
Short: bearish trend AND close crosses below the lowest low over the local swing lookback ending one chart bar ago.
Long: on chart bars at T2 or T3, a newly confirmed T3 pivot high, sampled from completed T3 bars, is greater than the previous confirmed T3 pivot high, or no previous pivot high exists; use PivotHigh(high, swing pivot lookback, swing pivot lookback).
Short: on chart bars at T2 or T3, a newly confirmed T3 pivot high, sampled from completed T3 bars, is lower than the previous confirmed T3 pivot high; use PivotHigh(high, swing pivot lookback, swing pivot lookback).
Long: on chart bars at T2 or T3, a newly confirmed T3 pivot low, sampled from completed T3 bars, is greater than the previous confirmed T3 pivot low, or no previous pivot low exists; use PivotLow(low, swing pivot lookback, swing pivot lookback).
Short: on chart bars at T2 or T3, a newly confirmed T3 pivot low, sampled from completed T3 bars, is lower than the previous confirmed T3 pivot low; use PivotLow(low, swing pivot lookback, swing pivot lookback).
Long: high two chart bars ago < current low.
Short: low two chart bars ago > current high.
Short: close <= the lower bound of a tracked bullish fair value gap after at least one chart bar has elapsed since its formation; track up to the IFVG track limit per direction.
Long: close >= the upper bound of a tracked bearish fair value gap after at least one chart bar has elapsed since its formation; track up to the IFVG track limit per direction.
Long: on T6 chart bars, the PO3 accumulation phase has ended, neither edge of the current PO3 accumulation range has previously been swept, and low < the range low.
Short: on T6 chart bars, the PO3 accumulation phase has ended, neither edge of the current PO3 accumulation range has previously been swept, and high > the range high.
Long: on T6 chart bars, the PO3 range low has been swept in the current cycle, no PO3 distribution has yet occurred, close > the range low, close > open, and the candle is strong.
Short: on T6 chart bars, the PO3 range high has been swept in the current cycle, no PO3 distribution has yet occurred, close < the range high, close < open, and the candle is strong.
Long: on T6 chart bars, the first qualifying sweep of the current Asia session range is below its low by more than the AMD sweep tolerance during the London or NY open session; then close > the Asia range low, close > open, and the candle is strong.
Short: on T6 chart bars, the first qualifying sweep of the current Asia session range is above its high by more than the AMD sweep tolerance during the London or NY open session; then close < the Asia range high, close < open, and the candle is strong.
Long: close crosses above the completed NY opening-range high, and no earlier bullish breakout signal has occurred for that range.
Short: close crosses below the completed NY opening-range low, and no earlier bearish breakout signal has occurred for that range.
Long: close crosses above the completed Asia opening-range high, and no earlier bullish breakout signal has occurred for that range.
Short: close crosses below the completed Asia opening-range low, and no earlier bearish breakout signal has occurred for that range.
Long: on chart bars at T5 or T6, during at least one enabled NY open, NY lunch, London, or Asia session, NOT consolidation, bullish trend, bullish structure, an active bullish BOS, and (low <= active bullish BOS level + ICC level touch tolerance AND close >= active bullish BOS level - ICC level touch tolerance OR low <= active bullish FVG upper bound AND close >= active bullish FVG lower bound), close > open, and the candle is strong.
Short: on chart bars at T5 or T6, during at least one enabled NY open, NY lunch, London, or Asia session, NOT consolidation, bearish trend, bearish structure, an active bearish BOS, and (high >= active bearish BOS level - ICC level touch tolerance AND close <= active bearish BOS level + ICC level touch tolerance OR high >= active bearish FVG lower bound AND close <= active bearish FVG upper bound), close < open, and the candle is strong.
Long: on chart bars at T5 or T6, during at least one enabled NY open, NY lunch, London, or Asia session, NOT consolidation, bullish trend, bullish structure, low <= ICC band low + ICC level touch tolerance, close < ICC band midpoint, close > open, and the candle is strong.
Short: on chart bars at T5 or T6, during at least one enabled NY open, NY lunch, London, or Asia session, NOT consolidation, bearish trend, bearish structure, high >= ICC band high - ICC level touch tolerance, close > ICC band midpoint, close < open, and the candle is strong.