Calculation: Fast range filter = recursively clamp the source (OHLC4) to within a smoothed range of its prior value; smoothed range = EMA(EMA(abs(source − prior source), shorter lookback), 2 × shorter lookback − 1) × multiplier. Direction is up when the filter rises, down when it falls, and otherwise retains its prior direction.
Calculation: Slow range filter = same as fast range filter, using its own longer sampling lookback and multiplier.
Calculation: Hull = selected HMA, EHMA, or THMA of close using the selected length.
Calculation: Following-line direction = direction of a trailing line that rises when close exceeds the upper Bollinger band and falls when close is below the lower Bollinger band; otherwise it holds. On an upward signal, the line trails at low minus ATR (or low if ATR filtering is disabled) and cannot decrease; on a downward signal, it trails at high plus ATR (or high) and cannot increase.
Long: Fast range-filter direction changes from down to up AND Hull > Hull two bars ago.
Long: Slow range-filter direction changes from down to up AND Hull > Hull two bars ago (when slow range-filter entries are selected).
Long: Following-line direction changes from down to up AND Hull > Hull two bars ago (when following-line entries are selected).
Short: Fast range-filter direction changes from up to down AND Hull < Hull two bars ago.
Short: Slow range-filter direction changes from up to down AND Hull < Hull two bars ago (when slow range-filter entries are selected).
Short: Following-line direction changes from up to down AND Hull < Hull two bars ago (when following-line entries are selected).
Exit: Long, selected exit rule is Hull AND Hull > Hull two bars ago.
Exit: Short, selected exit rule is Hull AND Hull > Hull two bars ago.
Exit: Long, selected exit rule is RangeFilter AND fast range-filter direction was up two bars ago AND is down now.
Exit: Short, selected exit rule is RangeFilter AND fast range-filter direction was down one bar ago AND is up now.
Exit: Long, selected exit rule is Following/SlowRangeFilter AND following-line direction changes from up to down when following-line mode is selected, OR slow range-filter direction was up two bars ago AND is down now when slow-filter mode is selected.
Exit: Short, selected exit rule is Following/SlowRangeFilter AND following-line direction changes from down to up when following-line mode is selected, OR slow range-filter direction was down two bars ago AND is up now when slow-filter mode is selected.
Exit: Long, point rule enabled AND price reaches the entry price plus the selected profit target.
Exit: Short, point rule enabled AND price reaches the entry price minus the selected profit target.
Exit: Long, point rule enabled AND following-line direction changes from up to down AND price reaches the entry price plus the selected profit target.
Exit: Short, point rule enabled AND following-line direction changes from down to up AND price reaches the entry price minus the selected profit target.