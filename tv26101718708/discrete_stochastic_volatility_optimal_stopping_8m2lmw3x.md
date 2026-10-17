# Discrete Stochastic Volatility Optimal Stopping

- url: https://www.tradingview.com/script/8m2lmw3x-Discrete-Stochastic-Volatility-Optimal-Stopping/
- type: indicator
- pine_id: PUB;8814855b584843059ea3dd2cbaff3622
- version: 1.0

## Description

## Technical Documentation: Discrete Approximation of Bivariate Optimal Stopping Boundaries

### Overview

This document outlines the mathematical methodology for discretizing a continuous-time stochastic volatility model to identify optimal execution boundaries. The algorithm maps an asset's price and variance processes into standardized state spaces to detect joint extrema, triggering execution when predefined statistical thresholds are breached.

---

### 1. Price Process Normalization

To evaluate structural price dislocation, the raw asset price $P_t$ is transformed into a standardized normal state space (Z-score).

**Mathematical Formulation:**


$$Z^{(S)}_t = \frac{P_t - \mu_S}{\sigma_S}$$

Where the sample mean ($\mu_S$) and sample standard deviation ($\sigma_S$) are calculated over an $N$-period lookback window:

* **Sample Mean:** $\mu_S = \frac{1}{N} \sum_{i=0}^{N-1} P_{t-i}$
* **Sample Standard Deviation:** $\sigma_S = \sqrt{\frac{1}{N} \sum_{i=0}^{N-1} (P_{t-i} - \mu_S)^2}$

**Purpose:** This isolates the magnitude of the price deviation relative to its recent equilibrium, providing the orthogonal $x$-axis for the state space.

---

### 2. Instantaneous Variance Estimation

Continuous-time models rely on instantaneous variance, which is unobservable in discrete time. The algorithm approximates this using the annualized rolling realized variance of geometric returns.

**Mathematical Formulation:**


$$v_t = \frac{252}{N} \sum_{i=0}^{N-1} r_{t-i}^2$$

Where the continuously compounded return $r_t$ is defined as:


$$r_t = \ln\left(\frac{P_t}{P_{t-1}}\right)$$

**Purpose:** Assuming the mean daily return is zero ($\mu \approx 0$), the squared log return $r_t^2$ serves as an unbiased estimator of daily variance. The factor $\frac{252}{N}$ standardizes the sum of these squared returns into an annualized volatility metric ($v_t$).

---

### 3. Variance Process Normalization

Because variance $v_t$ is heteroskedastic and mean-reverting, the empirical variance series must also be standardized to evaluate expansion or compression relative to its own baseline.

**Mathematical Formulation:**


$$Z^{(v)}_t = \frac{v_t - \mu_v}{\sigma_v}$$

Where $\mu_v$ and $\sigma_v$ are the $N$-period sample mean and standard deviation of the variance series $v_t$.

**Purpose:** This yields a unitless metric representing the statistical extremity of the current volatility regime, forming the orthogonal $y$-axis of the state space.

---

### 4. Boundary Evaluation Logic

The discrete optimal stopping conditions approximate the analytical Hamilton-Jacobi-Bellman (HJB) boundaries by evaluating the intersection of the two state variables ($Z^{(S)}_t$ and $Z^{(v)}_t$) against arbitrary static thresholds ($\alpha$ for maxima, $\beta$ for minima).

**Entry Condition (Buy):**
Execution is triggered exclusively at the joint minimum of price and variance, defined by the logical intersection:


$$\tau_B = \inf \{ t \ge 0 \mid (Z^{(S)}_t \le \beta_S) \land (Z^{(v)}_t \le \beta_v) \}$$


*Requires price to be heavily discounted while the market regime is highly compressed.*

**Exit Condition (Sell):**
Liquidation is triggered exclusively at the joint maximum, defined by the logical intersection:


$$\tau_S = \inf \{ t \ge \tau_B \mid (Z^{(S)}_t \ge \alpha_S) \land (Z^{(v)}_t \ge \alpha_v) \}$$


*Requires price to be statistically overextended during a regime of extreme variance expansion.*

## Source Code

````pine
//@version=5
indicator("Discrete Stochastic Volatility Optimal Stopping", overlay=false)

// =========================================================================
// INPUT PARAMETERS
// =========================================================================
int lookback = input.int(252, "State Space Lookback (N)", minval=10)

// Boundary Critical Values
float beta_s = input.float(-1.5, "Buy Boundary: Price Z-Score (beta_s)", maxval=0.0)
float beta_v = input.float(-1.0, "Buy Boundary: Variance Z-Score (beta_v)", maxval=0.0)

float alpha_s = input.float(1.5, "Sell Boundary: Price Z-Score (alpha_s)", minval=0.0)
float alpha_v = input.float(1.5, "Sell Boundary: Variance Z-Score (alpha_v)", minval=0.0)

// =========================================================================
// MATHEMATICAL CALCULATIONS
// =========================================================================

// 1. Process S_t: Price Standardization (Z_S)
float mu_s = ta.sma(close, lookback)
float sigma_s = ta.stdev(close, lookback)
float z_s = sigma_s == 0 ? 0 : (close - mu_s) / sigma_s

// 2. Process v_t: Discrete Realized Variance Estimation
float log_return = math.log(close / close[1])
float squared_return = math.pow(log_return, 2)
float realized_variance = math.sum(squared_return, lookback) * (252.0 / lookback)

// 3. Variance Standardization (Z_v)
float mu_v = ta.sma(realized_variance, lookback)
float sigma_v = ta.stdev(realized_variance, lookback)
float z_v = sigma_v == 0 ? 0 : (realized_variance - mu_v) / sigma_v

// =========================================================================
// OPTIMAL STOPPING BOUNDARY EVALUATION
// =========================================================================

// Buy Region: State variables cross the lower boundary S_*(v)
bool buy_condition = (z_s <= beta_s) and (z_v <= beta_v)

// Sell Region: State variables cross the upper boundary S^*(v)
bool sell_condition = (z_s >= alpha_s) and (z_v >= alpha_v)

// =========================================================================
// PLOTTING AND VISUALIZATION
// =========================================================================

// Plot State Variables
plot(z_s, title="Price Z-Score (Z_s)", color=color.new(color.blue, 0), linewidth=2)
plot(z_v, title="Variance Z-Score (Z_v)", color=color.new(color.orange, 0), linewidth=2)

// Plot Mean Reversion Baseline
hline(0, title="Mean (0)", color=color.new(color.gray, 50), linestyle=hline.style_dotted)

// Plot Critical Boundaries (Alpha / Beta Limits)
hline(alpha_s, title="Sell Boundary (Price)", color=color.new(color.red, 50), linestyle=hline.style_dashed)
hline(alpha_v, title="Sell Boundary (Variance)", color=color.new(color.red, 50), linestyle=hline.style_dotted)

hline(beta_s, title="Buy Boundary (Price)", color=color.new(color.green, 50), linestyle=hline.style_dashed)
hline(beta_v, title="Buy Boundary (Variance)", color=color.new(color.green, 50), linestyle=hline.style_dotted)

// Highlight Execution Zones
// Fills the background when the joint distribution satisfies the optimal stopping conditions.
bgcolor(buy_condition ? color.new(color.green, 80) : na, title="Buy Execution Region")
bgcolor(sell_condition ? color.new(color.red, 80) : na, title="Sell Execution Region")
````
