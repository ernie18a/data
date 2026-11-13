Calculation: PriorProfile = take the last completed bar of a timeframe higher than the chart timeframe. Split its low-to-high range into N equal price levels, with level i = low + i*(range/N) for i=0..N-1. The volume at a level is the sum of volume of the lowest-timeframe bars inside that higher-timeframe bar whose low <= level <= high.
Calculation: POC = the price level with the highest volume in PriorProfile (first one found, lowest price on ties)
Calculation: VAH, VAL = start at the POC level with accumulated volume 0 (POC volume is not counted). Repeat: step up one level and add its volume, and stop if accumulated >= P% of total profile volume; then step down one level and add its volume. Skip a direction once its end of the profile is reached. Stop when accumulated >= P% of total volume or both ends are reached. VAH = the highest level reached, VAL = the lowest level reached.
Calculation: ProfHigh, ProfLow = high and low of the last completed higher-timeframe bar used for PriorProfile
Calculation: PeriodOpen = open of the first chart-timeframe bar of the currently forming higher-timeframe bar (constant for the whole forming period)
Long: PeriodOpen > VAH AND PeriodOpen < ProfHigh AND close is within a tiny tolerance of POC
Long: PeriodOpen > ProfHigh
Short: PeriodOpen < VAL AND PeriodOpen > ProfLow AND close is within a tiny tolerance of POC
Short: PeriodOpen < ProfLow