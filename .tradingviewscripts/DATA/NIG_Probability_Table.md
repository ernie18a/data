<!-- tradingview-pine-id: PUB;b3973dfbd7eb45d3baa8ba57b37ab629 -->
<!-- tradingviewscripts-format: 1 -->
# NIG Probability Table

Source: https://www.tradingview.com/script/NpswVR6U/

## Description

Normal-Inverse Gaussian Probability Table

This indicator implements the Normal-Inverse Gaussian (NIG) distribution to estimate the likelihood of future price based on recent market behavior.

📊 Key Features:
- Estimates the parameters (α: tail heaviness, β: skewness, δ: scale, μ: location)
  of the NIG distribution using a sliding window over log returns.
- Uses a numerically approximated version of the modified Bessel function (K₁) 
  to calculate the NIG probability density function (PDF).
- Normalizes the total probability across all bins to ensure the values are interpretable.
- Displays a dynamic probability table showing the chance of future returns falling into each bin.

⚠️ Notes:
- This is a real-time approximation. The Bessel function and posterior inference are simplified.
- Tail probabilities and shape parameters are sensitive to the window size and input settings.
- Useful for risk analysis, option overlays, and strategy filters.

---

## Source Code

````pine
//@version=6
indicator("NIG Probability Table", overlay=false)

windowSize = input.int(100, "Window Size")
atrLength = input.int(14, "ATR Length")
atrMult = input.float(3.0, "ATR Multiplier")
binSize = input.int(19, "Bin Size", maxval=50)
boxWidth = input.int(2, "Box Width")
showProb = input.bool(true, "Show Probability")


ret = math.log(close / close[1])
mu_hat = ta.sma(ret, windowSize)
sigma_hat = ta.stdev(ret, windowSize)
skewness = ta.sma(math.pow(ret - mu_hat, 3), windowSize) / math.pow(sigma_hat, 3)
kurtosis = ta.sma(math.pow(ret - mu_hat, 4), windowSize) / math.pow(sigma_hat, 4)

beta_hat = skewness * 0.5
alpha_hat = kurtosis * 0.75 + 1
delta_hat = sigma_hat

// NIG PDF 근사 함수
nig_pdf(x, alpha, beta, delta, mu) =>
    delta_x = math.sqrt(delta * delta + math.pow(x - mu, 2))
    z = alpha * delta_x
    bessel_approx = math.sqrt(math.pi / (2 * z)) * math.exp(-z)
    term1 = alpha * delta * bessel_approx / (math.pi * delta_x)
    term2 = math.exp(delta * math.sqrt(alpha * alpha - beta * beta) + beta * (x - mu))
    term1 * term2

// 수익률 구간 설정
pRange = atrMult * ta.atr(atrLength)
minR = +pRange/close[1]
maxR = -pRange/close[1]
bins = binSize
step = (maxR - minR) / bins

var box[] pdfLabels = array.new_box(bins)

// 누적 확률 계산
var float[] probs = array.new_float(bins, 0.0)


if barstate.islast
    total_prob = 0.0
    for i = 0 to bins - 1
        lo = minR + step * i
        loL = math.log(1+lo)
        hi = lo + step
        hiL = math.log(1+hi)
        diff = loL - hiL
        mid = (loL + hiL) / 2
        p = (nig_pdf(hiL, alpha_hat[1], beta_hat[1], delta_hat[1], mu_hat[1]) + nig_pdf(loL, alpha_hat[1], beta_hat[1], delta_hat[1], mu_hat[1])) * diff / 2  // 근사 적분
        array.set(probs, i, p)
        total_prob += p

    // 레이블 출력
    for i = 0 to bins - 1
        lo = minR + step * i
        loP = close[1] * (1+lo)
        hi = lo + step
        hiP = close[1] * (1+hi)
        prob = array.get(probs, i)
        normP = prob
        b = array.get(pdfLabels, i)
        boxText = str.tostring(normP * 100, "#.##") + "%"
        boxColor = normP < 0.05 ? color.from_gradient(normP, 0, 0.05, color.blue, color.orange) : normP < 0.1 ? color.from_gradient(normP, 0.05, 0.1, color.orange, color.red) : color.from_gradient(normP, 0.1, 0.5, color.red, color.purple)
                
        if na(b)
            b := box.new(bar_index+1, hiP, bar_index+1+boxWidth, loP, border_width=0, bgcolor=color.new(boxColor, 50), text=showProb ? boxText : na)
            array.set(pdfLabels, i, b)
        else
            b.set_left(bar_index+1)
            b.set_right(bar_index+1+boxWidth)
            b.set_top(hiP)
            b.set_bottom(loP)
            b.set_text(showProb ? boxText : na)
````
