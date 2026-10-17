#  Watermark Pro _ AAK_

- url: https://www.tradingview.com/script/tQUsUUPm-Watermark-Pro-AAK/
- type: indicator
- pine_id: PUB;8a7295ac139a42a4b26b5046af5059ef
- version: 1.0

## Description

═══════════════════════════════════════════════════════════════════════════════

//   [b]Hey everyone [/b]— I built this tool for myself and decided to share it
//   because I think a lot of you will find it useful too.
 
//   I wanted something that kept my charts looking clean and professional
//   while also keeping my head in the right place during live trading.
//   That's basically what this is — a watermark and a mindset tool combined.
 
//   You can put your name, brand, or social handle directly on your chart
//   with full control over the text, colors, and sizing. Great for sharing
//   setups, recording analysis, or just making your charts feel like yours.
 
//   It also shows the symbol, timeframe automatically so everything is always clear .
 
//   My favourite feature is the reminder panel. Three short messages stay
//   on your chart the whole time you're trading — I use mine to stay
 disciplined and keep emotions out of my decisions. 

//   You can write whatever speaks to you personally.
 
//   There's also an optional bias panel where you lock in your directional
  read before the session starts. It keeps you accountable to your
 pre-session analysis instead of reacting to every candle.
 
//   Everything is fully customizable — panels can be repositioned, toggled
 on or off, styled with custom colors and borders, and there's an
auto-hide option for lower timeframes so your view stays clean.


//   Hope this adds value to your trading. Use it, make it yours.

//  @AAK_
 ═══════════════════════════════════════════════════════════════════════════════

## Source Code

````pine
//@version=6
indicator("◈ AAK Watermark Pro", shorttitle="AAK WM", overlay=true)


// ─────────────────────────────────────────────────────────────────────────────
//  1  ·  DISPLAY SETTINGS
// ─────────────────────────────────────────────────────────────────────────────
var string G1 = "⚙️  Display Settings"

i_show_hdr  = input.bool(true,  "Show Header Panel",
     group   = G1,
     tooltip = "Toggle the entire header / watermark panel on or off")
i_show_rem  = input.bool(true,  "Show Reminder Panel",
     group   = G1,
     tooltip = "Toggle the trading psychology reminder panel on or off")
i_auto_hide = input.bool(false, "Auto-Hide on Timeframes Under 5 Min",
     group   = G1,
     tooltip = "Hides all panels automatically when the chart timeframe is below 5 minutes — keeps scalping views clean")


// ─────────────────────────────────────────────────────────────────────────────
//  2  ·  HEADER — BRANDING
// ─────────────────────────────────────────────────────────────────────────────
var string G2 = "🏷️  Header — Branding"

i_show_title  = input.bool(true,  "Title · Show",                group = G2)
i_title       = input.string("", "Title · Text",                 group = G2)
i_col_title   = input.color(color.new(#B0B0B0, 0), "Title · Color",     group = G2)
i_size_title  = input.string("Huge",   "Title · Size",           group = G2,
     options = ["Tiny","Small","Normal","Large","Huge","Auto"])

i_show_sub    = input.bool(true,  "Subtitle · Show",             group = G2)
i_sub         = input.string("AAK", "Subtitle · Text",           group = G2)
i_col_sub     = input.color(color.new(#ac0505, 0), "Subtitle · Color",  group = G2)
i_size_sub    = input.string("Large",  "Subtitle · Size",        group = G2,
     options = ["Tiny","Small","Normal","Large","Huge","Auto"])

i_show_handle = input.bool(false, "Handle · Show",               group = G2)
i_handle      = input.string("", "Handle · Text",                group = G2,
     tooltip = "Social handle, secondary tag line, or any extra branding text")
i_col_handle  = input.color(color.new(#777777, 0), "Handle · Color",    group = G2)
i_size_handle = input.string("Normal", "Handle · Size",          group = G2,
     options = ["Tiny","Small","Normal","Large","Huge","Auto"])


// ─────────────────────────────────────────────────────────────────────────────
//  3  ·  CHART INFO
// ─────────────────────────────────────────────────────────────────────────────
var string G3 = "📊  Chart Info"

i_show_sym  = input.bool(true,  "Symbol & TF · Show",            group = G3)
i_col_sym   = input.color(color.new(#888888, 0), "Symbol & TF · Color",  group = G3)
i_size_sym  = input.string("Large",  "Symbol & TF · Size",       group = G3,
     options = ["Tiny","Small","Normal","Large","Huge","Auto"])


// ─────────────────────────────────────────────────────────────────────────────
//  4  ·  HEADER APPEARANCE
// ─────────────────────────────────────────────────────────────────────────────
var string G4 = "🎨  Header — Appearance"

i_hdr_bg    = input.color(color.new(#000000, 100), "Header · Background",
     group   = G4,
     tooltip = "Panel background fill · Transparency 100 = fully invisible")
i_hdr_brd   = input.bool(false, "Header · Show Border",          group = G4)
i_hdr_brd_c = input.color(color.new(#555555, 40), "Header · Border Color", group = G4)


// ─────────────────────────────────────────────────────────────────────────────
//  5  ·  REMINDER MESSAGES
// ─────────────────────────────────────────────────────────────────────────────
var string G5 = "💬  Reminder Messages"

i_rem_bg    = input.color(color.new(#000000, 100), "Reminders · Background",
     group   = G5,
     tooltip = "Panel background fill · Transparency 100 = fully invisible")
i_rem_brd   = input.bool(false, "Reminders · Show Border",       group = G5)
i_rem_brd_c = input.color(color.new(#555555, 40), "Reminders · Border Color", group = G5)

i_r1_on   = input.bool(true,  "Reminder 1 · Show",               group = G5)
i_r1_txt  = input.string("  ◈  Patience is a position",
     "Reminder 1 · Text",                                         group = G5)
i_r1_col  = input.color(color.new(#9E9E9E, 0), "Reminder 1 · Color",   group = G5)
i_r1_size = input.string("Small",  "Reminder 1 · Size",          group = G5,
     options = ["Tiny","Small","Normal","Large","Huge","Auto"])

i_r2_on   = input.bool(true,  "Reminder 2 · Show",               group = G5)
i_r2_txt  = input.string("  ◈  Capital preservation is the strategy",
     "Reminder 2 · Text",                                         group = G5)
i_r2_col  = input.color(color.new(#9E9E9E, 0), "Reminder 2 · Color",   group = G5)
i_r2_size = input.string("Small",  "Reminder 2 · Size",          group = G5,
     options = ["Tiny","Small","Normal","Large","Huge","Auto"])

i_r3_on   = input.bool(true,  "Reminder 3 · Show",               group = G5)
i_r3_txt  = input.string("  ◈  If this trade loses, am I okay with that?",
     "Reminder 3 · Text",                                         group = G5)
i_r3_col  = input.color(color.new(#9E9E9E, 0), "Reminder 3 · Color",   group = G5)
i_r3_size = input.string("Small",  "Reminder 3 · Size",          group = G5,
     options = ["Tiny","Small","Normal","Large","Huge","Auto"])


// ─────────────────────────────────────────────────────────────────────────────
//  6  ·  POSITIONING
// ─────────────────────────────────────────────────────────────────────────────
var string G6 = "📍  Positioning"

i_hdr_v = input.string("Top",    "Header · Vertical",            group = G6,
     options = ["Top","Middle","Bottom"])
i_hdr_h = input.string("Center", "Header · Horizontal",          group = G6,
     options = ["Left","Center","Right"])
i_rem_v = input.string("Bottom", "Reminders · Vertical",         group = G6,
     options = ["Top","Middle","Bottom"])
i_rem_h = input.string("Left",   "Reminders · Horizontal",       group = G6,
     options = ["Left","Center","Right"])


// ─────────────────────────────────────────────────────────────────────────────
//  7  ·  TRADE BIAS  (optional extra feature)
// ─────────────────────────────────────────────────────────────────────────────
var string G7 = "🧭  Trade Bias  (Optional)"

i_show_bias = input.bool(false,     "Trade Bias · Show",          group = G7,
     tooltip = "Forces pre-trade clarity by anchoring your directional read on the chart")
i_bias_txt  = input.string("NEUTRAL", "Bias · Direction",         group = G7,
     options  = ["BULLISH","BEARISH","NEUTRAL","WAITING","NO BIAS"],
     tooltip  = "Your current market bias for this instrument — update before each session")
i_bias_bull = input.color(color.new(#26A69A, 0), "Bullish Color", group = G7)
i_bias_bear = input.color(color.new(#EF5350, 0), "Bearish Color", group = G7)
i_bias_neut = input.color(color.new(#9E9E9E, 0), "Neutral Color", group = G7)
i_bias_v    = input.string("Top",   "Bias · Vertical",            group = G7,
     options = ["Top","Middle","Bottom"])
i_bias_h    = input.string("Right", "Bias · Horizontal",          group = G7,
     options = ["Left","Center","Right"])


// ═══════════════════════════════════════════════════════════════════════════════
//  HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════

// Map size label → Pine Script size constant
f_size(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>           size.auto

// Build table position string from vertical + horizontal labels
f_pos(string v, string h) =>
    string vp = v == "Top" ? "top" : v == "Middle" ? "middle" : "bottom"
    string hp = h == "Left" ? "left" : h == "Center" ? "center" : "right"
    vp + "_" + hp

// Build a clean human-readable timeframe label
f_tf() =>
    string r = ""
    if timeframe.isseconds
        r := str.tostring(timeframe.multiplier) + "s"
    else if timeframe.isminutes
        r := timeframe.multiplier >= 60 ?
             str.tostring(math.round(timeframe.multiplier / 60)) + "H" :
             str.tostring(timeframe.multiplier) + "m"
    else if timeframe.isdaily
        r := str.tostring(timeframe.multiplier) + "D"
    else if timeframe.isweekly
        r := str.tostring(timeframe.multiplier) + "W"
    else if timeframe.ismonthly
        r := str.tostring(timeframe.multiplier) + "M"
    else
        r := timeframe.period
    r


// ═══════════════════════════════════════════════════════════════════════════════
//  AUTO-HIDE & VISIBILITY FLAGS
// ═══════════════════════════════════════════════════════════════════════════════
bool _small_tf = timeframe.isminutes and timeframe.multiplier < 5
bool _suppress = i_auto_hide and _small_tf

bool do_hdr  = i_show_hdr  and not _suppress
bool do_rem  = i_show_rem  and not _suppress
bool do_bias = i_show_bias and not _suppress


// ═══════════════════════════════════════════════════════════════════════════════
//  PRE-COMPUTED VALUES
// ═══════════════════════════════════════════════════════════════════════════════

var string _tf_str = f_tf()
var string _sym_tf = syminfo.ticker + "  ·  " + _tf_str

string _hdr_pos  = f_pos(i_hdr_v, i_hdr_h)
string _rem_pos  = f_pos(i_rem_v, i_rem_h)
string _bias_pos = f_pos(i_bias_v, i_bias_h)

string _bias_label =
     i_bias_txt == "BULLISH"  ? "▲  BULLISH"  :
     i_bias_txt == "BEARISH"  ? "▼  BEARISH"  :
     i_bias_txt == "WAITING"  ? "◻  WAITING"  :
     i_bias_txt == "NO BIAS"  ? "─  NO BIAS"  :
                                 "◈  NEUTRAL"

color _bias_col =
     i_bias_txt == "BULLISH" ? i_bias_bull :
     i_bias_txt == "BEARISH" ? i_bias_bear :
     i_bias_neut

string _hdr_align =
     i_hdr_h == "Left"  ? text.align_left  :
     i_hdr_h == "Right" ? text.align_right :
     text.align_center

string _rem_align =
     i_rem_h == "Left"  ? text.align_left  :
     i_rem_h == "Right" ? text.align_right :
     text.align_center

string _bias_align =
     i_bias_h == "Left"  ? text.align_left  :
     i_bias_h == "Right" ? text.align_right :
     text.align_center

int _hdr_bw = i_hdr_brd ? 1 : 0
int _rem_bw = i_rem_brd ? 1 : 0


// ═══════════════════════════════════════════════════════════════════════════════
//  TABLE HANDLES
// ═══════════════════════════════════════════════════════════════════════════════
var table tbl_hdr  = na
var table tbl_rem  = na
var table tbl_bias = na


// ═══════════════════════════════════════════════════════════════════════════════
//  RENDER ENGINE
// ═══════════════════════════════════════════════════════════════════════════════
if barstate.islast

    // ── HEADER PANEL ────────────────────────────────────────────────────────────
    int hdr_rows = (i_show_title  ? 1 : 0) + (i_show_sub    ? 1 : 0) +
                   (i_show_handle ? 1 : 0) + (i_show_sym    ? 1 : 0)

    if do_hdr and hdr_rows > 0
        if not na(tbl_hdr)
            table.delete(tbl_hdr)

        tbl_hdr := table.new(
             position     = _hdr_pos,
             columns      = 1,
             rows         = hdr_rows,
             bgcolor      = i_hdr_bg,
             frame_color  = i_hdr_brd_c,
             frame_width  = _hdr_bw,
             border_width = 0)

        int r = 0

        if i_show_title
            table.cell(tbl_hdr, 0, r,
                 text        = i_title,
                 text_color  = i_col_title,
                 text_size   = f_size(i_size_title),
                 text_halign = _hdr_align,
                 bgcolor     = i_hdr_bg)
            r += 1

        if i_show_sub
            table.cell(tbl_hdr, 0, r,
                 text        = i_sub,
                 text_color  = i_col_sub,
                 text_size   = f_size(i_size_sub),
                 text_halign = _hdr_align,
                 bgcolor     = i_hdr_bg)
            r += 1

        if i_show_handle
            table.cell(tbl_hdr, 0, r,
                 text        = i_handle,
                 text_color  = i_col_handle,
                 text_size   = f_size(i_size_handle),
                 text_halign = _hdr_align,
                 bgcolor     = i_hdr_bg)
            r += 1

        if i_show_sym
            table.cell(tbl_hdr, 0, r,
                 text        = _sym_tf,
                 text_color  = i_col_sym,
                 text_size   = f_size(i_size_sym),
                 text_halign = _hdr_align,
                 bgcolor     = i_hdr_bg)

    else if not na(tbl_hdr)
        table.delete(tbl_hdr)
        tbl_hdr := na


    // ── REMINDER PANEL ──────────────────────────────────────────────────────────
    int rem_rows = (i_r1_on ? 1 : 0) + (i_r2_on ? 1 : 0) + (i_r3_on ? 1 : 0)

    if do_rem and rem_rows > 0
        if not na(tbl_rem)
            table.delete(tbl_rem)

        tbl_rem := table.new(
             position     = _rem_pos,
             columns      = 1,
             rows         = rem_rows,
             bgcolor      = i_rem_bg,
             frame_color  = i_rem_brd_c,
             frame_width  = _rem_bw,
             border_width = 0)

        int rr = 0

        if i_r1_on
            table.cell(tbl_rem, 0, rr,
                 text        = i_r1_txt,
                 text_color  = i_r1_col,
                 text_size   = f_size(i_r1_size),
                 text_halign = _rem_align,
                 bgcolor     = i_rem_bg)
            rr += 1

        if i_r2_on
            table.cell(tbl_rem, 0, rr,
                 text        = i_r2_txt,
                 text_color  = i_r2_col,
                 text_size   = f_size(i_r2_size),
                 text_halign = _rem_align,
                 bgcolor     = i_rem_bg)
            rr += 1

        if i_r3_on
            table.cell(tbl_rem, 0, rr,
                 text        = i_r3_txt,
                 text_color  = i_r3_col,
                 text_size   = f_size(i_r3_size),
                 text_halign = _rem_align,
                 bgcolor     = i_rem_bg)

    else if not na(tbl_rem)
        table.delete(tbl_rem)
        tbl_rem := na


    // ── TRADE BIAS PANEL ────────────────────────────────────────────────────────
    if do_bias
        if not na(tbl_bias)
            table.delete(tbl_bias)

        tbl_bias := table.new(
             position     = _bias_pos,
             columns      = 1,
             rows         = 2,
             bgcolor      = color.new(color.black, 100),
             frame_width  = 0,
             border_width = 0)

        table.cell(tbl_bias, 0, 0,
             text        = "CURRENT BIAS",
             text_color  = color.new(#666666, 0),
             text_size   = size.tiny,
             text_halign = _bias_align,
             bgcolor     = color.new(color.black, 100))

        table.cell(tbl_bias, 0, 1,
             text        = _bias_label,
             text_color  = _bias_col,
             text_size   = size.normal,
             text_halign = _bias_align,
             bgcolor     = color.new(color.black, 100))

    else if not na(tbl_bias)
        table.delete(tbl_bias)
        tbl_bias := na
````
