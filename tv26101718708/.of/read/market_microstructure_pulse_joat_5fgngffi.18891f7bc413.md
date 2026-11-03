Calculation: Intrabar direction = within each chart bar, compare each completed lower-timeframe bar's close with the preceding lower-timeframe close in that chart bar; the first is flat. A higher close is up, a lower close is down, and an equal close is flat.
Calculation: Directional counts and volumes = count up and down intrabar directions separately and sum the corresponding lower-timeframe volumes; exclude flat directions. Tick imbalance is (up count - down count) / (up count + down count), or zero if the denominator is zero. Volume imbalance is calculated identically using directional volumes.
Calculation: Pulse = chart-bar EMA of tick imbalance, or of 0.55 × tick imbalance + 0.45 × volume imbalance when volume weighting is enabled, clamped to [-1, 1].
Calculation: Directional streaks = within each chart bar, count consecutive up or down intrabar directions separately; a flat direction neither extends nor ends a streak, and an opposite direction ends it. Record each side's maximum and ending streak. Dominance is up if the ending up streak exceeds the ending down streak, down if the ending down streak exceeds the ending up streak, and neutral otherwise.
Calculation: Flip cooldown = chart bars elapsed since the last up or down flip that passed the cooldown; both directions share the same cooldown.
Long: Pulse > 0.
Short: Pulse < 0.
Long: Tick imbalance > 0.
Short: Tick imbalance < 0.
Long: Up directional volume > down directional volume.
Short: Down directional volume > up directional volume.
Long: Maximum up streak >= minimum streak threshold.
Short: Maximum down streak >= minimum streak threshold.
Long: Dominance = up.
Short: Dominance = down.
Long: Pulse > positive extreme threshold.
Short: Pulse < negative extreme threshold.
Long: Up count / (up count + down count) >= imbalance threshold AND up count + down count >= minimum directional count.
Short: Down count / (up count + down count) >= imbalance threshold AND up count + down count >= minimum directional count AND up count / (up count + down count) < imbalance threshold.
Long: Dominance = up AND previous chart bar's dominance = down AND maximum up streak >= minimum streak threshold AND flip cooldown >= minimum cooldown.
Short: Dominance = down AND previous chart bar's dominance = up AND maximum down streak >= minimum streak threshold AND flip cooldown >= minimum cooldown.
Long: Pulse > positive extreme threshold AND previous pulse <= positive extreme threshold AND dominance = up AND maximum up streak >= minimum streak threshold.
Short: Pulse < negative extreme threshold AND previous pulse >= negative extreme threshold AND dominance = down AND maximum down streak >= minimum streak threshold.
Long: Pulse > 0 AND previous pulse <= 0.
Short: Pulse < 0 AND previous pulse >= 0.