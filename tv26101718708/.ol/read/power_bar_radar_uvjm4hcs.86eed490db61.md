Calculation: Move score = (current close − previous close) divided by the standard deviation of close-to-close changes over the statistical lookback, including the current change; use 0 if the standard deviation is 0
Calculation: Close location = (close − low) / (high − low); use 0.5 if high = low
Calculation: Average range = arithmetic mean of high − low over the statistical lookback, including the current bar
Calculation: Average volume = arithmetic mean of volume over the volume lookback, including the current bar
Calculation: Prior high = highest high over the structure lookback, excluding the current bar
Calculation: Prior low = lowest low over the structure lookback, excluding the current bar
Long: Move score >= move threshold AND Close location >= close-location threshold AND high − low > Average range × range factor AND (volume filter disabled OR (volume > 0 AND Average volume > 0 AND volume > Average volume × volume factor)) AND (structure filter disabled OR high > Prior high)
Short: Move score <= −move threshold AND Close location <= 1 − close-location threshold AND high − low > Average range × range factor AND (volume filter disabled OR (volume > 0 AND Average volume > 0 AND volume > Average volume × volume factor)) AND (structure filter disabled OR low < Prior low)