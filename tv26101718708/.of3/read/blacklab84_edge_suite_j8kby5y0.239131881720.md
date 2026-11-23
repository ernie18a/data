Calculation: HullMA = HMA(close, hull length)
Calculation: HmaSlope = HullMA - HullMA[slope lag]
Calculation: Atr = ATR(ATR length)
Calculation: Vwap = VWAP(typical price)
Calculation: UpperBand = Vwap + band multiplier * Atr
Calculation: LowerBand = Vwap - band multiplier * Atr
Calculation: Rsi = RSI(close, RSI length)
Calculation: VolumeAverage = SMA(volume, volume average length)
Calculation: BullDivergence(RSI length, divergence pivot lookback) = a pivot low of low with divergence pivot lookback bars on each side is confirmed on this bar AND that pivot's low is below the previous confirmed pivot low's low AND RSI(close, RSI length) at that pivot's bar is above its value at the previous confirmed pivot low's bar
Calculation: BearDivergence(RSI length, divergence pivot lookback) = a pivot high of high with divergence pivot lookback bars on each side is confirmed on this bar AND that pivot's high is above the previous confirmed pivot high's high AND RSI(close, RSI length) at that pivot's bar is below its value at the previous confirmed pivot high's bar
Calculation: BullHiddenDivergence(RSI length, divergence pivot lookback) = a pivot low of low with divergence pivot lookback bars on each side is confirmed on this bar AND that pivot's low is above the previous confirmed pivot low's low AND RSI(close, RSI length) at that pivot's bar is below its value at the previous confirmed pivot low's bar
Calculation: BearHiddenDivergence(RSI length, divergence pivot lookback) = a pivot high of high with divergence pivot lookback bars on each side is confirmed on this bar AND that pivot's high is below the previous confirmed pivot high's high AND RSI(close, RSI length) at that pivot's bar is above its value at the previous confirmed pivot high's bar
Calculation: BullCmoDivergence(CMO length, CMO pivot lookback, prior pivot count) = a pivot low of low with CMO pivot lookback bars on each side is confirmed on this bar AND, for any of the previous prior pivot count confirmed pivot lows, this pivot's low is below that pivot's low AND CMO(close, CMO length) at this pivot's bar is above its value at that pivot's bar
Calculation: BearCmoDivergence(CMO length, CMO pivot lookback, prior pivot count) = a pivot high of high with CMO pivot lookback bars on each side is confirmed on this bar AND, for any of the previous prior pivot count confirmed pivot highs, this pivot's high is above that pivot's high AND CMO(close, CMO length) at this pivot's bar is below its value at that pivot's bar
Long: HullMA > HullMA[direction lag] AND close > Vwap AND BullDivergence(RSI length, divergence pivot lookback) AND Rsi < overbought level AND volume > VolumeAverage * volume confirmation multiplier
Short: HullMA <= HullMA[direction lag] AND close < Vwap AND BearDivergence(RSI length, divergence pivot lookback) AND Rsi > oversold level AND volume > VolumeAverage * volume confirmation multiplier
Long: HullMA > HullMA[direction lag]
Short: HullMA <= HullMA[direction lag]
Long: close > HullMA
Short: close <= HullMA
Long: BullDivergence(RSI length, divergence pivot lookback)
Short: BearDivergence(RSI length, divergence pivot lookback)
Long: BullDivergence(shorter RSI length, divergence pivot lookback)
Short: BearDivergence(shorter RSI length, divergence pivot lookback)
Long: BullCmoDivergence(CMO length, CMO pivot lookback, prior pivot count)
Short: BearCmoDivergence(CMO length, CMO pivot lookback, prior pivot count)
Long: BullHiddenDivergence(RSI length, divergence pivot lookback)
Short: BearHiddenDivergence(RSI length, divergence pivot lookback)
Long: HmaSlope > Atr * acceleration multiplier AND HmaSlope[1] <= Atr * acceleration multiplier
Short: HmaSlope < -(Atr * acceleration multiplier) AND HmaSlope[1] >= -(Atr * acceleration multiplier)
Long: low <= LowerBand + tag buffer * Atr AND close > LowerBand
Short: high >= UpperBand - tag buffer * Atr AND close < UpperBand
Long: volume >= VolumeAverage * climax multiplier AND low <= Lowest(low, climax lookback) AND close > (high + low) / 2
Short: volume >= VolumeAverage * climax multiplier AND high >= Highest(high, climax lookback) AND close < (high + low) / 2