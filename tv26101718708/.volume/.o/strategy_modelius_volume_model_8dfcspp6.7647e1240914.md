Calculation: Modelius volume = volume accumulated while the Renko direction is unchanged, divided by the number of consecutive same-direction bars when normalization is enabled; otherwise, the accumulated volume. Renko direction is up when the synthetic close rises and down when it falls. Synthetic close advances to the selected price source when it exceeds the prior synthetic close by the brick size or falls below it by the brick size; otherwise it stays unchanged. Brick size is the selected fixed amount, ATR, or fraction of close.
Calculation: Signed Modelius volume = Modelius volume when Renko direction is up, and negative Modelius volume when Renko direction is down.
Long: Signed Modelius volume crosses above zero
Short: Signed Modelius volume crosses below zero
Exit: Long, price reaches the position's profit target OR stop loss OR trailing stop
Exit: Short, price reaches the position's profit target OR stop loss OR trailing stop