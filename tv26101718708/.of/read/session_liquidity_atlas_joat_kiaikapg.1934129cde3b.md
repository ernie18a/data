Calculation: Session = bars whose opening times fall within the selected session window; the previous session high and low are the maximum high and minimum low of the most recently completed session.
Calculation: Opening range = maximum high and minimum low of the first max(1, ceiling(opening-range duration / chart-bar duration)) bars of the current session, updated through the current bar and retained until the next session starts.
Calculation: Sweep flags = on each confirmed session bar after the first, set the high-sweep flag to high > previous session high AND close < previous session high, and set the low-sweep flag to low < previous session low AND close > previous session low; retain both flags on all other bars.
Calculation: Sweep state = reset to 0 at session start; on each subsequent session bar set to -1 on a high sweep and then to 1 on a low sweep, otherwise retain its previous value. Each sweep age resets to 0 at session start and on its corresponding sweep, and increases by 1 on each subsequent session bar without that sweep.
Calculation: Breakout state = reset to 0 at session start; on each subsequent session bar, if opening-range display is enabled, set to 1 when close > current opening-range high AND previous close <= current opening-range high, otherwise set to -1 when close < current opening-range low AND previous close >= current opening-range low; otherwise retain its previous value.
Calculation: Bias = reset to 0 at session start. On each subsequent session bar apply the first matching condition: if opening-range display is enabled AND close > current opening-range high AND previous close <= current opening-range high, set to 1; if opening-range display is enabled AND close < current opening-range low AND previous close >= current opening-range low, set to -1; if sweep state = -1 AND high-sweep age >= sweep-hold bars AND close < open, set to -1; if sweep state = 1 AND low-sweep age >= sweep-hold bars AND close > open, set to 1; if bias = 0, set to 1 when close >= open and otherwise to -1; otherwise retain its previous value. Retain bias outside the session.
Calculation: Session VWAP = cumulative sum of ((high + low + close) / 3) × volume divided by cumulative volume since session start; undefined when cumulative volume is zero.
Calculation: Liquidity score = clamp(50 + 35 × body balance + 20 × VWAP delta + 10 × (breakout state + sweep state), 0, 100), where body balance is (latest session close - session open) / session range and VWAP delta is (current close - session VWAP) / session range. Session range is the current session high minus low, retained outside the session. Use 0 for either ratio when session range is zero and for VWAP delta when session VWAP is undefined.
Long: Low-sweep flag = true
Short: High-sweep flag = true
Long: Close > current opening-range high AND previous close <= current opening-range high
Short: Close < current opening-range low AND previous close >= current opening-range low
Long: Bias > 0
Short: Bias < 0
Long: Close >= session VWAP
Short: Close < session VWAP
Long: Liquidity score >= 60
Short: Liquidity score <= 40