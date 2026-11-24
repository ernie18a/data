Calculation: Asia high = highest(high) within the configured Asia session
Calculation: Asia low = lowest(low) within the configured Asia session
Calculation: Asia range = Asia high - Asia low
Long: A confirmed chart-bar close is above Asia high, after the Asia session and during the configured bias window; no earlier close in that window was above Asia high or below Asia low; and the Asia-range gate is disabled or Asia range is between its configured minimum and maximum
Short: A confirmed chart-bar close is below Asia low, after the Asia session and during the configured bias window; no earlier close in that window was above Asia high or below Asia low; and the Asia-range gate is disabled or Asia range is between its configured minimum and maximum
Calculation: London opening-range high = highest(high) within the configured London opening range
Calculation: London opening-range low = lowest(low) within the configured London opening range
Long: The first confirmed chart-bar close above London opening-range high after that range completes, within the configured maximum bars after completion and before the configured entry cutoff; Asia-session bias is long; and each enabled higher-timeframe filter was aligned with that bias when it triggered, using the last completed bar of T1 and T2 sampled on chart bars, with close > EMA(close, shared lookback, respective timeframe, last completed bar)
Short: The first confirmed chart-bar close below London opening-range low after that range completes, within the configured maximum bars after completion and before the configured entry cutoff; Asia-session bias is short; and each enabled higher-timeframe filter was aligned with that bias when it triggered, using the last completed bar of T1 and T2 sampled on chart bars, with close < EMA(close, shared lookback, respective timeframe, last completed bar)
Calculation: Bullish FVG top = low; bottom = high[gap-separation lag]
Calculation: Bearish FVG top = low[gap-separation lag]; bottom = high
Long: On a confirmed chart bar, low - high[gap-separation lag] exceeds the configured minimum FVG size, measured as a fixed amount or as a percentage of close according to the configured size mode
Short: On a confirmed chart bar, low[gap-separation lag] - high exceeds the configured minimum FVG size, measured as a fixed amount or as a percentage of close according to the configured size mode
Calculation: FVG age = current chart-bar index - FVG formation chart-bar index
Calculation: Bullish FVG mitigation = after the configured FVG eligibility age, (low <= top AND high >= bottom) in touch mode, low <= (top + bottom) / 2 in midpoint-fill mode, or low <= bottom in full-fill mode
Calculation: Bearish FVG mitigation = after the configured FVG eligibility age, (low <= top AND high >= bottom) in touch mode, high >= (top + bottom) / 2 in midpoint-fill mode, or high >= top in full-fill mode
Long: Asia-session bias is long; a bullish FVG is within its configured maximum age, older than the configured FVG eligibility age, and has not previously met the bullish FVG mitigation condition; and low <= FVG top * upper-proximity parameter AND low >= FVG bottom
Short: Asia-session bias is short; a bearish FVG is within its configured maximum age, older than the configured FVG eligibility age, and has not previously met the bearish FVG mitigation condition; and high >= FVG bottom * lower-proximity parameter AND high <= FVG top
Calculation: Zone overlap top = min(zone1 top, zone2 top)
Calculation: Zone overlap bottom = max(zone1 bottom, zone2 bottom)
Calculation: Zone overlap size = Zone overlap top - Zone overlap bottom
Calculation: BPR age = current chart-bar index - BPR formation chart-bar index
Calculation: BPR mitigation = after the configured BPR eligibility age, (last FVG bullish AND close < BPR bottom) OR (last FVG bearish AND close > BPR top)
Long: A new bullish FVG overlaps an unmitigated bearish FVG within its maximum age or a bearish FVG mitigated within the configured swept-FVG memory window and retained within its configured memory count; Zone overlap size meets the configured minimum BPR size, measured as a fixed amount or percentage of close according to the configured size mode; and no unmitigated BPR within its maximum age has Zone overlap size > 0 with the candidate zone
Short: A new bearish FVG overlaps an unmitigated bullish FVG within its maximum age or a bullish FVG mitigated within the configured swept-FVG memory window and retained within its configured memory count; Zone overlap size meets the configured minimum BPR size, measured as a fixed amount or percentage of close according to the configured size mode; and no unmitigated BPR within its maximum age has Zone overlap size > 0 with the candidate zone
Exit: long, after an ABLC long signal, New York time reaches the configured time-exit cutoff
Exit: short, after an ABLC short signal, New York time reaches the configured time-exit cutoff