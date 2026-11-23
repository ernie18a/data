Calculation: LegFlow_k = (2*close_k - high_k - low_k) / (high_k - low_k) * min(volume_k / RMA(volume_k, volume baseline), per-leg volume cap), for each leg k; RMA runs only on regular-session bars with volume_k > 0; LegFlow_k is undefined unless the bar is in regular session, volume_k > 0 and high_k > low_k; for the inverse-exposure leg, LegFlow_k is multiplied by -1
Calculation: BlendFlow = (sum over k of w_k * LegFlow_k) / (sum over k of w_k), over legs k with LegFlow_k defined and w_k > 0; undefined if no such leg
Calculation: LegCount = number of legs k with LegFlow_k defined and w_k > 0
Calculation: CoverageOK = FlowZ is defined AND LegCount >= min active legs
Calculation: FlowZ = ZScore(EMA(BlendFlow, smoothing length), normalization lookback); the EMA and the window of its last normalization lookback values update only on bars where BlendFlow is defined and hold their values otherwise; FlowZ is undefined until the window holds at least minimum sample count values and while its standard deviation is zero
Calculation: FlowRatio = |FlowZ| / SMA(|FlowZ|, strength lookback)
Calculation: BullWeightShare = (sum over k of w_k where LegFlow_k > 0) / (sum over k of w_k where LegFlow_k is defined and w_k > 0)
Calculation: BearWeightShare = (sum over k of w_k where LegFlow_k < 0) / (sum over k of w_k where LegFlow_k is defined and w_k > 0)
Calculation: FilterRSI = RSI(close of filter reference, filter length), computed on the filter reference's own bars; each chart bar takes the value of the filter reference bar with the same time
Calculation: BullFilterPass = FilterRSI < oversold level OR (FilterRSI > FilterRSI[1] AND FilterRSI[1] < oversold level) OR (midline < FilterRSI AND FilterRSI < overbought level)
Calculation: BearFilterPass = FilterRSI > overbought level OR (FilterRSI < FilterRSI[1] AND FilterRSI[1] > overbought level) OR (oversold level < FilterRSI AND FilterRSI < midline)
Calculation: BullAlignment = CoverageOK AND FlowZ > 0 AND FlowZ > FlowZ[1] AND BullFilterPass AND BullWeightShare >= min directional breadth AND in regular session
Calculation: BearAlignment = CoverageOK AND FlowZ < 0 AND FlowZ < FlowZ[1] AND BearFilterPass AND BearWeightShare >= min directional breadth AND in regular session
Calculation: BullAgreementEvent = BullAlignment AND NOT BullAlignment[1] AND bars since previous BullAgreementEvent >= agreement cooldown
Calculation: BearAgreementEvent = BearAlignment AND NOT BearAlignment[1] AND bars since previous BearAgreementEvent >= agreement cooldown
Calculation: BullFlowSurge = CoverageOK AND FlowZ > 0 AND FlowRatio > strength threshold AND in regular session
Calculation: BearFlowSurge = CoverageOK AND FlowZ < 0 AND FlowRatio > strength threshold AND in regular session
Calculation: PrevLowPrice = low at the pivot bar of the most recent earlier PivotLow(low, pivot strength, pivot strength) whose pivot bar had CoverageOK
Calculation: PrevLowFlow = FlowZ at that same pivot bar
Calculation: PrevHighPrice = high at the pivot bar of the most recent earlier PivotHigh(high, pivot strength, pivot strength) whose pivot bar had CoverageOK
Calculation: PrevHighFlow = FlowZ at that same pivot bar
Long: BullAgreementEvent
Short: BearAgreementEvent
Long: BullAlignment AND (BullAgreementEvent OR bars since previous BullAgreementEvent < label hold bars)
Short: BearAlignment AND (BearAgreementEvent OR bars since previous BearAgreementEvent < label hold bars)
Long: FlowZ crosses above 0 AND CoverageOK AND BullFilterPass AND in regular session
Short: FlowZ crosses below 0 AND CoverageOK AND BearFilterPass AND in regular session
Long: BullFlowSurge AND NOT BullFlowSurge[1]
Short: BearFlowSurge AND NOT BearFlowSurge[1]
Long: PivotLow(low, pivot strength, pivot strength) is defined AND CoverageOK[pivot strength] AND in regular session[pivot strength] AND low[pivot strength] < PrevLowPrice AND FlowZ[pivot strength] - PrevLowFlow >= min flow disagreement AND FilterRSI[pivot strength] <= bullish divergence level
Short: PivotHigh(high, pivot strength, pivot strength) is defined AND CoverageOK[pivot strength] AND in regular session[pivot strength] AND high[pivot strength] > PrevHighPrice AND PrevHighFlow - FlowZ[pivot strength] >= min flow disagreement AND FilterRSI[pivot strength] >= bearish divergence level