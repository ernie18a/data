Calculation: Bull line = EMA of (3 × current high − highest high over each of the short, medium, and long lookbacks, summed), on the configured indicator timeframe, which may be higher or lower than the chart timeframe.
Calculation: Bear line = EMA of (lowest low over each of the short, medium, and long lookbacks, summed − 3 × current low), on the configured indicator timeframe, which may be higher or lower than the chart timeframe. The EMA uses the same smoothing period for both lines; the three lookbacks are short, medium, and long.
Long: Bull line > Bear line on the latest completed indicator bar AND Bull line <= Bear line on the preceding completed indicator bar
Short: Bull line < Bear line on the latest completed indicator bar AND Bull line >= Bear line on the preceding completed indicator bar
Exit: long, Bull line < Bear line on the latest completed indicator bar
Exit: short, Bull line > Bear line on the latest completed indicator bar