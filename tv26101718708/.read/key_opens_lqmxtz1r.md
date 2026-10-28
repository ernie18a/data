# Key Opens

- url: https://www.tradingview.com/script/LQMxtZ1r-Key-Opens/
- type: indicator
- pine_id: PUB;d536d8ef6892497f8a1df49a15b00f55
- version: 2.0

## Description

Key Opens

Marks the key opening prices of the trading day as horizontal levels, based on New York time. It includes the daily session open, Asia, Midnight, True London, London, 8:30, NY-AM and NY-PM opens, plus optional Monthly and Weekly opens and 3 custom slots.

Each level starts at the open of the candle containing that time and extends until the next occurrence of the same open. Every open can be toggled, renamed, re-timed and recoloured. Times convert to New York automatically, including daylight saving.

Settings: history depth, line style and width, label size and offset, optional price in labels, and optional vertical lines.

Notes: Use an extended-hours (ETH) chart. Best on 15m and below; on higher timeframes, levels use the containing candle's open, so they're approximate.

## Source Code

````pine
//@version=6
indicator("Key Opens", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ─────────────────────────────────────────────────────────────
// Key Opens — marks Monthly / Weekly / Daily (18:00) / Asia / Midnight /
// True London / London / 8:30 / 9:30 / PM + 3 custom opens. All times are New York.
// Use on ETH (extended) session charts, 15m or lower.
// ─────────────────────────────────────────────────────────────

const string TZ = "America/New_York"

// ── General
string grpG   = "General"
int    keepN  = input.int(1, "History per open (1 = most recent only)", minval = 1, maxval = 18, group = grpG)
string lsIn   = input.string("Solid", "Line style", options = ["Solid", "Dashed", "Dotted"], group = grpG)
int    lw     = input.int(1, "Line width", minval = 1, maxval = 4, group = grpG)
int    lblOff = input.int(4, "Label offset (bars)", minval = 0, group = grpG)
string lblSz  = input.string(size.small, "Label size", options = [size.tiny, size.small, size.normal], group = grpG)
bool   showPx = input.bool(false, "Show price in label", group = grpG)
bool   showVt = input.bool(false, "Vertical line at open time", group = grpG)

// ── Opens  (toggle | label name | time NY | colour)
string grpO = "Opens"
bool   onMo = input.bool(false,  "",                inline = "mo", group = grpO)
string nMo  = input.string("Monthly Open", "",     inline = "mo", group = grpO)
color  cMo  = input.color(#ffffff, "",             inline = "mo", group = grpO)

bool   onWk = input.bool(false,  "",                inline = "wk", group = grpO)
string nWk  = input.string("Weekly Open", "",      inline = "wk", group = grpO)
color  cWk  = input.color(#ffffff, "",             inline = "wk", group = grpO)

bool   onDy = input.bool(true,  "",                inline = "dy", group = grpO)
string nDy  = input.string("NDO", "",       inline = "dy", group = grpO)
color  cDy  = input.color(#ffffff, "",             inline = "dy", group = grpO)

bool   onAs = input.bool(true,  "",                inline = "as", group = grpO)
string nAs  = input.string("Asia", "",        inline = "as", group = grpO)
string tAs  = input.string("20:00", "",            inline = "as", group = grpO)
color  cAs  = input.color(#ffffff, "",             inline = "as", group = grpO)

bool   onMn = input.bool(true,  "",                inline = "mn", group = grpO)
string nMn  = input.string("Midnight", "",    inline = "mn", group = grpO)
string tMn  = input.string("00:00", "",            inline = "mn", group = grpO)
color  cMn  = input.color(#ffffff, "",             inline = "mn", group = grpO)

bool   onTl = input.bool(true,  "",                inline = "tl", group = grpO)
string nTl  = input.string("True London", "",  inline = "tl", group = grpO)
string tTl  = input.string("01:30", "",            inline = "tl", group = grpO)
color  cTl  = input.color(#ffffff, "",             inline = "tl", group = grpO)

bool   onLo = input.bool(true,  "",                inline = "lo", group = grpO)
string nLo  = input.string("London", "",      inline = "lo", group = grpO)
string tLo  = input.string("02:00", "",            inline = "lo", group = grpO)
color  cLo  = input.color(#ffffff, "",             inline = "lo", group = grpO)

bool   on83 = input.bool(true,  "",                inline = "83", group = grpO)
string n83  = input.string("8:30", "",        inline = "83", group = grpO)
string t83  = input.string("08:30", "",            inline = "83", group = grpO)
color  c83  = input.color(#ffffff, "",             inline = "83", group = grpO)

bool   onNy = input.bool(true,  "",                inline = "ny", group = grpO)
string nNy  = input.string("NY-AM", "",          inline = "ny", group = grpO)
string tNy  = input.string("09:30", "",            inline = "ny", group = grpO)
color  cNy  = input.color(#ffffff, "",             inline = "ny", group = grpO)

bool   onPm = input.bool(true,  "",                inline = "pm", group = grpO)
string nPm  = input.string("NY-PM", "",          inline = "pm", group = grpO)
string tPm  = input.string("13:30", "",            inline = "pm", group = grpO)
color  cPm  = input.color(#ffffff, "",             inline = "pm", group = grpO)

// ── Custom opens
string grpC = "Custom Opens"
bool   onC1 = input.bool(false, "",                inline = "c1", group = grpC)
string nC1  = input.string("Custom 1", "",         inline = "c1", group = grpC)
string tC1  = input.string("10:00", "",            inline = "c1", group = grpC)
color  cC1  = input.color(#ffffff, "",             inline = "c1", group = grpC)

bool   onC2 = input.bool(false, "",                inline = "c2", group = grpC)
string nC2  = input.string("Custom 2", "",         inline = "c2", group = grpC)
string tC2  = input.string("11:00", "",            inline = "c2", group = grpC)
color  cC2  = input.color(#ffffff, "",             inline = "c2", group = grpC)

bool   onC3 = input.bool(false, "",                inline = "c3", group = grpC)
string nC3  = input.string("Custom 3", "",         inline = "c3", group = grpC)
string tC3  = input.string("12:00", "",            inline = "c3", group = grpC)
color  cC3  = input.color(#ffffff, "",             inline = "c3", group = grpC)

string lineStyle = switch lsIn
    "Solid"  => line.style_solid
    "Dotted" => line.style_dotted
    => line.style_dashed

// ── Helpers
// "HH:MM", "H:MM" or "HHMM" -> minutes after midnight (na if invalid)
parseMin(string raw) =>
    string s = str.trim(raw)
    int h = na
    int m = na
    if str.contains(s, ":")
        array<string> parts = str.split(s, ":")
        h := int(str.tonumber(str.trim(parts.get(0))))
        m := parts.size() > 1 ? int(str.tonumber(str.trim(parts.get(1)))) : 0
    else if str.length(s) >= 3
        int v = int(str.tonumber(s))
        h := int(math.floor(v / 100))
        m := v % 100
    na(h) or na(m) or h < 0 or h > 23 or m < 0 or m > 59 ? na : h * 60 + m

// HH:MM on the NY calendar date of timestamp `ts`
targetOn(int ts, int tm) =>
    timestamp(TZ, year(ts, TZ), month(ts, TZ), dayofmonth(ts, TZ), int(math.floor(tm / 60)), tm % 60)

// true on the bar that contains HH:MM (NY time). Checks the date at both
// ends of the bar so opens aren't missed when a bar straddles midnight.
hitAt(string hhmm) =>
    int tm = parseMin(hhmm)
    bool hit = false
    if timeframe.isintraday and not na(tm) and not na(time_close)
        int t1 = targetOn(time, tm)
        int t2 = targetOn(time_close - 1, tm)
        hit := (time <= t1 and t1 < time_close) or (time <= t2 and t2 < time_close)
    hit

// ── Object per open
type KeyOpen
    string       name
    color        col
    array<line>  lines
    array<label> labels
    array<line>  verts

newKO(string name, color col) =>
    KeyOpen.new(name, col, array.new<line>(), array.new<label>(), array.new<line>())

method update(KeyOpen k, bool enabled, bool hit) =>
    if enabled and hit
        // freeze the previous level where the new one starts
        if k.lines.size() > 0
            k.lines.last().set_x2(bar_index - 1)
            k.labels.last().set_x(bar_index - 1)
        string txt = k.name + (showPx ? "  " + str.tostring(open, format.mintick) : "")
        k.lines.push(line.new(bar_index, open, bar_index, open, color = k.col, style = lineStyle, width = lw))
        k.labels.push(label.new(bar_index + lblOff, open, txt, color = color.new(color.black, 100), textcolor = k.col, style = label.style_label_left, size = lblSz))
        if showVt
            k.verts.push(line.new(bar_index, open, bar_index, open + syminfo.mintick, extend = extend.both, color = color.new(k.col, 70), style = line.style_dotted))
        // trim history
        if k.lines.size() > keepN
            k.lines.shift().delete()
            k.labels.shift().delete()
        if k.verts.size() > keepN
            k.verts.shift().delete()
    // extend the live level to the current bar
    if enabled and k.lines.size() > 0
        k.lines.last().set_x2(bar_index)
        k.labels.last().set_x(bar_index + lblOff)

// ── Instances
var KeyOpen koMo = newKO(nMo, cMo)
var KeyOpen koWk = newKO(nWk, cWk)
var KeyOpen koDy = newKO(nDy, cDy)
var KeyOpen koAs = newKO(nAs, cAs)
var KeyOpen koMn = newKO(nMn, cMn)
var KeyOpen koTl = newKO(nTl, cTl)
var KeyOpen koLo = newKO(nLo, cLo)
var KeyOpen ko83 = newKO(n83, c83)
var KeyOpen koNy = newKO(nNy, cNy)
var KeyOpen koPm = newKO(nPm, cPm)
var KeyOpen koC1 = newKO(nC1, cC1)
var KeyOpen koC2 = newKO(nC2, cC2)
var KeyOpen koC3 = newKO(nC3, cC3)

// Monthly / Weekly / Daily follow the exchange session (18:00 ET on CME)
koMo.update(onMo, timeframe.change("M"))
koWk.update(onWk, timeframe.change("W"))
koDy.update(onDy, timeframe.change("D"))

// Time-of-day opens
koAs.update(onAs, hitAt(tAs))
koMn.update(onMn, hitAt(tMn))
koTl.update(onTl, hitAt(tTl))
koLo.update(onLo, hitAt(tLo))
ko83.update(on83, hitAt(t83))
koNy.update(onNy, hitAt(tNy))
koPm.update(onPm, hitAt(tPm))
koC1.update(onC1, hitAt(tC1))
koC2.update(onC2, hitAt(tC2))
koC3.update(onC3, hitAt(tC3))
````
