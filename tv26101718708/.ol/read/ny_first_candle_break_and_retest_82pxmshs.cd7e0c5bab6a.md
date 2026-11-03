Calculation: Session opening range = high and low of the first chart bar inside the configured session, captured when the prior bar was outside it; reset each session
Calculation: ATR = average true range over the configured lookback
Calculation: Break threshold = ATR × configured minimum-break fraction
Calculation: Upper retest band = session opening high ± ATR × configured retest fraction
Calculation: Lower retest band = session opening low ± ATR × configured retest fraction
Calculation: High break = during the session after its opening bar, high exceeds session opening high + break threshold; record its bar and keep it broken for the session
Calculation: Low break = during the session after its opening bar, low falls below session opening low − break threshold; record its bar and keep it broken for the session
Calculation: High retest = high break recorded, bars since break is within the configured minimum and maximum, and current low is inside the upper retest band
Calculation: Low retest = low break recorded, bars since break is within the configured minimum and maximum, and current high is inside the lower retest band
Calculation: Average volume = simple moving average of volume over the configured lookback
Calculation: Long stop = current low − ATR × configured stop multiplier; long risk = close − long stop
Calculation: Short stop = current high + ATR × configured stop multiplier; short risk = short stop − close
Calculation: Long targets = close + long risk × configured reward-to-risk ratio × each configured target fraction
Calculation: Short targets = close − short risk × configured reward-to-risk ratio × each configured target fraction
Calculation: Long trailing stop = close − ATR × configured trailing fraction; activate when close − stored long entry price ≥ (long target 3 − stored long entry price) × configured activation fraction, and update only when above the initial long stop and higher than the prior trailing stop
Calculation: Short trailing stop = close + ATR × configured trailing fraction; activate when stored short entry price − close ≥ (stored short entry price − short target 3) × configured activation fraction, and update only when below the initial short stop and lower than the prior trailing stop
Long: within the configured session AND high retest AND close > session opening high AND close > EMA (when EMA filter is enabled) AND close > session VWAP (when VWAP filter is enabled) AND volume > average volume × configured volume threshold (when volume confirmation is enabled)
Short: within the configured session AND low retest AND close < session opening low AND close < EMA (when EMA filter is enabled) AND close < session VWAP (when VWAP filter is enabled) AND volume > average volume × configured volume threshold (when volume confirmation is enabled)
Exit: Long, low ≤ long stop OR high ≥ an applicable long target OR trailing stop is active and low ≤ long trailing stop OR current bar is outside the configured session and prior bar was inside it
Exit: Short, high ≥ short stop OR low ≤ an applicable short target OR trailing stop is active and high ≥ short trailing stop OR current bar is outside the configured session and prior bar was inside it