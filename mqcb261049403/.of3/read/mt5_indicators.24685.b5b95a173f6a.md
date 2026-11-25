Calculation: Kalman velocity(applied price, period) = v, where c = max(period, 1)/100, q = sqrt(c), f[0] = applied price[0], v[0] = 0, and on each later bar v = v[1] + (applied price - f[1]) * c and f = f[1] + (applied price - f[1]) * q + v
Long: Kalman velocity crosses above zero
Short: Kalman velocity crosses below zero