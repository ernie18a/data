Calculation: Relative volume = volume / SMA(volume, chart volume lookback), or fallback relative-volume value if volume or SMA is unavailable or SMA is zero
Calculation: Candle body ratio = abs(close - open) / (high - low), or zero when high equals low
Calculation: Bullish fair-value gap = current low > high at the gap-reference lag; bearish fair-value gap = current high < low at the gap-reference lag
Calculation: Bullish CISD = current close > previous-bar high; bearish CISD = current close < previous-bar low
Calculation: Bullish order block = previous-bar close < previous-bar open AND current close > previous-bar high; bearish order block = previous-bar close > previous-bar open AND current close < previous-bar low
Calculation: Bullish sweep = current low < latest confirmed Pivot Low(low, pivot strength, pivot strength) AND current close > that pivot low; bearish sweep = current high > latest confirmed Pivot High(high, pivot strength, pivot strength) AND current close < that pivot high
Calculation: Prime session = New York time at or after the prime-session start parameter and before the prime-session end parameter; kill zone = New York time at or after the kill-zone start parameter and at or before the kill-zone end parameter; midday = New York time at or after the midday-start parameter
Calculation: Bad candle quality = candle body ratio < weak-body parameter OR current and previous bars each have an upper-wick or lower-wick ratio > wick-ratio parameter, where upper-wick ratio = (high - max(open, close)) / (high - low) and lower-wick ratio = (min(open, close) - low) / (high - low), or zero when high equals low
Calculation: Hard bad conditions = abs(EMA(close, EMA lookback) - its value at the EMA-slope lag) < ATR(ATR lookback) * flat-slope parameter OR ATR(ATR lookback) < SMA(ATR(ATR lookback), ATR-average lookback) * low-volatility parameter OR highest(high, compression lookback) - lowest(low, compression lookback) < ATR(ATR lookback) * compression parameter OR bad candle quality
Calculation: HTF overextension = abs(T1 current close - EMA(T1 close, EMA lookback)) > ATR(T1, ATR lookback) * maximum-extension parameter; chart bars read the still-forming T1 bar
Calculation: Bullish HTF score = max(0, trend weight if T1 close > EMA(T1 close, EMA lookback) + slope weight if EMA(T1 close, EMA lookback) minus its value at the EMA-slope lag > ATR(T1, ATR lookback) * T1-slope parameter + displacement weight if T1 close > T1 open AND T1 close - T1 open > ATR(T1, ATR lookback) * displacement-body parameter * displacement-multiplier parameter + volume-flow weight if (T1 volume unavailable OR its SMA at the T1 volume-flow lookback is unavailable or zero OR T1 volume > that SMA) AND T1 close > T1 open + gap weight if T1 low > T1 high at the gap-reference lag + CISD weight if T1 close > previous-bar T1 high + prime-session weight if prime session - midday penalty if midday - extension penalty if HTF overextension - bad-condition penalty if hard bad conditions); bearish score uses the corresponding bearish comparisons and the same weights. Chart bars read the still-forming T1 bar; prime-session, midday, and bad-condition terms use the chart bar
Calculation: Bullish HTF setup = T1 close > EMA(T1 close, EMA lookback) AND bullish HTF score >= required-score parameter AND ((bullish HTF score >= sweet-spot lower parameter AND bullish HTF score <= sweet-spot upper parameter AND bullish HTF score > bearish HTF score) OR (bullish HTF score > sweet-spot upper parameter AND NOT HTF overextension AND bullish HTF score > bearish HTF score)) AND (countertrend blocking disabled OR bullish HTF score > bearish HTF score + dominance-buffer parameter); bearish HTF setup is the mirrored condition
Calculation: Bullish flow = close > open AND relative volume > normal-volume parameter AND close > EMA(close, EMA lookback); bearish flow = close < open AND relative volume > normal-volume parameter AND close < EMA(close, EMA lookback)
Calculation: Bullish micro confirmation = number of true conditions among bullish fair-value gap, bullish CISD, and bullish order block on T2 bars >= the in-kill-zone confirmation-count parameter in the kill zone, otherwise >= the outside-kill-zone confirmation-count parameter; bearish micro confirmation is mirrored. Chart bars read the still-forming T2 bar
Calculation: Bullish LTF trigger = (close > EMA(close, EMA lookback) AND EMA(close, EMA lookback) minus its value at the EMA-slope lag > ATR(ATR lookback) * chart-slope parameter AND (bullish flow OR (close > open AND relative volume > strong-volume parameter))) OR ((bullish sweep OR bullish fair-value gap OR bullish CISD OR bullish order block) AND bullish flow) OR bullish micro confirmation; bearish LTF trigger is mirrored
Calculation: Entry quality = candle body ratio >= minimum-body parameter AND (ATR(ATR lookback) > SMA(ATR(ATR lookback), ATR-average lookback) * healthy-volatility parameter OR highest(high, expansion lookback) - lowest(low, expansion lookback) > ATR(ATR lookback) * expansion parameter OR kill zone) AND NOT hard bad conditions AND NOT HTF overextension
Long: (bar-close confirmation disabled OR chart bar confirmed) AND chart bar is in the configured session AND bullish HTF setup AND bullish LTF trigger AND entry quality AND position is flat
Short: (bar-close confirmation disabled OR chart bar confirmed) AND chart bar is in the configured session AND bearish HTF setup AND bearish LTF trigger AND entry quality AND position is flat
Long: bullish sweep
Short: bearish sweep
Long: bullish fair-value gap
Short: bearish fair-value gap
Long: bullish order block
Short: bearish order block
Long: bullish flow
Short: bearish flow
Long: bullish HTF score > bearish HTF score
Short: bearish HTF score > bullish HTF score
Long: bullish micro confirmation
Short: bearish micro confirmation
Long: bullish HTF setup
Short: bearish HTF setup
Long: bullish LTF trigger
Short: bearish LTF trigger
Long: EMA(close, EMA lookback) minus its value at the EMA-slope lag > ATR(ATR lookback) * chart-slope parameter
Short: EMA(close, EMA lookback) minus its value at the EMA-slope lag < -ATR(ATR lookback) * chart-slope parameter
Long: bullish HTF score >= forecast-score parameter AND bullish HTF score > bearish HTF score
Short: bearish HTF score >= forecast-score parameter AND bearish HTF score > bullish HTF score
Long: bullish HTF setup AND NOT bullish LTF trigger
Short: bearish HTF setup AND NOT bearish LTF trigger
Long: long entry signal AND kill zone AND bullish HTF score >= kill-zone-alert score parameter
Short: short entry signal AND kill zone AND bearish HTF score >= kill-zone-alert score parameter
Exit: long, high >= entry price + (entry price - (entry-bar low - ATR(entry bar, ATR lookback) * stop-multiplier parameter)) * target-multiple parameter OR low <= entry-bar low - ATR(entry bar, ATR lookback) * stop-multiplier parameter OR bars elapsed since entry >= timeout parameter
Exit: short, low <= entry price - (entry-bar high + ATR(entry bar, ATR lookback) * stop-multiplier parameter - entry price) * target-multiple parameter OR high >= entry-bar high + ATR(entry bar, ATR lookback) * stop-multiplier parameter OR bars elapsed since entry >= timeout parameter