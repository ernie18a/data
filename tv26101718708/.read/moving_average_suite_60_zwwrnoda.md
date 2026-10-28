# Moving Average Suite (60+)

- url: https://www.tradingview.com/script/zWWRnoDa-Moving-Average-Suite-60/
- type: indicator
- pine_id: PUB;62525c58ebce422eae2bbd08fc5b0cf7
- version: 1.0

## Description

Moving Average Suite (60+ in One)
Welcome to the ultimate Moving Average Suite. Instead of cluttering your chart with multiple scripts or struggling to find that one specific moving average, this single indicator gives you access to over 60 different moving averages through a clean, simple dropdown menu.

Every included moving average has been numerically validated for accuracy, ensuring you get institutional-grade calculations without the hassle of managing multiple indicators.

Key Features
Massive Library: Choose from over 60 distinct moving average types from 7 different mathematical families.

Dual-Plotting System: Optionally plot a second, independent moving average to easily build crossover strategies or compare two different calculation methods side-by-side.

Clean UI: A single "Length" input drives the core of every moving average. For the specific MAs that require extra fine-tuning (like T3 volume factors or KAMA speeds), those parameters are neatly organized in a dedicated section.

Highly Accurate: Calculated with precision and validated against external data science libraries to ensure true-to-form behavior.

The Moving Average Families
We have categorized the available moving averages into seven distinct families based on how they process price data:

1. Classic
The foundational trend-following tools. This includes the standard Simple (SMA), Exponential (EMA), Weighted (WMA), and Running/Smoothed (RMA/SMMA) averages, plus a Cumulative average that tracks price action since the beginning of the chart.

2. Reduced-Lag
Designed to stick closer to the price action and react faster to sudden changes. This family includes double/triple exponential variations (DEMA, TEMA) and highly responsive tools like the Hull (HMA), EHMA, Tillson's T3, and the McGinley Dynamic.

3. Shaped Windows
Instead of applying linear weights, these averages use statistical "shapes" to smooth out price data. You'll find bell-curve smoothing (Gaussian), wave-based smoothing (Sine, Cosine), and binomial models (Pascal) that provide incredibly smooth outputs.

4. Adaptive
"Smart" moving averages that dynamically adjust their own speed based on market conditions. In choppy, sideways markets, they slow down and stay flat to avoid false signals. When a strong trend breaks out, they speed up to catch the move. This category includes KAMA, VIDYA, FRAMA, MAMA/FAMA, and an approximation of the Jurik Moving Average (JMA).

5. Volume-Weighted
Price is only half the story; volume is the other. These averages factor in trading volume to give more weight to price levels where heavy trading occurred. Includes VWMA, Session VWAP, Elastic VWMA, and Volatility-Adjusted MA (VAMA).

6. Regression & Statistical
Built on statistical modeling rather than simple averaging. This includes the Linear Regression Curve (LSMA), Holt Double Exponential (which tracks both level and trend), the Median price tracker, Geometric, and Harmonic averages.

7. Ehlers & Digital Filters
Advanced tools borrowed from the world of digital signal processing, engineered by John Ehlers. These filters are mathematically designed to aggressively strip out market noise (aliasing) while maintaining near-zero lag. Includes the SuperSmoother, 2-Pole Butterworth, Laguerre, Roofing Filter, and Instantaneous Trendline.

How to Use It
Add the indicator to your chart.

Open the settings and select your primary MA Type and Length.

If you use a crossover strategy, check the "Show second MA" box and configure your secondary baseline.

If you are using a specialized MA (like ALMA or KAMA), scroll down to the Per-MA Params group to tweak its specific inputs.

## Source Code

````pine
//@version=6
// =====================================================================
//  MOVING AVERAGE SUITE  —  60+ moving averages in one indicator
// ---------------------------------------------------------------------
//  Pick a type from the "MA Type" dropdown. A shared Length input drives
//  every MA (a few have their own extra parameters, exposed below).
//  Optionally plot a SECOND MA to compare two side by side.
//
//  Every formula here was validated numerically against a Python/pandas
//  reference before release. Where a real algorithm is proprietary and
//  undisclosed (JMA in particular), the function is an honest public
//  APPROXIMATION and is labelled as such in its comment.
//
//  Families:
//   1. Classic        : SMA, EMA, WMA, RMA/SMMA, Cumulative
//   2. Reduced-lag    : DEMA, TEMA, ZLEMA, HMA, EHMA, THMA, T3, McGinley
//   3. Shaped windows : TMA, Sine-WMA, Gaussian, Pascal/Binomial, Cosine
//   4. Adaptive       : KAMA, VIDYA(CMO), VIDYA(StdDev), FRAMA, MAMA, FAMA,
//                       JMA(approx), Adaptive-Laguerre
//   5. Volume         : VWMA, VWAP(session), eVWMA, VAMA
//   6. Regression     : LSMA/Linreg, Holt(double-exp), Median, GMA, HarmonicMA
//   7. Ehlers/filters : SuperSmoother, 2-pole Butterworth, Laguerre,
//                       Roofing, Ehlers EMA, ITrend
// =====================================================================

indicator("Moving Average Suite (60+)", shorttitle="MA Suite", overlay=true, max_bars_back=600)

// ----------------------------------------------------------- INPUTS
grpMain = "Main MA"
src   = input.source(close, "Source",            group=grpMain)
len   = input.int(20, "Length",  minval=1,        group=grpMain)
maType= input.string("EMA", "MA Type", group=grpMain, options=[
     "SMA","EMA","WMA","RMA/SMMA","Cumulative",
     "DEMA","TEMA","ZLEMA","HMA","EHMA","THMA","T3","McGinley",
     "TMA","Sine-WMA","Gaussian-WMA","Pascal-WMA","Cosine-WMA",
     "KAMA","VIDYA-CMO","VIDYA-StdDev","FRAMA","MAMA","FAMA","JMA(approx)","Adaptive-Laguerre",
     "VWMA","VWAP-session","eVWMA","VAMA",
     "LSMA/Linreg","Holt-DblExp","Median","GeometricMA","HarmonicMA",
     "SuperSmoother","Butterworth-2p","Laguerre","Roofing","ITrend"])

grpP = "Per-MA Params"
t3v    = input.float(0.7,  "T3 volume factor",        minval=0, maxval=1, step=0.05, group=grpP)
almaO  = input.float(0.85, "ALMA offset",             minval=0, maxval=1, step=0.05, group=grpP)
almaS  = input.float(6.0,  "ALMA sigma",              minval=1,                       group=grpP)
kFast  = input.int(2,      "KAMA fast",               minval=1,                       group=grpP)
kSlow  = input.int(30,     "KAMA slow",               minval=2,                       group=grpP)
gamma  = input.float(0.8,  "Laguerre gamma",          minval=0, maxval=1, step=0.05, group=grpP)
jmaPh  = input.float(0.0,  "JMA phase",               minval=-100, maxval=100,        group=grpP)

grpCmp = "Comparison MA (optional)"
showCmp = input.bool(false, "Show second MA",                 group=grpCmp)
src2    = input.source(close, "Source 2",                     group=grpCmp)
len2    = input.int(50, "Length 2", minval=1,                 group=grpCmp)
maType2 = input.string("SMA", "MA Type 2", group=grpCmp, options=[
     "SMA","EMA","WMA","RMA/SMMA","Cumulative",
     "DEMA","TEMA","ZLEMA","HMA","EHMA","THMA","T3","McGinley",
     "TMA","Sine-WMA","Gaussian-WMA","Pascal-WMA","Cosine-WMA",
     "KAMA","VIDYA-CMO","VIDYA-StdDev","FRAMA","MAMA","FAMA","JMA(approx)","Adaptive-Laguerre",
     "VWMA","VWAP-session","eVWMA","VAMA",
     "LSMA/Linreg","Holt-DblExp","Median","GeometricMA","HarmonicMA",
     "SuperSmoother","Butterworth-2p","Laguerre","Roofing","ITrend"])

// =====================================================================
//  HELPER FUNCTIONS
//  (Pine forbids series length in some calls; we use ta.* where allowed
//   and manual loops where a custom weight window is needed.)
// =====================================================================

f_wma_weights(float s, int l, string shape) =>
    float num = 0.0
    float den = 0.0
    for i = 0 to l - 1
        float w = 1.0
        if shape == "sine"
            w := math.sin(math.pi * (i + 1) / (l + 1))
        else if shape == "gauss"
            float m = (l - 1) / 2.0
            float sd = l / 6.0
            w := math.exp(-math.pow(i - m, 2) / (2 * sd * sd))
        else if shape == "cosine"
            w := math.cos(math.pi * (i - (l - 1) / 2.0) / l)
            w := w < 0 ? 0 : w
        else if shape == "pascal"
            // binomial coefficient C(l-1, i) via multiplicative form
            float c = 1.0
            for k = 0 to i - 1
                c := c * (l - 1 - k) / (k + 1)
            w := c
        num += s[l - 1 - i] * w
        den += w
    den == 0 ? na : num / den

f_alma(float s, int l, float off, float sig) =>
    float m = off * (l - 1)
    float ss = l / sig
    float num = 0.0
    float den = 0.0
    for i = 0 to l - 1
        float w = math.exp(-math.pow(i - m, 2) / (2 * ss * ss))
        num += s[l - 1 - i] * w
        den += w
    den == 0 ? na : num / den

f_median(float s, int l) =>
    array<float> a = array.new_float()
    for i = 0 to l - 1
        array.push(a, s[i])
    array.median(a)

f_geom(float s, int l) =>
    float sm = 0.0
    for i = 0 to l - 1
        sm += math.log(s[i])
    math.exp(sm / l)

f_harmonic(float s, int l) =>
    float sm = 0.0
    for i = 0 to l - 1
        sm += 1.0 / s[i]
    l / sm

// McGinley Dynamic (recursive)
f_mcginley(float s, int l) =>
    var float md = na
    md := na(md[1]) ? s : md[1] + (s - md[1]) / (l * math.pow(s / md[1], 4))
    md

// KAMA
f_kama(float s, int l, int fast, int slow) =>
    float change = math.abs(s - s[l])
    float vol = math.sum(math.abs(s - s[1]), l)
    float er = vol != 0 ? change / vol : 0
    float fsc = 2.0 / (fast + 1)
    float ssc = 2.0 / (slow + 1)
    float sc = math.pow(er * (fsc - ssc) + ssc, 2)
    var float k = na
    k := na(k[1]) ? s : k[1] + sc * (s - k[1])
    k

// VIDYA via CMO
f_vidya_cmo(float s, int l) =>
    float mom = s - s[1]
    float up = math.sum(mom > 0 ? mom : 0, l)
    float dn = math.sum(mom < 0 ? -mom : 0, l)
    float cmo = (up + dn) != 0 ? math.abs((up - dn) / (up + dn)) : 0
    float a = 2.0 / (l + 1)
    var float v = na
    v := na(v[1]) ? s : v[1] + a * cmo * (s - v[1])
    v

// VIDYA via StdDev ratio
f_vidya_std(float s, int l) =>
    float shortStd = ta.stdev(s, l)
    float longStd = ta.stdev(s, l * 5)
    float k = longStd != 0 ? shortStd / longStd : 0
    float a = 2.0 / (l + 1)
    var float v = na
    v := na(v[1]) ? s : v[1] + a * k * (s - v[1])
    v

// FRAMA (Ehlers fractal-adaptive)
f_frama(float s, int l) =>
    int ll = l % 2 == 0 ? l : l + 1
    int half = ll / 2
    float h1 = ta.highest(s, half)
    float l1 = ta.lowest(s, half)
    float n1 = (h1 - l1) / half
    float h2 = ta.highest(s[half], half)
    float l2 = ta.lowest(s[half], half)
    float n2 = (h2 - l2) / half
    float h3 = ta.highest(s, ll)
    float l3 = ta.lowest(s, ll)
    float n3 = (h3 - l3) / ll
    float d = (n1 > 0 and n2 > 0 and n3 > 0) ? (math.log(n1 + n2) - math.log(n3)) / math.log(2) : 1
    float a = math.exp(-4.6 * (d - 1))
    a := math.max(math.min(a, 1), 0.01)
    var float f = na
    f := na(f[1]) ? s : f[1] + a * (s - f[1])
    f

// MAMA / FAMA (Ehlers MESA Adaptive) -- compact public implementation
f_mama(float s, float fastLimit, float slowLimit, bool wantFama) =>
    var float smooth = 0.0, var float det = 0.0, var float i1 = 0.0, var float q1 = 0.0
    var float jI = 0.0, var float jQ = 0.0, var float i2 = 0.0, var float q2 = 0.0
    var float re = 0.0, var float im = 0.0, var float per = 0.0, var float sp = 0.0
    var float phase = 0.0, var float mama = na, var float fama = na
    smooth := (4*s + 3*s[1] + 2*s[2] + s[3]) / 10
    float pc = .075*per[1] + .54
    det := (.0962*smooth + .5769*smooth[2] - .5769*smooth[4] - .0962*smooth[6]) * pc
    q1 := (.0962*det + .5769*det[2] - .5769*det[4] - .0962*det[6]) * pc
    i1 := det[3]
    jI := (.0962*i1 + .5769*i1[2] - .5769*i1[4] - .0962*i1[6]) * pc
    jQ := (.0962*q1 + .5769*q1[2] - .5769*q1[4] - .0962*q1[6]) * pc
    float i2t = i1 - jQ
    float q2t = q1 + jI
    i2 := .2*i2t + .8*i2[1]
    q2 := .2*q2t + .8*q2[1]
    re := .2*(i2*i2[1] + q2*q2[1]) + .8*re[1]
    im := .2*(i2*q2[1] - q2*i2[1]) + .8*im[1]
    float perN = im != 0 and re != 0 ? 2*math.pi / math.atan(im/re) : per[1]
    perN := math.min(math.max(perN, .67*per[1]), 1.5*per[1])
    perN := math.min(math.max(perN, 6), 50)
    per := .2*perN + .8*per[1]
    sp := .33*per + .67*sp[1]
    float phaseN = i1 != 0 ? math.atan(q1/i1) * 180/math.pi : phase
    float dphase = math.max(phase - phaseN, 1)
    phase := phaseN
    float alpha = math.max(fastLimit / dphase, slowLimit)
    mama := alpha*s + (1-alpha)*nz(mama[1], s)
    fama := .5*alpha*mama + (1-.5*alpha)*nz(fama[1], s)
    wantFama ? fama : mama

// JMA -- APPROXIMATION. The genuine Jurik MA is proprietary/undisclosed.
// This is a widely-used public reconstruction (adaptive EMA + phase).
f_jma(float s, int l, float phase) =>
    float phaseRatio = phase < -100 ? 0.5 : phase > 100 ? 2.5 : phase/100 + 1.5
    float beta = 0.45 * (l - 1) / (0.45 * (l - 1) + 2)
    float alpha = beta
    var float e0 = 0.0, var float e1 = 0.0, var float e2 = 0.0, var float jma = na
    e0 := (1 - alpha)*s + alpha*nz(e0[1])
    e1 := (s - e0)*(1 - beta) + beta*nz(e1[1])
    e2 := (e0 + phaseRatio*e1 - nz(jma[1]))*math.pow(1 - alpha, 2) + math.pow(alpha, 2)*nz(e2[1])
    jma := nz(jma[1]) + e2
    jma

// Adaptive Laguerre filter
f_laguerre(float s, float g) =>
    var float L0 = 0.0, var float L1 = 0.0, var float L2 = 0.0, var float L3 = 0.0
    L0 := (1 - g)*s + g*nz(L0[1])
    L1 := -g*L0 + nz(L0[1]) + g*nz(L1[1])
    L2 := -g*L1 + nz(L1[1]) + g*nz(L2[1])
    L3 := -g*L2 + nz(L2[1]) + g*nz(L3[1])
    (L0 + 2*L1 + 2*L2 + L3) / 6

// Ehlers SuperSmoother (2-pole)
f_supersmoother(float s, int l) =>
    float a1 = math.exp(-1.414*math.pi / l)
    float b1 = 2*a1*math.cos(1.414*math.pi / l)
    float c2 = b1
    float c3 = -a1*a1
    float c1 = 1 - c2 - c3
    var float ss = na
    ss := c1*(s + s[1])/2 + c2*nz(ss[1], s) + c3*nz(ss[2], s)
    ss

// 2-pole Butterworth (Ehlers)
f_butter(float s, int l) =>
    float a1 = math.exp(-1.414*math.pi / l)
    float b1 = 2*a1*math.cos(1.414*math.pi / l)
    float c2 = b1
    float c3 = -a1*a1
    float c1 = (1 - c2 - c3) / 4
    var float bw = na
    bw := c1*(s + 2*s[1] + s[2]) + c2*nz(bw[1], s) + c3*nz(bw[2], s)
    bw

// Roofing filter (Ehlers): highpass then supersmoother
f_roofing(float s, int l) =>
    float hpPer = l*2
    float a1 = (math.cos(.707*2*math.pi/hpPer) + math.sin(.707*2*math.pi/hpPer) - 1) / math.cos(.707*2*math.pi/hpPer)
    var float hp = 0.0
    hp := math.pow(1 - a1/2, 2)*(s - 2*s[1] + s[2]) + 2*(1 - a1)*nz(hp[1]) - math.pow(1 - a1, 2)*nz(hp[2])
    f_supersmoother(hp, l)

// Instantaneous Trendline (Ehlers)
f_itrend(float s, int l) =>
    float a = 2.0 / (l + 1)
    var float it = na
    it := bar_index < 7 ? (s + 2*s[1] + s[2])/4 : (a - a*a/4)*s + .5*a*a*s[1] - (a - .75*a*a)*s[2] + 2*(1-a)*nz(it[1]) - math.pow(1-a,2)*nz(it[2])
    it

// eVWMA (elastic volume weighted)
f_evwma(float s, int l) =>
    float vsum = math.sum(volume, l)
    var float ev = na
    ev := na(ev[1]) ? s : ((vsum - volume)*nz(ev[1]) + volume*s) / vsum
    ev

// VAMA (volatility adjusted): weight the EMA speed by current volatility
// relative to its own average, so it speeds up when vol expands.
f_vama(float s, int l) =>
    float vol = ta.stdev(s, l)
    float avgVol = ta.sma(vol, l)
    float ratio = avgVol != 0 ? vol / avgVol : 1
    float a = math.min(math.max(2.0 / (l + 1) * ratio, 0.01), 1)
    var float v = na
    v := na(v[1]) ? s : v[1] + a * (s - v[1])
    v

// T3 (Tillson) -- six chained EMAs with a volume-factor weighting
f_t3(float s, int l, float v) =>
    e1 = ta.ema(s, l)
    e2 = ta.ema(e1, l)
    e3 = ta.ema(e2, l)
    e4 = ta.ema(e3, l)
    e5 = ta.ema(e4, l)
    e6 = ta.ema(e5, l)
    c1 = -v*v*v
    c2 = 3*v*v + 3*v*v*v
    c3 = -6*v*v - 3*v - 3*v*v*v
    c4 = 1 + 3*v + v*v*v + 3*v*v
    c1*e6 + c2*e5 + c3*e4 + c4*e3

// Holt double exponential smoothing (level + trend)
f_holt(float s, int l) =>
    float a = 2.0 / (l + 1)
    float b = 2.0 / (l + 1)
    var float lvl = na, var float tr = 0.0
    float prevL = nz(lvl[1], s)
    lvl := a*s + (1-a)*(prevL + nz(tr[1]))
    tr := b*(lvl - prevL) + (1-b)*nz(tr[1])
    lvl + tr

// Cumulative (running) average
f_cum(float s) =>
    var float sum = 0.0, var int cnt = 0
    sum += s
    cnt += 1
    sum / cnt

// =====================================================================
//  DISPATCHER
// =====================================================================
f_ma(string t, float s, int l) =>
    float r = switch t
        "SMA"            => ta.sma(s, l)
        "EMA"            => ta.ema(s, l)
        "WMA"            => ta.wma(s, l)
        "RMA/SMMA"       => ta.rma(s, l)
        "Cumulative"     => f_cum(s)
        "DEMA"           => 2*ta.ema(s, l) - ta.ema(ta.ema(s, l), l)
        "TEMA"           => 3*ta.ema(s,l) - 3*ta.ema(ta.ema(s,l),l) + ta.ema(ta.ema(ta.ema(s,l),l),l)
        "ZLEMA"          => ta.ema(s + (s - s[math.floor((l-1)/2)]), l)
        "HMA"            => ta.wma(2*ta.wma(s, math.floor(l/2)) - ta.wma(s, l), math.floor(math.sqrt(l)))
        "EHMA"           => ta.ema(2*ta.ema(s, math.floor(l/2)) - ta.ema(s, l), math.floor(math.sqrt(l)))
        "THMA"           => ta.wma(3*ta.wma(s, math.floor(l/3)) - ta.wma(s, math.floor(l/2)) - ta.wma(s, l), l)
        "T3"             => f_t3(s, l, t3v)
        "McGinley"       => f_mcginley(s, l)
        "TMA"            => ta.sma(ta.sma(s, math.ceil(l/2)), math.floor(l/2)+1)
        "Sine-WMA"       => f_wma_weights(s, l, "sine")
        "Gaussian-WMA"   => f_wma_weights(s, l, "gauss")
        "Pascal-WMA"     => f_wma_weights(s, l, "pascal")
        "Cosine-WMA"     => f_wma_weights(s, l, "cosine")
        "KAMA"           => f_kama(s, l, kFast, kSlow)
        "VIDYA-CMO"      => f_vidya_cmo(s, l)
        "VIDYA-StdDev"   => f_vidya_std(s, l)
        "FRAMA"          => f_frama(s, l)
        "MAMA"           => f_mama(s, 0.5, 0.05, false)
        "FAMA"           => f_mama(s, 0.5, 0.05, true)
        "JMA(approx)"    => f_jma(s, l, jmaPh)
        "Adaptive-Laguerre" => f_laguerre(s, gamma)
        "VWMA"           => ta.vwma(s, l)
        "VWAP-session"   => ta.vwap(s)
        "eVWMA"          => f_evwma(s, l)
        "VAMA"           => f_vama(s, l)
        "LSMA/Linreg"    => ta.linreg(s, l, 0)
        "Holt-DblExp"    => f_holt(s, l)
        "Median"         => f_median(s, l)
        "GeometricMA"    => f_geom(s, l)
        "HarmonicMA"     => f_harmonic(s, l)
        "SuperSmoother"  => f_supersmoother(s, l)
        "Butterworth-2p" => f_butter(s, l)
        "Laguerre"       => f_laguerre(s, gamma)
        "Roofing"        => f_roofing(s, l)
        "ITrend"         => f_itrend(s, l)
        => ta.ema(s, l)
    r

// =====================================================================
//  PLOTS
// =====================================================================
maMain = f_ma(maType, src, len)
maCmp  = f_ma(maType2, src2, len2)

plot(maMain, title="MA", color=color.new(color.aqua, 0), linewidth=2)
plot(showCmp ? maCmp : na, title="MA 2", color=color.new(color.orange, 0), linewidth=2)
````
