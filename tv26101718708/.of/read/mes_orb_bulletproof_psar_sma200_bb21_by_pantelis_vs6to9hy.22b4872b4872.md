Calculation: Opening Range = OR High is the highest high and OR Low is the lowest low of the bars from the session open until a fixed opening-range duration has elapsed; both are frozen for the rest of that session. OR Size = OR High - OR Low.
Calculation: HTF ATR = ATR computed on a timeframe higher than the chart timeframe, using the higher-timeframe bar still forming at the current chart bar.
Calculation: StopDist = stop multiplier * HTF ATR
Calculation: Parabolic SAR = standard Parabolic SAR on chart-timeframe bars.
Long: bar is inside the session AND the opening range is complete AND position is flat AND no long has been entered yet this session AND the last N consecutive closes (including the current bar) are all > OR High AND close > Parabolic SAR AND OR Size >= minimum fraction * HTF ATR
Short: bar is inside the session AND the opening range is complete AND position is flat AND no short has been entered yet this session AND the last N consecutive closes (including the current bar) are all < OR Low AND close < Parabolic SAR AND OR Size >= minimum fraction * HTF ATR
Exit: long, core portion: low <= entry price - StopDist OR high >= entry price + R multiple * StopDist
Exit: long, runner portion: high >= entry price + OR multiple * OR Size OR low <= max(entry price - StopDist, Parabolic SAR if Parabolic SAR < close, otherwise ignore Parabolic SAR)
Exit: short, core portion: high >= entry price + StopDist OR low <= entry price - R multiple * StopDist
Exit: short, runner portion: low <= entry price - OR multiple * OR Size OR high >= min(entry price + StopDist, Parabolic SAR if Parabolic SAR > close, otherwise ignore Parabolic SAR)
Exit: long or short, all remaining portions: the session has ended (the current bar is the first bar outside the session after an in-session bar)