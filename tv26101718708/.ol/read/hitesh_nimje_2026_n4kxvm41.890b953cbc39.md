Calculation: Session price trend score = ((weighted mean of session closes, weights 1 to n − arithmetic mean of session closes) × (n + 1) / 2) / (population standard deviation of session closes × sqrt(n² − 1) / (2 × sqrt(3))); calculate separately for each configured session using its bars so far
Calculation: Session buyer volume = sum of volume for session bars with close ≥ open
Calculation: Session seller volume = sum of volume for session bars with close < open
Long: Session price trend score > 0 OR session buyer volume > session seller volume
Short: Session price trend score ≤ 0 OR session buyer volume < session seller volume