Calculation: Direction reference = previous close if previous-close direction is selected; otherwise current open.
Calculation: Relative volume = current volume / simple moving average of volume, when the average is positive.
Calculation: Body quality = abs(close - open) / (high - low) when high > low; otherwise zero.
Long: close >= direction reference
Short: close < direction reference
Long: close >= direction reference AND relative volume >= selected alert minimum threshold AND (body-quality filter = disabled OR body quality >= minimum body quality OR (relative volume >= extreme threshold AND weak-body extreme alerts = enabled))
Short: close < direction reference AND relative volume >= selected alert minimum threshold AND (body-quality filter = disabled OR body quality >= minimum body quality OR (relative volume >= extreme threshold AND weak-body extreme alerts = enabled))
Calculation: Selected alert minimum threshold = the confirmation, strong, or extreme relative-volume threshold; confirmation < strong < extreme.