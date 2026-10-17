# Iterative Epanechnikov Channel

- url: https://www.tradingview.com/script/4psPeM38-Iterative-Epanechnikov-Channel/
- type: indicator
- pine_id: PUB;6eb7dfa29f4b4a6c8a41704d71799d02
- version: 1.0

## Description

The Iterative Epanechnikov Channel is a kernel-based smoothing and state estimation framework that applies an Epanechnikov kernel regression to price data, combined with a rolling standard deviation envelope to construct adaptive dynamic channel boundaries.

Unlike kernels with infinite support that allow distant historical observations to influence the estimate, the Epanechnikov kernel uses a compact weighting structure that strictly limits influence to a finite window. This ensures that only relevant, recent price information contributes to the regression, resulting in a more localized and structurally responsive estimate of price behavior.

The resulting channel is structurally responsive while remaining statistically efficient, making it particularly effective for tracking short-to-intermediate trend development, identifying localized overextension, and adapting quickly to evolving conditions.

Its primary utility is as a state estimation and structural tracking tool for price behavior, rather than a persistence-weighted regime model.

[b]TRADING USES [/b] 
The Epanechnikov Channel is best interpreted as a localized structural filter; within a multi-model framework, it captures the immediate structural state of price, helping distinguish early transitions, active trends, and short-term disequilibrium relative to slower, memory-weighted estimators.

[b]Trend Detection[/b]
The channel basis line (Epanechnikov smoothed price) provides a responsive representation of underlying market direction. Sustained movement above or below the basis reflects directional continuation, while rapid shifts in the basis can indicate emerging changes in trend.

[b]Structural Responsiveness[/b]
Due to the compact support of the Epanechnikov kernel, only recent price data contributes to the estimate. This produces sharper turning points and faster adaptation to new information, allowing the channel to respond efficiently to changes in market structure.

[b]Mean Reversion Context[/b]
Because the estimator is more localized, price interacts with the channel boundaries more frequently. These interactions represent short-term deviations from the estimated state:

- Upper band: localized overextension
- Lower band: localized underextension

This makes the channel well-suited for mean reversion frameworks and volatility-based entry timing.

[b]State Estimation[/b]
The channel functions as a continuous estimator of market state:

- The basis represents the inferred local price state
- The envelope represents dynamic volatility dispersion around that state

Compared to heavy-tailed kernels, the Epanechnikov-based state estimate is more sensitive to current conditions and less influenced by distant history, providing a clearer view of present market structure.

[b]Volatility & Risk Context[/b]
The rolling standard deviation envelope expands and contracts based on realized volatility, providing a contextual risk framework. Wider channels indicate increased uncertainty and dispersion, while tighter channels indicate compression and lower variance conditions.

[b]THEORY[/b]
The Epanechnikov kernel is a quadratic, compact-support kernel used in Nadaraya–Watson nonparametric regression, introduced by V. A. Epanechnikov (1969, Non-Parametric Estimation of a Multivariate Probability Density, Theory of Probability & Its Applications) as the mean squared error–optimal bounded kernel; in this implementation it is applied causally (non-repainting) and centered at the current bar using only historical data, with the original startAtBar offset removed to maintain proper kernel alignment with the estimation point.

It is defined as:
K(u) = 3/4 (1 − u²), for |u| ≤ 1

Where:
---> u represents normalized distance from the current observation
---> ℓ (lookback) defines the window over which the kernel operates

Unlike Gaussian kernels, which apply exponentially decaying weights over an infinite range, the Epanechnikov kernel assigns zero weight to all observations outside its finite support. This produces a strictly localized estimator that is both computationally efficient and statistically optimal in a mean squared error sense among bounded kernels.

Because the kernel is centered on the current observation and evaluated using only past data, the implementation remains causal and non-repainting while preserving the essential structure of kernel regression.

The rolling standard deviation complements this by measuring dispersion around the estimated state, forming a volatility-adaptive envelope. Rather than acting as a strict statistical confidence interval, it provides a dynamic representation of market expansion and contraction. The Epanechnikov kernel is a localized smoothing estimator rather than a structural similarity model, thus dispersion is defined using price-based volatility rather than kernel-weighted variance, providing a stable and interpretable envelope consistent with its role as a reactive state estimator.

The iterative implementation processes data sequentially (bar-by-bar), ensuring computational efficiency and making the indicator suitable for real-time use without repainting.

[b]CALIBRATION[/b]
Calibration determines the balance between responsiveness, noise, and structural clarity.

[b]Length (Lookback)[/b]
- Lower (8–16): More responsive, increased sensitivity to short-term structure
- Medium (20–40): Balanced for swing trading and intermediate regimes
- Higher (50–64+): Smoother output, reduced noise, slower response to turning points

[b]Smoothing Mode (Single vs Double Pass)[/b]
Controls the tradeoff between responsiveness and stability:

[b]Single Pass:[/b]
- Pure Epanechnikov regression
- Maximum responsiveness
- Faster detection of structural changes
- Increased sensitivity to noise

[b]Double Pass:[/b]
- Applies the kernel regression twice
- Reduces variance and smooths fluctuations
- Produces cleaner structural output
- Introduces additional lag

This parameter allows users to tune the indicator based on whether early signal detection or stability is preferred.

[b]MARKET USAGE[/b]
Stock, Forex, Crypto, Commodities, and Indices.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SensitiveSuit

//@version=6
indicator('Iterative Epanechnikov Channel', overlay = true)

//INPUTS
length        = input.int(30,  title = 'Lookback')
src           = input.source(close, title = 'Source')
useDoublePass = input.bool(false, title = 'Use Double-Pass Smoothing')
//EPANECHNIKOV KERNEL (Causal, Centered at Current Bar, Source: Epanechnikov, V. A. (1969). Non-Parametric Estimation of a Multivariate Probability Density. Theory of Probability & Its Applications.)
epanechnikov(_src, _lookback) =>
    _currentWeight = 0.0
    _cumulativeWeight = 0.0

    for i = 0 to _lookback - 1
        y = _src[i]
        if not na(y)
            u = i / float(_lookback)
            if u <= 1.0
                w = 0.75 * (1.0 - u * u)
                _currentWeight += y * w
                _cumulativeWeight += w

    _currentWeight / _cumulativeWeight

//DOUBLE-PASS SMOOTHING (OPTIONAL BUT PRESERVED)
yhat_raw = epanechnikov(src, length)
yhat     = useDoublePass ? epanechnikov(yhat_raw, length) : yhat_raw
//ROLLING STANDARD DEVIATION (NON-REPAINTING)
rolling_stddev(_src, window) =>
    sum = 0.0
    sum_sq = 0.0

    for i = 0 to window - 1
        sum += _src[i]
        sum_sq += math.pow(_src[i], 2)

    mean = sum / window
    variance = (sum_sq / window) - math.pow(mean, 2)
    math.sqrt(math.max(variance, 0))

deviation = rolling_stddev(src, length)
//CHANNEL CONSTRUCTION
upper = yhat + deviation
lower = yhat - deviation
//PLOTS
u = plot(upper, color = color.blue, title = 'Upper', linewidth = 1)
l = plot(lower, color = color.blue, title = 'Lower', linewidth = 1)
plot(yhat, color = color.orange, title = 'Epanechnikov Basis', linewidth = 2)
fill(u, l, color = color.rgb(33, 150, 243, 90), title = "Channel Fill")
````
