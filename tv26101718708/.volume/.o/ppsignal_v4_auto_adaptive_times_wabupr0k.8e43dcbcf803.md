Calculation: Close trend line = current-point least-squares linear regression of (current higher-timeframe close + 2×previous close + 2×close two bars ago + close three bars ago)/6; use the current higher-timeframe bar, including while it is forming.
Calculation: Open trend line = current-point least-squares linear regression of the same weighted average of higher-timeframe opens, using the same lookback as the close trend line and the current higher-timeframe bar, including while it is forming.
Long: Close trend line > open trend line
Short: Close trend line < open trend line
Exit: Long, close trend line < open trend line
Exit: Short, close trend line > open trend line