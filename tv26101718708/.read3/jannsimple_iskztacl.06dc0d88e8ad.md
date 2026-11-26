Calculation: PsychLevel(price, precision, fraction) = unit × trunc(price / unit) + unit × fraction, where unit = 10^(trunc(log10(price)) − (price < PsubunitThreshold ? precision + 1 : precision) + 1)
Calculation: Near psychological level = absolute distance from close to any PsychLevel(close, PcoarsePrecision or PfinePrecision, PfractionLow, PfractionMiddle, or PfractionHigh) is less than close × PpsychTolerance
Calculation: EMA bullish alignment = EMA(close, PshortEMALookback) > EMA(close, PlongEMALookback), with PshortEMALookback shorter than PlongEMALookback
Calculation: EMA bearish alignment = EMA(close, PshortEMALookback) < EMA(close, PlongEMALookback), with PshortEMALookback shorter than PlongEMALookback
Calculation: Above VWAP = close > VWAP(hlc3)
Calculation: Below VWAP = close < VWAP(hlc3)
Calculation: VWAP reclaim = close > VWAP(hlc3) AND close[1] < VWAP(hlc3)[1]
Calculation: VWAP rejection = close < VWAP(hlc3) AND close[1] > VWAP(hlc3)[1]
Calculation: Bullish confirmation = (close > open AND close − open > (high − low) × PbodyRangeFraction) OR (close > open AND close > close[1] AND open < close[1] AND close[1] < open[1] AND close > VWAP(hlc3))
Calculation: Bearish confirmation = (close < open AND open − close > (high − low) × PbodyRangeFraction) OR (close < open AND close < close[1] AND open > close[1] AND close[1] > open[1] AND close < VWAP(hlc3))
Calculation: Volume surge = volume > SMA(volume, PvolumeSMALookback) × PvolumeMultiplier
Calculation: T1 bullish = on chart bars, T1 close > EMA(T1 close, PtrendEMALookback) calculated on T1 bars using lookahead off (last completed T1 bar historically; still-forming T1 bar in real time)
Calculation: T1 bearish = on chart bars, T1 close < EMA(T1 close, PtrendEMALookback) calculated on T1 bars using lookahead off (last completed T1 bar historically; still-forming T1 bar in real time)
Calculation: Near support = on chart bars, close is within PpivotTolerance × (high − low) of the classic floor pivot PP, S1, or S2 calculated from the last completed T2 bar's high, low, and close
Calculation: Near resistance = on chart bars, close is within PpivotTolerance × (high − low) of the classic floor pivot PP, R1, or R2 calculated from the last completed T2 bar's high, low, and close
Calculation: Long score = weighted sum of true conditions: PemaAlignmentWeight for EMA bullish alignment; PvwapAlignmentWeight for Above VWAP; PvwapReclaimWeight for VWAP reclaim; PcandleConfirmationWeight for Bullish confirmation; PproximityWeight for Near support; PpsychologicalWeight for Near psychological level; PtrendWeight for T1 bullish; PvolumeWeight for Volume surge
Calculation: Short score = weighted sum of true conditions: PemaAlignmentWeight for EMA bearish alignment; PvwapAlignmentWeight for Below VWAP; PvwapReclaimWeight for VWAP rejection; PcandleConfirmationWeight for Bearish confirmation; PproximityWeight for Near resistance; PpsychologicalWeight for Near psychological level; PtrendWeight for T1 bearish; PvolumeWeight for Volume surge
Calculation: Long raw event = if PrequireBoth is true, an EMA(close, PshortEMALookback) cross above EMA(close, PlongEMALookback) and a VWAP reclaim both occur within the current and prior PcrossWindow − 1 chart bars; otherwise, either occurs on the current chart bar
Calculation: Short raw event = if PrequireBoth is true, an EMA(close, PshortEMALookback) cross below EMA(close, PlongEMALookback) and a VWAP rejection both occur within the current and prior PcrossWindow − 1 chart bars; otherwise, either occurs on the current chart bar
Calculation: Long label condition = Long raw event is true on the current chart bar and false on the prior chart bar AND (Long score > PminimumScore OR (Long score = PminimumScore AND T1 bullish AND (Near support OR Near psychological level))) AND (PtrendFilter is disabled OR T1 bullish) AND (PtimeFilter is disabled OR New York chart-bar time is within either [PAMStart, PAMEnd) or [PPMStart, PPMEnd)) AND chart bars since the prior Long label condition exceeds PcooldownBars
Calculation: Short label condition = Short raw event is true on the current chart bar and false on the prior chart bar AND (Short score > PminimumScore OR (Short score = PminimumScore AND T1 bearish AND (Near resistance OR Near psychological level))) AND (PtrendFilter is disabled OR T1 bearish) AND (PtimeFilter is disabled OR New York chart-bar time is within either [PAMStart, PAMEnd) or [PPMStart, PPMEnd)) AND chart bars since the prior Short label condition exceeds PcooldownBars
Long: EMA bullish alignment
Long: Above VWAP
Long: VWAP reclaim
Long: Bullish confirmation
Long: Near support
Long: Near psychological level
Long: T1 bullish
Long: Volume surge
Short: EMA bearish alignment
Short: Below VWAP
Short: VWAP rejection
Short: Bearish confirmation
Short: Near resistance
Short: Near psychological level
Short: T1 bearish
Short: Volume surge
Long: Long label condition
Long: Long label condition AND Long score >= PperfectAlertScore
Long: Long label condition AND Long score >= PhighConvictionAlertScore
Short: Short label condition
Short: Short label condition AND Short score >= PperfectAlertScore
Short: Short label condition AND Short score >= PhighConvictionAlertScore