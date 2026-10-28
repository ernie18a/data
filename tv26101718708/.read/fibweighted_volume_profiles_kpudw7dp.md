# Fib-Weighted Volume Profiles

- url: https://www.tradingview.com/script/KPUDW7dp/
- type: indicator
- pine_id: PUB;52d9a9ee7a344ecf93da8fdf398951c8
- version: 4.0

## Description

[b]Fib-Weighted Volume Profiles[/b] combines [i]Fibonacci retracement levels[/i] with a [i]swing-based volume profile[/i] on the most recent confirmed pivot leg. Instead of drawing Fib levels in isolation, this indicator shows how much of the swing's traded volume accumulated near each Fib price — helping you spot high-confluence support, resistance, and reaction zones.

[b]What makes it different[/b]

[list]
[*]Volume-weighted Fib analysis on the active swing leg (not a fixed session profile)
[*]POC (Point of Control), 70% Value Area, and horizontal volume histogram
[*]Golden Pocket zone (0.618–0.66) highlighted for OTE / pullback trading
[*]Confluence star ratings (★ to ★★★) based on volume %, POC proximity, and Golden Pocket
[*]Ghost POC lines from prior swings for historical liquidity context
[*]Optional HTF EMA trend filter to fade counter-trend levels
[*]Developing swing extension (SH* / SL*) before pivot confirmation
[*]Built-in alerts for strong Fib confluence, POC touch, and Golden Pocket volume
[/list]

[b]How it works[/b]

[list=1]
[*]Detects the latest swing using confirmed pivot highs/lows (default 5 left / 5 right bars — no repaint).
[*]Builds a volume profile across that swing range using configurable price bins.
[*]Plots standard Fib levels (0, 0.236, 0.382, 0.5, 0.618, 0.786, 1) and measures the % of total swing volume near each level.
[*]Colors and line weight reflect volume strength: strong (≥20%), medium (≥10%), weak.
[*]When POC aligns with a Fib level, labels merge into a single POC+Fib tag.
[*]Value Area box turns green/red on breakout; dashed style indicates a developing (unconfirmed) swing.
[/list]

[b]Chart elements[/b]

[list]
[*][b]Yellow dashed line[/b] — POC (highest volume price in the swing)
[*][b]Blue box[/b] — Value Area (~70% of volume); dashed border = developing leg
[*][b]Purple box[/b] — Golden Pocket (0.618–0.66)
[*][b]Grey histogram[/b] — Volume distribution by price bin
[*][b]Colored Fib lines[/b] — Volume strength at each retracement level
[*][b]P-1, P-2 labels[/b] — Ghost POC from previous swings
[*][b]SH / SL[/b] — Swing high / low markers (asterisk = developing)
[/list]

[b]Recommended settings[/b]

[list]
[*][b]Stocks / Forex (15m–1H):[/b] Bin Count 24–32, Pivot 5/5
[*][b]Crypto (5m–15m):[/b] Bin Count 32, enable LTF Volume Distribution if on higher TF
[*][b]No volume data (some CFDs):[/b] Enable "Synthetic Profile If No Volume" — Fib + swing only, or equal-weight approximation
[*][b]Crowded labels:[/b] Increase "Label Horizontal Spacing" to 12–16 bars
[/list]

[b]Alerts[/b]

[list]
[*]Strong 0.618 Volume — volume confluence at the 0.618 Fib level
[*]Strong Fib Confluence — any Fib level exceeds the strong threshold (default 20%)
[*]POC First Touch — price touches POC for the first time in the current swing
[*]Golden Pocket + Volume — price in Golden Pocket with strong zone volume
[/list]

[b]Limitations[/b]

[list]
[*]Designed for the [i]latest swing leg[/i] — not a full-session anchored profile.
[*]Very long swings are trimmed to Max Bar Range (default 500) for performance.
[*]LTF volume applies to the current bar only; history uses chart-timeframe volume.
[*]Pivot settings affect swing detection — adjust for your market and timeframe.
[*]Drawing limits (500 lines/labels/boxes) may clip visuals on extremely active charts.
[/list]

[quote]
[b]Disclaimer:[/b] This indicator is for educational and analytical purposes only. It does not constitute financial, investment, or trading advice. Past volume distribution patterns do not guarantee future price behavior. Always manage risk and do your own research before making trading decisions.
[/quote]

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Fib-Weighted Volume Profiles v3
// Swing-based Fib + Volume Profile confluence. Alerts fire on price interaction, not swing birth.
//
// v3 changes:
// - Live profile rebuild on confirmed bars within active swing
// - Interaction-based alerts (price touch + volume threshold)
// - Ghost POC only on confirmed pivot transitions
// - HVN/LVN nodes, adaptive Fib tolerance, close-weighted distribution
// - Display presets (Full/Clean/Minimal), info table, histogram box cap
// - VA breakout hysteresis, expanded render-key for reliable input redraw
// - Neon Pro theme: vivid palettes, gradient histogram, glass-style table

//@version=6
indicator("Fib-Weighted Volume Profiles", "Fib Vol Profile", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

const int   MAX_HIST_BOXES     = 48
const float VA_TARGET          = 0.70
const float HVN_POC_RATIO      = 0.50
const float LVN_AVG_RATIO      = 0.25

// ─── Constants ───────────────────────────────────────────────────────────────
const int   FIB_COUNT          = 7
const float FIB_RATIO_0        = 0.0
const float FIB_RATIO_1        = 0.236
const float FIB_RATIO_2        = 0.382
const float FIB_RATIO_3        = 0.5
const float FIB_RATIO_4        = 0.618
const float FIB_RATIO_5        = 0.786
const float FIB_RATIO_6        = 1.0
const float GOLDEN_POCKET_LO   = 0.618
const float GOLDEN_POCKET_HI   = 0.66
const string FIB_NAME_0        = "0"
const string FIB_NAME_1        = "0.236"
const string FIB_NAME_2        = "0.382"
const string FIB_NAME_3        = "0.5"
const string FIB_NAME_4        = "0.618"
const string FIB_NAME_5        = "0.786"
const string FIB_NAME_6        = "1"

// ─── Theme presets — Neon Pro (Dark / Light) ───────────────────────────────────
const color D_STRONG_BULL   = #00E676
const color D_STRONG_BEAR   = #FF2D6A
const color D_MEDIUM        = #FFB300
const color D_WEAK          = #78909C
const color D_POC           = #FFD600
const color D_VA            = #2979FF
const color D_GOLDEN        = #E040FB
const color D_VA_BREAK_UP   = #00E676
const color D_VA_BREAK_DN   = #FF1744
const color D_HIST          = #00E5FF
const color D_FIB_FIXED     = #90A4AE
const color D_WARN          = #FF9100
const color D_RETEST        = #00E5FF
const color D_ACCENT        = #00E5FF
const color D_LABEL_BG      = color.new(#0a0e17, 8)
const color D_TBL_BG        = color.new(#0a0e17, 5)
const color D_TBL_BORDER    = color.new(#00E5FF, 40)
const color D_TBL_LABEL     = #90A4AE
const color D_TBL_VALUE     = #ECEFF1
const color D_TBL_HDR       = color.new(#00E5FF, 88)

const color L_STRONG_BULL   = #00C853
const color L_STRONG_BEAR   = #D50000
const color L_MEDIUM        = #FF6D00
const color L_WEAK          = #455A64
const color L_POC           = #0091EA
const color L_VA            = #1976D2
const color L_GOLDEN        = #AA00FF
const color L_VA_BREAK_UP   = #2E7D32
const color L_VA_BREAK_DN   = #C62828
const color L_HIST          = #00838F
const color L_FIB_FIXED     = #37474F
const color L_WARN          = #E65100
const color L_RETEST        = #006064
const color L_ACCENT        = #0091EA
const color L_LABEL_BG      = color.new(#ffffff, 8)
const color L_TBL_BG        = color.new(#e3f2fd, 4)
const color L_TBL_BORDER    = color.new(#0091EA, 35)
const color L_TBL_LABEL     = #546E7A
const color L_TBL_VALUE     = #102027
const color L_TBL_HDR       = color.new(#0091EA, 90)

// ─── Inputs ──────────────────────────────────────────────────────────────────
string GRP_PIVOT = "Pivot / Swing"
int    pivotLeft  = input.int(10, "Pivot Left Bars", minval = 1, maxval = 50, group = GRP_PIVOT)
int    pivotRight = input.int(10, "Pivot Right Bars", minval = 1, maxval = 50, group = GRP_PIVOT, tooltip = "Uses confirmed pivots only; no repaint.")
bool   extendDevelopingSwing = input.bool(true, "Extend Developing Leg", group = GRP_PIVOT, tooltip = "Uses running high/low from leg start until pivot is confirmed.")

string GRP_PROFILE = "Volume Profile"
int    binCount            = input.int(32, "Bin Count", minval = 8, maxval = 64, group = GRP_PROFILE)
int    maxBarsInRange      = input.int(500, "Max Bar Range", minval = 10, maxval = 2000, group = GRP_PROFILE)
string distribMode         = input.string("Range", "Volume Distribution", options = ["Range", "HLC3", "Close-Weighted"], group = GRP_PROFILE, tooltip = "Range: equal spread across bar range. HLC3: single bin at typical price. Close-Weighted: 60% at close, 40% across range.")
bool   allowSyntheticVolume = input.bool(false, "Synthetic Profile If No Volume", group = GRP_PROFILE, tooltip = "Assigns equal weight per bar when real volume is unavailable. When off, only Fib + swing lines are drawn.")
bool   useLtfVolume        = input.bool(false, "LTF Volume (Experimental)", group = GRP_PROFILE, tooltip = "Experimental: lower-TF volume on the current bar only. Historical bars use chart TF volume.")
string ltfTimeframe        = input.timeframe("5", "LTF Timeframe", group = GRP_PROFILE, active = useLtfVolume)
bool   liveProfileUpdate   = input.bool(true, "Live Profile Update", group = GRP_PROFILE, tooltip = "Rebuild profile on each confirmed bar within the active swing.")

string GRP_FIB = "Fibonacci"
bool   adaptiveFibTol  = input.bool(true, "Adaptive Fib Tolerance", group = GRP_FIB, tooltip = "When on, zone width follows bin size instead of fixed %. Reduces overlapping Fib zone totals.")
float  fibTolerancePct = input.float(1.5, "Fib Volume Tolerance (%)", minval = 0.1, maxval = 10.0, step = 0.1, group = GRP_FIB, active = not adaptiveFibTol)
bool   showFib0   = input.bool(true, "0",     group = GRP_FIB, inline = "f0")
bool   showFib236 = input.bool(true, "0.236", group = GRP_FIB, inline = "f1")
bool   showFib382 = input.bool(true, "0.382", group = GRP_FIB, inline = "f2")
bool   showFib5   = input.bool(true, "0.5",   group = GRP_FIB, inline = "f3")
bool   showFib618 = input.bool(true, "0.618", group = GRP_FIB, inline = "f4")
bool   showFib786 = input.bool(true, "0.786", group = GRP_FIB, inline = "f5")
bool   showFib1   = input.bool(true, "1",     group = GRP_FIB, inline = "f6")
bool   fibColorByVolume = input.bool(true, "Color by Volume Strength", group = GRP_FIB, tooltip = "On: each Fib line is colored by volume % (theme strength colors). Off: all Fib lines use theme Fib fixed color.")
int    fibLineWidth     = input.int(1, "Fib Line Width", minval = 1, maxval = 4, group = GRP_FIB)
int    fibStrongLineWidth = input.int(2, "Strong Fib Line Width", minval = 1, maxval = 4, group = GRP_FIB, tooltip = "Line width when volume >= 20% and Color by Volume Strength is on.")

string GRP_THEME = "Theme"
string themeMode = input.string("Dark", "Color Theme", options = ["Dark", "Light", "Special"], group = GRP_THEME, tooltip = "Dark: neon-on-black pro palette. Light: high-contrast electric palette. Special: custom colors below.")
bool   isSpecialTheme = themeMode == "Special"

string GRP_THEME_CUSTOM = "Custom Theme Colors"
color  custStrongBull   = input.color(#00E676, "Strong (Bullish)", group = GRP_THEME_CUSTOM, active = isSpecialTheme)
color  custStrongBear   = input.color(#FF2D6A, "Strong (Bearish)", group = GRP_THEME_CUSTOM, active = isSpecialTheme)
color  custMedium       = input.color(#FFB300, "Medium", group = GRP_THEME_CUSTOM, active = isSpecialTheme)
color  custWeak         = input.color(#78909C, "Weak", group = GRP_THEME_CUSTOM, active = isSpecialTheme)
color  custPOC          = input.color(#FFD600, "POC", group = GRP_THEME_CUSTOM, active = isSpecialTheme)
color  custVA           = input.color(#2979FF, "Value Area", group = GRP_THEME_CUSTOM, active = isSpecialTheme)
color  custGoldenPocket = input.color(#E040FB, "Golden Pocket", group = GRP_THEME_CUSTOM, active = isSpecialTheme)
color  custVABreakUp    = input.color(#00E676, "VA Breakout Up", group = GRP_THEME_CUSTOM, active = isSpecialTheme)
color  custVABreakDn    = input.color(#FF1744, "VA Breakout Down", group = GRP_THEME_CUSTOM, active = isSpecialTheme)
color  custHistogram    = input.color(#00E5FF, "Histogram", group = GRP_THEME_CUSTOM, active = isSpecialTheme)
color  custFibFixed     = input.color(#90A4AE, "Fib Line (Fixed)", group = GRP_THEME_CUSTOM, active = isSpecialTheme)
color  custWarning      = input.color(#FF9100, "Warning Labels", group = GRP_THEME_CUSTOM, active = isSpecialTheme)
color  custRetest       = input.color(#00E5FF, "VA Retest Label", group = GRP_THEME_CUSTOM, active = isSpecialTheme)
color  custTableBg      = input.color(color.new(#0a0e17, 5), "Table Background", group = GRP_THEME_CUSTOM, active = isSpecialTheme)
color  custTableBorder  = input.color(color.new(#00E5FF, 40), "Table Border", group = GRP_THEME_CUSTOM, active = isSpecialTheme)
color  custTableLabel   = input.color(#90A4AE, "Table Label Text", group = GRP_THEME_CUSTOM, active = isSpecialTheme)
color  custTableValue   = input.color(#ECEFF1, "Table Value Text", group = GRP_THEME_CUSTOM, active = isSpecialTheme)

string GRP_VIS = "Display"
string displayPreset     = input.string("Full", "Display Preset", options = ["Full", "Clean", "Minimal"], group = GRP_VIS, tooltip = "Full: all layers. Clean: fewer labels, no ghost POC. Minimal: core Fib + POC only.")
bool   showInfoTable     = input.bool(true, "Info Table", group = GRP_VIS)
bool   showHvnLvn        = input.bool(true, "HVN / LVN Nodes", group = GRP_VIS, tooltip = "High/Low Volume Nodes relative to POC and local peaks/valleys.")
bool   showVaRetest      = input.bool(true, "VA Retest Label", group = GRP_VIS, active = displayPreset == "Full")
bool   showHistogram     = input.bool(true, "Profile Histogram", group = GRP_VIS, active = displayPreset != "Minimal")
bool   showPOC           = input.bool(true, "POC Line", group = GRP_VIS)
bool   showValueArea     = input.bool(true, "Value Area (70%)", group = GRP_VIS)
bool   showGoldenPocket  = input.bool(true, "Golden Pocket (0.618–0.66)", group = GRP_VIS, tooltip = "Purple box: OTE / Golden Pocket retracement zone between 0.618 and 0.66 Fib.")
bool   showSwingMarks    = input.bool(true, "Swing Markers", group = GRP_VIS)
bool   showGhostPoc      = input.bool(true, "Ghost POC (Prior Swings)", group = GRP_VIS, active = displayPreset == "Full")
int    ghostPocCount     = input.int(2, "Ghost POC Count", minval = 1, maxval = 3, group = GRP_VIS)
float  minVolumePctLabel = input.float(5.0, "Min Label Volume %", minval = 0.0, maxval = 50.0, step = 0.5, group = GRP_VIS)
int    histWidthBars     = input.int(12, "Histogram Width (bars)", minval = 3, maxval = 40, group = GRP_VIS)
int    labelStaggerBars  = input.int(10, "Label Horizontal Spacing (bars)", minval = 4, maxval = 30, group = GRP_VIS, tooltip = "Labels in the same price zone are shifted horizontally by this many bars.")
int    maxMainLabelSlots = input.int(3, "Main Column Max Labels", minval = 1, maxval = 6, group = GRP_VIS, tooltip = "Max stacked labels to the right of the histogram; beyond this limit only the line is shown.")

bool presetFull    = displayPreset == "Full"
bool presetClean   = displayPreset == "Clean"
bool presetMinimal = displayPreset == "Minimal"
bool effShowHistogram   = not presetMinimal and showHistogram
bool effShowGhostPoc    = presetFull and showGhostPoc
bool effShowSwingMarks  = not presetMinimal and showSwingMarks
bool effShowGoldenPocket = not presetMinimal and showGoldenPocket
bool effShowVaRetest    = presetFull and showVaRetest
bool effShowHvnLvn      = not presetMinimal and showHvnLvn
bool effShowInfoTable   = showInfoTable
int  effMaxLabelSlots   = presetMinimal ? 1 : presetClean ? 2 : maxMainLabelSlots
int  effHistWidth       = presetMinimal ? math.min(histWidthBars, 8) : histWidthBars

string GRP_MTF = "Higher Timeframe"
bool   useMtfFilter    = input.bool(false, "HTF EMA Color Fade", group = GRP_MTF, tooltip = "Fades counter-trend Fib colors using HTF EMA slope. Not a trade filter.")
string htfTimeframe    = input.timeframe("240", "HTF", group = GRP_MTF)
int    htfEmaLen       = input.int(50, "HTF EMA Length", minval = 5, maxval = 500, group = GRP_MTF)
bool   fadeCounterTrend = input.bool(true, "Fade Counter-Trend", group = GRP_MTF)

string GRP_ALERT = "Alerts"
float  alertStrongPct   = input.float(20.0, "Strong Confluence Threshold (%)", minval = 5.0, maxval = 80.0, step = 1.0, group = GRP_ALERT)
bool   alertOn618       = input.bool(true, "0.618 Alert", group = GRP_ALERT)
bool   alertAnyStrongFib = input.bool(true, "Any Strong Fib", group = GRP_ALERT)
bool   alertPocTouch    = input.bool(true, "POC First Touch", group = GRP_ALERT)
bool   alertGoldenPocket = input.bool(true, "Golden Pocket + Volume", group = GRP_ALERT, tooltip = "Fires once per swing when price touches Golden Pocket with volume >= threshold.")

f_themePick(color darkVal, color lightVal, color customVal) =>
    switch themeMode
        "Light"   => lightVal
        "Special" => customVal
        => darkVal

color colStrongBull   = f_themePick(D_STRONG_BULL, L_STRONG_BULL, custStrongBull)
color colStrongBear   = f_themePick(D_STRONG_BEAR, L_STRONG_BEAR, custStrongBear)
color colMedium       = f_themePick(D_MEDIUM, L_MEDIUM, custMedium)
color colWeak         = f_themePick(D_WEAK, L_WEAK, custWeak)
color colPOC          = f_themePick(D_POC, L_POC, custPOC)
color colVA           = f_themePick(D_VA, L_VA, custVA)
color colGoldenPocket = f_themePick(D_GOLDEN, L_GOLDEN, custGoldenPocket)
color colVABreakUp    = f_themePick(D_VA_BREAK_UP, L_VA_BREAK_UP, custVABreakUp)
color colVABreakDn    = f_themePick(D_VA_BREAK_DN, L_VA_BREAK_DN, custVABreakDn)
color colHistogram    = f_themePick(D_HIST, L_HIST, custHistogram)
color colFibFixed     = f_themePick(D_FIB_FIXED, L_FIB_FIXED, custFibFixed)
color colWarning      = f_themePick(D_WARN, L_WARN, custWarning)
color colRetest       = f_themePick(D_RETEST, L_RETEST, custRetest)
color colTableBg      = f_themePick(D_TBL_BG, L_TBL_BG, custTableBg)
color colTableBorder  = f_themePick(D_TBL_BORDER, L_TBL_BORDER, custTableBorder)
color colTableLabel   = f_themePick(D_TBL_LABEL, L_TBL_LABEL, custTableLabel)
color colTableValue   = f_themePick(D_TBL_VALUE, L_TBL_VALUE, custTableValue)
color colAccent       = f_themePick(D_ACCENT, L_ACCENT, custTableBorder)
color colLabelBg      = f_themePick(D_LABEL_BG, L_LABEL_BG, custTableBg)
color colTableHdr     = f_themePick(D_TBL_HDR, L_TBL_HDR, color.new(custTableBorder, 88))

bool isLightTheme = themeMode == "Light"

f_labelBg(color accent) =>
    color.new(accent, isLightTheme ? 86 : 82)

f_histBarColor(float v, float maxV) =>
    float pct = maxV > 0 ? v / maxV * 100.0 : 0.0
    isLightTheme ? color.from_gradient(pct, 0.0, 100.0, #B3E5FC, colHistogram) : color.from_gradient(pct, 0.0, 100.0, #1A237E, colHistogram)

f_vaFill(color base) =>
    color.new(base, isLightTheme ? 91 : 89)

f_vaBorder(color base) =>
    color.new(base, isLightTheme ? 25 : 18)

f_gpFill() =>
    color.new(colGoldenPocket, isLightTheme ? 93 : 91)

f_gpBorder() =>
    color.new(colGoldenPocket, isLightTheme ? 30 : 20)

// ─── Types ───────────────────────────────────────────────────────────────────
type SwingLeg
    float hi
    float lo
    int   hiBar
    int   loBar
    bool  bullish
    bool  valid
    bool  developingHi
    bool  developingLo

type ProfileResult
    array<float> volBins
    float totalVol
    float rangeHigh
    float rangeLow
    float binSize
    int   startBar
    int   endBar
    int   pocBin
    float pocPrice
    float vaHigh
    float vaLow
    bool  valid
    bool  rangeTrimmed
    array<int> hvnBins
    array<int> lvnBins

// ─── Volume state ────────────────────────────────────────────────────────────
bool hasRealVolume  = ta.cum(volume) > 0
bool volumeActive   = hasRealVolume or allowSyntheticVolume
bool useSyntheticOnly = not hasRealVolume and allowSyntheticVolume
int  chartTfSec     = timeframe.in_seconds()
int  ltfTfSec       = timeframe.in_seconds(ltfTimeframe)
bool ltfVolumeOk    = useLtfVolume and ltfTfSec > 0 and ltfTfSec < chartTfSec

[ltfHArr, ltfLArr, ltfCArr, ltfVArr] = request.security_lower_tf(syminfo.tickerid, ltfTimeframe, [high, low, close, volume])

// ─── Fib helpers ─────────────────────────────────────────────────────────────
f_fibVisible(int idx) =>
    switch idx
        0 => showFib0
        1 => showFib236
        2 => showFib382
        3 => showFib5
        4 => showFib618
        5 => showFib786
        => showFib1

f_fibRatio(int idx) =>
    switch idx
        0 => FIB_RATIO_0
        1 => FIB_RATIO_1
        2 => FIB_RATIO_2
        3 => FIB_RATIO_3
        4 => FIB_RATIO_4
        5 => FIB_RATIO_5
        => FIB_RATIO_6

f_fibName(int idx) =>
    switch idx
        0 => FIB_NAME_0
        1 => FIB_NAME_1
        2 => FIB_NAME_2
        3 => FIB_NAME_3
        4 => FIB_NAME_4
        5 => FIB_NAME_5
        => FIB_NAME_6

f_swingRangeHigh(SwingLeg swing) =>
    math.max(swing.hi, swing.lo)

f_swingRangeLow(SwingLeg swing) =>
    math.min(swing.hi, swing.lo)

f_binMid(ProfileResult profile, int binIdx) =>
    profile.rangeLow + (binIdx + 0.5) * profile.binSize

f_binLow(ProfileResult profile, int binIdx) =>
    profile.rangeLow + binIdx * profile.binSize

f_binHigh(ProfileResult profile, int binIdx) =>
    profile.rangeLow + (binIdx + 1) * profile.binSize

f_priceToBin(ProfileResult profile, float price) =>
    int idx = int(math.floor((price - profile.rangeLow) / profile.binSize))
    math.max(0, math.min(binCount - 1, idx))

f_fibPriceSwing(SwingLeg swing, float ratio) =>
    float rHi  = f_swingRangeHigh(swing)
    float rLo  = f_swingRangeLow(swing)
    float span = rHi - rLo
    swing.bullish ? rHi - ratio * span : rLo + ratio * span

f_fibPrice(SwingLeg swing, ProfileResult profile, float ratio) =>
    profile.valid ? (swing.bullish ? profile.rangeHigh - ratio * (profile.rangeHigh - profile.rangeLow) : profile.rangeLow + ratio * (profile.rangeHigh - profile.rangeLow)) : f_fibPriceSwing(swing, ratio)

f_goldenPocketBounds(SwingLeg swing, ProfileResult profile) =>
    float p618 = f_fibPrice(swing, profile, GOLDEN_POCKET_LO)
    float p660 = f_fibPrice(swing, profile, GOLDEN_POCKET_HI)
    [math.max(p618, p660), math.min(p618, p660)]

f_inGoldenPocket(SwingLeg swing, ProfileResult profile, float price) =>
    [gpHi, gpLo] = f_goldenPocketBounds(swing, profile)
    price <= gpHi and price >= gpLo

f_labelGapFromSwing(SwingLeg swing) =>
    float span = f_swingRangeHigh(swing) - f_swingRangeLow(swing)
    math.max(span / binCount * 2.0, syminfo.mintick * 8)

f_labelGap(ProfileResult profile) =>
    math.max(profile.binSize * 2.0, syminfo.mintick * 8)

// ─── Volume distribution ───────────────────────────────────────────────────────
f_distributeBarVolume(array<float> volBins, ProfileResult profile, float barHigh, float barLow, float barClose, float barVol, string mode) =>
    if barVol > 0 and profile.binSize > 0
        if mode == "HLC3"
            float midPrice = (barHigh + barLow + barClose) / 3.0
            int b = f_priceToBin(profile, midPrice)
            array.set(volBins, b, array.get(volBins, b) + barVol)
        else if mode == "Close-Weighted"
            int bClose = f_priceToBin(profile, barClose)
            array.set(volBins, bClose, array.get(volBins, bClose) + barVol * 0.60)
            float effLow  = math.max(barLow, profile.rangeLow)
            float effHigh = math.min(barHigh, profile.rangeHigh)
            if effHigh >= effLow
                int bStart  = f_priceToBin(profile, effLow)
                int bEnd    = f_priceToBin(profile, effHigh)
                int touched = bEnd - bStart + 1
                float share = barVol * 0.40 / touched
                for b = bStart to bEnd
                    array.set(volBins, b, array.get(volBins, b) + share)
        else
            float effLow  = math.max(barLow, profile.rangeLow)
            float effHigh = math.min(barHigh, profile.rangeHigh)
            if effHigh >= effLow
                int bStart  = f_priceToBin(profile, effLow)
                int bEnd    = f_priceToBin(profile, effHigh)
                int touched = bEnd - bStart + 1
                float share = barVol / touched
                for b = bStart to bEnd
                    array.set(volBins, b, array.get(volBins, b) + share)

f_distributeLtfArrays(array<float> volBins, ProfileResult profile, array<float> hArr, array<float> lArr, array<float> cArr, array<float> vArr, bool synthetic, string mode) =>
    int n = array.size(vArr)
    if n > 0
        for i = 0 to n - 1
            float v = array.get(vArr, i)
            if synthetic
                v := v > 0 ? v : 1.0
            if v > 0
                f_distributeBarVolume(volBins, profile, array.get(hArr, i), array.get(lArr, i), array.get(cArr, i), v, mode)

f_barVolume(float rawVol, bool synthetic) =>
    synthetic ? 1.0 : rawVol

f_detectHvnLvn(array<float> volBins, int pocIdx, int bins) =>
    array<int> hvns = array.new_int()
    array<int> lvns = array.new_int()
    float pocVol = pocIdx >= 0 ? array.get(volBins, pocIdx) : 0.0
    float avgVol = 0.0
    for b = 0 to bins - 1
        avgVol += array.get(volBins, b)
    avgVol := bins > 0 ? avgVol / bins : 0.0
    float hvnMin = pocVol * HVN_POC_RATIO
    float lvnMax = avgVol * LVN_AVG_RATIO
    if bins >= 3 and pocVol > 0
        for b = 1 to bins - 2
            float v = array.get(volBins, b)
            float vLo = array.get(volBins, b - 1)
            float vHi = array.get(volBins, b + 1)
            if v >= hvnMin and v > vLo and v > vHi and b != pocIdx
                array.push(hvns, b)
            if v <= lvnMax and v < vLo and v < vHi and v > 0
                array.push(lvns, b)
    [hvns, lvns]

f_finalizeProfile(array<float> volBins, ProfileResult result, int bins) =>
    float total     = 0.0
    int   pocIdx    = 0
    float maxBinVol = 0.0
    for b = 0 to bins - 1
        float v = array.get(volBins, b)
        total += v
        if v > maxBinVol
            maxBinVol := v
            pocIdx    := b
    result.volBins  := volBins
    result.totalVol := total
    result.pocBin   := pocIdx
    result.pocPrice := f_binMid(result, pocIdx)
    result.valid    := total > 0
    if result.valid
        float targetVA = total * VA_TARGET
        float accVol   = array.get(volBins, pocIdx)
        int loIdx = pocIdx
        int hiIdx = pocIdx
        while accVol < targetVA and (loIdx > 0 or hiIdx < bins - 1)
            float volBelow = loIdx > 0 ? array.get(volBins, loIdx - 1) : -1.0
            float volAbove = hiIdx < bins - 1 ? array.get(volBins, hiIdx + 1) : -1.0
            if volBelow >= volAbove and loIdx > 0
                loIdx -= 1
                accVol += array.get(volBins, loIdx)
            else if hiIdx < bins - 1
                hiIdx += 1
                accVol += array.get(volBins, hiIdx)
            else if loIdx > 0
                loIdx -= 1
                accVol += array.get(volBins, loIdx)
            else
                break
        result.vaLow  := f_binLow(result, loIdx)
        result.vaHigh := f_binHigh(result, hiIdx)
        [hvnArr, lvnArr] = f_detectHvnLvn(volBins, pocIdx, bins)
        result.hvnBins := hvnArr
        result.lvnBins := lvnArr
    result

// ─── Profile builder ─────────────────────────────────────────────────────────
f_buildProfile(SwingLeg swing, bool volActive, bool synthetic, bool ltfOk, int liveEndBar) =>
    array<float> volBins = array.new<float>(binCount, 0.0)
    ProfileResult result = ProfileResult.new(volBins, 0.0, 0.0, 0.0, 0.0, 0, 0, -1, na, na, na, false, false, array.new_int(), array.new_int())

    if swing.valid and volActive
        int rawStart = math.min(swing.hiBar, swing.loBar)
        int rawEnd   = math.max(swing.hiBar, swing.loBar)
        int endBar   = liveProfileUpdate ? math.max(rawEnd, liveEndBar) : rawEnd
        bool trimmed = endBar - rawStart > maxBarsInRange
        int startBar = trimmed ? endBar - maxBarsInRange : rawStart
        int barsInRange = endBar - startBar

        float rHi   = f_swingRangeHigh(swing)
        float rLo   = f_swingRangeLow(swing)
        float bSize = (rHi - rLo) / binCount

        if barsInRange >= 0 and bSize > 0
            result.rangeHigh    := rHi
            result.rangeLow     := rLo
            result.binSize      := bSize
            result.startBar     := startBar
            result.endBar       := endBar
            result.rangeTrimmed := trimmed

            for i = 0 to barsInRange
                int targetBar = startBar + i
                int barsAgo   = bar_index - targetBar
                if barsAgo >= 0
                    if ltfOk and barsAgo == 0
                        f_distributeLtfArrays(volBins, result, ltfHArr, ltfLArr, ltfCArr, ltfVArr, synthetic, distribMode)
                    else
                        float barVol = f_barVolume(volume[barsAgo], synthetic)
                        if barVol > 0
                            f_distributeBarVolume(volBins, result, high[barsAgo], low[barsAgo], close[barsAgo], barVol, distribMode)

            result := f_finalizeProfile(volBins, result, binCount)

    result

f_effectiveFibTol(ProfileResult profile) =>
    adaptiveFibTol and profile.valid ? math.max(profile.binSize * 2.0, syminfo.mintick * 4) : (profile.rangeHigh - profile.rangeLow) * fibTolerancePct / 100.0

f_zoneVolumePct(ProfileResult profile, float fibPrice) =>
    if not profile.valid or profile.totalVol <= 0 or array.size(profile.volBins) < binCount
        0.0
    else
        float tol     = f_effectiveFibTol(profile)
        float zLo     = fibPrice - tol
        float zHi     = fibPrice + tol
        float zoneVol = 0.0
        for b = 0 to binCount - 1
            float bMid = f_binMid(profile, b)
            if bMid >= zLo and bMid <= zHi
                zoneVol += array.get(profile.volBins, b)
        zoneVol / profile.totalVol * 100.0

f_priceTouchesLevel(float level, float gap) =>
    math.abs(close - level) <= gap or (low <= level and high >= level)

f_strengthColor(SwingLeg swing, float volPct) =>
    if volPct >= 20.0
        swing.bullish ? colStrongBull : colStrongBear
    else if volPct >= 10.0
        colMedium
    else
        colWeak

f_fibLineColor(SwingLeg swing, float volPct, bool volLayer) =>
    if fibColorByVolume and volLayer
        f_strengthColor(swing, volPct)
    else if fibColorByVolume
        colWeak
    else
        colFibFixed

f_fibLineWidth(float volPct, bool volLayer) =>
    fibColorByVolume and volLayer and volPct >= 20.0 ? fibStrongLineWidth : fibLineWidth

f_confluenceStars(float volPct, bool pocNear, bool inGP) =>
    if volPct >= 20.0 and (pocNear or inGP)
        "★★★ "
    else if volPct >= 10.0 or (pocNear and volPct >= 5.0)
        "★★ "
    else if volPct >= minVolumePctLabel
        "★ "
    else
        ""

f_fmtPrice(float price) =>
    str.tostring(price, format.mintick)

f_nearPrice(float a, float b, float gap) =>
    math.abs(a - b) < gap

// Horizontal slot index for labels in the same price band (0 = main column)
f_labelSlot(array<float> placedYs, float y, float gap) =>
    int slot = 0
    int n = array.size(placedYs)
    if n > 0
        for i = 0 to n - 1
            if f_nearPrice(array.get(placedYs, i), y, gap)
                slot += 1
    slot

f_fadeColor(color base, bool aligned) =>
    useMtfFilter and fadeCounterTrend and not aligned ? color.new(base, 55) : base

// ─── HTF EMA trend ───────────────────────────────────────────────────────────
float htfEma     = request.security(syminfo.tickerid, htfTimeframe, ta.ema(close, htfEmaLen), barmerge.gaps_off, barmerge.lookahead_off)
float htfEmaPrev = htfEma[1]
int   htfTrend   = htfEma > htfEmaPrev ? 1 : htfEma < htfEmaPrev ? -1 : 0

// ─── Swing detection ─────────────────────────────────────────────────────────
var float lastHi    = na
var float lastLo    = na
var int   lastHiBar = na
var int   lastLoBar = na

float ph = ta.pivothigh(high, pivotLeft, pivotRight)
float pl = ta.pivotlow(low, pivotLeft, pivotRight)

if not na(ph)
    lastHi    := ph
    lastHiBar := bar_index - pivotRight
if not na(pl)
    lastLo    := pl
    lastLoBar := bar_index - pivotRight

bool hasSwing   = not na(lastHi) and not na(lastLo) and not na(lastHiBar) and not na(lastLoBar)
bool bullishLeg = hasSwing and lastLoBar < lastHiBar
int  lenFromLo  = math.max(hasSwing ? bar_index - lastLoBar + 1 : 1, 1)
int  lenFromHi  = math.max(hasSwing ? bar_index - lastHiBar + 1 : 1, 1)

float runHi     = ta.highest(high, lenFromLo)
int   hiBarsAgo = ta.highestbars(high, lenFromLo)
float runLo     = ta.lowest(low, lenFromHi)
int   loBarsAgo = ta.lowestbars(low, lenFromHi)

float effHi    = lastHi
float effLo    = lastLo
int   effHiBar = lastHiBar
int   effLoBar = lastLoBar
bool  devHi    = false
bool  devLo    = false

if hasSwing and extendDevelopingSwing
    if bullishLeg
        if runHi > lastHi
            effHi    := runHi
            effHiBar := bar_index - hiBarsAgo
            devHi    := true
    else
        if runLo < lastLo
            effLo    := runLo
            effLoBar := bar_index - loBarsAgo
            devLo    := true

SwingLeg swing = SwingLeg.new(na, na, 0, 0, false, false, false, false)
if hasSwing
    swing.hi           := effHi
    swing.lo           := effLo
    swing.hiBar        := effHiBar
    swing.loBar        := effLoBar
    swing.bullish      := bullishLeg
    swing.valid        := effHi != effLo
    swing.developingHi := devHi
    swing.developingLo := devLo

bool trendAligned = not useMtfFilter or (swing.bullish and htfTrend >= 0) or (not swing.bullish and htfTrend <= 0)
bool isDeveloping = swing.developingHi or swing.developingLo

// ─── Profile cache + ghost POC ───────────────────────────────────────────────
var int   cachedHiBar      = na
var int   cachedLoBar      = na
var float cachedHi         = na
var float cachedLo         = na
var int   cachedEndBar     = na
var array<float> ghostPocs = array.new_float()
var ProfileResult activeProfile = ProfileResult.new(array.new<float>(binCount, 0.0), 0.0, 0.0, 0.0, 0.0, 0, 0, -1, na, na, na, false, false, array.new_int(), array.new_int())

bool pivotConfirmed = not na(ph) or not na(pl)
bool swingChanged = swing.valid and (
     na(cachedHiBar) or na(cachedLoBar) or na(cachedHi) or na(cachedLo) or
     cachedHiBar != swing.hiBar or cachedLoBar != swing.loBar or
     cachedHi != swing.hi or cachedLo != swing.lo)
bool profileStale = liveProfileUpdate and swing.valid and volumeActive and barstate.isconfirmed and (
     na(cachedEndBar) or cachedEndBar != bar_index)

if swingChanged
    // Ghost POC only on confirmed pivot transition — not on developing H/L extension
    if activeProfile.valid and volumeActive and not na(activeProfile.pocPrice) and pivotConfirmed
        array.unshift(ghostPocs, activeProfile.pocPrice)
        while array.size(ghostPocs) > ghostPocCount
            array.pop(ghostPocs)
    cachedHiBar     := swing.hiBar
    cachedLoBar     := swing.loBar
    cachedHi        := swing.hi
    cachedLo        := swing.lo
    cachedEndBar    := bar_index
    activeProfile   := f_buildProfile(swing, volumeActive, useSyntheticOnly, ltfVolumeOk, bar_index)
else if profileStale
    cachedEndBar  := bar_index
    activeProfile := f_buildProfile(swing, volumeActive, useSyntheticOnly, ltfVolumeOk, bar_index)

ProfileResult profile = activeProfile
bool showVolLayer = volumeActive and profile.valid

// ─── VA state machine ────────────────────────────────────────────────────────
var int  vaState         = 0
var bool vaRetestShown   = false
var bool pocTouched      = false
var bool alert618Sent    = false
var bool alertAnyFibSent = false
var bool alertGpSent     = false

float lblGapSwing = swing.valid ? f_labelGapFromSwing(swing) : syminfo.mintick * 8
float lblGapProf  = profile.valid ? f_labelGap(profile) : lblGapSwing
float gpP618      = swing.valid ? f_fibPrice(swing, profile, GOLDEN_POCKET_LO) : na
float gpP660      = swing.valid ? f_fibPrice(swing, profile, GOLDEN_POCKET_HI) : na
float gpTop       = swing.valid ? math.max(gpP618, gpP660) : na
float gpBot       = swing.valid ? math.min(gpP618, gpP660) : na

if swingChanged
    vaState       := 0
    vaRetestShown := false
    pocTouched    := false
    alert618Sent  := false
    alertAnyFibSent := false
    alertGpSent   := false

if showVolLayer and barstate.isconfirmed
    if close > profile.vaHigh
        if vaState != 1
            vaRetestShown := false
        vaState := 1
    else if close < profile.vaLow
        if vaState != -1
            vaRetestShown := false
        vaState := -1
    // Inside VA: keep prior breakout state (hysteresis) — avoids whipsaw color flicker

bool vaRetest = false
if showVolLayer and vaState != 0 and not vaRetestShown and barstate.isconfirmed
    bool backToVa = vaState == 1 ? close <= profile.vaHigh + lblGapProf and close >= profile.vaLow : close >= profile.vaLow - lblGapProf and close <= profile.vaHigh
    if backToVa
        vaRetest      := true
        vaRetestShown := true

// ─── Alert logic (price interaction + volume threshold) ─────────────────────
float maxFibVol = 0.0
int   maxFibIdx = -1
if showVolLayer
    for fi = 0 to FIB_COUNT - 1
        if f_fibVisible(fi)
            float v = f_zoneVolumePct(profile, f_fibPrice(swing, profile, f_fibRatio(fi)))
            if v > maxFibVol
                maxFibVol := v
                maxFibIdx   := fi

float alertVol618 = showVolLayer and showFib618 ? f_zoneVolumePct(profile, f_fibPrice(swing, profile, FIB_RATIO_4)) : 0.0
float fib618Px    = showVolLayer ? f_fibPrice(swing, profile, FIB_RATIO_4) : na
float gpVol       = showVolLayer ? f_zoneVolumePct(profile, (gpTop + gpBot) / 2.0) : 0.0
bool  inGpNow     = swing.valid and close <= gpTop and close >= gpBot

bool touchPocNow = showVolLayer and f_priceTouchesLevel(profile.pocPrice, lblGapProf)
if touchPocNow and not pocTouched
    pocTouched := true

bool touch618Now = showVolLayer and showFib618 and alertVol618 >= alertStrongPct and f_priceTouchesLevel(fib618Px, lblGapProf)
bool touchAnyFibNow = false
if showVolLayer and maxFibIdx >= 0 and maxFibVol >= alertStrongPct
    float maxFibPx = f_fibPrice(swing, profile, f_fibRatio(maxFibIdx))
    touchAnyFibNow := f_priceTouchesLevel(maxFibPx, lblGapProf)

bool touchGpNow = showVolLayer and inGpNow and gpVol >= alertStrongPct and f_priceTouchesLevel((gpTop + gpBot) / 2.0, lblGapProf)

bool strong618    = alertOn618 and touch618Now and not alert618Sent
bool strongAnyFib = alertAnyStrongFib and touchAnyFibNow and not alertAnyFibSent
bool alertPoc     = alertPocTouch and pocTouched and not pocTouched[1]
bool strongGp     = alertGoldenPocket and touchGpNow and not alertGpSent

if strong618
    alert618Sent := true
if strongAnyFib
    alertAnyFibSent := true
if strongGp
    alertGpSent := true

alertcondition(strong618, title = "Strong 0.618 Volume", message = "Price touched 0.618 Fib with strong volume confluence.")
alertcondition(strongAnyFib, title = "Strong Fib Confluence", message = "Price touched a strong Fib level with volume confluence.")
alertcondition(alertPoc, title = "POC First Touch", message = "Price touched POC for the first time.")
alertcondition(strongGp, title = "Golden Pocket Volume", message = "Price in Golden Pocket with strong volume confluence.")

// ─── Drawing objects ─────────────────────────────────────────────────────────
var array<line>  fibLines    = array.new_line()
var array<label> fibLabels   = array.new_label()
var array<box>   histBoxes   = array.new_box()
var array<line>  ghostLines  = array.new_line()
var array<label> ghostLabels = array.new_label()
var line  pocLine      = na
var label pocLabel     = na
var box   vaBox        = na
var box   gpBox        = na
var label shLabel      = na
var label slLabel      = na
var label trimLabel    = na
var label volWarnLabel = na
var label vaRetestLabel = na
var array<line>  hvnLines    = array.new_line()
var array<line>  lvnLines    = array.new_line()
var table infoTable = na

f_renderKey() =>
    themeMode + "|" + displayPreset + "|" + str.tostring(binCount) + "|" + str.tostring(fibColorByVolume) +
     "|" + str.tostring(fibLineWidth) + "|" + str.tostring(fibStrongLineWidth) + "|" +
     str.tostring(showPOC) + "|" + str.tostring(showValueArea) + "|" + str.tostring(effShowHistogram) +
     "|" + str.tostring(effShowGhostPoc) + "|" + str.tostring(effShowHvnLvn) + "|" + str.tostring(effHistWidth)

var string appliedRenderKey = na
var color prevCustPOC     = na
var color prevCustBull    = na
var color prevCustBear    = na
var color prevCustMed     = na
var color prevCustWeak    = na
var color prevCustVA      = na
var color prevCustGP      = na
var color prevCustHist    = na
var color prevCustFib     = na
var color prevCustVaUp    = na
var color prevCustVaDn    = na
var color prevCustWarn    = na
var color prevCustRetest  = na
var color prevCustTblBg   = na
var color prevCustTblBr   = na
var color prevCustTblLbl  = na
var color prevCustTblVal  = na

bool custColorsChanged = isSpecialTheme and barstate.islast and (
     custPOC != prevCustPOC or custStrongBull != prevCustBull or custStrongBear != prevCustBear or
     custMedium != prevCustMed or custWeak != prevCustWeak or custVA != prevCustVA or
     custGoldenPocket != prevCustGP or custHistogram != prevCustHist or custFibFixed != prevCustFib or
     custVABreakUp != prevCustVaUp or custVABreakDn != prevCustVaDn or
     custWarning != prevCustWarn or custRetest != prevCustRetest or
     custTableBg != prevCustTblBg or custTableBorder != prevCustTblBr or
     custTableLabel != prevCustTblLbl or custTableValue != prevCustTblVal)

string renderKey         = f_renderKey()
bool   renderKeyChanged  = barstate.islast and (na(appliedRenderKey) or renderKey != appliedRenderKey)
bool   needsRedraw       = barstate.islast and swing.valid and array.size(fibLines) == 0
bool   doRender          = swingChanged or needsRedraw or renderKeyChanged or custColorsChanged or (profileStale and barstate.islast)

if doRender
    for ln in fibLines
        line.delete(ln)
    array.clear(fibLines)
    for lb in fibLabels
        label.delete(lb)
    array.clear(fibLabels)
    for bx in histBoxes
        box.delete(bx)
    array.clear(histBoxes)
    for gl in ghostLines
        line.delete(gl)
    array.clear(ghostLines)
    for glb in ghostLabels
        label.delete(glb)
    array.clear(ghostLabels)
    for hl in hvnLines
        line.delete(hl)
    array.clear(hvnLines)
    for ll in lvnLines
        line.delete(ll)
    array.clear(lvnLines)
    if not na(pocLine)
        line.delete(pocLine)
        pocLine := na
    if not na(pocLabel)
        label.delete(pocLabel)
        pocLabel := na
    if not na(vaBox)
        box.delete(vaBox)
        vaBox := na
    if not na(gpBox)
        box.delete(gpBox)
        gpBox := na
    if not na(shLabel)
        label.delete(shLabel)
        shLabel := na
    if not na(slLabel)
        label.delete(slLabel)
        slLabel := na
    if not na(trimLabel)
        label.delete(trimLabel)
        trimLabel := na
    if not na(volWarnLabel)
        label.delete(volWarnLabel)
        volWarnLabel := na
    if not na(vaRetestLabel)
        label.delete(vaRetestLabel)
        vaRetestLabel := na

    if swing.valid
        int xLeft     = showVolLayer ? profile.startBar : math.min(swing.hiBar, swing.loBar)
        int xRight    = showVolLayer ? math.max(profile.endBar, bar_index) : math.max(math.max(swing.hiBar, swing.loBar), bar_index)
        int histRight = xRight + effHistWidth
        float lblGap  = showVolLayer ? lblGapProf : lblGapSwing
        bool devStyle = isDeveloping

        if not volumeActive
            volWarnLabel := label.new(bar_index, high, "No volume data", style = label.style_label_down, color = color.new(colWarning, 70), textcolor = colWarning, size = size.tiny)
        else if useSyntheticOnly
            volWarnLabel := label.new(bar_index, high, "Synthetic volume — no real data", style = label.style_label_down, color = color.new(colWarning, 70), textcolor = colWarning, size = size.tiny)

        if effShowGoldenPocket
            gpBox := box.new(xLeft, gpTop, histRight, gpBot, bgcolor = f_gpFill(), border_color = f_gpBorder(), border_width = 2)

        if showVolLayer and showValueArea and not na(profile.vaHigh) and not na(profile.vaLow)
            color vaBg  = vaState == 1 ? colVABreakUp : vaState == -1 ? colVABreakDn : colVA
            vaBox := box.new(xLeft, profile.vaHigh, histRight, profile.vaLow, bgcolor = f_vaFill(vaBg), border_color = f_vaBorder(vaBg), border_width = devStyle ? 2 : 1, border_style = devStyle ? line.style_dashed : line.style_solid)

        if showVolLayer and effShowHistogram and array.size(profile.volBins) >= binCount
            float maxBinVol = array.max(profile.volBins)
            int histTr = isLightTheme ? 38 : 28
            int boxesDrawn = 0
            if maxBinVol > 0
                for b = 0 to binCount - 1
                    if boxesDrawn >= MAX_HIST_BOXES
                        break
                    float v = array.get(profile.volBins, b)
                    if v > 0
                        float barW = effHistWidth * (v / maxBinVol)
                        color barCol = f_histBarColor(v, maxBinVol)
                        box bx = box.new(xRight, f_binHigh(profile, b), int(xRight + barW), f_binLow(profile, b), bgcolor = color.new(barCol, histTr), border_color = color.new(barCol, histTr + 8), border_width = 1)
                        array.push(histBoxes, bx)
                        boxesDrawn += 1

        // HVN / LVN secondary nodes
        if showVolLayer and effShowHvnLvn
            int hvnN = array.size(profile.hvnBins)
            if hvnN > 0
                for hi = 0 to hvnN - 1
                    int bIdx = array.get(profile.hvnBins, hi)
                    float hvnPx = f_binMid(profile, bIdx)
                    if not f_nearPrice(hvnPx, profile.pocPrice, lblGap)
                        line hln = line.new(xLeft, hvnPx, histRight, hvnPx, color = color.new(colStrongBull, 20), width = 2, style = line.style_dotted)
                        array.push(hvnLines, hln)
            int lvnN = array.size(profile.lvnBins)
            if lvnN > 0
                for li = 0 to lvnN - 1
                    int bIdx = array.get(profile.lvnBins, li)
                    float lvnPx = f_binMid(profile, bIdx)
                    line lln = line.new(xLeft, lvnPx, histRight, lvnPx, color = color.new(colWeak, 45), width = 1, style = line.style_dashed)
                    array.push(lvnLines, lln)

        array<float> placedLabelYs = array.new_float()
        int pocMergedFib = -1
        string pocTxt    = showVolLayer ? "POC\n" + f_fmtPrice(profile.pocPrice) : ""
        color  pocTxtCol = colPOC

        if showVolLayer and showPOC
            for fi = 0 to FIB_COUNT - 1
                if f_fibVisible(fi)
                    float chkPx  = f_fibPrice(swing, profile, f_fibRatio(fi))
                    float chkVol = f_zoneVolumePct(profile, chkPx)
                    if f_nearPrice(chkPx, profile.pocPrice, lblGap) and chkVol >= minVolumePctLabel
                        pocMergedFib := fi
                        bool inGP    = f_inGoldenPocket(swing, profile, profile.pocPrice)
                        string stars = f_confluenceStars(chkVol, true, inGP)
                        pocTxt    := stars + "POC+" + f_fibName(fi) + "\n" + f_fmtPrice(profile.pocPrice) + "  %" + str.tostring(chkVol, "#.#")
                        pocTxtCol := f_fadeColor(f_strengthColor(swing, chkVol), trendAligned)
                        break
            if pocMergedFib < 0
                pocTxt := "POC\n" + f_fmtPrice(profile.pocPrice)
            pocLine  := line.new(xLeft, profile.pocPrice, histRight, profile.pocPrice, color = colPOC, width = 3, style = line.style_dashed)
            pocLabel := label.new(histRight, profile.pocPrice, pocTxt, style = label.style_label_left, color = f_labelBg(pocTxtCol), textcolor = pocTxtCol, size = size.normal)
            array.push(placedLabelYs, profile.pocPrice)

        for fi = 0 to FIB_COUNT - 1
            if f_fibVisible(fi)
                float ratio  = f_fibRatio(fi)
                float fibPx  = f_fibPrice(swing, profile, ratio)
                float volPct = showVolLayer ? f_zoneVolumePct(profile, fibPx) : 0.0
                color lnCol  = f_fadeColor(f_fibLineColor(swing, volPct, showVolLayer), trendAligned)
                int   lnW    = f_fibLineWidth(volPct, showVolLayer)
                line ln = line.new(xLeft, fibPx, histRight, fibPx, color = lnCol, width = lnW, style = devStyle ? line.style_dashed : line.style_solid)
                array.push(fibLines, ln)
                if showVolLayer and volPct >= minVolumePctLabel and fi != pocMergedFib
                    bool pocNear = f_nearPrice(fibPx, profile.pocPrice, lblGap)
                    if not pocNear
                        bool inGP    = f_inGoldenPocket(swing, profile, fibPx)
                        string stars = f_confluenceStars(volPct, false, inGP)
                        int slot     = f_labelSlot(placedLabelYs, fibPx, lblGap)
                        if slot <= effMaxLabelSlots
                            int labelX = histRight + slot * labelStaggerBars
                            string txt = stars + f_fibName(fi) + "\n" + f_fmtPrice(fibPx) + "  %" + str.tostring(volPct, "#.#")
                            label lb = label.new(labelX, fibPx, txt, style = label.style_label_left, color = f_labelBg(lnCol), textcolor = lnCol, size = size.normal)
                            array.push(fibLabels, lb)
                            array.push(placedLabelYs, fibPx)

        int ghostSize = array.size(ghostPocs)
        if showVolLayer and effShowGhostPoc and ghostSize > 0
            int ghostColX = histRight + (effMaxLabelSlots + 1) * labelStaggerBars
            array<float> placedGhostYs = array.new_float()
            for gi = 0 to ghostSize - 1
                float gP = array.get(ghostPocs, gi)
                bool skipGhostLbl = showPOC and f_nearPrice(gP, profile.pocPrice, lblGap)
                int gSlot = f_labelSlot(placedGhostYs, gP, lblGap)
                bool showGLbl = not skipGhostLbl and gSlot <= 2
                int lineEndX = showGLbl ? ghostColX + gSlot * labelStaggerBars : histRight
                line gl = line.new(xLeft, gP, lineEndX, gP, color = color.new(colAccent, 55), width = 1, style = line.style_dotted)
                array.push(ghostLines, gl)
                if showGLbl
                    label glb = label.new(ghostColX + gSlot * labelStaggerBars, gP, "P-" + str.tostring(gi + 1) + "\n" + f_fmtPrice(gP), style = label.style_label_left, color = f_labelBg(colPOC), textcolor = color.new(colPOC, 15), size = size.small)
                    array.push(ghostLabels, glb)
                    array.push(placedGhostYs, gP)

        if effShowSwingMarks
            shLabel := label.new(swing.hiBar, swing.hi, swing.developingHi ? "SH*" : "SH", style = label.style_label_down, color = f_labelBg(colStrongBear), textcolor = colStrongBear, size = size.tiny)
            slLabel := label.new(swing.loBar, swing.lo, swing.developingLo ? "SL*" : "SL", style = label.style_label_up, color = f_labelBg(colStrongBull), textcolor = colStrongBull, size = size.tiny)

        if showVolLayer and profile.rangeTrimmed
            trimLabel := label.new(xRight, profile.rangeHigh, "Range trimmed (" + str.tostring(maxBarsInRange) + " bars)", style = label.style_label_down, color = color.new(colWarning, 70), textcolor = colWarning, size = size.tiny)

    if barstate.islast
        appliedRenderKey := renderKey
        if custColorsChanged
            prevCustPOC    := custPOC
            prevCustBull   := custStrongBull
            prevCustBear   := custStrongBear
            prevCustMed    := custMedium
            prevCustWeak   := custWeak
            prevCustVA     := custVA
            prevCustGP     := custGoldenPocket
            prevCustHist   := custHistogram
            prevCustFib    := custFibFixed
            prevCustVaUp   := custVABreakUp
            prevCustVaDn   := custVABreakDn
            prevCustWarn   := custWarning
            prevCustRetest := custRetest
            prevCustTblBg  := custTableBg
            prevCustTblBr  := custTableBorder
            prevCustTblLbl := custTableLabel
            prevCustTblVal := custTableValue

// ─── Live VA update + retest marker ──────────────────────────────────────────
if showVolLayer and not na(vaBox) and barstate.islast
    color vaBgLive = vaState == 1 ? colVABreakUp : vaState == -1 ? colVABreakDn : colVA
    box.set_bgcolor(vaBox, f_vaFill(vaBgLive))
    box.set_border_color(vaBox, f_vaBorder(vaBgLive))

if vaRetest and showVolLayer and effShowVaRetest
    float retestY = vaState == 1 ? profile.vaHigh : profile.vaLow
    if not na(vaRetestLabel)
        label.delete(vaRetestLabel)
    vaRetestLabel := label.new(bar_index, retestY, "VA↩", style = label.style_label_left, color = f_labelBg(colRetest), textcolor = colRetest, size = size.tiny)

// ─── Info table (dashboard) ──────────────────────────────────────────────────
if barstate.islast
    if not na(infoTable)
        table.delete(infoTable)
        infoTable := na
    if effShowInfoTable and swing.valid
        infoTable := table.new(position.top_right, 2, 8, bgcolor = colTableBg, border_width = 2, border_color = colTableBorder, frame_color = colAccent, frame_width = 1)
        string dirTxt = swing.bullish ? "Bull" : "Bear"
        string htfTxt = useMtfFilter ? (htfTrend > 0 ? "Up" : htfTrend < 0 ? "Down" : "Flat") : "Off"
        string topFib = maxFibIdx >= 0 ? f_fibName(maxFibIdx) + " " + str.tostring(maxFibVol, "#.#") + "%" : "—"
        string pocTxt = showVolLayer ? f_fmtPrice(profile.pocPrice) : "—"
        string vaTxt  = showVolLayer and not na(profile.vaHigh) ? f_fmtPrice(profile.vaLow) + " – " + f_fmtPrice(profile.vaHigh) : "—"
        string hvnTxt = showVolLayer ? str.tostring(array.size(profile.hvnBins)) : "—"
        string lvnTxt = showVolLayer ? str.tostring(array.size(profile.lvnBins)) : "—"
        table.cell(infoTable, 0, 0, "FIB VOL", bgcolor = colTableHdr, text_color = colAccent, text_size = size.small)
        table.cell(infoTable, 1, 0, dirTxt + (isDeveloping ? " ·dev" : ""), bgcolor = colTableHdr, text_color = swing.bullish ? colStrongBull : colStrongBear, text_size = size.small)
        table.cell(infoTable, 0, 1, "POC", bgcolor = colTableBg, text_color = colTableLabel, text_size = size.small)
        table.cell(infoTable, 1, 1, pocTxt, bgcolor = colTableBg, text_color = colPOC, text_size = size.small)
        table.cell(infoTable, 0, 2, "VA", bgcolor = colTableBg, text_color = colTableLabel, text_size = size.small)
        table.cell(infoTable, 1, 2, vaTxt, bgcolor = colTableBg, text_color = colVA, text_size = size.small)
        table.cell(infoTable, 0, 3, "Top Fib", bgcolor = colTableBg, text_color = colTableLabel, text_size = size.small)
        table.cell(infoTable, 1, 3, topFib, bgcolor = colTableBg, text_color = colMedium, text_size = size.small)
        table.cell(infoTable, 0, 4, "HTF", bgcolor = colTableBg, text_color = colTableLabel, text_size = size.small)
        table.cell(infoTable, 1, 4, htfTxt, bgcolor = colTableBg, text_color = htfTrend >= 0 ? colStrongBull : colStrongBear, text_size = size.small)
        table.cell(infoTable, 0, 5, "HVN", bgcolor = colTableBg, text_color = colTableLabel, text_size = size.small)
        table.cell(infoTable, 1, 5, hvnTxt, bgcolor = colTableBg, text_color = colStrongBull, text_size = size.small)
        table.cell(infoTable, 0, 6, "LVN", bgcolor = colTableBg, text_color = colTableLabel, text_size = size.small)
        table.cell(infoTable, 1, 6, lvnTxt, bgcolor = colTableBg, text_color = colWeak, text_size = size.small)
        table.cell(infoTable, 0, 7, "Distrib", bgcolor = colTableBg, text_color = colTableLabel, text_size = size.small)
        table.cell(infoTable, 1, 7, distribMode, bgcolor = colTableBg, text_color = colTableValue, text_size = size.small)
````
