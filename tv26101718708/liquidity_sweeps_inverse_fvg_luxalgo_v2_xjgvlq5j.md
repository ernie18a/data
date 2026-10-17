# Liquidity Sweeps & Inverse FVG [LuxAlgo] v2

- url: https://www.tradingview.com/script/XJgVlq5j-Liquidity-Sweeps-Inverse-FVG-LuxAlgo-v2/
- type: indicator
- pine_id: PUB;9bd6ad3b3f1742308eb2322006adadc3
- version: 1.0

## Description

sweep indicator with fair value gaps volatility filters

## Source Code

````pine
//@version=6
indicator("Liquidity Sweeps & Inverse FVG [LuxAlgo]", overlay = true, max_boxes_count = 500, max_lines_count = 500)

// --- Groups ---
string G_SWEEP  = "Liquidity Sweeps"
string G_IFVG   = "Inverse Fair Value Gaps"
string G_TREND  = "Trend Filter"
string G_STYLE  = "Style"

// --- Inputs: Liquidity Sweeps ---
lenSweep  = input.int(5, "Swing Length", minval = 1, group = G_SWEEP, tooltip = "Length for pivot detection.")
optSweep  = input.string("Only Wicks", "Sweep Options", options = ["Only Wicks", "Only Outbreaks & Retest", "Wicks + Outbreaks & Retest"], group = G_SWEEP)
extendSwp = input.bool(true, "Extend Sweep Area", group = G_SWEEP) 
maxBSwp   = input.int(300, "Max Bars", minval = 1, maxval = 5000, group = G_SWEEP)

// --- Inputs: IFVG ---
atrLen    = input.int(14, "ATR Length", minval = 1, group = G_IFVG)
volMult   = input.float(0.5, "Volatility Filter (ATR Multiplier)", minval = 0, step = 0.1, group = G_IFVG, tooltip = "Minimum gap size relative to ATR to consider an FVG.")
showFVG   = input.bool(false, "Show Original FVGs", group = G_IFVG, tooltip = "Display regular FVGs before they are inverted.")
maxFVGs   = input.int(50, "Max Active FVGs", minval = 1, maxval = 100, group = G_IFVG)

// --- Inputs: Trend Filter ---
useTrend  = input.bool(true, "Use Trend Filter", group = G_TREND, tooltip = "Only confirm IFVGs that align with the trend (Bullish IFVG above Trend, Bearish IFVG below Trend).")
trendLen  = input.int(200, "Trend Length", minval = 1, group = G_TREND)
trendType = input.string("EMA", "Trend Type", options = ["EMA", "SMA"], group = G_TREND)

// --- Inputs: Style ---
bullColor = input.color(#089981, "Bullish Color", group = G_STYLE, inline = "bull")
bullFill  = input.color(color.new(#089981, 80), "", group = G_STYLE, inline = "bull")
bearColor = input.color(#f23645, "Bearish Color", group = G_STYLE, inline = "bear")
bearFill  = input.color(color.new(#f23645, 80), "", group = G_STYLE, inline = "bear")

// --- Constants & Types ---
oW = optSweep == "Only Wicks"
oO = optSweep == "Only Outbreaks & Retest"

type piv
    float prc 
    int   bix 
    bool  brk 
    bool  mit 
    bool  tak 
    bool  wic 
    line  lin 

type boxBr 
    box  bx 
    line ln
    bool br
    int  dr

type FVG
    float top
    float bottom
    int   start_index
    bool  is_bull
    bool  is_inverted
    box   bx

// --- Arrays & Variables ---
var aPivH  = array.new<piv>()
var aPivL  = array.new<piv>()
var aBoxBr = array.new<boxBr>()
var aFVGs  = array.new<FVG>()

n = bar_index
atr = ta.atr(atrLen)

// Trend Calculation
trend = trendType == "EMA" ? ta.ema(close, trendLen) : ta.sma(close, trendLen)
plot(useTrend ? trend : na, "Trend Filter", color.new(chart.fg_color, 50), 2)

// --- Methods & Functions ---
method n(float p) => not na(p)

method l(piv get, color c, string s = "sd") => 
    style = switch s 
        "dt" => line.style_dotted
        "ds" => line.style_dashed
        =>      line.style_solid 
    line.new(get.bix, get.prc, n, get.prc, color = c, style = style)

method br(piv get, color c3, color c, int d) =>
    y1 = d == 1 ? high : get.prc
    y2 = d == 1 ? get.prc : low
    boxBr.new(box.new(n - 1, y1, n + 1, y2, border_color = color.new(na, 0), bgcolor = c3), line.new(n, y1, n, y2, color = c, width = 3), false, d)

lnDot(y, c) => line.new(n, y, n + 3, y, color = c, style = line.style_dotted)

// --- Liquidity Sweeps Logic ---
ph = ta.pivothigh(lenSweep, lenSweep)
pl = ta.pivotlow(lenSweep, lenSweep)

if ph.n() 
    aPivH.unshift(piv.new(ph, n - lenSweep, false, false, false, false, line(na)))

if pl.n() 
    aPivL.unshift(piv.new(pl, n - lenSweep, false, false, false, false, line(na))) 

for i = array.size(aPivH) - 1 to 0
    get = aPivH.get(i)
    if not get.mit
        if not get.brk
            if close > get.prc 
                if not oW
                    get.brk := true
                else 
                    get.mit := true
            if not oO and not get.wic 
                if high > get.prc and close < get.prc                   
                    aBoxBr.unshift(get.br(color.new(bearColor, 80), bearColor, 1))       
                    get.l(color.new(bearColor, 50), "dt"), lnDot(low, bearColor)
                    get.wic := true  
        else 
            if close < get.prc 
                get.mit := true
            if not oW and low < get.prc and close > get.prc                    
                aBoxBr.unshift(get.br(color.new(bullColor, 80), bullColor, -1))    
                get.l(color.new(bullColor, 50), "ds"), lnDot(high, bullColor)
                get.tak := true 

    if n - get.bix > 2000 or get.mit or get.tak 
        piv p = aPivH.remove(i)
        if not na(p.lin)
            p.lin.delete()

for i = array.size(aPivL) - 1 to 0
    get = aPivL.get(i)
    if not get.mit
        if not get.brk
            if close < get.prc 
                if not oW
                    get.brk := true
                else 
                    get.mit := true
            if not oO and not get.wic 
                if low < get.prc and close > get.prc                              
                    aBoxBr.unshift(get.br(color.new(bullColor, 80), bullColor, -1))     
                    get.l(color.new(bullColor, 50), "dt"), lnDot(high, bullColor)
                    get.wic := true 
        else 
            if close > get.prc 
                get.mit := true
            if not oW and high > get.prc and close < get.prc                     
                aBoxBr.unshift(get.br(color.new(bearColor, 80), bearColor, 1))    
                get.l(color.new(bearColor, 50), "ds"), lnDot(low, bearColor)
                get.tak := true  

    if n - get.bix > 2000 or get.mit or get.tak 
        piv p = aPivL.remove(i)
        if not na(p.lin)
            p.lin.delete()

if extendSwp
    for bx in aBoxBr 
        if not bx.br and n - bx.bx.get_left() - 1 <= maxBSwp 
            bx.bx.set_right(bar_index)
            if bx.dr == -1 and close < bx.bx.get_bottom() 
                bx.br := true 
            if bx.dr ==  1 and close > bx.bx.get_top() 
                bx.br := true 

// --- Inverse Fair Value Gaps Logic ---

// FVG Detection
bull_fvg = low > high[2] and close[1] > high[2]
bear_fvg = high < low[2] and close[1] < low[2]

// Volatility Filter
fvg_size = bull_fvg ? low - high[2] : (bear_fvg ? low[2] - high : 0.0)
is_significant = fvg_size >= (nz(atr[1]) * volMult)

if bull_fvg and is_significant
    aFVGs.unshift(FVG.new(low, high[2], n - 1, true, false, showFVG ? box.new(n - 2, high[2], n, low, bgcolor = bullFill, border_color = color.new(na, 0)) : na))
if bear_fvg and is_significant
    aFVGs.unshift(FVG.new(low[2], high, n - 1, false, false, showFVG ? box.new(n - 2, high, n, low[2], bgcolor = bearFill, border_color = color.new(na, 0)) : na))

// Alert Variables
var bool alertBullIFVG = false
var bool alertBearIFVG = false
alertBullIFVG := false
alertBearIFVG := false

// FVG Processing (Mitigation & Inversion)
if aFVGs.size() > 0
    for i = aFVGs.size() - 1 to 0
        fvg = aFVGs.get(i)
        
        if not fvg.is_inverted
            // Condition Checks
            isBullFlip = fvg.is_bull and close < fvg.bottom
            isBearFlip = not fvg.is_bull and close > fvg.top
            
            // Trend Alignment check
            // Original Bull FVG flipped -> Bearish IFVG (Price must be < Trend)
            // Original Bear FVG flipped -> Bullish IFVG (Price must be > Trend)
            if isBullFlip and (not useTrend or close < trend)
                fvg.is_inverted := true
                alertBearIFVG := true
                if not na(fvg.bx)
                    fvg.bx.delete()
                fvg.bx := box.new(fvg.start_index, fvg.bottom, n, fvg.top, bgcolor = bearFill, border_color = bearColor, border_style = line.style_dashed)
            else if isBearFlip and (not useTrend or close > trend)
                fvg.is_inverted := true
                alertBullIFVG := true
                if not na(fvg.bx)
                    fvg.bx.delete()
                fvg.bx := box.new(fvg.start_index, fvg.bottom, n, fvg.top, bgcolor = bullFill, border_color = bullColor, border_style = line.style_dashed)
            else
                if not na(fvg.bx)
                    fvg.bx.set_right(n)
        else
            fvg.bx.set_right(n)

    if aFVGs.size() > maxFVGs
        aFVGs.pop()

// --- Alerts ---
if alertBullIFVG
    alert("Bullish IFVG Confirmed", alert.freq_once_per_bar_close)
if alertBearIFVG
    alert("Bearish IFVG Confirmed", alert.freq_once_per_bar_close)

alertcondition(alertBullIFVG, "Bullish IFVG Confirmed", "A bearish FVG has been inverted into a bullish zone.")
alertcondition(alertBearIFVG, "Bearish IFVG Confirmed", "A bullish FVG has been inverted into a bearish zone.")
````
