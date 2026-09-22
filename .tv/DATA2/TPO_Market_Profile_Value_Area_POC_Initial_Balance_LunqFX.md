<!-- tradingview-pine-id: PUB;2c011ce6a8194b02b5a5ead6cab94671 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# TPO Market Profile, Value Area, POC & Initial Balance [LunqFX]

Source: https://www.tradingview.com/script/OHHJmtGY-TPO-Market-Profile-Value-Area-POC-Initial-Balance-LunqFX/

## Description

A volume profile answers how MUCH traded at each price. A Market Profile answers a different question: how LONG price stayed there. This indicator draws the second one — a TPO profile, built letter by letter from the session's own half-hour brackets, with the Point of Control, the Value Area and the Initial Balance that come with it.

That distinction is the whole reason Market Profile exists as a separate discipline. Price can sit on a level for four hours on thin volume, and a volume profile will draw a narrow bar there while the auction was in fact spending most of its day at that price. Time at price and volume at price are two different maps of the same session, and they routinely disagree about where value actually is.

TPO stands for Time Price Opportunity, and the profile is the shape those opportunities build. It is the same structure floor traders assembled by hand before screens existed, which is why the Point of Control, the Value Area and the Initial Balance are named the way they are rather than the way a modern indicator would name them.

Included: TPO letters per session, the Point of Control, a value area at a percentage you choose, the Initial Balance of the first hour, levels extended to the right, a dashboard reading where price sits against that structure, and alerts on acceptance outside value and on the initial balance breaking.

❶ THE PROFILE AND WHAT IT COUNTS

The session is split into brackets of thirty minutes by default. Bracket one is A, bracket two is B, and so on. A bracket is credited to a price row when it traded anywhere inside that row, and each row is then drawn to the length of the count it collected.

The counting rule matters more than it sounds: a bracket counts ONCE for a row however many bars of that bracket touched it. That single rule is what makes the result a measure of time rather than of activity, and it is the entire difference from the volume profile beside it on your chart.

Brackets are cut from elapsed session time rather than from bar count, so the same profile appears whether you run the chart on 5 minutes or on 15.

A bracket can never be finer than a bar, and the script enforces that rather than letting you ask for something the chart cannot deliver. Request thirty-minute brackets on a one-hour chart and every bar would jump the counter by two, leaving half the brackets empty and the letter view printing A, C, E with the gaps missing. The bracket size is floored at the chart's own timeframe, and the dashboard shows the size actually in use.

The classic letter view — A, B, C printed at every price the bracket reached — is in the settings, and it is worth knowing why it is not the default. A true TPO grid needs one text object per row per bracket: forty rows across twenty-six brackets is more than a thousand objects for one session, against a platform cap of five hundred for the whole script. Packing each row's letters into a single text object instead runs into a second wall, because Pine centres a label's text on its anchor and gives no way to left-align it, so the profile spreads both ways from the anchor and lands on top of price. Rows drawn to their own length say the same thing and can be read at a glance. Both views are one setting apart, and there is a shift control for moving either clear of the candles.

❷ POINT OF CONTROL — THE POC

The price row that collected the most brackets — the price the session spent the most time at. It is drawn as a solid line and its row of letters is coloured gold.

A volume profile has a POC too, and the two are frequently at different prices on the same day. That gap is worth looking at: a volume POC well away from the time POC means the heavy trading and the long acceptance happened in different places, which is usually where the day's argument was.

The POC is where the auction found agreement. Traders use it as the session's magnet: price that leaves it tends to come back to it, and a session whose POC is far from its close often has unfinished business there.

❸ VALUE AREA

The band containing the chosen share of the session's total time, seventy percent by convention. It is built the classic way: start at the Point of Control, then step outward one row at a time, always taking whichever neighbouring row holds more time, until the target is enclosed.

Rows inside the value area are drawn bright; rows outside are dimmed. What you are looking at is the difference between where the market agreed on price and where it merely passed through.

❹ INITIAL BALANCE

The high and low set during the first two brackets — the first hour of the session on default settings. Drawn as two dotted lines.

The Initial Balance is the day's opening statement. A session that spends the rest of the day inside it is balanced and rotational, and its edges are the fade. A session that leaves it early has found a direction, and the break level becomes the reference for the rest of the day. The dashboard says which of the two is happening.

❺ THE DASHBOARD

A header that reads IN VALUE, ABOVE VALUE or BELOW VALUE according to where price sits against the developing profile, the number of brackets built so far, the Point of Control, both value area edges, the Initial Balance range, and whether that balance is still holding.

HOW TO USE IT

1 — Read the header first. In value means the session is balanced and the edges are the trade. Above or below value means price is away from agreement and either seeking a new one or coming back.

2 — Use the Point of Control as the session's magnet. It is the single most-referenced price of the day and the most common target for a return move.

3 — Watch the Initial Balance in the first two hours. Holding inside it points to a rotational day; leaving it early points to a directional one, and that judgement changes which of the levels above are worth trading.

4 — Compare today's value area with yesterday's. Higher value against lower value is the cleanest read of whether the auction is migrating, and it is visible at a glance once several sessions are on the chart.

5 — Read it beside a volume profile, not instead of one. Where the two disagree — heavy volume at a price the market barely spent time at, or the reverse — is where the most information is.

HOW IT WORKS

Sessions come from the symbol's own trading day, so nothing has to be configured per market. Elapsed session time in minutes divided by the bracket size gives each bar its bracket number, which keeps letters tied to the clock rather than to bar count.

When a session closes, its range is divided into the chosen number of rows. For every row the script walks the session's bars and marks which brackets overlapped that row, then counts the distinct brackets and builds the letter string. The row with the highest count becomes the Point of Control. The value area grows outward from it, one row at a time toward whichever neighbour holds more, until the chosen share of total brackets is enclosed. The Initial Balance is the extreme high and low among bars belonging to brackets one and two.

A completed session is drawn once and never touched again. The developing session is rebuilt once per closed bar.

Best used on intraday charts from 5 to 30 minutes, on instruments with a defined session — index futures and CFDs, gold, forex majors, large-cap crypto.

LIMITATIONS — read before relying on any of it

▸ This is a bar-based approximation of a floor-based technique. Classic TPO is built from every price the market printed during a bracket; here a bracket is credited to a row when any bar of that bracket overlapped the row. On low timeframes the two are nearly identical; on higher ones a single wide bar credits its bracket to more rows than the market may truly have spent time in, and the profile widens accordingly. Use 5 to 30 minute charts and the difference stays small.

▸ It needs an intraday chart. A profile is built from many bars inside one session, so on a daily chart or higher a single bar IS the session and there is nothing to divide. The script draws nothing there and the dashboard says so rather than printing a meaningless block. Use 5 to 30 minutes.

▸ Sessions are the symbol's own trading day. On a market that trades around the clock that is the calendar day in exchange time, which is a convention rather than a real auction boundary. Crypto profiles are therefore useful for structure but not for session theory in the futures sense.

▸ Only the most recent sessions are built. Older sessions are skipped entirely rather than drawn and discarded, because building every session of a long history is enough to time the script out. Scroll back far enough and the profiles stop.

▸ The first session on a freshly loaded chart can be partial. The script starts counting a session from the first bar it is given, and if the chart begins in the middle of a trading day that profile covers only the part it could see. It is normally out of range of the sessions actually drawn, but on a very short chart it is the one to distrust.

▸ The row count changes the shape. More rows give a finer profile with a more precise Point of Control; fewer rows smooth it. Two readings are only comparable at the same row count.

▸ The letter view is a compromise, and the default block view exists because of it. Pine caps a script at five hundred drawing objects and centres a label's text on its anchor with no way to left-align it, so neither a true letter grid nor a clean left-anchored letter column is possible. If you switch the letters on, expect them centred on the anchor rather than laid out as a terminal would lay them out.

▸ There is a hard platform limit on drawings. With the default forty rows and five sessions the script stays well inside it, but raising both together will start dropping the oldest rows.

▸ The Initial Balance is the first two brackets, which is one hour on default settings. Traders who define it differently should change the bracket size rather than expect the level to move.

▸ None of this predicts anything. A profile describes an auction that has already happened.

WHY IT IS ORIGINAL

Time at price and volume at price are different measurements, and this publication implements the first. The counting rule — one credit per bracket per row regardless of how many bars touched it — is what separates the two, and it is stated openly here rather than left inside the code.

The parts belong together because they are one object read at four resolutions. The letters are the raw shape. The Point of Control is its densest point. The value area is the band that shape encloses. The Initial Balance is the first hour of it, kept separate because the day's character is decided there. Remove the letters and the levels float above nothing; remove the levels and the shape has to be read by eye.

SETTINGS

▸ Profile — bracket size in minutes, price rows per session, value area percentage, how many sessions to keep. The bracket size is floored at the chart's timeframe, and the profile width is capped at the session's own bar count, so neither setting can be pushed into a state the chart cannot render honestly. ▸ Levels — Point of Control, value area edges, initial balance, and how far levels extend to the right. ▸ Visuals — blocks or letters, profile width and transparency, letter size, how far to shift the profile sideways, neon candles, dashboard and its position.

ALERTS — accepted above value, accepted below value, initial balance broken up, initial balance broken down. All fire on closed bars.

NON-REPAINTING — a completed session's profile is drawn once from closed bars and is never recalculated. Only the developing session updates, and it rebuilds once per closed bar rather than tick by tick.

This indicator is an educational market-analysis tool, not financial advice. It describes the structure of sessions that have already completed and does not predict future prices. Always confirm with your own analysis and manage your risk.

---

## Source Code

````pine
//@version=6
// ============================================================================
//  TPO Market Profile, Value Area, POC & Initial Balance [LunqFX]
// ----------------------------------------------------------------------------
//  A volume profile answers how MUCH traded at each price. This answers a
//  different question: how LONG price stayed there.
//
//  Every session is split into half-hour brackets, each bracket gets a letter,
//  and that letter is printed at every price the bracket traded through. The
//  shape the letters build is the session's Market Profile — the auction seen
//  as time at price rather than volume at price. Price can sit on a level for
//  four hours on almost no volume, and only one of the two profiles will ever
//  show you that.
//
//    1  THE PROFILE   each price row drawn to the length of the time it held
//    2  POC           the price that collected the most time
//    3  VALUE AREA    the band holding 70% of the session's time
//    4  INITIAL BAL   the range set by the first hour, drawn separately
//    5  PANEL         where price sits against that structure right now
//
//  The classic letter view is available in the settings. It is not the
//  default because a true TPO grid needs one text object per row per bracket,
//  which is over a thousand objects for a single session against a platform
//  cap of five hundred for the entire script.
//
//  NON-REPAINTING: a completed session's profile is drawn once, from closed
//  bars, and is never recalculated. Only the developing session updates, and
//  it rebuilds once per closed bar rather than on every tick.
// ============================================================================
// No max_bars_back is declared: the deepest historical reference in the whole
// script is [1], and reserving a large history buffer for nothing costs memory
// the drawings actually need.
indicator("TPO Market Profile, Value Area, POC & Initial Balance [LunqFX]",
     "TPO", overlay = true, max_labels_count = 500, max_lines_count = 500,
     max_boxes_count = 500)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE
// ─────────────────────────────────────────────────────────────────────────
VALUE = #00F5D4      // rows inside the value area, and rising candles
FALL  = #FF2E88      // falling candles — the matched half of the pair
OUT   = #6B7688      // rows outside the value area
POC_C = #FBBF24      // the price that held the most time
IB_C  = #A78BFA      // initial balance
CARD  = #131A24
CARD2 = #1B2431
TXT   = #F1F5F9
MUTE  = #94A3B8

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gP    = "Profile"
brkMin= input.int(30, "Bracket size (minutes)", minval = 5, maxval = 240, step = 5, group = gP, tooltip = "The classic Market Profile bracket is thirty minutes: each half hour of the session becomes one letter. Larger brackets give a coarser, faster profile.")
rows  = input.int(40, "Price rows per session", minval = 10, maxval = 80, group = gP, tooltip = "How finely the session's range is divided. More rows give a more detailed shape and cost more to draw.")
vaPct = input.float(70.0, "Value area %", minval = 40.0, maxval = 95.0, step = 1.0, group = gP, tooltip = "The share of the session's time the value area must contain. Seventy percent is the convention Market Profile was built around.")
nSess = input.int(5, "Sessions shown", minval = 1, maxval = 10, group = gP)

gL    = "Levels"
showPOC = input.bool(true, "Point of Control", group = gL)
showVA  = input.bool(true, "Value area edges", group = gL)
showIB  = input.bool(true, "Initial balance", group = gL, tooltip = "The range set during the first two brackets — the first hour of the session on default settings. Leaving it is the classic sign the session has found a direction.")
extRight= input.int(20, "Extend levels right (bars)", minval = 0, maxval = 200, group = gL)

gV    = "Visuals"
// Blocks rather than letters by default, and the reason is a hard platform
// limit rather than taste. A real TPO grid is one letter per row per bracket:
// forty rows across twenty-six brackets is over a thousand objects for a
// single session, against a cap of five hundred for the whole script. Packing
// a row's letters into one text object instead makes Pine centre the string
// on its anchor, which is how the profile ends up as an unreadable column of
// type sitting on the candles. A row drawn as a bar of its own length says
// the same thing and can actually be read.
blocks  = input.bool(true, "Draw the profile as blocks", group = gV)
blockW  = input.int(30, "Profile width (bars)", minval = 5, maxval = 200, group = gV, tooltip = "How many bars wide the longest row of the profile is drawn. Everything else is scaled against it.")
blockOp = input.int(58, "Profile transparency", minval = 20, maxval = 90, group = gV, tooltip = "Higher lets more of the price action through. The profile sits over the session it describes, so this is the setting that decides which of the two you read first.")
letters = input.bool(false, "Draw the TPO letters instead", group = gV, tooltip = "The authentic letter view. Pine centres a label's text on its anchor and cannot left-align it, so the letters spread both ways from the anchor point — use the shift setting below to move them clear of price.")
txtSize = input.string("Small", "Letter size", options = ["Tiny","Small","Normal"], group = gV)
// Pine centres the text of a label on its anchor, so a profile drawn at the
// session's first bar spreads both ways from it and lands on the candles.
// This pushes the whole profile sideways so the two stop fighting.
shiftX  = input.int(0, "Shift the profile (bars)", minval = -300, maxval = 300, group = gV, tooltip = "Negative moves the profile left of the session, positive moves it right. Zero draws it over the session, which is the classic Market Profile placement.")
candOn  = input.bool(true, "Neon candles", group = gV, tooltip = "Translucent bodies against solid outlines, so the candles sit in the chart rather than on top of it. Turn off to keep your own colours.")
showHUD = input.bool(true, "Dashboard", group = gV)
hudPos  = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gV)

// ─────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────
// Pine has no character-from-code function, so the bracket alphabet is a
// lookup string. Fifty-two letters covers a twenty-six hour session at
// half-hour brackets, which is longer than any listed market runs.
ALPHA = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

letterOf(int i) =>
    j = math.min(math.max(i, 0), 51)
    str.substring(ALPHA, j, j + 1)

sizeOf(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        => size.small

hudP(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.middle_right

// ─────────────────────────────────────────────────────────────────────────
//  SESSION AND BRACKETS
//  The session is the symbol's own trading day, so nothing has to be set per
//  market. A bracket is the whole-numbered slice of elapsed session time,
//  which keeps letters tied to the clock rather than to the bar count — the
//  same profile therefore appears on a 5-minute and on a 15-minute chart.
// ─────────────────────────────────────────────────────────────────────────
// A Market Profile needs many bars inside one session. On a daily chart or
// higher a bar IS the session, so every "session" holds one bracket and the
// profile of a single bar is not a profile at all. The script draws nothing
// there and the panel says why, rather than printing a meaningless block.
intraday = timeframe.in_seconds() < 86400

// A bracket cannot be finer than a bar. Ask for thirty-minute brackets on a
// one-hour chart and every bar jumps the bracket counter by two, so half the
// brackets are never filled: the count reads twenty-nine where fifteen were
// actually traded, and the letter view prints A, C, E with the gaps missing.
// The requested size is therefore floored at the chart's own timeframe.
tfMin    = math.max(1, int(timeframe.in_seconds() / 60))
brkEff   = math.max(brkMin, tfMin)

dTime   = time("D")
sessNew = na(dTime[1]) ? false : dTime != dTime[1]

var int sessOpenTime = na
var int sessOpenBar  = na

// per-bar record of the session being built
var array<float> bh = array.new<float>()
var array<float> bl = array.new<float>()
var array<int>   bk = array.new<int>()

// ─────────────────────────────────────────────────────────────────────────
//  DRAWING STORE
//  Completed sessions keep their drawings. The developing one is rebuilt as
//  the session grows, so the two sets are held apart and only the developing
//  set is ever deleted.
// ─────────────────────────────────────────────────────────────────────────
var array<label> keptLbl = array.new<label>()
var array<line>  keptLin = array.new<line>()
var array<box>   keptBox = array.new<box>()
var array<label> devLbl  = array.new<label>()
var array<line>  devLin  = array.new<line>()
var array<box>   devBox  = array.new<box>()

// Every function here takes the arrays it works on as parameters rather than
// reaching for them in the outer scope. It reads the same way at each call
// site and it keeps one rule throughout: nothing in this script touches state
// it was not handed.
wipe(array<label> lbls, array<line> lins, array<box> bxs) =>
    if array.size(lbls) > 0
        for i = 0 to array.size(lbls) - 1
            label.delete(array.get(lbls, i))
        array.clear(lbls)
    if array.size(lins) > 0
        for i = 0 to array.size(lins) - 1
            line.delete(array.get(lins, i))
        array.clear(lins)
    if array.size(bxs) > 0
        for i = 0 to array.size(bxs) - 1
            box.delete(array.get(bxs, i))
        array.clear(bxs)
    0

// The platform hard-caps a script at 500 objects of each kind, and rows x
// sessions can be set past that. Pine would then drop the oldest silently
// while the array kept holding references to them, so the cap is enforced
// here — and it has to be measured from `rows`, because the developing
// session adds a whole profile of its own on top of whatever is kept.
trim(array<label> lbls, array<line> lins, array<box> bxs) =>
    cap = math.min(rows * nSess, 500 - rows)
    while array.size(lbls) > cap
        label.delete(array.get(lbls, 0))
        array.shift(lbls)
    while array.size(bxs) > cap
        box.delete(array.get(bxs, 0))
        array.shift(bxs)
    while array.size(lins) > 6 * nSess
        line.delete(array.get(lins, 0))
        array.shift(lins)
    0

// ─────────────────────────────────────────────────────────────────────────
//  THE PROFILE
//  Rows are cut from the session's own range. A bracket counts once for a row
//  when it traded anywhere inside it, however many bars of that bracket
//  touched it — that single rule is what makes this a measure of time rather
//  than of activity, and it is the whole difference from a volume profile.
//
//  Two things are deliberate in the signature. The measurements come back as
//  a tuple, because Pine does not allow a function to assign to a variable
//  declared outside it. And the drawing stores are passed IN rather than
//  reached for as globals, which removes any question about a function
//  mutating outer state and drops the branching this used to need.
// ─────────────────────────────────────────────────────────────────────────
build(array<label> lblStore, array<line> linStore, array<box> boxStore) =>
    float pocY = na
    float vahY = na
    float valY = na
    float ibH  = na
    float ibL  = na
    int   nBrk = 0

    n = array.size(bh)
    if n > 0 and not na(sessOpenBar)
        hi  = array.max(bh)
        lo  = array.min(bl)
        rng = hi - lo
        if rng > 0
            rh   = rng / rows
            maxB = array.max(bk)
            nBrk := maxB + 1

            counts = array.new<int>(rows, 0)
            texts  = array.new<string>(rows, "")
            // allocated once and refilled per row: creating a fresh array
            // inside the row loop makes one throwaway object per row per build
            seen   = array.new<bool>(maxB + 1, false)

            for r = 0 to rows - 1
                rLo  = lo + rh * r
                rHi  = rLo + rh
                array.fill(seen, false)
                for i = 0 to n - 1
                    if array.get(bh, i) >= rLo and array.get(bl, i) <= rHi
                        array.set(seen, array.get(bk, i), true)
                c = 0
                s = ""
                for b = 0 to maxB
                    if array.get(seen, b)
                        c += 1
                        // the letter string is only assembled when it will be
                        // drawn; building it regardless is a string join per
                        // bracket per row on every rebuild, for nothing
                        if letters
                            s := s + letterOf(b)
                array.set(counts, r, c)
                array.set(texts, r, s)

            total = array.sum(counts)
            pocR  = array.indexof(counts, array.max(counts))

            // Value area: grow outward from the POC, always taking the richer
            // neighbour, until the target share of the session's time is
            // enclosed. The loop condition alone guarantees a side is still
            // available, so no early exit is needed — Pine has no `break`.
            need = total * vaPct / 100.0
            acc  = array.get(counts, pocR)
            up   = pocR
            dn   = pocR
            while acc < need and (up < rows - 1 or dn > 0)
                cu = up < rows - 1 ? array.get(counts, up + 1) : -1
                cd = dn > 0        ? array.get(counts, dn - 1) : -1
                if cu >= cd and cu >= 0
                    up  += 1
                    acc += cu
                else if cd >= 0
                    dn  -= 1
                    acc += cd

            pocY := lo + rh * (pocR + 0.5)
            vahY := lo + rh * (up + 1)
            valY := lo + rh * dn

            // initial balance: the range of the first two brackets
            for i = 0 to n - 1
                if array.get(bk, i) <= 1
                    ibH := na(ibH) ? array.get(bh, i) : math.max(ibH, array.get(bh, i))
                    ibL := na(ibL) ? array.get(bl, i) : math.min(ibL, array.get(bl, i))

            xL = sessOpenBar + shiftX
            xR = bar_index + extRight

            // Rows drawn as bars: length is the row's bracket count against the
            // busiest row, so the shape IS the distribution of time. The POC is
            // by construction the longest bar on the profile.
            // Width is capped at the session's own bar count. A profile wider
            // than the session it describes runs over the top of the next one,
            // which is visible the moment the chart timeframe is coarse enough
            // that a session holds fewer bars than the requested width.
            maxC = array.max(counts)
            wMax = math.min(blockW, n)
            if blocks and maxC > 0
                for r = 0 to rows - 1
                    c2 = array.get(counts, r)
                    if c2 > 0
                        col = r == pocR ? POC_C : (r >= dn and r <= up) ? VALUE : OUT
                        w   = math.max(1, int(math.round(c2 / float(maxC) * wMax)))
                        y0  = lo + rh * r
                        y1  = y0 + rh * 0.82          // a gap between rows keeps them legible
                        array.push(boxStore, box.new(xL, y1, xL + w, y0,
                             border_color = color.new(col, 100),
                             bgcolor = color.new(col, r == pocR ? math.max(10, blockOp - 30) : blockOp)))

            if letters
                for r = 0 to rows - 1
                    t = array.get(texts, r)
                    if str.length(t) > 0
                        col = r == pocR ? POC_C : (r >= dn and r <= up) ? VALUE : OUT
                        array.push(lblStore, label.new(xL, lo + rh * (r + 0.5), t,
                             xloc = xloc.bar_index, style = label.style_none,
                             textcolor = col, size = sizeOf(txtSize), textalign = text.align_left))

            if showPOC
                array.push(linStore, line.new(xL, pocY, xR, pocY, color = POC_C, width = 2))

            if showVA
                array.push(linStore, line.new(xL, vahY, xR, vahY, color = color.new(VALUE, 25), width = 1, style = line.style_dashed))
                array.push(linStore, line.new(xL, valY, xR, valY, color = color.new(VALUE, 25), width = 1, style = line.style_dashed))

            if showIB and not na(ibH) and not na(ibL)
                array.push(linStore, line.new(xL, ibH, xR, ibH, color = color.new(IB_C, 30), width = 1, style = line.style_dotted))
                array.push(linStore, line.new(xL, ibL, xR, ibL, color = color.new(IB_C, 30), width = 1, style = line.style_dotted))

    [pocY, vahY, valY, ibH, ibL, nBrk]

// ─────────────────────────────────────────────────────────────────────────
//  SESSION LOOP
// ─────────────────────────────────────────────────────────────────────────
var float curPOC = na
var float curVAH = na
var float curVAL = na
var float curIBH = na
var float curIBL = na
var int   curBrk = 0

if intraday and sessNew and barstate.isconfirmed
    // Only sessions close enough to the end of the chart are ever built. The
    // script keeps `nSess` of them, so building every session in a two-year
    // history and then deleting all but five is thousands of full passes done
    // for nothing — which is how a profile script times out on load.
    sessBars = array.size(bh)
    if sessBars > 0 and bar_index >= last_bar_index - sessBars * (nSess + 1)
        wipe(devLbl, devLin, devBox)
        [p0, v0, l0, h0, o0, b0] = build(keptLbl, keptLin, keptBox)
        trim(keptLbl, keptLin, keptBox)
    array.clear(bh)
    array.clear(bl)
    array.clear(bk)
    sessOpenTime := time
    sessOpenBar  := bar_index

if na(sessOpenTime)
    sessOpenTime := time
    sessOpenBar  := bar_index

// The intraday guard belongs here too, not only on the drawing. Without it a
// daily chart keeps pushing every bar into these arrays while the block that
// clears them never runs, so the script quietly accumulates the entire history
// and frees none of it.
if intraday and barstate.isconfirmed
    elapsedMin = math.max(0, int((time - sessOpenTime) / 60000))
    array.push(bh, high)
    array.push(bl, low)
    array.push(bk, int(elapsedMin / brkEff))

// The developing profile is rebuilt once per closed bar, not on every tick.
// Rebuilding is an O(rows x bars) pass, and running it tick by tick on a fast
// chart is enough to make the whole script stutter.
var int lastDevBar = -1
if intraday and barstate.islast and bar_index != lastDevBar
    lastDevBar := bar_index
    wipe(devLbl, devLin, devBox)
    [p, vh, vl, ih, il, nb] = build(devLbl, devLin, devBox)
    curPOC := p
    curVAH := vh
    curVAL := vl
    curIBH := ih
    curIBL := il
    curBrk := nb

// ─────────────────────────────────────────────────────────────────────────
//  CANDLES
//  A matched neon pair at the same saturation and lightness, with translucent
//  bodies against solid outlines. The background shows faintly through the
//  body while the edge stays crisp, which is what makes a candle read as part
//  of the chart rather than a sticker placed over it.
// ─────────────────────────────────────────────────────────────────────────
cEdge = close >= open ? VALUE : FALL
plotcandle(candOn ? open : na, high, low, close, "Candles",
     color = color.new(cEdge, 24), wickcolor = color.new(cEdge, 18), bordercolor = cEdge)

// ─────────────────────────────────────────────────────────────────────────
//  DASHBOARD
// ─────────────────────────────────────────────────────────────────────────
var table hud = table.new(position.top_right, 2, 6)
if showHUD and barstate.islast
    table.delete(hud)
    hud := table.new(hudP(hudPos), 2, 6, bgcolor = CARD,
         border_color = color.new(#28323F, 0), border_width = 1)

    inValue = not na(curVAH) and not na(curVAL) and close <= curVAH and close >= curVAL
    aboveVA = not na(curVAH) and close > curVAH
    ibBroke = not na(curIBH) and not na(curIBL) and (close > curIBH or close < curIBL)

    hTx = not intraday ? "USE AN INTRADAY CHART" :
          na(curPOC)   ? "building the session" :
          inValue      ? "IN VALUE  ·  balanced" :
          aboveVA      ? "ABOVE VALUE  ·  seeking higher" : "BELOW VALUE  ·  seeking lower"
    hBg = not intraday ? #4A3410 : na(curPOC) ? CARD2 : inValue ? #23324A : aboveVA ? #0A5F55 : #8E1148
    // the effective bracket is shown, not the requested one, so a chart whose
    // timeframe forced the size up says so instead of quietly disagreeing
    hSub= not intraday ? "a daily bar is one bracket  " : str.tostring(curBrk) + " x " + str.tostring(brkEff) + "m  "

    table.cell(hud, 0, 0, "  " + hTx + "  ", text_color = color.white, text_size = size.large, text_halign = text.align_left, bgcolor = hBg)
    table.cell(hud, 1, 0, hSub, text_color = color.white, text_size = size.normal, text_halign = text.align_right, bgcolor = hBg)

    table.cell(hud, 0, 1, "  Point of Control", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = CARD)
    // size.large, not huge: a price is six to eight characters, and at huge
    // the cell grows wide enough to push the whole panel under the price
    // scale on the right of the chart
    table.cell(hud, 1, 1, (na(curPOC) ? "—" : str.tostring(curPOC, format.mintick)) + "  ", text_color = POC_C, text_size = size.large, text_halign = text.align_right, bgcolor = CARD)

    table.cell(hud, 0, 2, "  Value area high", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = CARD2)
    table.cell(hud, 1, 2, (na(curVAH) ? "—" : str.tostring(curVAH, format.mintick)) + "  ", text_color = TXT, text_size = size.normal, text_halign = text.align_right, bgcolor = CARD2)

    table.cell(hud, 0, 3, "  Value area low", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = CARD2)
    table.cell(hud, 1, 3, (na(curVAL) ? "—" : str.tostring(curVAL, format.mintick)) + "  ", text_color = TXT, text_size = size.normal, text_halign = text.align_right, bgcolor = CARD2)

    ibTx = na(curIBH) or na(curIBL) ? "—" : str.tostring(curIBL, format.mintick) + "  –  " + str.tostring(curIBH, format.mintick)
    table.cell(hud, 0, 4, "  Initial balance", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = CARD)
    table.cell(hud, 1, 4, ibTx + "  ", text_color = IB_C, text_size = size.normal, text_halign = text.align_right, bgcolor = CARD)

    table.cell(hud, 0, 5, "  Day so far", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = CARD2)
    table.cell(hud, 1, 5, (na(curIBH) ? "—" : ibBroke ? "initial balance broken" : "holding inside first hour") + "  ", text_color = na(curIBH) ? MUTE : ibBroke ? POC_C : MUTE, text_size = size.normal, text_halign = text.align_right, bgcolor = CARD2)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS — closed bars only
// ─────────────────────────────────────────────────────────────────────────
alertcondition(barstate.isconfirmed and not na(curVAH) and close > curVAH and close[1] <= curVAH, "Accepted above value", "LunqFX TPO: price closed above the value area high")
alertcondition(barstate.isconfirmed and not na(curVAL) and close < curVAL and close[1] >= curVAL, "Accepted below value", "LunqFX TPO: price closed below the value area low")
alertcondition(barstate.isconfirmed and not na(curIBH) and close > curIBH and close[1] <= curIBH, "Initial balance broken up", "LunqFX TPO: price closed above the initial balance high")
alertcondition(barstate.isconfirmed and not na(curIBL) and close < curIBL and close[1] >= curIBL, "Initial balance broken down", "LunqFX TPO: price closed below the initial balance low")
````
