Calculation: Footprint level ask and bid volumes = on each chart bar, divide its low–high range into the configured number of equal price levels, using minimum tick as the step if the range is zero; for each T1 bar within that chart bar, including a still-forming bar, split its volume equally among every level whose interval overlaps its high–low range, assigning each share to ask volume if its close is above its open and to bid volume otherwise.
Calculation: Volume Delta = sum across all configured price levels of ask volume minus bid volume.
Long: Volume Delta > 0
Short: Volume Delta <= 0
Long: At any price level, ask volume > bid volume × imbalance ratio
Short: At any price level, bid volume > ask volume × imbalance ratio
Long: Each of the highest minimum consecutive levels has ask volume > bid volume × imbalance ratio
Short: Each of the highest minimum consecutive levels has bid volume > ask volume × imbalance ratio
Long: At the highest price level, ask volume > bid volume × imbalance ratio AND bid volume < minimum tick × unfinished-auction volume multiplier
Short: At the lowest price level, bid volume > ask volume × imbalance ratio AND ask volume < minimum tick × unfinished-auction volume multiplier
Long: Close < open AND Volume Delta > 0
Short: Close > open AND Volume Delta < 0