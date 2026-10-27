# GEX Levels from a Level String, with OI Age Check

- url: https://www.tradingview.com/script/uKwF557w-GEX-Levels-from-a-Level-String-with-OI-Age-Check/
- type: indicator
- pine_id: PUB;46752750d7164231a7fb5bcc9daa1932
- version: 1.0

## Description

WHAT IT DOES
Draws options gamma-exposure (GEX) levels on the chart from one line of text that you paste: the gamma flip, the call wall, the put wall, and up to 20 more strikes ranked by absolute GEX. A table in the top-right corner shows how old the open-interest snapshot behind those levels is, and turns red once it is older than the threshold you set.

WHY THE AGE CHECK
For US-listed options, open interest is reported once per day. Without a timestamp, levels computed from last night's open interest look the same at the open, at the close and after a weekend. This script shows the age of the snapshot on the chart, so old positioning is not read as current.

HOW TO READ THE LEVELS
Under the usual dealer-positioning convention, positive GEX is read as hedging that dampens moves and negative GEX as hedging that amplifies them. The gamma flip is where cumulative GEX changes sign. The call wall and the put wall are the strikes with the largest positive and the most negative GEX. These readings rest on an assumption about who holds the options; see Limitations.

HOW THE LEVELS ARE COMPUTED
The script does not compute GEX. It draws levels computed outside TradingView, because Pine Script cannot call an external API at runtime. You can produce them with your own code from any option chain:
- Per contract line: GEX = gamma x open interest x spot^2 x 0.01 x 100, with Black-Scholes gamma. Calls count positive, puts negative.
- By strike: sum the signed GEX of all rights and expiries at that strike.
- Gamma flip: where cumulative GEX over ascending strikes crosses zero, interpolated linearly between the two bracketing strikes. Count a crossing only after the cumulative has reached 0.5% of the total absolute GEX, so near-zero noise in the far wing is ignored. With several crossings, use the one nearest to spot. With none, write na.
- Call wall: strike with the largest positive GEX. Put wall: strike with the most negative GEX.
- Extra levels: the top strikes by absolute GEX, in descending order.

LEVEL STRING FORMAT (v1)
One line, no spaces, fields separated by semicolons:
v1;asof=20260904T2000Z;spot=5400.00;FLIP=5387.5;CW=5450;PW=5300;L=5425:1.2e9,5375:-8.01e8

- v1: format version, always first
- asof: open-interest snapshot time in UTC, yyyyMMddTHHmmZ
- spot: underlying price used for the computation
- FLIP: gamma flip, or na when there is no valid crossing
- CW: call wall
- PW: put wall
- L: top strikes as strike:gex pairs separated by commas, in descending order of absolute GEX, with signed gex such as 1.2e9 or -8.01e8

Unknown fields are ignored. A string that does not start with v1 shows "No level string".

HOW TO USE
1. Build the string from an option chain as described above and copy it.
2. Paste it into the "Level string" input as a single line, with no spaces or line breaks.
3. Set the age threshold in hours. The default is 24.
4. Choose how many entries of L to draw (0 to 20, default 10). Strikes equal to a wall are not drawn twice.
5. For alerts, use Create Alert and pick one of the three GEX conditions: price crossing the gamma flip, the call wall or the put wall.

HOW IT WORKS
The script parses the string on the last bar, then deletes and redraws its lines and labels there. Lines extend across the whole chart. The live count stays at 3 + N lines and 3 + N labels, well under TradingView's limits.

LIMITATIONS
- The levels are only as good as the option chain and the open interest they came from.
- The sign convention assumes dealers are long the calls customers sell and short the puts customers buy. That is an assumption of the method, not an observed fact, and getting it wrong moves the flip to the other side of spot.
- The string has to be pasted again for every refresh. There is no automatic feed.
- The age comes from the asof field. A string without asof is shown as stale.
- The levels are context for your own analysis, not trade signals.

The chart shows SPY on the 15-minute timeframe with levels from open interest dated 2026-10-08.

## Source Code

````pine
//@version=6
indicator("GEX Levels from a Level String, with OI Age Check",
     shorttitle = "GEX",
     overlay = true,
     max_lines_count = 500,
     max_labels_count = 500)

//──────────────────────────────────────────────────────────────────────────────
// Draws gamma-exposure levels that were computed OFF the chart from an option
// chain. Pine cannot call an API at runtime, so the levels arrive as one text
// string pasted into the input below. Format (version 1, no whitespace):
//
//   v1;asof=20260904T2000Z;spot=5400.00;FLIP=5430.34;CW=5500;PW=5300;L=5500:6.899e8,5300:-2.412e8
//
//   asof  open-interest snapshot time, UTC, yyyyMMddTHHmmZ
//   spot  underlying price used for the computation
//   FLIP  gamma flip (zero crossing of cumulative GEX); "na" when there is no valid crossing
//   CW    call wall (strike with the largest positive GEX)
//   PW    put wall (strike with the most negative GEX)
//   L     top strikes as strike:GEX pairs, sorted by |GEX| descending; strikes
//         equal to a wall are not drawn twice
//
// The grammar is split on ';', '=', ',' and ':' only. Unknown keys are ignored.
//
// For US-listed options, open interest is reported once per day, so a level
// string is only as fresh as its OI snapshot. The table states that age and turns red past the
// threshold you set, instead of letting old levels look current.
//
// Object management: everything is deleted and redrawn on the last bar only,
// so the live count is 3 + N lines and 3 + N labels, well under the caps.
//──────────────────────────────────────────────────────────────────────────────

// ── Inputs ───────────────────────────────────────────────────────────────────
grpS = "Level string"
levelStr   = input.string("", "Level string (v1 format, see the description)", group = grpS, display = display.none)
staleAfter = input.float(24.0, "Warn when the OI snapshot is older than (hours)", minval = 1.0, group = grpS,
     tooltip = "For US-listed options, open interest is reported once per day. Past this age, a newer open-interest update exists than the one the levels were computed from.")
maxExtra   = input.int(10, "Extra |GEX| levels to draw", minval = 0, maxval = 20, group = grpS)
showTable  = input.bool(true, "Show freshness table", group = grpS)

// ── Parsing helpers ──────────────────────────────────────────────────────────
// str.tonumber() is not documented to accept exponent notation, so the
// mantissa and the exponent are parsed separately: "6.899e8" -> 6.899 * 10^8.
parseSci(string s) =>
    parts = str.split(s, "e")
    m = str.tonumber(array.get(parts, 0))
    e = array.size(parts) > 1 ? str.tonumber(array.get(parts, 1)) : 0.0
    na(m) ? float(na) : m * math.pow(10, na(e) ? 0.0 : e)

// "20260904T2000Z" -> UNIX ms in UTC. Anything of the wrong length is na.
parseAsOf(string s) =>
    if str.length(s) != 14
        int(na)
    else
        y  = int(str.tonumber(str.substring(s, 0, 4)))
        mo = int(str.tonumber(str.substring(s, 4, 6)))
        d  = int(str.tonumber(str.substring(s, 6, 8)))
        h  = int(str.tonumber(str.substring(s, 9, 11)))
        mi = int(str.tonumber(str.substring(s, 11, 13)))
        timestamp("UTC", y, mo, d, h, mi, 0)

// ── State ────────────────────────────────────────────────────────────────────
var float flipLv  = na
var float callLv  = na
var float putLv   = na
var float spotIn  = na
var int   asOfMs  = na
var bool  parseOk = false
var float[] xStrike = array.new_float()
var float[] xGex    = array.new_float()
var line[]  drawn   = array.new_line()
var label[] tags    = array.new_label()
var table   hud     = table.new(position.top_right, 1, 4, border_width = 1)

drawLevel(float px, string name, color c, int width) =>
    ln = line.new(bar_index - 1, px, bar_index, px, extend = extend.both, color = c, width = width)
    lb = label.new(bar_index, px, name + "  " + str.tostring(px, format.mintick),
         style = label.style_label_left, color = color.new(c, 20), textcolor = color.white, size = size.small)
    array.push(drawn, ln)
    array.push(tags, lb)

// ── Parse + redraw on the last bar only ──────────────────────────────────────
if barstate.islast
    for ln in drawn
        line.delete(ln)
    for lb in tags
        label.delete(lb)
    array.clear(drawn)
    array.clear(tags)
    array.clear(xStrike)
    array.clear(xGex)
    flipLv := na
    callLv := na
    putLv  := na
    spotIn := na
    asOfMs := na
    parseOk := false

    if str.length(levelStr) > 0
        fields = str.split(levelStr, ";")
        if array.size(fields) > 0 and array.get(fields, 0) == "v1"
            parseOk := true
            for f in fields
                kv = str.split(f, "=")
                if array.size(kv) == 2
                    key = array.get(kv, 0)
                    val = array.get(kv, 1)
                    switch key
                        "asof" => asOfMs := parseAsOf(val)
                        "spot" => spotIn := str.tonumber(val)
                        "FLIP" => flipLv := str.tonumber(val)   // "na" parses to na, which is the intent
                        "CW"   => callLv := str.tonumber(val)
                        "PW"   => putLv  := str.tonumber(val)
                        "L"    =>
                            for item in str.split(val, ",")
                                pair = str.split(item, ":")
                                if array.size(pair) == 2
                                    array.push(xStrike, str.tonumber(array.get(pair, 0)))
                                    array.push(xGex, parseSci(array.get(pair, 1)))

    // Extra levels first (behind), headline levels on top. The string is
    // already sorted by |GEX| descending, so the index is the rank.
    // Guarded: a Pine `for 0 to -1` iterates downward instead of skipping.
    nExtra = math.min(array.size(xStrike), maxExtra)
    if nExtra > 0
        for i = 0 to nExtra - 1
            k = array.get(xStrike, i)
            g = array.get(xGex, i)
            if not na(k) and k != callLv and k != putLv
                // Rank 0 is nearly opaque; the last one fades out. |GEX| in
                // words would be noise on a chart, so only the sign is coloured.
                transp = 40 + int(50 * i / nExtra)
                drawLevel(k, (g >= 0 ? "+" : "-") + "GEX", color.new(g >= 0 ? color.teal : color.orange, transp), 1)
    if not na(putLv)
        drawLevel(putLv, "Put wall", color.red, 2)
    if not na(callLv)
        drawLevel(callLv, "Call wall", color.green, 2)
    if not na(flipLv)
        drawLevel(flipLv, "Gamma flip", color.yellow, 2)

    // Freshness table. timenow is the chart's wall clock, so the age is
    // real even on a stale-looking historical bar.
    if showTable
        ageH  = na(asOfMs) ? float(na) : (timenow - asOfMs) / 3600000.0
        stale = na(ageH) or ageH >= staleAfter
        bg    = not parseOk ? color.new(color.gray, 20) : stale ? color.new(color.red, 10) : color.new(color.green, 40)
        status = not parseOk ? "No level string" : na(ageH) ? "asof missing - treat as STALE" :
                 stale ? "STALE: OI " + str.tostring(ageH, "#.#") + "h old" : "OI " + str.tostring(ageH, "#.#") + "h old"
        table.cell(hud, 0, 0, "GEX levels", text_color = color.white, bgcolor = color.new(color.gray, 20), text_size = size.small)
        table.cell(hud, 0, 1, status, text_color = color.white, bgcolor = bg, text_size = size.small)
        table.cell(hud, 0, 2, na(asOfMs) ? "" : "OI as of " + str.format_time(asOfMs, "yyyy-MM-dd HH:mm", "UTC") + " UTC",
             text_color = color.white, bgcolor = color.new(color.gray, 20), text_size = size.small)
        table.cell(hud, 0, 3, na(spotIn) ? "" : "computed at spot " + str.tostring(spotIn, format.mintick),
             text_color = color.white, bgcolor = color.new(color.gray, 20), text_size = size.small)

// ── Alerts ───────────────────────────────────────────────────────────────────
// alertcondition() must live at global scope. The levels are set on the last
// bar, which is where realtime alerts evaluate, so these fire on live crosses.
// ta.cross() is called unconditionally on every bar (v6 `and` short-circuits,
// which would otherwise break its history); against na it is simply false.
crossFlip = ta.cross(close, flipLv)
crossCall = ta.cross(close, callLv)
crossPut  = ta.cross(close, putLv)
alertcondition(crossFlip, "GEX: price crossed gamma flip", "Price crossed the gamma flip level")
alertcondition(crossCall, "GEX: price crossed call wall",  "Price crossed the call wall")
alertcondition(crossPut,  "GEX: price crossed put wall",   "Price crossed the put wall")
````
