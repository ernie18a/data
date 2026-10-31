Calculation: First average = a configurable moving average of a configurable OHLC-derived price on the chart timeframe or a configurable higher or lower timeframe, evaluated on the last completed bar or the still-forming bar as configured.
Calculation: Second average = a separately configured moving average of the first average on the same timeframe and bar.
Long: First average > second average AND first average on the preceding indicator bar <= second average on the preceding indicator bar.
Short: First average < second average AND first average on the preceding indicator bar >= second average on the preceding indicator bar.
Exit: long, first average < second average OR low <= entry price minus the configured stop-loss distance OR high >= entry price plus the configured take-profit distance.
Exit: short, first average > second average OR high >= entry price plus the configured stop-loss distance OR low <= entry price minus the configured take-profit distance.