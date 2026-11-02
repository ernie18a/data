Calculation: Developing session volume profile = On each confirmed chart bar, divide the high-to-low range of all chart bars in the current, still-forming higher-timeframe session into equal price bins. Distribute each bar's volume equally among all bins from its low bin through its high bin, clamping bin indices to the profile range. The POC is the midpoint of the highest-volume bin, choosing the lowest bin on a tie. Starting at the POC bin, add the higher-volume adjacent bin until the included volume reaches the selected fraction of total profile volume, choosing the upper bin on a tie. VAH and VAL are the upper and lower edges of the included bins.
Calculation: Session VWAP = VWAP of a selected chart-bar price source, reset at the start of each still-forming higher-timeframe anchor period.
Calculation: Previous session high and low = The high and low of the last completed higher-timeframe profile session.
Long: Close crosses above the developing session POC.
Short: Close crosses below the developing session POC.
Long: Close > developing session VAH.
Short: Close < developing session VAL.
Long: Close crosses above the previous session high.
Short: Close crosses below the previous session low.
Long: Close crosses above session VWAP.
Short: Close crosses below session VWAP.