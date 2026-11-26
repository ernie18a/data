Calculation: Confirmed signal bar = bar is confirmed AND ATR(ATR lookback) > 0
Calculation: Volume passes = volume multiplier <= 0 OR volume is unavailable OR SMA(volume, volume lookback) is unavailable OR volume >= SMA(volume, volume lookback) * volume multiplier
Calculation: Bullish bar = close > open
Calculation: Bearish bar = close < open
Calculation: Opening range levels = highest high and lowest low during the configured session's initial range duration, fixed after that duration ends
Calculation: Entry risk = ATR(ATR lookback) * stop distance, sampled on the entry bar
Calculation: Long stop = entry price - entry risk
Calculation: Long final target = entry price + entry risk * final-target R
Calculation: Short stop = entry price + entry risk
Calculation: Short final target = entry price - entry risk * final-target R
Long: Confirmed signal bar AND close crosses above session VWAP(hlc3) after at least the minimum consecutive closes strictly below it AND Volume passes
Short: Confirmed signal bar AND close crosses below session VWAP(hlc3) after at least the minimum consecutive closes strictly above it AND Volume passes
Long: Confirmed signal bar AND EMA(close, intermediate lookback) > EMA(close, longer lookback) AND EMA(close, longer lookback) > EMA(close, longer lookback)[slope lookback] AND low <= EMA(close, intermediate lookback) within the touch lookback AND close > EMA(close, shorter lookback) AND Bullish bar AND close > high[1] AND Volume passes
Short: Confirmed signal bar AND EMA(close, intermediate lookback) < EMA(close, longer lookback) AND EMA(close, longer lookback) < EMA(close, longer lookback)[slope lookback] AND high >= EMA(close, intermediate lookback) within the touch lookback AND close < EMA(close, shorter lookback) AND Bearish bar AND close < low[1] AND Volume passes
Long: Confirmed signal bar AND a close is above a confirmed PivotHigh(high, pivot lookback, pivot lookback); on a later bar within the retest window, low <= that pivot level + ATR(ATR lookback) * retest tolerance AND close > that level AND Bullish bar; defer pivots confirmed while the break is active until it ends
Short: Confirmed signal bar AND a close is below a confirmed PivotLow(low, pivot lookback, pivot lookback); on a later bar within the retest window, high >= that pivot level - ATR(ATR lookback) * retest tolerance AND close < that level AND Bearish bar; defer pivots confirmed while the break is active until it ends
Long: Confirmed signal bar AND low < Lowest(low, sweep lookback)[1] AND close > Lowest(low, sweep lookback)[1] AND Bullish bar AND close - low > high - close AND Volume passes
Short: Confirmed signal bar AND high > Highest(high, sweep lookback)[1] AND close < Highest(high, sweep lookback)[1] AND Bearish bar AND high - close > close - low AND Volume passes
Long: Confirmed signal bar AND at confirmation of a PivotLow(low, pivot lookback, pivot lookback), its low is below the immediately preceding confirmed pivot low, RSI(close, RSI lookback) at its pivot bar is above RSI at the preceding pivot bar, and the pivot gap is within the maximum
Short: Confirmed signal bar AND at confirmation of a PivotHigh(high, pivot lookback, pivot lookback), its high is above the immediately preceding confirmed pivot high, RSI(close, RSI lookback) at its pivot bar is below RSI at the preceding pivot bar, and the pivot gap is within the maximum
Long: Confirmed signal bar AND within the configured session AND the opening range is complete AND no opening-range break has fired this session AND close > opening-range high
Short: Confirmed signal bar AND within the configured session AND the opening range is complete AND no opening-range break has fired this session AND close < opening-range low
Exit: long, Confirmed signal bar AND (low <= Long stop OR (high >= Long final target AND low > Long stop) OR (bars since entry >= holding limit AND low > Long stop AND high < Long final target))
Exit: short, Confirmed signal bar AND (high >= Short stop OR (low <= Short final target AND high < Short stop) OR (bars since entry >= holding limit AND high < Short stop AND low > Short final target))