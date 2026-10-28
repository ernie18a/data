# MMM Market Structure & Order Flow @MaxMaserati 3.0

- url: https://www.tradingview.com/script/I2ut4Ljl-MMM-Market-Structure-Order-Flow-MaxMaserati-3-0/
- type: indicator
- pine_id: PUB;b5b84d1a9c0d426f9af0595d7b4a4aaf
- version: 1.0

## Description

MMM Market Structure & Order Flow Suite

The MMM Market Structure & Order Flow Suite is the flagship technical analysis system of the Max Maserati Model (MMM) — a trading philosophy built on the principle that every price movement is the direct result of a battle between passive liquidity and aggressive order flow. Rather than relying on lagging indicators or subjective pattern recognition, the MMM methodology reads the market as a continuous auction, where price is always seeking to find the most efficient level at which both buyers and sellers are willing to transact.
This suite translates that philosophy into a fully mechanical, rule-based charting system. It maps market structure, order flow dynamics, volume imbalances, and liquidity voids across every confirmed candle close — giving traders a clear, objective picture of who is in control of the auction at any given moment and where the market is most likely to move next.

1. NBC & BC Candles (The Auction State)
The foundation of the Max Maserati Model begins with reading the state of the auction through candle closures. Every candle tells a story about whether the market is in balance or whether one side has seized control.
NBC (No Body Close / Fair Pricing): A balanced, two-way auction where buyers and sellers are transacting efficiently and neither side has overwhelmed the other. Both participants are present, liquidity is flowing freely, and the market is printing fair value. These candles represent equilibrium and are displayed in standard neutral colours.
BC (Body Close / Unfair Pricing): Aggressive market orders have overwhelmed passive limit orders, pushing price significantly beyond the prior candle's range and locking out one side of the market entirely. Because one side cannot participate during this aggressive push, the price reached is considered institutionally unfair — and in auction theory, unfair pricing is always a candidate for correction. These candles are highlighted in custom MMM colours to immediately separate aggressive expansion from balanced rotation.
[image]https://www.tradingview.com/x/YflBSeue/[/image]

2. Accelerator Candles (AX)
Accelerator candles are a specific sub-class of BC candles that the MMM methodology treats as high-conviction momentum signals. They are not simply large candles — they must be backed by both exceptional range expansion and a significant delta reading relative to recent historical averages.
The logic is rooted in energy expenditure: when the market burns through an extraordinary amount of liquidity to generate a single move, it tends to exhaust the aggressive side temporarily. Price will often pause at these levels, pull back to partially rebalance the expanded range, or establish a significant structural turning point. The suite flags these candles with AX labels and displays the exact range and delta expansion ratios versus recent averages, so traders can immediately assess the intensity of the move and anticipate what is likely to follow.
[image]https://www.tradingview.com/x/gGf0cP4K/[/image]

3. Structural Breaks (CDL / CDS)
In the Max Maserati Model, not all breaks of structure are created equal. The MMM framework applies a strict body-close rule that filters out the noise of wick-based violations — because in auction theory, a wick simply represents a rejected price exploration, not a committed directional move.
A structural break is only confirmed when a candle's body fully closes beyond a validated Swing High or Swing Low. CDL (Change of Delivery Long) marks a confirmed bullish structural break where aggressive buyers have successfully closed price above a prior swing high. CDS (Change of Delivery Short) marks a confirmed bearish structural break where aggressive sellers have closed price below a prior swing low. Each swing need to have at least a BC candle to be considered as valid. Every break is graded 1 to 3 stars based on the volume behind the breakout candle, giving traders an immediate read on the institutional conviction behind the move.
[image]https://www.tradingview.com/x/aUj4v9KP/[/image]

4. UH / UL (Unbalanced High / Unbalanced Low)
One of the more precise concepts within the MMM methodology is the identification of un-auctioned price levels — specific extremes where the market moved so aggressively in one direction that it never allowed two-way participation at that exact price.
When a candle closes perfectly flat at its extreme — no upper wick on a bearish candle, or no lower wick on a bullish candle — it means the matching engine never had the opportunity to auction price at that level from the opposing side. The suite identifies these as UH (Unbalanced High) and UL (Unbalanced Low), marking them with a $$$ sign and UH/UL text. In auction theory, unfinished business always gets revisited — price carries a high mathematical tendency to return and sweep these specific levels to complete the auction process. Markers delete automatically the moment price touches them, keeping the chart clean and objective.
[image]https://www.tradingview.com/x/Z1V5km3E/[/image]

5. Structural Voids (Gaps)
Where standard analysis refers to these as Fair Value Gaps, the Max Maserati Model explicitly rejects that framing. A gap does not represent fair value — it represents a bypassed auction, a zone where pricing was so aggressive that one side of the market was completely excluded. The suite identifies three distinct types of structural voids and removes them automatically once price returns to fill them:

UDG (Unfair Distribution Gap): The classic 3-candle gap where a middle candle prints a massive range with no overlap between the high of the first candle and the low of the third. Pure, one-sided distribution with no two-way participation across the entire zone.

UOG (Unfair Opening Gap): A true price vacuum where a candle's open is completely detached from the prior candle's close. Typically triggered by news events or major session transitions, these represent total liquidity vacuums that forced the matching engine to skip entire price levels entirely.

ULG (Unfair Liquidity Gap): The most subtle of the three — overlapping wicks suggest some price exploration occurred, but the bodies of adjacent candles are completely detached, revealing that the actual transactional zone between the two candles was paper-thin. Extremely low liquidity in this area makes it a high-probability return target.

6. Volume Bubbles & Delta
Order flow is the engine behind every structural move in the MMM framework, and this module makes that order flow visible at the price level. Using tick-level footprint data where available — or a sophisticated synthetic OHLCV delta calculation as a fallback — the suite measures exact Delta (Buy Volume minus Sell Volume) on every candle and across specific price zones.
Visual Volume Bubbles are projected onto the chart to show net delta positioning inside defined grid ranges, revealing precisely where aggressive buyers or sellers are most concentrated. This allows traders to confirm whether a structural break or gap fill is backed by genuine institutional order flow, or whether it is an unsupported move vulnerable to reversal.
[image]https://www.tradingview.com/x/CXkQmMi2/[/image]

7. Imbalances
Beyond the standard gap structures, the MMM suite performs a deeper scan for intra-candle imbalances — zones where volume has clustered so heavily on one side of a candle that proper two-way price rotation never occurred within that candle's range itself.
When open or close boundaries show extreme one-sided volume without any meaningful rotation back through those levels, the suite registers an active imbalance node. These nodes function as localised, high-sensitivity support and resistance areas that remain active until price naturally rotates back through them to rebalance the order book. They are often the most precise entry and reaction levels on the chart precisely because they represent the market's unfinished internal business.

8. Trade Measurements & Grid Geometry
The final layer of the suite is a dynamic Ruler Geometry system that removes the need for manual measurement tools entirely. Customisable point-based grid zones — defaulting to 40-point and 60-point intervals aligned to the MMM risk framework — are automatically projected forward from the current price level.
This gives traders an instant visual framework to quantify risk parameters, measure objective profit targets, track tick and point progression in real time, and maintain consistent position sizing discipline — all without cluttering the chart with manual drawings. The grid adapts dynamically as price moves, ensuring the projection always reflects the current market context.
[image]https://www.tradingview.com/x/CXkQmMi2/[/image]

Note: This script does not repaint. All lines, gap boxes, wickless markers, and structural labels are calculated exclusively on confirmed candle closes and delete in real-time the moment they are mitigated by live price action. Every signal you see on this chart has already been confirmed by the market.

## Source Code

````pine
//@version=6
indicator("MMM Market Structure & Order Flow Suite @MaxMaserati 3.0","MMM Market Structure @MaxMaserati 3.0" , overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

const color deep_green = #006400
const color deep_red   = #8b0000

type SwingLine
    line         id
    label        lbl
    float        price
    int          t1
    int          bIndex
    bool         active
    box          shadowBox
    bool         isProtected
    float        swingClose
    float        swingMid
    array<line>  breakLines
    array<label> breakLbls

type UnbalNode
    float target_price
    bool  is_bull
    int   creation_bar

type GapBox
    box    b
    line   l
    label  lbl
    float  top
    float  bot
    bool   isBull
    string gType
    bool   isTouched
    bool   stoppedExtending
    color  origBg
    color  origBorder
    color  origLine
    color  origLblText
    int    creationBar

type AxData
    label lbl
    label tri
    float trigger
    bool  is_bull

// ─── Settings: Core System ───
grp_core = "Core Settings"
tfInput        = input.timeframe("D", "Reference Timeframe", group=grp_core)
point_override = input.float(0.0, "Manual Point Override (0 = Auto)", step=0.01, group=grp_core)

// ─── Settings: Auction State ───
grp_cndl = "Auction State (Candles)"
show_candles = input.bool(true, "Enable Auction State Colors", group=grp_cndl)
c_bull_bc    = input.color(#27ffc3, "BuBC (Bullish Unfair)", group=grp_cndl, tooltip="Aggressive buyers (Hammer) violently consumed passive liquidity (Wall).")
c_bear_bc    = input.color(#9c27b0, "BeBC (Bearish Unfair)", group=grp_cndl, tooltip="Aggressive sellers (Hammer) violently consumed passive liquidity (Wall).")
c_nbc        = input.color(color.white, "NBC (Fair Pricing)", group=grp_cndl, tooltip="Balanced, two-way auction where buyers and sellers are synchronized.")

// ─── Settings: Momentum Ignition ───
grp_acc = "Momentum Ignition (Accelerators)"
detect_plus_only    = input.bool(false, "Plus Velocity Only (BuX+/BeX+)", group=grp_acc)
size_factor         = input.float(1.5, "Range Expansion Factor", minval=1.0, step=0.1, group=grp_acc)
ax_must_be_wickless = input.bool(false, "Strict: AX MUST Be Wickless", group=grp_acc)
use_delta_filter    = input.bool(true, "Enable Delta Confirmation", inline="ax1", group=grp_acc)
delta_factor        = input.float(1.5, "Delta Expansion Factor", minval=1.0, step=0.1, inline="ax1", group=grp_acc)
show_bull           = input.bool(true, "Show Bullish AX", inline="ax2", group=grp_acc)
show_bear           = input.bool(true, "Show Bearish AX", inline="ax2", group=grp_acc)
show_triangles      = input.bool(true, "Show Directional Triangles",  inline="ax3", group=grp_acc)
tri_size_str        = input.string("tiny", "Triangle Size", options=["auto","tiny","small","normal","large"], inline="ax3", group=grp_acc)
show_delta_info     = input.bool(true, "Show Delta Text", inline="ax4", group=grp_acc)
show_comparison     = input.bool(true, "Show Expansion Ratio",  inline="ax4", group=grp_acc)
lbl_size_str        = input.string("tiny", "Label Size", options=["tiny","small","normal","large"], group=grp_acc)

// ─── Settings: Market Structure ───
grp_strc = "Market Structure (Swings & Breaks)"
showSwings          = input.bool(true, "Show Swings (SH/SL)",          inline="strc1", group=grp_strc)
showLabelsRight     = input.bool(true, "Project Labels Right",         inline="strc1", group=grp_strc)
showBreaks          = input.bool(true, "Show Structure Breaks",        inline="strc2", group=grp_strc)
showStars           = input.bool(true, "Grade Break Quality",          inline="strc2", group=grp_strc)
showProtectedLevels = input.bool(true, "Show Protected Levels",        inline="strc3", group=grp_strc)
showShadow          = input.bool(true, "Show Protected Shadows",       inline="strc3", group=grp_strc)

// ─── Settings: Un-Auctioned Price ───
grp_wick = "Un-Auctioned Price (Wickless)"
show_uh_ul        = input.bool(true,  "Enable UH/UL Detection", group=grp_wick, tooltip="Candles closing perfectly flat at their extremes leave un-auctioned pricing. Price has a high probability to return and sweep these.")
show_wick_dollars = input.bool(true,  "Show $$$ Sign",          inline="w1", group=grp_wick)
show_wick_text    = input.bool(true,  "Show UH/UL Text",        inline="w1", group=grp_wick)
dots_on_ax_only   = input.bool(false, "Strict: AX Candles Only",group=grp_wick)
uh_col            = input.color(color.red,  "UH Color",         inline="w2", group=grp_wick)
ul_col            = input.color(color.lime, "UL Color",         inline="w2", group=grp_wick)
wick_dot_size     = input.string("tiny", "Marker Size", options=["tiny","small","normal","large"], group=grp_wick)

// ─── Settings: Structural Voids ───
grp_gaps = "Structural Voids (Gaps)"
show_upg        = input.bool(true, "Show UDG (Distribution)", inline="g1", group=grp_gaps, tooltip="Unfair Distribution Gap: Pure, one-sided distribution where a massive range is printed without overlap.")
bull_upg_css    = input.color(color.new(#2157f3, 80), "Bu",   inline="g1", group=grp_gaps)
bear_upg_css    = input.color(color.new(#ff1100, 80), "Be",   inline="g1", group=grp_gaps)
show_og         = input.bool(true, "Show UOG (Opening)",      inline="g2", group=grp_gaps, tooltip="Unfair Opening Gap: Total liquidity vacuum forcing the matching engine to teleport price.")
bull_og_css     = input.color(color.new(#2157f3, 50), "Bu",   inline="g2", group=grp_gaps)
bear_og_css     = input.color(color.new(#ff1100, 50), "Be",   inline="g2", group=grp_gaps)
show_vi         = input.bool(true, "Show ULG (Liquidity)",    inline="g3", group=grp_gaps, tooltip="Unfair Liquidity Gap: Overlapping wicks but detached bodies, indicating extremely thin liquidity.")
bull_vi_css     = input.color(color.new(#2157f3, 0),  "Bu",   inline="g3", group=grp_gaps)
bear_vi_css     = input.color(color.new(#ff1100, 0),  "Be",   inline="g3", group=grp_gaps)
gapExtMode      = input.string("Until First Touch", "Extension Mode", options=["3 Candles (Fixed)", "Until First Touch", "Until Filled"], group=grp_gaps)
hide_filled     = input.bool(true,  "Delete Filled Voids",    inline="g4", group=grp_gaps)
force_grey      = input.bool(false, "Monochrome Voids",       inline="g4", group=grp_gaps)
maxGaps         = input.int(15,     "Max Active Voids",                    group=grp_gaps)
show_gap_labels = input.bool(true,  "Show Void Labels",       inline="g5", group=grp_gaps)
gap_lbl_side    = input.string("Left", "Side", options=["Left", "Right"],  inline="g5", group=grp_gaps)
gap_lbl_col     = input.color(color.white, "Text Color",                   inline="g5", group=grp_gaps)

// ─── Settings: Order Flow ───
grp_of = "Order Flow & Footprint"
use_footprint    = input.bool(true, "Use Real Footprint Delta", group=grp_of)
fp_ticks         = input.int(10, "Ticks per Row", minval=1, inline="of1", group=grp_of)
fp_va            = input.int(70, "Value Area %", minval=1, maxval=100, inline="of1", group=grp_of)
show_bubbles     = input.bool(false, "Show Grid Volume Bubbles", group=grp_of)
buy_col          = input.color(#00FF00,"Positive Bubble", inline="of2", group=grp_of)
sell_col         = input.color(#FF0000,"Negative Bubble", inline="of2", group=grp_of)
vol_threshold    = input.float(1000.0, "Bubble Threshold", minval=1, inline="of3", group=grp_of)
vol_multiplier   = input.float(1.5, "Size Multiplier", minval=0.1, inline="of3", group=grp_of)

// ─── Settings: Risk Projections ───
grp_rul = "Risk Projections & Grid"
zone_1_size       = input.float(40.0, "Zone 1 Size (Pts)", inline="rg1", group=grp_rul)
zone_2_size       = input.float(60.0, "Zone 2 Size (Pts)", inline="rg1", group=grp_rul)
box_offset_input  = input.int(15, "Projection Offset", inline="rg2", group=grp_rul)
box_width_input   = input.int(2, "Projection Width", inline="rg2", group=grp_rul)
show_grid         = input.bool(true, "Show Point Grid", group=grp_rul)
show_grid_lines   = input.bool(false, "Show Internal Grid Lines", group=grp_rul)
grid_line_style   = input.string("Dotted", "Line Style", options=["Solid", "Dotted", "Dashed"], inline="rg3", group=grp_rul)
minor_step        = input.float(10.0, "Minor Step", minval=1.0, inline="rg4", group=grp_rul)
major_step        = input.float(20.0, "Major Step", minval=1.0, inline="rg4", group=grp_rul)
grid_label_style  = input.string("Full (e.g., 5 Pts)", "Label Style", options=["Full (e.g., 5 Pts)", "Numbers Only (e.g., 5)", "Hidden (Lines Only)"], group=grp_rul)
show_main_labels  = input.bool(true, "Show Projection Labels", inline="rg5", group=grp_rul)
show_conn_lines   = input.bool(false, "Show Extension Lines", inline="rg5", group=grp_rul)
global_label_size = input.string("Tiny", "Label Size", options=["Tiny", "Small", "Normal", "Large"], group=grp_rul)
line_color_input  = input.color(color.new(color.gray, 60), "Base Line", inline="rg6", group=grp_rul)
label_color_input = input.color(color.new(color.gray, 10), "Text Color", inline="rg6", group=grp_rul)
zone_color_1      = input.color(color.new(color.gray, 85), "Zone 1 Fill", inline="rg7", group=grp_rul)
zone_color_2      = input.color(color.new(color.black, 85), "Zone 2 Fill", inline="rg7", group=grp_rul)
col_minor_pts     = input.color(color.new(color.gray, 60), "Minor Color", inline="rg8", group=grp_rul)
col_major_pts     = input.color(color.new(color.black, 40), "Major Color", inline="rg8", group=grp_rul)

// ─── Settings: Macro Liquidity ───
grp_htf = "Macro Liquidity (HTF Levels)"
htf_extend_bars = input.int(10, "Line Extension (Bars)", minval=1, group=grp_htf)
htf_label_size  = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large"], group=grp_htf)
color_htf_line  = input.color(color.new(color.black, 0), "Line Color", group=grp_htf)
showATH = input.bool(true, "ATH", inline="h1", group=grp_htf)
showATL = input.bool(true, "ATL", inline="h1", group=grp_htf)
showPDH = input.bool(true, "PDH", inline="h2", group=grp_htf)
showPDL = input.bool(true, "PDL", inline="h2", group=grp_htf)
showDH  = input.bool(true, "DH",  inline="h3", group=grp_htf)
showDL  = input.bool(true, "DL",  inline="h3", group=grp_htf)
showPWH = input.bool(true, "PWH", inline="h4", group=grp_htf)
showPWL = input.bool(true, "PWL", inline="h4", group=grp_htf)
showPMH = input.bool(true, "PMH", inline="h5", group=grp_htf)
showPML = input.bool(true, "PML", inline="h5", group=grp_htf)

// ─── State Tracking ───
var SwingLine[] swingHighs = array.new<SwingLine>()
var SwingLine[] swingLows  = array.new<SwingLine>()
var int   signalState    = 0
var int   trendState     = 0
var float trackHigh      = 0.0
var int   trackHighTime  = 0
var float trackHighClose = 0.0
var float trackHighMid   = 0.0
var float trackLow       = 0.0
var int   trackLowTime   = 0
var float trackLowClose  = 0.0
var float trackLowMid    = 0.0

var color protected_bull = #103c10
var color protected_bear = #ff0000
var color bull_target    = #046319
var color bear_target    = #ae0303

float  SHADOW_HEIGHT      = 0.1
int    shadowTransparency = 85
int    lineWidth          = 1
string structureLabelSize = "tiny"
string lineStyle          = "Solid"
color  lineBullColor      = color.rgb(0, 180, 0)
color  lineBearColor      = color.rgb(200, 0, 0)

var array<UnbalNode> active_unbal = array.new<UnbalNode>()
var array<GapBox>    visual_gaps  = array.new<GapBox>()
var array<AxData>    active_axs   = array.new<AxData>()

var major_sr_lines  = array.new_line()
var major_sr_labels = array.new_label()
var lines_arr       = array.new_line()
var labels_arr      = array.new_label()
var boxes_arr       = array.new_box()

var float global_ath = na
var float global_atl = na

var map<float, float> hist_buy  = map.new<float, float>()
var map<float, float> hist_sell = map.new<float, float>()

// ─── Helpers ───
get_point_multiplier() =>
    string t = syminfo.ticker
    float  m = 1.0
    if syminfo.type == "forex"
        m := syminfo.mintick * 10
    else if str.contains(t, "CL") or str.contains(t, "NG") or str.contains(t, "WTI")
        m := 0.01
    else if str.contains(t, "GC") or str.contains(t, "SI") or str.contains(t, "XAU")
        m := 0.1
    else if syminfo.type == "crypto"
        m := syminfo.mintick * 10
    m

float pt = point_override > 0 ? point_override : get_point_multiplier()
string lbl_sz_str = global_label_size == "Tiny" ? size.tiny : global_label_size == "Small" ? size.small : global_label_size == "Normal" ? size.normal : size.large
string htf_sz_str = htf_label_size == "Tiny" ? size.tiny : htf_label_size == "Small" ? size.small : htf_label_size == "Normal" ? size.normal : size.large

getStyle(s) => s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted
getSizeFromString(s) => s == "small" ? size.small : s == "normal" ? size.normal : s == "large" ? size.large : size.tiny
get_size(s) => s == "auto" ? size.auto : s == "small" ? size.small : s == "normal" ? size.normal : s == "large" ? size.large : size.tiny

formatVolume(float vol) => vol >= 1000000 ? str.tostring(vol / 1000000, "#.##") + "M" : vol >= 1000 ? str.tostring(vol / 1000, "#.##") + "K" : str.tostring(vol, "#")
f_fmt_delta(float d) =>
    float a = math.abs(d)
    string pfx = d >= 0.0 ? "+" : ""
    a >= 1000000.0 ? pfx + str.tostring(math.round(d / 1000000.0, 1)) + "M" : a >= 1000.0 ? pfx + str.tostring(math.round(d / 1000.0, 1)) + "K" : pfx + str.tostring(math.round(d))

getBubbleSize(float vol) => (vol / vol_threshold) >= (2.0 * vol_multiplier) ? size.large : (vol / vol_threshold) >= vol_multiplier ? size.normal : size.small
calculateBreakQuality(float vol, float avgVol) => vol > avgVol * 1.5 ? 3 : vol > avgVol ? 2 : 1
getQualityStars(int score) => str.tostring(score) + "⭐"

deleteSwing(SwingLine s) =>
    if not na(s.id)
        line.delete(s.id)
    if not na(s.lbl)
        label.delete(s.lbl)
    if not na(s.shadowBox)
        box.delete(s.shadowBox)
    if not na(s.breakLines)
        if s.breakLines.size() > 0
            for l in s.breakLines
                line.delete(l)
    if not na(s.breakLbls)
        if s.breakLbls.size() > 0
            for lbl in s.breakLbls
                label.delete(lbl)

f_drawMajorSRLine(bool showLine, float val, string lbl_str, int x_start, int connX, int boxStartX, float minPrice, float maxPrice) =>
    if showLine and not na(val) and val >= minPrice and val <= maxPrice
        int x2 = x_start + htf_extend_bars
        major_sr_lines.push(line.new(x_start, val, x2, val, color=color_htf_line, width=1))
        if show_main_labels
            major_sr_labels.push(label.new(x2, val, lbl_str, textcolor=color_htf_line, style=label.style_label_left, color=color.new(color.white, 100), size=htf_sz_str))
        if show_conn_lines
            major_sr_lines.push(line.new(connX, val, boxStartX, val, color=color_htf_line, width=1))

f_synthetic_delta() =>
    float delta = 0.0
    if volume > 0
        float pm = close - open
        float pr = high - low
        if pr > 0
            float bp = math.abs(pm) / pr
            float uw = high - math.max(open, close)
            float lw = math.min(open, close) - low
            float cp = (close - low) / pr
            if pm > 0
                float br = math.min(0.85, 0.50 + bp * 0.25 + (lw > uw ? 0.10 : 0.0) + (cp > 0.7 ? 0.05 : 0.0))
                delta := volume * (br * 2.0 - 1.0)
            else if pm < 0
                float sr = math.min(0.85, 0.50 + bp * 0.25 + (uw > lw ? 0.10 : 0.0) + (cp < 0.3 ? 0.05 : 0.0))
                delta := volume * -(sr * 2.0 - 1.0)
            else
                delta := uw > lw * 1.5 ? volume * -0.40 : lw > uw * 1.5 ? volume * 0.40 : volume * (cp > 0.5 ? 0.04 : -0.04)
        else
            delta := pm > 0 ? volume * 0.20 : pm < 0 ? volume * -0.20 : 0.0
    delta

// ─── Computed Series ───
timeDelta  = time - time[1]
futureTime = time + (timeDelta * 10)
avgVolume  = ta.sma(volume, 20)
float candle_range = high - low

footprint fp      = use_footprint ? request.footprint(fp_ticks, fp_va) : na 
float fp_delta    = use_footprint and not na(fp) ? fp.delta() : na
bool using_real_fp= use_footprint and not na(fp_delta)
float current_delta = using_real_fp ? fp_delta : f_synthetic_delta()

[pdh_val, pdl_val]  = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_on)
[pwh_val, pwl_val]  = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead=barmerge.lookahead_on)
[pmh_val, pml_val]  = request.security(syminfo.tickerid, "M", [high[1], low[1]], lookahead=barmerge.lookahead_on)
[dh_val,  dl_val]   = request.security(syminfo.tickerid, "D", [high, low])
[htf_high, htf_low] = request.security(syminfo.tickerid, tfInput, [high[1], low[1]], lookahead=barmerge.lookahead_on)

// ─── Logic: Structure & Swings ───
bool curr_BuBC      = close > high[1] or open > high[1]
bool curr_BuBC_Plus = curr_BuBC and close > (high + low) / 2.0
bool curr_BeBC      = close < low[1]  or open < low[1]
bool curr_BeBC_Plus = curr_BeBC and close < (high + low) / 2.0
bool is_any_BC      = curr_BuBC or curr_BeBC

float _tk = syminfo.mintick
bool is_bull_c     = close >= open
bool no_lower_wick = (math.min(open, close) - low) <= _tk
bool raw_ul        = is_bull_c and no_lower_wick and candle_range > _tk

bool is_bear_c     = close <= open
bool no_upper_wick = (high - math.max(open, close)) <= _tk
bool raw_uh        = is_bear_c and no_upper_wick and candle_range > _tk

highlightLastSwing(SwingLine[] swings, string newText, color baseColor, float heightATR) =>
    if swings.size() > 0 and showProtectedLevels
        lastSwing = swings.get(swings.size() - 1)
        lastSwing.id.set_x2(time)
        lastSwing.id.set_color(baseColor)
        if showShadow and na(lastSwing.shadowBox)
            float topPrice = lastSwing.price + (heightATR * SHADOW_HEIGHT)
            float botPrice = lastSwing.price - (heightATR * SHADOW_HEIGHT)
            lastSwing.shadowBox := box.new(lastSwing.t1, topPrice, time, botPrice, xloc=xloc.bar_time, border_width=0, bgcolor=color.new(baseColor, shadowTransparency))
        lastSwing.lbl.set_text(newText)
        lastSwing.lbl.set_textcolor(baseColor)
        lastSwing.lbl.set_tooltip("Protected Level - Break invalidates if touched")
        lastSwing.lbl.set_y(lastSwing.price)
        lastSwing.isProtected := true
        lastSwing.lbl.set_style(newText == "CDS SH" ? label.style_label_down : label.style_label_up)
        lastSwing.lbl.set_x(showLabelsRight ? futureTime : lastSwing.t1)
        swings.set(swings.size() - 1, lastSwing)

updateTargets(int bias) =>
    if swingHighs.size() > 0
        for i = 0 to swingHighs.size() - 1
            s = swingHighs.get(i)
            if not s.isProtected
                s.lbl.set_text(bias == 1 ? "Buyers TGT" : "SH")
                s.lbl.set_textcolor(bias == 1 ? bull_target : lineBearColor)
                s.lbl.set_y(s.price)
                s.lbl.set_style(label.style_label_down)
                s.lbl.set_x(showLabelsRight ? futureTime : s.t1)
    if swingLows.size() > 0
        for i = 0 to swingLows.size() - 1
            s = swingLows.get(i)
            if not s.isProtected
                s.lbl.set_text(bias == -1 ? "Sellers TGT" : "SL")
                s.lbl.set_textcolor(bias == -1 ? bear_target : lineBullColor)
                s.lbl.set_y(s.price)
                s.lbl.set_style(label.style_label_up)
                s.lbl.set_x(showLabelsRight ? futureTime : s.t1)

global_ath := math.max(nz(global_ath, high), high)
global_atl := math.min(nz(global_atl, low),  low)

float tol = _tk * 2
if close > open and (open - low) <= tol
    active_unbal.push(UnbalNode.new(low, true, bar_index))
if close < open and (high - open) <= tol
    active_unbal.push(UnbalNode.new(high, false, bar_index))

if active_unbal.size() > 0
    for i = active_unbal.size() - 1 to 0
        node = active_unbal.get(i)
        if bar_index > node.creation_bar
            if (node.is_bull ? low <= node.target_price : high >= node.target_price)
                active_unbal.remove(i)

if not na(fp) and barstate.isconfirmed
    for r in fp.rows()
        float p = (r.up_price() + r.down_price()) / 2.0
        hist_buy.put(p, (hist_buy.contains(p) ? hist_buy.get(p) : 0.0) + r.buy_volume())
        hist_sell.put(p, (hist_sell.contains(p) ? hist_sell.get(p) : 0.0) + r.sell_volume())

if bar_index == 0
    trackHigh := high, trackHighTime := time, trackHighClose := close, trackHighMid := (high + low) / 2
    trackLow := low, trackLowTime := time, trackLowClose := close, trackLowMid := (high + low) / 2

if barstate.isconfirmed
    float currentAtr = ta.atr(14)
    if trendState == 0
        if high > trackHigh
            trackHigh := high, trackHighTime := time, trackHighClose := close, trackHighMid := (high + low) / 2
        if low < trackLow
            trackLow := low, trackLowTime := time, trackLowClose := close, trackLowMid := (high + low) / 2
    if trendState == 1 and high >= trackHigh
        trackHigh := high, trackHighTime := time, trackHighClose := close, trackHighMid := (high + low) / 2
    if trendState == -1 and low <= trackLow
        trackLow := low, trackLowTime := time, trackLowClose := close, trackLowMid := (high + low) / 2

    if curr_BeBC and (trendState == 1 or trendState == 0) and showSwings
        newLine = line.new(trackHighTime, trackHigh, futureTime, trackHigh, xloc=xloc.bar_time, color=lineBearColor, width=lineWidth, style=getStyle(lineStyle))
        newLbl  = label.new(trackHighTime, trackHigh, signalState == 1 ? "Buyers TGT" : "SH", xloc=xloc.bar_time, color=color(na), textcolor=signalState == 1 ? bull_target : lineBearColor, style=label.style_label_down, size=getSizeFromString(structureLabelSize))
        if showLabelsRight
            newLbl.set_x(futureTime)
        swingHighs.push(SwingLine.new(newLine, newLbl, trackHigh, trackHighTime, bar_index, true, na, false, trackHighClose, trackHighMid, array.new<line>(), array.new<label>()))
        trendState := -1
        trackLow := low, trackLowTime := time, trackLowClose := close, trackLowMid := (high + low) / 2

    else if curr_BuBC and (trendState == -1 or trendState == 0) and showSwings
        newLine = line.new(trackLowTime, trackLow, futureTime, trackLow, xloc=xloc.bar_time, color=lineBullColor, width=lineWidth, style=getStyle(lineStyle))
        newLbl  = label.new(trackLowTime, trackLow, signalState == -1 ? "Sellers TGT" : "SL", xloc=xloc.bar_time, color=color(na), textcolor=signalState == -1 ? bear_target : lineBullColor, style=label.style_label_up, size=getSizeFromString(structureLabelSize))
        if showLabelsRight
            newLbl.set_x(futureTime)
        swingLows.push(SwingLine.new(newLine, newLbl, trackLow, trackLowTime, bar_index, true, na, false, trackLowClose, trackLowMid, array.new<line>(), array.new<label>()))
        trendState := 1
        trackHigh := high, trackHighTime := time, trackHighClose := close, trackHighMid := (high + low) / 2

    if swingLows.size() > 0 and showBreaks
        for i = swingLows.size() - 1 to 0
            s = swingLows.get(i)
            if low <= s.price
                if close < s.price and signalState != -1
                    if swingHighs.size() > 0
                        breakQuality = calculateBreakQuality(volume, avgVolume)
                        labelText    = showStars ? "CDS " + getQualityStars(breakQuality) : "CDS"
                        newCDSLine   = line.new(s.t1, s.price, time, s.price, xloc=xloc.bar_time, color=lineBearColor, width=lineWidth, style=getStyle(lineStyle))
                        newCDSLbl    = label.new(int(math.avg(s.t1, time)), s.price, labelText, xloc=xloc.bar_time, color=color(na), textcolor=lineBearColor, style=label.style_label_up, size=getSizeFromString(structureLabelSize))
                        highlightLastSwing(swingHighs, "CDS SH", protected_bear, currentAtr)
                        protSwing = swingHighs.get(swingHighs.size() - 1)
                        protSwing.breakLines.push(newCDSLine)
                        protSwing.breakLbls.push(newCDSLbl)
                        swingHighs.set(swingHighs.size() - 1, protSwing)
                        signalState := -1
                        updateTargets(-1)
                deleteSwing(s)
                swingLows.remove(i)
            else
                if s.isProtected
                    if not na(s.shadowBox)
                        s.shadowBox.set_right(futureTime)
                else
                    s.id.set_x2(futureTime)
                    if not na(s.shadowBox)
                        s.shadowBox.set_right(futureTime)
                    if showLabelsRight
                        s.lbl.set_x(futureTime)

    if swingHighs.size() > 0 and showBreaks
        for i = swingHighs.size() - 1 to 0
            s = swingHighs.get(i)
            if high >= s.price
                if close > s.price and signalState != 1
                    if swingLows.size() > 0
                        breakQuality = calculateBreakQuality(volume, avgVolume)
                        labelText    = showStars ? "CDL " + getQualityStars(breakQuality) : "CDL"
                        newCDLLine   = line.new(s.t1, s.price, time, s.price, xloc=xloc.bar_time, color=lineBullColor, width=lineWidth, style=getStyle(lineStyle))
                        newCDLLbl    = label.new(int(math.avg(s.t1, time)), s.price, labelText, xloc=xloc.bar_time, color=color(na), textcolor=lineBullColor, style=label.style_label_down, size=getSizeFromString(structureLabelSize))
                        highlightLastSwing(swingLows, "CDL SL", protected_bull, currentAtr)
                        protSwing = swingLows.get(swingLows.size() - 1)
                        protSwing.breakLines.push(newCDLLine)
                        protSwing.breakLbls.push(newCDLLbl)
                        swingLows.set(swingLows.size() - 1, protSwing)
                        signalState := 1
                        updateTargets(1)
                deleteSwing(s)
                swingHighs.remove(i)
            else
                if s.isProtected
                    if not na(s.shadowBox)
                        s.shadowBox.set_right(futureTime)
                else
                    s.id.set_x2(futureTime)
                    if not na(s.shadowBox)
                        s.shadowBox.set_right(futureTime)
                    if showLabelsRight
                        s.lbl.set_x(futureTime)

    // ─── Gap Detection ───
    float bull_gap_top = math.min(close, open), float bull_gap_bot = math.max(close[1], open[1])
    float bear_gap_top = math.min(close[1], open[1]), float bear_gap_bot = math.max(close, open)
    bool  fixedStop = gapExtMode == "3 Candles (Fixed)"
    int   upg_right = fixedStop ? bar_index + 2 : bar_index + 1
    int   lbl_x     = gap_lbl_side == "Right" ? upg_right : bar_index - 1
    color grey_box  = color.new(#636363, 80), color grey_line = color.new(#636363, 0)
    color act_bull_vi = force_grey ? grey_line : bull_vi_css, color act_bear_vi = force_grey ? grey_line : bear_vi_css
    color act_bull_og = force_grey ? grey_box : bull_og_css,  color act_bear_og = force_grey ? grey_box : bear_og_css
    color act_bull_upg= force_grey ? grey_box : bull_upg_css, color act_bear_upg= force_grey ? grey_box : bear_upg_css

    if show_vi
        if open > close[1] and high[1] > low and close > close[1] and open > open[1] and high[1] < bull_gap_top
            float mid = math.avg(bull_gap_top, bull_gap_bot)
            bx  = box.new(bar_index-1, bull_gap_top, upg_right, bull_gap_bot, border_color=act_bull_vi, bgcolor=na, border_style=line.style_dotted)
            ln  = line.new(bar_index-1, mid, upg_right, mid, color=color.new(act_bull_vi, 0), style=line.style_dotted)
            lbl = show_gap_labels ? label.new(lbl_x, mid, "ULG+", color=color.new(color.white, 100), textcolor=gap_lbl_col, style=label.style_none, size=size.tiny) : na
            visual_gaps.push(GapBox.new(bx, ln, lbl, bull_gap_top, bull_gap_bot, true, "ULG", false, fixedStop, na, act_bull_vi, color.new(act_bull_vi, 0), gap_lbl_col, bar_index))
        if open < close[1] and low[1] < high and close < close[1] and open < open[1] and low[1] > bear_gap_bot
            float mid = math.avg(bear_gap_top, bear_gap_bot)
            bx  = box.new(bar_index-1, bear_gap_top, upg_right, bear_gap_bot, border_color=act_bear_vi, bgcolor=na, border_style=line.style_dotted)
            ln  = line.new(bar_index-1, mid, upg_right, mid, color=color.new(act_bear_vi, 0), style=line.style_dotted)
            lbl = show_gap_labels ? label.new(lbl_x, mid, "ULG-", color=color.new(color.white, 100), textcolor=gap_lbl_col, style=label.style_none, size=size.tiny) : na
            visual_gaps.push(GapBox.new(bx, ln, lbl, bear_gap_top, bear_gap_bot, false, "ULG", false, fixedStop, na, act_bear_vi, color.new(act_bear_vi, 0), gap_lbl_col, bar_index))

    if show_og
        if low > high[1]
            float mid = math.avg(low, high[1])
            bx  = box.new(bar_index-1, low, upg_right, high[1], border_color=na, bgcolor=act_bull_og)
            ln  = line.new(bar_index-1, mid, upg_right, mid, color=force_grey ? grey_line : color.new(bull_og_css, 0))
            lbl = show_gap_labels ? label.new(lbl_x, mid, "UOG+", color=color.new(color.white, 100), textcolor=gap_lbl_col, style=label.style_none, size=size.tiny) : na
            visual_gaps.push(GapBox.new(bx, ln, lbl, low, high[1], true, "UOG", false, fixedStop, act_bull_og, na, force_grey ? grey_line : color.new(bull_og_css, 0), gap_lbl_col, bar_index))
        if high < low[1]
            float mid = math.avg(low[1], high)
            bx  = box.new(bar_index-1, low[1], upg_right, high, border_color=na, bgcolor=act_bear_og)
            ln  = line.new(bar_index-1, mid, upg_right, mid, color=force_grey ? grey_line : color.new(bear_og_css, 0))
            lbl = show_gap_labels ? label.new(lbl_x, mid, "UOG-", color=color.new(color.white, 100), textcolor=gap_lbl_col, style=label.style_none, size=size.tiny) : na
            visual_gaps.push(GapBox.new(bx, ln, lbl, low[1], high, false, "UOG", false, fixedStop, act_bear_og, na, force_grey ? grey_line : color.new(bear_og_css, 0), gap_lbl_col, bar_index))

    if show_upg
        if low > high[2] and close[1] > high[2] and not (low > high[1] or low[1] > high[2])
            float mid = math.avg(low, high[2])
            bx  = box.new(bar_index-2, low, upg_right, high[2], border_color=na, bgcolor=act_bull_upg)
            ln  = line.new(bar_index-2, mid, upg_right, mid, color=force_grey ? grey_line : color.new(bull_upg_css, 0))
            lbl = show_gap_labels ? label.new(lbl_x, mid, "UDG+", color=color.new(color.white, 100), textcolor=gap_lbl_col, style=label.style_none, size=size.tiny) : na
            visual_gaps.push(GapBox.new(bx, ln, lbl, low, high[2], true, "UDG", false, fixedStop, act_bull_upg, na, force_grey ? grey_line : color.new(bull_upg_css, 0), gap_lbl_col, bar_index))
        if high < low[2] and close[1] < low[2] and not (high < low[1] or high[1] < low[2])
            float mid = math.avg(low[2], high)
            bx  = box.new(bar_index-2, low[2], upg_right, high, border_color=na, bgcolor=act_bear_upg)
            ln  = line.new(bar_index-2, mid, upg_right, mid, color=force_grey ? grey_line : color.new(bear_upg_css, 0))
            lbl = show_gap_labels ? label.new(lbl_x, mid, "UDG-", color=color.new(color.white, 100), textcolor=gap_lbl_col, style=label.style_none, size=size.tiny) : na
            visual_gaps.push(GapBox.new(bx, ln, lbl, low[2], high, false, "UDG", false, fixedStop, act_bear_upg, na, force_grey ? grey_line : color.new(bear_upg_css, 0), gap_lbl_col, bar_index))

    if visual_gaps.size() > 0
        for i = visual_gaps.size() - 1 to 0
            u = visual_gaps.get(i)
            bool isFilled = false
            bool newlyTouched = false
            if bar_index > u.creationBar
                if u.isBull
                    if low <= u.top and not u.isTouched
                        u.isTouched := true, newlyTouched := true
                    if low <= u.bot
                        isFilled := true
                else
                    if high >= u.bot and not u.isTouched
                        u.isTouched := true, newlyTouched := true
                    if high >= u.top
                        isFilled := true
            if newlyTouched
                if u.gType == "ULG"
                    u.b.set_border_color(color.new(u.origBorder, 80))
                else
                    u.b.set_bgcolor(color.new(u.origBg, 85))
                if not na(u.l)
                    u.l.set_color(color.new(u.origLine, 80))
                if not na(u.lbl)
                    u.lbl.set_textcolor(color.new(u.origLblText, 70))
                if gapExtMode == "Until First Touch"
                    u.stoppedExtending := true
            if hide_filled and isFilled
                u.b.delete(), u.lbl.delete(), u.l.delete()
                visual_gaps.remove(i)
            else if not u.stoppedExtending
                u.b.set_right(bar_index + 1)
                if not na(u.l)
                    u.l.set_x2(bar_index + 1)
                if not na(u.lbl) and gap_lbl_side == "Right"
                    u.lbl.set_x(bar_index + 1)

    while visual_gaps.size() > maxGaps
        if visual_gaps.size() > 0
            u = visual_gaps.get(0)
            u.b.delete(), u.lbl.delete(), u.l.delete()
            visual_gaps.remove(0)
        else
            break

// ─── Logic: Accelerator ───
var float bc_range_1 = 0.0, var float bc_range_2 = 0.0
var float bc_delta_1 = 0.0, var float bc_delta_2 = 0.0

float avg_bc_range = (bc_range_1 + bc_range_2) / 2.0
float avg_bc_delta = (math.abs(bc_delta_1) + math.abs(bc_delta_2)) / 2.0

var bool bull_accel = false, var bool bear_accel = false
var bool is_plus = false
var float range_ratio = 0.0, var float delta_ratio = 0.0

bull_accel := false, bear_accel := false, is_plus := false
range_ratio := 0.0, delta_ratio := 0.0

if curr_BuBC and avg_bc_range > 0
    if not detect_plus_only or curr_BuBC_Plus
        float rr = candle_range / avg_bc_range
        bool rng_ok = candle_range >= avg_bc_range * size_factor
        bool dlt_ok = false
        float dr = 0.0
        if use_delta_filter and avg_bc_delta > 0
            dr := math.abs(current_delta) / avg_bc_delta
            dlt_ok := current_delta > 0.0 and dr >= delta_factor
        else if use_delta_filter
            dlt_ok := current_delta > 0.0
        else
            dlt_ok := current_delta >= 0.0
            dr := avg_bc_delta > 0.0 ? math.abs(current_delta) / avg_bc_delta : 0.0
        if rng_ok and dlt_ok
            if not ax_must_be_wickless or raw_ul
                bull_accel := true, is_plus := curr_BuBC_Plus, range_ratio := rr, delta_ratio := dr

if curr_BeBC and avg_bc_range > 0
    if not detect_plus_only or curr_BeBC_Plus
        float rr = candle_range / avg_bc_range
        bool rng_ok = candle_range >= avg_bc_range * size_factor
        bool dlt_ok = false
        float dr = 0.0
        if use_delta_filter and avg_bc_delta > 0
            dr := math.abs(current_delta) / avg_bc_delta
            dlt_ok := current_delta < 0.0 and dr >= delta_factor
        else if use_delta_filter
            dlt_ok := current_delta < 0.0
        else
            dlt_ok := current_delta <= 0.0
            dr := avg_bc_delta > 0.0 ? math.abs(current_delta) / avg_bc_delta : 0.0
        if rng_ok and dlt_ok
            if not ax_must_be_wickless or raw_uh
                bear_accel := true, is_plus := curr_BeBC_Plus, range_ratio := rr, delta_ratio := dr

if barstate.isconfirmed and is_any_BC
    bc_range_2 := bc_range_1, bc_range_1 := candle_range
    bc_delta_2 := bc_delta_1, bc_delta_1 := current_delta

// ─── Drawing: Auction State Colors ───
color final_candle_col = na
if show_candles
    if curr_BuBC and not curr_BeBC
        final_candle_col := c_bull_bc
    else if curr_BeBC and not curr_BuBC
        final_candle_col := c_bear_bc
    else if curr_BuBC and curr_BeBC
        final_candle_col := close >= open ? c_bull_bc : c_bear_bc
    else
        final_candle_col := c_nbc

if bull_accel and show_bull
    final_candle_col := deep_green
else if bear_accel and show_bear
    final_candle_col := deep_red

barcolor(final_candle_col)

// ─── Drawing: Un-Auctioned Price (UH/UL) ───
bool is_ax_candle = bull_accel or bear_accel
bool fire_ul = show_uh_ul and raw_ul and (dots_on_ax_only ? is_ax_candle : true)
bool fire_uh = show_uh_ul and raw_uh and (dots_on_ax_only ? is_ax_candle : true)

var label[] uh_dots   = array.new<label>()
var label[] uh_texts  = array.new<label>()
var float[] uh_prices = array.new<float>()

var label[] ul_dots   = array.new<label>()
var label[] ul_texts  = array.new<label>()
var float[] ul_prices = array.new<float>()

int UH_UL_MAX = 50

if uh_prices.size() > 0
    for i = uh_prices.size() - 1 to 0
        if high >= uh_prices.get(i)
            label.delete(uh_dots.get(i)), label.delete(uh_texts.get(i))
            uh_dots.remove(i), uh_texts.remove(i), uh_prices.remove(i)

if ul_prices.size() > 0
    for i = ul_prices.size() - 1 to 0
        if low <= ul_prices.get(i)
            label.delete(ul_dots.get(i)), label.delete(ul_texts.get(i))
            ul_dots.remove(i), ul_texts.remove(i), ul_prices.remove(i)

if fire_uh
    if uh_prices.size() >= UH_UL_MAX
        label.delete(uh_dots.shift()), label.delete(uh_texts.shift()), uh_prices.shift()
    label _ud = show_wick_dollars ? label.new(bar_index, high, "$$$", style=label.style_none, textcolor=uh_col, size=get_size(wick_dot_size)) : na
    label _ut = show_wick_text ? label.new(bar_index, high, "UH", style=label.style_label_down, color=color.new(color.white, 100), textcolor=uh_col, size=get_size(wick_dot_size)) : na
    uh_dots.push(_ud), uh_texts.push(_ut), uh_prices.push(high)

if fire_ul
    if ul_prices.size() >= UH_UL_MAX
        label.delete(ul_dots.shift()), label.delete(ul_texts.shift()), ul_prices.shift()
    label _ld = show_wick_dollars ? label.new(bar_index, low, "$$$", style=label.style_none, textcolor=ul_col, size=get_size(wick_dot_size)) : na
    label _lt = show_wick_text ? label.new(bar_index, low, "UL", style=label.style_label_up, color=color.new(color.white, 100), textcolor=ul_col, size=get_size(wick_dot_size)) : na
    ul_dots.push(_ld), ul_texts.push(_lt), ul_prices.push(low)

// ─── Drawing: Accelerator Labels ───
if active_axs.size() > 0
    for i = active_axs.size() - 1 to 0
        ax = active_axs.get(i)
        bool del = false
        if ax.is_bull and low <= ax.trigger
            del := true
        else if not ax.is_bull and high >= ax.trigger
            del := true
            
        if del
            label.delete(ax.lbl)
            label.delete(ax.tri)
            active_axs.remove(i)

if bull_accel and show_bull
    label tri = show_triangles ? label.new(bar_index, low, "", yloc=yloc.belowbar, style=label.style_triangleup, color=deep_green, size=get_size(tri_size_str)) : na
    string vel = is_plus ? "+" : "-"
    string ltxt = "BuAx" + vel
    if show_delta_info
        ltxt := ltxt + "\nD:" + f_fmt_delta(current_delta)
    if show_comparison
        ltxt := ltxt + "\nR:" + str.tostring(math.round(range_ratio, 2)) + "x"
        if use_delta_filter
            ltxt := ltxt + " D:" + str.tostring(math.round(delta_ratio, 2)) + "x"
    string tt = "Bullish Accelerator | BuAx" + vel + "\nVelocity: " + (is_plus ? "Plus (close > mid)" : "Minus (close <= mid)") + "\nDelta Source: " + (using_real_fp ? "FOOTPRINT" : "SYNTHETIC") + "\nRange: " + str.tostring(math.round(candle_range, 2)) + " | Avg: " + str.tostring(math.round(avg_bc_range, 2)) + " | Ratio: " + str.tostring(math.round(range_ratio, 2)) + "x | Need: " + str.tostring(size_factor) + "x\nDelta: " + f_fmt_delta(current_delta) + " | Avg: " + f_fmt_delta(avg_bc_delta) + " | Ratio: " + str.tostring(math.round(delta_ratio, 2)) + "x | Need: " + str.tostring(delta_factor) + "x\nVolume: " + str.tostring(volume)
    label lbl = label.new(bar_index, low, ltxt, yloc=yloc.belowbar, style=label.style_label_up, color=color.new(color.white, 100), textcolor=deep_green, size=get_size(lbl_size_str), tooltip=tt)
    active_axs.push(AxData.new(lbl, tri, low, true))

if bear_accel and show_bear
    label tri = show_triangles ? label.new(bar_index, high, "", yloc=yloc.abovebar, style=label.style_triangledown, color=deep_red, size=get_size(tri_size_str)) : na
    string vel = is_plus ? "+" : "-"
    string ltxt = "BeAx" + vel
    if show_delta_info
        ltxt := ltxt + "\nD:" + f_fmt_delta(current_delta)
    if show_comparison
        ltxt := ltxt + "\nR:" + str.tostring(math.round(range_ratio, 2)) + "x"
        if use_delta_filter
            ltxt := ltxt + " D:" + str.tostring(math.round(delta_ratio, 2)) + "x"
    string tt = "Bearish Accelerator | BeAx" + vel + "\nVelocity: " + (is_plus ? "Plus (close < mid)" : "Minus (close >= mid)") + "\nDelta Source: " + (using_real_fp ? "FOOTPRINT" : "SYNTHETIC") + "\nRange: " + str.tostring(math.round(candle_range, 2)) + " | Avg: " + str.tostring(math.round(avg_bc_range, 2)) + " | Ratio: " + str.tostring(math.round(range_ratio, 2)) + "x | Need: " + str.tostring(size_factor) + "x\nDelta: " + f_fmt_delta(current_delta) + " | Avg: " + f_fmt_delta(avg_bc_delta) + " | Ratio: " + str.tostring(math.round(delta_ratio, 2)) + "x | Need: " + str.tostring(delta_factor) + "x\nVolume: " + str.tostring(volume)
    label lbl = label.new(bar_index, high, ltxt, yloc=yloc.abovebar, style=label.style_label_down, color=color.new(color.white, 100), textcolor=deep_red, size=get_size(lbl_size_str), tooltip=tt)
    active_axs.push(AxData.new(lbl, tri, high, false))

// ─── Drawing: Trade Measurement & Grid ───
if barstate.islast
    while lines_arr.size() > 0
        line.delete(lines_arr.pop())
    while labels_arr.size() > 0
        label.delete(labels_arr.pop())
    while boxes_arr.size() > 0
        box.delete(boxes_arr.pop())
    while major_sr_lines.size() > 0
        line.delete(major_sr_lines.pop())
    while major_sr_labels.size() > 0
        label.delete(major_sr_labels.pop())

    var map<float, float> live_buy  = map.new<float, float>()
    var map<float, float> live_sell = map.new<float, float>()
    live_buy.clear(), live_sell.clear()

    array<float> h_keys = hist_buy.keys()
    if h_keys.size() > 0
        for k in h_keys
            live_buy.put(k, hist_buy.get(k)), live_sell.put(k, hist_sell.get(k))

    if not barstate.isconfirmed and not na(fp)
        for r in fp.rows()
            float p = (r.up_price() + r.down_price()) / 2.0
            live_buy.put(p, (live_buy.contains(p) ? live_buy.get(p) : 0.0) + r.buy_volume())
            live_sell.put(p, (live_sell.contains(p) ? live_sell.get(p) : 0.0) + r.sell_volume())

    if not na(htf_high) and not na(htf_low)
        float cycle_length = zone_1_size + zone_2_size
        float effective_low = math.min(htf_low, low)
        float effective_high = math.max(htf_high, high)
        float startPrice = math.floor(effective_low / (cycle_length * pt)) * (cycle_length * pt) - (cycle_length * pt)
        int bandsToCheck = math.ceil((effective_high - startPrice) / (cycle_length * pt)) + 1
        float maxRulerPrice = startPrice + (bandsToCheck * cycle_length * pt)

        int startX_box = bar_index + box_offset_input
        int endX_box = startX_box + box_width_input
        int startX_ruler = endX_box
        int endX_ruler = startX_ruler + box_width_input
        int lbl_510_X = startX_box - 1
        int connX = bar_index - 3
        int box_center_X = math.round((startX_box + endX_box) / 2)
        int text_center_X = math.round((startX_ruler + endX_ruler) / 2)

        array<float> all_live_prices = live_buy.keys()
        var map<float, string> htf_map = map.new<float, string>()
        htf_map.clear()

        if showDH and not na(dh_val)
            htf_map.put(dh_val, "DH")
        if showDL and not na(dl_val)
            htf_map.put(dl_val, htf_map.contains(dl_val) ? htf_map.get(dl_val) + "-DL" : "DL")
        if showPDH and not na(pdh_val)
            htf_map.put(pdh_val, htf_map.contains(pdh_val) ? htf_map.get(pdh_val) + "-PDH" : "PDH")
        if showPDL and not na(pdl_val)
            htf_map.put(pdl_val, htf_map.contains(pdl_val) ? htf_map.get(pdl_val) + "-PDL" : "PDL")
        if showPWH and not na(pwh_val)
            htf_map.put(pwh_val, htf_map.contains(pwh_val) ? htf_map.get(pwh_val) + "-W" : "PWH")
        if showPWL and not na(pwl_val)
            htf_map.put(pwl_val, htf_map.contains(pwl_val) ? htf_map.get(pwl_val) + "-W" : "PWL")
        if showPMH and not na(pmh_val)
            htf_map.put(pmh_val, htf_map.contains(pmh_val) ? htf_map.get(pmh_val) + "-M" : "PMH")
        if showPML and not na(pml_val)
            htf_map.put(pml_val, htf_map.contains(pml_val) ? htf_map.get(pml_val) + "-M" : "PML")
        if showATH and not na(global_ath)
            htf_map.put(global_ath, htf_map.contains(global_ath) ? htf_map.get(global_ath) + "-ATH" : "ATH")
        if showATL and not na(global_atl)
            htf_map.put(global_atl, htf_map.contains(global_atl) ? htf_map.get(global_atl) + "-ATL" : "ATL")

        array<float> htf_keys = htf_map.keys()
        if htf_keys.size() > 0
            for val in htf_keys
                f_drawMajorSRLine(true, val, htf_map.get(val), endX_box, connX, startX_box, startPrice, maxRulerPrice)

        string sel_style = grid_line_style == "Solid" ? line.style_solid : grid_line_style == "Dashed" ? line.style_dashed : line.style_dotted

        for i = 0 to bandsToCheck
            float currentBase = startPrice + (i * cycle_length * pt)
            float level_1 = currentBase + (zone_1_size * pt)
            float level_2 = currentBase + (cycle_length * pt)

            lines_arr.push(line.new(startX_ruler, currentBase, endX_ruler, currentBase, color=line_color_input, width=1))
            if show_main_labels
                labels_arr.push(label.new(endX_ruler, currentBase, str.tostring(currentBase, format.mintick), textcolor=label_color_input, style=label.style_label_left, color=color.new(color.white, 100), size=lbl_sz_str))
            if show_conn_lines
                lines_arr.push(line.new(connX, currentBase, startX_box, currentBase, color=line_color_input, style=line.style_dashed))

            lines_arr.push(line.new(startX_ruler, level_1, endX_ruler, level_1, color=line_color_input, width=1))
            if show_main_labels
                labels_arr.push(label.new(endX_ruler, level_1, str.tostring(level_1, format.mintick), textcolor=label_color_input, style=label.style_label_left, color=color.new(color.white, 100), size=lbl_sz_str))
            if show_conn_lines
                lines_arr.push(line.new(connX, level_1, startX_box, level_1, color=line_color_input, style=line.style_dashed))

            if i == bandsToCheck
                lines_arr.push(line.new(startX_ruler, level_2, endX_ruler, level_2, color=line_color_input, width=1))
                if show_main_labels
                    labels_arr.push(label.new(endX_ruler, level_2, str.tostring(level_2, format.mintick), textcolor=label_color_input, style=label.style_label_left, color=color.new(color.white, 100), size=lbl_sz_str))
                if show_conn_lines
                    lines_arr.push(line.new(connX, level_2, startX_box, level_2, color=line_color_input, style=line.style_dashed))

            boxes_arr.push(box.new(startX_box, level_1, endX_box, currentBase, bgcolor=zone_color_1, border_color=na))
            labels_arr.push(label.new(text_center_X, math.avg(currentBase, level_1), str.tostring(zone_1_size) + " Pts", textcolor=line_color_input, style=label.style_none, size=size.small))
            boxes_arr.push(box.new(startX_box, level_2, endX_box, level_1, bgcolor=zone_color_2, border_color=na))
            labels_arr.push(label.new(text_center_X, math.avg(level_1, level_2), str.tostring(zone_2_size) + " Pts", textcolor=line_color_input, style=label.style_none, size=size.small))

            if show_grid
                string minor_lbl = grid_label_style == "Full (e.g., 5 Pts)" ? "• " + str.tostring(minor_step, "#.##") + " Pts" : "• " + str.tostring(minor_step, "#.##")
                string major_lbl = grid_label_style == "Full (e.g., 5 Pts)" ? "• " + str.tostring(major_step, "#.##") + " Pts" : "• " + str.tostring(major_step, "#.##")

                float z1_minor = level_1
                while z1_minor > currentBase
                    z1_minor -= minor_step * pt
                    if z1_minor > currentBase
                        if show_grid_lines
                            lines_arr.push(line.new(startX_box, z1_minor, endX_box, z1_minor, color=col_minor_pts, width=1, style=sel_style))
                        if grid_label_style != "Hidden (Lines Only)"
                            labels_arr.push(label.new(lbl_510_X, z1_minor, minor_lbl, textcolor=col_minor_pts, style=label.style_label_right, color=color.new(color.white, 100), size=lbl_sz_str))

                float z1_major = level_1
                while z1_major > currentBase
                    z1_major -= major_step * pt
                    if z1_major > currentBase
                        if show_grid_lines
                            lines_arr.push(line.new(startX_box, z1_major, endX_box, z1_major, color=col_major_pts, width=2, style=sel_style))
                        if grid_label_style != "Hidden (Lines Only)"
                            labels_arr.push(label.new(lbl_510_X, z1_major, major_lbl, textcolor=col_major_pts, style=label.style_label_right, color=color.new(color.white, 100), size=lbl_sz_str))

                float z2_minor = level_2
                while z2_minor > level_1
                    z2_minor -= minor_step * pt
                    if z2_minor > level_1
                        if show_grid_lines
                            lines_arr.push(line.new(startX_box, z2_minor, endX_box, z2_minor, color=col_minor_pts, width=1, style=sel_style))
                        if grid_label_style != "Hidden (Lines Only)"
                            labels_arr.push(label.new(lbl_510_X, z2_minor, minor_lbl, textcolor=col_minor_pts, style=label.style_label_right, color=color.new(color.white, 100), size=lbl_sz_str))

                float z2_major = level_2
                while z2_major > level_1
                    z2_major -= major_step * pt
                    if z2_major > level_1
                        if show_grid_lines
                            lines_arr.push(line.new(startX_box, z2_major, endX_box, z2_major, color=col_major_pts, width=2, style=sel_style))
                        if grid_label_style != "Hidden (Lines Only)"
                            labels_arr.push(label.new(lbl_510_X, z2_major, major_lbl, textcolor=col_major_pts, style=label.style_label_right, color=color.new(color.white, 100), size=lbl_sz_str))

            if show_bubbles
                float z1_buy_total = 0.0, float z1_sell_total = 0.0
                float z1_maxB_v = 0.0, float z1_maxB_p = na
                float z1_maxS_v = 0.0, float z1_maxS_p = na
                if all_live_prices.size() > 0
                    for p in all_live_prices
                        if p >= currentBase and p < level_1
                            float bv = live_buy.contains(p) ? live_buy.get(p) : 0.0
                            float sv = live_sell.contains(p) ? live_sell.get(p) : 0.0
                            z1_buy_total += bv, z1_sell_total += sv
                            if bv > z1_maxB_v
                                z1_maxB_v := bv, z1_maxB_p := p
                            if sv > z1_maxS_v
                                z1_maxS_v := sv, z1_maxS_p := p
                float z1_delta = z1_buy_total - z1_sell_total
                if math.abs(z1_delta) > 0
                    color z1_col = z1_delta >= 0 ? buy_col : sell_col
                    float target_p = z1_delta >= 0 ? z1_maxB_p : z1_maxS_p
                    if na(target_p)
                        target_p := math.avg(currentBase, level_1)
                    string z1_txt = "●\nΔ " + (z1_delta > 0 ? "+" : "") + formatVolume(z1_delta)
                    string z1_tt = "Zone 1 Total Volume\nTotal Buy: " + formatVolume(z1_buy_total) + "\nTotal Sell: " + formatVolume(z1_sell_total) + "\nNet Delta: " + formatVolume(z1_delta) + "\nAnchored at Max " + (z1_delta >= 0 ? "Bull" : "Bear") + " Node"
                    labels_arr.push(label.new(box_center_X, target_p, z1_txt, textcolor=z1_col, style=label.style_none, size=getBubbleSize(math.abs(z1_delta)), tooltip=z1_tt))

            if show_bubbles
                float z2_buy_total = 0.0, float z2_sell_total = 0.0
                float z2_maxB_v = 0.0, float z2_maxB_p = na
                float z2_maxS_v = 0.0, float z2_maxS_p = na
                if all_live_prices.size() > 0
                    for p in all_live_prices
                        if p >= level_1 and p < level_2
                            float bv = live_buy.contains(p) ? live_buy.get(p) : 0.0
                            float sv = live_sell.contains(p) ? live_sell.get(p) : 0.0
                            z2_buy_total += bv, z2_sell_total += sv
                            if bv > z2_maxB_v
                                z2_maxB_v := bv, z2_maxB_p := p
                            if sv > z2_maxS_v
                                z2_maxS_v := sv, z2_maxS_p := p
                float z2_delta = z2_buy_total - z2_sell_total
                if math.abs(z2_delta) > 0
                    color z2_col = z2_delta >= 0 ? buy_col : sell_col
                    float target_p = z2_delta >= 0 ? z2_maxB_p : z2_maxS_p
                    if na(target_p)
                        target_p := math.avg(level_1, level_2)
                    string z2_txt = "●\nΔ " + (z2_delta > 0 ? "+" : "") + formatVolume(z2_delta)
                    string z2_tt = "Zone 2 Total Volume\nTotal Buy: " + formatVolume(z2_buy_total) + "\nTotal Sell: " + formatVolume(z2_sell_total) + "\nNet Delta: " + formatVolume(z2_delta) + "\nAnchored at Max " + (z2_delta >= 0 ? "Bull" : "Bear") + " Node"
                    labels_arr.push(label.new(box_center_X, target_p, z2_txt, textcolor=z2_col, style=label.style_none, size=getBubbleSize(math.abs(z2_delta)), tooltip=z2_tt))

// ─── Alerts ───
alertcondition(bull_accel, "Bullish Accelerator", "BuAx Detected")
alertcondition(bear_accel, "Bearish Accelerator", "BeAx Detected")
alertcondition(fire_ul, "UL — Unbalanced Low", "Wickless Bull Candle UL Detected")
alertcondition(fire_uh, "UH — Unbalanced High", "Wickless Bear Candle UH Detected")
````
