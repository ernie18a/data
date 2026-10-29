Calculation: JVariation = Apply a Jurik moving average to the result of three successive moving averages, each using the same lookback and method: first smooth close; then smooth close minus the first average; then smooth close minus the first and second averages. Calculate on the configured indicator timeframe, which may be higher or lower than the chart timeframe; use completed bars.
Long: JVariation on the last completed indicator bar > JVariation on the preceding completed indicator bar
Long: JVariation on the last completed indicator bar > JVariation two bars earlier AND JVariation two bars earlier < JVariation three bars earlier
Short: JVariation on the last completed indicator bar < JVariation on the preceding completed indicator bar
Short: JVariation on the last completed indicator bar < JVariation two bars earlier AND JVariation two bars earlier > JVariation three bars earlier
Exit: Short, JVariation on the last completed indicator bar > JVariation on the preceding completed indicator bar
Exit: Long, JVariation on the last completed indicator bar < JVariation on the preceding completed indicator bar