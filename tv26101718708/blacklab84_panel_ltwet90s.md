# Blacklab84 Panel

- url: https://www.tradingview.com/script/ltWET90s-Blacklab84-Panel/
- type: indicator
- pine_id: PUB;3ad95b1bb931485290a6925b3bdbba9b
- version: 1.0

## Description

E D G E  —  Momentum Panel                                 
                                                            
PANEL COMPONENTS:                                           
• Chande Momentum Oscillator — less lag than RSI            
• Trend Strength (ADX-style) — know when trend has teeth    
• Volume Delta bar — are buyers or sellers in control?      
• Divergence detection — CMO vs price

## Source Code

````pine
//@version=6
// ╔══════════════════════════════════════════════════════════════╗
// ║  E D G E  —  Momentum Panel                                 ║
// ║                                                              ║
// ║  PANEL COMPONENTS:                                           ║
// ║  • Chande Momentum Oscillator — less lag than RSI            ║
// ║  • Trend Strength (ADX-style) — know when trend has teeth    ║
// ║  • Volume Delta bar — are buyers or sellers in control?      ║
// ║  • Divergence detection — CMO vs price                       ║
// ╚══════════════════════════════════════════════════════════════╝
indicator("EDGE Panel", shorttitle="EDGE Panel", overlay=false, explicit_plot_zorder=true)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PALETTE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
C_BULL_BRIGHT = color.new(#00e5a0, 0)
C_BULL_FADE   = color.new(#00e5a0, 80)
C_BEAR_BRIGHT = color.new(#ff4455, 0)
C_BEAR_FADE   = color.new(#ff4455, 80)
C_AMBER       = color.new(#f0c040, 0)
C_SLATE       = color.new(#7c8db5, 0)
C_SLATE_FADE  = color.new(#7c8db5, 70)
C_BG_OB       = color.new(#ff4455, 93)
C_BG_OS       = color.new(#00e5a0, 93)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
g1 = "Chande Momentum"
cmoLen    = input.int(14,   "CMO Length",       group=g1, minval=3)
cmoOB     = input.int(50,   "Overbought",       group=g1)
cmoOS     = input.int(-50,  "Oversold",         group=g1)
showDiv   = input.bool(true,"Show Divergence",  group=g1)

g2 = "Trend Strength"
adxLen    = input.int(14,   "ADX Length",       group=g2, minval=3)
adxStrong = input.int(25,   "Strong Trend >",   group=g2)
showADX   = input.bool(true,"Show Trend Strength Bar", group=g2)



// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SCALE ANCHORS — must be first, force 0-100 pane
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(105,  title="_top",    color=color.new(color.white, 100), editable=false)
plot(-105, title="_bottom", color=color.new(color.white, 100), editable=false)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ① CHANDE MOMENTUM OSCILLATOR
//    CMO = (sum of up moves - sum of down moves) / total moves × 100
//    Range: -100 to +100 (0 = neutral)
//    Better than RSI: symmetric around 0, no smoothing distortion
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
momUp   = math.max(close - close[1], 0)
momDn   = math.max(close[1] - close, 0)
sumUp   = math.sum(momUp, cmoLen)
sumDn   = math.sum(momDn, cmoLen)
cmo     = sumUp + sumDn != 0 ? 100 * (sumUp - sumDn) / (sumUp + sumDn) : 0

// Signal line — 5-bar EMA of CMO
cmoSig  = ta.ema(cmo, 5)

// Color: 4 states
cmoColor = cmo >= cmoOB ? C_BEAR_BRIGHT : cmo <= cmoOS ? C_BULL_BRIGHT : cmo > 0 ? C_BULL_FADE : C_BEAR_FADE

// OB/OS zones
bgcolor(cmo >= cmoOB ? C_BG_OB : na, title="CMO OB Zone")
bgcolor(cmo <= cmoOS ? C_BG_OS : na, title="CMO OS Zone")

hline(cmoOB,  title="OB",      color=color.new(#ff4466, 50), linestyle=hline.style_dashed)
hline(0,      title="Zero",    color=color.new(#7c8db5, 50), linestyle=hline.style_dotted)
hline(cmoOS,  title="OS",      color=color.new(#00e5a0, 50), linestyle=hline.style_dashed)

plot(cmo,    title="CMO",     color=cmoColor,                    linewidth=3)
plot(cmoSig, title="CMO Sig", color=color.new(#f0c040, 0),       linewidth=1)

// ─── CMO Divergence ──────────────────────────────────────
// Uses confirmed price pivots, reads CMO value at that bar
c_pivLen = 10

c_priceH = ta.pivothigh(high, c_pivLen, c_pivLen)
c_priceL = ta.pivotlow(low,  c_pivLen, c_pivLen)

c_cmoAtPivH = cmo[c_pivLen]
c_cmoAtPivL = cmo[c_pivLen]

var float c_prevPriceH1 = na
var float c_prevCmoH1   = na
var float c_prevPriceH2 = na
var float c_prevCmoH2   = na

var float c_prevPriceL1 = na
var float c_prevCmoL1   = na
var float c_prevPriceL2 = na
var float c_prevCmoL2   = na

bearDiv = false
bullDiv = false

if not na(c_priceH)
    c_prevPriceH2 := c_prevPriceH1
    c_prevCmoH2   := c_prevCmoH1
    c_prevPriceH1 := c_priceH
    c_prevCmoH1   := c_cmoAtPivH
    if not na(c_prevPriceH2) and not na(c_prevCmoH2)
        if c_prevPriceH1 > c_prevPriceH2 and c_prevCmoH1 < c_prevCmoH2
            bearDiv := true

if not na(c_priceL)
    c_prevPriceL2 := c_prevPriceL1
    c_prevCmoL2   := c_prevCmoL1
    c_prevPriceL1 := c_priceL
    c_prevCmoL1   := c_cmoAtPivL
    if not na(c_prevPriceL2) and not na(c_prevCmoL2)
        if c_prevPriceL1 < c_prevPriceL2 and c_prevCmoL1 > c_prevCmoL2
            bullDiv := true

// CMO divergence — gold circles, outer position (further from zero)
plot(showDiv and bearDiv ? 97  : na, title="Bear Div (CMO)", style=plot.style_circles, color=color.new(#ffd600, 0), linewidth=4, offset=-c_pivLen)
plot(showDiv and bullDiv ? -97 : na, title="Bull Div (CMO)", style=plot.style_circles, color=color.new(#ffd600, 0), linewidth=4, offset=-c_pivLen)

// ─── RSI Divergence (white diamonds) ─────────────────────
// Independent divergence using RSI at confirmed price pivots
c_rsi14 = ta.rsi(close, 14)

c_rsiAtPivH = c_rsi14[c_pivLen]
c_rsiAtPivL = c_rsi14[c_pivLen]

var float c_prevRsiH1   = na
var float c_prevRsiH2   = na
var float c_prevRsiL1   = na
var float c_prevRsiL2   = na
var float c_prevRsiPH1  = na   // price at that pivot
var float c_prevRsiPH2  = na
var float c_prevRsiPL1  = na
var float c_prevRsiPL2  = na

rsiBearDiv = false
rsiBullDiv = false

if not na(c_priceH)
    c_prevRsiPH2 := c_prevRsiPH1
    c_prevRsiH2  := c_prevRsiH1
    c_prevRsiPH1 := c_priceH
    c_prevRsiH1  := c_rsiAtPivH
    if not na(c_prevRsiPH2) and not na(c_prevRsiH2)
        if c_prevRsiPH1 > c_prevRsiPH2 and c_prevRsiH1 < c_prevRsiH2
            rsiBearDiv := true

if not na(c_priceL)
    c_prevRsiPL2 := c_prevRsiPL1
    c_prevRsiL2  := c_prevRsiL1
    c_prevRsiPL1 := c_priceL
    c_prevRsiL1  := c_rsiAtPivL
    if not na(c_prevRsiPL2) and not na(c_prevRsiL2)
        if c_prevRsiPL1 < c_prevRsiPL2 and c_prevRsiL1 > c_prevRsiL2
            rsiBullDiv := true

// RSI divergence — white diamonds, inner position (closer to zero than gold)
plot(showDiv and rsiBearDiv ? 88  : na, title="Bear Div (RSI)", style=plot.style_circles, color=color.new(#ffffff, 10), linewidth=3, offset=-c_pivLen)
plot(showDiv and rsiBullDiv ? -88 : na, title="Bull Div (RSI)", style=plot.style_circles, color=color.new(#ffffff, 10), linewidth=3, offset=-c_pivLen)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ② TREND STRENGTH (Directional Movement Index)
//    Plotted as a thin bar at the top of the pane (85-100)
//    Amber when trending (ADX > threshold), slate when ranging
//    This is the "do I trade this move?" filter
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Manual ADX calculation (Pine v6 compatible)
trueRange  = math.max(high - low, math.max(math.abs(high - close[1]), math.abs(low - close[1])))
dmPlus     = high - high[1] > low[1] - low ? math.max(high - high[1], 0) : 0
dmMinus    = low[1] - low > high - high[1] ? math.max(low[1] - low, 0) : 0

smTR      = ta.rma(trueRange, adxLen)
smDMPlus  = ta.rma(dmPlus,    adxLen)
smDMMinus = ta.rma(dmMinus,   adxLen)

diPlus    = smTR != 0 ? smDMPlus  / smTR * 100 : 0
diMinus   = smTR != 0 ? smDMMinus / smTR * 100 : 0
dx        = diPlus + diMinus != 0 ? math.abs(diPlus - diMinus) / (diPlus + diMinus) * 100 : 0
adx       = ta.rma(dx, adxLen)

isTrending = adx > adxStrong
// Map ADX (0-100) into top strip of pane (85 to 100)
adxMapped  = 85 + adx / 100 * 15

adxColor  = isTrending ? C_AMBER : C_SLATE_FADE
plot(showADX ? adxMapped : na, title="Trend Strength", color=adxColor, linewidth=4, style=plot.style_line)
hline(85 + adxStrong / 100 * 15, title="Trend Threshold", color=color.new(#f0c040, 70), linestyle=hline.style_dotted)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ③ VOLATILITY STATE — faint line in panel bottom strip
//    ATR percentile mapped to -105 to -85 strip at bottom
//    Rises toward -85 when volatility is expanding (trending)
//    Falls toward -105 when volatility is compressing (coiling)
//    Amber = trending/expanding, Slate = ranging/compressing
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
p_atrLen    = input.int(14,  "ATR Length",        group="Volatility Line", minval=1)
p_atrPctLen = input.int(100, "Percentile Window", group="Volatility Line", minval=20)
showVolLine = input.bool(true, "Show Volatility Line", group="Volatility Line")

p_atr    = ta.atr(p_atrLen)
p_atrPct = 0.0
if barstate.isconfirmed
    p_count = 0
    for i = 1 to p_atrPctLen
        if p_atr[i] < p_atr
            p_count += 1
    p_atrPct := p_count / p_atrPctLen * 100

// Map percentile (0-100) into bottom strip (-105 to -85)
p_volMapped = -105 + p_atrPct / 100 * 20
p_volColor  = p_atrPct >= 70 ? color.new(#f0c040, 55) : color.new(#7c8db5, 70)

plot(showVolLine ? p_volMapped : na, title="Volatility State", color=p_volColor, linewidth=2, style=plot.style_line)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(ta.crossover(cmo,  cmoOS), title="CMO Cross OS Up",   message="EDGE Panel: CMO crossed above oversold — bullish momentum!")
alertcondition(ta.crossunder(cmo, cmoOB), title="CMO Cross OB Down", message="EDGE Panel: CMO crossed below overbought — bearish momentum!")
alertcondition(ta.crossover(cmo,  cmoSig) and cmo < 0, title="CMO Bull Cross",  message="EDGE Panel: CMO bullish signal cross!")
alertcondition(ta.crossunder(cmo, cmoSig) and cmo > 0, title="CMO Bear Cross",  message="EDGE Panel: CMO bearish signal cross!")
alertcondition(bullDiv, title="CMO Bull Divergence", message="EDGE Panel: Bullish divergence on CMO!")
alertcondition(bearDiv, title="CMO Bear Divergence", message="EDGE Panel: Bearish divergence on CMO!")
alertcondition(ta.crossover(adx,  adxStrong), title="Trend Starting",  message="EDGE Panel: Trend strength breaking out — ADX rising!")
alertcondition(ta.crossunder(adx, adxStrong), title="Trend Weakening", message="EDGE Panel: Trend weakening — ADX falling below threshold!")
````
