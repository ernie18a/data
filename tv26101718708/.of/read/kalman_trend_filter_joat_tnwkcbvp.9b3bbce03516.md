Calculation: Kalman price and velocity = On the first bar initialize price to close, velocity to 0, and both price and velocity error covariances to 1. On each bar, including the first, predict price as previous price plus previous velocity, predict price covariance as previous price covariance plus price process noise, and predict velocity covariance as previous velocity covariance plus velocity process noise. Set residual to close minus predicted price, price gain to predicted price covariance divided by (predicted price covariance plus measurement noise), and velocity gain to predicted velocity covariance divided by (predicted velocity covariance plus 2 times measurement noise). Update price to predicted price plus price gain times residual, velocity to previous velocity plus 0.1 times velocity gain times residual, and each covariance to its predicted covariance times (1 minus its corresponding gain). Compute the same filter independently on the higher timeframe when alignment is enabled, using its last completed bar.
Long: Velocity > positive velocity threshold AND previous velocity <= positive velocity threshold AND close > Kalman price AND (higher-timeframe alignment is disabled OR last completed higher-timeframe velocity > 0).
Short: Velocity < negative velocity threshold AND previous velocity >= negative velocity threshold AND close < Kalman price AND (higher-timeframe alignment is disabled OR last completed higher-timeframe velocity < 0).
Long: Velocity > 0.
Short: Velocity < 0.
Long: Velocity > 0 AND close > Kalman price.
Short: Velocity < 0 AND close < Kalman price.
Long: Velocity > 0 AND close > Kalman price AND absolute velocity > previous absolute velocity.
Short: Velocity < 0 AND close < Kalman price AND absolute velocity > previous absolute velocity.
Long: Velocity > 0 AND previous velocity <= 0.
Short: Velocity < 0 AND previous velocity >= 0.