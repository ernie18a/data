Calculation: Row buy and sell volume = On each chart bar, divide its low-to-high range into the profile-row-count equal-price rows; assign each T1 intrabar’s positive volume to the row containing its (high + low) / 2, classifying it as buy when its close exceeds the previous T1 close, sell when it is lower, and splitting volume equally when equal; for the first T1 intrabar in a chart bar, compare its close with its open. Use T1 intrabars within the chart bar, including the forming T1 bar; if there is no classified intrabar volume, row volumes remain zero.
Calculation: Volume Delta = sum of row buy volume − sum of row sell volume; when there are no T1 intrabars or their total volume is zero, use chart-bar volume × (close − low) / (high − low) as buy volume and the remainder as sell volume, using an even split when high = low; use zero delta when chart-bar volume is not positive.
Calculation: Diagonal row imbalance = For each row with total volume ≥ minimum-row-volume, a buy candidate exists when row buy volume ≥ imbalance-ratio × sell volume in the row below, or when that lower-row sell volume is zero and this row has positive buy volume and zero sell volume; a sell candidate exists symmetrically against buy volume in the row above, treating a missing adjacent row as zero. If both candidates exist, classify the row as buy when its buy volume ≥ its sell volume, otherwise as sell. Do not classify rows when there is no classified intrabar volume.
Long: Any row has a buy Diagonal row imbalance.
Short: Any row has a sell Diagonal row imbalance.
Long: The highest-price run of consecutive buy Diagonal row imbalances whose length meets the stack-length parameter exists.
Short: The highest-price run of consecutive sell Diagonal row imbalances whose length meets the stack-length parameter exists.
Long: The number of buy Diagonal row imbalances on the chart bar ≥ the burst-count parameter.
Short: The number of sell Diagonal row imbalances on the chart bar ≥ the burst-count parameter.
Long: Volume Delta > 0.
Short: Volume Delta < 0.
Long: Volume Delta > 0 after a prior run of at least the delta-flip run-length parameter of negative-delta chart bars; zero-delta bars do not break the run.
Short: Volume Delta < 0 after a prior run of at least the delta-flip run-length parameter of positive-delta chart bars; zero-delta bars do not break the run.
Long: Per-bar POC(row total volume, row midpoint prices; lowest-price row on ties) is higher than the previous chart bar’s POC, and the change in ticks ≥ the POC-shift threshold.
Short: Per-bar POC(row total volume, row midpoint prices; lowest-price row on ties) is no higher than the previous chart bar’s POC, and the absolute change in ticks ≥ the POC-shift threshold.