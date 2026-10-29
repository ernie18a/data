Calculation: Prior-day high/low = high/low of the last completed daily bar (higher timeframe).
Calculation: Asia-session high/low = highest high/lowest low of the configured session, using chart-timeframe bars; use only after the session ends.
Calculation: Relative volume = current bar volume divided by the average volume of the preceding configured number of chart-timeframe bars.
Calculation: Opposite swing level = nearest prior swing low for a short setup or swing high for a long setup; a swing is a low/high with the configured number of bars on each side having no lower low/higher high, searched within the preceding 80 bars.
Calculation: Entry price = midpoint of the confirmation bar's three-bar fair value gap, if present; otherwise its close. Bearish gap: confirmation-bar high < high two bars earlier? [correction: < low two bars earlier]; bullish gap: confirmation-bar low > high two bars earlier.
Calculation: Stop = sweep extreme, adjusted by the configured buffer outward; target = entry price plus/minus configured risk multiple, where risk is the distance from entry to stop (minus for long, plus for short).
Long: low < a selected prior-day low or completed Asia-session low AND close > that pool AND (minimum sweep-volume filter is off OR relative volume meets its configured threshold).
Long: a qualifying low sweep is still active AND its extreme has not been broken AND it is within the configured maximum bars since the sweep AND close > its opposite swing level AND high - low meets the configured ATR displacement multiple.
Short: high > a selected prior-day high or completed Asia-session high AND close < that pool AND (minimum sweep-volume filter is off OR relative volume meets its configured threshold).
Short: a qualifying high sweep is still active AND its extreme has not been broken AND it is within the configured maximum bars since the sweep AND close < its opposite swing level AND high - low meets the configured ATR displacement multiple.
Exit: long, low <= stop OR high >= target; if both are touched on one bar, stop takes precedence.
Exit: short, high >= stop OR low <= target; if both are touched on one bar, stop takes precedence.