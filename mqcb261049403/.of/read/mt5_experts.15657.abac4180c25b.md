Calculation: TSI = 100 × second-stage smoothing of close-to-close changes ÷ second-stage smoothing of their absolute values; each stage applies its own configurable smoothing method and lookback, with the first stage applied before the second. Calculate on the configurable indicator timeframe, which may be higher, lower, or equal to the chart timeframe, using completed bars.
Calculation: Trigger = TSI from TriggerShift bars earlier on the indicator timeframe.
Long: On a newly completed indicator-timeframe bar, previous completed bar TSI > Trigger AND latest completed bar TSI <= Trigger
Short: On a newly completed indicator-timeframe bar, previous completed bar TSI < Trigger AND latest completed bar TSI >= Trigger
Exit: Long, on a newly completed indicator-timeframe bar, previous completed bar TSI < Trigger AND latest completed bar TSI >= Trigger
Exit: Short, on a newly completed indicator-timeframe bar, previous completed bar TSI > Trigger AND latest completed bar TSI <= Trigger