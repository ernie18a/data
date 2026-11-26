# Price*Volume Z-Score Oscillator

- url: https://www.tradingview.com/script/aUFko3g0-Price-Volume-Z-Score-Oscillator/
- type: indicator
- pine_id: PUB;3cf6b3021f8c4440acc676c699cb1aac
- version: 1.0

## Description

[b]Useful for finding statistically significant order blocks for OTM options on stocks. Used to find "informed traders". [/b]

To understand the math behind this indicator, we have to break it down into three distinct layers: the **Variable Construction**, the **Central Limit Theorem application**, and the **Z-Transformation**.

---

### 1. The Variable: Dollar Volume ([symbol="BMV:PV"]BMV:PV[/symbol]$)

Instead of looking at Price or Volume in isolation, we create a composite variable:


$$PV_t = P_t \times V_t$$

* **$P_t$**: The closing price at time $t$.
* **$V_t$**: The number of shares/contracts traded at time $t$.

This represents the total **nominal value** flowing through the asset. It is a more rigorous measure of market conviction than volume alone because it accounts for the capital required to move the price at that specific level.

---

### 2. The Moving Window (Rolling Statistics)

We don't compare the current [symbol="BMV:PV"]BMV:PV[/symbol]$ to the beginning of time; we compare it to a **lookback window** ($n=20$).

#### The Arithmetic Mean ($\mu$)

We calculate the Simple Moving Average of the [symbol="BMV:PV"]BMV:PV[/symbol]$ product:


$$\mu_{PV} = \frac{1}{n} \sum_{i=0}^{n-1} PV_{t-i}$$


This establishes the "expected" liquidity environment for the current regime.

#### The Standard Deviation ($\sigma$)

We measure the dispersion (volatility) of the [symbol="BMV:PV"]BMV:PV[/symbol]$ product over that same window:


$$\sigma_{PV} = \sqrt{\frac{1}{n} \sum_{i=0}^{n-1} (PV_{t-i} - \mu_{PV})^2}$$


This tells us how much the "Dollar Volume" typically fluctuates. If $\sigma$ is high, the market is erratic; if $\sigma$ is low, the market is consistent.

---

### 3. The Z-Score Transformation

The Z-score is a "dimensionless" number. It strips away the dollar signs and the share counts, leaving only a pure measure of **distance in units of volatility**.

$$Z = \frac{PV_{current} - \mu_{PV}}{\sigma_{PV}}$$

* **If $Z = 0$**: The current Dollar Volume is exactly average.
* **If $Z = 1$**: The current Dollar Volume is 1 Standard Deviation above average.
* **If $Z = 4$**: The current Dollar Volume is an extreme outlier.

---

### 4. The "4 StDev" Threshold (Statistical Significance)

Why is $Z \ge 4$ significant? We use the **Empirical Rule** and **Chebyshev’s Inequality** to understand the probability:

| Z-Score | Probability (Normal Dist.) | Frequency of Occurrence |
| --- | --- | --- |
| **1.0** | 68.2% | Common |
| **2.0** | 95.4% | Significant (95th percentile) |
| **3.0** | 99.7% | Rare (The "Three-Sigma" event) |
| **4.0** | **99.993%** | **Extreme Outlier** |

In a perfectly normal distribution, a Z-score of 4 should only happen roughly **once every 15,000 bars**.

> **The Reality of "Fat Tails":** Financial data is not perfectly normal; it has "leptokurtosis" (fat tails). This means 4 StDev events happen more often than 0.01% in trading. When you see $Z > 4$, you aren't seeing random noise; you are seeing a **non-random liquidity shock**—likely institutional block trades or massive delta-hedging rebalancing.

### Why this matters for your 0DTE research:

In 0DTE options, Gamma is at its peak. A $Z > 4$ event in the underlying [symbol="BMV:PV"]BMV:PV[/symbol]$ product suggests a sudden burst of activity that can force market makers to hedge aggressively. Since $Z$ is rolling, the "average" adapts to the day's volatility, ensuring that a "spike" in the morning is measured differently than a "spike" during the slow lunch hour.

## Source Code

````pine
//@version=6
indicator(title="Price-Volume Z-Score Oscillator", shorttitle="PV Z-Score", overlay=false)

// --- Inputs ---
len = input.int(20, "Length", minval=1)
src = input.source(close, "Source")
z_threshold = input.float(4.0, "Alert Threshold", step=0.1)

// --- Calculations ---
// 1. Calculate Price * Volume (Dollar Volume)
pv = src * volume

// 2. Calculate Rolling Mean and Standard Deviation of the PV product
pv_mean = ta.sma(pv, len)
pv_stdev = ta.stdev(pv, len)

// 3. Calculate the Z-Score
// Z = (Value - Average) / Standard Deviation
z_score = (pv - pv_mean) / pv_stdev

// --- Plotting ---
// Plot the Z-Score as a histogram or line
plot_color = z_score >= z_threshold ? color.red : color.gray
plot(z_score, title="PV Z-Score", color=plot_color, style=plot.style_columns)

// Baseline and Threshold lines
hline(0, "Baseline", color=color.gray, linestyle=hline.style_dotted)
hline(z_threshold, "4 StDev Threshold", color=color.red, linestyle=hline.style_dashed, linewidth=2)
hline(-z_threshold, "-4 StDev Threshold", color=color.blue, linestyle=hline.style_dashed)

// Background Fill for visual clarity when in extreme territory
fill(hline(z_threshold), hline(5), color=color.new(color.red, 90), title="Extreme Positive Deviation")
````
