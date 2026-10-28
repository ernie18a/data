Calculation: Renko wave = a run of same-direction changes in the assigned close; update the assigned close to the selected OHLC price only when it exceeds the prior assigned close by the configured box size. Box size is configured as a fixed price amount, ATR, or close divided by a configured value.
Calculation: Wave effort = sum of volume in the wave.
Calculation: Wave result = absolute distance from wave start to its most extreme price.
Calculation: Effort change = current wave effort / previous completed wave effort in the same direction - 1.
Calculation: Result change = current wave result / previous completed wave result in the same direction - 1.
Long: Up-wave AND effort change >= threshold AND result change >= threshold
Long: Up-wave AND effort change <= -threshold AND result change <= -threshold
Long: Up-wave AND ((effort change <= -threshold AND result change > -threshold) OR (-threshold < effort change < threshold AND result change >= threshold))
Long: Up-wave AND effort change >= threshold AND result change <= -threshold
Long: Down-wave AND effort change <= -threshold AND result change <= -threshold AND wave low > previous completed down-wave low AND following up-wave reaches the configured reversal-box count
Long: Down-wave AND effort change >= threshold AND (result change <= -threshold OR result change >= configured climax-extension threshold) AND following down-wave reaches the configured reversal-box count AND immediately following down-wave effort change <= -threshold AND result change <= -threshold AND wave low > climax-wave low
Short: Down-wave AND effort change >= threshold AND result change >= threshold
Short: Down-wave AND effort change <= -threshold AND result change <= -threshold
Short: Down-wave AND ((effort change <= -threshold AND result change > -threshold) OR (-threshold < effort change < threshold AND result change >= threshold))
Short: Down-wave AND effort change >= threshold AND result change <= -threshold
Short: Up-wave AND effort change <= -threshold AND result change <= -threshold AND wave high < previous completed up-wave high AND following down-wave reaches the configured reversal-box count
Short: Up-wave AND effort change >= threshold AND (result change <= -threshold OR result change >= configured climax-extension threshold) AND following up-wave reaches the configured reversal-box count AND immediately following up-wave effort change <= -threshold AND result change <= -threshold AND wave high < climax-wave high