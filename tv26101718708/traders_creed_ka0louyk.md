# Traders Creed

- url: https://www.tradingview.com/script/Ka0LOUYK-Traders-Creed/
- type: indicator
- pine_id: PUB;8bb6698ea042479bb1b287cc8356de11
- version: 2.0

## Description

Just a passive script with the silhouette of a Sniper and two candlestick bullets. 
As traders we must stalk our entries and time our exits. 
I created this to remind me always to stay patient and enter only the best conviction set ups. 

This indicator has a custom message box so you can write anything that reminds you to remain disciplined while you trade.  The two bullets represent two entries per turn. 
Like a sniper once you miss, your target is aware and will evade. You only get one more try. 
After that, walk away.  The market is always there later. 

Happy Trading.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════════
// THE CREED [BG Public]  ·  v1.6  ·  Boss Gbini
//
// The public edition: the same insignia, with a general five-step Trade Frame
// as the default rules. Every row is yours to rewrite in the settings.
//
// Two bullets. A sniper does not spray the market — he lies still, reads the
// wind, and fires only when the shot is there. This indicator draws nothing on
// price and reads nothing from it. It sits in the corner of the chart as the
// reminder: WAIT FOR THE RIGHT TIME.
//
// Drawn as block-character art in a table cell (monospace), so it stays fixed
// on screen whatever the zoom or scroll. Spaces are non-breaking so the
// silhouette keeps its shape.
//
// v1.1 · both bullets stamped from one pixel template — twins; a one-pixel gap
// carved around the rifle where it crosses the shooter, so the stock, receiver
// and scope read against his shoulder and head.
// v1.2 · the feet turned the right way — toes down, as a prone shooter lies.
// v1.3 · the creed line takes its own size, colour and offsets — sideways in
// characters, up or down in lines, above or below the sniper.
// v1.4 · MICRO size — half of Tiny — for the sniper and the creed line.
// v1.5 · MINI size (between Micro and Tiny); horizontal and vertical offsets for
// the sniper, the creed line riding along with him.
// v1.6 · THE TRADE FRAME — up to seven rules in a column over the bullets, with
// their own size, colour and gap.
// ═══════════════════════════════════════════════════════════════════════════════
indicator("The Creed [BG Public]", "The Creed", overlay = true)

string G = "🎯 The Creed"
string c_pos  = input.string("Bottom Right", "Position",
     options = ["Top Left", "Top Centre", "Top Right", "Middle Left", "Middle Centre", "Middle Right", "Bottom Left", "Bottom Centre", "Bottom Right"], group = G)
string c_sz   = input.string("Small", "Size", options = ["Micro", "Mini", "Tiny", "Small", "Normal", "Large", "Huge"], group = G)
float  c_h    = input.float(0.0, "Horizontal offset", -50.0, 50.0, step = 0.5, group = G,
     tooltip = "Moves the sniper — and the creed line with him — in % of the chart's width. + right, − left, measured from the corner chosen in Position. A nudge towards the edge he already sits on has nowhere to go.")
float  c_v    = input.float(0.0, "Vertical offset", -50.0, 50.0, step = 0.5, group = G,
     tooltip = "Moves the sniper — and the creed line with him — in % of the chart's height. + up, − down, measured from the corner chosen in Position.")
color  c_col  = input.color(color.new(color.white, 0), "Silhouette", group = G,
     tooltip = "White by default. Raise the colour's transparency to sink it into the background.")
string GL = "📜 Creed Line"
bool   c_line  = input.bool(true, "Creed line", inline = "cl", group = GL)
string c_text  = input.string("TWO BULLETS · WAIT FOR THE SHOT", "", inline = "cl", group = GL)
string c_lsz   = input.string("Small", "Size", options = ["Micro", "Mini", "Tiny", "Small", "Normal", "Large", "Huge"], inline = "cl2", group = GL)
color  c_lcol  = input.color(color.new(color.white, 0), "Colour", inline = "cl2", group = GL)
int    c_lh    = input.int(0, "Horizontal offset (characters)", -40, 40, group = GL,
     tooltip = "0 = centred under the sniper. + moves the line right, − moves it left, one character of the line's own font per step.")
int    c_lv    = input.int(0, "Vertical offset (lines)", -10, 10, group = GL,
     tooltip = "0 = directly under the sniper. + moves the line further down, one line per step. − moves it up: −1 puts it directly above the sniper, −2 one line above that, and so on.")

string GR = "📋 Trade Frame"
bool   r_on   = input.bool(true, "Rules", inline = "r0", group = GR,
     tooltip = "Up to seven rules for framing a trade, stacked in a column over the bullets. A blank row is skipped, so rows 6 and 7 can wait until you dial them in.")
bool   r_num  = input.bool(true, "Numbered", inline = "r0", group = GR)
string r_sz   = input.string("Small", "Size", options = ["Micro", "Mini", "Tiny", "Small", "Normal", "Large", "Huge"], inline = "r1", group = GR)
color  r_col  = input.color(color.new(color.white, 0), "Colour", inline = "r1", group = GR)
int    r_gap  = input.int(0, "Gap above the bullets (lines)", 0, 10, group = GR)
string r1 = input.string("Establish HTF trend", "1", group = GR)
string r2 = input.string("Seek Zone, Draw on LQ", "2", group = GR)
string r3 = input.string("Seek appropriate LTF entry", "3", group = GR)
string r4 = input.string("Size right (pro-trend 1, counter-trend 1/2)", "4", group = GR)
string r5 = input.string("Manage Trade", "5", group = GR)
string r6 = input.string("", "6", group = GR)
string r7 = input.string("", "7", group = GR)

f_pos(string p) =>
    p == "Top Left" ? position.top_left : p == "Top Centre" ? position.top_center : p == "Top Right" ? position.top_right :
     p == "Middle Left" ? position.middle_left : p == "Middle Centre" ? position.middle_center : p == "Middle Right" ? position.middle_right :
     p == "Bottom Left" ? position.bottom_left : p == "Bottom Centre" ? position.bottom_center : position.bottom_right
f_sz(string s) => s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : s == "Huge" ? size.huge : size.normal
// MICRO and MINI sit below the named sizes, so they are given in typographic
// points instead — Micro half of Tiny, Mini between the two. table.cell takes
// either form, so each cell has a points branch.
f_pt(string s) => s == "Micro" ? 4 : s == "Mini" ? 6 : 0
string TIP = "THE CREED\n\nI carry two bullets.\nI do not chase. I do not spray.\nI wait for the sweep, the story and the level.\nWhen the shot is there, I take it once — and I let it work."

string ART = "                                       ▄███▄                                                       \n                                     ▄▄█████▄                                        █           █ \n                                    ▀▀▀█████ ▄█▄▄▄▄▄▄▄▄▄                            ▄█▄         ▄█▄\n                                       ███▀▀ ████▀▀▀█▀▀▀                      ▀▀▀▀▀ ███   ▀▀▀▀▀ ███\n                                   ▄▄ ▄▄▄▄▄████████████▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄███     ▀▀▀▀ ███    ▀▀▀▀ ███\n                         ▄▄▄▄▄███████▄ █████▀▀▀▀▀▀▀▀▀▀▀▀      ▄█▄      ▀▀▀      ▀▀▀ ███     ▀▀▀ ███\n                ▄▄▄▄▄█████████████████ ▀▀▀▀ ▄██               █▀█                    █           █ \n▄▄▄▄▄▄████████████████████████████████████▄▄██               █▀ ▀█                   ▀           ▀ \n███████████▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀  ▀▀█▀▀               ▄█   █▄                                \n███▀                                                        ▀     ▀                                \n ▀▀                                                                                                "

// Layout · 3 × 6. Column 1 holds the insignia: row 1 the creed line when it sits
// above, row 2 the Trade Frame rules, row 3 the sniper, row 4 the creed line when
// it sits below. The rules are padded to one width and right-aligned, so they
// stand as a straight-edged column over the bullets. The sniper's
// offsets are empty spacer cells around that column — a spacer on the left pushes
// the block right, on the right pushes it left, below lifts it, above lowers it.
// The creed line's offsets are padding inside its own cell: non-breaking spaces
// to slide it sideways (a centred cell moves by half the padding, so it is
// doubled), blank lines to open the gap.
var table t = table.new(position.bottom_right, 3, 6)
if barstate.islast
    table.clear(t, 0, 0, 2, 5)
    table.set_position(t, f_pos(c_pos))
    if c_h > 0
        table.cell(t, 0, 3, "", width = c_h)
    if c_h < 0
        table.cell(t, 2, 3, "", width = -c_h)
    if c_v < 0
        table.cell(t, 1, 0, "", height = -c_v)
    if c_v > 0
        table.cell(t, 1, 5, "", height = c_v)
    if f_pt(c_sz) > 0
        table.cell(t, 1, 3, ART, text_color = c_col, text_size = f_pt(c_sz), text_halign = text.align_left,
             text_font_family = font.family_monospace, tooltip = TIP)
    else
        table.cell(t, 1, 3, ART, text_color = c_col, text_size = f_sz(c_sz), text_halign = text.align_left,
             text_font_family = font.family_monospace, tooltip = TIP)
    string nb = " "
    if r_on
        array<string> rs = array.new_string(0)
        int mx = 0
        for s in array.from(r1, r2, r3, r4, r5, r6, r7)
            if str.trim(s) != ""
                string ln = (r_num ? str.tostring(array.size(rs) + 1) + ". " : "") + str.trim(s)
                array.push(rs, ln)
                mx := math.max(mx, str.length(ln))
        if array.size(rs) > 0
            string col = ""
            for ln in rs
                col += (col == "" ? "" : "\n") + str.replace_all(ln, " ", nb) + str.repeat(nb, mx - str.length(ln))
            col += r_gap > 0 ? "\n" + str.repeat(nb, r_gap, "\n") : ""
            if f_pt(r_sz) > 0
                table.cell(t, 1, 2, col, text_color = r_col, text_size = f_pt(r_sz), text_halign = text.align_right,
                     text_font_family = font.family_monospace)
            else
                table.cell(t, 1, 2, col, text_color = r_col, text_size = f_sz(r_sz), text_halign = text.align_right,
                     text_font_family = font.family_monospace)
    if c_line
        string pad = str.repeat(nb, 2 * math.abs(c_lh))
        string txt = c_lh > 0 ? pad + c_text : c_lh < 0 ? c_text + pad : c_text
        bool   up  = c_lv < 0
        int    gap = up ? -c_lv - 1 : c_lv
        string blk = gap > 0 ? str.repeat(nb, gap, "\n") : ""   // the blank lines
        string out = up ? txt + (gap > 0 ? "\n" + blk : "") : (gap > 0 ? blk + "\n" : "") + txt
        if f_pt(c_lsz) > 0
            table.cell(t, 1, up ? 1 : 4, out, text_color = c_lcol, text_size = f_pt(c_lsz), text_halign = text.align_center,
                 text_font_family = font.family_monospace)
        else
            table.cell(t, 1, up ? 1 : 4, out, text_color = c_lcol, text_size = f_sz(c_lsz), text_halign = text.align_center,
                 text_font_family = font.family_monospace)
````
