# Oracle

- url: https://www.tradingview.com/script/bnmVNsy0-Oracle/
- type: indicator
- pine_id: PUB;85175ada9e06461783b20e1bbea2e7ad
- version: 1.0

## Description

# Oracle 

**Oracle** fits an adaptive, weighted polynomial regression to recent price action and projects the most likely path forward as **Japanese candlesticks** — so the forecast reads exactly like the chart you're already looking at, not an abstract line. On top of the forecast, Oracle draws a **Prediction Trail** of its own past forecasts, giving you an honest, visual track record of how accurate the model has actually been on the current symbol and timeframe.

It's designed around one principle: a projection is only as useful as your ability to trust it — so Oracle constantly shows you its confidence and adapts itself to fit the market better.



## 🔮 What it does

- Studies the last *N* candles and models their underlying curve (trend + curvature).
- Projects the next candles into the future and renders them as **up/down candlesticks with wicks**.
- Continuously scores the fit quality with **R²** and adjusts (or hides) the projection accordingly.
- Plots a **trail of past predictions** so you can compare "what the model expected" against "what actually happened."



## 🧠 How it works

- A **weighted quadratic regression** is fitted to recent closes, with more weight on the newest candles so the model stays responsive.
- The fitted curve is extrapolated forward to build the projected candles.
- An **R² confidence score** (0–100%) measures how cleanly price fits the model — high R² means a clean, trend-like structure; low R² means choppy, unpredictable conditions.
- Optional market filters refine the raw projection so it respects real market behavior.


## ✨ Key features

**Projection**
- Future path drawn as **projected candlesticks** (body + wick), color-coded up/down.
- Adjustable projection length, candle body width, and wick size.

**Prediction Trail (track record)**
- Plots the model's earlier forecasts, shifted forward, so each point lines up with the candle it was predicting.
- Instantly shows whether the model has been leading price accurately or diverging.
- Adjustable horizon, color, and width.

**Accuracy Enhancements (all optional)**
- **Auto-Optimize Lookback** — automatically selects the lookback window with the best fit (highest R²), so you don't have to guess.
- **Damp Far Extrapolation** — blends distant candles toward a straight line so the curve stays realistic and never "explodes."
- **Scale by Confidence** — flattens the projection toward price when fit quality is low, keeping forecasts conservative when the market is unclear.

**Context & filters**
- **ATR confidence bands** around the projection (static or volatility-adjusted).
- **Volume Delta** bias, **EMA trend** filter, **RSI** softening, and **Support/Resistance** capping — each toggled independently.

**Usability**
- R² confidence label + info readout (ATR, volume ratio, volatility factor).
- Fully customizable colors, widths, label sizes, and an analysis start-date filter.
- **Every input has a built-in tooltip** explaining what it does.


## ⚙️ Suggested workflow

1. Add Oracle to a clean chart and keep the default enhancements on.
2. Read the **R² label** first — the higher it is, the more weight the projection deserves.
3. Check the **Prediction Trail**: if it has been hugging price recently, the model is in tune with this market; if it's diverging, treat the forecast with caution.
4. Use the projected candles as a **scenario / bias**, then confirm with your own strategy and risk plan.

**Tips:** Raise the *Min Confidence Threshold* and keep *Damping* on for calmer, more realistic forecasts. Use a longer lookback for swing context and a shorter one for intraday.


## 📈 Best on

Works on **any market and timeframe** — crypto, forex, indices, metals, and stocks. Trending and structured conditions produce the highest R² and the most reliable projections; in pure chop, low confidence will (correctly) flag the projection as unreliable.


## ⚠️ Disclaimer

Oracle is a **statistical projection and study tool**. It does not predict the future, guarantee any outcome, or constitute financial advice. Markets are uncertain — always do your own analysis and manage your risk. Past model behavior (including the Prediction Trail) does not guarantee future accuracy.

## Source Code

````pine

//@version=6
indicator("Oracle", shorttitle="Oracle", overlay=true, max_lines_count=500, max_labels_count=500)

// === MAIN INPUTS ===
length = input.int(50, minval=10, maxval=200, title="Historical Lookback", tooltip="Number of past candles used to fit the model.\nعدد الشموع الماضية المستخدمة لبناء النموذج.")
proj_len = input.int(20, minval=5, maxval=50, title="Projection Candles", tooltip="How many candles to project into the future.\nعدد الشموع المُسقطة إلى المستقبل.")
proj_color_up = input.color(color.green, title="Projection Up Color", tooltip="Color of bullish projected candles.\nلون الشموع المتوقّعة الصاعدة.")
proj_color_down = input.color(color.red, title="Projection Down Color", tooltip="Color of bearish projected candles.\nلون الشموع المتوقّعة الهابطة.")
candle_width = input.int(6, minval=1, maxval=20, title="Projection Candle Body Width", tooltip="Thickness (pixels) of the projected candle body.\nسماكة جسم الشمعة المتوقّعة (بالبكسل).")
wick_ratio   = input.float(0.3, minval=0.0, maxval=2.0, step=0.1, title="Projection Wick Size (×ATR)", tooltip="Wick length as a multiple of ATR.\nطول الظل كمضاعف من ATR.")

// === 🚀 ACCURACY ENHANCEMENTS ===
use_adaptive_len = input.bool(true, title="Auto-Optimize Lookback (R²)", tooltip="Automatically pick the lookback length that fits best (highest R²).\nاختيار طول النافذة الأفضل مطابقةً تلقائياً (أعلى R²).")
adaptive_min = input.int(20, minval=10, maxval=200, title="Min Lookback to Test", tooltip="Smallest lookback the optimizer will try.\nأصغر طول نافذة يجرّبه المُحسِّن.")
use_conf_scaling = input.bool(true, title="Scale Projection by Confidence", tooltip="Flatten the projection toward price when fit quality (R²) is low.\nتسطيح الإسقاط نحو السعر عندما تكون جودة المطابقة R² منخفضة.")
use_curve_damp = input.bool(true, title="Damp Far Extrapolation", tooltip="Blend far candles toward a straight line so the curve doesn't explode.\nمزج الشموع البعيدة نحو خط مستقيم كي لا ينفجر المنحنى.")
curve_damp = input.float(0.5, minval=0.0, maxval=1.0, step=0.1, title="Damping Strength", tooltip="How strongly far candles are pulled toward a straight line.\nمدى سحب الشموع البعيدة نحو الخط المستقيم.")

// === PREDICTION TRAIL (past forecast) ===
show_trail  = input.bool(true,  title="Show Prediction Trail", tooltip="Show the line of past forecasts to compare with what actually happened.\nإظهار خط التوقّعات السابقة لمقارنته بما حدث فعلاً.")
trail_color = input.color(color.new(color.aqua, 0), title="Prediction Trail Color", tooltip="Color of the prediction trail line.\nلون خط مسار التوقّع.")
trail_width = input.int(2, minval=1, title="Prediction Trail Width", tooltip="Thickness of the trail line.\nسماكة خط المسار.")
trail_horizon = input.int(5, minval=1, maxval=50, title="Prediction Trail Horizon (candles ahead)", tooltip="How many candles ahead the trail forecasts (then drawn shifted back to compare).\nكم شمعة للأمام يتوقّع المسار (ثم يُرسم مُزاحاً للخلف للمقارنة).")

// === FILTER TOGGLES ===
use_atr = input.bool(true, title="Use ATR Filter", tooltip="Draw volatility (ATR) confidence bands around the projection.\nرسم نطاقات تذبذب (ATR) حول الإسقاط.")
atr_mult = input.float(1.5, minval=0.5, maxval=3.0, step=0.1, title="ATR Multiplier", tooltip="Width of the ATR bands.\nعرض نطاقات ATR.")
use_dynamic_atr = input.bool(true, title="Dynamic ATR Scaling (Volatility Adjusted)", tooltip="Scale the bands by current vs average volatility.\nمعايرة النطاقات حسب التذبذب الحالي مقابل المتوسط.")
atr_lookback = input.int(50, minval=20, maxval=100, title="ATR Comparison Period", tooltip="Period for the average-volatility comparison.\nفترة مقارنة متوسط التذبذب.")

use_volume = input.bool(true, title="Use Volume Delta", tooltip="Bias the projection by buying vs selling volume.\nتحيّز الإسقاط حسب حجم الشراء مقابل البيع.")
volume_lookback = input.int(10, minval=5, maxval=20, title="Volume Lookback", tooltip="Candles used to measure the volume balance.\nعدد الشموع لقياس توازن الحجم.")
volume_impact = input.float(0.05, minval=0.01, maxval=0.15, step=0.01, title="Volume Impact %", tooltip="How strongly volume bends the projection.\nمدى تأثير الحجم على انحناء الإسقاط.")

use_ema_trend = input.bool(true, title="Use EMA Trend Filter", tooltip="Reduce projections that go against the EMA trend.\nتقليل الإسقاطات المعاكسة لاتجاه EMA.")
ema_length = input.int(50, minval=20, maxval=200, title="EMA Length", tooltip="EMA period for the trend filter.\nفترة EMA لفلتر الاتجاه.")
counter_trend_reduction = input.float(0.5, minval=0.1, maxval=0.9, step=0.1, title="Counter-Trend Reduction %", tooltip="How much to shrink counter-trend moves.\nمقدار تقليص الحركات المعاكسة للاتجاه.")

use_rsi = input.bool(false, title="Use RSI Filter", tooltip="Soften projections when RSI is overbought/oversold.\nتلطيف الإسقاطات عند تشبّع RSI شراءً/بيعاً.")
rsi_length = input.int(14, minval=7, maxval=30, title="RSI Length", tooltip="RSI period.\nفترة RSI.")
rsi_overbought = input.int(70, minval=50, maxval=90, title="RSI Overbought", tooltip="RSI overbought level.\nمستوى تشبّع شراء RSI.")
rsi_oversold = input.int(30, minval=10, maxval=50, title="RSI Oversold", tooltip="RSI oversold level.\nمستوى تشبّع بيع RSI.")

use_sr_levels = input.bool(false, title="Use Support/Resistance", tooltip="Stop the projection at nearby support/resistance.\nإيقاف الإسقاط عند الدعم/المقاومة القريبة.")
sr_lookback = input.int(50, minval=20, maxval=200, title="S/R Lookback", tooltip="Lookback for the support/resistance pivots.\nفترة البحث عن نقاط الدعم/المقاومة.")

// === CONFIDENCE & DISPLAY ===
show_confidence = input.bool(true, title="Show R-Squared Confidence", tooltip="Show the R² fit-quality label and hide low-confidence projections.\nإظهار جودة المطابقة R² وإخفاء الإسقاطات منخفضة الثقة.")
confidence_threshold = input.float(0.5, minval=0.1, maxval=0.9, step=0.05, title="Min Confidence Threshold", tooltip="Hide the projection if R² is below this value.\nإخفاء الإسقاط إذا كان R² أقل من هذه القيمة.")
show_bands = input.bool(true, title="Show Confidence Bands", tooltip="Show the ATR confidence bands.\nإظهار نطاقات ثقة ATR.")
band_frequency = input.int(5, minval=2, maxval=10, title="Band Frequency (Candles)", tooltip="Draw a confidence band every N candles.\nرسم نطاق ثقة كل N شمعة.")
show_labels = input.bool(true, title="Show Labels", tooltip="Show the price / info labels.\nإظهار ملصقات الأسعار/المعلومات.")
label_size = input.string("small", options=["tiny", "small", "normal", "large"], title="Label Size", tooltip="Size of the labels.\nحجم الملصقات.")

// === WEIGHTED REGRESSION SETTINGS ===
use_weighted = input.bool(true, title="Use Weighted Regression", tooltip="Give recent candles more weight than older ones in the fit.\nإعطاء الشموع الأحدث وزناً أكبر من الأقدم في المطابقة.")
weight_strength = input.float(1.0, minval=0.1, maxval=2.0, step=0.1, title="Weight Strength", tooltip="How much extra weight recent candles get.\nمقدار الوزن الإضافي للشموع الأحدث.")

// === CALCULATE FILTERS ===
atr_val = ta.atr(14)
ema_val = ta.ema(close, ema_length)
rsi_val = ta.rsi(close, rsi_length)

// Dynamic ATR Scaling
volatility_factor = 1.0
if use_dynamic_atr
    atr_long = ta.atr(atr_lookback)
    if atr_long > 0
        volatility_factor := atr_val / atr_long
        volatility_factor := math.min(math.max(volatility_factor, 0.5), 2.0)

// Volume Delta
bullish_vol = 0.0
bearish_vol = 0.0
for i = 0 to volume_lookback - 1
    if close[i] > open[i]
        bullish_vol := bullish_vol + volume[i]
    else
        bearish_vol := bearish_vol + volume[i]

volume_ratio = bullish_vol / (bullish_vol + bearish_vol)
vol_strength = (volume_ratio - 0.5) * 2

// Current trend direction
current_trend = close > ema_val ? 1 : -1

// === FIND SUPPORT/RESISTANCE LEVELS ===
find_sr_levels(src, lookback) =>
    pivot_high = ta.pivothigh(src, lookback, lookback)
    pivot_low = ta.pivotlow(src, lookback, lookback)
    [pivot_high, pivot_low]

[resistance, support] = find_sr_levels(high, sr_lookback)
nearest_resistance = resistance
nearest_support = support

// === SHARED WEIGHTED-QUADRATIC FIT (projection + adaptive optimizer + trail) ===
f_fit(len, useW, wstr) =>
    float s0 = 0.0
    float sx = 0.0
    float sx2 = 0.0
    float sx3 = 0.0
    float sx4 = 0.0
    float sy = 0.0
    float sxy = 0.0
    float sx2y = 0.0
    float meanY = 0.0
    for i = 0 to len - 1
        w = useW ? 1.0 + (i / len) * wstr : 1.0
        x = i + 1.0
        y = close[len - 1 - i]
        s0   += w
        sx   += x * w
        sx2  += x * x * w
        sx3  += x * x * x * w
        sx4  += x * x * x * x * w
        sy   += y * w
        sxy  += x * y * w
        sx2y += x * x * y * w
        meanY += y
    meanY := meanY / len
    det = s0 * (sx2 * sx4 - sx3 * sx3) - sx * (sx * sx4 - sx3 * sx2) + sx2 * (sx * sx3 - sx2 * sx2)
    float a = na
    float b = na
    float c = na
    float r2 = 0.0
    if det != 0
        a := (sy * (sx2 * sx4 - sx3 * sx3) - sx * (sxy * sx4 - sx3 * sx2y) + sx2 * (sxy * sx3 - sx2 * sx2y)) / det
        b := (s0 * (sxy * sx4 - sx3 * sx2y) - sy * (sx * sx4 - sx3 * sx2) + sx2 * (sx * sx2y - sxy * sx2)) / det
        c := (s0 * (sx2 * sx2y - sxy * sx3) - sx * (sx * sx2y - sxy * sx2) + sy * (sx * sx3 - sx2 * sx2)) / det
        float sst = 0.0
        float ssr = 0.0
        for j = 0 to len - 1
            xx = j + 1.0
            yy = close[len - 1 - j]
            yp = a + b * xx + c * xx * xx
            sst += (yy - meanY) * (yy - meanY)
            ssr += (yy - yp) * (yy - yp)
        r2 := sst > 0 ? 1 - ssr / sst : 0.0
        r2 := math.max(math.min(r2, 1), 0)
    [a, b, c, r2]

// R² only — used by the adaptive optimizer (keeps tuple-destructuring out of the loop)
f_fit_r2(len, useW, wstr) =>
    [fa, fb, fc, fr2] = f_fit(len, useW, wstr)
    fr2

// forecast made `trail_horizon` bars ago, drawn here → compare to the real candle
[t_a, t_b, t_c, t_r2] = f_fit(length, use_weighted, weight_strength)
t_fx = length + trail_horizon
float trail_fc = na
if not na(t_a)
    trail_fc := t_a + t_b * t_fx + t_c * t_fx * t_fx
    if use_curve_damp
        t_slope = t_b + 2 * t_c * length
        t_lin = (t_a + t_b * length + t_c * length * length) + t_slope * trail_horizon
        t_blend = curve_damp * math.min(1.0, trail_horizon / proj_len)
        trail_fc := trail_fc * (1 - t_blend) + t_lin * t_blend
    if use_conf_scaling
        trail_fc := close + (trail_fc - close) * t_r2
trail_val = show_trail and bar_index >= length ? trail_fc : na
plot(trail_val, "Prediction Trail", color=trail_color, linewidth=trail_width, offset=trail_horizon)

// === MAIN PROJECTION LOGIC ===
if barstate.islast
    // --- Adaptive lookback: pick the window that fits best (highest R-squared) ---
    eff_len = length
    if use_adaptive_len
        float bestR2 = -1.0
        for k = 0 to 4
            tl = math.max(10, int(math.round(adaptive_min + (length - adaptive_min) * k / 4.0)))
            r2t = f_fit_r2(tl, use_weighted, weight_strength)
            if r2t > bestR2
                bestR2 := r2t
                eff_len := tl

    [a, bb, c, r_squared] = f_fit(eff_len, use_weighted, weight_strength)
    low_confidence = na(a) or r_squared < confidence_threshold

    proj_y = array.new<float>(0)
    proj_y.push(close)

    if not na(a)
        for i = 1 to proj_len
            fx = eff_len + i * 1.0
            fy = a + bb * fx + c * fx * fx

            if use_curve_damp
                slope = bb + 2 * c * eff_len
                lin = (a + bb * eff_len + c * eff_len * eff_len) + slope * i
                blend = curve_damp * (i / proj_len)
                fy := fy * (1 - blend) + lin * blend

            if use_volume
                vol_adjust = vol_strength * (i / proj_len) * volume_impact
                fy := fy * (1 + vol_adjust)

            if use_ema_trend
                if (fy < close and current_trend > 0) or (fy > close and current_trend < 0)
                    fy := close + (fy - close) * (1 - counter_trend_reduction)

            if use_rsi
                if rsi_val > rsi_overbought and fy > close
                    fy := close + (fy - close) * 0.3
                if rsi_val < rsi_oversold and fy < close
                    fy := close + (fy - close) * 0.3

            if use_sr_levels and not na(nearest_resistance) and not na(nearest_support)
                if fy > nearest_resistance and close < nearest_resistance
                    fy := nearest_resistance * 0.98
                if fy < nearest_support and close > nearest_support
                    fy := nearest_support * 1.02

            if use_conf_scaling
                fy := close + (fy - close) * r_squared

            proj_y.push(fy)
    
    var array<line> lines = array.new<line>(0)
    var array<line> band_lines = array.new<line>(0)
    var array<label> labels = array.new<label>(0)
    
    if lines.size() > 0
        for l in lines
            l.delete()
        lines.clear()
    
    if band_lines.size() > 0
        for l in band_lines
            l.delete()
        band_lines.clear()
    
    if labels.size() > 0
        for l in labels
            l.delete()
        labels.clear()
    
    if not low_confidence or not show_confidence
        for i = 1 to proj_y.size() - 1
            x2 = bar_index + i
            o  = proj_y.get(i - 1)
            y2 = proj_y.get(i)
            body_top = math.max(o, y2)
            body_bot = math.min(o, y2)

            wlen = atr_val * wick_ratio * (use_dynamic_atr ? volatility_factor : 1.0)
            hi = body_top + wlen
            lo = body_bot - wlen

            col = y2 >= o ? proj_color_up : proj_color_down
            alpha = math.min(55, int(i / proj_len * 45))
            if low_confidence and show_confidence
                alpha := 65

            wick_line = line.new(x2, lo, x2, hi, color=color.new(col, alpha), width=1)
            lines.push(wick_line)
            body_line = line.new(x2, body_bot, x2, body_top, color=color.new(col, alpha), width=candle_width)
            lines.push(body_line)
            
            if use_atr and show_bands and i % band_frequency == 0
                atr_adj = atr_val * atr_mult
                if use_dynamic_atr
                    atr_adj := atr_adj * volatility_factor
                
                band_expand = 1 + (i / proj_len * 0.5)
                upper = y2 + (atr_adj * band_expand)
                lower = y2 - (atr_adj * band_expand)
                
                band_up = line.new(x2, y2, x2, upper, color=color.new(color.gray, 30), width=1, style=line.style_dotted)
                band_down = line.new(x2, y2, x2, lower, color=color.new(color.gray, 30), width=1, style=line.style_dotted)
                band_lines.push(band_up)
                band_lines.push(band_down)
                
                if show_labels and i == proj_len
                    upper_text = "Upper: " + str.tostring(upper, "#.##")
                    label_up = label.new(x2, upper, text=upper_text, color=color.new(color.gray, 50), textcolor=color.white, style=label.style_label_down, size=label_size)
                    labels.push(label_up)
                    
                    lower_text = "Lower: " + str.tostring(lower, "#.##")
                    label_down = label.new(x2, lower, text=lower_text, color=color.new(color.gray, 50), textcolor=color.white, style=label.style_label_up, size=label_size)
                    labels.push(label_down)
        
        if show_confidence
            confidence_pct = r_squared * 100
            confidence_color = r_squared >= 0.7 ? color.green : (r_squared >= 0.4 ? color.orange : color.red)
            
            label_text = "R2: " + str.tostring(confidence_pct, "#.#") + "%"
            if low_confidence
                label_text := label_text + " LOW CONFIDENCE"
            
            conf_label = label.new(bar_index + 1, high * 1.01, text=label_text, color=color.new(confidence_color, 80), textcolor=color.white, style=label.style_label_down, size=label_size)
            labels.push(conf_label)
            
            if show_labels
                info_text = "ATR: " + str.tostring(atr_val, "#.##") + " | Vol Ratio: " + str.tostring(volume_ratio * 100, "#") + "%"
                
                if use_dynamic_atr
                    info_text := info_text + " | Vol Factor: " + str.tostring(volatility_factor, "#.##")
                
                info_label = label.new(bar_index + 1, low * 0.99, text=info_text, color=color.new(color.white, 30), textcolor=color.white, style=label.style_label_up, size="tiny")
                labels.push(info_label)
    
    else
        warn_label = label.new(bar_index + 1, close, text="LOW CONFIDENCE - PROJECTION HIDDEN", color=color.new(color.red, 80), textcolor=color.white, style=label.style_label_down, size="large")
        labels.push(warn_label)
````
