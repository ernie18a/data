# CS FVG Wave Pro

- url: https://www.tradingview.com/script/Pk4hT7gZ/
- type: indicator
- pine_id: PUB;71b4fbf69d5f44fb9811c91e33457f10
- version: 1.0

## Description

CS FVG Wave Pro: Institutional Volume Profiler & Liquidity Engine
Stop trading Fair Value Gaps (FVGs) blind. 90% of Smart Money Concepts (SMC) traders enter the market based on the 50% mark of a liquidity void, assuming the money is evenly distributed. CS FVG Wave Pro eliminates the guesswork and gives you an exact X-ray of the institutional order flow within each Gap.

By merging pure Price Action with lower timeframe (LTF) Order Flow analysis, this indicator projects an aesthetic "volume cloud" that reveals exactly where the true high-liquidity node (POC) is waiting to be mitigated.

All of this is packed into a minimalist "Naked Chart" design, built specifically for traders who hate cluttered screens.

🔥 CORE FEATURES
☁️ Aesthetic Cloud Engine: Forget about classic, ugly, jagged histograms. The script processes internal volume and renders it as a solid, gradient cloud that visually flows with price action.

🎯 Dynamic POC (Liquidity Laser): The Point of Control (the exact price with the highest injected volume) doesn't stay stuck in the past. It projects as a dynamic line and a clean label that tracks the price in real-time until the zone is mitigated.

🛡️ Institutional Volume Filter: Not all Gaps matter. The internal engine compares the FVG's volume against a general moving average. If the void was created with low volume (traps or low liquidity sessions), the indicator simply won't draw it. Trade only the footprints of smart money.

📊 Data Transparency (Real vs. Estimated): TradingView sometimes limits lower timeframe history. This indicator is 100% honest with you:

POC (White Text): Indicates that real intraday volume was mapped with pinpoint accuracy.

POC (Est) (Gray Text): If historical data is unavailable, the algorithm injects a mathematical Gaussian curve to estimate the gap's center of gravity, visually warning you so you can adjust your risk management.

👻 Ghost Mode & Auto-Cleanup: Keep your screen immaculate. Once the price pierces and mitigates a level, the entire zone disappears (or turns into a gray ghost, depending on your settings), eliminating the visual noise of past supports/resistances.

⚙️ HOW TO USE IT
Add the indicator to your chart (ideal for 5m, 15m, 1H, or 4H timeframes).

Look for the densest color clouds: that is where the largest amount of capital was trapped.

Use the projected POC line as your exact entry point (Sniper Entry) and place your structural Stop Loss safely above/below the cloud.

Pro Tip: Enable the "Money Flow ($)" mode in the settings to view the calculated volume in actual capital instead of basic contracts.

CS FVG Wave Pro doesn't guess the market; it scans it.
Developed for high-precision trading.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/

//@version=6
indicator('CS FVG Wave Pro', overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ═════════════════════════════════════════════════════════════════════════════
// 1. INPUTS
// ═════════════════════════════════════════════════════════════════════════════
grp_data  = "📊 Data Engine"
autoTf    = input.bool(true, "Auto Lower Timeframe", group = grp_data)
tf1       = input.timeframe("5", "Manual TF", group = grp_data)
data_mode = input.string("Money Flow ($)", "Display Data", options=["Units (Spot/Contracts)", "Money Flow ($)"], group = grp_data)

useVolFilt = input.bool(false, "Enable Institutional Vol Filter", group = grp_data)
volMult    = input.float(1.2, "Volume Multiplier", minval = 0.1, step = 0.1, group = grp_data)

grp_ui    = "🌊 Aesthetics & Style"
waveMode  = input.string("Real Volume Zones", "Wave Style", options=["Real Volume Zones", "Aesthetic Smooth Wave"], group = grp_ui)
showContour = input.bool(false, "Show Edge Contour", group = grp_ui)
showBox   = input.bool(false, "Show Background Box", group = grp_ui)
showMit   = input.bool(false, "Keep Mitigated (Ghost Mode)", group = grp_ui)

// AJUSTE DE PUNTO DULCE: 12 FVGs x 40 Bins = 480 (Dentro del límite de 500)
max_hist  = input.int(12, "Max Historical Waves", minval=1, maxval=100, group = grp_ui)
bins      = input.int(40, "Resolution (Cloud Effect)", group = grp_ui, minval=20, maxval=80) 

smooth_f  = input.int(4, "Wave Smoothness", group = grp_ui, minval=0, maxval=10)
vp_width  = input.int(40, "Max Amplitude", group = grp_ui)
gap_filt  = input.float(0.1, 'Gap Filter (ATR)', step = 0.1, group = grp_ui)

grp_txt   = "🏷️ Label Design"
txt_size_in = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal"], group = grp_txt)
txt_col   = input.color(color.white, 'Real Vol Text Color', group = grp_txt)
lbl_bg    = input.color(color.new(color.black, 30), 'Label BG (70% Opacity)', group = grp_txt)

bull_col  = input.color(color.rgb(0, 255, 170), 'Bullish Color', group = grp_ui) 
bear_col  = input.color(color.rgb(255, 0, 106), 'Bearish Color', group = grp_ui) 
mit_col   = input.color(color.rgb(128, 128, 128), 'Mitigated Color', group = grp_ui)

var txt_size = txt_size_in == "Tiny" ? size.tiny : txt_size_in == "Small" ? size.small : size.normal

// ═════════════════════════════════════════════════════════════════════════════
// 2. DATA PROCESSING
// ═════════════════════════════════════════════════════════════════════════════
currentTime = timeframe.in_seconds("") / 60
lower_tf = autoTf ? str.tostring(math.max(1, int(currentTime/10))) : tf1
c_arr = request.security_lower_tf('', lower_tf, close)
v_arr = request.security_lower_tf('', lower_tf, volume)

avgVol = ta.sma(volume, 50)

type fvg 
    int start_idx
    box bgBox
    array<float> volProfile
    array<box> waveMass       
    array<line> waveContour   
    line anchorLine           
    line pocLine
    label pocLbl
    bool isBull
    bool mitigated
    bool isRealVol 

var fvgs = array.new<fvg>(0)

// ═════════════════════════════════════════════════════════════════════════════
// 3. MAIN ENGINE
// ═════════════════════════════════════════════════════════════════════════════
bull_cond = low > high[2] and (low - high[2]) > (ta.atr(14) * gap_filt)
bear_cond = high < low[2] and (low[2] - high) > (ta.atr(14) * gap_filt)

if bull_cond or bear_cond
    top_p = bull_cond ? low : low[2]
    bot_p = bull_cond ? high[2] : high
    s_i   = bar_index - 1
    b_c   = bull_cond ? bull_col : bear_col
    
    vP_temp = array.new<float>(bins, 0.)
    binS = (top_p - bot_p) / bins
    
    if c_arr.size() > 0
        for k = 0 to bins - 1
            mid = bot_p + binS * k + binS / 2
            for i = 0 to c_arr.size() - 1
                if math.abs(c_arr.get(i) - mid) <= binS
                    vP_temp.set(k, vP_temp.get(k) + v_arr.get(i))

    bool has_real_vol = vP_temp.max() > 0
    float totalGapVol = has_real_vol ? vP_temp.sum() : volume 
    
    bool passVol = not useVolFilt or (totalGapVol > avgVol * volMult)

    if passVol
        box_id = box.new(s_i, top_p, s_i + 15, bot_p, border_color=showBox ? b_c : na, bgcolor=showBox ? color.new(b_c, 95) : na)
        wM = array.new<box>(0)
        wC = array.new<line>(0)
        
        for k = 0 to bins - 1
            wM.push(box.new(s_i, na, s_i, na, border_width=0))
        for k = 0 to bins - 2
            wC.push(line.new(s_i, na, s_i, na, color=b_c, width=2))

        ancL = line.new(s_i, top_p, s_i, bot_p, color=b_c, width=2)
        pLin = line.new(s_i, na, s_i, na, color=color.white, style=line.style_dashed)
        pLbl = label.new(s_i, na, "", style=label.style_label_left, color=lbl_bg, textcolor=txt_col, size=txt_size)

        if not has_real_vol
            for k = 0 to bins - 1
                dist = math.abs(k - (bins / 2)) / (bins / 2)
                vP_temp.set(k, math.exp(-math.pow(dist, 2) / 0.35)) 

        sP = array.new<float>(bins, 0.0)
        int apply_smooth = waveMode == "Real Volume Zones" ? 0 : smooth_f
        for k = 0 to bins - 1
            float sum = 0., int cnt = 0
            for j = math.max(0, k - apply_smooth) to math.min(bins - 1, k + apply_smooth)
                sum += vP_temp.get(j), cnt += 1
            sP.set(k, sum / cnt)

        fvgs.push(fvg.new(s_i, box_id, sP, wM, wC, ancL, pLin, pLbl, bull_cond, false, has_real_vol))

// ═════════════════════════════════════════════════════════════════════════════
// 4. RENDERING & DYNAMIC EXTENSION
// ═════════════════════════════════════════════════════════════════════════════
if fvgs.size() > 0
    for i = fvgs.size() - 1 to 0
        f = fvgs.get(i)
        t_f = f.bgBox.get_top(), b_f = f.bgBox.get_bottom(), bin_f = (t_f - b_f) / bins
        mV = f.volProfile.max()
        
        if not f.mitigated
            if (f.isBull and low < b_f) or (not f.isBull and high > t_f)
                f.mitigated := true

        if f.mitigated and not showMit
            f.bgBox.delete()
            f.anchorLine.delete()
            f.pocLine.delete()
            f.pocLbl.delete()
            for bx in f.waveMass
                bx.delete()
            for ln in f.waveContour
                ln.delete()
            fvgs.remove(i)
            continue

        c_curr = f.mitigated ? mit_col : (f.isBull ? bull_col : bear_col)
        t_l = f.mitigated ? 85 : 0

        for k = 0 to bins - 1
            rat = mV > 0 ? f.volProfile.get(k) / mV : 0
            bx_id = f.waveMass.get(k)
            bx_id.set_top(b_f + bin_f * (k + 1))
            bx_id.set_bottom(b_f + bin_f * k)
            bx_id.set_right(f.start_idx + math.round(rat * vp_width))
            bx_id.set_bgcolor(color.new(c_curr, f.mitigated ? 95 : int(math.max(10, 100 - rat * 80)))) 

        for k = 0 to bins - 2
            ln_id = f.waveContour.get(k)
            r1 = mV > 0 ? f.volProfile.get(k) / mV : 0
            r2 = mV > 0 ? f.volProfile.get(k+1) / mV : 0
            ln_id.set_xy1(f.start_idx + math.round(r1 * vp_width), b_f + bin_f * k + bin_f/2)
            ln_id.set_xy2(f.start_idx + math.round(r2 * vp_width), b_f + bin_f * (k + 1) + bin_f/2)
            ln_id.set_color(showContour ? color.new(c_curr, t_l) : na) 

        if mV > 0
            p_y = b_f + bin_f * f.volProfile.indexof(mV) + bin_f/2
            string info = data_mode == "Units (Spot/Contracts)" ? str.tostring(mV, format.volume) : "$" + str.tostring(mV * p_y, format.volume)
            
            int targetX = f.mitigated ? f.start_idx + 10 : bar_index + 15
            
            f.pocLine.set_xy1(f.start_idx + vp_width, p_y)
            f.pocLine.set_xy2(targetX, p_y)
            f.pocLine.set_color(color.new(color.white, t_l + 20))
            
            string prefix = f.isRealVol ? "POC: " : "POC (Est): "
            color current_txt_col = f.isRealVol ? txt_col : color.new(color.gray, 0) 

            f.pocLbl.set_xy(targetX, p_y)
            f.pocLbl.set_text(f.mitigated ? "" : prefix + info)
            f.pocLbl.set_textcolor(f.mitigated ? na : current_txt_col)
            f.pocLbl.set_color(f.mitigated ? na : lbl_bg)

// LIMPIEZA DE HISTORIAL
if fvgs.size() > max_hist
    old = fvgs.shift()
    old.bgBox.delete()
    old.anchorLine.delete()
    old.pocLine.delete()
    old.pocLbl.delete()
    for bx in old.waveMass
        bx.delete()
    for ln in old.waveContour
        ln.delete()
````
