Calculation: Range(L) = highest(high, L) - lowest(low, L)
Calculation: Range position(L) = -100 * (close - SMA((open + high + low + close) / 4, L)[1]) / Range(L)[1]
Calculation: Weighted score = [Σ(i=1..10) W_i * Range position(L_i) * Range(L_i) / L_(11-i)] / Σ(i=1..10) W_i; L1 through L10 are separate lookbacks ordered shortest to longest, and W1 through W10 are separate weights
Calculation: Positive-side accumulator = if weighted score > 0, nz(Positive-side accumulator[1]) + weighted score - weighted score[1], otherwise unavailable
Calculation: Negative-side accumulator = if weighted score < 0, nz(Negative-side accumulator[1]) + weighted score[1] - weighted score, otherwise unavailable
Calculation: Armed = false until weighted score crosses zero in either direction after elapsed chart-bar count exceeds L10; thereafter true
Calculation: Long setup = Armed AND Negative-side accumulator > highest(Positive-side accumulator, L10) * Long sensitivity
Calculation: Short setup = Armed AND Positive-side accumulator > highest(Negative-side accumulator, L10) * Short sensitivity
Calculation: Long peak = while long, max(previous Long peak when available, high, high[1]); otherwise unavailable
Calculation: Short trough = while short, min(previous Short trough when available, low, low[1]); otherwise unavailable
Calculation: Post-update take-profit lock = initially clear; set to long when the long take-profit condition is true, otherwise retain its previous state; clear when its previous state was long and Short setup is true; set to short when the short take-profit condition is true, otherwise retain its state; clear when its previous state was short and Long setup is true
Long: Long setup AND post-update take-profit lock is clear AND datetime is within the configured entry date window
Short: Short setup AND post-update take-profit lock is clear AND datetime is within the configured entry date window
Exit: Long, Long peak / entry price - 1 > Take-profit percent / 100 OR low <= entry price * (1 - Stop-loss percent / 100)
Exit: Short, entry price / Short trough - 1 > Take-profit percent / 100 OR high >= entry price / (1 - Stop-loss percent / 100)