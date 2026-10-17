# Robust Bollinger Bands

- url: https://www.tradingview.com/script/V3JiqCOO-Robust-Bollinger-Bands/
- type: indicator
- pine_id: PUB;f5c365eeeeea414ab2552b6f05b1d6f3
- version: 1.0

## Description

"First and foremost, full credit and massive respect to John Bollinger for inventing the original Bollinger Bands, an absolute cornerstone of technical analysis. This script does not aim to replace his legendary work, but rather to build upon his core philosophy by applying modern robust statistics to solve extreme outlier scenarios."

Description:
Overview
The "Institutional Robust Bollinger Bands" is a highly advanced, mathematically robust volatility indicator designed to solve the most common flaws of the classic Bollinger Bands. Standard Bollinger Bands rely on a Simple Moving Average (SMA) and Standard Deviation. Because standard deviation squares the distance from the mean, extreme market events (flash crashes, large gaps, or massive outlier wicks) artificially inflate the bands. This creates a "ghosting effect" where the bands remain irrationally wide long after the volatile event has passed, leading to false signals (fakeouts).
This script completely rebuilds the volatility model using Robust Statistics, Huber Weights, Kaufman-inspired Efficiency Ratios, and Asymmetric Expansion.
How It Solves the Classic Bollinger Bands Problem
Median (Q50) vs. SMA: Instead of using an SMA for the Basis line, this indicator uses the Median (Q50). The Median is statistically immune to single-bar manipulation. Even if a massive outlier wick occurs, the Basis line remains stable, completely ignoring the "fake" movement.
Huber Weighted Dispersion vs. Standard Deviation: Instead of squaring outliers, this script uses Median Absolute Deviation (MAD) and Huber Weights. Price action that falls outside a statistical threshold (1.345 * MAD) receives heavily penalized weights. This means the bands measure true continuous volatility rather than being skewed by one-off anomalies.
Asymmetric Bands: Financial markets do not follow a perfect normal distribution (Bell Curve); they exhibit skewness and fat tails. This script calculates the Skewness (Q75 + Q25 - 2 * Q50) and Kurtosis (Q95 - Q05). If the trend is aggressively skewed to the upside, the upper band expands further while the lower band tightens, adapting to the directional momentum asynchronously.
The Role of Classic Indicators & Custom Volatility Engines
While the core logic replaces classic averages with quantiles, we still utilize the classic Simple Moving Average (SMA) for a very specific, underlying purpose: Smoothing dynamic mathematical engines.
Efficiency Ratio (ER): We calculate a raw directional efficiency (netDisp / hlRange) inspired by Perry Kaufman's methodology. We then apply an SMA to smooth this raw data. This smoothed ER dynamically adjusts the Lambda (Skewness) multiplier. When the market is trending cleanly, the asymmetry expands automatically.
Gap & Body Volatility: We measure real tick-by-tick shock (disp = body + gap). We use an SMA to compare the short-term volatility of this calculation against its long-term average. This dynamically adjusts the Mu (Fat Tail) multiplier, fortifying the bands automatically when market gaps increase.
Key Features for Traders
Self-Adaptive Multipliers: You don't need to manually change settings for different assets. The internal Efficiency Ratio and Volatility engines automatically scale the Skewness and Kurtosis multipliers based on the asset's current state.
Percentile-Based Squeeze Detection (Yellow Background): Instead of looking for an absolute lowest value (which often breaks in prolonged ranging markets), the script uses a Percentile Rank logic. If the current bandwidth falls within the narrowest 15% (adjustable) of the last 100 bars, the background turns Gold/Yellow. This provides a highly stable visual cue that a major volatility breakout is building up.
QUICK COMPARISON: CLASSIC BB vs. ROBUST BB
1. BASIS LINE (MIDDLE BAND)
Classic: SMA (Simple Moving Average) - Sensitive to spikes.
Robust: Median (Q50) - Completely immune to single-candle manipulation.
2. VOLATILITY MEASUREMENT
Classic: Standard Deviation (Squared errors) - Outliers cause "Ghosting Effect".
Robust: Huber Weighted Dispersion - Punishes outliers, keeping bands stable.
3. BAND STRUCTURE
Classic: Perfectly Symmetric - Ignores market trend bias.
Robust: Asymmetric Expansion - Adapts to price skewness (Bullish/Bearish bias).
4. DYNAMIC MULTIPLIERS
Classic: Static (User-defined) - Requires manual tuning.
Robust: Self-Adaptive - Automatically scales Kurtosis and Skewness via Efficiency Ratios.
5. SQUEEZE DETECTION
Classic: Manual observation.
Robust: Percentile-Rank Based - Background turns yellow when bandwidth is in the narrowest 15% of recent history.
Usage
Use this indicator exactly as you would use classic Bollinger Bands, but with the confidence that outlier wicks will not distort your analysis. Look for continuous Squeeze (yellow) zones to prepare for breakouts, and observe the asymmetric expansion of the bands to understand the true strength and bias of a trend.
Disclaimer: This script is for educational and analytical purposes only. It does not constitute financial advice.

## Source Code

````pine
//blntduman 2026
//@version=6
indicator(shorttitle="RBB", title="Robust Bollinger Bands", overlay=true, timeframe="", timeframe_gaps=true)

TT_LENGTH  = "Hesaplama periyodu (Tavsiye edilen: 20-50 arası)."
TT_MULT    = "Bantların uzaklık çarpanı (Tavsiye edilen: 1.5 - 3.0)."

// --- Girdiler ---
length = input.int(20, "Length (Periyot)", minval = 5, tooltip = TT_LENGTH)
mult   = input.float(2.0, "Multiplier (Çarpan)", minval = 0.1, maxval = 10, tooltip = TT_MULT)

base_lambda = input.float(1.0, "Base Lambda (Çarpıklık)", step = 0.1, group="Gelişmiş Katsayılar")
base_mu     = input.float(0.5, "Base Mu (Kuyruk Kalınlığı)", step = 0.1, group="Gelişmiş Katsayılar")

sq_lookback = input.int(100, "Daralma Geçmişi (Squeeze Lookback)", group="Daralma (Squeeze) Ayarları")
sq_threshold= input.float(15.0, "Daralma Eşiği (%)", group="Daralma (Squeeze) Ayarları", tooltip="Bant genişliği son 100 barın en dar %15'lik kısmına girdiğinde sarı yanar. Daha uzun sarı bölgeler için bu değeri artırabilirsiniz (Örn: 20).")

// --- Volatilite ve Verimlilik (Dinamik Katsayılar İçin) ---
body = math.abs(close - open)
gap  = nz(math.abs(open - close[1]), 0.0)
disp = body + gap

eps     = syminfo.mintick
hlRange = math.max(high - low, eps)
netDisp = nz(math.abs(close - close[1]), 0.0)
e_raw   = hlRange == 0 ? 0.0 : (netDisp / hlRange) * 100.0 

smooth_e = ta.sma(e_raw, length) / 100.0 
disp_ratio = ta.sma(disp, 3) / ta.sma(disp, length) 

dyn_lambda = base_lambda * (smooth_e + 0.5) 
dyn_mu     = base_mu * nz(disp_ratio, 1.0)  

// --- Yardımcı Fonksiyon (Kantil Hesaplama) ---
f_percentile(arr, p) =>
    a_copy = array.copy(arr)
    array.sort(a_copy)
    len_arr = array.size(a_copy)
    k = (len_arr - 1) * (p / 100.0)
    f = int(math.floor(k))
    c = int(math.ceil(k))
    res = f == c ? array.get(a_copy, f) : array.get(a_copy, f) * (c - k) + array.get(a_copy, c) * (k - f)
    res

// --- Sağlam (Robust) Matematiksel Çekirdek ---
float basis = na
float dev_up = na
float dev_dn = na

if bar_index >= length - 1
    a = array.new_float(length)
    for i = 0 to length - 1
        array.set(a, i, close[i])
    
    q05 = f_percentile(a, 5)
    q25 = f_percentile(a, 25)
    q50 = f_percentile(a, 50) // Orta Çizgi (Medyan)
    q75 = f_percentile(a, 75)
    q95 = f_percentile(a, 95)
    
    basis := q50
    
    devs = array.new_float(length)
    for i = 0 to length - 1
        array.set(devs, i, math.abs(array.get(a, i) - q50))
    
    mad = f_percentile(devs, 50)
    c_val = 1.345 * mad
    if c_val == 0
        c_val := 1e-9
    
    sum_w_var = 0.0
    for i = 0 to length - 1
        xi = array.get(a, i)
        err = math.abs(xi - q50)
        wi = err <= c_val ? 1.0 : (c_val / err)
        sum_w_var += wi * math.pow(xi - q50, 2)
    
    term1 = math.sqrt(sum_w_var / length)
    
    skewness_raw = q75 + q25 - 2 * q50
    
    term2_upper = skewness_raw > 0 ? dyn_lambda * skewness_raw : 0.0
    term2_lower = skewness_raw < 0 ? dyn_lambda * math.abs(skewness_raw) : 0.0
    
    term3 = dyn_mu * (q95 - q05)
    
    dev_up := mult * (term1 + term2_upper + term3)
    dev_dn := mult * (term1 + term2_lower + term3)

// Bant Değerleri
upper = basis + dev_up
lower = basis - dev_dn

// --- YENİ DARALMA (SQUEEZE) MANTIĞI ---
bandwidth = upper - lower
// Bant genişliğinin son "sq_lookback" barlarına göre yüzdelik sıralaması
bw_prank = ta.percentrank(bandwidth, sq_lookback)

// Eğer şu anki genişlik, son 100 barın en dar %15'lik kısmındaysa daralma (Squeeze) sayılır.
is_squeeze = not na(bw_prank) and (bw_prank <= sq_threshold)

// --- Çizim ve Renklendirme ---
color_basis = #2962FF
color_upper = #F23645
color_lower = #089981

// Daralma (Squeeze) anında dikkat çekici altın/sarı renk
color_bg = is_squeeze ? color.new(color.yellow, 80) : color.new(#2196F3, 92)

plot(basis, "Basis (Median)", color=color_basis, linewidth=1)
p1 = plot(upper, "Upper Band", color=color_upper, linewidth=1)
p2 = plot(lower, "Lower Band", color=color_lower, linewidth=1)

fill(p1, p2, title = "Band Background", color=color_bg)
````
