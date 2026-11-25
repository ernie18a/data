Calculation: ICS structure(P,G,theta,S) = on chart bars anchored at the selected calculation bar (live bar or last completed bar), form G consecutive nonoverlapping P-bar blocks; each block value is the geometric mean of its highest high and lowest low. From the newest block, take the longest consecutive monotonic run of block values; direction is the newest-to-oldest direction unless the angle of their log-price slope divided by Yang-Zhang volatility(S) is within theta of zero, in which case direction is flat. For an up direction, upper and lower rails are log-space lines through, respectively, the lowest and highest block highs and the lowest and highest block lows; for down, through the highest and lowest block highs and the highest and lowest block lows; for flat, use the highest block high and lowest block low. Extrapolate the rails to the selected calculation bar. The six grid lookbacks P1–P6 are ordered shortest to longest; primary lookback P is separate.
Calculation: channel position = (ln(close) - ln(lower rail)) / (ln(upper rail) - ln(lower rail)), using the selected calculation bar.
Calculation: upper and lower channel distances = abs(ln(close / respective rail)) / Yang-Zhang volatility(S), using the selected calculation bar.
Calculation: scale counts = the number of the six grid ICS directions that are up and the number that are down.
Calculation: fast sign = sign of the sum of the three shortest grid ICS directions; slow sign = sign of the sum of the three longest grid ICS directions.
Calculation: compression ratio = ((ln(upper rail) - ln(lower rail)) / Yang-Zhang volatility(S)) / SMA of that normalized channel width over lookback L.
Calculation: breakout state = initialize inside; reset to inside when a nonflat primary direction changes. From inside, move to up breakout above the upper rail or down breakout below the lower rail. In up breakout, remember when upper channel distance reaches threshold D; below the lower rail switch to gapped down breakout, at or inside the upper rail return inside as failed up, or, while above the upper rail, move to up retest when remembered distance is reached and then falls below D. From up retest, below the lower rail switches to gapped down breakout, at or inside the upper rail returns inside as failed up, or distance reaching D returns to confirmed up breakout. Mirror these rules for down breakout and down retest, with an above-upper-rail cross switching to gapped up breakout, a return to or above the lower rail failing down, and distance reaching D confirming down. Use channel position and channel distances at the selected calculation bar.
Calculation: cascade raw up = fast sign up and slow sign down; cascade raw down = fast sign down and slow sign up.
Calculation: compression-release raw up = previous compression ratio below compression threshold AND current compression ratio above expansion threshold AND primary direction up AND fast sign up; raw down uses primary direction down and fast sign down. Compression threshold is lower than expansion threshold.
Calculation: icon eligible = fresh-only is off or neither directional raw condition of that icon class was true on the previous chart bar; AND cooldown is zero or no prior icon of that class exists or at least cooldown bars have elapsed since it.
Long: ICS structure(P, G, theta, S).direction = up
Short: ICS structure(P, G, theta, S).direction = down
Long: ICS structure(P1, G, theta, S).direction = up
Short: ICS structure(P1, G, theta, S).direction = down
Long: ICS structure(P2, G, theta, S).direction = up
Short: ICS structure(P2, G, theta, S).direction = down
Long: ICS structure(P3, G, theta, S).direction = up
Short: ICS structure(P3, G, theta, S).direction = down
Long: ICS structure(P4, G, theta, S).direction = up
Short: ICS structure(P4, G, theta, S).direction = down
Long: ICS structure(P5, G, theta, S).direction = up
Short: ICS structure(P5, G, theta, S).direction = down
Long: ICS structure(P6, G, theta, S).direction = up
Short: ICS structure(P6, G, theta, S).direction = down
Long: up scale count > down scale count
Short: down scale count > up scale count
Long: up scale count changes to unanimity or one below unanimity, and its previous value was different
Short: down scale count changes to unanimity or one below unanimity, and its previous value was different
Long: breakout state is up breakout or up retest
Short: breakout state is down breakout or down retest
Long: breakout state changes to up retest
Short: breakout state changes to down retest
Long: breakout confirmation changes from false to true while breakout state is up breakout
Short: breakout confirmation changes from false to true while breakout state is down breakout
Long: gap flag changes from false to true while breakout state is up breakout
Short: gap flag changes from false to true while breakout state is down breakout
Long: failed-down state begins
Short: failed-up state begins
Long: cascade raw up AND icon eligible for the cascade class
Short: cascade raw down AND icon eligible for the cascade class
Long: compression-release raw up AND icon eligible for the compression-release class
Short: compression-release raw down AND icon eligible for the compression-release class
Long: footprint is enabled and footprint data is available and footprint volume delta > 0
Short: footprint is enabled and footprint data is available and footprint volume delta < 0
Long: footprint is enabled and current footprint POC > footprint POC N bars ago
Short: footprint is enabled and current footprint POC < footprint POC N bars ago