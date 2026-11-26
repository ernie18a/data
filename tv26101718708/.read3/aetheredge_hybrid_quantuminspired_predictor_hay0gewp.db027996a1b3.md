Calculation: safe_range = max(high - low, minimum price step)
Calculation: safe_atr = max(ATR(ATR length), minimum price step)
Calculation: range_position = (close - low) / safe_range
Calculation: volume_zscore = clip((volume - SMA(volume, volume lookback)) / stdev(volume, volume lookback), -volume z clip, volume z clip) if stdev(volume, volume lookback) > 0, else 0
Calculation: structure_score = clip((tanh((EMA(close, shorter lookback) - EMA(close, medium lookback)) / EMA(close, medium lookback) * trend scale) + tanh((close - EMA(close, shorter lookback)) / safe_atr / deviation scale) + (RSI(close, RSI length) - 50) / 50 + tanh((EMA(close, medium lookback) - EMA(close, longer lookback)) / EMA(close, longer lookback) * tier scale)) / 4, -1, 1), where shorter lookback < medium lookback < longer lookback
Calculation: absorption_score = clip((SMA(range_position, absorption lookback) * 2 - 1 + tanh((min(open, close) - low - (high - max(open, close))) / safe_range * wick scale) + tanh((close - VWAP) / safe_atr / vwap scale) + sweep) / 4, -1, 1), where sweep = sweep magnitude if low < lowest(low, sweep lookback)[1] and close > lowest(low, sweep lookback)[1]; else -sweep magnitude if high > highest(high, sweep lookback)[1] and close < highest(high, sweep lookback)[1]; else 0
Calculation: flow_score = clip((tanh(volume_zscore * sign(close - open) / spike scale) + tanh(sign(close - close[change lookback]) * (volume - SMA(volume, short volume lookback)) / SMA(volume, volume lookback) * divergence scale) + tanh((SMA(range_position * volume, accumulation lookback) / SMA(volume, volume lookback) - 0.5) * accumulation scale) + tanh(abs(volume_zscore) / extreme scale) * sign(close - close[1])) / 4, -1, 1), where the divergence and accumulation terms are 0 when SMA(volume, volume lookback) <= 0, and short volume lookback < volume lookback
Calculation: quantum_raw(c) = abs(sum over k = 0, 1, 2 of amplitude_c(F_k) * exp(i * phase_c(F_k, k)))^2 for c in {up, down, side}, where F_0 = structure_score, F_1 = absorption_score, F_2 = flow_score, amplitude_up(f) = exp(-(f - 1)^2 / (2 * coherence width^2)), amplitude_down(f) = exp(-(f + 1)^2 / (2 * coherence width^2)), amplitude_side(f) = exp(-f^2 / (2 * coherence width^2)), phase_up(f, k) = f * phase intensity * pi / 2 + k * phase step, phase_down(f, k) = -f * phase intensity * pi / 2 + k * phase step, phase_side(f, k) = abs(f) * phase intensity * pi + k * phase step
Calculation: quantum_prob(c) = (1 - decoherence) * quantum_raw(c) / (quantum_raw(up) + quantum_raw(down) + quantum_raw(side)) + decoherence / 3
Calculation: x_j = structure_score if j = structure, absorption_score if j = absorption, flow_score if j = flow, 1 if j = bias
Calculation: move_class = UP if (close - close[forecast horizon]) / close[forecast horizon] * 100 > move threshold, DOWN if (close - close[forecast horizon]) / close[forecast horizon] * 100 < -move threshold, else SIDE
Calculation: train_prob(c) = exp(S_c) / sum over c' of exp(S_c'), where S_c = sum over j of neural_weight(c, j)[1] * x_j[forecast horizon]
Calculation: neural_weight(c, j) = weight decay * neural_weight(c, j)[1] - learning rate * (train_prob(c) - [move_class = c]) * x_j[forecast horizon], where neural_weight(c, j) before the first bar = initial weight(c, j) and [move_class = c] is 1 if move_class = c, else 0
Calculation: neural_prob(c) = exp(S_c) / sum over c' of exp(S_c'), where S_c = sum over j of neural_weight(c, j) * x_j
Calculation: knn_prob(c) = sum over the K nearest samples m of w_m * [move_class_m = c] / sum over the same samples of w_m, where K = min(neighbor count, number of samples); the samples are m_b for the last training window bars b, with m_b = (structure_score, absorption_score, flow_score each taken forecast horizon bars before bar b, and move_class taken at bar b); d_m = sqrt(sum over the three features of (current feature - feature of m)^2); w_m = 1 / (1 + d_m); [move_class_m = c] is 1 if move_class of m = c, else 0; and knn_prob(c) = 1/3 when there are no samples
Calculation: combined_prob(c) = (quantum weight * quantum_prob(c) + KNN weight * knn_prob(c) + neural weight * neural_prob(c)) / (quantum weight + KNN weight + neural weight)
Calculation: dominant_state = UP if combined_prob(up) >= max(combined_prob(down), combined_prob(side)), DOWN if combined_prob(down) >= max(combined_prob(up), combined_prob(side)), else SIDE
Calculation: dominant_prob = max(combined_prob(up), combined_prob(down), combined_prob(side))
Calculation: certainty = 1 + (sum over c of combined_prob(c) * ln(combined_prob(c))) / ln(3)
Long: dominant_state == UP AND dominant_state[1] != UP AND dominant_prob >= flip threshold
Short: dominant_state == DOWN AND dominant_state[1] != DOWN AND dominant_prob >= flip threshold
Long: combined_prob(up) >= alert threshold AND combined_prob(up)[1] < alert threshold
Short: combined_prob(down) >= alert threshold AND combined_prob(down)[1] < alert threshold
Long: dominant_state == UP AND dominant_prob >= strong threshold
Short: dominant_state == DOWN AND dominant_prob >= strong threshold
Long: dominant_prob < strong threshold AND certainty >= certainty threshold AND combined_prob(up) > combined_prob(down)
Short: dominant_prob < strong threshold AND certainty >= certainty threshold AND combined_prob(down) > combined_prob(up)
Exit: long, dominant_prob < strong threshold AND certainty < certainty threshold
Exit: short, dominant_prob < strong threshold AND certainty < certainty threshold
Option: sell call, dominant_state == SIDE AND dominant_prob >= strong threshold
Option: sell put, dominant_state == SIDE AND dominant_prob >= strong threshold