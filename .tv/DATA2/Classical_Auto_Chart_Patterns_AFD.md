<!-- tradingview-pine-id: PUB;aa5197d6cb6c4ca58177db9bc1bb4664 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Classical Auto Chart Patterns [AFD]

Source: https://www.tradingview.com/script/g5uim9n5-Classical-Auto-Chart-Patterns-AFD/

## Description

A pattern's name tells you what it's supposed to mean. This script also shows you what it actually did.

[image]https://www.tradingview.com/x/Brun1Plu/[/image]
[image]https://www.tradingview.com/x/bDyvMMdW/[/image]
Fifteen classical chart patterns, drawn automatically off confirmed pivots. When one completes, its label reads what price did — not what the textbook hoped. A bullish-named shape that breaks down is labelled Rectangle · Closed Below, not Bearish Reversal.

Reading the label

Every reading starts with Conventionally. That word is literal: it's what the textbook says about the shape's name, not what this script thinks about your chart. Then two plain ideas — which way the textbook reads the shape (Bullish, Bearish, or Two-Sided when it won't call one), and what kind of move it files the shape under (Continuation is a pause inside an existing move; Reversal is a turn).

 []Conventionally Bearish Reversal · Rising Wedge []Conventionally Two-Sided Continuation · Rising Channel [*]Conventionally Two-Sided · Rectangle — won't say either way 

Those same two ideas are filters in the settings, read from the same grouping as the label — so the panel and the chart can't disagree about what a formation is.

What it draws

Fifteen formations, off confirmed pivots only:

 Channels and wedges, rising and falling, each fitted to two boundaries Triangles — ascending, descending, symmetrical []Rectangles, flags and pennants — flags and pennants need a prior move, and stop being named once the pause runs too long to be brief Neckline reversals — double top and bottom, head & shoulders and its inverse, each drawn through its own extrema with its neckline 

Once an anchor is placed, it never moves.

Three things here that are unusual

[image]https://www.tradingview.com/x/fSnhLVy4/[/image]
1. Expired formations stay on the chart. A shape that ran past its apex, drifted out of the width band that let it be named, or outlived the swings that defined it is drawn dim and dashed, right beside the ones that completed. Showing only what completed is a survivorship filter on the evidence in front of you. It ships off (Expired formations kept = 0, to keep a fast intraday chart clean) — turn it up and they're back.

2. The reading is attributed, not endorsed. That Conventionally prefix isn't politeness. On AMEX:SPY 2m over 1,549 bars at default settings, across the 58 formations that completed, price ran no further with the completing close over the next 20 bars than against it. One instrument, one timeframe, chart history — not a forecast. The script reports what the literature says about the name. It doesn't endorse it, and it doesn't tell you what to do.

3. Nothing is scored or ranked. No formation carries a grade, a strength value or an ordering against another — not on a drawing, not in the table. Shapes are compared in exactly one place, and it's a setting you control: when more qualify than there are draw slots, the By dropdown decides which get drawn. That comparison never reaches a label and says nothing about a formation's quality.

On the chart

[image]https://www.tradingview.com/x/gWQHEFc9/[/image]
Three states you can tell apart at a glance. Forming is solid and runs to the right edge. Completed is dotted and stops at the bar a close finished beyond a boundary. Expired is dim and dashed.

Entry, Target and Stop levels are drawn when a formation completes. Entry is that completing close. Up to three targets sit at your own multiples of R and ship at 0.25R, 0.5R and 1R. The Stop ships at the formation's own opposite boundary read on the completing bar — or, on a neckline pattern, the far peak or trough it's built on — with a fixed-R option if you prefer. R is the formation's own height, capped at your multiple of recent daily range. These are your settings drawn as geometry. They measure nothing about outcomes. A level can record that a bar traded to its price, on its own label; an unmarked level means only that no bar has reached it yet — never that it failed.

Gate levels on % Complete ships off, so every completion gets levels. Switch it on and only completions inside a % band you set are given levels — the rest are still detected, named, tabled and alerted, just without levels.

A corner table lists the completed formations still on the chart — name, conventional reading, and the same prices the labels carry, read from the same frozen fields. Two alerts fire on a bar's close, not on a wick through a line: a formation is admitted, and a formation completes.

Late by design — how it behaves live

This draws off confirmed pivots only. A pivot isn't confirmed until Swing strength bars have closed past it, so a formation appears that many bars after the pivot that anchors it — and because each boundary is drawn back to its anchors, the finished chart shows a line on bars where it hadn't been drawn yet. The left end of every boundary means "confirmed later," not "known then." On history the whole formation is there the moment you load it; live, it appears some bars after its anchors print. TradingView classes pivot-based scripts as potentially misleading for exactly this reason, and this one is in that category.

It draws into the past but never revises a drawing in place. Stepped through Bar Replay one bar at a time over 150 bars of NASDAQ:AAPL 1m: 183 boundaries each held one contiguous run of frames — none altered, none vanishing and returning — and 22 completed labels never moved or changed text. Replay hands over whole closed bars, so nothing here is claimed tick by tick. One value comes from a higher timeframe — a daily range that caps how far a level can project — requested as the previous completed daily bar with barmerge.lookahead_on, the pairing that does not repaint. Nothing else reads a timeframe other than your own.

Settings worth knowing

 []Swing strength sets the scale — higher means fewer, larger formations and a longer wait for each. It stays editable under every preset. []Preset — Strict, Balanced or Permissive — is how cleanly a shape has to fit its anchors. It says nothing about how shapes resolve. []Draw formations while they are forming is off by default, so a fresh chart opens showing formations that have already ended. []Completed / Expired formations kept are recency windows, not contests — worth turning up before you conclude a family is missing. 

Credit

The boundary-validity geometry — same-side anchors, no bar piercing the line between them, nothing violating it since — is my own earlier work, open source and public as Auto Trendlines [AFD]. The formation layer here is built on top of it.

Licence

Open source under the Mozilla Public License 2.0. © Auction Foundry

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Auction Foundry

//@version=6
indicator(title = "Classical Auto Chart Patterns [AFD]", shorttitle = "CACP [AFD]", overlay = true,
     max_lines_count = 500, max_labels_count = 160, max_boxes_count = 85,
     max_polylines_count = 25, max_bars_back = 5000)

// =============================================================================
// Classical Auto Chart Patterns [AFD]
//
// Draws the classical two-boundary formations - wedges, triangles, rectangles,
// channels, flags, pennants - and the neckline reversal patterns - double top
// and bottom, head & shoulders and its inverse - from CONFIRMED pivots only.
//
// Detection lag is inherent and is not hidden. A boundary is anchored to
// ta.pivothigh()/ta.pivotlow(), which return a value only after `Swing strength`
// bars have closed past the pivot, so a formation appears that many bars after
// the pivot that defines it. Once drawn, an anchor never moves. Boundaries are
// drawn back to their anchors, so read the left end of one as "confirmed later",
// not as "known then".
//
// max_lines_count is at the platform ceiling of 500. Over the declared cap Pine
// silently drops the OLDEST lines, so a shortfall shows as a formation missing
// its boundaries rather than as an error.
// =============================================================================


// ======================== Constants ==========================================

int   SURVIVORS_PER_SIDE = 3
int   MAX_KEPT_PER_SIDE  = 12
int   MAX_ACTIVE         = 6
int   RESOLVED_MAX       = MAX_KEPT_PER_SIDE * MAX_KEPT_PER_SIDE
int   POLE_LOOKBACK      = 20
float POLE_MIN_ATR       = 3.0
float FLAG_SPAN_MULT     = 2.0
float SYMMETRY_MIN       = 0.30
float OVERLAP_MIN        = 0.30
float FLAT_TRAVEL_FRAC   = 0.25
float FLAT_TRAVEL_ATR    = 1.25
float HOLD_FACTOR        = 10.0
float AGE_SPAN_MULT      = 2.0
float APEX_SPAN_MULT     = 1.5
float CHANNEL_WIDTH_MAX  = 1.5
float TOP_MATCH_ATR      = 0.5
float SHOULDER_MATCH_ATR = 0.75
float HEAD_BEYOND_ATR    = 0.5
int   NECK_MAX_ACTIVE    = 3
float NECK_HEIGHT_MAX_ATR = 6.0
int   DRAW_MAX_BACK      = 9500
int   GLOW_OUTER_WIDTH   = 9
int   GLOW_OUTER_TRANSP  = 88
int   GLOW_INNER_WIDTH   = 4
int   GLOW_INNER_TRANSP  = 72
int   GLOW_RETAINED_DIM  = 8
int   FILL_RETAINED_DIM  = 6
int   FILL_EXPIRED_DIM   = 12
int   EXPIRED_TRANSP     = 62
int   LABEL_X_GAP        = 15
int   LABEL_COL_GAP      = 8
int   LEADER_TRANSP      = 55
int   ARROW_MIN_RUN      = 5
int   LEG_TRANSP         = 35
int   ZONE_TRANSP        = 68
int   HIT_NONE           = 0
int   HIT_TARGET         = 1
int   HIT_STOP           = -1
int   HIT_BOTH           = 2
string HIT_MARK      = " · Reached"
string HIT_MARK_BOTH = " · Both Reached In One Bar"
int   R_CAP_ATR_LEN      = 7
float STRUCT_STOP_FLOOR_R = 0.5
string R_CAP_NOTE = "R is the height of the formation itself — the vertical distance " +
     "the shape spans. A level of 1R sits one full height from Entry, 0.5R half of it, " +
     "2R twice.\n" +
     "• `R cap (× daily ATR)` can rein this in for a very tall formation, ceiling R at " +
     "that multiple of the last 7 daily bars' average range; at 0 the cap is off. When " +
     "it binds, two formations of different heights can show the same distance to Target."
string LEVEL_NOTE_MIN = "User-configured geometry, not a measured outcome."

string LEVEL_NOTE = LEVEL_NOTE_MIN + "\n" +
     "• Entry is the completing close. The Target sits at your own multiple of the " +
     "formation's height, capped - unless you set the cap to 0 - at your own multiple " +
     "of the average true range of the last 7 DAILY bars, or of your chart's own last " +
     "7 bars on a weekly or monthly chart, where the daily figure is requested as " +
     "always and then discarded for being no lower than the chart. The Stop sits on " +
     "the basis its own label names.\n" +
     "• `Reached` records that one bar's high or low traded to this price, and that zone " +
     "is brightened and outlined to say the same thing. It is never counted, scored or " +
     "compared, and where one bar reached both prices nothing in the data says " +
     "which of them it traded to first.\n" +
     "• No mark, or a faded zone, means only that no bar has reached it yet — not that it " +
     "failed. None of this says what price will do next."

string LABEL_SIZE        = size.small

string F_FALLING_WEDGE = "Falling Wedge"
string F_RISING_WEDGE  = "Rising Wedge"
string F_SYMMETRICAL   = "Symmetrical Triangle"
string F_ASC_TRIANGLE  = "Ascending Triangle"
string F_DESC_TRIANGLE = "Descending Triangle"
string F_RECTANGLE     = "Rectangle"
string F_RISING_CHAN   = "Rising Channel"
string F_FALLING_CHAN  = "Falling Channel"
string F_BULL_FLAG     = "Bull Flag"
string F_BEAR_FLAG     = "Bear Flag"
string F_PENNANT       = "Pennant"
string F_DOUBLE_TOP    = "Double Top"
string F_DOUBLE_BOT    = "Double Bottom"
string F_HS            = "Head & Shoulders"
string F_IHS           = "Inverse Head & Shoulders"
string F_NONE          = ""

string R_BULL    = "Conventionally Bullish"
string R_BEAR    = "Conventionally Bearish"
string R_NEUTRAL = "Two-Sided"

string CAT_ALL   = "All"
string CAT_CONT  = "Continuation"
string CAT_BILAT = "Bilateral"
string CAT_REV   = "Reversal"

string BIAS_ALL  = "All"
string BIAS_BULL = "Bullish"
string BIAS_BEAR = "Bearish"
string BIAS_NEUT = "Two-sided"

string ADJ_BULL  = "Bullish"
string ADJ_BEAR  = "Bearish"
string ADJ_NEUT  = "Two-Sided"
string NOUN_CONT = " Continuation"
string NOUN_REV  = " Reversal"

int STATE_FORMING  = 0
int STATE_COMPLETE = 1
int STATE_EXPIRED  = 2

string EXP_APEX   = "Expired At Its Apex"
string EXP_AGE    = "Expired: Ran Past Its Own Length"
string EXP_BAND   = "Expired: Width Left Its Band"
string EXP_BRIEF  = "Expired: No Longer Brief"
string EXP_WINDOW = "Expired: Past The Search Window"

string UNREACH_REMOVE = "Remove it"
string UNREACH_FADE   = "Fade it"
int    ZONE_FADE_TRANSP  = 94
int    LABEL_FADE_TRANSP = 92
int    TEXT_FADE_TRANSP  = 55
int    ZONE_REACHED_TRANSP = 40
int    ZONE_REACHED_WIDTH  = 2
int    ZONE_NO_BORDER      = 100
int    ZONE_EDGE_TRANSP    = 18
int    ZONE_EDGE_WIDTH     = 1

string PRE_STRICT = "Strict"
string PRE_BAL    = "Balanced"
string PRE_PERM   = "Permissive"

string LBL_OFF    = "Off"
string LBL_MARKER = "Marker"
string LBL_NAME   = "Name"
string LBL_FULL   = "Name + reading"

string STYLE_GLOW = "Glow"

string LBL_AT  = "On the shape"
string LBL_COL = "Right column"

string SEL_NEAR = "Nearest"
string SEL_NEW  = "Newest"
string SEL_TALL = "Tallest"
string SEL_LONG = "Longest"

int TBL_COLS     = 11
int TBL_ROWS     = 12
int TBL_DATA_MAX = 10
int   TBL_FILL_TRANSP = 20
color TBL_FILL_TEXT   = color.white
int TBL_SPINE_TRANSP   = 93
int TBL_CHIP_TRANSP    = 85
int TBL_DIVIDER_TRANSP = 88
int TBL_DIVIDER_ROW = 5
int TBL_ENTRY_ROW   = 6
string REACHED_NONE      = "—"
string REACHED_AMBIGUOUS = " (one bar)"
string TBL_NOTE_A = "Entry is the close that completed the formation. The Target is your own multiple of R - that formation's own height brought down to the R cap, whichever is smaller - and the Stop sits on the basis its own field names."
string TBL_NOTE_B = "% Complete, completion, reached and the times beside the prices are this chart's history."
string TBL_NOTE_C = "A dash under Reached, or a price with no time beside it, means no bar has reached that level yet, not that it failed."
string TBL_NOTE_E = "% Complete is how far through its own span a formation had run at the bar it ended on: bars from its left edge - the LATER of its two boundaries' first anchors, or the first extreme of a Double Top, Double Bottom or Head and Shoulders, which are drawn from one neckline and have no shared anchor - over bars from that edge to where its span runs out, which is the apex where two boundaries converge, otherwise whichever of the age, width, duration and length bounds comes first. A dash down the level rows, Reached included, means the completion's own figure fell outside the band Gate levels on % Complete sets: the formation was given no levels, so there was none to reach."
string TBL_NOTE_D = "Not a forecast. Not advice."
string PCT_NOTE = "% complete is age, not quality: bars since this formation's left edge - the later of its two boundaries' first anchors, or the first extreme of a Double Top, Double Bottom or Head and Shoulders - over bars to whichever bound ends it, the apex where two boundaries converge, otherwise the first of the age, width, duration and length bounds. It moves with the chart's last bar and describes elapsed bars and nothing else; 100% means the bound itself and never a bar short of it. A higher figure is an older formation rather than a better one, and it falls in one case only: a flag or pennant that stops being brief is renamed to the longer-lived channel or triangle underneath it, and re-bases against that longer life. Not a forecast. `Gate levels on % Complete`, when it is switched on, reads this same figure, taken at the bar a formation completes on rather than at this one."
string TBL_NOTE = "• " + TBL_NOTE_A + "\n• " + TBL_NOTE_B + "\n• " + TBL_NOTE_C +
     "\n• " + TBL_NOTE_E + "\n• " + TBL_NOTE_D
string TBL_TL = "Top left"
string TBL_TC = "Top center"
string TBL_TR = "Top right"
string TBL_ML = "Mid left"
string TBL_MC = "Mid center"
string TBL_MR = "Mid right"
string TBL_BL = "Bottom left"
string TBL_BC = "Bottom center"
string TBL_BR = "Bottom right"
string TBL_SZ_TINY   = "Tiny"
string TBL_SZ_SMALL  = "Small"
string TBL_SZ_NORMAL = "Normal"
string TBL_SZ_LARGE  = "Large"

string RISK_NOTE = "Size is your own risk budget ÷ the drawn stop distance ÷ the instrument's point value, in whole units, rounded down.\n• The first currency figure is what those whole units carry; the second is the budget you set — typed directly, or account size × percent. Rounding down leaves the difference unused.\n• Where the budget does not cover one whole unit the size is zero and the first figure is instead what one unit would have cost, named as such; nothing carries anything.\n• Arithmetic on figures you set — not a measured outcome, not a forecast and not advice.\n• Your budget is assumed to be in the instrument's own currency; nothing here converts one currency to another."
string RISK_AMOUNT  = "Amount"
string RISK_PERCENT = "Percent"
string ALERT_BRIEF = "Brief"
string ALERT_FULL  = "Full"
string ALERT_JSON  = "JSON"
string ALERT_NOTE = "Descriptive only. Not a signal, not an order and not advice."

string G_DETECT  = "Detection"
string G_CONT    = "Formations · Continuation & Bilateral"
string G_REV     = "Formations · Reversal"
string G_SHOWN   = "Formations shown"
string G_TRADE   = "Trade levels"
string G_DISPLAY = "Display"
string G_ALERT   = "Alerts"


// ======================== Inputs =============================================

string presetInput = input.string(PRE_BAL, "Preset", group = G_DETECT,
     options = [PRE_STRICT, PRE_BAL, PRE_PERM], display = display.none,
     tooltip = "Five geometry settings, moved together: how far back a boundary may " +
     "anchor, how much history is searched, how far price may pierce a line, and the two " +
     "angle tolerances. Governs how cleanly a pair of pivots must fit before it counts as " +
     "a boundary — never how a shape resolves.\n\n" +
     "• Strict — a pair must fit tightly: least pierce, tightest angles. Six highs and " +
     "six lows searched over 200 bars, so its shapes span less.\n" +
     "• Balanced — the shipped settings. Ten and ten over 300 bars.\n" +
     "• Permissive — the loosest fit admitted, and shapes that may span the most: twelve " +
     "highs and twelve lows over 400 bars.\n" +
     "• Looser is not simply MORE. A looser fit also lets one long boundary stand where " +
     "a tighter one found two shorter ones, and a wider pool anchors further back. " +
     "Which preset draws more depends on the chart in front of you.\n" +
     "• `Swing strength` and `ATR` are separate settings and are read under all " +
     "three; they set scale and unit, not strictness.")

int swingInput = input.int(8, "Swing strength", minval = 1, maxval = 50, group = G_DETECT,
     display = display.none, inline = "d1",
     tooltip = "How many bars must close either side of a high or low before it counts " +
     "as a pivot. Everything here is built from pivots.\n\n" +
     "• This number is the drawing lag: a boundary cannot appear until this many bars " +
     "close past its anchor.\n" +
     "• Raise → fewer, larger formations, each arriving later.\n" +
     "• Lower → more formations sooner, from smaller swings.\n" +
     "• The right value follows the timeframe, not the instrument. Read under every " +
     "preset.")

int atrLenInput = input.int(14, "ATR", minval = 1, maxval = 200, group = G_DETECT,
     display = display.none, inline = "d1",
     tooltip = "The lookback for the volatility unit every other tolerance is expressed " +
     "in — the boundary and completion tolerances, and the two angle settings.\n\n" +
     "• Changing this changes what all of them mean at once.\n" +
     "• It does NOT reach `R cap (× daily ATR)`, which reads a fixed 7-bar average of " +
     "true range and does not follow this number.\n" +
     "• Shorter → reacts faster to a volatility change, noisier.\n" +
     "• Longer → steadier, slower to notice a change of character.\n" +
     "• A SIMPLE mean of true range over that many bars. TradingView's own ATR smooths " +
     "with RMA by default, so at the same length this figure is close to it but not " +
     "equal — read the tolerances against this one, not against an ATR pane.")

int   swingUsed    = swingInput
int   poolUsed     = switch presetInput
    PRE_STRICT => 6
    PRE_PERM   => 12
    => 10
int   barsUsed     = switch presetInput
    PRE_STRICT => 200
    PRE_PERM   => 400
    => 300
float tolUsed      = switch presetInput
    PRE_STRICT => 0.10
    PRE_PERM   => 0.45
    => 0.25
float flatUsed     = switch presetInput
    PRE_STRICT => 1.0
    PRE_PERM   => 3.0
    => 1.5
float parallelUsed = switch presetInput
    PRE_STRICT => 8.0
    PRE_PERM   => 22.0
    => 15.0

float  completionUsed   = 0.0
bool   skipRepeatUsed   = true
int    widthUsed        = 1
string styleUsed        = "Glow"
int    fillTranspUsed   = 85
float  labelGapUsed     = 1.25
int    projectUsed      = 20
bool   nearestFillUsed  = true
int    leadReachUsed    = 60

color chanColorInput  = input.color(#31BFA5, "", group = G_CONT, inline = "k1")
bool  showChannelsInput   = input.bool(true, "Channels", group = G_CONT, inline = "k1",
     tooltip = "Two roughly parallel boundaries with price travelling between them — " +
     "rising climbs, falling descends.\n\n" +
     "• This switch and the seven below decide which families are BUILT. Off → the " +
     "family never forms, completes, or alerts.\n" +
     "• That differs from the `Conventional reading` and `Conventional category` filters " +
     "below, which " +
     "only hide drawings.\n" +
     "• The swatch colours both boundaries, so families can be told apart — it marks " +
     "nothing as favourable.")
color flagColorInput  = input.color(#E86FA8, "", group = G_CONT, inline = "k2")
bool  showFlagsInput      = input.bool(true, "Flags", group = G_CONT, inline = "k2",
     tooltip = "A brief, tight pause after a sharp move — two near-parallel boundaries " +
     "drifting back against it.\n\n" +
     "• A flag is set apart from an ordinary channel by the move in front of it and how " +
     "briefly the pause lasts; run the pause too long and it stops being a flag.\n" +
     "• A flag has to clear a prior-move test AND a duration test, which no other family " +
     "does, so it passes on a strict subset of what a channel would. At the shipped " +
     "`Completed formations kept` that can leave none on screen — the tests doing their " +
     "job, not a switch off somewhere.")
color pennColorInput  = input.color(#C2C24E, "", group = G_CONT, inline = "k3")
bool  showPennantsInput   = input.bool(true, "Pennants", group = G_CONT, inline = "k3",
     tooltip = "A flag's brief pause with the boundaries converging instead of parallel " +
     "— a small symmetrical triangle after a sharp move.\n\n" +
     "• The prior move and the duration test tell a pennant from an ordinary symmetrical " +
     "triangle; without them the geometry is just a triangle.\n" +
     "• It clears both of a flag's extra tests as well, on top of converging geometry, so " +
     "it passes on a narrower subset again.")
color triColorInput   = input.color(#4C9BF2, "", group = G_CONT, inline = "k4")
bool  showTrianglesInput  = input.bool(true, "Triangles", group = G_CONT, inline = "k4",
     tooltip = "Two boundaries closing on each other.\n\n" +
     "• Ascending — flat top, rising lows. Descending — flat base, falling highs. " +
     "Symmetrical — both sides moving inward.\n" +
     "• One switch governs all three names; to keep only some, use `Conventional " +
     "category` below " +
     "(ascending/descending are continuation, symmetrical is bilateral).\n" +
     "• Whether a side counts as flat is the `Preset`'s flat tolerance — the same figure " +
     "that separates an ascending triangle from a symmetrical one.")

color rectColorInput  = input.color(#B07CF0, "", group = G_CONT, inline = "k5")
bool  showRectanglesInput = input.bool(true, "Rectangles", group = G_CONT, inline = "k5",
     tooltip = "Two roughly flat boundaries — a high and a low price has returned to more " +
     "than once, both edges anchored to confirmed pivots.\n\n" +
     "• How flat a boundary must be is the `Preset`'s flat tolerance, which separates a " +
     "rectangle from a shallow channel.\n" +
     "• A more permissive preset → more sloping pairs report as rectangles; the two names " +
     "are the same lines seen through different tolerances.")

color wedgeColorInput = input.color(#E8A33D, "", group = G_REV, inline = "k6")
bool  showWedgesInput     = input.bool(true, "Wedges", group = G_REV, inline = "k6",
     tooltip = "Two boundaries sloping the SAME way while closing on each other.\n\n" +
     "• Rising wedge — both angles positive. Falling wedge — both negative. Still " +
     "travelling one way while running out of room.\n" +
     "• That shared direction is the whole distinction from a triangle, where a side is " +
     "flat or the two move oppositely.\n" +
     "• A pair that would not meet within one-and-a-half formation lengths is not named a " +
     "wedge — a wedge is one that meets soon.")
color topsColorInput  = input.color(#DE8A5A, "", group = G_REV, inline = "k7")
bool  showTopsInput       = input.bool(true, "Tops & Bottoms", group = G_REV, inline = "k7",
     tooltip = "Double tops and bottoms — two extremes at about the same price with a " +
     "pullback between them, drawn with the neckline the pullback sets.\n\n" +
     "• From a second detector that matches pivot extremes against each other, not the " +
     "boundary scan the six families above use.\n" +
     "• Completes when a confirmed close finishes through the neckline.\n" +
     "• How near two extremes must be to count as the same price is a fixed ATR tolerance, " +
     "not an exposed setting.")
color hsColorInput    = input.color(#64B5CD, "", group = G_REV, inline = "k8")
bool  showHSInput         = input.bool(true, "Head & Shoulders", group = G_REV, inline = "k8",
     tooltip = "Head & shoulders and its inverse — three extremes where the middle runs " +
     "past the two outside it, and those two sit at about the same price.\n\n" +
     "• The neckline is drawn across the pullbacks either side of the head.\n" +
     "• Same detector and completion as `Tops & Bottoms`: a confirmed close through the " +
     "neckline.\n" +
     "• Where the middle is not clearly beyond its neighbours the set is recorded as a " +
     "double instead — one shape or the other, never both, double tested first.")

string biasInput = input.string(BIAS_ALL, "Conventional reading", group = G_SHOWN,
     options = [BIAS_ALL, BIAS_BULL, BIAS_BEAR, BIAS_NEUT], display = display.none,
     tooltip = "Narrows what is DRAWN to the names the classical literature reads one way, " +
     "on top of the family switches. Both must admit a formation before it appears.\n\n" +
     "• Bullish — falling wedge, ascending triangle, bull flag, double bottom, inverse " +
     "head & shoulders.\n" +
     "• Bearish — rising wedge, descending triangle, bear flag, double top, head & " +
     "shoulders.\n" +
     "• Two-sided — symmetrical triangle, rectangle, pennant, both channels.\n" +
     "• This only HIDES: a filtered formation is still detected, still completes or " +
     "expires, still alerts. It also still counts against `Completed formations kept`, " +
     "and — because it completed at a real level — it can hold back a LATER completion " +
     "of an admitted name that broke the same way at the same level. Combined with " +
     "`Conventional category` below, some pairs share no name and the chart draws " +
     "nothing.\n" +
     "• The grouping is the textbook's, not endorsed here — chart geometry, not a " +
     "forecast.")

string categoryInput = input.string(CAT_ALL, "Conventional category", group = G_SHOWN,
     options = [CAT_ALL, CAT_CONT, CAT_BILAT, CAT_REV], display = display.none,
     tooltip = "Narrows what is drawn by the category the literature files each name under " +
     "— a pause inside a move, a shape that could break either way, or a turn.\n\n" +
     "• Continuation — both flags, the pennant, both channels, ascending and descending " +
     "triangles.\n" +
     "• Bilateral — symmetrical triangle, rectangle.\n" +
     "• Reversal — both wedges, double top and bottom, head & shoulders and its inverse.\n" +
     "• This reaches an individual name, which the family switches cannot: it keeps the " +
     "symmetrical triangle while dropping the other two.\n" +
     "• Applied with the family switch and `Conventional reading`. A family switched ON " +
     "can still draw nothing — `Rectangles` on with `Continuation` is the " +
     "case, since a rectangle is filed as bilateral.\n" +
     "• The grouping is the textbook's, not endorsed here. A hidden formation still forms, " +
     "completes and alerts — and, as under `Conventional reading`, still occupies a kept " +
     "slot and can hold back a later completion at its own level.")

bool showFormingInput = input.bool(false, "Draw formations while they are forming",
     group = G_SHOWN,
     tooltip = "Adds formations named but not yet resolved. Off by default, so a fresh " +
     "chart shows only shapes that have ended.\n\n" +
     "• On → forming boundaries reach the right edge and move with price every bar, which " +
     "on a fast chart can bury the settled ones.\n" +
     "• Off changes only the drawing: every formation is still detected, completes or " +
     "expires, alerts while hidden, and is drawn the moment it ends.\n" +
     "• `Formations drawn`, under Display, governs these and only these.")

int keptInput = input.int(1, "Completed formations kept", minval = 0, maxval = 10,
     group = G_SHOWN,
     display = display.none,
     tooltip = "How many COMPLETED formations stay drawn, dimmed, behind price. Neckline " +
     "patterns count against the same number.\n\n" +
     "• Raise → more kept; a recency window, not a contest — newest kept, oldest dropped " +
     "as each arrives, nothing ranked.\n" +
     "• One exception: a completed formation that was GIVEN levels and has had none of " +
     "them reached holds its place for as long a stretch as it took to build, and a newer " +
     "one arriving inside that stretch is dropped instead. Past it, oldest-first resumes.\n" +
     "• A completion the `% complete` band withheld levels from has none to be unreached, " +
     "so it takes no such hold and is replaced in the ordinary order.\n" +
     "• Flags and pennants clear two tests no other family has, so they pass on a narrow " +
     "subset and may not be in the most recent handful — raise this, or switch other " +
     "families off, if you want to see them.\n" +
     "• Display only. A dropped formation still completed and alerted; 0 draws none.")

int expiredKeptInput = input.int(0, "Expired formations kept", minval = 0, maxval = 10,
     group = G_SHOWN,
     display = display.none,
     tooltip = "How many formations that ended WITHOUT completing stay drawn behind price, " +
     "neckline patterns included. Off by default.\n\n" +
     "• A formation ends two ways: a close finishes beyond a boundary (completes), or a " +
     "bound that defined it runs out (expires).\n" +
     "• It expires by running past where its lines would meet, drifting out of its width " +
     "band, no longer being brief enough for a flag or pennant, or outliving its length.\n" +
     "• Expired ones are drawn faint and dashed (see `Expired formations`), labelled with " +
     "the bound that ended them. Nothing resolved them, so no alert fires.\n" +
     "• Raise → shows the ones that did not complete. 0 draws only completions — the " +
     "default, because expired shapes crowd a fast intraday chart.")

int drawnInput = input.int(2, "Formations drawn", minval = 1, maxval = 9, group = G_DISPLAY,
     display = display.none, active = showFormingInput, inline = "n1",
     tooltip = "How many formations still FORMING may be on screen at once. The script " +
     "tracks nine — six formations and three neckline patterns — and this count spans " +
     "both.\n\n" +
     "• Raise → more forming shapes at once, shading compounds (four translucent bands are " +
     "roughly half-opaque). Lower → fewer shapes, candles stay legible.\n" +
     "• A free place goes to whichever the `By` dropdown beside this setting puts " +
     "first — an ordering by one measurement, never a quality judgement, and never " +
     "shown on the chart.\n" +
     "• One already drawn keeps its place unless another is ten times further ahead on " +
     "that measurement, so the chart is not swapping every bar.\n" +
     "• Needs `Draw formations while they are forming` on. What it hides still forms, " +
     "completes and alerts.")

string drawnByInput = input.string(SEL_NEAR, "by",
     options = [SEL_NEAR, SEL_NEW, SEL_TALL, SEL_LONG],
     group = G_DISPLAY, display = display.none, active = showFormingInput,
     inline = "n1",
     tooltip = "Which measurement decides who gets the places `Formations drawn` hands " +
     "out, when more are forming than there are places.\n\n" +
     "• Nearest — smallest gap between the last close and either boundary or the " +
     "neckline. The shipped setting; keeps drawn shapes near where you are reading.\n" +
     "• Newest — fewest bars since the left edge.\n" +
     "• Tallest — greatest distance between the boundaries, the same height the R unit " +
     "is taken from; keeps the widest shapes.\n" +
     "• Longest — most bars since the left edge.\n" +
     "• Each is a measurement only — never a quality judgement, and none says how a " +
     "formation ended. Changing it changes which are DRAWN; all keep forming, completing " +
     "and alerting.")

color  expiredColorInput = input.color(#8A8F98, "Expired formations", group = G_DISPLAY,
     active = expiredKeptInput > 0,
     tooltip = "Colour for a formation that ended without completing.\n\n" +
     "• An expired formation drops its family colour by design — the family stays on its " +
     "label, and what is worth seeing at a glance is that it ran out.\n" +
     "• Colour and line style separate the three states: forming solid in the family " +
     "colour, completed dotted and dimmer, expired dashed in this colour and dimmer " +
     "again.\n" +
     "• Transparency is fixed by the script rather than by the colour you pick, so an " +
     "expired formation is never brighter than a live one.")

bool   fillInput       = input.bool(true, "Shade the area between the boundaries",
     group = G_DISPLAY,
     tooltip = "Whether the area between the boundaries is shaded. The shade is what " +
     "makes a formation read as one object rather than as two lines.\n\n" +
     "• The shade takes the family colour; a completed formation is shaded fainter than a " +
     "forming one, by the same margin its boundaries dim.\n" +
     "• Only one FORMING formation is shaded at a time — whichever the `By` dropdown " +
     "beside `Formations drawn` puts first among the regular families — because " +
     "shading is the part that covers the " +
     "candles. A neckline pattern has no second line to fill against and is never " +
     "shaded.\n" +
     "• One further exception: a formation whose band would fully enclose another is not " +
     "shaded, so it cannot hide the shapes inside it. Its boundaries and name still draw.")

string labelModeInput  = input.string(LBL_FULL, "Formation names",
     options = [LBL_OFF, LBL_MARKER, LBL_NAME, LBL_FULL],
     display = display.none, group = G_DISPLAY, inline = "l1",
     tooltip = "How much of a formation's name is written on the chart, from nothing up to " +
     "the full classical reading.\n\n" +
     "• Off — no label. The shape is still detected, completes and alerts.\n" +
     "• Marker — a dot in the family colour; the name waits on its hover text.\n" +
     "• Name — the shape's name alone, e.g. Ascending Triangle.\n" +
     "• Name + reading — the name plus the direction and category the classical " +
     "literature attaches, worded as the convention's reading, not this script's.\n" +
     "• Every mode's hover text names which boundary a completed formation closed beyond, " +
     "so nothing is exclusive to the wordier modes.")

string labelPlaceInput = input.string(LBL_COL, "",
     options = [LBL_AT, LBL_COL],
     display = display.none, group = G_DISPLAY, inline = "l1",
     tooltip = "Whether the text sits on the shapes themselves or in one column clear of " +
     "the drawings — it settles what happens when two labels want the same place.\n\n" +
     "• It governs the LEVEL labels as well as the formation names: a level label whose " +
     "own line reaches the column joins it, so one setting does not split the chart " +
     "between two conventions. A level line too short to reach keeps its label where the " +
     "line ends.\n" +
     "• Under `Formation names` = `Marker` the names are dots on their shapes and have no " +
     "column to sit in, so this governs the level labels alone. It is not greyed there, " +
     "because a greyed control that is still placing something is worse than one left " +
     "live with nothing to place.\n" +
     "• On the shape — drawn on the boundary it belongs to, nudged clear of any name " +
     "already there. Two at a similar price can still overlap, since the separation " +
     "compares only names sharing a chart column and moves them in price, not pixels.\n" +
     "• Right column — every name placed the same distance past the drawings, with a " +
     "leader line back to its formation. Sharing one column makes the comparison exact, " +
     "so no name is skipped — but the gap it opens is in price, like the one above, and " +
     "a chart squeezed far enough vertically can still bring two together.")

bool hoverNotesInput = input.bool(true, "Hover notes", group = G_DISPLAY,
     tooltip = "Whether the chart's drawings carry the explanatory text that appears when " +
     "the cursor rests on them.\n\n" +
     "• On (default) — a formation's name, its conventional reading, how it completed or " +
     "why it ended, and what each level is.\n" +
     "• Off — the same drawings without the hover. No level, mark or alert changes.\n" +
     "• One exception, and it is the arrow. A projection arrow is the graphic form of a " +
     "formation's attributed reading, so it is drawn only where that attribution is " +
     "readable. While a formation is forming, that is the label with `Formation names` " +
     "set to `Name + reading`, or the hover — switch both off and its arrow goes. Once " +
     "it completes, the label states its name and which side it closed beyond and not " +
     "the reading, so the hover is the only place left: hovers off takes a completed " +
     "formation's arrow and its leg with them whatever `Formation names` is set to. " +
     "`Projection arrows and legs` says the same thing from its own side.\n" +
     "• The levels keep one line either way, naming them as your own geometry, not a " +
     "measured outcome. That line is part of what the drawing states, so it has no off " +
     "switch.\n" +
     "• The levels table follows too, but its note is disclosure, so it moves rather than " +
     "leaves: off, it comes off the value cells and stays on the field names and " +
     "formation names — every figure keeps it one hover away.")

bool projArrowInput = input.bool(true, "Projection arrows and legs", group = G_DISPLAY,
     tooltip = "Adds two drawings that show where a formation's geometry came from and " +
     "which way the classical literature reads it.\n\n" +
     "• The leg — a dotted line across the prior move measured to promote a channel to a " +
     "flag, or a symmetrical triangle to a pennant.\n" +
     "• The arrow — one R tall, pointing the attributed reading (`Conventionally " +
     "Bullish/Bearish`). That reading follows the shape's name, not the close, so it " +
     "never flips; a two-sided family shows none.\n" +
     "• Drawn only where that wording is reachable elsewhere. While forming: the label " +
     "under `Name + reading`, or the hover with `Hover notes` on. Once completed: the " +
     "hover alone, because a completed label names the shape and the side it closed " +
     "beyond, not the reading. With none of those, no arrow.\n" +
     "• An expired formation draws neither surface.\n" +
     "• The direction is the textbook's, not endorsed here — chart geometry, not a " +
     "forecast.\n" +
     "• Arrow and leg are the formation's own geometry and describe no measured " +
     "outcome.\n\n" + R_CAP_NOTE)

bool showLevelsInput = input.bool(true, "Show entry and exit levels", group = G_TRADE,
     tooltip = "Adds Entry, Target and Stop to a completed formation, drawn on the " +
     "completing bar and frozen there. `Target levels` below stacks up to three tiers, so " +
     "a formation carries three to five levels.\n\n" +
     "• Entry — the close that completed the formation. An observed price.\n" +
     "• R — the formation's height at its left edge, the unit the other two use. Fixed at " +
     "the shape's start: a channel or rectangle may widen up to 1.5x further right without " +
     "R following.\n" +
     "• Target — your multiple of R, placed the way the closing bar went.\n" +
     "• Stop — your multiple of R, placed against it.\n" +
     "• Arithmetic on the shape and your own numbers: nothing is fitted, optimised or read " +
     "off past outcomes.\n" +
     "• Every completion gets them until you say otherwise. `Gate levels on % Complete` " +
     "below opens a band on how far a formation had run when it broke, and a completion " +
     "outside that band is drawn, named and tabled with its level rows dashed.\n" +
     "• An expired formation draws none.\n" +
     "• Switching this off removes the levels everywhere at once — the drawings, the " +
     "table's level rows, and the prices in the alert message. Every setting below it " +
     "greys out and stops governing anything, with one exception it names in its own " +
     "tooltip: `R cap (× daily ATR)` stays live, because a projection arrow is one R long " +
     "whether or not any level is drawn.\n" +
     "• User-configured geometry projected from the formation's own height. It measures " +
     "nothing about outcomes and describes no expected result.\n\n" +
     R_CAP_NOTE)
bool pctGateOnInput = input.bool(false, "Gate levels on % Complete", group = G_TRADE,
     active = showLevelsInput, display = display.none,
     tooltip = "Off by default. While it is off every completion is given Entry, Target " +
     "and Stop, which is how every build before this setting behaved.\n\n" +
     "• Switched on, a completion is given levels only when its `% Complete` falls inside " +
     "the band below, and the two figures stop being greyed out.\n" +
     "• Outside the band the formation is still detected, named, tabled and alerted; it " +
     "is given no levels and its alert carries no prices.\n" +
     "• `% Complete` is elapsed bars, not quality: a higher figure is an older formation " +
     "rather than a better one. This gate selects on age and on nothing else.\n" +
     "• A bar count compared against a figure you set. It measures no outcome and " +
     "describes no expected result.")
int levelGateInput = input.int(80, "between", minval = 0,
     maxval = 100, step = 5, group = G_TRADE, inline = "g1",
     active = showLevelsInput and pctGateOnInput, display = display.none)
int levelCapInput = input.int(100, "and", minval = 0, maxval = 100, step = 5,
     group = G_TRADE, inline = "g1",
     active = showLevelsInput and pctGateOnInput, display = display.none,
     tooltip = "The band of `% Complete` inside which a completion is given Entry, " +
     "Target and Stop, once `Gate levels on % Complete` above is switched on. Outside " +
     "it the formation is still detected, named, tabled and alerted; it is given no " +
     "levels and its alert carries no prices.\n\n" +
     "• `% Complete` is how far through its own span a formation had run at the bar " +
     "it completed on - for a triangle or a wedge, how far along the base-to-apex " +
     "distance the completing bar sits; for the rest, how much of the shape's " +
     "allotted life it had used. The panel reports it per formation.\n" +
     "• The band is inclusive at both ends, and it reads the SAME figure the panel " +
     "prints: a row showing 50% is inside a band that opens at 50, because both are " +
     "the rounded percentage and not the raw fraction behind it.\n" +
     "• The two figures are read as a range. Entering the larger one first gives the " +
     "same band, not an empty one.\n" +
     "• At 0 the low end withholds nothing; at 100 the high end withholds nothing, " +
     "and 0 to 100 withholds nothing at all - the same behaviour as leaving the " +
     "switch above off.\n" +
     "• Narrow the band → fewer completions carry levels.\n" +
     "• It reaches one thing besides the levels. A completion the band withheld levels " +
     "from cannot suppress a later completion of the same move, because the rule that " +
     "does that measures against the earlier one's Stop and it has none. So moving " +
     "either end can change which formations are KEPT, not only which carry levels.\n" +
     "• It ships at 80 to 100, greyed and governing nothing until the switch above is " +
     "on; a completion then has to have used at least 80% of its own span to be given " +
     "levels. A chart of named formations with a dash down every level row is this " +
     "setting, not a fault - lower the low end toward 50 to widen what is given " +
     "levels. The README says where the two figures come from.\n" +
     "• It is drawn like any other completion and kept for as long as `Completed " +
     "formations kept` allows — but it does NOT get the hold an unreached completion " +
     "gets, because it has no levels to be unreached, so a newer completion can take " +
     "its place straight away.\n" +
     "• Two figures you set, applied to bar counts read off the chart. They measure " +
     "no outcome and describe no expected result.")

int targetTiersInput = input.int(3, "Target levels", minval = 1, maxval = 3,
     group = G_TRADE, active = showLevelsInput, display = display.none,
     tooltip = "How many Target zones a completed formation is given, stacked outward " +
     "from Entry.\n\n" +
     "• 1 — one Target zone, labelled `Target`.\n" +
     "• 2 or 3 — labels read `T1`, `T2`, `T3`, each band starting where the one before it " +
     "ended. A tier set nearer than the one before draws where you set it and overlaps, " +
     "never reordered.\n" +
     "• Each is your own multiple of the formation's height. Raise → more geometry you " +
     "configured; it measures nothing and says nothing about which a bar will trade to.\n" +
     "• Each band and label is marked on its own when a bar reaches it.\n" +
     "• The highest-NUMBERED enabled level closes the question with the Stop — by number, " +
     "not distance. Once it or the Stop is reached, every band stops extending.\n\n" +
     R_CAP_NOTE)
float targetRInput = input.float(0.25, "Target 1 (R)", minval = 0.05, maxval = 10.0,
     step = 0.05, group = G_TRADE, active = showLevelsInput, display = display.none,
     tooltip = "How far the first Target zone sits from Entry, in R.\n\n" +
     "• Because R scales with the shape, the same setting sits proportionally further out " +
     "on a large formation than on a small one.\n" +
     "• The label carries this figure back, naming itself as your setting; at `Target " +
     "levels` 1 it just reads `Target`.\n" +
     "• A higher figure puts the zone further from Entry, a lower one nearer. Where it " +
     "sits is all this changes.\n" +
     "• User-set geometry, not a measured outcome.\n\n" + R_CAP_NOTE)
float targetR2Input = input.float(0.5, "Target 2 (R)", minval = 0.05, maxval = 20.0,
     step = 0.05, group = G_TRADE, display = display.none,
     active = showLevelsInput and targetTiersInput >= 2,
     tooltip = "How far the second Target zone sits from Entry, in R, like the first.\n\n" +
     "• Its band starts where the first ended, so the two read as a ladder.\n" +
     "• Needs `Target levels` at 2 or more; below that it is not drawn or created.\n" +
     "• A higher figure puts it further out. Nothing requires it beyond the first: a " +
     "nearer figure draws nearer, and the label carries its own multiple either way.\n" +
     "• User-set geometry, not a measured outcome.\n\n" + R_CAP_NOTE)
float targetR3Input = input.float(1.0, "Target 3 (R)", minval = 0.05, maxval = 30.0,
     step = 0.05, group = G_TRADE, display = display.none,
     active = showLevelsInput and targetTiersInput >= 3,
     tooltip = "How far the third Target zone sits from Entry, in R, like the other two.\n\n" +
     "• Its band starts where the second ended. Needs `Target levels` at 3.\n" +
     "• With three enabled this closes the question with the Stop — as the highest-" +
     "numbered tier, whether or not set furthest out. Once a bar reaches it or the Stop, " +
     "every band stops extending.\n" +
     "• A higher figure sits further from Entry, a lower one nearer.\n" +
     "• User-set geometry, not a measured outcome.\n\n" + R_CAP_NOTE)
bool stopStructInput = input.bool(true, "Stop at structure", group = G_TRADE,
     active = showLevelsInput, display = display.none,
     tooltip = "An alternative basis for the Stop: the formation's own " +
     "invalidation structure, instead of a fixed distance from Entry.\n\n" +
     "• Off: `Stop (R)` below places the Stop a fixed distance from Entry.\n" +
     "• On (default): the Stop sits at the formation's opposite boundary read at the " +
     "completing bar — the far side of a channel, wedge or triangle — or, on a " +
     "neckline pattern, at the far peak or trough it is built on. That is the level " +
     "a return would have to carry price back through.\n" +
     "• On, this overrides `Stop (R)`, which greys out; the Targets are " +
     "unchanged.\n" +
     "• The distance then follows the shape's own width — a wider shape gives a " +
     "farther Stop — but is floored at 0.5R, so a very narrow shape does not place " +
     "the Stop nearer than that.\n" +
     "• There is a floor and no ceiling, so the distance can run to several R — " +
     "the Targets are multiples of R and the Stop is not, and where the R cap is " +
     "binding the two are measured off different things. The label and the table " +
     "therefore print the Stop's OWN distance in R beside it, as `structure · " +
     "4.8R`, so the two sides of the trade can be read against each other " +
     "without arithmetic.\n" +
     "• The label and table name the Stop as `structure` while this is on.\n" +
     "• User-set geometry, not a measured outcome.")
float stopRInput = input.float(0.3, "Stop (R)", minval = 0.1, maxval = 10.0,
     step = 0.1, group = G_TRADE, display = display.none,
     active = showLevelsInput and not stopStructInput,
     tooltip = "How far the Stop zone sits from Entry, in R, on the opposite side to the " +
     "Targets.\n\n" +
     "• The ratio between the two settings shows on the chart as the relative size of the " +
     "two zones.\n" +
     "• The label carries this figure back, naming itself as your setting.\n" +
     "• A higher figure sits further from Entry — below on an upward formation, above on " +
     "a downward one — and a lower one nearer.\n" +
     "• User-set geometry, not a measured outcome.\n\n" + R_CAP_NOTE)
float rCapMultInput = input.float(1.0, "R cap (× daily ATR)", minval = 0.0, maxval = 10.0,
     step = 0.25, group = G_TRADE,
     active = showLevelsInput or (projArrowInput and labelModeInput != LBL_OFF and
     (hoverNotesInput or (showFormingInput and labelModeInput == LBL_FULL))),
     display = display.none,
     tooltip = "The ceiling on R, as a multiple of the average true range of the last 7 " +
     "daily bars (true range counts the gap from the prior close).\n\n" +
     "• R is the formation's height. Where the height exceeds this multiple of the daily " +
     "range, the multiple is used instead and every level measured in R moves in with " +
     "it. A ceiling only: a shorter formation keeps its own height, and at 0 the cap " +
     "is off. A structure Stop is measured off the shape's own boundary rather than in " +
     "R, so the cap reaches it only through its 0.5R floor.\n" +
     "• Lower → the cap binds more often; raise → the shape's own height rules more often. " +
     "The lower your chart timeframe, the more it binds, since the cap is daily and the " +
     "height is in chart-timeframe terms. When it binds, different heights show the same " +
     "distance to Target.\n" +
     "• On a weekly or monthly chart the daily figure is requested exactly as it always " +
     "is and then discarded, being no lower than the chart; the cap reads your chart's " +
     "own last 7 bars instead — 7 weeks or 7 months.\n" +
     "• A brand-new listing without 7 completed daily bars yet has nothing to cap against, " +
     "so R runs uncapped at the formation's height until it does.\n" +
     "• It also sets the length of a `Projection arrows and legs` arrow, which is one R " +
     "long. That is why this stays live with `Show entry and exit levels` off — it is the " +
     "one setting here that still governs something. It greys out only when neither is " +
     "left: levels off, and no arrow drawable because the attributed reading is " +
     "unreachable with `Formation names` and `Hover notes` both off.\n" +
     "• User-set geometry, not a measured outcome.")
bool levelPriceInput = input.bool(true, "Show prices on level labels",
     group = G_TRADE, active = showLevelsInput, display = display.none,
     tooltip = "Adds each level's own price to its label, rounded to the instrument's " +
     "tick.\n\n" +
     "• Entry — the close that completed the formation, restated where the level is.\n" +
     "• Target and Stop — the price your R multiple puts each at, on the formation's " +
     "height.\n" +
     "• Rounded to the tick, so a projected level reads as a quotable price.\n" +
     "• Off → narrower labels. Under `On the shape` placement they sit over the candles, " +
     "so turn this off when they crowd.\n" +
     "• Every figure is read off the chart or a setting you made. None says a bar will " +
     "trade there.")

string CLOSE_KEEP  = "Keep"
string CLOSE_CLEAR = "Clear"
string onCloseInput = input.string(CLOSE_CLEAR, "Once a level is reached",
     options = [CLOSE_KEEP, CLOSE_CLEAR], group = G_TRADE,
     active = showLevelsInput, display = display.none,
     tooltip = "What happens to a formation's levels once a confirmed bar has reached one " +
     "of them.\n\n" +
     "• Keep — a reached level keeps its band and label, the label marked · Reached; " +
     "everything else stays.\n" +
     "• Clear (default) — a reached target's band and label come off; when the question " +
     "closes, the rest goes with it (entry, remaining bands, stop, labels, leaders), so a " +
     "crowded chart gets its space back.\n" +
     "• Applies level by level: an inner target reached while the question is open clears " +
     "on its own; outer targets and the stop stay until reached or the question closes.\n" +
     "• The set clears on the question closing, whichever level closed it — an absence " +
     "says a formation is finished with, nothing about how it turned out.\n" +
     "• The levels table keeps which levels a bar reached, so clearing loses nothing. " +
     "`Show levels table` is where to read it.")

string LEVELS_NEWEST = "Newest only"
string LEVELS_ALL    = "All"
string levelsForInput = input.string(LEVELS_NEWEST, "Levels drawn for",
     options = [LEVELS_NEWEST, LEVELS_ALL], group = G_TRADE,
     active = showLevelsInput, display = display.none,
     tooltip = "Which completed formations carry entry, target and stop levels on the " +
     "chart.\n\n" +
     "• Newest only (default) — the most recent completion that is CARRYING levels: one " +
     "inside the `% Complete` band, of a name the filters admit. An older formation keeps " +
     "its shape, name and reading; its levels come off. A newer completion OUTSIDE the " +
     "band takes nothing from it — it has no levels to take.\n" +
     "• All — every retained completed formation carries its own set, which on a long pool " +
     "is many lines and bands at once.\n" +
     "• Newest is by completion bar and nothing else — no formation displaces another for " +
     "being taller, nearer or of a kind.\n" +
     "• Levels coming off says a newer formation completed, nothing about how the older " +
     "turned out — that is in the levels table, which keeps every row.")

string unreachedInput = input.string(UNREACH_REMOVE, "If a level is not reached",
     options = [UNREACH_REMOVE, UNREACH_FADE], group = G_TRADE, active = showLevelsInput,
     display = display.none,
     tooltip = "What becomes of a level no bar reached, once the question is closed by " +
     "another. A zone extends until a bar reaches it; an unreached one extends until the " +
     "question closes.\n\n" +
     "• Remove it (default) — the unreached zone and label go, leaving the levels a bar " +
     "traded to (those under `Once a level is reached`). Two zones ending on one bar would " +
     "otherwise read as a pair settled together.\n" +
     "• Fade it — both stay, the unreached one dimmed, so the original geometry stays " +
     "visible beside the answer.\n" +
     "• Neither says the unreached level failed. No mark means only that no confirmed bar " +
     "traded to it, and nothing here is counted or compared.")

color targetColorInput = input.color(#8C66FF, "Target zone", group = G_TRADE,
     active = showLevelsInput,
     tooltip = "Colour for the zone placed on the side the completing close went, and for " +
     "its label.\n\n" +
     "• A colour for one of the two sides, not a verdict on either.\n" +
     "• Where the zone sits was decided by `Target 1/2/3 (R)` and by the formation's own " +
     "height; nothing about the colour says a bar will trade to it.")
color stopColorInput   = input.color(#D9453D, "Stop zone", group = G_TRADE,
     active = showLevelsInput,
     tooltip = "Colour for the zone placed against the side the completing close went, and " +
     "for its label.\n\n" +
     "• These two are the only non-family colours in the script — everywhere else a " +
     "colour names a family and carries no direction.\n" +
     "• Here they name which side of Entry each level was configured onto. That is all the " +
     "colour says.\n" +
     "• Both zones are user-configured geometry from the formation's own height; neither " +
     "describes a measured outcome, and no colour asserts a level will be reached.")

bool sizingInput = input.bool(false, "Show position size", group = G_TRADE,
     active = showLevelsInput,
     tooltip = "Whether the levels table and stop label state how many whole units your " +
     "risk budget covers at the stop this formation drew.\n\n" +
     "• The calculation: your budget ÷ the Entry-to-Stop distance ÷ what the exchange says " +
     "one point is worth. Rounded DOWN, so the figure never exceeds your budget.\n" +
     "• Every input is yours or the exchange's — nothing is measured from what price did " +
     "after completion, and nothing is a forecast.\n" +
     "• A dash means unanswerable (no budget, a stop on the entry price, or a point value " +
     "the feed lacks) — not a size of zero. A `0` is an answer: one unit already costs " +
     "more than your budget.\n" +
     "• The budget is assumed in the instrument's own currency; this script converts none " +
     "and holds no exchange rate.\n" +
     "• Sizes are never summed, counted or compared across formations, and none is drawn " +
     "on or beside a formation.")

string riskBasisInput = input.string(RISK_AMOUNT, "Risk budget", group = G_TRADE,
     options = [RISK_AMOUNT, RISK_PERCENT], active = sizingInput and showLevelsInput,
     display = display.none,
     tooltip = "Which of the two figures below is used.\n\n" +
     "• Amount — a flat budget, the same on every setup. Set in `Amount per setup`.\n" +
     "• Percent — the budget moves with the account you enter; needs `Account size` and " +
     "`Percent per setup`.\n" +
     "• Whichever is not selected greys out and is not read.")

float riskAmtInput = input.float(0.0, "Amount per setup", minval = 0.0, step = 50.0,
     group = G_TRADE, display = display.none,
     active = sizingInput and showLevelsInput and riskBasisInput == RISK_AMOUNT,
     tooltip = "What you are willing to have at risk on one setup, in the instrument's own " +
     "currency.\n\n" +
     "• At 0 (the shipped default) nothing is sized and every size cell shows a dash — the " +
     "script must not invent a budget for you.\n" +
     "• A ceiling, not a target: rounding down usually leaves some unused, so the size " +
     "cell states BOTH — what the whole units actually carry, and the figure you typed. " +
     "`2 · 480 of 700 USD · (12.00 × 20)` is two units carrying 480 of a 700 " +
     "budget, on a 12.00 stop at 20 a point.\n" +
     "• Where the budget does not cover one whole unit the size is zero, and the cell " +
     "names what one would have cost instead of leaving a bare 0: `0 · one unit needs " +
     "13390 USD · budget 700 · (669.50 × 20)`.")

float accountInput = input.float(0.0, "Account size", minval = 0.0, step = 1000.0,
     group = G_TRADE, display = display.none,
     active = sizingInput and showLevelsInput and riskBasisInput == RISK_PERCENT,
     tooltip = "The account the percentage below is taken from, in the instrument's own " +
     "currency.\n\n" +
     "• At 0 nothing is sized and every size cell shows a dash.\n" +
     "• Read on the bar it is used and written nowhere. One caveat: under `Alert detail = " +
     "Full` or `JSON` the message's size line prints the budget alongside what the " +
     "position carries, and at a percent that budget is the account divided back out. " +
     "`Brief` (default) carries no figures.")

float riskPctInput = input.float(1.0, "Percent per setup", minval = 0.0, maxval = 100.0,
     step = 0.05, group = G_TRADE, display = display.none,
     active = sizingInput and showLevelsInput and riskBasisInput == RISK_PERCENT,
     tooltip = "What share of the account size above one setup may risk.\n\n" +
     "• The step is a twentieth of a percent, so a fractional limit goes in exactly.\n" +
     "• At 0 nothing is sized and every size cell shows a dash.\n" +
     "• Your figure, and this script has no opinion about it — nothing recommends a " +
     "percentage or reacts to the one you set.")

bool showTableInput = input.bool(true, "Show levels table", group = G_TRADE,
     active = showLevelsInput,
     tooltip = "A legend of the completed formations the script is carrying, one column " +
     "each.\n\n" +
     "• Every price is the same frozen figure its label carries, read from the same field " +
     "— the table cannot disagree with the chart.\n" +
     "• Columns are in completion order, oldest first — time order and nothing else.\n" +
     "• A column outlives its LEVELS: `Once a level is reached` and `Levels drawn for` " +
     "delete level objects while the column stays, so `Reached` still names whichever " +
     "level closed the question. A row does not outlive the formation — hiding its kind, " +
     "the platform's drawing-reach limit each takes the row too.\n" +
     "• `Reached` names levels, never counts them — no tally, rate, or figure comparing " +
     "one formation with another.\n" +
     "• Follows `Show entry and exit levels`: with levels off, nothing to list.")
string tablePosInput = input.string(TBL_TR, "Table position and size", group = G_TRADE,
     options = [TBL_TL, TBL_TC, TBL_TR, TBL_ML, TBL_MC, TBL_MR,
     TBL_BL, TBL_BC, TBL_BR], inline = "t1",
     active = showTableInput and showLevelsInput, display = display.none)
string tableSizeInput = input.string(TBL_SZ_SMALL, "", group = G_TRADE,
     options = [TBL_SZ_TINY, TBL_SZ_SMALL, TBL_SZ_NORMAL, TBL_SZ_LARGE],
     active = showTableInput and showLevelsInput, display = display.none,
     inline = "t1", tooltip = "Where the table sits and how large its text is. " +
     "Neither changes anything the table says.")

string alertDetailInput = input.string(ALERT_BRIEF, "Alert detail", group = G_ALERT,
     options = [ALERT_BRIEF, ALERT_FULL, ALERT_JSON], display = display.none,
     tooltip = "How much an alert message says. It changes nothing on the chart and " +
     "nothing about WHEN an alert fires.\n\n" +
     "• Brief (default) — the formation, symbol, timeframe and what happened.\n" +
     "• Full — that first line, then Entry, Stop and each enabled Target, plus the size " +
     "line when `Show position size` is on.\n" +
     "• JSON — the same fields as keys, for a journal or webhook that parses them.\n" +
     "• No buy, sell, order, action or signal field in any of the three, and there will " +
     "not be one. The message names a formation and the prices you configured off it — " +
     "what to do is not this script's to say.\n" +
     "• Prices appear only once a formation has completed; an admission alert carries no " +
     "levels, since none exist yet.")

stopBasisMult() => stopRInput
stopBasisUnit() => "R"
stopBasisText() => stopStructInput ? "structure" :
     str.tostring(stopBasisMult(), "0.0#") + stopBasisUnit()

levelNote() =>
    hoverNotesInput ? LEVEL_NOTE : LEVEL_NOTE_MIN

dataNote() =>
    hoverNotesInput ? TBL_NOTE : ""

riskBudgetOf() =>
    float out = na
    if sizingInput
        if riskBasisInput == RISK_PERCENT
            if accountInput > 0 and riskPctInput > 0
                out := accountInput * riskPctInput / 100.0
        else
            if riskAmtInput > 0
                out := riskAmtInput
    out

stopDistance(float entryP, float stopP) =>
    float d  = math.abs(entryP - stopP)
    float mt = syminfo.mintick
    na(mt) or mt <= 0 ? d : math.round(d / mt) * mt

sizeUnits(float entryP, float stopP, float budget) =>
    int out = na
    if not na(entryP) and not na(stopP) and not na(budget) and budget > 0
        float dist = stopDistance(entryP, stopP)
        float pv   = syminfo.pointvalue
        if dist > 0 and not na(pv) and pv > 0
            out := math.floor(budget / (dist * pv))
    out

sizeText(float entryP, float stopP) =>
    float budget = riskBudgetOf()
    int   units  = sizeUnits(entryP, stopP, budget)
    string out = "—"
    if not na(units)
        float dist    = stopDistance(entryP, stopP)
        float perUnit = dist * syminfo.pointvalue
        float carried = units * perUnit
        string head = units == 0 ?
             "0 · one unit needs " + str.tostring(perUnit, "#.##") + " " +
             syminfo.currency + " · budget " + str.tostring(budget, "#.##") :
             str.tostring(units) + " · " + str.tostring(carried, "#.##") +
             " of " + str.tostring(budget, "#.##") + " " + syminfo.currency
        out := head + " · (" + str.tostring(dist, format.mintick) + " × " +
             str.tostring(syminfo.pointvalue, "#.##") + ")"
    out

riskCellNote() =>
    dataNote() == "" ? RISK_NOTE : RISK_NOTE + "\n" + dataNote()

stopNote(float entryP, float stopP) =>
    string out = levelNote()
    if sizingInput
        out := "At your risk: " + sizeText(entryP, stopP) + "\n" + RISK_NOTE +
             "\n" + levelNote()
    out

alertText(string kind, string noun, string event, bool hasLevels,
     float entryP, float t1P, float t2P, float t3P, float stopP) =>
    string head = kind + noun + " on " + syminfo.ticker + " " +
         timeframe.period + " - " + event
    string out = head
    if alertDetailInput != ALERT_BRIEF
        string sizeLine = hasLevels and sizingInput ?
             sizeText(entryP, stopP) : ""
        if alertDetailInput == ALERT_JSON
            out := '{"formation":"' + kind + '","event":"' + event +
                 '","symbol":"' + syminfo.ticker + '","timeframe":"' +
                 timeframe.period + '"'
            if hasLevels
                out := out + ',"entry":' + str.tostring(entryP, format.mintick) +
                     ',"stop":' + str.tostring(stopP, format.mintick) +
                     (stopStructInput ? ',"stop_basis":"structure"' :
                         ',"stop_r":' + str.tostring(stopRInput, "#.##")) +
                     ',"t1":' + str.tostring(t1P, format.mintick) +
                     ',"t1_r":' + str.tostring(targetRInput, "#.##")
                if targetTiersInput >= 2
                    out := out + ',"t2":' + str.tostring(t2P, format.mintick) +
                         ',"t2_r":' + str.tostring(targetR2Input, "#.##")
                if targetTiersInput >= 3
                    out := out + ',"t3":' + str.tostring(t3P, format.mintick) +
                         ',"t3_r":' + str.tostring(targetR3Input, "#.##")
                if sizeLine != ""
                    out := out + ',"size":"' + sizeLine + '"'
                out := out + ',"levels_note":"' + LEVEL_NOTE_MIN + '"'
            out := out + ',"note":"' + ALERT_NOTE + '"}'
        else
            if hasLevels
                out := out + "\nEntry " + str.tostring(entryP, format.mintick) +
                     " · T1 " + str.tostring(t1P, format.mintick) + " (" +
                     str.tostring(targetRInput, "#.##") + "R)"
                if targetTiersInput >= 2
                    out := out + " · T2 " + str.tostring(t2P, format.mintick) +
                         " (" + str.tostring(targetR2Input, "#.##") + "R)"
                if targetTiersInput >= 3
                    out := out + " · T3 " + str.tostring(t3P, format.mintick) +
                         " (" + str.tostring(targetR3Input, "#.##") + "R)"
                out := out + " · Stop " + str.tostring(stopP, format.mintick) +
                     " (" + (stopStructInput ? "structure" :
                         str.tostring(stopBasisMult(), "#.##") + stopBasisUnit()) + ")"
                if sizeLine != ""
                    out := out + "\nAt your risk: " + sizeLine
                out := out + "\n" + LEVEL_NOTE_MIN
            out := out + "\n" + ALERT_NOTE
    out

// ======================== Types ==============================================

type Pivot
    int   bar
    float price

type Boundary
    int   b1
    float p1
    int   b2
    float p2
    bool  isHigh

type Formation
    string   kind
    Boundary upper
    Boundary lower
    int      startBar
    int      apexBar
    int      state
    int      limitBar = -1
    bool     armed = false
    int      completedBar
    int      side
    string   expiredWhy = ""
    line     upLine
    line     loLine
    linefill band
    label    tag
    line     upGlowOut
    line     upGlowIn
    line     loGlowOut
    line     loGlowIn
    line     leader
    line     arrow
    line     leg
    float    legP1     = 0.0
    float    legP2     = 0.0
    float    doneClose = 0.0
    float    doneCap   = 0.0
    int      doneTime  = 0
    float    targetP  = 0.0
    float    stopP    = 0.0
    int      hitBar   = -1
    int      hitWhich = 0
    float    targetP2 = 0.0
    float    targetP3 = 0.0
    int      hit1Bar  = -1
    int      hit2Bar  = -1
    int      hit3Bar  = -1
    int      hit1Time = 0
    int      hit2Time = 0
    int      hit3Time = 0
    int      stopTime = 0
    line     entryLn
    line     entryGlowOut
    line     entryGlowIn
    box      targetZone
    box      targetZone2
    box      targetZone3
    box      stopZone
    label    entryTag
    label    targetTag
    label    targetTag2
    label    targetTag3
    label    stopTag
    line     entryLead
    line     targetLead
    line     targetLead2
    line     targetLead3
    line     stopLead
    bool     encloses = false
    bool     nested   = false
    bool     drawn    = false

type NeckFormation
    string   kind
    int      e1Bar
    float    e1P
    int      e2Bar
    float    e2P
    int      e3Bar = -1
    float    e3P   = 0.0
    Boundary neck
    int      startBar
    int      state
    int      completedBar
    int      side
    int      limitBar = -1
    bool     armed = false
    string   expiredWhy = ""
    float    legP1  = 0.0
    bool     hasLeg = false
    float    doneClose = 0.0
    float    doneCap   = 0.0
    int      doneTime  = 0
    float    targetP  = 0.0
    float    stopP    = 0.0
    int      hitBar   = -1
    int      hitWhich = 0
    float    targetP2 = 0.0
    float    targetP3 = 0.0
    int      hit1Bar  = -1
    int      hit2Bar  = -1
    int      hit3Bar  = -1
    int      hit1Time = 0
    int      hit2Time = 0
    int      hit3Time = 0
    int      stopTime = 0
    bool     drawn    = false
    polyline outline
    line     neckLn
    line     leader
    line     arrow
    line     leg
    line     entryLn
    line     entryGlowOut
    line     entryGlowIn
    box      targetZone
    box      targetZone2
    box      targetZone3
    box      stopZone
    label    tag
    label    entryTag
    label    targetTag
    label    targetTag2
    label    targetTag3
    label    stopTag
    line     entryLead
    line     targetLead
    line     targetLead2
    line     targetLead3
    line     stopLead

type PairKey
    int ub1
    int ub2
    int lb1
    int lb2

type LevelRow
    int    bar     = 0
    string name    = ""
    string reading = ""
    int    side    = 0
    int    doneAt  = 0
    int    h1      = -1
    int    h2      = -1
    int    h3      = -1
    int    which   = 0
    int    h1At    = 0
    int    h2At    = 0
    int    h3At    = 0
    int    stopAt  = 0
    float  entry   = 0.0
    float  t1      = 0.0
    float  t2      = 0.0
    float  t3      = 0.0
    float  stop    = 0.0
    float  rUnit   = 0.0
    float  pctDone
    bool   armed = false


// ======================== Functions ==========================================

priceAt(Boundary bd, int b) =>
    bd.p1 + (bd.p2 - bd.p1) / (bd.b2 - bd.b1) * (b - bd.b1)

pctComplete(int startBar, int limitBar, int atBar) =>
    int   endBar = math.min(limitBar, startBar + barsUsed)
    int   total  = endBar - startBar
    float pct    = na
    if total > 0
        pct := math.min(1.0, math.max(0.0, (atBar - startBar) / (1.0 * total)))
    pct

pctShown(float pct) =>
    float shown = na(pct) ? na : pct >= 1.0 ? 100.0 :
         math.min(99.0, math.round(100 * pct))
    shown

pctText(float pct) =>
    float shown = pctShown(pct)
    na(shown) ? "—" : str.tostring(shown, "0") + "%"

levelsArmed(float pct) =>
    float shown = pctShown(pct)
    int   band1 = math.min(levelGateInput, levelCapInput)
    int   band2 = math.max(levelGateInput, levelCapInput)
    bool  lo    = band1 <= 0 or (not na(shown) and shown >= band1)
    bool  hi    = band2 >= 100 or (not na(shown) and shown <= band2)
    bool  armed = not pctGateOnInput or (lo and hi)
    armed

slopePerBar(Boundary bd) =>
    (bd.p2 - bd.p1) / (bd.b2 - bd.b1)

angleDeg(float slope, float atrValue) =>
    math.todegrees(math.atan(slope / atrValue))

piercedBetween(Boundary bd, float tol) =>
    bool hit = false
    if bd.b2 - bd.b1 > 1
        for b = bd.b1 + 1 to bd.b2 - 1
            int off = bar_index - b
            float linePrice = priceAt(bd, b)
            if bd.isHigh ? high[off] > linePrice + tol : low[off] < linePrice - tol
                hit := true
                break
    hit

violatedInRange(Boundary bd, int fromBar, int toBar, float tol) =>
    bool hit = false
    if toBar >= fromBar
        for b = fromBar to toBar
            int off = bar_index - b
            float linePrice = priceAt(bd, b)
            if bd.isHigh ? high[off] > linePrice + tol : low[off] < linePrice - tol
                hit := true
                break
    hit

violatedNow(Boundary bd, float tol) =>
    float linePrice = priceAt(bd, bar_index)
    bd.isHigh ? high > linePrice + tol : low < linePrice - tol

overlapRatio(Boundary up, Boundary lo) =>
    int lo1 = math.max(up.b1, lo.b1)
    int hi1 = math.min(up.b2, lo.b2)
    int shared = math.max(0, hi1 - lo1)
    int longer = math.max(up.b2 - up.b1, lo.b2 - lo.b1)
    longer <= 0 ? 0.0 : shared / float(longer)

widthRatio(Boundary up, Boundary lo) =>
    int oStart = math.max(up.b1, lo.b1)
    int oEnd   = math.min(up.b2, lo.b2)
    float wStart = priceAt(up, oStart) - priceAt(lo, oStart)
    float wEnd   = priceAt(up, oEnd) - priceAt(lo, oEnd)
    oEnd <= oStart or wStart <= 0 or wEnd <= 0 ? 1e9 : wEnd / wStart

apexBarOf(Boundary up, Boundary lo) =>
    float su = slopePerBar(up)
    float sl = slopePerBar(lo)
    int result = -1
    if su != sl
        float b = (lo.p1 - sl * lo.b1 - up.p1 + su * up.b1) / (su - sl)
        if b > 0 and b < 1e9
            result := math.round(b)
    result

apexLimitOf(Boundary up, Boundary lo, int apexBar) =>
    apexBar > 0 and priceAt(up, apexBar) <= priceAt(lo, apexBar) ? apexBar - 1 : apexBar

measurePole(int startBar, float atrValue) =>
    int off = bar_index - startBar
    int back = off + POLE_LOOKBACK
    float result = 0.0
    if back <= bar_index and atrValue > 0
        result := (close[off] - close[back]) / atrValue
    result

classify(float upperAngle, float lowerAngle, float poleAtr, float flatTol, float parallelTol,
     bool convergesSoon, bool divergesFast, float wRatio, bool flagBrief) =>
    bool upperFlat = math.abs(upperAngle) < flatTol
    bool lowerFlat = math.abs(lowerAngle) < flatTol
    string kind = F_NONE
    if upperFlat and lowerFlat
        if not divergesFast and wRatio <= CHANNEL_WIDTH_MAX and
             wRatio >= 1.0 / CHANNEL_WIDTH_MAX
            kind := F_RECTANGLE
    else if upperAngle < lowerAngle and convergesSoon
        if upperFlat
            kind := F_ASC_TRIANGLE
        else if lowerFlat
            kind := F_DESC_TRIANGLE
        else if upperAngle < 0 and lowerAngle > 0
            float steep = math.max(math.abs(upperAngle), math.abs(lowerAngle))
            if math.min(math.abs(upperAngle), math.abs(lowerAngle)) / steep < SYMMETRY_MIN
                kind := F_NONE
            else
                kind := flagBrief and math.abs(poleAtr) >= POLE_MIN_ATR ?
                     F_PENNANT : F_SYMMETRICAL
        else if upperAngle < 0
            kind := F_FALLING_WEDGE
        else
            kind := F_RISING_WEDGE
    else if not divergesFast and math.abs(upperAngle - lowerAngle) <= parallelTol and
         wRatio <= CHANNEL_WIDTH_MAX and wRatio >= 1.0 / CHANNEL_WIDTH_MAX
        float meanAngle = (upperAngle + lowerAngle) / 2.0
        if meanAngle > flatTol
            kind := flagBrief and poleAtr <= -POLE_MIN_ATR ? F_BEAR_FLAG : F_RISING_CHAN
        else if meanAngle < -flatTol
            kind := flagBrief and poleAtr >= POLE_MIN_ATR ? F_BULL_FLAG : F_FALLING_CHAN
    kind

boundaryTravel(Boundary bd, int rightEdge, float height) =>
    float out = na
    if height > 0
        int drawn = math.max(0, rightEdge - bd.b1)
        out := math.abs(slopePerBar(bd)) * drawn / height
    out

boundaryDrift(Boundary bd, int rightEdge, float atr) =>
    float out = na
    if atr > 0
        int drawn = math.max(0, rightEdge - bd.b1)
        out := math.abs(slopePerBar(bd)) * drawn / atr
    out

claimsUpperFlat(string kind) =>
    kind == F_RECTANGLE or kind == F_ASC_TRIANGLE

claimsLowerFlat(string kind) =>
    kind == F_RECTANGLE or kind == F_DESC_TRIANGLE

flatTravelHeld(string kind, Boundary up, Boundary lo, int rightEdge, float height, float atr) =>
    bool held = true
    if claimsUpperFlat(kind)
        float tUp = boundaryTravel(up, rightEdge, height)
        if not na(tUp) and tUp > FLAT_TRAVEL_FRAC
            held := false
        float dUp = boundaryDrift(up, rightEdge, atr)
        if held and not na(dUp) and dUp > FLAT_TRAVEL_ATR
            held := false
    if held and claimsLowerFlat(kind)
        float tLo = boundaryTravel(lo, rightEdge, height)
        if not na(tLo) and tLo > FLAT_TRAVEL_FRAC
            held := false
        float dLo = boundaryDrift(lo, rightEdge, atr)
        if held and not na(dLo) and dLo > FLAT_TRAVEL_ATR
            held := false
    held

familyOn(string kind) =>
    switch kind
        F_FALLING_WEDGE => showWedgesInput
        F_RISING_WEDGE  => showWedgesInput
        F_SYMMETRICAL   => showTrianglesInput
        F_ASC_TRIANGLE  => showTrianglesInput
        F_DESC_TRIANGLE => showTrianglesInput
        F_RECTANGLE     => showRectanglesInput
        F_RISING_CHAN   => showChannelsInput
        F_FALLING_CHAN  => showChannelsInput
        F_BULL_FLAG     => showFlagsInput
        F_BEAR_FLAG     => showFlagsInput
        F_PENNANT       => showPennantsInput
        F_DOUBLE_TOP    => showTopsInput
        F_DOUBLE_BOT    => showTopsInput
        F_HS            => showHSInput
        F_IHS           => showHSInput
        => false

readingOf(string kind) =>
    switch kind
        F_FALLING_WEDGE => R_BULL
        F_ASC_TRIANGLE  => R_BULL
        F_BULL_FLAG     => R_BULL
        F_DOUBLE_BOT    => R_BULL
        F_IHS           => R_BULL
        F_RISING_WEDGE  => R_BEAR
        F_DESC_TRIANGLE => R_BEAR
        F_BEAR_FLAG     => R_BEAR
        F_DOUBLE_TOP    => R_BEAR
        F_HS            => R_BEAR
        => R_NEUTRAL

biasOn(string kind) =>
    switch biasInput
        BIAS_BULL => readingOf(kind) == R_BULL
        BIAS_BEAR => readingOf(kind) == R_BEAR
        BIAS_NEUT => readingOf(kind) == R_NEUTRAL
        => true

categoryOf(string kind) =>
    switch kind
        F_BULL_FLAG     => CAT_CONT
        F_BEAR_FLAG     => CAT_CONT
        F_PENNANT       => CAT_CONT
        F_RISING_CHAN   => CAT_CONT
        F_FALLING_CHAN  => CAT_CONT
        F_ASC_TRIANGLE  => CAT_CONT
        F_DESC_TRIANGLE => CAT_CONT
        F_SYMMETRICAL   => CAT_BILAT
        F_RECTANGLE     => CAT_BILAT
        => CAT_REV

categoryOn(string kind) =>
    categoryInput == CAT_ALL or categoryOf(kind) == categoryInput

readingPhrase(string kind) =>
    string reading = readingOf(kind)
    string adj     = reading == R_BULL ? ADJ_BULL : reading == R_BEAR ? ADJ_BEAR : ADJ_NEUT
    string cat     = categoryOf(kind)
    string noun    = cat == CAT_CONT ? NOUN_CONT : cat == CAT_REV ? NOUN_REV : ""
    adj + noun

conventionText(string kind) =>
    "Conventionally " + readingPhrase(kind)

closeAgrees(string reading, int side) =>
    reading == R_NEUTRAL ? 0 : (side == 1) == (reading == R_BULL) ? 1 : -1

shownBy(string kind) =>
    biasOn(kind) and categoryOn(kind)

familyColor(string kind) =>
    switch kind
        F_FALLING_WEDGE => wedgeColorInput
        F_RISING_WEDGE  => wedgeColorInput
        F_SYMMETRICAL   => triColorInput
        F_ASC_TRIANGLE  => triColorInput
        F_DESC_TRIANGLE => triColorInput
        F_RECTANGLE     => rectColorInput
        F_RISING_CHAN   => chanColorInput
        F_FALLING_CHAN  => chanColorInput
        F_BULL_FLAG     => flagColorInput
        F_BEAR_FLAG     => flagColorInput
        F_PENNANT       => pennColorInput
        F_DOUBLE_TOP    => topsColorInput
        F_DOUBLE_BOT    => topsColorInput
        F_HS            => hsColorInput
        F_IHS           => hsColorInput
        => chart.fg_color

// True when either of these lines is already a boundary of a formation on the
// chart. A boundary participates in ONE formation at a time.
//
// Testing the exact pair is not enough: stage 2 pairs K uppers against K lowers,
// so one upper line would pair with every lower that overlaps it and each pairing
// would be its own formation. The pick arrays are ranked by distance from the
// current close, so the surviving pairing is the one nearest price. The cost:
// where a line genuinely bounds two shapes at once, only the nearer is drawn.
boundaryHeld(array<Formation> held, Boundary up, Boundary lo) =>
    bool found = false
    for f in held
        if f.upper.b1 == up.b1 and f.upper.b2 == up.b2
            found := true
        if f.lower.b1 == lo.b1 and f.lower.b2 == lo.b2
            found := true
    found

boundaryInFormations(array<Formation> held, Boundary b) =>
    bool found = false
    for f in held
        if (f.upper.b1 == b.b1 and f.upper.b2 == b.b2 and f.upper.p1 == b.p1 and f.upper.p2 == b.p2) or
             (f.lower.b1 == b.b1 and f.lower.b2 == b.b2 and f.lower.p1 == b.p1 and f.lower.p2 == b.p2)
            found := true
    found

boundaryInNeck(array<NeckFormation> neckHeld, Boundary b) =>
    bool found = false
    for nf in neckHeld
        if nf.neck.b1 == b.b1 and nf.neck.b2 == b.b2 and nf.neck.p1 == b.p1 and nf.neck.p2 == b.p2
            found := true
    found

seenPair(array<PairKey> memory, Boundary up, Boundary lo) =>
    bool found = false
    for k in memory
        if k.ub1 == up.b1 and k.ub2 == up.b2 and k.lb1 == lo.b1 and k.lb2 == lo.b2
            found := true
    found

inKeptPool(array<Boundary> pool, int b1, int b2) =>
    bool found = false
    for bd in pool
        if bd.b1 == b1 and bd.b2 == b2
            found := true
    found

retirePair(array<PairKey> memory, array<Boundary> upperKept, array<Boundary> lowerKept, Boundary up, Boundary lo) =>
    bool added = not seenPair(memory, up, lo)
    if added
        array.push(memory, PairKey.new(up.b1, up.b2, lo.b1, lo.b2))
        while array.size(memory) > RESOLVED_MAX
            int drop = 0
            bool foundStale = false
            for i = 0 to array.size(memory) - 1
                if not foundStale
                    PairKey k = array.get(memory, i)
                    if not inKeptPool(upperKept, k.ub1, k.ub2) or not inKeptPool(lowerKept, k.lb1, k.lb2)
                        drop := i
                        foundStale := true
            array.remove(memory, drop)
    added

leftEdgeOf(Formation f) =>
    math.max(f.upper.b1, f.lower.b1)

boundStart(Boundary bd) =>
    bd.b1

drawLeftOf(Formation f) =>
    math.min(f.upper.b1, f.lower.b1)

formationHeight(Formation f) =>
    int leftEdge = leftEdgeOf(f)
    math.abs(priceAt(f.upper, leftEdge) - priceAt(f.lower, leftEdge))

neckHeight(NeckFormation nf) =>
    switch nf.kind
        F_HS         => math.abs(nf.e2P - priceAt(nf.neck, nf.e2Bar))
        F_IHS        => math.abs(nf.e2P - priceAt(nf.neck, nf.e2Bar))
        F_DOUBLE_TOP => math.max(nf.e1P, nf.e2P) - nf.neck.p1
        => nf.neck.p1 - math.min(nf.e1P, nf.e2P)

slotCost(Formation f, string sel) =>
    switch sel
        SEL_NEW  => 1.0 * math.max(bar_index - f.startBar, 0)
        SEL_TALL => 1.0 / math.max(formationHeight(f), syminfo.mintick)
        SEL_LONG => 1.0 / math.max(bar_index - leftEdgeOf(f), 1)
        => math.min(math.abs(close - priceAt(f.upper, bar_index)),
             math.abs(close - priceAt(f.lower, bar_index)))

neckSlotCost(NeckFormation nf, string sel) =>
    switch sel
        SEL_NEW  => 1.0 * math.max(bar_index - nf.startBar, 0)
        SEL_TALL => 1.0 / math.max(neckHeight(nf), syminfo.mintick)
        SEL_LONG => 1.0 / math.max(bar_index - nf.e1Bar, 1)
        => math.abs(close - priceAt(nf.neck, bar_index))

rankAmong(float d, int gi, array<float> actD, array<float> nkD) =>
    int nearer = 0
    if array.size(actD) > 0
        for j = 0 to array.size(actD) - 1
            float e = array.get(actD, j)
            if e < d or (e == d and j < gi)
                nearer := nearer + 1
    if array.size(nkD) > 0
        for j = 0 to array.size(nkD) - 1
            float e = array.get(nkD, j)
            int   gj = array.size(actD) + j
            if e < d or (e == d and gj < gi)
                nearer := nearer + 1
    nearer

assignDrawnSlots(array<Formation> reg, array<NeckFormation> nk, int budget,
     string sel) =>
    int n = array.size(reg)
    int m = array.size(nk)
    array<float> actD = array.new<float>()
    array<float> nkD  = array.new<float>()
    if n > 0
        for i = 0 to n - 1
            Formation f = array.get(reg, i)
            float d = slotCost(f, sel)
            array.push(actD, f.drawn ? d / HOLD_FACTOR : d)
    if m > 0
        for i = 0 to m - 1
            NeckFormation nf = array.get(nk, i)
            float d = neckSlotCost(nf, sel)
            array.push(nkD, nf.drawn ? d / HOLD_FACTOR : d)

    int held = 0
    if n > 0
        for i = 0 to n - 1
            Formation f = array.get(reg, i)
            f.drawn := rankAmong(array.get(actD, i), i, actD, nkD) < budget
            held := f.drawn ? held + 1 : held
    if m > 0
        for i = 0 to m - 1
            NeckFormation nf = array.get(nk, i)
            nf.drawn := rankAmong(array.get(nkD, i), n + i, actD, nkD) < budget
            held := nf.drawn ? held + 1 : held
    held

bandGoverned(string kind) =>
    switch kind
        F_RECTANGLE    => true
        F_RISING_CHAN  => true
        F_FALLING_CHAN => true
        F_BULL_FLAG    => true
        F_BEAR_FLAG    => true
        => false

durationGoverned(string kind) =>
    switch kind
        F_BULL_FLAG => true
        F_BEAR_FLAG => true
        F_PENNANT   => true
        => false

flagEdgeOf(int leftEdge) =>
    leftEdge + math.round(FLAG_SPAN_MULT * POLE_LOOKBACK)

demoteOf(string kind) =>
    switch kind
        F_BULL_FLAG => F_FALLING_CHAN
        F_BEAR_FLAG => F_RISING_CHAN
        F_PENNANT   => F_SYMMETRICAL
        => kind

bandEdgeOf(Boundary up, Boundary lo, int leftEdge) =>
    float w0    = priceAt(up, leftEdge) - priceAt(lo, leftEdge)
    float drift = slopePerBar(up) - slopePerBar(lo)
    int result = -1
    if w0 > 0 and drift != 0
        float room = drift > 0 ? w0 * (CHANNEL_WIDTH_MAX - 1.0) :
             w0 * (1.0 - 1.0 / CHANNEL_WIDTH_MAX)
        result := leftEdge + math.floor(room / math.abs(drift))
    result

rightEdgeOf(Formation f, int project) =>
    int result = bar_index + project
    if f.apexBar >= bar_index and f.apexBar < result
        result := f.apexBar
    if bandGoverned(f.kind)
        int leftEdge = leftEdgeOf(f)
        int band     = bandEdgeOf(f.upper, f.lower, leftEdge)
        if band > leftEdge and band < result
            result := band
    if durationGoverned(f.kind)
        int brief = flagEdgeOf(leftEdgeOf(f))
        if brief < result
            result := brief
    result

cappedR(float raw, float cap) =>
    na(cap) or cap <= 0.0 ? raw : math.min(raw, cap)

structStopFloored(float raw, float entry, int side, float r) =>
    float dist = side * (entry - raw)
    entry - side * math.max(dist, STRUCT_STOP_FLOOR_R * r)

formationRUnit(Formation f) => cappedR(formationHeight(f), f.doneCap)

neckRUnit(NeckFormation nf) => cappedR(neckHeight(nf), nf.doneCap)

stopRSuffix(float entryP, float stopP, float r) =>
    not stopStructInput or na(r) or r <= 0.0 or na(entryP) or na(stopP) ? "" :
         " · " + str.tostring(math.abs(entryP - stopP) / r, "0.0#") + "R"

levelTol() =>
    na(syminfo.mintick) or syminfo.mintick <= 0 ? 0.0 : syminfo.mintick / 2.0

levelHit(float targetP, float stopP, int side, float barHigh, float barLow,
     bool tierThisBar) =>
    float tol = levelTol()
    bool tHit = side == 1 ? barHigh >= targetP - tol : barLow  <= targetP + tol
    bool sHit = side == 1 ? barLow  <= stopP   + tol : barHigh >= stopP   - tol
    sHit and (tHit or tierThisBar) ? HIT_BOTH :
         tHit ? HIT_TARGET : sHit ? HIT_STOP : HIT_NONE

tierReached(float p, int side, float barHigh, float barLow) =>
    float tol = levelTol()
    side == 1 ? barHigh >= p - tol : barLow <= p + tol

priceTag(float price) =>
    levelPriceInput ? " · " + str.tostring(price, format.mintick) : ""

entryText(float price) =>
    "Entry" + priceTag(price)

levelTag(string name, float mult, float price, bool reached, bool ambiguous) =>
    name + " " + str.tostring(mult, "0.0#") + "R" + priceTag(price) +
         (reached ? (ambiguous ? HIT_MARK_BOTH : HIT_MARK) : "")

levelField(string name, float mult) =>
    name + " · " + str.tostring(mult, "0.0#") + "R"

stopTag(float price, bool reached, bool ambiguous, float entryP, float r) =>
    "Stop " + stopBasisText() + stopRSuffix(entryP, price, r) +
         priceTag(price) + (reached ? (ambiguous ? HIT_MARK_BOTH : HIT_MARK) : "")

stopField() =>
    "Stop · " + stopBasisText()

zoneLook(box zone, bool reached, bool faded, color base) =>
    int transp = faded ? ZONE_FADE_TRANSP : reached ? ZONE_REACHED_TRANSP : ZONE_TRANSP
    box.set_bgcolor(zone, color.new(base, transp))
    box.set_border_color(zone, color.new(base,
         faded ? ZONE_NO_BORDER : reached ? 0 : ZONE_EDGE_TRANSP))
    box.set_border_width(zone, faded ? 0 :
         reached ? ZONE_REACHED_WIDTH : ZONE_EDGE_WIDTH)

levelRightOf(int hitWhich, int hitBar, int doneBar) =>
    hitWhich == HIT_NONE ?
         math.max(bar_index, doneBar + math.max(ARROW_MIN_RUN, projectUsed)) : hitBar

levelLabelX(bool column, int labelX, int lvlX, int reach) =>
    column and labelX - lvlX <= reach ? labelX : lvlX

levelLead(line ln, bool want, int xFrom, int xTo, float p, color c) =>
    line out = ln
    if not want
        line.delete(ln)
        out := na
    else if na(ln)
        out := line.new(x1 = xFrom, y1 = p, x2 = xTo, y2 = p, color = c,
             style = line.style_dotted, width = 1)
    else
        line.set_xy1(ln, xFrom, p)
        line.set_xy2(ln, xTo, p)
        line.set_color(ln, c)
    out

tierRightOf(int hitTierBar, int openRight) =>
    hitTierBar >= 0 ? hitTierBar : openRight

tierShown(int which, int hitTierBar) =>
    hitTierBar >= 0 ? onCloseInput == CLOSE_KEEP :
         not (which != HIT_NONE and unreachedInput == UNREACH_REMOVE)

stopLabelShown(int which) =>
    not (which == HIT_TARGET and unreachedInput == UNREACH_REMOVE)

levelsWithheld(bool armed, int which, int doneBar, int newestDone) =>
    not armed or
     (onCloseInput == CLOSE_CLEAR and which != HIT_NONE) or
     (levelsForInput == LEVELS_NEWEST and doneBar < newestDone)

targetName(int tier) =>
    targetTiersInput > 1 ? "T" + str.tostring(tier) : "Target"

reachedText(int h1, int h2, int h3, int which) =>
    string txt = ""
    for tier = 1 to targetTiersInput
        int hb = tier == 3 ? h3 : tier == 2 ? h2 : h1
        if hb >= 0
            txt := txt + (str.length(txt) > 0 ? ", " : "") + targetName(tier)
    if which == HIT_STOP or which == HIT_BOTH
        txt := txt + (str.length(txt) > 0 ? ", " : "") + "Stop"
    str.length(txt) == 0 ? REACHED_NONE :
         which == HIT_BOTH ? txt + REACHED_AMBIGUOUS : txt

levelCellText(float price, int at, int doneAt) =>
    string txt = str.tostring(price, format.mintick)
    if at > 0
        string same = str.format_time(at, "yyyy-MM-dd", syminfo.timezone) ==
             str.format_time(doneAt, "yyyy-MM-dd", syminfo.timezone) ?
             "HH:mm" : "d MMM HH:mm"
        txt := txt + "  " + str.format_time(at,
             timeframe.isintraday ? same : "d MMM yyyy", syminfo.timezone)
    txt

levelFill(bool reached, color side) =>
    color c = na
    if reached
        c := color.new(side, TBL_FILL_TRANSP)
    c

levelTextColor(bool reached, color side, bool armed, color plain) =>
    not armed ? plain : reached ? TBL_FILL_TEXT : color.new(side, 0)

targetMult(int tier) =>
    tier == 3 ? targetR3Input : tier == 2 ? targetR2Input : targetRInput

tierZone(box zn, bool want, float pFrom, float pTo, int left, int right,
     bool reached, bool faded) =>
    box out = zn
    if not want
        box.delete(zn)
        out := na
    else
        if na(zn)
            out := box.new(left = left, top = math.max(pFrom, pTo), right = right,
                 bottom = math.min(pFrom, pTo), border_color = na,
                 bgcolor = color.new(targetColorInput, ZONE_TRANSP))
        else
            box.set_right(zn, right)
        zoneLook(out, reached, faded, targetColorInput)
    out

tierLabel(label tg, bool want, bool showText, int tier, float p, int lblX,
     bool reached, bool ambiguous, bool faded) =>
    label out = tg
    if not want
        label.delete(tg)
        out := na
    else
        string txt = showText ? levelTag(targetName(tier), targetMult(tier), p,
             reached, ambiguous) : ""
        if na(tg)
            out := label.new(x = lblX, y = p, text = txt,
                 style = label.style_label_left,
                 color = color.new(targetColorInput, 80),
                 textcolor = chart.fg_color, size = LABEL_SIZE,
                 tooltip = levelNote())
        else
            label.set_x(tg, lblX)
            label.set_text(tg, txt)
        if faded
            label.set_color(out, color.new(targetColorInput, LABEL_FADE_TRANSP))
            label.set_textcolor(out, color.new(chart.fg_color, TEXT_FADE_TRANSP))
    out

enclosesFormation(Formation outer, Formation inner, int outerRight, int innerRight) =>
    int outerLeft = leftEdgeOf(outer)
    int innerLeft = leftEdgeOf(inner)
    bool result = false
    if outerLeft <= innerLeft and outerRight >= innerRight and innerRight > innerLeft
        result := priceAt(outer.upper, innerLeft) >= priceAt(inner.upper, innerLeft) and
             priceAt(outer.lower, innerLeft) <= priceAt(inner.lower, innerLeft) and
             priceAt(outer.upper, innerRight) >= priceAt(inner.upper, innerRight) and
             priceAt(outer.lower, innerRight) <= priceAt(inner.lower, innerRight)
    result

spreadLabelY(array<int> xs, array<float> ys, int x, float y, float atrValue, int dir,
     float gapMult) =>
    float result = y
    if not na(atrValue) and atrValue > 0 and array.size(xs) > 0
        float gap = gapMult * atrValue
        bool moved = true
        int guard = 0
        int limit = array.size(xs) + 1
        while moved and guard < limit
            moved := false
            guard := guard + 1
            for i = 0 to array.size(xs) - 1
                if math.abs(array.get(xs, i) - x) <= LABEL_X_GAP and
                     math.abs(array.get(ys, i) - result) < gap
                    result := result + dir * gap
                    moved := true
    array.push(xs, x)
    array.push(ys, result)
    result

glowLine(int x1, float y1, int x2, float y2, color c, int extraWidth, int transp,
     string lineStyle) =>
    line.new(x1 = x1, y1 = y1, x2 = x2, y2 = y2,
         color = color.new(c, math.min(99, transp)), width = widthUsed + extraWidth,
         style = lineStyle)

formingText(string kind) =>
    conventionText(kind) + " · " + kind

completedText(string kind, int side) =>
    kind + " · " + (side == 1 ? "Closed Above" : "Closed Below")

tooltipText(string kind, int side, bool complete, bool nested, float pct) =>
    int    rel    = closeAgrees(readingOf(kind), side)
    string agrees = rel == 0 ? "" : rel == 1 ?
         " — with the conventional reading" : " — against the conventional reading"
    string inside = nested ? "\n• Drawn inside a larger formation on this chart, " +
         "which gives up its shading so this one reads in front" : ""
    string aged   = complete or na(pct) ? "" :
         " · " + pctText(pct) + " complete\n• " + PCT_NOTE
    conventionText(kind) + " · " + kind + "\n• " +
     (complete ? (side == 1 ? "Closed above the upper boundary" :
     "Closed below the lower boundary") + agrees : "Still forming" + aged) + inside

expiredTooltip(string kind, string why) =>
    conventionText(kind) + " · " + kind + "\n• " + why +
     "\n• Ended without completing, so no alert fired for it."

eraseFormation(Formation f) =>
    line.delete(f.upLine)
    line.delete(f.loLine)
    line.delete(f.upGlowOut)
    line.delete(f.upGlowIn)
    line.delete(f.loGlowOut)
    line.delete(f.loGlowIn)
    line.delete(f.leader)
    line.delete(f.arrow)
    line.delete(f.leg)
    line.delete(f.entryLn)
    line.delete(f.entryGlowOut)
    line.delete(f.entryGlowIn)
    box.delete(f.targetZone)
    box.delete(f.targetZone2)
    box.delete(f.targetZone3)
    box.delete(f.stopZone)
    label.delete(f.entryTag)
    label.delete(f.targetTag)
    label.delete(f.targetTag2)
    label.delete(f.targetTag3)
    label.delete(f.stopTag)
    line.delete(f.entryLead)
    line.delete(f.targetLead)
    line.delete(f.targetLead2)
    line.delete(f.targetLead3)
    line.delete(f.stopLead)
    label.delete(f.tag)
    f.upLine := na
    f.loLine := na
    f.upGlowOut := na
    f.upGlowIn := na
    f.loGlowOut := na
    f.loGlowIn := na
    f.leader := na
    f.arrow := na
    f.leg := na
    f.entryLn := na
    f.entryGlowOut := na
    f.entryGlowIn := na
    f.targetZone := na
    f.targetZone2 := na
    f.targetZone3 := na
    f.stopZone := na
    f.entryTag := na
    f.targetTag := na
    f.targetTag2 := na
    f.targetTag3 := na
    f.stopTag := na
    f.entryLead := na
    f.targetLead := na
    f.targetLead2 := na
    f.targetLead3 := na
    f.stopLead := na
    f.band := na
    f.tag := na

eraseLabels(Formation f) =>
    label.delete(f.tag)
    line.delete(f.leader)
    if not na(f.entryTag)
        label.set_text(f.entryTag, "")
    if not na(f.targetTag)
        label.set_text(f.targetTag, "")
    if not na(f.targetTag2)
        label.set_text(f.targetTag2, "")
    if not na(f.targetTag3)
        label.set_text(f.targetTag3, "")
    if not na(f.stopTag)
        label.set_text(f.stopTag, "")
    line.delete(f.entryLead)
    line.delete(f.targetLead)
    line.delete(f.targetLead2)
    line.delete(f.targetLead3)
    line.delete(f.stopLead)
    f.tag := na
    f.leader := na
    f.entryLead := na
    f.targetLead := na
    f.targetLead2 := na
    f.targetLead3 := na
    f.stopLead := na

neckSideOf(string kind) =>
    kind == F_DOUBLE_TOP or kind == F_HS ? -1 : 1

neckTooltip(string kind, int side, bool complete, float pct) =>
    string agrees = (side == 1) == (readingOf(kind) == R_BULL) ?
         " — with the conventional reading" : " — against the conventional reading"
    string aged = complete or na(pct) ? "" :
         " · " + pctText(pct) + " complete\n• " + PCT_NOTE
    conventionText(kind) + " · " + kind + "\n• " +
     (complete ? (side == 1 ? "Closed above the neckline" :
     "Closed below the neckline") + agrees : "Still forming" + aged)

extremeBetween(array<Pivot> pool, int fromBar, int toBar, bool lowest) =>
    Pivot result = na
    for p in pool
        if p.bar > fromBar and p.bar < toBar
            if na(result) or (lowest ? p.price < result.price : p.price > result.price)
                result := p
    result

troughBeyond(Pivot t, float pA, float pB, bool tops) =>
    na(t) ? false : (tops ? t.price < math.min(pA, pB) : t.price > math.max(pA, pB))

detectNeck(array<Pivot> anchors, array<Pivot> troughs, bool tops, float atrValue) =>
    NeckFormation result = na
    int n = array.size(anchors)
    if n >= 2
        Pivot a = array.get(anchors, n - 2)
        Pivot b = array.get(anchors, n - 1)
        if math.abs(a.price - b.price) <= TOP_MATCH_ATR * atrValue
            Pivot t = extremeBetween(troughs, a.bar, b.bar, tops)
            if troughBeyond(t, a.price, b.price, tops)
                result := NeckFormation.new(kind = tops ? F_DOUBLE_TOP : F_DOUBLE_BOT,
                     e1Bar = a.bar, e1P = a.price, e2Bar = b.bar, e2P = b.price,
                     neck = Boundary.new(t.bar, t.price, b.bar, t.price, not tops),
                     startBar = a.bar, state = STATE_FORMING, completedBar = -1,
                     side = 0)
    if na(result) and n >= 3
        Pivot s1 = array.get(anchors, n - 3)
        Pivot hd = array.get(anchors, n - 2)
        Pivot s2 = array.get(anchors, n - 1)
        bool headBeyond = tops ?
             hd.price > s1.price + HEAD_BEYOND_ATR * atrValue and
             hd.price > s2.price + HEAD_BEYOND_ATR * atrValue :
             hd.price < s1.price - HEAD_BEYOND_ATR * atrValue and
             hd.price < s2.price - HEAD_BEYOND_ATR * atrValue
        if headBeyond and math.abs(s1.price - s2.price) <= SHOULDER_MATCH_ATR * atrValue
            Pivot t1 = extremeBetween(troughs, s1.bar, hd.bar, tops)
            Pivot t2 = extremeBetween(troughs, hd.bar, s2.bar, tops)
            if troughBeyond(t1, s1.price, hd.price, tops) and
                 troughBeyond(t2, hd.price, s2.price, tops)
                result := NeckFormation.new(kind = tops ? F_HS : F_IHS,
                     e1Bar = s1.bar, e1P = s1.price, e2Bar = hd.bar, e2P = hd.price,
                     e3Bar = s2.bar, e3P = s2.price,
                     neck = Boundary.new(t1.bar, t1.price, t2.bar, t2.price, not tops),
                     startBar = s1.bar, state = STATE_FORMING, completedBar = -1,
                     side = 0)
    if not na(result)
        float candHeight = neckHeight(result)
        if candHeight <= 0 or candHeight > NECK_HEIGHT_MAX_ATR * atrValue
            result := na
    result

neckPoints(NeckFormation nf) =>
    array<chart.point> pts = array.new<chart.point>()
    array.push(pts, chart.point.from_index(nf.e1Bar, nf.e1P))
    array.push(pts, chart.point.from_index(nf.neck.b1, nf.neck.p1))
    array.push(pts, chart.point.from_index(nf.e2Bar, nf.e2P))
    if nf.e3Bar > 0
        array.push(pts, chart.point.from_index(nf.neck.b2, nf.neck.p2))
        array.push(pts, chart.point.from_index(nf.e3Bar, nf.e3P))
    pts

eraseNeck(NeckFormation nf) =>
    polyline.delete(nf.outline)
    line.delete(nf.neckLn)
    line.delete(nf.leader)
    line.delete(nf.arrow)
    line.delete(nf.leg)
    line.delete(nf.entryLn)
    line.delete(nf.entryGlowOut)
    line.delete(nf.entryGlowIn)
    box.delete(nf.targetZone)
    box.delete(nf.targetZone2)
    box.delete(nf.targetZone3)
    box.delete(nf.stopZone)
    label.delete(nf.tag)
    label.delete(nf.entryTag)
    label.delete(nf.targetTag)
    label.delete(nf.targetTag2)
    label.delete(nf.targetTag3)
    label.delete(nf.stopTag)
    line.delete(nf.entryLead)
    line.delete(nf.targetLead)
    line.delete(nf.targetLead2)
    line.delete(nf.targetLead3)
    line.delete(nf.stopLead)
    nf.outline := na
    nf.neckLn := na
    nf.leader := na
    nf.arrow := na
    nf.leg := na
    nf.entryLn := na
    nf.entryGlowOut := na
    nf.entryGlowIn := na
    nf.targetZone := na
    nf.targetZone2 := na
    nf.targetZone3 := na
    nf.stopZone := na
    nf.tag := na
    nf.entryTag := na
    nf.targetTag := na
    nf.targetTag2 := na
    nf.targetTag3 := na
    nf.stopTag := na
    nf.entryLead := na
    nf.targetLead := na
    nf.targetLead2 := na
    nf.targetLead3 := na
    nf.stopLead := na

eraseNeckLabels(NeckFormation nf) =>
    label.delete(nf.tag)
    line.delete(nf.leader)
    if not na(nf.entryTag)
        label.set_text(nf.entryTag, "")
    if not na(nf.targetTag)
        label.set_text(nf.targetTag, "")
    if not na(nf.targetTag2)
        label.set_text(nf.targetTag2, "")
    if not na(nf.targetTag3)
        label.set_text(nf.targetTag3, "")
    if not na(nf.stopTag)
        label.set_text(nf.stopTag, "")
    line.delete(nf.entryLead)
    line.delete(nf.targetLead)
    line.delete(nf.targetLead2)
    line.delete(nf.targetLead3)
    line.delete(nf.stopLead)
    nf.tag := na
    nf.leader := na
    nf.entryLead := na
    nf.targetLead := na
    nf.targetLead2 := na
    nf.targetLead3 := na
    nf.stopLead := na

holdsSlot(int state, int hitWhich, int startBar, int completedBar, bool armed) =>
    showLevelsInput and armed and state == STATE_COMPLETE and
         hitWhich == HIT_NONE and
         bar_index - completedBar <= completedBar - startBar

repeatsCompletion(int state, int hitWhich, int incSide, float incEntry,
     float incStop, int side, float entry, bool incArmed) =>
    incArmed and state == STATE_COMPLETE and hitWhich == HIT_NONE and
         incSide == side and
         math.abs(entry - incEntry) <= math.abs(incEntry - incStop)

completionIsRepeat(array<Formation> fs, array<NeckFormation> ns, int side,
     float entry) =>
    bool found = false
    for f in fs
        if not found and repeatsCompletion(f.state, f.hitWhich, f.side, f.doneClose,
             f.stopP, side, entry, f.armed)
            found := true
    for nf in ns
        if not found and repeatsCompletion(nf.state, nf.hitWhich, nf.side, nf.doneClose,
             nf.stopP, side, entry, nf.armed)
            found := true
    found

trimEnded(array<Formation> fs, array<NeckFormation> ns, int keep) =>
    int dropped = 0
    while array.size(fs) + array.size(ns) > keep
        int regIdx = -1
        for [i, f] in fs
            if regIdx < 0 and not holdsSlot(f.state, f.hitWhich, f.startBar,
                 f.completedBar, f.armed)
                regIdx := i
        int nkIdx = -1
        for [i, nf] in ns
            if nkIdx < 0 and not holdsSlot(nf.state, nf.hitWhich, nf.startBar,
                 nf.completedBar, nf.armed)
                nkIdx := i
        bool allHeld = regIdx < 0 and nkIdx < 0
        int  rTake   = allHeld ? array.size(fs) - 1 : regIdx
        int  nTake   = allHeld ? array.size(ns) - 1 : nkIdx
        int  rBar    = rTake < 0 ? 0 : array.get(fs, rTake).completedBar
        int  nBar    = nTake < 0 ? 0 : array.get(ns, nTake).completedBar
        bool takeReg = nTake < 0 or (rTake >= 0 and
             (allHeld ? rBar >= nBar : rBar <= nBar))
        if takeReg
            eraseFormation(array.remove(fs, rTake))
        else
            eraseNeck(array.remove(ns, nTake))
        dropped := dropped + 1
    dropped

tablePos(string s) =>
    switch s
        TBL_TL => position.top_left
        TBL_TC => position.top_center
        TBL_ML => position.middle_left
        TBL_MC => position.middle_center
        TBL_MR => position.middle_right
        TBL_BL => position.bottom_left
        TBL_BC => position.bottom_center
        TBL_BR => position.bottom_right
        => position.top_right

tableSize(string s) =>
    switch s
        TBL_SZ_TINY   => size.tiny
        TBL_SZ_NORMAL => size.normal
        TBL_SZ_LARGE  => size.large
        => size.small

rowInsertAt(array<LevelRow> rows, int bar) =>
    int at = array.size(rows)
    int i  = 0
    for r in rows
        if r.bar > bar and at == array.size(rows)
            at := i
        i := i + 1
    at

addRow(array<LevelRow> rows, LevelRow row) =>
    int at = rowInsertAt(rows, row.bar)
    if at >= array.size(rows)
        array.push(rows, row)
    else
        array.insert(rows, at, row)


// ======================== Calculations =======================================

float atrValue = ta.sma(ta.tr(true), atrLenInput)

float pierceTol   = tolUsed * atrValue
float completeTol = completionUsed * atrValue

float chartCapAtr = ta.sma(ta.tr(true), R_CAP_ATR_LEN)
float dailyCapAtr = request.security(syminfo.tickerid, "D",
     ta.sma(ta.tr(true), R_CAP_ATR_LEN)[1], lookahead = barmerge.lookahead_on)
float rCapValue   = rCapMultInput * (timeframe.in_seconds() >= timeframe.in_seconds("D") ?
     chartCapAtr : dailyCapAtr)

var array<Pivot>     highPivots = array.new<Pivot>()
var array<Pivot>     lowPivots  = array.new<Pivot>()
var array<Boundary>  upperKept  = array.new<Boundary>()
var array<Boundary>  lowerKept  = array.new<Boundary>()
var array<Formation> active     = array.new<Formation>()
var array<Formation> retained   = array.new<Formation>()
var array<Formation> expiredSet = array.new<Formation>()
var array<NeckFormation> neckActive   = array.new<NeckFormation>()
var array<NeckFormation> neckRetained = array.new<NeckFormation>()
var array<NeckFormation> neckExpired  = array.new<NeckFormation>()
var array<PairKey>   resolved   = array.new<PairKey>()

float pivotHigh = ta.pivothigh(swingUsed, swingUsed)
float pivotLow  = ta.pivotlow(swingUsed, swingUsed)

if barstate.isconfirmed and not na(atrValue) and atrValue > 0

    bool newHigh = not na(pivotHigh)
    bool newLow  = not na(pivotLow)

    if newHigh
        array.push(highPivots, Pivot.new(bar_index - swingUsed, pivotHigh))
    if newLow
        array.push(lowPivots, Pivot.new(bar_index - swingUsed, pivotLow))

    while array.size(highPivots) > 0 and
         (array.size(highPivots) > poolUsed or
         bar_index - array.get(highPivots, 0).bar > barsUsed)
        array.shift(highPivots)
    while array.size(lowPivots) > 0 and
         (array.size(lowPivots) > poolUsed or
         bar_index - array.get(lowPivots, 0).bar > barsUsed)
        array.shift(lowPivots)

    if array.size(upperKept) > 0
        for i = array.size(upperKept) - 1 to 0
            Boundary bd = array.get(upperKept, i)
            if violatedNow(bd, pierceTol) or bar_index - bd.b1 > barsUsed
                array.remove(upperKept, i)
    if array.size(lowerKept) > 0
        for i = array.size(lowerKept) - 1 to 0
            Boundary bd = array.get(lowerKept, i)
            if violatedNow(bd, pierceTol) or bar_index - bd.b1 > barsUsed
                array.remove(lowerKept, i)

    if newHigh and array.size(highPivots) > 1
        Pivot newest = array.get(highPivots, array.size(highPivots) - 1)
        for i = 0 to array.size(highPivots) - 2
            Pivot older = array.get(highPivots, i)
            Boundary bd = Boundary.new(older.bar, older.price, newest.bar, newest.price, true)
            if not piercedBetween(bd, pierceTol)
                if not violatedInRange(bd, bd.b2 + 1, bar_index, pierceTol)
                    array.push(upperKept, bd)
        while array.size(upperKept) > MAX_KEPT_PER_SIDE
            array.shift(upperKept)

    if newLow and array.size(lowPivots) > 1
        Pivot newest = array.get(lowPivots, array.size(lowPivots) - 1)
        for i = 0 to array.size(lowPivots) - 2
            Pivot older = array.get(lowPivots, i)
            Boundary bd = Boundary.new(older.bar, older.price, newest.bar, newest.price, false)
            if not piercedBetween(bd, pierceTol)
                if not violatedInRange(bd, bd.b2 + 1, bar_index, pierceTol)
                    array.push(lowerKept, bd)
        while array.size(lowerKept) > MAX_KEPT_PER_SIDE
            array.shift(lowerKept)

    if (newHigh or newLow) and array.size(upperKept) > 0 and array.size(lowerKept) > 0

        array<int> upperPick = array.new<int>()
        array<int> lowerPick = array.new<int>()

        for n = 1 to math.min(SURVIVORS_PER_SIDE, array.size(upperKept))
            int best = -1
            float bestDist = 0.0
            for i = 0 to array.size(upperKept) - 1
                if not array.includes(upperPick, i)
                    float d = math.abs(priceAt(array.get(upperKept, i), bar_index) - close)
                    if best == -1 or d < bestDist
                        best := i
                        bestDist := d
            if best >= 0
                array.push(upperPick, best)

        for n = 1 to math.min(SURVIVORS_PER_SIDE, array.size(lowerKept))
            int best = -1
            float bestDist = 0.0
            for i = 0 to array.size(lowerKept) - 1
                if not array.includes(lowerPick, i)
                    float d = math.abs(priceAt(array.get(lowerKept, i), bar_index) - close)
                    if best == -1 or d < bestDist
                        best := i
                        bestDist := d
            if best >= 0
                array.push(lowerPick, best)

        for ui in upperPick
            for li in lowerPick
                Boundary up = array.get(upperKept, ui)
                Boundary lo = array.get(lowerKept, li)
                if overlapRatio(up, lo) >= OVERLAP_MIN and not boundaryHeld(active, up, lo) and
                     not seenPair(resolved, up, lo) and not boundaryInNeck(neckActive, up) and
                     not boundaryInNeck(neckActive, lo)
                    int startBar = math.max(up.b1, lo.b1)
                    int span = math.max(up.b2 - up.b1, lo.b2 - lo.b1)
                    int apexBar = apexBarOf(up, lo)
                    float pole = measurePole(startBar, atrValue)
                    bool convergesSoon = apexBar > startBar and
                         apexBar - startBar <= math.round(APEX_SPAN_MULT * span)
                    bool divergesFast = apexBar > 0 and apexBar <= startBar and
                         startBar - apexBar <= math.round(APEX_SPAN_MULT * span)
                    bool flagBrief = span <= math.round(FLAG_SPAN_MULT * POLE_LOOKBACK)
                    string kind = classify(angleDeg(slopePerBar(up), atrValue),
                         angleDeg(slopePerBar(lo), atrValue), pole, flatUsed, parallelUsed,
                         convergesSoon, divergesFast, widthRatio(up, lo), flagBrief)
                    int limitBar = apexBar > startBar ? apexLimitOf(up, lo, apexBar) :
                         startBar + math.round(AGE_SPAN_MULT * span)
                    if bandGoverned(kind)
                        int bandBar = bandEdgeOf(up, lo, startBar)
                        if bandBar > startBar and bandBar < limitBar
                            limitBar := bandBar
                    if durationGoverned(kind)
                        int briefBar = flagEdgeOf(startBar)
                        if briefBar < limitBar
                            limitBar := briefBar
                    bool alive = bar_index <= limitBar and bar_index - startBar <= barsUsed
                    bool flatOk = flatTravelHeld(kind, up, lo, bar_index,
                         math.abs(priceAt(up, startBar) - priceAt(lo, startBar)),
                         atrValue)
                    if kind != F_NONE and familyOn(kind) and alive and flatOk
                        if array.size(active) >= MAX_ACTIVE
                            Formation evicted = array.shift(active)
                            retirePair(resolved, upperKept, lowerKept, evicted.upper, evicted.lower)
                            eraseFormation(evicted)
                        Formation nf = Formation.new(kind = kind, upper = up, lower = lo,
                             startBar = startBar, apexBar = apexBar, limitBar = limitBar,
                             state = STATE_FORMING, completedBar = -1, side = 0)
                        if durationGoverned(kind)
                            int poleOff = bar_index - startBar
                            nf.legP1 := close[poleOff + POLE_LOOKBACK]
                            nf.legP2 := close[poleOff]
                        array.push(active, nf)
                        alert(alertText(kind, " formation",
                             "both boundaries confirmed", false, na, na, na, na,
                             na), alert.freq_once_per_bar_close)

    array<NeckFormation> neckCands = array.new<NeckFormation>()
    if newHigh
        NeckFormation c = detectNeck(highPivots, lowPivots, true, atrValue)
        if not na(c)
            array.push(neckCands, c)
    if newLow
        NeckFormation c = detectNeck(lowPivots, highPivots, false, atrValue)
        if not na(c)
            array.push(neckCands, c)
    for nf in neckCands
        if not violatedInRange(nf.neck, nf.neck.b1 + 1, bar_index, pierceTol)
            int lastAnchor = nf.e3Bar > 0 ? nf.e3Bar : nf.e2Bar
            int span = lastAnchor - nf.e1Bar
            int limitBar = nf.startBar + math.round(AGE_SPAN_MULT * span)
            nf.limitBar := limitBar
            bool alive = bar_index <= limitBar and bar_index - nf.startBar <= barsUsed
            if familyOn(nf.kind) and alive and not boundaryInFormations(active, nf.neck)
                if array.size(neckActive) >= NECK_MAX_ACTIVE
                    eraseNeck(array.shift(neckActive))
                int legOff = bar_index - nf.e1Bar + POLE_LOOKBACK
                if legOff <= bar_index
                    nf.legP1 := close[legOff]
                    nf.hasLeg := true
                array.push(neckActive, nf)
                alert(alertText(nf.kind, " pattern",
                     "all anchor pivots confirmed", false, na, na, na, na, na),
                     alert.freq_once_per_bar_close)

    for f in retained
        if f.hitWhich == HIT_NONE and bar_index > f.completedBar
            if f.hit1Bar == -1 and tierReached(f.targetP, f.side, high, low)
                f.hit1Bar  := bar_index
                f.hit1Time := time
            if targetTiersInput >= 2 and f.hit2Bar == -1 and
                 tierReached(f.targetP2, f.side, high, low)
                f.hit2Bar  := bar_index
                f.hit2Time := time
            if targetTiersInput >= 3 and f.hit3Bar == -1 and
                 tierReached(f.targetP3, f.side, high, low)
                f.hit3Bar  := bar_index
                f.hit3Time := time
            float outerPF = targetTiersInput >= 3 ? f.targetP3 :
                 targetTiersInput >= 2 ? f.targetP2 : f.targetP
            bool tierBarF = f.hit1Bar == bar_index or f.hit2Bar == bar_index or
                 f.hit3Bar == bar_index
            int whichF = levelHit(outerPF, f.stopP, f.side, high, low, tierBarF)
            if whichF != HIT_NONE
                f.hitWhich := whichF
                f.hitBar   := bar_index
                if whichF == HIT_STOP or whichF == HIT_BOTH
                    f.stopTime := time
    for nf in neckRetained
        if nf.hitWhich == HIT_NONE and bar_index > nf.completedBar
            if nf.hit1Bar == -1 and tierReached(nf.targetP, nf.side, high, low)
                nf.hit1Bar  := bar_index
                nf.hit1Time := time
            if targetTiersInput >= 2 and nf.hit2Bar == -1 and
                 tierReached(nf.targetP2, nf.side, high, low)
                nf.hit2Bar  := bar_index
                nf.hit2Time := time
            if targetTiersInput >= 3 and nf.hit3Bar == -1 and
                 tierReached(nf.targetP3, nf.side, high, low)
                nf.hit3Bar  := bar_index
                nf.hit3Time := time
            float outerPN = targetTiersInput >= 3 ? nf.targetP3 :
                 targetTiersInput >= 2 ? nf.targetP2 : nf.targetP
            bool tierBarN = nf.hit1Bar == bar_index or nf.hit2Bar == bar_index or
                 nf.hit3Bar == bar_index
            int whichN = levelHit(outerPN, nf.stopP, nf.side, high, low, tierBarN)
            if whichN != HIT_NONE
                nf.hitWhich := whichN
                nf.hitBar   := bar_index
                if whichN == HIT_STOP or whichN == HIT_BOTH
                    nf.stopTime := time

    if array.size(active) > 0
        for i = array.size(active) - 1 to 0
            Formation f = array.get(active, i)
            float upperLine = priceAt(f.upper, bar_index)
            float lowerLine = priceAt(f.lower, bar_index)
            bool brokeUp   = close > upperLine + completeTol
            bool brokeDown = close < lowerLine - completeTol

            int span = math.max(f.upper.b2 - f.upper.b1, f.lower.b2 - f.lower.b1)
            int limitBar = f.apexBar > f.startBar ?
                 apexLimitOf(f.upper, f.lower, f.apexBar) :
                 f.startBar + math.round(AGE_SPAN_MULT * span)
            string whyEnd = f.apexBar > f.startBar ? EXP_APEX : EXP_AGE
            if bandGoverned(f.kind)
                int bandBar = bandEdgeOf(f.upper, f.lower, f.startBar)
                if bandBar > f.startBar and bandBar < limitBar
                    limitBar := bandBar
                    whyEnd := EXP_BAND
            int    underlyingLimit = limitBar
            string underlyingWhy   = whyEnd
            if durationGoverned(f.kind)
                int briefBar = flagEdgeOf(f.startBar)
                if briefBar < limitBar
                    limitBar := briefBar
                    whyEnd := EXP_BRIEF
            if durationGoverned(f.kind) and bar_index > limitBar
                 and bar_index <= underlyingLimit
                 and bar_index - f.startBar <= barsUsed
                 and familyOn(demoteOf(f.kind))
                f.kind := demoteOf(f.kind)
                limitBar := underlyingLimit
                whyEnd := underlyingWhy
                eraseFormation(f)
            f.limitBar := limitBar

            if bar_index > limitBar or bar_index - f.startBar > barsUsed
                int windowBar = f.startBar + barsUsed
                f.completedBar := math.max(f.startBar, math.min(limitBar, windowBar))
                f.expiredWhy := windowBar < limitBar ? EXP_WINDOW : whyEnd
                f.state := STATE_EXPIRED
                eraseFormation(f)
                array.remove(active, i)
                retirePair(resolved, upperKept, lowerKept, f.upper, f.lower)
                array.push(expiredSet, f)
                trimEnded(expiredSet, neckExpired, expiredKeptInput)
            else
                int thisSide = brokeUp ? 1 : (brokeDown ? -1 : 0)
                if thisSide != 0
                    f.state := STATE_COMPLETE
                    f.completedBar := bar_index
                    f.side := thisSide
                    f.doneClose := close
                    f.doneCap   := rCapValue
                    f.doneTime  := time
                    float doneR = cappedR(formationHeight(f), f.doneCap)
                    f.targetP := f.doneClose + f.side * targetRInput * doneR
                    f.stopP := stopStructInput ?
                         structStopFloored(priceAt(f.side == 1 ? f.lower : f.upper,
                             f.completedBar), f.doneClose, f.side, doneR) :
                         f.doneClose - f.side * stopRInput * doneR
                    f.targetP2 := f.doneClose + f.side * targetR2Input * doneR
                    f.targetP3 := f.doneClose + f.side * targetR3Input * doneR
                    float donePct = pctComplete(f.startBar, f.limitBar, f.completedBar)
                    f.armed := levelsArmed(donePct)
                    array.remove(active, i)
                    retirePair(resolved, upperKept, lowerKept, f.upper, f.lower)
                    alert(alertText(f.kind, "", f.side == 1 ?
                         "closed above the upper boundary" :
                         "closed below the lower boundary",
                         showLevelsInput and f.armed, f.doneClose,
                         f.targetP, f.targetP2, f.targetP3, f.stopP),
                         alert.freq_once_per_bar_close)
                    eraseFormation(f)
                    if not (skipRepeatUsed and showLevelsInput and
                         completionIsRepeat(retained, neckRetained, f.side, f.doneClose))
                        array.push(retained, f)
                        trimEnded(retained, neckRetained, keptInput)

    if array.size(neckActive) > 0
        for i = array.size(neckActive) - 1 to 0
            NeckFormation nf = array.get(neckActive, i)
            int lastAnchor = nf.e3Bar > 0 ? nf.e3Bar : nf.e2Bar
            int span = lastAnchor - nf.e1Bar
            int limitBar = nf.startBar + math.round(AGE_SPAN_MULT * span)
            nf.limitBar := limitBar
            if bar_index > limitBar or bar_index - nf.startBar > barsUsed
                int windowBar = nf.startBar + barsUsed
                nf.completedBar := math.max(nf.startBar, math.min(limitBar, windowBar))
                nf.expiredWhy := windowBar < limitBar ? EXP_WINDOW : EXP_AGE
                nf.state := STATE_EXPIRED
                eraseNeck(nf)
                array.remove(neckActive, i)
                array.push(neckExpired, nf)
                trimEnded(expiredSet, neckExpired, expiredKeptInput)
            else
                float neckP = priceAt(nf.neck, bar_index)
                int   dir   = neckSideOf(nf.kind)
                bool  broke = dir == 1 ? close > neckP + completeTol :
                     close < neckP - completeTol
                if broke
                    nf.state := STATE_COMPLETE
                    nf.completedBar := bar_index
                    nf.side := dir
                    nf.doneClose := close
                    nf.doneCap   := rCapValue
                    nf.doneTime  := time
                    float neckR = cappedR(neckHeight(nf), nf.doneCap)
                    nf.targetP := nf.doneClose + nf.side * targetRInput * neckR
                    float neckStopP = na
                    if stopStructInput
                        float ext = nf.side == 1 ?
                             math.min(nf.e1P, nf.e2P) : math.max(nf.e1P, nf.e2P)
                        if nf.e3Bar >= 0
                            ext := nf.side == 1 ?
                                 math.min(ext, nf.e3P) : math.max(ext, nf.e3P)
                        neckStopP := structStopFloored(ext, nf.doneClose, nf.side, neckR)
                    else
                        neckStopP := nf.doneClose - nf.side * stopRInput * neckR
                    nf.stopP := neckStopP
                    nf.targetP2 := nf.doneClose + nf.side * targetR2Input * neckR
                    nf.targetP3 := nf.doneClose + nf.side * targetR3Input * neckR
                    float neckPct = pctComplete(nf.startBar, nf.limitBar, nf.completedBar)
                    nf.armed := levelsArmed(neckPct)
                    alert(alertText(nf.kind, "", nf.side == 1 ?
                         "closed above the neckline" :
                         "closed below the neckline",
                         showLevelsInput and nf.armed, nf.doneClose,
                         nf.targetP, nf.targetP2, nf.targetP3, nf.stopP),
                         alert.freq_once_per_bar_close)
                    eraseNeck(nf)
                    array.remove(neckActive, i)
                    if not (skipRepeatUsed and showLevelsInput and
                         completionIsRepeat(retained, neckRetained, nf.side, nf.doneClose))
                        array.push(neckRetained, nf)
                        trimEnded(retained, neckRetained, keptInput)

    assignDrawnSlots(active, neckActive, drawnInput, drawnByInput)


// ======================== Visuals ============================================

var table lvlTable = table.new(position.top_right, TBL_COLS, TBL_ROWS,
     bgcolor = color.new(chart.bg_color, 0),
     border_color = color.new(chart.fg_color, 80), border_width = 1,
     frame_color = color.new(chart.fg_color, 55), frame_width = 1)

fieldCell(int row, string name, string sz, color txt) =>
    table.cell(lvlTable, 0, row, name, text_color = txt, text_size = sz,
         text_halign = text.align_left, text_formatting = text.format_bold,
         bgcolor = color.new(chart.fg_color, TBL_SPINE_TRANSP),
         tooltip = TBL_NOTE)

if barstate.islast
    array<int>   lblXs = array.new<int>()
    array<float> lblYs = array.new<float>()

    bool column    = labelPlaceInput == LBL_COL and labelModeInput != LBL_MARKER
    bool lvlColumn = labelPlaceInput == LBL_COL
    int  labelX    = bar_index + projectUsed + LABEL_COL_GAP


    array<bool>  actDraw = array.new<bool>()
    array<bool>  actShow = array.new<bool>()
    array<bool>  actFill = array.new<bool>()
    array<bool>  nkDraw  = array.new<bool>()
    array<float> actDist = array.new<float>()
    for f in active
        array.push(actDraw, f.drawn)
        array.push(actShow, showFormingInput and shownBy(f.kind))
        array.push(actDist, slotCost(f, drawnByInput))
    for nf in neckActive
        array.push(nkDraw, nf.drawn)
    if array.size(actDist) > 0
        for i = 0 to array.size(actDist) - 1
            float d = array.get(actDist, i)
            int betterReg = 0
            bool eligible = array.get(actDraw, i) and array.get(actShow, i)
            if eligible
                for j = 0 to array.size(actDist) - 1
                    float e = array.get(actDist, j)
                    if array.get(actDraw, j) and array.get(actShow, j) and
                         (e < d or (e == d and j < i))
                        betterReg := betterReg + 1
            array.push(actFill, eligible and betterReg == 0)

    for f in active
        f.encloses := false
        f.nested   := false
    for f in retained
        f.encloses := false
        f.nested   := false
    for f in expiredSet
        f.encloses := false
        f.nested   := false
    array<Formation> shownF = array.new<Formation>()
    array<int>       shownR = array.new<int>()
    int scanIdx = -1
    for f in active
        scanIdx := scanIdx + 1
        if showFormingInput and array.get(actDraw, scanIdx) and shownBy(f.kind)
            array.push(shownF, f)
            array.push(shownR, rightEdgeOf(f, projectUsed))
    for f in retained
        if shownBy(f.kind) and bar_index - drawLeftOf(f) <= DRAW_MAX_BACK
            array.push(shownF, f)
            array.push(shownR, f.completedBar)
    for f in expiredSet
        if shownBy(f.kind) and bar_index - drawLeftOf(f) <= DRAW_MAX_BACK
            array.push(shownF, f)
            array.push(shownR, f.completedBar)
    if array.size(shownF) > 1
        for i = 0 to array.size(shownF) - 1
            Formation outer = array.get(shownF, i)
            for j = 0 to array.size(shownF) - 1
                if i != j
                    Formation inner = array.get(shownF, j)
                    if enclosesFormation(outer, inner, array.get(shownR, i),
                         array.get(shownR, j))
                        outer.encloses := true
                        inner.nested   := true

    int newestDone = -1
    if showLevelsInput and levelsForInput == LEVELS_NEWEST
        for f in retained
            if f.armed and shownBy(f.kind) and bar_index - drawLeftOf(f) <= DRAW_MAX_BACK
                newestDone := math.max(newestDone, f.completedBar)
        for nf in neckRetained
            if nf.armed and shownBy(nf.kind) and bar_index - nf.e1Bar <= DRAW_MAX_BACK
                newestDone := math.max(newestDone, nf.completedBar)
    if showLevelsInput
        for f in retained
            if shownBy(f.kind) and bar_index - drawLeftOf(f) <= DRAW_MAX_BACK and
                     not levelsWithheld(f.armed, f.hitWhich, f.completedBar, newestDone)
                int lx = levelLabelX(lvlColumn, labelX,
                     levelRightOf(f.hitWhich, f.hitBar, f.completedBar), leadReachUsed)
                array.push(lblXs, lx)
                array.push(lblYs, f.doneClose)
                if tierShown(f.hitWhich, f.hit1Bar)
                    array.push(lblXs, lx)
                    array.push(lblYs, f.targetP)
                if stopLabelShown(f.hitWhich)
                    array.push(lblXs, lx)
                    array.push(lblYs, f.stopP)
                if targetTiersInput >= 2 and tierShown(f.hitWhich, f.hit2Bar)
                    array.push(lblXs, lx)
                    array.push(lblYs, f.targetP2)
                if targetTiersInput >= 3 and tierShown(f.hitWhich, f.hit3Bar)
                    array.push(lblXs, lx)
                    array.push(lblYs, f.targetP3)
        for nf in neckRetained
            if shownBy(nf.kind) and bar_index - nf.e1Bar <= DRAW_MAX_BACK and
                     not levelsWithheld(nf.armed, nf.hitWhich, nf.completedBar, newestDone)
                int lx = levelLabelX(lvlColumn, labelX,
                     levelRightOf(nf.hitWhich, nf.hitBar, nf.completedBar), leadReachUsed)
                array.push(lblXs, lx)
                array.push(lblYs, nf.doneClose)
                if tierShown(nf.hitWhich, nf.hit1Bar)
                    array.push(lblXs, lx)
                    array.push(lblYs, nf.targetP)
                if stopLabelShown(nf.hitWhich)
                    array.push(lblXs, lx)
                    array.push(lblYs, nf.stopP)
                if targetTiersInput >= 2 and tierShown(nf.hitWhich, nf.hit2Bar)
                    array.push(lblXs, lx)
                    array.push(lblYs, nf.targetP2)
                if targetTiersInput >= 3 and tierShown(nf.hitWhich, nf.hit3Bar)
                    array.push(lblXs, lx)
                    array.push(lblYs, nf.targetP3)

    if not column
        for f in retained
            if not na(f.tag)
                array.push(lblXs, label.get_x(f.tag))
                array.push(lblYs, label.get_y(f.tag))
        for nf in neckRetained
            if not na(nf.tag)
                array.push(lblXs, label.get_x(nf.tag))
                array.push(lblYs, label.get_y(nf.tag))
        for f in expiredSet
            if not na(f.tag)
                array.push(lblXs, label.get_x(f.tag))
                array.push(lblYs, label.get_y(f.tag))
        for nf in neckExpired
            if not na(nf.tag)
                array.push(lblXs, label.get_x(nf.tag))
                array.push(lblYs, label.get_y(nf.tag))

    int idx = -1
    for f in active
        idx := idx + 1
        if not showFormingInput or not array.get(actDraw, idx) or not shownBy(f.kind)
            eraseFormation(f)
            continue
        int rightEdge = rightEdgeOf(f, projectUsed)
        int   x1u = boundStart(f.upper)
        int   x1l = boundStart(f.lower)
        float y1u = priceAt(f.upper, x1u)
        float y1l = priceAt(f.lower, x1l)
        float y2u = priceAt(f.upper, rightEdge)
        float y2l = priceAt(f.lower, rightEdge)
        color fc = familyColor(f.kind)
        int   tagX = column ? labelX : rightEdge
        float tagY = labelModeInput == LBL_MARKER or labelModeInput == LBL_OFF ? y2u :
             spreadLabelY(lblXs, lblYs, tagX, y2u, atrValue, 1, labelGapUsed)
        if na(f.upLine)
            if styleUsed == STYLE_GLOW
                f.upGlowOut := glowLine(x1u, y1u, rightEdge, y2u, fc,
                     GLOW_OUTER_WIDTH, GLOW_OUTER_TRANSP, line.style_solid)
                f.upGlowIn  := glowLine(x1u, y1u, rightEdge, y2u, fc,
                     GLOW_INNER_WIDTH, GLOW_INNER_TRANSP, line.style_solid)
                f.loGlowOut := glowLine(x1l, y1l, rightEdge, y2l, fc,
                     GLOW_OUTER_WIDTH, GLOW_OUTER_TRANSP, line.style_solid)
                f.loGlowIn  := glowLine(x1l, y1l, rightEdge, y2l, fc,
                     GLOW_INNER_WIDTH, GLOW_INNER_TRANSP, line.style_solid)
            f.upLine := line.new(x1 = x1u, y1 = y1u, x2 = rightEdge, y2 = y2u,
                 color = fc, width = widthUsed)
            f.loLine := line.new(x1 = x1l, y1 = y1l, x2 = rightEdge, y2 = y2l,
                 color = fc, width = widthUsed)
            if labelModeInput != LBL_OFF
                bool marker = labelModeInput == LBL_MARKER
                f.tag := label.new(x = tagX, y = tagY,
                     text = marker ? "" :
                     (labelModeInput == LBL_FULL ? formingText(f.kind) : f.kind),
                     style = marker ? label.style_circle : label.style_label_left,
                     color = marker ? fc : color.new(fc, 80),
                     textcolor = chart.fg_color, size = marker ? size.tiny : LABEL_SIZE,
                     tooltip = hoverNotesInput ?
                     tooltipText(f.kind, f.side, false, f.nested,
                     pctComplete(f.startBar, f.limitBar, bar_index)) : "")
                if column
                    f.leader := line.new(x1 = rightEdge, y1 = y2u, x2 = tagX, y2 = tagY,
                         color = color.new(fc, LEADER_TRANSP), width = 1,
                         style = line.style_dotted)
        else
            line.set_xy2(f.upLine, rightEdge, y2u)
            line.set_xy2(f.loLine, rightEdge, y2l)
            if not na(f.upGlowOut)
                line.set_xy2(f.upGlowOut, rightEdge, y2u)
                line.set_xy2(f.upGlowIn, rightEdge, y2u)
                line.set_xy2(f.loGlowOut, rightEdge, y2l)
                line.set_xy2(f.loGlowIn, rightEdge, y2l)
            if not na(f.tag)
                label.set_xy(f.tag, tagX, tagY)
                label.set_tooltip(f.tag, hoverNotesInput ?
                     tooltipText(f.kind, f.side, false, f.nested,
                     pctComplete(f.startBar, f.limitBar, bar_index)) : "")
            if not na(f.leader)
                line.set_xy1(f.leader, rightEdge, y2u)
                line.set_xy2(f.leader, tagX, tagY)
        bool wantFill = fillInput and not f.encloses and
             (not nearestFillUsed or array.get(actFill, idx))
        if wantFill and na(f.band)
            f.band := linefill.new(f.upLine, f.loLine, color.new(fc, fillTranspUsed))
        else if not wantFill and not na(f.band)
            linefill.delete(f.band)
            f.band := na
        bool attributionShown = labelModeInput == LBL_FULL or
             (labelModeInput != LBL_OFF and hoverNotesInput)
        string reading   = readingOf(f.kind)
        bool   wantArrow = projArrowInput and reading != R_NEUTRAL and attributionShown
        if wantArrow
            float r    = cappedR(formationHeight(f), rCapValue)
            float midY = (y2u + y2l) / 2
            int   dir  = reading == R_BULL ? 1 : -1
            int   run  = math.max(ARROW_MIN_RUN, projectUsed)
            if na(f.arrow)
                f.arrow := line.new(x1 = rightEdge, y1 = midY, x2 = rightEdge + run,
                     y2 = midY + dir * r, color = fc, width = widthUsed,
                     style = line.style_arrow_right)
            else
                line.set_xy1(f.arrow, rightEdge, midY)
                line.set_xy2(f.arrow, rightEdge + run, midY + dir * r)
        else if not na(f.arrow)
            line.delete(f.arrow)
            f.arrow := na
        bool wantLeg = projArrowInput and durationGoverned(f.kind)
        if wantLeg and na(f.leg)
            f.leg := line.new(x1 = f.startBar - POLE_LOOKBACK, y1 = f.legP1,
                 x2 = f.startBar, y2 = f.legP2, color = color.new(fc, LEG_TRANSP),
                 width = widthUsed, style = line.style_dotted)
        else if not wantLeg and not na(f.leg)
            line.delete(f.leg)
            f.leg := na
    for f in retained
        if not shownBy(f.kind)
            eraseFormation(f)
            continue
        int   leftBar = drawLeftOf(f)
        if bar_index - leftBar > DRAW_MAX_BACK
            eraseFormation(f)
            continue
        int   x1u     = boundStart(f.upper)
        int   x1l     = boundStart(f.lower)
        float y1u     = priceAt(f.upper, x1u)
        float y1l     = priceAt(f.lower, x1l)
        float y2u     = priceAt(f.upper, f.completedBar)
        float y2l     = priceAt(f.lower, f.completedBar)
        color fc      = familyColor(f.kind)
        float anchorY = f.side == 1 ? y2u : y2l
        bool  fresh   = na(f.upLine)
        if fresh
            if styleUsed == STYLE_GLOW
                f.upGlowOut := glowLine(x1u, y1u, f.completedBar, y2u, fc,
                     GLOW_OUTER_WIDTH, GLOW_OUTER_TRANSP + GLOW_RETAINED_DIM,
                     line.style_dotted)
                f.upGlowIn  := glowLine(x1u, y1u, f.completedBar, y2u, fc,
                     GLOW_INNER_WIDTH, GLOW_INNER_TRANSP + GLOW_RETAINED_DIM,
                     line.style_dotted)
                f.loGlowOut := glowLine(x1l, y1l, f.completedBar, y2l, fc,
                     GLOW_OUTER_WIDTH, GLOW_OUTER_TRANSP + GLOW_RETAINED_DIM,
                     line.style_dotted)
                f.loGlowIn  := glowLine(x1l, y1l, f.completedBar, y2l, fc,
                     GLOW_INNER_WIDTH, GLOW_INNER_TRANSP + GLOW_RETAINED_DIM,
                     line.style_dotted)
            f.upLine := line.new(x1 = x1u, y1 = y1u, x2 = f.completedBar,
                 y2 = y2u, color = color.new(fc, 55), width = widthUsed,
                 style = line.style_dotted)
            f.loLine := line.new(x1 = x1l, y1 = y1l, x2 = f.completedBar,
                 y2 = y2l, color = color.new(fc, 55), width = widthUsed,
                 style = line.style_dotted)
            if labelModeInput != LBL_OFF
                bool marker = labelModeInput == LBL_MARKER
                string full = completedText(f.kind, f.side)
                f.tag := label.new(x = f.completedBar, y = anchorY,
                     text = marker ? "" : (labelModeInput == LBL_FULL ? full : f.kind),
                     style = marker ? label.style_circle : (column ? label.style_label_left :
                     (f.side == 1 ? label.style_label_down : label.style_label_up)),
                     color = marker ? fc : color.new(fc, 82),
                     textcolor = chart.fg_color, size = marker ? size.tiny : LABEL_SIZE,
                     tooltip = hoverNotesInput ?
                     tooltipText(f.kind, f.side, true, f.nested, float(na)) : "")
                if column
                    f.leader := line.new(x1 = f.completedBar, y1 = anchorY,
                         x2 = f.completedBar, y2 = anchorY,
                         color = color.new(fc, LEADER_TRANSP), width = 1,
                         style = line.style_dotted)
        if not na(f.tag) and labelModeInput != LBL_MARKER and (column or fresh)
            int   tagX = column ? labelX : f.completedBar
            float tagY = spreadLabelY(lblXs, lblYs, tagX, anchorY, atrValue,
                 f.side == 1 ? 1 : -1, labelGapUsed)
            label.set_xy(f.tag, tagX, tagY)
            if not na(f.leader)
                line.set_xy1(f.leader, f.completedBar, anchorY)
                line.set_xy2(f.leader, tagX, tagY)
        if not na(f.tag)
            label.set_tooltip(f.tag, hoverNotesInput ?
                 tooltipText(f.kind, f.side, true, f.nested, float(na)) : "")
        bool wantFill = fillInput and not f.encloses and not na(f.upLine)
        if wantFill and na(f.band)
            f.band := linefill.new(f.upLine, f.loLine,
                 color.new(fc, math.min(99, fillTranspUsed + FILL_RETAINED_DIM)))
        else if not wantFill and not na(f.band)
            linefill.delete(f.band)
            f.band := na
        string reading = readingOf(f.kind)
        bool attributionShown = labelModeInput != LBL_OFF and
             hoverNotesInput
        if projArrowInput and reading != R_NEUTRAL and attributionShown and
             (not showLevelsInput or
             not levelsWithheld(f.armed, f.hitWhich, f.completedBar, newestDone))
            if na(f.arrow)
                float r   = cappedR(formationHeight(f), f.doneCap)
                int   run = math.max(ARROW_MIN_RUN, projectUsed)
                int   dir = reading == R_BULL ? 1 : -1
                f.arrow := line.new(x1 = f.completedBar, y1 = f.doneClose,
                     x2 = f.completedBar + run, y2 = f.doneClose + dir * r,
                     color = color.new(fc, 55), width = widthUsed,
                     style = line.style_arrow_right)
            if na(f.leg) and durationGoverned(f.kind) and
                 bar_index - (f.startBar - POLE_LOOKBACK) <= DRAW_MAX_BACK
                f.leg := line.new(x1 = f.startBar - POLE_LOOKBACK, y1 = f.legP1,
                     x2 = f.startBar, y2 = f.legP2, color = color.new(fc, LEG_TRANSP),
                     width = widthUsed, style = line.style_dotted)
        else
            if not na(f.arrow)
                line.delete(f.arrow)
                f.arrow := na
            if not na(f.leg)
                line.delete(f.leg)
                f.leg := na
        if showLevelsInput and not levelsWithheld(f.armed, f.hitWhich, f.completedBar, newestDone)
            int lvlX  = levelRightOf(f.hitWhich, f.hitBar, f.completedBar)
            int lblX3 = levelLabelX(lvlColumn, labelX, lvlX, leadReachUsed)
            int lvl1X = tierRightOf(f.hit1Bar, lvlX)
            bool lvlText = true
            if na(f.entryLn)
                if styleUsed == STYLE_GLOW
                    f.entryGlowOut := glowLine(f.completedBar, f.doneClose, lvlX,
                         f.doneClose, fc, GLOW_OUTER_WIDTH,
                         GLOW_OUTER_TRANSP + GLOW_RETAINED_DIM, line.style_solid)
                    f.entryGlowIn := glowLine(f.completedBar, f.doneClose, lvlX,
                         f.doneClose, fc, GLOW_INNER_WIDTH,
                         GLOW_INNER_TRANSP + GLOW_RETAINED_DIM, line.style_solid)
                f.entryLn := line.new(x1 = f.completedBar, y1 = f.doneClose,
                     x2 = lvlX, y2 = f.doneClose, color = fc, width = widthUsed)
                f.targetZone := box.new(left = f.completedBar,
                     top = math.max(f.doneClose, f.targetP), right = lvl1X,
                     bottom = math.min(f.doneClose, f.targetP), border_color = na,
                     bgcolor = color.new(targetColorInput, ZONE_TRANSP))
                f.stopZone := box.new(left = f.completedBar,
                     top = math.max(f.doneClose, f.stopP), right = lvlX,
                     bottom = math.min(f.doneClose, f.stopP), border_color = na,
                     bgcolor = color.new(stopColorInput, ZONE_TRANSP))
                f.entryTag := label.new(x = lblX3, y = f.doneClose,
                     text = lvlText ? entryText(f.doneClose) : "",
                     style = label.style_label_left,
                     color = color.new(fc, 80), textcolor = chart.fg_color,
                     size = LABEL_SIZE, tooltip = levelNote())
                f.targetTag := label.new(x = lblX3, y = f.targetP,
                     text = lvlText ?
                         levelTag("Target", targetRInput, f.targetP, false, false) : "",
                     style = label.style_label_left,
                     color = color.new(targetColorInput, 80),
                     textcolor = chart.fg_color, size = LABEL_SIZE,
                     tooltip = levelNote())
                f.stopTag := label.new(x = lblX3, y = f.stopP,
                     text = lvlText ?
                         stopTag(f.stopP, false, false, f.doneClose,
                         formationRUnit(f)) : "",
                     style = label.style_label_left,
                     color = color.new(stopColorInput, 80),
                     textcolor = chart.fg_color, size = LABEL_SIZE,
                     tooltip = stopNote(f.doneClose, f.stopP))
            bool loseStop = f.hitWhich == HIT_TARGET
            bool loseT1   = f.hitWhich != HIT_NONE and f.hit1Bar == -1
            bool loseT2   = f.hitWhich != HIT_NONE and f.hit2Bar == -1
            bool loseT3   = f.hitWhich != HIT_NONE and f.hit3Bar == -1
            if unreachedInput == UNREACH_REMOVE
                if loseStop and not na(f.stopZone)
                    box.delete(f.stopZone)
                    label.delete(f.stopTag)
                    f.stopZone := na
                    f.stopTag  := na
            else
                if loseStop and not na(f.stopZone)
                    if not na(f.stopTag)
                        label.set_color(f.stopTag, color.new(stopColorInput, LABEL_FADE_TRANSP))
                        label.set_textcolor(f.stopTag, color.new(chart.fg_color, TEXT_FADE_TRANSP))
                if loseT1 and not na(f.targetZone)
                    if not na(f.targetTag)
                        label.set_color(f.targetTag, color.new(targetColorInput, LABEL_FADE_TRANSP))
                        label.set_textcolor(f.targetTag, color.new(chart.fg_color, TEXT_FADE_TRANSP))
            line.set_x2(f.entryLn, lvlX)
            if not na(f.entryGlowOut)
                line.set_x2(f.entryGlowOut, lvlX)
            if not na(f.entryGlowIn)
                line.set_x2(f.entryGlowIn, lvlX)
            if not na(f.entryTag)
                label.set_x(f.entryTag, lblX3)
                label.set_text(f.entryTag, lvlText ? entryText(f.doneClose) : "")
            bool tHit = f.hit1Bar >= 0
            bool sHit = f.hitWhich == HIT_STOP or f.hitWhich == HIT_BOTH
            bool amb1 = f.hitWhich == HIT_BOTH and f.hit1Bar == f.hitBar
            if not tierShown(f.hitWhich, f.hit1Bar)
                if not na(f.targetZone)
                    box.delete(f.targetZone)
                    f.targetZone := na
                if not na(f.targetTag)
                    label.delete(f.targetTag)
                    f.targetTag := na
            if not na(f.targetZone)
                box.set_right(f.targetZone, lvl1X)
                zoneLook(f.targetZone, tHit, loseT1, targetColorInput)
            if not na(f.targetTag)
                label.set_x(f.targetTag, lblX3)
                label.set_text(f.targetTag, lvlText ? levelTag(targetName(1), targetRInput,
                     f.targetP, tHit, amb1) : "")
            if not na(f.stopZone)
                box.set_right(f.stopZone, lvlX)
                zoneLook(f.stopZone, sHit, loseStop, stopColorInput)
            if not na(f.stopTag)
                label.set_x(f.stopTag, lblX3)
                label.set_text(f.stopTag, lvlText ? stopTag(f.stopP,
                     sHit, f.hitWhich == HIT_BOTH, f.doneClose,
                     formationRUnit(f)) : "")
            bool lead = lblX3 != lvlX and lvlText
            f.entryLead := levelLead(f.entryLead, lead, lvlX, lblX3, f.doneClose,
                 color.new(fc, LEADER_TRANSP))
            f.targetLead := levelLead(f.targetLead,
                 lead and not na(f.targetZone) and not na(f.targetTag),
                 lvl1X, lblX3, f.targetP, color.new(targetColorInput,
                 loseT1 ? LABEL_FADE_TRANSP : LEADER_TRANSP))
            f.stopLead := levelLead(f.stopLead, lead and not na(f.stopZone),
                 lvlX, lblX3, f.stopP, color.new(stopColorInput,
                 loseStop ? LABEL_FADE_TRANSP : LEADER_TRANSP))
            bool want2 = targetTiersInput >= 2 and tierShown(f.hitWhich, f.hit2Bar)
            bool want3 = targetTiersInput >= 3 and tierShown(f.hitWhich, f.hit3Bar)
            int  lvl2X = tierRightOf(f.hit2Bar, lvlX)
            int  lvl3X = tierRightOf(f.hit3Bar, lvlX)
            bool hit2  = f.hit2Bar >= 0
            bool hit3  = f.hit3Bar >= 0
            bool amb2  = f.hitWhich == HIT_BOTH and f.hit2Bar == f.hitBar
            bool amb3  = f.hitWhich == HIT_BOTH and f.hit3Bar == f.hitBar
            bool tag2  = want2 and lvlText
            bool tag3  = want3 and lvlText
            f.targetZone2 := tierZone(f.targetZone2, want2, f.targetP,
                 f.targetP2, f.completedBar, lvl2X, hit2, loseT2)
            f.targetTag2 := tierLabel(f.targetTag2, want2, lvlText, 2,
                 f.targetP2, lblX3, hit2, amb2, loseT2)
            f.targetLead2 := levelLead(f.targetLead2,
                 lead and tag2, lvl2X, lblX3, f.targetP2,
                 color.new(targetColorInput,
                 loseT2 ? LABEL_FADE_TRANSP : LEADER_TRANSP))
            f.targetZone3 := tierZone(f.targetZone3, want3, f.targetP2,
                 f.targetP3, f.completedBar, lvl3X, hit3, loseT3)
            f.targetTag3 := tierLabel(f.targetTag3, want3, lvlText, 3,
                 f.targetP3, lblX3, hit3, amb3, loseT3)
            f.targetLead3 := levelLead(f.targetLead3,
                 lead and tag3, lvl3X, lblX3, f.targetP3,
                 color.new(targetColorInput,
                 loseT3 ? LABEL_FADE_TRANSP : LEADER_TRANSP))
        else if not na(f.entryLn)
            line.delete(f.entryLn)
            line.delete(f.entryGlowOut)
            line.delete(f.entryGlowIn)
            box.delete(f.targetZone)
            box.delete(f.targetZone2)
            box.delete(f.targetZone3)
            box.delete(f.stopZone)
            label.delete(f.entryTag)
            label.delete(f.targetTag)
            label.delete(f.targetTag2)
            label.delete(f.targetTag3)
            label.delete(f.stopTag)
            line.delete(f.entryLead)
            line.delete(f.targetLead)
            line.delete(f.targetLead2)
            line.delete(f.targetLead3)
            line.delete(f.stopLead)
            f.entryLn := na
            f.entryGlowOut := na
            f.entryGlowIn := na
            f.targetZone := na
            f.targetZone2 := na
            f.targetZone3 := na
            f.stopZone := na
            f.entryTag := na
            f.targetTag := na
            f.targetTag2 := na
            f.targetTag3 := na
            f.stopTag := na
            f.entryLead := na
            f.targetLead := na
            f.targetLead2 := na
            f.targetLead3 := na
            f.stopLead := na

    string expStyle = line.style_dashed
    color  expColor = color.new(expiredColorInput, EXPIRED_TRANSP)
    for f in expiredSet
        if not shownBy(f.kind)
            eraseFormation(f)
            continue
        int leftBar = drawLeftOf(f)
        if bar_index - leftBar > DRAW_MAX_BACK
            eraseFormation(f)
            continue
        int   x1u     = boundStart(f.upper)
        int   x1l     = boundStart(f.lower)
        float y1u     = priceAt(f.upper, x1u)
        float y1l     = priceAt(f.lower, x1l)
        float y2u     = priceAt(f.upper, f.completedBar)
        float y2l     = priceAt(f.lower, f.completedBar)
        float anchorY = (y2u + y2l) / 2
        bool  fresh   = na(f.upLine)
        if fresh
            if styleUsed == STYLE_GLOW
                f.upGlowOut := glowLine(x1u, y1u, f.completedBar, y2u, expiredColorInput,
                     GLOW_OUTER_WIDTH, GLOW_OUTER_TRANSP + GLOW_RETAINED_DIM, expStyle)
                f.upGlowIn  := glowLine(x1u, y1u, f.completedBar, y2u, expiredColorInput,
                     GLOW_INNER_WIDTH, GLOW_INNER_TRANSP + GLOW_RETAINED_DIM, expStyle)
                f.loGlowOut := glowLine(x1l, y1l, f.completedBar, y2l, expiredColorInput,
                     GLOW_OUTER_WIDTH, GLOW_OUTER_TRANSP + GLOW_RETAINED_DIM, expStyle)
                f.loGlowIn  := glowLine(x1l, y1l, f.completedBar, y2l, expiredColorInput,
                     GLOW_INNER_WIDTH, GLOW_INNER_TRANSP + GLOW_RETAINED_DIM, expStyle)
            f.upLine := line.new(x1 = x1u, y1 = y1u, x2 = f.completedBar,
                 y2 = y2u, color = expColor, width = widthUsed, style = expStyle)
            f.loLine := line.new(x1 = x1l, y1 = y1l, x2 = f.completedBar,
                 y2 = y2l, color = expColor, width = widthUsed, style = expStyle)
            if labelModeInput != LBL_OFF
                bool marker = labelModeInput == LBL_MARKER
                f.tag := label.new(x = f.completedBar, y = anchorY,
                     text = marker ? "" : (labelModeInput == LBL_FULL ?
                     f.kind + " · " + f.expiredWhy : f.kind),
                     style = marker ? label.style_circle : (column ?
                     label.style_label_left : label.style_label_center),
                     color = marker ? expColor : color.new(expiredColorInput, 82),
                     textcolor = chart.fg_color, size = marker ? size.tiny : LABEL_SIZE,
                     tooltip = hoverNotesInput ? expiredTooltip(f.kind, f.expiredWhy) : "")
                if column
                    f.leader := line.new(x1 = f.completedBar, y1 = anchorY,
                         x2 = f.completedBar, y2 = anchorY,
                         color = color.new(expiredColorInput, LEADER_TRANSP), width = 1,
                         style = line.style_dotted)
        if not na(f.tag) and labelModeInput != LBL_MARKER and (column or fresh)
            int   tagX = column ? labelX : f.completedBar
            float tagY = spreadLabelY(lblXs, lblYs, tagX, anchorY, atrValue, 1, labelGapUsed)
            label.set_xy(f.tag, tagX, tagY)
            if not na(f.leader)
                line.set_xy1(f.leader, f.completedBar, anchorY)
                line.set_xy2(f.leader, tagX, tagY)
        bool wantExpFill = fillInput and not f.encloses and not na(f.upLine)
        if wantExpFill and na(f.band)
            f.band := linefill.new(f.upLine, f.loLine,
                 color.new(expiredColorInput, math.min(99, fillTranspUsed + FILL_EXPIRED_DIM)))
        else if not wantExpFill and not na(f.band)
            linefill.delete(f.band)
            f.band := na

    int nkIdx = -1
    for nf in neckActive
        nkIdx := nkIdx + 1
        if not showFormingInput or not shownBy(nf.kind) or
             not array.get(nkDraw, nkIdx)
            eraseNeck(nf)
            continue
        int   rightEdge = bar_index + projectUsed
        float neckY     = priceAt(nf.neck, rightEdge)
        color fc        = familyColor(nf.kind)
        int   lblDir    = neckSideOf(nf.kind) == -1 ? 1 : -1
        int   tagX      = column ? labelX : rightEdge
        float tagY      = labelModeInput == LBL_MARKER or labelModeInput == LBL_OFF ? nf.e2P :
             spreadLabelY(lblXs, lblYs, tagX, nf.e2P, atrValue, lblDir, labelGapUsed)
        if na(nf.neckLn)
            nf.outline := polyline.new(neckPoints(nf), line_color = fc,
                 line_width = widthUsed)
            nf.neckLn := line.new(x1 = nf.neck.b1, y1 = nf.neck.p1, x2 = rightEdge,
                 y2 = neckY, color = fc, width = widthUsed)
            if labelModeInput != LBL_OFF
                bool marker = labelModeInput == LBL_MARKER
                nf.tag := label.new(x = tagX, y = tagY,
                     text = marker ? "" : (labelModeInput == LBL_FULL ?
                     formingText(nf.kind) : nf.kind),
                     style = marker ? label.style_circle : label.style_label_left,
                     color = marker ? fc : color.new(fc, 80),
                     textcolor = chart.fg_color, size = marker ? size.tiny : LABEL_SIZE,
                     tooltip = hoverNotesInput ? neckTooltip(nf.kind, nf.side, false,
                     pctComplete(nf.startBar, nf.limitBar, bar_index)) : "")
                if column
                    nf.leader := line.new(x1 = rightEdge, y1 = neckY, x2 = tagX,
                         y2 = tagY, color = color.new(fc, LEADER_TRANSP), width = 1,
                         style = line.style_dotted)
        else
            line.set_xy2(nf.neckLn, rightEdge, neckY)
            if not na(nf.tag)
                label.set_xy(nf.tag, tagX, tagY)
                label.set_tooltip(nf.tag, hoverNotesInput ?
                     neckTooltip(nf.kind, nf.side, false,
                     pctComplete(nf.startBar, nf.limitBar, bar_index)) : "")
            if not na(nf.leader)
                line.set_xy1(nf.leader, rightEdge, neckY)
                line.set_xy2(nf.leader, tagX, tagY)
        bool attributionShown = labelModeInput == LBL_FULL or
             (labelModeInput != LBL_OFF and hoverNotesInput)
        if projArrowInput and attributionShown
            float r   = cappedR(neckHeight(nf), rCapValue)
            int   dir = neckSideOf(nf.kind)
            int   run = math.max(ARROW_MIN_RUN, projectUsed)
            if na(nf.arrow)
                nf.arrow := line.new(x1 = rightEdge, y1 = neckY, x2 = rightEdge + run,
                     y2 = neckY + dir * r, color = fc, width = widthUsed,
                     style = line.style_arrow_right)
            else
                line.set_xy1(nf.arrow, rightEdge, neckY)
                line.set_xy2(nf.arrow, rightEdge + run, neckY + dir * r)
        else if not na(nf.arrow)
            line.delete(nf.arrow)
            nf.arrow := na
        bool wantLeg = projArrowInput and nf.hasLeg
        if wantLeg and na(nf.leg)
            nf.leg := line.new(x1 = nf.e1Bar - POLE_LOOKBACK, y1 = nf.legP1,
                 x2 = nf.e1Bar, y2 = nf.e1P, color = color.new(fc, LEG_TRANSP),
                 width = widthUsed, style = line.style_dotted)
        else if not wantLeg and not na(nf.leg)
            line.delete(nf.leg)
            nf.leg := na

    for nf in neckRetained
        if not shownBy(nf.kind)
            eraseNeck(nf)
            continue
        if bar_index - nf.e1Bar > DRAW_MAX_BACK
            eraseNeck(nf)
            continue
        color fc       = familyColor(nf.kind)
        float neckEndY = priceAt(nf.neck, nf.completedBar)
        bool  fresh    = na(nf.neckLn)
        if fresh
            nf.outline := polyline.new(neckPoints(nf), line_color = color.new(fc, 55),
                 line_width = widthUsed, line_style = line.style_dotted)
            nf.neckLn := line.new(x1 = nf.neck.b1, y1 = nf.neck.p1,
                 x2 = nf.completedBar, y2 = neckEndY, color = color.new(fc, 55),
                 width = widthUsed, style = line.style_dotted)
            if labelModeInput != LBL_OFF
                bool marker = labelModeInput == LBL_MARKER
                nf.tag := label.new(x = nf.completedBar, y = nf.doneClose,
                     text = marker ? "" : (labelModeInput == LBL_FULL ?
                     completedText(nf.kind, nf.side) : nf.kind),
                     style = marker ? label.style_circle : (column ?
                     label.style_label_left : (nf.side == 1 ? label.style_label_down :
                     label.style_label_up)),
                     color = marker ? fc : color.new(fc, 82),
                     textcolor = chart.fg_color, size = marker ? size.tiny : LABEL_SIZE,
                     tooltip = hoverNotesInput ? neckTooltip(nf.kind, nf.side, true, float(na)) : "")
                if column
                    nf.leader := line.new(x1 = nf.completedBar, y1 = nf.doneClose,
                         x2 = nf.completedBar, y2 = nf.doneClose,
                         color = color.new(fc, LEADER_TRANSP), width = 1,
                         style = line.style_dotted)
        if not na(nf.tag) and labelModeInput != LBL_MARKER and (column or fresh)
            int   tagX = column ? labelX : nf.completedBar
            float tagY = spreadLabelY(lblXs, lblYs, tagX, nf.doneClose, atrValue,
                 nf.side == 1 ? 1 : -1, labelGapUsed)
            label.set_xy(nf.tag, tagX, tagY)
            if not na(nf.leader)
                line.set_xy1(nf.leader, nf.completedBar, nf.doneClose)
                line.set_xy2(nf.leader, tagX, tagY)
        bool attributionShown = labelModeInput != LBL_OFF and
             hoverNotesInput
        if projArrowInput and attributionShown and
             (not showLevelsInput or
             not levelsWithheld(nf.armed, nf.hitWhich, nf.completedBar, newestDone))
            if na(nf.arrow)
                float r   = cappedR(neckHeight(nf), nf.doneCap)
                int   run = math.max(ARROW_MIN_RUN, projectUsed)
                nf.arrow := line.new(x1 = nf.completedBar, y1 = nf.doneClose,
                     x2 = nf.completedBar + run, y2 = nf.doneClose + nf.side * r,
                     color = color.new(fc, 55), width = widthUsed,
                     style = line.style_arrow_right)
            if na(nf.leg) and nf.hasLeg and
                 bar_index - (nf.e1Bar - POLE_LOOKBACK) <= DRAW_MAX_BACK
                nf.leg := line.new(x1 = nf.e1Bar - POLE_LOOKBACK, y1 = nf.legP1,
                     x2 = nf.e1Bar, y2 = nf.e1P, color = color.new(fc, LEG_TRANSP),
                     width = widthUsed, style = line.style_dotted)
        else
            if not na(nf.arrow)
                line.delete(nf.arrow)
                nf.arrow := na
            if not na(nf.leg)
                line.delete(nf.leg)
                nf.leg := na
        if showLevelsInput and not levelsWithheld(nf.armed, nf.hitWhich, nf.completedBar, newestDone)
            int lvlX  = levelRightOf(nf.hitWhich, nf.hitBar, nf.completedBar)
            int lblX3 = levelLabelX(lvlColumn, labelX, lvlX, leadReachUsed)
            int lvl1X = tierRightOf(nf.hit1Bar, lvlX)
            bool lvlText = true
            if na(nf.entryLn)
                if styleUsed == STYLE_GLOW
                    nf.entryGlowOut := glowLine(nf.completedBar, nf.doneClose,
                         lvlX, nf.doneClose, fc, GLOW_OUTER_WIDTH,
                         GLOW_OUTER_TRANSP + GLOW_RETAINED_DIM, line.style_solid)
                    nf.entryGlowIn := glowLine(nf.completedBar, nf.doneClose,
                         lvlX, nf.doneClose, fc, GLOW_INNER_WIDTH,
                         GLOW_INNER_TRANSP + GLOW_RETAINED_DIM, line.style_solid)
                nf.entryLn := line.new(x1 = nf.completedBar, y1 = nf.doneClose,
                     x2 = lvlX, y2 = nf.doneClose, color = fc, width = widthUsed)
                nf.targetZone := box.new(left = nf.completedBar,
                     top = math.max(nf.doneClose, nf.targetP), right = lvl1X,
                     bottom = math.min(nf.doneClose, nf.targetP), border_color = na,
                     bgcolor = color.new(targetColorInput, ZONE_TRANSP))
                nf.stopZone := box.new(left = nf.completedBar,
                     top = math.max(nf.doneClose, nf.stopP), right = lvlX,
                     bottom = math.min(nf.doneClose, nf.stopP), border_color = na,
                     bgcolor = color.new(stopColorInput, ZONE_TRANSP))
                nf.entryTag := label.new(x = lblX3, y = nf.doneClose,
                     text = lvlText ? entryText(nf.doneClose) : "",
                     style = label.style_label_left,
                     color = color.new(fc, 80), textcolor = chart.fg_color,
                     size = LABEL_SIZE, tooltip = levelNote())
                nf.targetTag := label.new(x = lblX3, y = nf.targetP,
                     text = lvlText ?
                         levelTag("Target", targetRInput, nf.targetP, false, false) : "",
                     style = label.style_label_left,
                     color = color.new(targetColorInput, 80),
                     textcolor = chart.fg_color, size = LABEL_SIZE,
                     tooltip = levelNote())
                nf.stopTag := label.new(x = lblX3, y = nf.stopP,
                     text = lvlText ?
                         stopTag(nf.stopP, false, false, nf.doneClose,
                         neckRUnit(nf)) : "",
                     style = label.style_label_left,
                     color = color.new(stopColorInput, 80),
                     textcolor = chart.fg_color, size = LABEL_SIZE,
                     tooltip = stopNote(nf.doneClose, nf.stopP))
            bool loseStop = nf.hitWhich == HIT_TARGET
            bool loseT1   = nf.hitWhich != HIT_NONE and nf.hit1Bar == -1
            bool loseT2   = nf.hitWhich != HIT_NONE and nf.hit2Bar == -1
            bool loseT3   = nf.hitWhich != HIT_NONE and nf.hit3Bar == -1
            if unreachedInput == UNREACH_REMOVE
                if loseStop and not na(nf.stopZone)
                    box.delete(nf.stopZone)
                    label.delete(nf.stopTag)
                    nf.stopZone := na
                    nf.stopTag  := na
            else
                if loseStop and not na(nf.stopZone)
                    if not na(nf.stopTag)
                        label.set_color(nf.stopTag, color.new(stopColorInput, LABEL_FADE_TRANSP))
                        label.set_textcolor(nf.stopTag, color.new(chart.fg_color, TEXT_FADE_TRANSP))
                if loseT1 and not na(nf.targetZone)
                    if not na(nf.targetTag)
                        label.set_color(nf.targetTag, color.new(targetColorInput, LABEL_FADE_TRANSP))
                        label.set_textcolor(nf.targetTag, color.new(chart.fg_color, TEXT_FADE_TRANSP))
            line.set_x2(nf.entryLn, lvlX)
            if not na(nf.entryGlowOut)
                line.set_x2(nf.entryGlowOut, lvlX)
            if not na(nf.entryGlowIn)
                line.set_x2(nf.entryGlowIn, lvlX)
            if not na(nf.entryTag)
                label.set_x(nf.entryTag, lblX3)
                label.set_text(nf.entryTag, lvlText ? entryText(nf.doneClose) : "")
            bool tHit = nf.hit1Bar >= 0
            bool sHit = nf.hitWhich == HIT_STOP or nf.hitWhich == HIT_BOTH
            bool amb1 = nf.hitWhich == HIT_BOTH and nf.hit1Bar == nf.hitBar
            if not tierShown(nf.hitWhich, nf.hit1Bar)
                if not na(nf.targetZone)
                    box.delete(nf.targetZone)
                    nf.targetZone := na
                if not na(nf.targetTag)
                    label.delete(nf.targetTag)
                    nf.targetTag := na
            if not na(nf.targetZone)
                box.set_right(nf.targetZone, lvl1X)
                zoneLook(nf.targetZone, tHit, loseT1, targetColorInput)
            if not na(nf.targetTag)
                label.set_x(nf.targetTag, lblX3)
                label.set_text(nf.targetTag, lvlText ? levelTag(targetName(1), targetRInput,
                     nf.targetP, tHit, amb1) : "")
            if not na(nf.stopZone)
                box.set_right(nf.stopZone, lvlX)
                zoneLook(nf.stopZone, sHit, loseStop, stopColorInput)
            if not na(nf.stopTag)
                label.set_x(nf.stopTag, lblX3)
                label.set_text(nf.stopTag, lvlText ? stopTag(nf.stopP,
                     sHit, nf.hitWhich == HIT_BOTH, nf.doneClose,
                     neckRUnit(nf)) : "")
            bool lead = lblX3 != lvlX and lvlText
            nf.entryLead := levelLead(nf.entryLead, lead, lvlX, lblX3,
                 nf.doneClose, color.new(fc, LEADER_TRANSP))
            nf.targetLead := levelLead(nf.targetLead,
                 lead and not na(nf.targetZone) and not na(nf.targetTag),
                 lvl1X, lblX3, nf.targetP, color.new(targetColorInput,
                 loseT1 ? LABEL_FADE_TRANSP : LEADER_TRANSP))
            nf.stopLead := levelLead(nf.stopLead, lead and not na(nf.stopZone),
                 lvlX, lblX3, nf.stopP, color.new(stopColorInput,
                 loseStop ? LABEL_FADE_TRANSP : LEADER_TRANSP))
            bool want2 = targetTiersInput >= 2 and tierShown(nf.hitWhich, nf.hit2Bar)
            bool want3 = targetTiersInput >= 3 and tierShown(nf.hitWhich, nf.hit3Bar)
            int  lvl2X = tierRightOf(nf.hit2Bar, lvlX)
            int  lvl3X = tierRightOf(nf.hit3Bar, lvlX)
            bool hit2  = nf.hit2Bar >= 0
            bool hit3  = nf.hit3Bar >= 0
            bool amb2  = nf.hitWhich == HIT_BOTH and nf.hit2Bar == nf.hitBar
            bool amb3  = nf.hitWhich == HIT_BOTH and nf.hit3Bar == nf.hitBar
            bool tag2  = want2 and lvlText
            bool tag3  = want3 and lvlText
            nf.targetZone2 := tierZone(nf.targetZone2, want2, nf.targetP,
                 nf.targetP2, nf.completedBar, lvl2X, hit2, loseT2)
            nf.targetTag2 := tierLabel(nf.targetTag2, want2, lvlText, 2,
                 nf.targetP2, lblX3, hit2, amb2, loseT2)
            nf.targetLead2 := levelLead(nf.targetLead2,
                 lead and tag2, lvl2X, lblX3, nf.targetP2,
                 color.new(targetColorInput,
                 loseT2 ? LABEL_FADE_TRANSP : LEADER_TRANSP))
            nf.targetZone3 := tierZone(nf.targetZone3, want3, nf.targetP2,
                 nf.targetP3, nf.completedBar, lvl3X, hit3, loseT3)
            nf.targetTag3 := tierLabel(nf.targetTag3, want3, lvlText, 3,
                 nf.targetP3, lblX3, hit3, amb3, loseT3)
            nf.targetLead3 := levelLead(nf.targetLead3,
                 lead and tag3, lvl3X, lblX3, nf.targetP3,
                 color.new(targetColorInput,
                 loseT3 ? LABEL_FADE_TRANSP : LEADER_TRANSP))
        else if not na(nf.entryLn)
            line.delete(nf.entryLn)
            line.delete(nf.entryGlowOut)
            line.delete(nf.entryGlowIn)
            box.delete(nf.targetZone)
            box.delete(nf.targetZone2)
            box.delete(nf.targetZone3)
            box.delete(nf.stopZone)
            label.delete(nf.entryTag)
            label.delete(nf.targetTag)
            label.delete(nf.targetTag2)
            label.delete(nf.targetTag3)
            label.delete(nf.stopTag)
            line.delete(nf.entryLead)
            line.delete(nf.targetLead)
            line.delete(nf.targetLead2)
            line.delete(nf.targetLead3)
            line.delete(nf.stopLead)
            nf.entryLn := na
            nf.entryGlowOut := na
            nf.entryGlowIn := na
            nf.targetZone := na
            nf.targetZone2 := na
            nf.targetZone3 := na
            nf.stopZone := na
            nf.entryTag := na
            nf.targetTag := na
            nf.targetTag2 := na
            nf.targetTag3 := na
            nf.stopTag := na
            nf.entryLead := na
            nf.targetLead := na
            nf.targetLead2 := na
            nf.targetLead3 := na
            nf.stopLead := na

    for nf in neckExpired
        if not shownBy(nf.kind)
            eraseNeck(nf)
            continue
        if bar_index - nf.e1Bar > DRAW_MAX_BACK
            eraseNeck(nf)
            continue
        float neckEndY = priceAt(nf.neck, nf.completedBar)
        bool  fresh    = na(nf.neckLn)
        if fresh
            nf.outline := polyline.new(neckPoints(nf), line_color = expColor,
                 line_width = widthUsed, line_style = expStyle)
            nf.neckLn := line.new(x1 = nf.neck.b1, y1 = nf.neck.p1,
                 x2 = nf.completedBar, y2 = neckEndY, color = expColor,
                 width = widthUsed, style = expStyle)
            if labelModeInput != LBL_OFF
                bool marker = labelModeInput == LBL_MARKER
                nf.tag := label.new(x = nf.completedBar, y = neckEndY,
                     text = marker ? "" : (labelModeInput == LBL_FULL ?
                     nf.kind + " · " + nf.expiredWhy : nf.kind),
                     style = marker ? label.style_circle : (column ?
                     label.style_label_left : label.style_label_center),
                     color = marker ? expColor : color.new(expiredColorInput, 82),
                     textcolor = chart.fg_color, size = marker ? size.tiny : LABEL_SIZE,
                     tooltip = hoverNotesInput ? expiredTooltip(nf.kind, nf.expiredWhy) : "")
                if column
                    nf.leader := line.new(x1 = nf.completedBar, y1 = neckEndY,
                         x2 = nf.completedBar, y2 = neckEndY,
                         color = color.new(expiredColorInput, LEADER_TRANSP), width = 1,
                         style = line.style_dotted)
        if not na(nf.tag) and labelModeInput != LBL_MARKER and (column or fresh)
            int   tagX = column ? labelX : nf.completedBar
            float tagY = spreadLabelY(lblXs, lblYs, tagX, neckEndY, atrValue, 1,
                 labelGapUsed)
            label.set_xy(nf.tag, tagX, tagY)
            if not na(nf.leader)
                line.set_xy1(nf.leader, nf.completedBar, neckEndY)
                line.set_xy2(nf.leader, tagX, tagY)

    table.clear(lvlTable, 0, 0, TBL_COLS - 1, TBL_ROWS - 1)
    if showTableInput and showLevelsInput
        table.set_position(lvlTable, tablePos(tablePosInput))
        string sz    = tableSize(tableSizeInput)
        color  fgTxt = color.new(chart.fg_color, 0)
        color  hdTxt = color.new(chart.fg_color, 30)
        array<LevelRow> rows = array.new<LevelRow>()
        for f in retained
            if shownBy(f.kind) and bar_index - drawLeftOf(f) <= DRAW_MAX_BACK
                addRow(rows, LevelRow.new(bar = f.completedBar, name = f.kind,
                     reading = readingPhrase(f.kind),
                     pctDone = pctComplete(f.startBar, f.limitBar, f.completedBar),
                     armed = f.armed,
                     side = f.side, doneAt = f.doneTime,
                     h1 = f.hit1Bar, h2 = f.hit2Bar, h3 = f.hit3Bar,
                     h1At = f.hit1Time, h2At = f.hit2Time, h3At = f.hit3Time,
                     stopAt = f.stopTime,
                     which = f.hitWhich, entry = f.doneClose, t1 = f.targetP, t2 = f.targetP2,
                     t3 = f.targetP3, stop = f.stopP, rUnit = formationRUnit(f)))
        for nf in neckRetained
            if shownBy(nf.kind) and bar_index - nf.e1Bar <= DRAW_MAX_BACK
                addRow(rows, LevelRow.new(bar = nf.completedBar, name = nf.kind,
                     reading = readingPhrase(nf.kind),
                     pctDone = pctComplete(nf.startBar, nf.limitBar, nf.completedBar),
                     armed = nf.armed,
                     side = nf.side, doneAt = nf.doneTime,
                     h1 = nf.hit1Bar, h2 = nf.hit2Bar, h3 = nf.hit3Bar,
                     h1At = nf.hit1Time, h2At = nf.hit2Time, h3At = nf.hit3Time,
                     stopAt = nf.stopTime,
                     which = nf.hitWhich, entry = nf.doneClose, t1 = nf.targetP, t2 = nf.targetP2,
                     t3 = nf.targetP3, stop = nf.stopP, rUnit = neckRUnit(nf)))
        int entryRow = TBL_ENTRY_ROW
        int stopRow  = entryRow + 1 + targetTiersInput
        int sizeRow  = stopRow + 1
        if array.size(rows) > 0
            fieldCell(0, "Formation", sz, hdTxt)
            fieldCell(1, "Reading (conventional)", sz, hdTxt)
            fieldCell(2, "% Complete", sz, hdTxt)
            fieldCell(3, "Completed", sz, hdTxt)
            fieldCell(4, "Reached", sz, hdTxt)
            fieldCell(entryRow, "Entry", sz, hdTxt)
            fieldCell(stopRow, stopField(), sz, hdTxt)
            if sizingInput
                fieldCell(sizeRow, "At your risk", sz, hdTxt)
            for tier = 1 to targetTiersInput
                fieldCell(entryRow + tier,
                     levelField(targetName(tier), targetMult(tier)), sz, hdTxt)
            table.cell(lvlTable, 0, TBL_DIVIDER_ROW, "", text_size = sz,
                 bgcolor = color.new(chart.fg_color, TBL_DIVIDER_TRANSP),
                 tooltip = TBL_NOTE)
            int colIdx = 1
            for row in rows
                if colIdx <= TBL_DATA_MAX
                    table.cell(lvlTable, colIdx, 0, row.name,
                         text_color = color.new(familyColor(row.name), 0),
                         text_size = sz, text_halign = text.align_left,
                         text_formatting = text.format_bold,
                         bgcolor = color.new(familyColor(row.name),
                              TBL_CHIP_TRANSP),
                         tooltip = TBL_NOTE)
                    table.cell(lvlTable, colIdx, 1, row.reading, text_color = fgTxt,
                         text_size = sz, text_halign = text.align_left,
                         tooltip = dataNote())
                    table.cell(lvlTable, colIdx, 2, pctText(row.pctDone),
                         text_color = fgTxt, text_size = sz,
                         text_halign = text.align_left, tooltip = dataNote())
                    table.cell(lvlTable, colIdx, 3,
                         (row.side == 1 ? "Closed Above" : "Closed Below") +
                         " · " + str.format_time(row.doneAt,
                         timeframe.isintraday ? "d MMM HH:mm" : "d MMM yyyy",
                         syminfo.timezone), text_color = fgTxt,
                         text_size = sz, text_halign = text.align_left,
                         tooltip = dataNote())
                    table.cell(lvlTable, colIdx, 4,
                         row.armed ?
                             reachedText(row.h1, row.h2, row.h3, row.which) : "—",
                         text_color = fgTxt, text_size = sz,
                         text_halign = text.align_left, tooltip = dataNote())
                    table.cell(lvlTable, colIdx, TBL_DIVIDER_ROW, "",
                         text_size = sz,
                         bgcolor = color.new(chart.fg_color, TBL_DIVIDER_TRANSP),
                         tooltip = dataNote())
                    table.cell(lvlTable, colIdx, entryRow,
                         row.armed ? str.tostring(row.entry, format.mintick) : "—",
                         text_color = fgTxt, text_size = sz,
                         text_halign = text.align_left,
                         text_formatting = text.format_bold,
                         text_font_family = font.family_monospace,
                         tooltip = dataNote())
                    bool stopHit = row.armed and
                         (row.which == HIT_STOP or row.which == HIT_BOTH)
                    table.cell(lvlTable, colIdx, stopRow,
                         row.armed ?
                             levelCellText(row.stop, row.stopAt, row.doneAt) +
                             stopRSuffix(row.entry, row.stop, row.rUnit) : "—",
                         text_color = levelTextColor(stopHit, stopColorInput,
                              row.armed, fgTxt),
                         bgcolor = levelFill(stopHit, stopColorInput),
                         text_size = sz, text_halign = text.align_left,
                         text_font_family = font.family_monospace,
                         tooltip = dataNote())
                    if sizingInput
                        table.cell(lvlTable, colIdx, sizeRow,
                             row.armed ? sizeText(row.entry, row.stop) : "—",
                             text_color = fgTxt, text_size = sz,
                             text_halign = text.align_left,
                             text_font_family = font.family_monospace,
                             tooltip = riskCellNote())
                    for t = 1 to targetTiersInput
                        float tierP = t == 3 ? row.t3 : t == 2 ? row.t2 : row.t1
                        int   tierB = t == 3 ? row.h3 : t == 2 ? row.h2 : row.h1
                        int   tierAt = t == 3 ? row.h3At : t == 2 ? row.h2At :
                             row.h1At
                        bool  tierHit = row.armed and tierB >= 0
                        table.cell(lvlTable, colIdx, entryRow + t,
                             row.armed ?
                                 levelCellText(tierP, tierAt, row.doneAt) : "—",
                             text_color = levelTextColor(tierHit, targetColorInput,
                                  row.armed, fgTxt),
                             bgcolor = levelFill(tierHit, targetColorInput),
                             text_size = sz, text_halign = text.align_left,
                             text_font_family = font.family_monospace,
                             tooltip = dataNote())
                colIdx := colIdx + 1
````
