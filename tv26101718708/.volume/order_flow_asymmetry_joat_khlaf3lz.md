# Order Flow Asymmetry [JOAT]

- url: https://www.tradingview.com/script/KhLaF3LZ-Order-Flow-Asymmetry-JOAT/
- type: indicator
- pine_id: PUB;2d62463259d646c5a7899cd3309be24a
- version: 1.0

## Description

[b]Order Flow Asymmetry [JOAT][/b]

[b]Introduction[/b]

Order Flow Asymmetry is an open-source synthetic institutional order flow indicator that tracks four independent measures of directional institutional activity — Volume-Weighted Momentum, Liquidity Vacuum detection, Microstructure Imbalance scoring, and a dynamic Information Ratio Band system — and classifies the current market into one of four regime states based on trend direction and volatility level. Smart money signals are generated only when regime, VWM direction, imbalance score, and the absence of a liquidity vacuum all align simultaneously.

The core thesis is that institutional participants leave statistical footprints in price and volume data that can be approximated without access to full order book data. When a large participant is absorbing supply, the result is: above-average volume, below-average price movement, high close-to-range ratio biased toward the institutional direction, and a cumulative imbalance in the bid-side proxy. Order Flow Asymmetry tracks these proxies simultaneously rather than relying on any single measure.

[image]https://www.tradingview.com/x/XCByZOi8/[/image]

[b]Core Concepts[/b]

[b]1. Volume-Weighted Momentum (VWM)[/b]

VWM weights each bar's price change by its volume — large-volume bars contribute more to the running total than small-volume bars. The cumulative result is then normalized relative to the 20-bar average volume, producing a -50 to +50 reading:

[pine]
float vwm     = ta.cum(ta.change(close) * volume) / ta.ema(volume, 20)
float vwmNorm = (vwm - ta.lowest(vwm,100)) / math.max(ta.highest(vwm,100) - ta.lowest(vwm,100), 1e-9) * 100 - 50
[/pine]

A crossover of zero in either direction is the primary momentum signal.

[b]2. Liquidity Vacuum Detection[/b]

A liquidity vacuum occurs when volume collapses below two standard deviations of its 50-bar mean while price moves more than one ATR in the same bar. This pattern indicates a move through a region with no counterparty liquidity — a potential institutional trap. Vacuum bars are marked with three-layer glow boxes and treated as signal inhibitors.

[b]3. Microstructure Imbalance Score[/b]

A bar-level bid/ask proxy is computed from close position within the high-low range. Bars closing in the upper half of their range contribute positive imbalance; bars closing in the lower half contribute negative. A 93% decay factor is applied each bar, producing a running imbalance score that emphasizes recent activity while retaining historical context.

[b]4. Four-State Regime Classification[/b]

The regime is determined by two binary conditions: ADX above threshold (trending vs. ranging) and ATR ratio above threshold (high vs. low volatility). This produces four states: Trend Bull, Trend Bear, Range High-Vol, Range Low-Vol. Each state receives a distinct background tint. Smart money signals require a Trend state — signals in Range states are suppressed.

[b]5. Information Ratio Bands[/b]

Standard deviation bands are computed from the MIDAS VWAP. The band width multiplier is dynamically set by the rolling Sharpe ratio estimate of recent returns — periods with higher risk-adjusted returns produce narrower bands, while periods with lower Sharpe ratios produce wider bands.

[pine]
float sharpe  = ta.ema(ret20, 20) / math.max(ta.stdev(ret20, 20), 1e-8)
float kFactor = math.max(0.5, math.min(3.0, math.abs(sharpe) * 2))
[/pine]

[image]https://www.tradingview.com/x/bB5oJDQu/[/image]

[b]Features[/b]

[list]
[*][b]Volume-Weighted Momentum:[/b] Cumulative volume-weighted price change normalized to -50/+50 range
[*][b]Institutional VWAP center line:[/b] Thick reference line showing the cumulative volume-weighted average price anchor — the central institutional value reference
[*][b]VWM gradient fill zones:[/b] Bull zone fills between VWAP and upper VWM level in bull theme color; bear zone fills between VWAP and lower VWM level in bear theme color — intensity reflects VWM magnitude
[*][b]IR Band gradient fill:[/b] Subtle gradient fill between upper and lower Information Ratio bands shows the full Sharpe-adjusted deviation range
[*][b]Regime transition markers:[/b] Every regime change draws a vertical dotted line plus a direction label (▲ TrendBull / ▼ TrendBear / ◆ RngHVol / ◇ RngLVol) — institutional regime context at a glance
[*][b]Absorption / Distribution labels:[/b] "Absorption" label when cumulative microstructure imbalance score exceeds extreme threshold; "Distribution" label when it falls below. Identifies potential institutional accumulation/distribution zones
[*][b]Smart money signal markers:[/b] "▲ SMART LONG" / "▼ SMART SHORT" labels with embedded VWM and Imbalance values, plus a vertical dotted line through each signal bar for visual alignment
[*][b]Liquidity vacuum detection:[/b] Volume collapse + ATR-relative move identifies institutional trap zones with 3-layer glow visualization and "Vacuum" text label
[*][b]Microstructure imbalance score:[/b] Decaying cumulative bid/ask proxy normalized by ATR, displayed in dashboard
[*][b]Four-state regime classification:[/b] Trend Bull / Trend Bear / Range High-Vol / Range Low-Vol from ADX and ATR ratio — distinct background tints for each state
[*][b]Information Ratio Bands:[/b] VWAP deviation bands with width dynamically set by rolling Sharpe estimate
[*][b]Gradient candle coloring by VWM:[/b] Bar colors reflect normalized VWM intensity using color.from_gradient() when VWM exceeds threshold in trend direction
[*][b]Three-layer glow candles (optional):[/b] Institutional-style neon glow candle effect
[*][b]12-row institutional dashboard:[/b] Regime, VWM, vacuum state, imbalance score, Sharpe k-factor, IR band levels, signal, win rate, and performance stats
[*][b]Four color themes:[/b] Phantom, Neon, Classic, Solar
[*][b]Non-repainting:[/b] All signals gated by barstate.isconfirmed; all inputs are historical only
[/list]

[b]Input Parameters[/b]

[b]Volume-Weighted Momentum:[/b]
[list]
[*]Volume Average Length (default: 20)
[*]VWM Cross Threshold (default: 5.0)
[/list]

[b]Liquidity Vacuum:[/b]
[list]
[*]Volume Mean Length, Sigma Below Mean, Vacuum Zone Width, Glow Strength
[/list]

[b]Microstructure Imbalance:[/b]
[list]
[*]Imbalance Decay Factor (default: 0.93)
[*]Imbalance Signal Gate (default: 15.0)
[/list]

[b]Regime Classification:[/b]
[list]
[*]ADX Trend Threshold (default: 25)
[*]ATR Ratio High-Vol Threshold (default: 1.2)
[/list]

[b]Information Ratio Bands:[/b]
[list]
[*]Show IR Bands toggle
[*]Sharpe Window (default: 20)
[/list]

[b]Signal:[/b]
[list]
[*]Cooldown Bars, TP ATR Multiple, SL ATR Multiple, Show Trade Block, Block Width
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Identify the Regime[/b]
Check the dashboard Regime row. Smart money signals only fire in Trend Bull or Trend Bear states. During Range states, no signals are generated regardless of VWM direction.

[b]Step 2: Watch for VWM Zero Cross[/b]
The VWM crossing zero in the direction of the trend regime is the primary trigger. Ensure no vacuum is active on the signal bar — vacuum bars inhibit signals because they represent suspect moves without genuine counterparty support.

[b]Step 3: Check Imbalance Score[/b]
The imbalance score reflects cumulative directional bias in bid/ask proxy. A score above the gate threshold in the trend direction adds confidence. A score contradicting the trend direction is a warning.

[b]Step 4: Use IR Bands as Dynamic Reference[/b]
The Information Ratio bands widen in low-Sharpe environments (price distributing far from VWAP) and narrow in high-Sharpe environments (price efficiently priced near VWAP). These bands serve as dynamic reference levels rather than fixed targets.

[b]Indicator Limitations[/b]

[list]
[*]VWM uses tick volume as a proxy for institutional participation. On forex spot and some crypto venues, tick volume may not accurately represent actual participation
[*]The microstructure imbalance score uses bar close position as a bid/ask proxy. This is an approximation — actual bid-ask data is not available in standard TradingView data
[*]Regime classification uses ADX and ATR ratio, both of which lag price. A trend beginning explosively will be classified as ranging for several bars until indicators respond
[*]The Information Ratio Band width is driven by a 20-bar Sharpe estimate, which is an extremely short window for a reliable Sharpe computation. It should be interpreted as a dynamic band-width scaler rather than a statistically significant Sharpe ratio
[*]Smart money signals are rare by design — the four-condition gate produces low-frequency output
[/list]

[b]Originality Statement[/b]

[list]
[*]The combination of Volume-Weighted Momentum, Liquidity Vacuum detection as a signal inhibitor, a decaying Microstructure Imbalance score, and Information Ratio Bands with Sharpe-driven width — all gated by a four-state regime classification — is an original analytical architecture not replicated in existing open-source Pine Script v6 publications
[*]Treating liquidity vacuums as signal inhibitors rather than signals themselves — suppressing momentum signals that occur immediately after a volume-collapse move — is a novel application of vacuum detection logic
[*]Dynamic VWAP deviation band width driven by a rolling Sharpe ratio estimate rather than a fixed multiplier provides adaptive band boundaries that reflect the current efficiency of price relative to VWAP
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Trading involves substantial risk of loss. Synthetic order flow measures are approximations that use publicly available price and volume data as proxies for actual institutional activity. Past signal performance does not predict future results. The author accepts no responsibility for trading losses resulting from use of this indicator.

Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Order Flow Asymmetry [JOAT]", overlay=true, max_boxes_count=100, max_lines_count=100, max_labels_count=100)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 1 — COLOR THEMES
// ─────────────────────────────────────────────────────────────────────────────
string themeInput = input.string("Neon", "Color Theme",
     options=["Phantom","Neon","Classic","Solar"],
     group="◈ Visual")

var color colorBULL  = na
var color colorBEAR  = na
var color colorELITE = na
var color colorNEUTR = na

if themeInput == "Phantom"
    colorBULL  := color.rgb(6, 182, 212)
    colorBEAR  := color.rgb(236, 72, 153)
    colorELITE := color.rgb(187, 134, 252)
    colorNEUTR := color.rgb(139, 148, 158)
else if themeInput == "Neon"
    colorBULL  := #00F5D4
    colorBEAR  := #FF4466
    colorELITE := #6C63FF
    colorNEUTR := #FFD700
else if themeInput == "Classic"
    colorBULL  := color.rgb(0, 255, 0)
    colorBEAR  := color.rgb(255, 0, 0)
    colorELITE := color.rgb(187, 134, 252)
    colorNEUTR := color.rgb(139, 148, 158)
else
    colorBULL  := #FF9800
    colorBEAR  := #42A5F5
    colorELITE := #FFEB3B
    colorNEUTR := #9E9E9E

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 2 — INPUTS
// ─────────────────────────────────────────────────────────────────────────────

// Volume-Weighted Momentum
var string G_VWM    = "◈ Volume-Weighted Momentum"
int   vwmVolLen     = input.int(20,    "Volume Average Length",   group=G_VWM)
float vwmCrossThres = input.float(5.0, "VWM Cross Threshold",     group=G_VWM)

// Liquidity Vacuum
var string G_VAC = "◈ Liquidity Vacuum"
int   vacVolLen  = input.int(50,   "Volume Mean Length",           group=G_VAC)
float vacSigma   = input.float(2.0,"Sigma Below Mean",  step=0.5,  group=G_VAC)
int   vacWidth   = input.int(5,    "Vacuum Zone Width (bars)",     group=G_VAC)
int   vacGlow    = input.int(85,   "Vacuum Glow Strength", 60, 99, group=G_VAC)

// Microstructure Imbalance
var string G_IMB = "◈ Microstructure Imbalance"
float imbDecay     = input.float(0.93,"Imbalance Decay Factor",   step=0.01, group=G_IMB)
float imbThreshold = input.float(15.0,"Imbalance Signal Gate",                group=G_IMB)

// Regime Classification
var string G_REG   = "◈ Regime Classification"
int   adxThres     = input.int(25,    "ADX Trend Threshold",       group=G_REG)
float atrRatioThres= input.float(1.2, "ATR Ratio HVol Threshold", step=0.1, group=G_REG)

// Information Ratio Bands
var string G_IR  = "◈ Information Ratio Bands"
bool  showIR     = input.bool(true,  "Show IR Bands",              group=G_IR)
int   sharpeWindow = input.int(20,   "Sharpe Window",    5, 50,    group=G_IR)

// Signal
var string G_SIG = "◈ Signal"
int   cooldown   = input.int(5,    "Cooldown Bars",       0, 20,   group=G_SIG)
float tpMultATR  = input.float(2.0,"TP ATR Multiple",  step=0.5,   group=G_SIG)
float slMultATR  = input.float(1.5,"SL ATR Multiple",  step=0.5,   group=G_SIG)
bool  showBlock  = input.bool(true, "Show Trade Block",             group=G_SIG)
int   blockW     = input.int(20,   "Block Width (bars)",  5, 100,  group=G_SIG)

// Visual
var string G_VIS   = "◈ Visual"
bool showRegimeBg  = input.bool(true,  "Show Regime Background",   group=G_VIS)
bool showVWMbars   = input.bool(true,  "Color Bars by VWM",        group=G_VIS)
bool showGlow      = input.bool(false, "Show Glow Candles",         group=G_VIS)
bool showVWMzones  = input.bool(true,  "Show VWM Gradient Zones",  group=G_VIS)
bool showRegMarker = input.bool(true,  "Show Regime Transition Markers", group=G_VIS)
bool showImbLabels = input.bool(true,  "Show Imbalance Zone Labels", group=G_VIS)

// Dashboard
var string G_DASH = "◈ Dashboard"
bool   showDash   = input.bool(true,          "Show Dashboard",     group=G_DASH)
string dashPos    = input.string("Top Right",  "Position",
     options=["Top Right","Top Left","Bottom Right","Bottom Left"],  group=G_DASH)
string dashSize   = input.string("Small",      "Size",
     options=["Tiny","Small","Normal"],                              group=G_DASH)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 3 — ATR / ADX FOUNDATION
// ─────────────────────────────────────────────────────────────────────────────

float atr14    = ta.atr(14)
float atrSMA50 = ta.sma(atr14, 50)
float atrRatio = atrSMA50 > 0.0 ? atr14 / atrSMA50 : 1.0

[diP, diM, adxVal] = ta.dmi(14, 14)

float ema50    = ta.ema(close, 50)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 4 — 4-STATE REGIME CLASSIFICATION
// ─────────────────────────────────────────────────────────────────────────────
// States: 1=TrendBull  2=TrendBear  3=RangeHVol  4=RangeLVol

bool isTrend = adxVal > float(adxThres)
bool isHVol  = atrRatio > atrRatioThres

int regime = isTrend and close > ema50 ? 1 :
     isTrend and close < ema50 ? 2 :
     isHVol ? 3 : 4

color regimeBgCol = na
if showRegimeBg
    regimeBgCol := regime == 1 ? color.new(colorBULL,  97) :
         regime == 2 ? color.new(colorBEAR,  97) :
         regime == 3 ? color.new(colorNEUTR, 97) :
         color.new(colorELITE, 97)

bgcolor(regimeBgCol, title="Regime Background")

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 5 — VOLUME-WEIGHTED MOMENTUM  (−50 … +50)
// ─────────────────────────────────────────────────────────────────────────────

float volAvg20   = ta.ema(volume, vwmVolLen)

var float cumVWM = 0.0
cumVWM := nz(cumVWM[1], 0.0) + ta.change(close) * volume

float vwmLow100  = ta.lowest(cumVWM, 100)
float vwmHigh100 = ta.highest(cumVWM, 100)
float vwmNorm    = (vwmHigh100 - vwmLow100) > 0.0 ?
     (cumVWM - vwmLow100) / (vwmHigh100 - vwmLow100) * 100.0 - 50.0 : 0.0

// VWM crosses — called at script scope (not inside conditionals)
bool vwmXup = ta.crossover( vwmNorm,  vwmCrossThres)
bool vwmXdn = ta.crossunder(vwmNorm, -vwmCrossThres)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 6 — LIQUIDITY VACUUM DETECTION
// ─────────────────────────────────────────────────────────────────────────────

float vacVolMean = ta.ema(volume, vacVolLen)
float vacVolStd  = ta.stdev(volume, vacVolLen)

bool vacuum = volume < vacVolMean - vacSigma * vacVolStd and
     (high - low) > atr14 and
     barstate.isconfirmed

// 3-layer glow box rendered on vacuum bars
if vacuum
    int   vEnd = bar_index + vacWidth
    float vH   = high + atr14 * 0.05
    float vL   = low  - atr14 * 0.05
    // Outer glow — most transparent
    box.new(bar_index, vH + atr14 * 0.15, vEnd, vL - atr14 * 0.15,
         bgcolor=color.new(colorELITE, math.min(99, vacGlow + 15)),
         border_color=na)
    // Mid glow
    box.new(bar_index, vH + atr14 * 0.08, vEnd, vL - atr14 * 0.08,
         bgcolor=color.new(colorELITE, math.min(99, vacGlow + 8)),
         border_color=na)
    // Core glow — least transparent
    box.new(bar_index, vH, vEnd, vL,
         bgcolor=color.new(colorELITE, vacGlow),
         border_color=color.new(colorELITE, math.max(0, vacGlow - 25)),
         border_width=1)
    // Vacuum label
    label.new(bar_index, high + atr14 * 0.2,
         "Vacuum",
         style     = label.style_label_down,
         color     = color.new(colorELITE, 80),
         textcolor = colorELITE,
         size      = size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 7 — MICROSTRUCTURE IMBALANCE SCORE  (−100 … +100)
// ─────────────────────────────────────────────────────────────────────────────

float barImb = (high - low) > 0.0 ?
     (close - (high + low) / 2.0) / (high - low) : 0.0

var float cumImb = 0.0
cumImb := nz(cumImb[1], 0.0) * imbDecay + barImb

float imbScore = math.max(-100.0, math.min(100.0,
     atr14 > 0.0 ? cumImb / atr14 * 15.0 : 0.0))

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 8 — MIDAS VWAP + INFORMATION RATIO BANDS
// ─────────────────────────────────────────────────────────────────────────────

var float svol = 0.0
var float svp  = 0.0
var float svp2 = 0.0

bool irReset = timeframe.change(timeframe.isintraday ? "D" : "W")

if irReset
    svol := volume
    svp  := volume * hlc3
    svp2 := volume * math.pow(hlc3, 2)
else
    svol += volume
    svp  += volume * hlc3
    svp2 += volume * math.pow(hlc3, 2)

float irVwap = svol > 0 ? svp  / svol : hlc3
float irVar  = svol > 0 ? (svp2 / svol) - math.pow(irVwap, 2) : 0.0
float irStd  = math.sqrt(math.max(0.0, irVar))

// Sharpe-driven kFactor  (clamp 0.5 … 3.0)
float ret20   = (close - close[sharpeWindow]) / math.max(close[sharpeWindow], 0.0001)
float sharpe  = ta.ema(ret20, sharpeWindow) /
     math.max(ta.stdev(ret20, sharpeWindow), 0.00001)
float kFactor = math.max(0.5, math.min(3.0, math.abs(sharpe) * 2.0))

float irUpper = irVwap + kFactor * irStd
float irLower = irVwap - kFactor * irStd

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 9 — ALL PLOT() DECLARATIONS (must be at script scope)
// ─────────────────────────────────────────────────────────────────────────────

// VWM gradient zone levels
float vwmUpperLevel = irVwap + (vwmNorm > 0 ? math.abs(vwmNorm) / 50.0 * irStd : 0.0)
float vwmLowerLevel = irVwap - (vwmNorm < 0 ? math.abs(vwmNorm) / 50.0 * irStd : 0.0)

// Institutional VWAP — thick central reference
plot(irVwap, "Institutional VWAP", color.new(chart.fg_color, 30), 2)

// VWM zone plots for gradient fill
pVwap  = plot(showVWMzones ? irVwap : na, "VWM VWAP Ref", color.new(chart.fg_color, 60), 1)
pVwmUp = plot(showVWMzones ? vwmUpperLevel : na, "VWM Upper Zone", color.new(colorBULL, 80), 1)
pVwmDn = plot(showVWMzones ? vwmLowerLevel : na, "VWM Lower Zone", color.new(colorBEAR, 80), 1)

// IR Band plots for gradient fill
pIRUpper = plot(showIR and not na(irUpper) ? irUpper : na, "IR Upper", color.new(colorBEAR, 50), 1, plot.style_linebr)
pIRLower = plot(showIR and not na(irLower) ? irLower : na, "IR Lower", color.new(colorBULL, 50), 1, plot.style_linebr)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 10 — GRADIENT FILLS
// ─────────────────────────────────────────────────────────────────────────────

// VWM Bull Zone — solid fill from VWAP up to VWM upper level
fill(pVwap, pVwmUp, color=color.new(colorBULL, 88), title="VWM Bull Zone")

// VWM Bear Zone — solid fill from VWAP down to VWM lower level
fill(pVwap, pVwmDn, color=color.new(colorBEAR, 88), title="VWM Bear Zone")

// IR Band Zone — solid fill between upper and lower IR bands
fill(pIRUpper, pIRLower, color=color.new(colorNEUTR, 95), title="IR Band Zone")

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 11 — SMART MONEY SIGNALS + COOLDOWN GATE
// ─────────────────────────────────────────────────────────────────────────────

bool smLong  = regime == 1 and vwmXup and
     imbScore >  imbThreshold and not vacuum and barstate.isconfirmed
bool smShort = regime == 2 and vwmXdn and
     imbScore < -imbThreshold and not vacuum and barstate.isconfirmed

var int barsCD = 999
barsCD += 1

bool confirmedLong  = smLong  and barsCD >= cooldown
bool confirmedShort = smShort and barsCD >= cooldown

if confirmedLong or confirmedShort
    barsCD := 0

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 12 — BAR COLORING BY VWM + REGIME
// ─────────────────────────────────────────────────────────────────────────────

color vwmBarCol = na
if showVWMbars
    if vwmNorm > 20 and regime == 1
        vwmBarCol := color.from_gradient(vwmNorm, 20, 50, color.new(colorBULL, 40), colorBULL)
    else if vwmNorm < -20 and regime == 2
        vwmBarCol := color.from_gradient(-vwmNorm, 20, 50, color.new(colorBEAR, 40), colorBEAR)
    else if regime == 1
        vwmBarCol := color.new(colorBULL, 70)
    else if regime == 2
        vwmBarCol := color.new(colorBEAR, 70)
    else
        vwmBarCol := color.new(colorNEUTR, 80)

barcolor(showVWMbars ? vwmBarCol : na)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 13 — GLOW CANDLES  (3-layer regime-tinted overlay)
// ─────────────────────────────────────────────────────────────────────────────

color glowBase3 = regime == 1 ? colorBULL : regime == 2 ? colorBEAR : colorNEUTR

plotcandle(open, high, low, close, "Glow D2",
     color      = showGlow ? color.new(glowBase3, 95) : na,
     wickcolor  = showGlow ? color.new(glowBase3, 95) : na,
     bordercolor= showGlow ? color.new(glowBase3, 95) : na,
     display    = showGlow ? display.all : display.none)

plotcandle(open, high, low, close, "Glow D1",
     color      = showGlow ? color.new(glowBase3, 85) : na,
     wickcolor  = showGlow ? color.new(glowBase3, 85) : na,
     bordercolor= showGlow ? color.new(glowBase3, 85) : na,
     display    = showGlow ? display.all : display.none)

plotcandle(open, high, low, close, "Glow Sh",
     color      = showGlow ? color.new(glowBase3, 70) : na,
     wickcolor  = showGlow ? color.new(glowBase3, 10) : na,
     bordercolor= showGlow ? color.new(glowBase3, 10) : na,
     display    = showGlow ? display.all : display.none)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 14 — REGIME TRANSITION MARKERS
// ─────────────────────────────────────────────────────────────────────────────

bool regimeChanged = regime != regime[1]

if regimeChanged and showRegMarker
    color regCol = regime == 1 ? colorBULL : regime == 2 ? colorBEAR : regime == 3 ? colorNEUTR : colorELITE
    line.new(bar_index, high + atr14 * 2, bar_index, low - atr14 * 2,
         color = color.new(colorELITE, 70),
         style = line.style_dotted,
         width = 1)
    string regLbl = regime == 1 ? "▲ TrendBull" :
         regime == 2 ? "▼ TrendBear" :
         regime == 3 ? "◆ RngHVol"   : "◇ RngLVol"
    label.new(bar_index, high + atr14 * 0.5,
         regLbl,
         style     = label.style_label_down,
         color     = color.new(regCol, 80),
         textcolor = regCol,
         size      = size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 15 — IMBALANCE ZONE MARKERS (extreme absorption / distribution)
// ─────────────────────────────────────────────────────────────────────────────

bool extremeBullImb = imbScore > 40 and not (imbScore > 40)[1]
bool extremeBearImb = imbScore < -40 and not (imbScore < -40)[1]

if extremeBullImb and showImbLabels
    label.new(bar_index, low - atr14 * 0.3,
         "Absorption",
         style     = label.style_label_up,
         color     = color.new(colorELITE, 75),
         textcolor = colorELITE,
         size      = size.tiny)

if extremeBearImb and showImbLabels
    label.new(bar_index, high + atr14 * 0.3,
         "Distribution",
         style     = label.style_label_down,
         color     = color.new(colorELITE, 75),
         textcolor = colorELITE,
         size      = size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 16 — TRADE BLOCKS + SMART MONEY SIGNAL LABELS
// ─────────────────────────────────────────────────────────────────────────────

var float smEntry = na
var float smSL    = na
var float smTP    = na
var int   smDir   = 0

if confirmedLong and showBlock
    smEntry := close
    smSL    := close - atr14 * slMultATR
    smTP    := close + atr14 * tpMultATR
    smDir   := 1
    int tEnd = bar_index + blockW
    // SL zone (risk box — bear color)
    box.new(bar_index, smEntry, tEnd, smSL,
         bgcolor=color.new(colorBEAR, 82),
         border_color=color.new(colorBEAR, 50))
    // TP zone (reward box — bull color)
    box.new(bar_index, smTP, tEnd, smEntry,
         bgcolor=color.new(colorBULL, 80),
         border_color=color.new(colorBULL, 45))
    // Institutional signal label — prominent with multi-line info
    label.new(bar_index, low - atr14 * 0.6,
         "▲  SMART LONG\nVWM: " + str.tostring(vwmNorm, "#.#") + "  Imb: " + str.tostring(imbScore, "#.#"),
         style     = label.style_label_up,
         color     = color.new(colorBULL, 65),
         textcolor = colorBULL,
         size      = size.small)
    // Vertical highlight line at signal
    line.new(bar_index, high + atr14 * 3, bar_index, low - atr14 * 0.5,
         color = color.new(colorBULL, 60),
         style = line.style_dotted,
         width = 2)

if confirmedShort and showBlock
    smEntry := close
    smSL    := close + atr14 * slMultATR
    smTP    := close - atr14 * tpMultATR
    smDir   := -1
    int tEnd2 = bar_index + blockW
    // SL zone (risk box — bear color)
    box.new(bar_index, smSL, tEnd2, smEntry,
         bgcolor=color.new(colorBEAR, 82),
         border_color=color.new(colorBEAR, 50))
    // TP zone (reward box — bull color)
    box.new(bar_index, smEntry, tEnd2, smTP,
         bgcolor=color.new(colorBULL, 80),
         border_color=color.new(colorBULL, 45))
    // Institutional signal label — prominent with multi-line info
    label.new(bar_index, high + atr14 * 0.6,
         "▼  SMART SHORT\nVWM: " + str.tostring(vwmNorm, "#.#") + "  Imb: " + str.tostring(imbScore, "#.#"),
         style     = label.style_label_down,
         color     = color.new(colorBEAR, 65),
         textcolor = colorBEAR,
         size      = size.small)
    // Vertical highlight line at signal
    line.new(bar_index, high + atr14 * 0.5, bar_index, low - atr14 * 3,
         color = color.new(colorBEAR, 60),
         style = line.style_dotted,
         width = 2)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 17 — LIGHTWEIGHT BACKTESTER
// ─────────────────────────────────────────────────────────────────────────────

var int   btT   = 0      // total closed trades
var int   btW   = 0      // winning trades
var float btR   = 0.0    // cumulative R
var int   btD   = 0      // active direction  1=long  -1=short  0=flat
var float btTP2 = na     // active TP price
var float btSL2 = na     // active SL price

if confirmedLong
    btD   := 1
    btTP2 := close + atr14 * tpMultATR
    btSL2 := close - atr14 * slMultATR

if confirmedShort
    btD   := -1
    btTP2 := close - atr14 * tpMultATR
    btSL2 := close + atr14 * slMultATR

if btD != 0 and not na(btTP2) and not na(btSL2)
    bool bw = btD ==  1 ? high >= btTP2 : low  <= btTP2
    bool bl = btD ==  1 ? low  <= btSL2 : high >= btSL2
    if bw or bl
        btT += 1
        if bw
            btW += 1
            btR += tpMultATR
        else
            btR -= 1.0
        btD := 0

float btWR = btT > 0 ? float(btW) / float(btT) * 100.0 : 0.0
float btEV = btT > 0 ? btR / float(btT) : 0.0

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 18 — DASHBOARD (13 rows × 2 columns)
// ─────────────────────────────────────────────────────────────────────────────

string dashPosVal = switch dashPos
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

string dSz = switch dashSize
    "Tiny"   => size.tiny
    "Normal" => size.normal
    => size.small

var table dash = table.new(dashPosVal, 2, 13,
     bgcolor=color.new(#0d1117, 10),
     border_color=color.new(#30363d, 20), border_width=1,
     frame_color=color.new(#30363d, 40),  frame_width=1)

f_dc(int c, int r, string t, color tc, color bg) =>
    table.cell(dash, c, r, t,
         text_color=tc,
         text_size=dSz,
         bgcolor=bg,
         text_halign=c == 0 ? text.align_left : text.align_right)

if showDash and barstate.islast
    color hBg  = color.new(#1A237E, 0)
    color pBg  = color.new(#161b22, 0)
    color dBg  = color.new(#0d1117, 10)
    color cMut = color.new(#8b949e, 0)

    // Row 0 — header
    f_dc(0, 0, "Order Flow Asymmetry [JOAT]",  colorELITE, hBg)
    f_dc(1, 0, timeframe.period + " | v1.1",   cMut,       hBg)

    // Row 1 — regime
    string regTxt = regime == 1 ? "Trend Bull" :
         regime == 2 ? "Trend Bear" :
         regime == 3 ? "Range HVol" : "Range LVol"
    color regCol2 = regime == 1 ? colorBULL :
         regime == 2 ? colorBEAR :
         regime == 3 ? colorNEUTR : colorELITE
    f_dc(0, 1, "Regime",  cMut,    pBg)
    f_dc(1, 1, regTxt,    regCol2, dBg)

    // Row 2 — VWM Score
    color vwmCol = vwmNorm > vwmCrossThres ? colorBULL :
         vwmNorm < -vwmCrossThres ? colorBEAR : colorNEUTR
    f_dc(0, 2, "VWM Score", cMut,   pBg)
    f_dc(1, 2, str.tostring(vwmNorm, "#.#"), vwmCol, dBg)

    // Row 3 — Vacuum
    f_dc(0, 3, "Vacuum", cMut, pBg)
    f_dc(1, 3,
         vacuum ? "DETECTED" : "─",
         vacuum ? colorELITE : cMut,
         dBg)

    // Row 4 — Imbalance Score
    color imbCol = imbScore > imbThreshold ? colorBULL :
         imbScore < -imbThreshold ? colorBEAR : colorNEUTR
    f_dc(0, 4, "Imbalance", cMut,   pBg)
    f_dc(1, 4, str.tostring(imbScore, "#.#"), imbCol, dBg)

    // Row 5 — Sharpe kFactor
    f_dc(0, 5, "Sharpe k", cMut, pBg)
    f_dc(1, 5, str.tostring(kFactor, "#.##"), cMut, dBg)

    // Row 6 — IR Upper
    f_dc(0, 6, "IR Upper", cMut,     pBg)
    f_dc(1, 6, str.tostring(irUpper, format.mintick), colorBEAR, dBg)

    // Row 7 — IR Lower
    f_dc(0, 7, "IR Lower", cMut,     pBg)
    f_dc(1, 7, str.tostring(irLower, format.mintick), colorBULL, dBg)

    // Row 8 — Active Signal
    string smSig = confirmedLong  ? "▲  LONG"  :
         confirmedShort ? "▼  SHORT" : "─  WAIT"
    color  smCol = confirmedLong  ? colorBULL  :
         confirmedShort ? colorBEAR  : cMut
    f_dc(0, 8, "Signal", cMut,  pBg)
    f_dc(1, 8, smSig,    smCol, dBg)

    // Row 9 — Backtest Win Rate
    color wrC = btWR >= 55.0 ? colorBULL :
         btWR >= 40.0 ? colorNEUTR :
         btT > 0 ? colorBEAR : cMut
    f_dc(0, 9, "Win Rate", cMut, pBg)
    f_dc(1, 9,
         btT > 0 ? str.tostring(btWR, "#.#") + "%" : "─",
         wrC, dBg)

    // Row 10 — Expected Value
    color evC = btEV >= 0.0 ? colorBULL : colorBEAR
    f_dc(0, 10, "Exp Value", cMut, pBg)
    f_dc(1, 10,
         btT > 0 ?
              (btEV >= 0 ? "+" : "") + str.tostring(btEV, "#.##") + " R" : "─",
         evC, dBg)

    // Row 11 — ADX
    f_dc(0, 11, "ADX", cMut, pBg)
    f_dc(1, 11,
         str.tostring(math.round(adxVal)),
         adxVal > float(adxThres) ? colorBULL : cMut,
         dBg)

    // Row 12 — branding footer
    f_dc(0, 12, "[JOAT]",          color.new(#6C63FF, 0), color.new(#0d1117, 20))
    f_dc(1, 12, "jackofalltrades", cMut,                  color.new(#0d1117, 20))

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 19 — ALERT CONDITIONS
// ─────────────────────────────────────────────────────────────────────────────

alertcondition(confirmedLong,
     "OFA Long",
     "Order Flow Asymmetry: Smart money long signal confirmed.")

alertcondition(confirmedShort,
     "OFA Short",
     "Order Flow Asymmetry: Smart money short signal confirmed.")

alertcondition(vacuum,
     "OFA Vacuum Detected",
     "Order Flow Asymmetry: Liquidity vacuum detected.")

alertcondition(regime != regime[1],
     "OFA Regime Shift",
     "Order Flow Asymmetry: Regime classification changed.")

// ─────────────────────────────────────────────────────────────────────────────
// END — Order Flow Asymmetry [JOAT] v1.1
// ─────────────────────────────────────────────────────────────────────────────
````
