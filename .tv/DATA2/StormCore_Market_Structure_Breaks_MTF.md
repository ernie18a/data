<!-- tradingview-pine-id: PUB;dbc329ced4c44bca941816bcd519dd0b -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# StormCore | Market Structure Breaks MTF

Source: https://www.tradingview.com/script/oRxUgDd5-stormcore-market-structure-breaks-mtf/

## Description

StormCore | Market Structure Breaks MTF is a professional-grade instrument designed for advanced Market Structure analysis, Smart Money Concepts (SMC), and institutional Price Action tracking.Unlike standard MTF indicators that suffer from repainting or lose crucial false-breakout data due to candle aggregation, this script utilizes a custom hybrid architecture to flawlessly synchronize Higher Timeframe (HTF) macro-levels with your local working chart.Built for traders who value precision, this tool focuses on sniper-accurate liquidity grabs (Judas Swings) and structurally confirmed breakouts.🌟 Key Innovations (v1.12 Architecture)1. Cross-TF Local Sweep EngineStandard indicators often "lose" liquidity sweeps inside higher timeframe candles. StormCore MSB solves this fundamentally: The engine extracts "pure" unmitigated macro-levels (1D, 1W, 1M) and scans every single local candle. If a local candle wicks through a monthly level and closes back inside, the script instantly triggers a Liquidity Sweep and places a ✖ mark right above/below that specific wick. No delay, no repainting.2. Bulletproof Null-Safety EngineUsing advanced Primitive Extraction and mathematical change detectors (ta.change), the core engine is fully immune to compilation crashes (na errors). It works flawlessly on newly listed assets, high-volatility pairs, and lower timeframes with limited historical data.3. Smart Institutional FiltersBreakouts of Structure (BOS) are only confirmed when true institutional interest is present. The script features two powerful, toggleable filters:Displacement Filter: The breakout candle's body must be impulsive (Default: $\ge$ 50% of ATR).Volume Validation: The breakout candle's volume must exceed the average volume (SMA 20) by at least 20%.📊 How to Read the ChartSolid Lines: Confirmed Break of Structure (BOS) on the respective timeframe (Blue = 1D, Orange = 1W, Purple = 1M). Line thickness reflects the timeframe hierarchy.Crosses (✖) & Dashed Lines: Liquidity Sweeps. Indicates that a macro-level was pierced, but the structure held. This is the optimal zone to look for reversals or to build positions during a markdown.Volume Highlights (VSA): Dark Green and Maroon candles indicate anomalous volume spikes on your current timeframe, validating smart money activity.⚙️ Priority & UI SettingsThe script features an MTF Overlap Filter. If Weekly and Monthly levels overlap perfectly, the algorithm automatically hides the lower timeframe to keep your chart clean and prioritize the macro-level. All modules (1D, 1W, 1M) can be toggled on/off in the clean, user-friendly settings menu.

---

## Source Code

````pine
//@version=6
// @author Andy Storm | AI-StormCore
// Version: v1.12 (Standalone & Bulletproof Engine)

indicator("StormCore | Market Structure Breaks MTF", "SC | MSB MTF", overlay=true, max_lines_count=500, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🎛️ GLOBAL MTF TOGGLES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupToggles = "━━━ GLOBAL MTF TOGGLES ━━━"
masterMTF    = input.bool(true, "Master Enable All", group=groupToggles)
show1D       = input.bool(true, "Show 1D (Daily)", group=groupToggles)
show1W       = input.bool(true, "Show 1W (Weekly)", group=groupToggles)
show1M       = input.bool(true, "Show 1M (Monthly)", group=groupToggles)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🧠 SMART FILTERS (INSTITUTIONAL)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupSmart   = "━━━ SMART FILTERS (INSTITUTIONAL) ━━━"
useVol       = input.bool(true, "Require Volume Validation", group=groupSmart, tooltip="Игнорирует пробои структуры, если объем свечи ниже среднего.")
volLen       = input.int(20, "Volume SMA Length", minval=1, group=groupSmart)
volFactor    = input.float(1.2, "Volume Factor", step=0.1, minval=0.0, group=groupSmart, tooltip="1.2 означает, что объем пробойной свечи должен быть на 20% выше SMA.")

useVolColor  = input.bool(true, "Color High Volume Candles", group=groupSmart, tooltip="Окрашивает свечи текущего графика с аномальным объемом (Темно-зеленый/Бордовый).")
showSweeps   = input.bool(true, "Show Liquidity Sweeps (✖)", group=groupSmart, tooltip="Отображает крестик и пунктирную линию проколотого уровня при сборе ликвидности.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ⚙️ STRUCTURE & DISPLACEMENT SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupStructure = "━━━ STRUCTURE SETTINGS ━━━"
pivotLen       = input.int(8, "Swing Length", minval=2, maxval=50, group=groupStructure)

groupFilter    = "━━━ DISPLACEMENT FILTER ━━━"
useDisplace    = input.bool(true, "Displacement Filter", group=groupFilter)
atrLen         = input.int(14, "ATR Length", minval=2, group=groupFilter)
atrFactor      = input.float(0.50, "Minimum Body / ATR", minval=0.0, step=0.05, group=groupFilter)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🎨 COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupColors  = "━━━ MTF COLORS ━━━"
c_1D         = input.color(color.new(color.blue, 0), "1D Color", group=groupColors)
c_1W         = input.color(color.new(color.orange, 0), "1W Color", group=groupColors)
c_1M         = input.color(color.new(color.purple, 0), "1M Color", group=groupColors)
c_transp     = color.new(color.white, 100)

c_highVolBuy = color.new(#006400, 0) // Dark Green
c_highVolSel = color.new(#800000, 0) // Maroon

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🧱 USER-DEFINED TYPES (v6 Architecture)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
type MSB_Data
    bool  isBullBOS = false
    bool  isBearBOS = false
    float lvlBull   = na
    int   timeBull  = na
    float lvlBear   = na
    int   timeBear  = na
    float active_sH = na 
    int   time_sH   = na 
    float active_sL = na 
    int   time_sL   = na 

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ⚙️ CORE CALCULATION ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_calcMSB(pLen, aLen, aFac, uDisp, uVol, vLen, vFac) =>
    MSB_Data res = MSB_Data.new()
    
    atr = ta.atr(aLen)
    bDisp = na(atr) or ((close - open) >= (atr * aFac))
    sDisp = na(atr) or ((open - close) >= (atr * aFac))
    
    bFilt = not uDisp or bDisp
    sFilt = not uDisp or sDisp
    
    volSma = ta.sma(volume, vLen)
    vFilt = not uVol or na(volSma) or (volume > volSma * vFac)
    
    pH = ta.pivothigh(high, pLen, pLen)
    pL = ta.pivotlow(low, pLen, pLen)
    
    var float sH = na
    var float sL = na
    var int tH = na
    var int tL = na
    
    if not na(pH)
        sH := pH
        tH := time[pLen]
        
    if not na(pL)
        sL := pL
        tL := time[pLen]
        
    res.isBullBOS := not na(sH) and close > sH and close[1] <= sH and bFilt and vFilt
    res.isBearBOS := not na(sL) and close < sL and close[1] >= sL and sFilt and vFilt
    
    if res.isBullBOS
        res.lvlBull := sH
        res.timeBull := tH
        sH := na 
        
    if res.isBearBOS
        res.lvlBear := sL
        res.timeBear := tL
        sL := na 
        
    res.active_sH := sH
    res.time_sH   := tH
    res.active_sL := sL
    res.time_sL   := tL
    
    res

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 📊 CHART VOLUME HIGHLIGHT (Current TF)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
chartVolSma = ta.sma(volume, volLen)
isChartHighVol = not na(chartVolSma) and (volume > chartVolSma * volFactor)
barColorCurrent = close >= open ? c_highVolBuy : c_highVolSel
barcolor(useVolColor and isChartHighVol ? barColorCurrent : na, title="High Volume Candles")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 📡 DATA REQUESTS & PRIMITIVE EXTRACTION (CRASH PREVENTION)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
d1_raw = request.security(syminfo.tickerid, "1D", f_calcMSB(pivotLen, atrLen, atrFactor, useDisplace, useVol, volLen, volFactor), lookahead=barmerge.lookahead_off)
w1_raw = request.security(syminfo.tickerid, "1W", f_calcMSB(pivotLen, atrLen, atrFactor, useDisplace, useVol, volLen, volFactor), lookahead=barmerge.lookahead_off)
m1_raw = request.security(syminfo.tickerid, "1M", f_calcMSB(pivotLen, atrLen, atrFactor, useDisplace, useVol, volLen, volFactor), lookahead=barmerge.lookahead_off)

MSB_Data d1 = na(d1_raw) ? MSB_Data.new() : d1_raw
MSB_Data w1 = na(w1_raw) ? MSB_Data.new() : w1_raw
MSB_Data m1 = na(m1_raw) ? MSB_Data.new() : m1_raw

bool d1_isBullBOS = d1.isBullBOS
bool d1_isBearBOS = d1.isBearBOS
float d1_lvlBull  = d1.lvlBull
int d1_timeBull   = d1.timeBull
float d1_lvlBear  = d1.lvlBear
int d1_timeBear   = d1.timeBear
float d1_act_sH   = d1.active_sH
int d1_time_sH    = d1.time_sH
float d1_act_sL   = d1.active_sL
int d1_time_sL    = d1.time_sL

bool w1_isBullBOS = w1.isBullBOS
bool w1_isBearBOS = w1.isBearBOS
float w1_lvlBull  = w1.lvlBull
int w1_timeBull   = w1.timeBull
float w1_lvlBear  = w1.lvlBear
int w1_timeBear   = w1.timeBear
float w1_act_sH   = w1.active_sH
int w1_time_sH    = w1.time_sH
float w1_act_sL   = w1.active_sL
int w1_time_sL    = w1.time_sL

bool m1_isBullBOS = m1.isBullBOS
bool m1_isBearBOS = m1.isBearBOS
float m1_lvlBull  = m1.lvlBull
int m1_timeBull   = m1.timeBull
float m1_lvlBear  = m1.lvlBear
int m1_timeBear   = m1.timeBear
float m1_act_sH   = m1.active_sH
int m1_time_sH    = m1.time_sH
float m1_act_sL   = m1.active_sL
int m1_time_sL    = m1.time_sL

// 🛡️ БРОНЕБОЙНЫЕ ТРИГГЕРЫ ПРОБОЕВ (Через математический детектор изменения)
d1_bull_trig = ta.change(d1_isBullBOS ? 1 : 0) > 0
d1_bear_trig = ta.change(d1_isBearBOS ? 1 : 0) > 0

w1_bull_trig = ta.change(w1_isBullBOS ? 1 : 0) > 0
w1_bear_trig = ta.change(w1_isBearBOS ? 1 : 0) > 0

m1_bull_trig = ta.change(m1_isBullBOS ? 1 : 0) > 0
m1_bear_trig = ta.change(m1_isBearBOS ? 1 : 0) > 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🎯 CROSS-TF LOCAL SWEEP ENGINE (Мгновенный детектор проколов)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_is_swp_bear(lvl) => not na(lvl) and high > lvl and close <= lvl and not (high[1] > lvl and close[1] <= lvl)
f_is_swp_bull(lvl) => not na(lvl) and low < lvl and close >= lvl and not (low[1] < lvl and close[1] >= lvl)

// Свипы сканируются на ТЕКУЩЕМ таймфрейме относительно полученных уровней
d1_swpBear_trig = f_is_swp_bear(d1_act_sH)
d1_swpBull_trig = f_is_swp_bull(d1_act_sL)

w1_swpBear_trig = f_is_swp_bear(w1_act_sH)
w1_swpBull_trig = f_is_swp_bull(w1_act_sL)

m1_swpBear_trig = f_is_swp_bear(m1_act_sH)
m1_swpBull_trig = f_is_swp_bull(m1_act_sL)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🛡️ MTF OVERLAP FILTER (Priority Logic)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_isOverlap(lvl, htf_array) =>
    isOv = false
    if not na(lvl)
        for val in htf_array
            if not na(val) and math.abs(lvl - val) <= syminfo.mintick
                isOv := true
                break
    isOv

arr_HTF_for_1W = array.from(m1_lvlBull, m1_lvlBear)
arr_HTF_for_1D = array.from(w1_lvlBull, w1_lvlBear, m1_lvlBull, m1_lvlBear)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🖌️ DYNAMIC RENDERING (Z-Index Inverted)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if masterMTF
    // 1. Дневной ТФ
    if show1D
        if d1_bull_trig and not f_isOverlap(d1_lvlBull, arr_HTF_for_1D)
            line.new(x1=d1_timeBull, y1=d1_lvlBull, x2=time, y2=d1_lvlBull, xloc=xloc.bar_time, color=c_1D, width=2, style=line.style_solid)
        if d1_bear_trig and not f_isOverlap(d1_lvlBear, arr_HTF_for_1D)
            line.new(x1=d1_timeBear, y1=d1_lvlBear, x2=time, y2=d1_lvlBear, xloc=xloc.bar_time, color=c_1D, width=2, style=line.style_solid)
            
        if showSweeps
            if d1_swpBear_trig
                label.new(x=time, y=high, text="✖", xloc=xloc.bar_time, color=c_transp, textcolor=c_1D, style=label.style_label_down, size=size.small)
                line.new(x1=d1_time_sH, y1=d1_act_sH, x2=time, y2=d1_act_sH, xloc=xloc.bar_time, color=c_1D, width=1, style=line.style_dashed)
            if d1_swpBull_trig
                label.new(x=time, y=low, text="✖", xloc=xloc.bar_time, color=c_transp, textcolor=c_1D, style=label.style_label_up, size=size.small)
                line.new(x1=d1_time_sL, y1=d1_act_sL, x2=time, y2=d1_act_sL, xloc=xloc.bar_time, color=c_1D, width=1, style=line.style_dashed)

    // 2. Недельный ТФ
    if show1W
        if w1_bull_trig and not f_isOverlap(w1_lvlBull, arr_HTF_for_1W)
            line.new(x1=w1_timeBull, y1=w1_lvlBull, x2=time, y2=w1_lvlBull, xloc=xloc.bar_time, color=c_1W, width=3, style=line.style_solid)
        if w1_bear_trig and not f_isOverlap(w1_lvlBear, arr_HTF_for_1W)
            line.new(x1=w1_timeBear, y1=w1_lvlBear, x2=time, y2=w1_lvlBear, xloc=xloc.bar_time, color=c_1W, width=3, style=line.style_solid)

        if showSweeps
            if w1_swpBear_trig
                label.new(x=time, y=high, text="✖", xloc=xloc.bar_time, color=c_transp, textcolor=c_1W, style=label.style_label_down, size=size.small)
                line.new(x1=w1_time_sH, y1=w1_act_sH, x2=time, y2=w1_act_sH, xloc=xloc.bar_time, color=c_1W, width=1, style=line.style_dashed)
            if w1_swpBull_trig
                label.new(x=time, y=low, text="✖", xloc=xloc.bar_time, color=c_transp, textcolor=c_1W, style=label.style_label_up, size=size.small)
                line.new(x1=w1_time_sL, y1=w1_act_sL, x2=time, y2=w1_act_sL, xloc=xloc.bar_time, color=c_1W, width=1, style=line.style_dashed)

    // 3. Месячный ТФ
    if show1M
        if m1_bull_trig
            line.new(x1=m1_timeBull, y1=m1_lvlBull, x2=time, y2=m1_lvlBull, xloc=xloc.bar_time, color=c_1M, width=4, style=line.style_solid)
        if m1_bear_trig
            line.new(x1=m1_timeBear, y1=m1_lvlBear, x2=time, y2=m1_lvlBear, xloc=xloc.bar_time, color=c_1M, width=4, style=line.style_solid)

        if showSweeps
            if m1_swpBear_trig
                label.new(x=time, y=high, text="✖", xloc=xloc.bar_time, color=c_transp, textcolor=c_1M, style=label.style_label_down, size=size.normal)
                line.new(x1=m1_time_sH, y1=m1_act_sH, x2=time, y2=m1_act_sH, xloc=xloc.bar_time, color=c_1M, width=2, style=line.style_dashed)
            if m1_swpBull_trig
                label.new(x=time, y=low, text="✖", xloc=xloc.bar_time, color=c_transp, textcolor=c_1M, style=label.style_label_up, size=size.normal)
                line.new(x1=m1_time_sL, y1=m1_act_sL, x2=time, y2=m1_act_sL, xloc=xloc.bar_time, color=c_1M, width=2, style=line.style_dashed)
````
