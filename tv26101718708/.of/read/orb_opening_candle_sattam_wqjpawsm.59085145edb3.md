Calculation: Opening range high and low = highest high and lowest low of the bars beginning in the configured opening-range interval after the configured session start; use the configured aggregation timeframe, which may be higher, lower, or equal to the chart timeframe. On historical bars use its last completed bar when higher, or its last available intrabar when lower. Reset the range at each session start.
Calculation: Stop = opening range midpoint or the opposite opening range edge, selected by parameter and fixed at entry.
Calculation: Target = entry price plus position direction (+1 for long, -1 for short) multiplied by a configured risk multiple and the absolute difference between entry price and stop.
Long: Opening range is complete AND close > opening range high.
Short: Opening range is complete AND close < opening range low.
Long: Session is active AND no close below the opening range low has occurred this session AND no previous lower-edge trap has occurred this session AND low < opening range low AND close >= opening range low.
Short: Session is active AND no close above the opening range high has occurred this session AND no previous upper-edge trap has occurred this session AND high > opening range high AND close <= opening range high.
Long: Session is active AND a previous bar this session closed above the opening range high AND no previous upper-edge retest has occurred this session AND low <= opening range high AND close > opening range high.
Short: Session is active AND a previous bar this session closed below the opening range low AND no previous lower-edge retest has occurred this session AND high >= opening range low AND close < opening range low.
Exit: long, bar is after entry AND (low <= stop OR high >= target).
Exit: short, bar is after entry AND (high >= stop OR low <= target).
Exit: long, current bar is the last bar of the session OR the session has ended or a new opening range has begun.
Exit: short, current bar is the last bar of the session OR the session has ended or a new opening range has begun.