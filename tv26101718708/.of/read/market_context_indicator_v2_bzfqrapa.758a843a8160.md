Calculation: High-interest levels = At a fixed bar interval, examine each prior close in a lookback window, from oldest to newest. For each candidate, count closes within a separate symmetric bar window around it whose distance from the candidate is at most a price tolerance; add the volumes of those bars to the candidate bar's volume and divide by the count. Add the candidate as a level if its count is at least the minimum and it is farther than the tolerance from every existing level. On each bar, before adding candidates, increment an existing level's count and replace its stored volume with the average of its stored volume and current volume if the close is within tolerance and current volume is at least the stored volume times a volume multiplier. Increment each level's age after candidate identification and remove it when its age exceeds the expiry.
Long: Low > high two bars ago AND low minus high two bars ago >= minimum gap size.
Short: High < low two bars ago AND low two bars ago minus high >= minimum gap size.
Long: A volume pivot high is confirmed using equal left and right lookbacks AND the pivot bar's close > its open.
Short: A volume pivot high is confirmed using equal left and right lookbacks AND the pivot bar's close <= its open.
Long: Shorter-period close EMA > longer-period close EMA.
Short: Shorter-period close EMA <= longer-period close EMA.
Long: Close > an existing high-interest level AND its test count >= minimum test count.
Short: Close <= an existing high-interest level AND its test count >= minimum test count.
Long: Shorter-period close EMA crosses above longer-period close EMA.
Short: Shorter-period close EMA crosses below longer-period close EMA.