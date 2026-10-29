Calculation: Estimated buy volume = volume × (close − low) / (high − low); use volume × 0.5 when high = low
Calculation: Estimated sell volume = volume × (high − close) / (high − low); use volume × 0.5 when high = low
Calculation: Bar delta = estimated buy volume − estimated sell volume
Calculation: Cumulative delta = cumulative sum of bar delta, starting at zero
Calculation: Buy percentage = estimated buy volume / volume × 100; use 50 when volume = 0
Calculation: Sell percentage = 100 − buy percentage
Calculation: Average bar delta = simple moving average of bar delta
Calculation: Average volume = simple moving average of volume
Long: buy percentage ≥ imbalance threshold OR volume ≥ average volume × large-print multiplier AND bar delta > 0 OR bar delta < −absolute average bar delta AND close ≥ previous close OR cumulative delta > its exponential moving average OR cumulative delta > its exponential moving average AND previous cumulative delta ≤ previous exponential moving average
Short: sell percentage ≥ imbalance threshold AND buy percentage < imbalance threshold OR volume ≥ average volume × large-print multiplier AND bar delta < 0 OR bar delta > absolute average bar delta AND close ≤ previous close OR cumulative delta ≤ its exponential moving average OR cumulative delta < its exponential moving average AND previous cumulative delta ≥ previous exponential moving average