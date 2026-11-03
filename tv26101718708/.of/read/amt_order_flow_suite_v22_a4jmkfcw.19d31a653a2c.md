Calculation: Bar delta = volume × abs(close − open) / (high − low), positive when close >= open and negative otherwise; use a body ratio of 0.5 when high = low.
Calculation: Session CVD = cumulative sum of bar delta, reset at each new calendar day in the selected timezone; its EMA continues across session resets.
Calculation: Session VWAP and deviation = volume-weighted mean and population standard deviation of (high + low + close) / 3 since the start of the current calendar day in the selected timezone; if cumulative volume is zero, use the current typical price as VWAP and zero as deviation.
Calculation: Value area high = session VWAP + session VWAP deviation; value area low = session VWAP − session VWAP deviation.
Long: Session CVD >= 0.
Short: Session CVD < 0.
Long: Bar delta >= 0.
Short: Bar delta < 0.
Long: Close >= session VWAP.
Short: Close < session VWAP.
Long: Session CVD > EMA of session CVD.
Short: Session CVD <= EMA of session CVD.
Long: Low <= lowest low over the divergence lookback including the current bar AND session CVD > highest divergence ratio below 1 × lowest session CVD over the same lookback AND session CVD > 0.
Short: High >= highest high over the divergence lookback including the current bar AND session CVD < highest divergence ratio below 1 × highest session CVD over the same lookback AND session CVD < 0.
Long: Lowest low over the failed-auction lookback including the current bar < current value area low − proximity distance AND close > current value area low − proximity distance AND close < current value area low + 2 × proximity distance AND bar delta > 0 AND session CVD > EMA of session CVD.
Short: Highest high over the failed-auction lookback including the current bar > current value area high + proximity distance AND close < current value area high + proximity distance AND close > current value area high − 2 × proximity distance AND bar delta < 0 AND session CVD < EMA of session CVD.