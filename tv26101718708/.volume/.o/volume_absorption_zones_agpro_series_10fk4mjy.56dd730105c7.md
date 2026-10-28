Calculation: Volume effort = current volume / its rolling average
Calculation: Spread ratio = (high - low) / the rolling average of (high - low)
Calculation: Close location = (close - low) / (high - low)
Calculation: Lower wick share = (min(open, close) - low) / (high - low)
Calculation: Upper wick share = (high - max(open, close)) / (high - low)
Calculation: Effort score = clamp(70 × (volume effort - 1) / (high-effort threshold - 1) + 30 × clamp((current volume - rolling volume average) / rolling volume standard deviation, 0, 3) / 3, 0, 100)
Calculation: Compression score = clamp(100 × (1 - spread ratio) / (1 - maximum spread ratio), 0, 100)
Calculation: Bull close score = clamp(200 × (close location - 0.5), 0, 100)
Calculation: Bear close score = clamp(200 × (0.5 - close location), 0, 100)
Calculation: Bull quality = 0.38 × effort score + 0.34 × compression score + 0.28 × bull close score
Calculation: Bear quality = 0.38 × effort score + 0.34 × compression score + 0.28 × bear close score
Calculation: Bull zone invalidation = zone low - ATR(14) at zone creation × invalidation buffer
Calculation: Bear zone invalidation = zone high + ATR(14) at zone creation × invalidation buffer
Long: Current bar is closed AND volume effort ≥ high-effort threshold AND spread ratio ≤ maximum spread ratio AND close location ≥ strong-close threshold AND lower wick share ≥ minimum absorbed-wick share AND bull quality ≥ minimum quality
Long: A later bar touches an active bullish zone AND closes above its top AND closes above its open
Short: Current bar is closed AND volume effort ≥ high-effort threshold AND spread ratio ≤ maximum spread ratio AND close location ≤ 1 - strong-close threshold AND upper wick share ≥ minimum absorbed-wick share AND bear quality ≥ minimum quality
Short: A later bar touches an active bearish zone AND closes below its bottom AND closes below its open
Exit: Long, a later bar closes below the bullish zone's invalidation level
Exit: Short, a later bar closes above the bearish zone's invalidation level