# Balanced Price Range (BPR) [TakingProphets]

- url: https://www.tradingview.com/script/r0QpyaoE-Balanced-Price-Range-BPR-TakingProphets/
- type: indicator
- pine_id: PUB;b59e7036f46643c3882ce73a964dd92e
- version: 1.0

## Description

OVERVIEW

The Balanced Price Range (BPR) study identifies areas where two opposing fair value gaps overlap in price. It marks the shared region between an inverted fair value gap and the newly formed gap that caused the inversion, tracking these zones forward in time until they are invalidated.

PURPOSE AND SCOPE
-----------------------------------------------------------------------------------------------

This study is intended for analytical and educational use. It automates the visual identification of overlapping gap regions so that a chart reader does not need to manually measure where two opposing fair value gaps intersect.

The study does not generate trade signals, recommendations, or forecasts. All markings are analytical references only.

LOGIC STRUCTURE
-----------------------------------------------------------------------------------------------

The study first identifies standard fair value gaps.

When an existing fair value gap is inverted by a confirmed candle close through it, the study checks whether the move responsible for that inversion also formed a new fair value gap in the opposing direction.

If it did, the study calculates the overlapping price region shared by the original gap and the newly formed opposing gap. That shared region is the Balanced Price Range.

If the two gaps do not share any overlapping price, no zone is drawn.

A bullish gap inverted downward by a bearish gap produces a bearish Balanced Price Range. A bearish gap inverted upward by a bullish gap produces a bullish Balanced Price Range.

A zone is invalidated when price closes back through it against its direction. A bearish zone is invalidated on a confirmed close above the zone high. A bullish zone is invalidated on a confirmed close below the zone low. Invalidated zones are removed from the chart and are not restored.

All state transitions require a confirmed bar close. Wicks and intrabar movement do not trigger detection or invalidation.

COMPONENTS AND VISUALS
-----------------------------------------------------------------------------------------------

Balanced Price Range zones are drawn as boxes spanning the overlapping price region and extended forward in time.

Bullish and bearish zones are styled independently.

An optional gradient renders each zone in graded bands at the zero, twenty five, fifty, seventy five, and one hundred percent levels of the zone, each with independent color, style, and thickness settings.

Optional labels identify each zone as a Balanced Price Range, positioned outside the lower right of the zone, with selectable label sizes.

INPUT CATEGORIES
-----------------------------------------------------------------------------------------------

General settings control detection sensitivity, minimum zone sizing, and how many zones are displayed on the chart.

Style settings control zone colors, gradient bands, label visibility, and label sizing for bullish and bearish zones independently.

USAGE GUIDELINES
-----------------------------------------------------------------------------------------------

This study is intended as a contextual reference for observing how price interacts with regions where opposing gaps overlap.

Zones may be used as study markers for observation and journaling. They are not entries, exits, or targets.

The study is designed for use alongside a reader's own analysis rather than in isolation.

OPERATIONAL NOTES AND LIMITATIONS
-----------------------------------------------------------------------------------------------

Because the overlapping region is by definition smaller than either source gap, zones can be narrow on lower timeframes. The minimum sizing filter is provided to manage this.

Detection depends on confirmed closes, so zones appear only after the relevant candle has closed.

Historical and real time behavior may differ in appearance as bars confirm.

Past chart behavior does not indicate future behavior. This study describes structure that has already formed.

ORIGINALITY AND ATTRIBUTION
-----------------------------------------------------------------------------------------------

This implementation is original code. The underlying concepts of fair value gaps, gap inversion, and balanced price ranges are widely discussed within the trading education community and are not claimed as proprietary.

TERMS AND DISCLAIMER
-----------------------------------------------------------------------------------------------

This study is provided for educational and analytical purposes only. It does not constitute financial advice, investment advice, or a recommendation to buy or sell any instrument.

Trading involves substantial risk of loss. Any decisions made are the sole responsibility of the user.

## Source Code

````pine
//@version=6
indicator('Balanced Price Range (BPR) [TakingProphets]', overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500, max_bars_back=1000)

// =============================================================================
// Balanced Price Range (BPR)
// Built from: Inversion Fair Value Gap (IFVG) [TakingProphets]
//              Gradient section mirrors Rejection Block Pro+ (personal_indicators/published/Rejection_Block_Pro.pine)
//
// A BPR is a specialized inversion FVG. Same 3-candle FVG detection and sizing
// filter as the IFVG indicator, with two differences:
//   1) A gap only counts as inverted if the confirmed move that inverts it also
//      forms a NEW opposing FVG (bullish gap inverting down -> new bearish FVG;
//      bearish gap inverting up -> new bullish FVG).
//   2) The drawn zone is the OVERLAP (intersection) of the original inverted gap
//      and the newly formed opposing gap: top = min(highs), bottom = max(lows).
//      No overlap -> no BPR drawn.
// =============================================================================

// ------------------------------------------------------------------ Groups ---
var string G_GEN = "General"
var string G_BPR = "BPR Style"

// ============================================================ GENERAL ========
detectionMode  = input.string('Single', 'Detection', options=['Series', 'Single'], group=G_GEN, tooltip='Series: merge adjacent Fair Value Gaps into one zone. Single: treat each gap individually.')
allowLongIFVGs = input.bool(false, 'Allow 7-15 Candle IFVGs', group=G_GEN, tooltip='If enabled, an FVG may invert within 15 candles. If disabled, it must invert within 6.')
atrStrictness  = input.string('Sensitive', 'Sensitivity', options=['Sensitive', 'Normal', 'Strict'], group=G_GEN, tooltip='Filter Fair Value Gaps by a minimum gap size measured in ATR(14). Sensitive removes only micro/tick gaps; Normal catches most gaps; Strict only allows large, obvious gaps.')
maxBprSetting  = input.string('3', 'BPRs to Show', options=['1', '2', '3', '4', '5', '10', '25'], group=G_GEN, tooltip='How many of the most recent Balanced Price Range boxes to keep on the chart. Lower = less clutter.')

// ========================================================= BPR STYLE =========
showBprLabel    = input.bool(true, 'Show Label', group=G_BPR, inline='bprlbl', tooltip='Show the "Balanced Price Range" text label on BPR boxes.')
bprLabelSizeSet = input.string('Tiny', 'Label Size', options=['Tiny', 'Small', 'Medium'], group=G_BPR, inline='bprlbl')
bprBullColor = input.color(color.new(color.blue, 55),   'BPR Bullish', group=G_BPR, inline='bprc')
bprBearColor = input.color(color.new(#D4A017, 55), 'BPR Bearish', group=G_BPR, inline='bprc')
bprGradShow   = input.bool(false, 'Show gradient', group=G_BPR)
bpr_q0_show   = input.bool(false, '0%',  group=G_BPR, inline='BQ0')
bpr_q0_color  = input.color(color.new(color.blue, 0), 'Color', group=G_BPR, inline='BQ0')
bpr_q0_style  = input.string('Dotted', 'Style', options=['Solid', 'Dashed', 'Dotted'], group=G_BPR, inline='BQ0', display=display.none)
bpr_q0_wSet   = input.string('Thin', '', options=['Thin', 'Medium', 'Thick'], group=G_BPR, inline='BQ0', display=display.none)
bpr_q25_show  = input.bool(true, '25%', group=G_BPR, inline='BQ25')
bpr_q25_color = input.color(color.new(color.blue, 0), 'Color', group=G_BPR, inline='BQ25')
bpr_q25_style = input.string('Dotted', 'Style', options=['Solid', 'Dashed', 'Dotted'], group=G_BPR, inline='BQ25', display=display.none)
bpr_q25_wSet  = input.string('Thin', '', options=['Thin', 'Medium', 'Thick'], group=G_BPR, inline='BQ25', display=display.none)
bpr_q50_show  = input.bool(true, '50%', group=G_BPR, inline='BQ50')
bpr_q50_color = input.color(color.new(color.blue, 0), 'Color', group=G_BPR, inline='BQ50')
bpr_q50_style = input.string('Dotted', 'Style', options=['Solid', 'Dashed', 'Dotted'], group=G_BPR, inline='BQ50', display=display.none)
bpr_q50_wSet  = input.string('Thin', '', options=['Thin', 'Medium', 'Thick'], group=G_BPR, inline='BQ50', display=display.none)
bpr_q75_show  = input.bool(true, '75%', group=G_BPR, inline='BQ75')
bpr_q75_color = input.color(color.new(color.blue, 0), 'Color', group=G_BPR, inline='BQ75')
bpr_q75_style = input.string('Dotted', 'Style', options=['Solid', 'Dashed', 'Dotted'], group=G_BPR, inline='BQ75', display=display.none)
bpr_q75_wSet  = input.string('Thin', '', options=['Thin', 'Medium', 'Thick'], group=G_BPR, inline='BQ75', display=display.none)
bpr_q100_show  = input.bool(false, '100%', group=G_BPR, inline='BQ100')
bpr_q100_color = input.color(color.new(color.blue, 0), 'Color', group=G_BPR, inline='BQ100')
bpr_q100_style = input.string('Dotted', 'Style', options=['Solid', 'Dashed', 'Dotted'], group=G_BPR, inline='BQ100', display=display.none)
bpr_q100_wSet  = input.string('Thin', '', options=['Thin', 'Medium', 'Thick'], group=G_BPR, inline='BQ100', display=display.none)

// ------------------------------------------------------------- Derived opts ---
bool fvgInSeries    = detectionMode == 'Series'
int  maxIFVGCandles = allowLongIFVGs ? 15 : 6
// A 3-candle opposing FVG completes one bar after the displacement candle that
// triggers the inversion close, so allow a short window for it to appear.
int  graceBars      = 2

f_showCount(string s) =>
    switch s
        '1'  => 1
        '2'  => 2
        '3'  => 3
        '4'  => 4
        '5'  => 5
        '10' => 10
        '25' => 25
        => 3
int maxBprShown = f_showCount(maxBprSetting)

string bprLabelSize = switch bprLabelSizeSet
    'Small'  => size.small
    'Medium' => size.normal
    => size.tiny

// ATR sizing filter (ported from iFVG Ultimate). Sensitive raised off 0 so micro
// gaps are filtered even on the loosest setting.
float atrStrictnessMult = switch atrStrictness
    'Sensitive' => 0.10
    'Normal'    => 0.25
    'Strict'    => 0.75
    => 0.25
float atrValue = ta.atr(14)

// ------------------------------------------------------------------- Types ---
// curBull: display character of the BPR box (true = bullish, false = bearish)
type FVG
    int   left
    float top
    int   right
    float bottom
    bool  bullish            // ORIGINAL FVG character (bullish gap = true)
    int   formedTime = time
    int   expireBar = na     // bar_index by which a pending FVG must invert
    bool  invertedPending = false  // inverted, awaiting the opposing FVG to complete
    int   oppExpireBar = na  // grace-window deadline for the opposing FVG
    box   drawing = na
    bool  curBull = false
    line  l0   = na
    line  l25  = na
    line  l50  = na
    line  l75  = na
    line  l100 = na
    label lbl  = na

// --------------------------------------------------------------- Functions ---
// How long a timeframe's candle runs for, in milliseconds (used for extension).
getTimeframeRuntime(tf) =>
    sec = timeframe.in_seconds(tf)
    if not na(sec) and sec > 0
        sec * 1000
    else
        switch tf
            "1"   => 60000
            "2"   => 120000
            "3"   => 180000
            "5"   => 300000
            "15"  => 900000
            "30"  => 1800000
            "60"  => 3600000
            "240" => 14400000
            "1D"  => 86400000
            => 3600000

// Fill color for the BPR box character.
colorFor(curBull) =>
    curBull ? bprBullColor : bprBearColor

// Gradient line style / width helpers (lifted from Rejection Block Pro+).
f_q_style(string s) =>
    switch s
        "Dashed" => line.style_dashed
        "Solid"  => line.style_solid
        => line.style_dotted

f_w(string s) =>
    switch s
        "Medium" => 2
        "Thick"  => 3
        => 1

// Create / update / delete a horizontal quadrant line (Rejection Block Pro+ pattern).
f_upd_hline(line ln, int x1, int x2, float y, bool want, color c, string st, int w) =>
    line out = ln
    if want
        if na(out)
            out := line.new(x1=x1, y1=y, x2=x2, y2=y, xloc=xloc.bar_time, color=c, style=f_q_style(st), width=w)
        else
            line.set_x1(out, x1), line.set_x2(out, x2), line.set_y1(out, y), line.set_y2(out, y)
            line.set_color(out, c), line.set_style(out, f_q_style(st)), line.set_width(out, w)
    else
        if not na(out)
            out.delete()
            out := na
    out

// Create / update / delete the zone label (bottom-right, anchored just outside).
f_upd_label(label lb, int x, float y, bool want, string txt, color c, string sz) =>
    label out = lb
    if want
        if na(out)
            out := label.new(x=x, y=y, xloc=xloc.bar_time, text=txt, style=label.style_label_left, textcolor=c, color=color.new(c, 100), size=sz, text_font_family=font.family_monospace)
        else
            label.set_xy(out, x, y)
            label.set_text(out, txt)
            label.set_textcolor(out, c)
            label.set_color(out, color.new(c, 100))
            label.set_size(out, sz)
    else
        if not na(out)
            out.delete()
            out := na
    out

// Pre-resolved gradient widths.
int bpr_q0_w   = f_w(bpr_q0_wSet)
int bpr_q25_w  = f_w(bpr_q25_wSet)
int bpr_q50_w  = f_w(bpr_q50_wSet)
int bpr_q75_w  = f_w(bpr_q75_wSet)
int bpr_q100_w = f_w(bpr_q100_wSet)

// ----------------------------------------------------------------- Methods ---
// Delete the box, all quadrant lines, and the label.
method remove(FVG this) =>
    if not na(this.drawing)
        this.drawing.delete()
        this.drawing := na
    if not na(this.l0)
        this.l0.delete()
        this.l0 := na
    if not na(this.l25)
        this.l25.delete()
        this.l25 := na
    if not na(this.l50)
        this.l50.delete()
        this.l50 := na
    if not na(this.l75)
        this.l75.delete()
        this.l75 := na
    if not na(this.l100)
        this.l100.delete()
        this.l100 := na
    if not na(this.lbl)
        this.lbl.delete()
        this.lbl := na
    true

// Draw / restyle the BPR box, gradient and label (render pass).
method render(FVG this, int xr) =>
    color fill = colorFor(this.curBull)
    if na(this.drawing)
        this.drawing := box.new(this.left, this.top, xr, this.bottom,
             bgcolor      = fill,
             border_color = color.new(fill, color.t(fill) / 3),
             border_width = 0,
             xloc         = xloc.bar_time)
    else
        this.drawing.set_bgcolor(fill)
        this.drawing.set_border_color(color.new(fill, color.t(fill) / 3))
        box.set_right(this.drawing, xr)

    float rng = this.top - this.bottom
    float y0   = this.bottom
    float y25  = this.bottom + rng * 0.25
    float y50  = this.bottom + rng * 0.50
    float y75  = this.bottom + rng * 0.75
    float y100 = this.top

    this.l0   := f_upd_hline(this.l0,   this.left, xr, y0,   bprGradShow and bpr_q0_show,   bpr_q0_color,   bpr_q0_style,   bpr_q0_w)
    this.l25  := f_upd_hline(this.l25,  this.left, xr, y25,  bprGradShow and bpr_q25_show,  bpr_q25_color,  bpr_q25_style,  bpr_q25_w)
    this.l50  := f_upd_hline(this.l50,  this.left, xr, y50,  bprGradShow and bpr_q50_show,  bpr_q50_color,  bpr_q50_style,  bpr_q50_w)
    this.l75  := f_upd_hline(this.l75,  this.left, xr, y75,  bprGradShow and bpr_q75_show,  bpr_q75_color,  bpr_q75_style,  bpr_q75_w)
    this.l100 := f_upd_hline(this.l100, this.left, xr, y100, bprGradShow and bpr_q100_show, bpr_q100_color, bpr_q100_style, bpr_q100_w)

    this.lbl := f_upd_label(this.lbl, xr, this.bottom, showBprLabel, "Balanced Price Range", color.new(fill, 0), bprLabelSize)
    true

// -------------------------------------------------------------------- State ---
var FVG[] pendingFVGs = array.new<FVG>(0)   // detected, awaiting inversion (undrawn)
var FVG[] activeBoxes = array.new<FVG>(0)   // drawn BPR boxes

int tfRuntime = getTimeframeRuntime(timeframe.period)

// ------------------------------------------------- Detection & inversion ---
if barstate.isconfirmed
    // --- Invalidate BPRs on a confirmed close back through, against direction ---
    // Bearish BPR: close ABOVE the overlap box top. Bullish BPR: close BELOW its
    // bottom. Uses the BPR box's own bounds; removed permanently (no re-trigger).
    if activeBoxes.size() > 0
        for i = activeBoxes.size() - 1 to 0
            FVG b = activeBoxes.get(i)
            bool invalid = (b.curBull and close < b.bottom) or ((not b.curBull) and close > b.top)
            if invalid
                b.remove()
                activeBoxes.remove(i)

    // --- Opposing FVG formed on THIS confirmed bar (gates inversions into BPRs) ---
    // New bearish FVG: current high below the low two bars back (top=low[2], bot=high).
    bool  newBearFvg = high < low[2] and (low[2] - high) > atrValue * atrStrictnessMult
    float newBearTop = low[2]
    float newBearBot = high
    // New bullish FVG: current low above the high two bars back (top=low, bot=high[2]).
    bool  newBullFvg = low > high[2] and (low - high[2]) > atrValue * atrStrictnessMult
    float newBullTop = low
    float newBullBot = high[2]

    // --- Pending FVGs: promote to BPR (overlap of original + opposing gap), or expire ---
    if pendingFVGs.size() > 0
        for i = pendingFVGs.size() - 1 to 0
            FVG p = pendingFVGs.get(i)
            // Opposing-gap coords for this gap's inversion direction (this bar).
            bool  haveOpp = p.bullish ? newBearFvg : newBullFvg
            float oppTop  = p.bullish ? newBearTop : newBullTop
            float oppBot  = p.bullish ? newBearBot : newBullBot
            if p.invertedPending
                // Already inverted on a prior bar; wait for the opposing FVG to
                // complete within the grace window (it lags the inversion by a bar).
                if haveOpp
                    float ovTop = math.min(p.top, oppTop)
                    float ovBot = math.max(p.bottom, oppBot)
                    if ovTop > ovBot
                        p.top    := ovTop
                        p.bottom := ovBot
                        p.curBull := not p.bullish            // BPR takes the inverted character
                        activeBoxes.push(p)
                    pendingFVGs.remove(i)                      // opposing FVG resolved (drawn if it overlapped)
                else if bar_index > p.oppExpireBar
                    pendingFVGs.remove(i)                      // grace lapsed with no opposing FVG
            else
                bool inverted = (p.bullish and close <= p.bottom) or ((not p.bullish) and close >= p.top)
                if inverted
                    // BPR gate: the inverting move must form a NEW opposing FVG.
                    if haveOpp
                        // Same-bar case: overlap = intersection of the two gaps.
                        float ovTop = math.min(p.top, oppTop)
                        float ovBot = math.max(p.bottom, oppBot)
                        if ovTop > ovBot
                            p.top    := ovTop
                            p.bottom := ovBot
                            p.curBull := not p.bullish
                            activeBoxes.push(p)
                        pendingFVGs.remove(i)                  // consumed (drawn only if BPR formed)
                    else
                        // Opposing FVG not complete yet — hold for the grace window.
                        p.invertedPending := true
                        p.oppExpireBar := bar_index + graceBars
                else if bar_index > p.expireBar
                    pendingFVGs.remove(i)                      // never inverted -> discard (undrawn)

    // --- Detect new 3-candle FVGs on this bar (no liquidity precondition) ---
    // Bullish gap: current low above the high two bars back.
    if low > high[2]
        float bTop = low
        float bBot = high[2]
        int   bLft = time[1]
        if fvgInSeries
            j = 1
            while low[j] > high[j + 2] and j < 50
                bBot := high[j + 2]
                bLft := time[j + 1]
                j += 1
        // Sizing filter: gap must exceed ATR * multiplier (measured at formation).
        if (bTop - bBot) > atrValue * atrStrictnessMult
            pendingFVGs.push(FVG.new(bLft, bTop, time, bBot, true, formedTime=time, expireBar=bar_index + maxIFVGCandles))

    // Bearish gap: current high below the low two bars back.
    if high < low[2]
        float sTop = low[2]
        float sBot = high
        int   sLft = time[1]
        if fvgInSeries
            j = 1
            while high[j] < low[j + 2] and j < 50
                sTop := low[j + 2]
                sLft := time[j + 1]
                j += 1
        if (sTop - sBot) > atrValue * atrStrictnessMult
            pendingFVGs.push(FVG.new(sLft, sTop, time, sBot, false, formedTime=time, expireBar=bar_index + maxIFVGCandles))

// ------------------------------------------ Keep only the most recent N BPRs ---
while activeBoxes.size() > maxBprShown
    FVG oldest = activeBoxes.shift()
    oldest.remove()

// ---------------------------------------------------------------- Render pass ---
// Runs every bar so boxes extend in realtime.
if activeBoxes.size() > 0
    int xr = time + tfRuntime
    for i = 0 to activeBoxes.size() - 1
        FVG f = activeBoxes.get(i)
        f.render(xr)
````
