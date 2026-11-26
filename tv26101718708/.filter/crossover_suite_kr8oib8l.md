# Crossover suite

- url: https://www.tradingview.com/script/KR8OIB8L-Crossover-suite/
- type: indicator
- pine_id: PUB;4a4c2da4214c4c4ca8927f9dd066f219
- version: 1.0

## Description

A suite for trading moving average cross overs. 4 MAs of variable kind (MAMA, FAMA, KAMA, FRAMA, ALMA, JMA) and lenght. Oscillator measures slow-fast distance. HUD gives stats for the crossover

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// Extracted and Architected by THE ALPHA COUNCIL
//@version=6
indicator("Kinematic Options Singularity [Alpha Council]", "Singularity Unified", overlay = false, max_polylines_count=100)

//---------------------------------------------------------------------------------------------------------------------}
// System Colors & Topography
//---------------------------------------------------------------------------------------------------------------------{
color C_BULL_ENTRY = #089981
color C_BEAR_ENTRY = #f23645
color C_BULL_EXIT  = color.new(#00FF00, 30)
color C_BEAR_EXIT  = color.new(#FF0000, 30)
color C_DASH_BG    = color.new(color.black, 80)

string OPT_JMA  = "JMA (Zero-Lag Fast)"
string OPT_ALMA = "ALMA (Gaussian Smooth)"
string OPT_KAMA = "KAMA (Kaufman Adaptive)"
string OPT_FRAMA= "FRAMA (Fractal Adaptive)"
string OPT_MAMA = "MAMA (MESA Fast Limit)"
string OPT_FAMA = "FAMA (MESA Slow Limit)"

//---------------------------------------------------------------------------------------------------------------------}
// Core Inputs: Universal Asymmetric Routing
//---------------------------------------------------------------------------------------------------------------------{
float src = input.source(close, "Data Source", group="Global Parameters")

// PILLAR 1: ENTRY ROUTING
string enFastType = input.string(OPT_ALMA, "ENTRY Fast MA Type", options=[OPT_JMA, OPT_ALMA, OPT_KAMA, OPT_FRAMA, OPT_MAMA, OPT_FAMA], group="Phase 1: Entry Matrix")
int    enFastLen  = input.int(21, "Entry Fast Length", minval=2, group="Phase 1: Entry Matrix")
string enSlowType = input.string(OPT_ALMA, "ENTRY Slow MA Type", options=[OPT_JMA, OPT_ALMA, OPT_KAMA, OPT_FRAMA, OPT_MAMA, OPT_FAMA], group="Phase 1: Entry Matrix")
int    enSlowLen  = input.int(55, "Entry Slow Length", minval=5, group="Phase 1: Entry Matrix")

// PILLAR 2: EXIT ROUTING
string exFastType = input.string(OPT_JMA, "EXIT Fast MA Type", options=[OPT_JMA, OPT_ALMA, OPT_KAMA, OPT_FRAMA, OPT_MAMA, OPT_FAMA], group="Phase 2: Exit Matrix")
int    exFastLen  = input.int(8,  "Exit Fast Length", minval=2, group="Phase 2: Exit Matrix")
string exSlowType = input.string(OPT_JMA, "EXIT Slow MA Type", options=[OPT_JMA, OPT_ALMA, OPT_KAMA, OPT_FRAMA, OPT_MAMA, OPT_FAMA], group="Phase 2: Exit Matrix")
int    exSlowLen  = input.int(21, "Exit Slow Length", minval=5, group="Phase 2: Exit Matrix")

// PILLAR 3: SIGNAL SWITCHBOARD
bool sigEnFsEs = input.bool(true,  "Signal: Entry Fast x Entry Slow", group="Signal Switchboard")
bool sigExFsEs = input.bool(true,  "Signal: Exit Fast x Exit Slow", group="Signal Switchboard")
bool sigEnFxExF= input.bool(false, "Signal: Entry Fast x Exit Fast", group="Signal Switchboard")
bool sigEnFxExS= input.bool(false, "Signal: Entry Fast x Exit Slow", group="Signal Switchboard")
bool sigEnSxExF= input.bool(false, "Signal: Entry Slow x Exit Fast", group="Signal Switchboard")
bool sigMtf    = input.bool(true,  "Require MTF Alignment for Entry Signals", group="Signal Switchboard")
string mtfRes  = input.timeframe("240", "Higher Timeframe Anchor", group="Signal Switchboard")
string sigSizeInput = input.string("Small", "Signal Size", options=["Tiny", "Small", "Normal"], group="Signal Switchboard")

// PILLAR 4: GHOST PROJECTION & RUSSIAN DOLL OSCILLATOR
int  ghostWindow = input.int(10, "Rainbow Ghost Lookback Window (X Bars)", minval=1, maxval=40, group="Dimensional Overlays")
int  ghostBars   = input.int(8,  "Rainbow Ghost Projection Length", minval=1, maxval=20, group="Dimensional Overlays")
bool showDoll    = input.bool(true, "Show Russian Doll Exit Oscillators (Sub-pane)", group="Dimensional Overlays")

//---------------------------------------------------------------------------------------------------------------------}
// Mathematical DSP Engines
//---------------------------------------------------------------------------------------------------------------------{
// 1. JMA
f_jma(_src, _length) =>
    float phaseRatio = 1.5 + 50.0 / 100.0
    float beta = 0.45 * (_length - 1) / (0.45 * (_length - 1) + 2)
    float alpha = math.pow(beta, 2.0)
    var float jma = 0.0, var float e0 = 0.0, var float e1 = 0.0, var float e2 = 0.0
    e0 := (1 - alpha) * _src + alpha * nz(e0[1], _src)
    e1 := (_src - e0) * (1 - beta) + beta * nz(e1[1], 0)
    e2 := (e0 + phaseRatio * e1 - nz(jma[1], _src)) * math.pow(1 - alpha, 2) + math.pow(alpha, 2) * nz(e2[1], 0)
    jma := e2 + nz(jma[1], _src)
    jma

// 2. FRAMA
f_frama(_src, _length) =>
    int len = math.max(2, math.round(_length / 2) * 2) 
    float n3 = (ta.highest(high, len) - ta.lowest(low, len)) / len
    float n1 = (ta.highest(high, len / 2) - ta.lowest(low, len / 2)) / (len / 2)
    float n2 = (ta.highest(high[len / 2], len / 2) - ta.lowest(low[len / 2], len / 2)) / (len / 2)
    float D = (n3 > 0 and (n1 + n2) > 0) ? (math.log(n1 + n2) - math.log(n3)) / math.log(2) : 1.0
    float alpha = math.max(math.min(math.exp(-4.6 * (D - 1)), 1.0), 0.01)
    var float frama = _src
    frama := alpha * _src + (1 - alpha) * nz(frama[1], _src)
    frama

// 3. KAMA
f_kama(_src, _length) =>
    float change = math.abs(_src - nz(_src[_length]))
    float vol = math.sum(math.abs(_src - nz(_src[1])), _length)
    float er = vol != 0 ? change / vol : 0
    float sc = math.pow(er * (0.6666 - 0.0645) + 0.0645, 2)
    var float kama = _src
    kama := nz(kama[1]) + sc * (_src - nz(kama[1]))
    kama

// 4. MAMA & FAMA
f_mama_fama(_src) =>
    var float p = 0.0, var float prevPhase = 0.0
    var float mama = _src, var float fama = _src
    float sm = (4*_src + 3*nz(_src[1]) + 2*nz(_src[2]) + nz(_src[3])) / 10.0
    float dt = (0.0962*sm + 0.5769*nz(sm[2]) - 0.5769*nz(sm[4]) - 0.0962*nz(sm[6])) * (0.075*nz(p[1]) + 0.54)
    float q1 = (0.0962*dt + 0.5769*nz(dt[2]) - 0.5769*nz(dt[4]) - 0.0962*nz(dt[6])) * (0.075*nz(p[1]) + 0.54)
    float i1 = nz(dt[3])
    float jI = (0.0962*i1 + 0.5769*nz(i1[2]) - 0.5769*nz(i1[4]) - 0.0962*nz(i1[6])) * (0.075*nz(p[1]) + 0.54)
    float jQ = (0.0962*q1 + 0.5769*nz(q1[2]) - 0.5769*nz(q1[4]) - 0.0962*nz(q1[6])) * (0.075*nz(p[1]) + 0.54)
    float i2 = i1 - jQ
    float q2 = q1 + jI
    i2 := 0.2*i2 + 0.8*nz(i2[1])
    q2 := 0.2*q2 + 0.8*nz(q2[1])
    float re = i2*nz(i2[1]) + q2*nz(q2[1])
    float im = i2*nz(q2[1]) - q2*nz(i2[1])
    re := 0.2*re + 0.8*nz(re[1])
    im := 0.2*im + 0.8*nz(im[1])
    if im != 0 and re != 0
        p := 360 / (180 / math.pi * math.atan(im/re))
    p := math.max(6, math.min(50, math.max(0.67 * nz(p[1]), math.min(1.5 * nz(p[1]), p))))
    float phase = i1 != 0 ? 180 / math.pi * math.atan(q1 / i1) : 0
    float dPhase = math.max(1, nz(prevPhase[1]) - phase)
    float alpha = math.max(0.05, math.min(0.5, 0.5 / dPhase))
    mama := alpha * _src + (1 - alpha) * nz(mama[1])
    fama := 0.5 * alpha * mama + (1 - 0.5 * alpha) * nz(fama[1])
    prevPhase := phase
    [mama, fama]

// Universal Router
f_get_ma(type, _src, _len) =>
    float val = _src
    if type == OPT_JMA
        val := f_jma(_src, _len)
    else if type == OPT_ALMA
        val := ta.alma(_src, _len, 0.85, 6)
    else if type == OPT_FRAMA
        val := f_frama(_src, _len)
    else if type == OPT_KAMA
        val := f_kama(_src, _len)
    else if type == OPT_MAMA
        [m, f] = f_mama_fama(_src)
        val := m
    else if type == OPT_FAMA
        [m, f] = f_mama_fama(_src)
        val := f
    val

//---------------------------------------------------------------------------------------------------------------------}
// Calculate Asymmetric Matrices
//---------------------------------------------------------------------------------------------------------------------{
float en_fast = f_get_ma(enFastType, src, enFastLen)
float en_slow = f_get_ma(enSlowType, src, enSlowLen)

float ex_fast = f_get_ma(exFastType, src, exFastLen)
float ex_slow = f_get_ma(exSlowType, src, exSlowLen)

// MTF Anchor
float htf_fast = request.security(syminfo.tickerid, mtfRes, f_get_ma(enFastType, close, enFastLen))
float htf_slow = request.security(syminfo.tickerid, mtfRes, f_get_ma(enSlowType, close, enSlowLen))
bool  htf_bull = htf_fast > htf_slow
bool  mtf_gate = sigMtf ? htf_bull : true
bool  mtf_gate_bear = sigMtf ? not htf_bull : true

//---------------------------------------------------------------------------------------------------------------------}
// Signal Generation Logic
//---------------------------------------------------------------------------------------------------------------------{
bool bull_EnFsEs = ta.crossover(en_fast, en_slow) and mtf_gate
bool bear_EnFsEs = ta.crossunder(en_fast, en_slow) and mtf_gate_bear

bool bull_ExFsEs = ta.crossunder(ex_fast, ex_slow) // Exit crosses are inverse to capture decay
bool bear_ExFsEs = ta.crossover(ex_fast, ex_slow)

bool bull_EnFxExF= ta.crossover(en_fast, ex_fast)
bool bear_EnFxExF= ta.crossunder(en_fast, ex_fast)

bool bull_EnFxExS= ta.crossover(en_fast, ex_slow)
bool bear_EnFxExS= ta.crossunder(en_fast, ex_slow)

bool bull_EnSxExF= ta.crossover(en_slow, ex_fast)
bool bear_EnSxExF= ta.crossunder(en_slow, ex_fast)

//---------------------------------------------------------------------------------------------------------------------}
// MAIN CHART PROJECTIONS (Forced to Overlay)
//---------------------------------------------------------------------------------------------------------------------{
// Plot Entry Matrix 
color c_en_fill = en_fast > en_slow ? color.new(C_BULL_ENTRY, 85) : color.new(C_BEAR_ENTRY, 85)
p_en_f = plot(en_fast, title="Entry Fast", color=en_fast > en_slow ? C_BULL_ENTRY : C_BEAR_ENTRY, linewidth=2, force_overlay=true)
p_en_s = plot(en_slow, title="Entry Slow", color=color.gray, linewidth=2, force_overlay=true)
fill(p_en_f, p_en_s, color=c_en_fill)

// Plot Exit Matrix
p_ex_f = plot(ex_fast, title="Exit Fast", color=ex_fast > ex_slow ? C_BULL_EXIT : C_BEAR_EXIT, linewidth=1, style=plot.style_stepline, force_overlay=true)
p_ex_s = plot(ex_slow, title="Exit Slow", color=color.new(color.gray, 50), linewidth=1, style=plot.style_stepline, force_overlay=true)
fill(p_ex_f, p_ex_s, color=ex_fast > ex_slow ? color.new(C_BULL_EXIT, 85) : color.new(C_BEAR_EXIT, 85), title="Exit Fill")

// Conditional Boolean State Routing for Signal Size
bool isTiny   = sigSizeInput == "Tiny"
bool isSmall  = sigSizeInput == "Small"
bool isNormal = sigSizeInput == "Normal"

// Signal Renderer Matrix

// EnF x EnS Bull
plotshape(isTiny   and sigEnFsEs and bull_EnFsEs, title="EnF x EnS Bull (T)", style=shape.triangleup, location=location.belowbar, color=C_BULL_ENTRY, size=size.tiny,   force_overlay=true)
plotshape(isSmall  and sigEnFsEs and bull_EnFsEs, title="EnF x EnS Bull (S)", style=shape.triangleup, location=location.belowbar, color=C_BULL_ENTRY, size=size.small,  force_overlay=true)
plotshape(isNormal and sigEnFsEs and bull_EnFsEs, title="EnF x EnS Bull (N)", style=shape.triangleup, location=location.belowbar, color=C_BULL_ENTRY, size=size.normal, force_overlay=true)
// EnF x EnS Bear
plotshape(isTiny   and sigEnFsEs and bear_EnFsEs, title="EnF x EnS Bear (T)", style=shape.triangledown, location=location.abovebar, color=C_BEAR_ENTRY, size=size.tiny,   force_overlay=true)
plotshape(isSmall  and sigEnFsEs and bear_EnFsEs, title="EnF x EnS Bear (S)", style=shape.triangledown, location=location.abovebar, color=C_BEAR_ENTRY, size=size.small,  force_overlay=true)
plotshape(isNormal and sigEnFsEs and bear_EnFsEs, title="EnF x EnS Bear (N)", style=shape.triangledown, location=location.abovebar, color=C_BEAR_ENTRY, size=size.normal, force_overlay=true)

// ExF x ExS Bull
plotshape(isTiny   and sigExFsEs and bull_ExFsEs, title="ExF x ExS Bull (T)", style=shape.xcross, location=location.abovebar, color=C_BEAR_EXIT, size=size.tiny,   force_overlay=true)
plotshape(isSmall  and sigExFsEs and bull_ExFsEs, title="ExF x ExS Bull (S)", style=shape.xcross, location=location.abovebar, color=C_BEAR_EXIT, size=size.small,  force_overlay=true)
plotshape(isNormal and sigExFsEs and bull_ExFsEs, title="ExF x ExS Bull (N)", style=shape.xcross, location=location.abovebar, color=C_BEAR_EXIT, size=size.normal, force_overlay=true)
// ExF x ExS Bear
plotshape(isTiny   and sigExFsEs and bear_ExFsEs, title="ExF x ExS Bear (T)", style=shape.xcross, location=location.belowbar, color=C_BULL_EXIT, size=size.tiny,   force_overlay=true)
plotshape(isSmall  and sigExFsEs and bear_ExFsEs, title="ExF x ExS Bear (S)", style=shape.xcross, location=location.belowbar, color=C_BULL_EXIT, size=size.small,  force_overlay=true)
plotshape(isNormal and sigExFsEs and bear_ExFsEs, title="ExF x ExS Bear (N)", style=shape.xcross, location=location.belowbar, color=C_BULL_EXIT, size=size.normal, force_overlay=true)

// EnF x ExF Bull
plotshape(isTiny   and sigEnFxExF and bull_EnFxExF, title="EnF x ExF Bull (T)", style=shape.diamond, location=location.belowbar, color=color.blue, size=size.tiny,   force_overlay=true)
plotshape(isSmall  and sigEnFxExF and bull_EnFxExF, title="EnF x ExF Bull (S)", style=shape.diamond, location=location.belowbar, color=color.blue, size=size.small,  force_overlay=true)
plotshape(isNormal and sigEnFxExF and bull_EnFxExF, title="EnF x ExF Bull (N)", style=shape.diamond, location=location.belowbar, color=color.blue, size=size.normal, force_overlay=true)
// EnF x ExF Bear
plotshape(isTiny   and sigEnFxExF and bear_EnFxExF, title="EnF x ExF Bear (T)", style=shape.diamond, location=location.abovebar, color=color.orange, size=size.tiny,   force_overlay=true)
plotshape(isSmall  and sigEnFxExF and bear_EnFxExF, title="EnF x ExF Bear (S)", style=shape.diamond, location=location.abovebar, color=color.orange, size=size.small,  force_overlay=true)
plotshape(isNormal and sigEnFxExF and bear_EnFxExF, title="EnF x ExF Bear (N)", style=shape.diamond, location=location.abovebar, color=color.orange, size=size.normal, force_overlay=true)

// EnF x ExS Bull
plotshape(isTiny   and sigEnFxExS and bull_EnFxExS, title="EnF x ExS Bull (T)", style=shape.circle, location=location.belowbar, color=color.fuchsia, size=size.tiny,   force_overlay=true)
plotshape(isSmall  and sigEnFxExS and bull_EnFxExS, title="EnF x ExS Bull (S)", style=shape.circle, location=location.belowbar, color=color.fuchsia, size=size.small,  force_overlay=true)
plotshape(isNormal and sigEnFxExS and bull_EnFxExS, title="EnF x ExS Bull (N)", style=shape.circle, location=location.belowbar, color=color.fuchsia, size=size.normal, force_overlay=true)
// EnF x ExS Bear
plotshape(isTiny   and sigEnFxExS and bear_EnFxExS, title="EnF x ExS Bear (T)", style=shape.circle, location=location.abovebar, color=color.purple, size=size.tiny,   force_overlay=true)
plotshape(isSmall  and sigEnFxExS and bear_EnFxExS, title="EnF x ExS Bear (S)", style=shape.circle, location=location.abovebar, color=color.purple, size=size.small,  force_overlay=true)
plotshape(isNormal and sigEnFxExS and bear_EnFxExS, title="EnF x ExS Bear (N)", style=shape.circle, location=location.abovebar, color=color.purple, size=size.normal, force_overlay=true)

// EnS x ExF Bull
plotshape(isTiny   and sigEnSxExF and bull_EnSxExF, title="EnS x ExF Bull (T)", style=shape.flag, location=location.belowbar, color=color.white, size=size.tiny,   force_overlay=true)
plotshape(isSmall  and sigEnSxExF and bull_EnSxExF, title="EnS x ExF Bull (S)", style=shape.flag, location=location.belowbar, color=color.white, size=size.small,  force_overlay=true)
plotshape(isNormal and sigEnSxExF and bull_EnSxExF, title="EnS x ExF Bull (N)", style=shape.flag, location=location.belowbar, color=color.white, size=size.normal, force_overlay=true)
// EnS x ExF Bear
plotshape(isTiny   and sigEnSxExF and bear_EnSxExF, title="EnS x ExF Bear (T)", style=shape.flag, location=location.abovebar, color=color.yellow, size=size.tiny,   force_overlay=true)
plotshape(isSmall  and sigEnSxExF and bear_EnSxExF, title="EnS x ExF Bear (S)", style=shape.flag, location=location.abovebar, color=color.yellow, size=size.small,  force_overlay=true)
plotshape(isNormal and sigEnSxExF and bear_EnSxExF, title="EnS x ExF Bear (N)", style=shape.flag, location=location.abovebar, color=color.yellow, size=size.normal, force_overlay=true)

//---------------------------------------------------------------------------------------------------------------------}
// PILLAR 4: Rainbow Polynomial "Ghost" Projection
//---------------------------------------------------------------------------------------------------------------------{
var array<polyline> ghostLinesFast = array.new<polyline>()

if barstate.islast
    for p in ghostLinesFast
        polyline.delete(p)
    array.clear(ghostLinesFast)
    
    // Project a rolling window of polynomial futures (The Rainbow Matrix)
    for j = 0 to ghostWindow
        // Access historical states using Pine's series indexer
        float start_f = en_fast[j]
        float vf      = start_f - nz(en_fast[j+1])
        float acc_f   = vf - (nz(en_fast[j+1]) - nz(en_fast[j+2]))
        
        array<chart.point> ptsFast = array.new<chart.point>()
        ptsFast.push(chart.point.from_index(bar_index - j, start_f))
        
        for i = 1 to ghostBars
            float proj_f = start_f + (vf * i) + (0.5 * acc_f * math.pow(i, 2))
            ptsFast.push(chart.point.from_index(bar_index - j + i, proj_f))
            
        // Shift color spectrum across the historical array (Neon Rainbow)
        color rbw_color = color.from_gradient(j, 0, ghostWindow, color.fuchsia, color.blue)
        polyline pf = polyline.new(ptsFast, line_color=rbw_color, line_style=line.style_dotted, line_width=2, force_overlay=true)
        array.push(ghostLinesFast, pf)

//---------------------------------------------------------------------------------------------------------------------}
// PILLAR 5: Options Greeks Proxies, Compression & Crossover Scoring
//---------------------------------------------------------------------------------------------------------------------{
// 1. Vega Proxy (Annualized Historical Volatility)
float log_ret = math.log(close / nz(close[1], close))
float hv = ta.stdev(log_ret, 20) * math.sqrt(252) * 100

// 2. Gamma Proxy & Momentum (Acceleration & Velocity of the Fast Entry Matrix)
float vel = en_fast - nz(en_fast[1])
float acc = vel - nz(vel[1])
float gamma_proxy = math.abs(acc / close * 10000)
float mom_proxy   = math.abs(vel / close * 1000)

// 3. Volume Confirmation
float rel_vol = nz(volume / ta.sma(volume, 20), 1.0)

// 4. Compression / Build-up (Bollinger Band Width Squeeze Proxy)
float bb_upper = ta.sma(close, 20) + 2 * ta.stdev(close, 20)
float bb_lower = ta.sma(close, 20) - 2 * ta.stdev(close, 20)
float bb_width = (bb_upper - bb_lower) / ta.sma(close, 20)
float bb_width_rank = ta.percentrank(bb_width, 100) // 0 to 100. Lower means tightest compression.
float cheapness = 100.0 - nz(bb_width_rank, 50.0) // High cheapness = highly compressed, low IV "flag" pattern

// 5. Expected Profit Margin & Breakout Volatility Score (0 - 100)
var float exp_profit_score = 0.0

// Trigger score update on any major structural cross
bool is_any_cross = (bull_EnFsEs or bear_EnFsEs or bull_ExFsEs or bear_ExFsEs or bull_EnFxExF or bear_EnFxExF)
if is_any_cross
    // Weighting: 30% Compression (Build-up), 30% Acceleration (Gamma), 20% Momentum, 20% Volume Confirmation
    float sc_comp  = cheapness * 0.30
    float sc_gamma = math.min(100, gamma_proxy * 15) * 0.30
    float sc_vol   = math.min(100, rel_vol * 35) * 0.20
    float sc_mom   = math.min(100, mom_proxy * 15) * 0.20
    exp_profit_score := math.min(100, math.max(0, sc_comp + sc_gamma + sc_vol + sc_mom))

//---------------------------------------------------------------------------------------------------------------------}
// SUB-PANE OSCILLATOR (Russian Doll Options Volatility Phase Delta)
//---------------------------------------------------------------------------------------------------------------------{
// Delta 1: Structural Macro Convergence (En Fast - En Slow)
float d_enFsEs = en_fast - en_slow
color c_enFsEs = d_enFsEs >= 0 ? (d_enFsEs > nz(d_enFsEs[1]) ? C_BULL_ENTRY : color.new(C_BULL_ENTRY, 60)) : (d_enFsEs < nz(d_enFsEs[1]) ? C_BEAR_ENTRY : color.new(C_BEAR_ENTRY, 60))

// Delta 2: Reactive Option Exit Matrix (Ex Fast - Ex Slow)
float d_exFsEs = ex_fast - ex_slow
color c_exFsEs = d_exFsEs >= 0 ? color.new(#00BCD4, 40) : color.new(#FF9800, 40) // Cyan/Amber

// Delta 3: Kinematic Options Squeeze Gap (En Fast - Ex Fast)
float d_enFxExF = en_fast - ex_fast
color c_enFxExF = d_enFxExF >= 0 ? color.new(color.white, 20) : color.new(color.white, 20)

// The Russian Doll Overlay (Highest to Lowest visual dominance)
plot(showDoll ? d_enFsEs : na,  title="Doll: Structural Macro", style=plot.style_columns, color=c_enFsEs, linewidth=3)
plot(showDoll ? d_exFsEs : na,  title="Doll: Reactive Exit",    style=plot.style_area,    color=c_exFsEs)
plot(showDoll ? d_enFxExF : na, title="Doll: Kinematic Gap",    style=plot.style_line,    color=c_enFxExF, linewidth=2)
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dotted)

//---------------------------------------------------------------------------------------------------------------------}
// HUD Options Matrix Panel
//---------------------------------------------------------------------------------------------------------------------{
var table hud = table.new(position.top_right, 2, 8, bgcolor=C_DASH_BG, border_width=1, border_color=color.gray, force_overlay=true)

if barstate.islast
    table.cell(hud, 0, 0, "MTF ANCHOR (" + mtfRes + ")", text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 0, htf_bull ? "BULLISH" : "BEARISH", text_color=htf_bull ? C_BULL_ENTRY : C_BEAR_ENTRY, text_size=size.small)
    
    table.cell(hud, 0, 1, "STRUCTURAL DOLL", text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 1, str.tostring(d_enFsEs, "#.00"), text_color=d_enFsEs > 0 ? C_BULL_ENTRY : C_BEAR_ENTRY, text_size=size.small)
    
    table.cell(hud, 0, 2, "REACTIVE DOLL", text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 2, str.tostring(d_exFsEs, "#.00"), text_color=d_exFsEs > 0 ? #00BCD4 : #FF9800, text_size=size.small)
    
    table.cell(hud, 0, 3, "KINEMATIC GAP DOLL", text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 3, str.tostring(d_enFxExF, "#.00"), text_color=color.white, text_size=size.small)
    
    table.cell(hud, 0, 4, "EXP. PROFIT SCORE", text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 4, str.tostring(exp_profit_score, "#.0"), text_color=exp_profit_score > 70 ? C_BULL_ENTRY : (exp_profit_score > 40 ? color.yellow : C_BEAR_ENTRY), text_size=size.small)
    
    table.cell(hud, 0, 5, "VEGA PROXY (HV %)", text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 5, str.tostring(hv, "#.0") + "%", text_color=color.white, text_size=size.small)
    
    table.cell(hud, 0, 6, "GAMMA PROXY (ACCEL)", text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 6, str.tostring(gamma_proxy, "#.00"), text_color=gamma_proxy > 2 ? C_BULL_ENTRY : color.gray, text_size=size.small)
    
    table.cell(hud, 0, 7, "VOL / COMPRESSION", text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 7, str.tostring(rel_vol, "#.0x") + " / " + str.tostring(cheapness, "#.0") + "%", text_color=rel_vol > 1.5 ? C_BULL_ENTRY : color.gray, text_size=size.small)

//---------------------------------------------------------------------------------------------------------------------}
````
