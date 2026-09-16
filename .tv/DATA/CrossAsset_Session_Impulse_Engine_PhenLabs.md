<!-- tradingview-pine-id: PUB;8d3522a06ca44dadb4f911d200d7acb0 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Cross-Asset Session Impulse Engine [PhenLabs]

Source: https://www.tradingview.com/script/j1gHuCnQ-Cross-Asset-Session-Impulse-Engine-PhenLabs/

## Description

📊 Cross-Asset Session Impulse Engine [PhenLabs]

Version: PineScript™ v6

⚠️HEADS UP⚠️
[*]Click the three dots on the right of the indicator after adding it to your chart and click pin to scale to make sure it is displaying properly

📌 Description
Cross-Asset Session Impulse Engine waits for the session opening range to lock, then asks a simple question before you take the break: did correlated markets print the same impulse, or is this chart running alone? A k-of-n basket (crypto, dollar, indices — you pick) must confirm in the same direction, with invert flags for assets like DXY that move against risk.

The engine is built for every TradingView plan. There is no footprint feed, no lower-timeframe history wall, and no silent crash when a basket symbol or volume field is missing. If the basket cannot load, the dashboard switches to chart-only and you still see the opening range. Confirmed signals, named alerts, and Pine Screener columns are included.

🚀 Points of Innovation

[*]Opening-range break is gated by live cross-asset breadth instead of a single-chart close
[*]Per-symbol invert flags so DXY-up can confirm a risk-off short without extra scripts
[*]All-plan design: same-timeframe request.security only — no Premium-only data path
[*]Dead basket symbols return na and drop out of the vote instead of aborting the script
[*]Missing volume skips the optional gate and labels Vol N/A instead of refusing to load
[*]Named bullish/bearish confirmed alerts plus Screener plots for breadth, signal, and armed state

🔧 Core Components

[*]Session clock: New York, London, Tokyo, or a custom session/timezone pair
[*]Opening range: first N session bars freeze ORH/ORL; later confirmed closes beyond those rails are impulses
[*]Basket voter: up to four input.symbol contexts, each with its own opening range on the same clock
[*]Confirmation gate: min k live same-direction votes, or chart-only when every basket feed fails
[*]Projection: ATR targets from the broken rail and invalidation at the opposite side of the range
[*]Dashboard: OR state, chart break, breadth, per-symbol arrows, data mode, signal

🔥 Key Features

[*]Preset sessions so you are not locked to US cash hours
[*]Enable/disable and invert each basket symbol; unused inputs stay hidden
[*]Optional relative-volume filter that degrades to off when the symbol has no volume
[*]Unconfirmed chart-break markers are hidden by default to keep price readable
[*]One confirmed signal per session, both directions, with alertconditions
[*]Screener-ready numeric plots (breadth net, signal +1/−1, armed)

🎨 Visualization

[*]Dashed ORH/ORL rails and a translucent opening-range box on the session
[*]Dotted ATR targets and a dashed invalidation line after a confirmed signal
[*]Triangle markers for confirmed impulses; optional faint circles for unconfirmed chart breaks
[*]Top-right dashboard: session, OR lock, chart state, breadth, basket tape, data mode, signal

📖 Usage Guidelines

[*]Session Preset — Default: New York — NY 09:30–16:00, London 08:00–16:30, Tokyo 09:00–15:00. Custom unlocks session and timezone.
[*]Opening Range Bars — Default: 6 — Range: 1-48 — On 5m this is ~30 minutes (classic ORB). Raise it on 1m, lower it on 15m.
[*]Min Basket Confirms — Default: 2 — Range: 0-4 — 0 fires on the chart break alone. Keep this ≤ the number of enabled live symbols.
[*]Enable Symbol 1–4 — Defaults: BTCUSDT on, ETHUSDT on, DXY on (invert on), ES1! off — Use distinct tickers. Invert for inverse assets.
[*]Require Relative Volume — Default: false — When on, confirmed bars need volume ≥ Min Rel Volume × SMA. No volume → gate skipped, dashboard shows N/A.
[*]Show Unconfirmed Chart Breaks — Default: false — Turn on only when you want to see the raw OR break before breadth arrives.
[*]Table Size — Default: Small — Tiny / Small / Normal. Visible only while the dashboard is on.

✅ Best Use Cases

[*]Intraday ORB on indices, FX, and crypto during NY, London, or Tokyo
[*]Filtering fake session breaks that do not show up in BTC, ETH, DXY, or ES
[*]Risk-off reads: DXY invert on so a dollar spike confirms shorts on the chart
[*]Watchlist screening via the XSIE Signal and XSIE Breadth Net columns

⚠️ Limitations

[*]Designed for intraday session charts. Daily bars often sit outside a cash-session window and will show OR as OUT.
[*]Basket symbols that match the chart ticker are skipped so the chart cannot vote twice.
[*]Confirmation can arrive after the chart break (late breadth). That is intended; the armed state stays until session end or confirmation.
[*]One signal per session. Opposite-range invalidation flags the trade; it does not flip and re-fire.
[*]Pine Screener itself is a paid TradingView product. The script only exposes plots — it does not unlock Screener on a free account.

💡 What Makes This Unique

[*]Cross-asset k-of-n is the confirmation, not a decorative correlation table
[*]All-plan data path with an explicit chart-only fallback when the basket is dead
[*]Invert-aware votes treat DXY as a risk switch instead of a same-direction clone

⚙️ Under the Hood

[*]Same-timeframe request.security basket: four unrolled tuple calls fetch OHLC on timeframe.period with lookahead_off and ignore_invalid_symbol=true. Invalid tickers return na and drop out of breadth instead of throwing. This is not lower-timeframe volume and not footprint — every plan sees the same engine.
[*]Opening-range state machine: each context (chart + basket) freezes ORH/ORL after N session bars. A break is the first confirmed close beyond the frozen rail. The lock bar cannot break because its high/low still define the range.
[*]Invert mapping: when Invert is on, an upside OR break on that symbol votes for a downside chart impulse (and vice versa).
[*]Data mode: no plan-gated feed is used. The Data row reports All-plan, live/enabled count, Vol x.xx or N/A, vol gate skipped, or basket failed · chart-only.
[*]Screener and alerts: plot XSIE Breadth Net, XSIE Signal (+1/−1 on the confirmed bar), and XSIE Armed. alertcondition titles are “XSIE Bullish Impulse Confirmed” and “XSIE Bearish Impulse Confirmed” — not a generic “extreme event”.

🔬 How It Works

[*]The session clock marks bars inside the chosen window. A new session resets range, votes, drawings, and the fired flag.
[*]The first N bars build ORH/ORL. After lock, a confirmed close beyond a rail arms bull or bear on the chart.
[*]Each live basket symbol builds its own range on the same clock and casts an up or down vote (optionally inverted).
[*]When armed direction reaches min confirms — or the basket is entirely dead and chart-only mode is on — the engine fires once, projects ATR targets, and sets invalidation at the opposite rail.
[*]A confirmed close through invalidation flags INVALIDATED. The next session starts clean.

💡 Note:
Best on 1–15m charts with the session that actually trades your market. Seed the basket with assets you can actually resolve on your TradingView plan and region; failed symbols simply show ✗ and the rest keep voting. This is an analytical aid, not financial advice.

---

## Source Code

````pine
//@version=6
indicator(
     title             = "Cross-Asset Session Impulse Engine [PhenLabs]",
     shorttitle        = "XSIE",
     overlay           = true,
     scale             = scale.none,
     max_lines_count   = 50,
     max_labels_count  = 50,
     max_boxes_count   = 20,
     max_polylines_count = 10)

// ── enums ──────────────────────────────────────────────────────────────────
enum SessionPreset
    NewYork = "New York"
    London  = "London"
    Tokyo   = "Tokyo"
    Custom  = "Custom"

enum TableSz
    Tiny   = "Tiny"
    Small  = "Small"
    Normal = "Normal"

// ── groups ─────────────────────────────────────────────────────────────────
string gSess = "Session"
string gOrb  = "Opening Range"
string gBsk  = "Cross-Asset Basket"
string gVol  = "Volume Gate"
string gVis  = "Visuals"
string gDash = "Dashboard"

// ── session ────────────────────────────────────────────────────────────────
SessionPreset sessPreset = input.enum(SessionPreset.NewYork, "Session Preset", group = gSess, tooltip = "NY 09:30–16:00, London 08:00–16:30, Tokyo 09:00–15:00 in their exchange timezones. Custom unlocks the session and timezone fields.")
string customSess = input.session("0930-1600", "Custom Session", group = gSess, active = sessPreset == SessionPreset.Custom)
string customTz   = input.string("America/New_York", "Custom Timezone", group = gSess, active = sessPreset == SessionPreset.Custom)

// ── opening range ──────────────────────────────────────────────────────────
int   orBars  = input.int(6, "Opening Range Bars", minval = 1, maxval = 48, group = gOrb, tooltip = "Bars after session open used to freeze the opening range. On 5m, 6 bars ≈ 30 minutes (classic ORB).")
int   atrLen  = input.int(14, "ATR Length", minval = 1, maxval = 100, group = gOrb)
float t1Mul   = input.float(1.0, "Target 1 (ATR)", minval = 0.1, step = 0.1, group = gOrb)
float t2Mul   = input.float(1.618, "Target 2 (ATR)", minval = 0.1, step = 0.001, group = gOrb)
int   minK    = input.int(2, "Min Basket Confirms", minval = 0, maxval = 4, group = gOrb, tooltip = "Confirmed signal requires this many live basket symbols impulsing in the same direction. 0 = chart-only (ignore basket). If every basket symbol fails to load, the engine auto-falls back to chart-only.")

// ── basket ─────────────────────────────────────────────────────────────────
bool   use1   = input.bool(true, "Enable Symbol 1", inline = "s1", group = gBsk)
string sym1   = input.symbol("BINANCE:BTCUSDT", "", inline = "s1", group = gBsk, active = use1)
bool   inv1   = input.bool(false, "Invert 1", group = gBsk, active = use1, tooltip = "On: an upside impulse on this symbol votes for a DOWNSIDE chart impulse (use for DXY vs risk assets).")

bool   use2   = input.bool(true, "Enable Symbol 2", inline = "s2", group = gBsk)
string sym2   = input.symbol("BINANCE:ETHUSDT", "", inline = "s2", group = gBsk, active = use2)
bool   inv2   = input.bool(false, "Invert 2", group = gBsk, active = use2)

bool   use3   = input.bool(true, "Enable Symbol 3", inline = "s3", group = gBsk)
string sym3   = input.symbol("TVC:DXY", "", inline = "s3", group = gBsk, active = use3)
bool   inv3   = input.bool(true, "Invert 3", group = gBsk, active = use3, tooltip = "DXY default is inverted: dollar up confirms risk-off (bearish) on the chart.")

bool   use4   = input.bool(false, "Enable Symbol 4", inline = "s4", group = gBsk)
string sym4   = input.symbol("CME_MINI:ES1!", "", inline = "s4", group = gBsk, active = use4)
bool   inv4   = input.bool(false, "Invert 4", group = gBsk, active = use4)

// ── volume ─────────────────────────────────────────────────────────────────
bool  useVol  = input.bool(false, "Require Relative Volume", group = gVol, tooltip = "When on, confirmed signals also need bar volume ≥ Min Rel Volume × SMA. If the chart has no volume, the gate is skipped automatically and the dashboard shows Vol N/A — the script still loads.")
int   volLen  = input.int(20, "Volume SMA Length", minval = 1, maxval = 200, group = gVol, active = useVol)
float volMin  = input.float(1.2, "Min Rel Volume", minval = 0.1, step = 0.1, group = gVol, active = useVol)

// ── visuals ────────────────────────────────────────────────────────────────
bool  showOr     = input.bool(true, "Show Opening Range", group = gVis)
bool  showBox    = input.bool(true, "Show OR Box", group = gVis, active = showOr)
bool  showSig    = input.bool(true, "Show Confirmed Signals", group = gVis)
bool  showRaw    = input.bool(false, "Show Unconfirmed Chart Breaks", group = gVis, tooltip = "Marks the chart OR break before basket confirmation. Off by default to keep the chart clean.")
bool  showTgt    = input.bool(true, "Show Targets / Invalidation", group = gVis)
bool  showDash   = input.bool(true, "Show Dashboard", group = gDash)
TableSz tblEnum  = input.enum(TableSz.Small, "Table Size", group = gDash, active = showDash)
color bullCol    = input.color(#00E5A0, "Bull Color", group = gVis)
color bearCol    = input.color(#FF3B6B, "Bear Color", group = gVis)
color dashBg     = input.color(#131722, "Dashboard Background", group = gDash, active = showDash)
color dashTx     = input.color(#D1D4DC, "Dashboard Text", group = gDash, active = showDash)

// ── helpers (pure — no global :=) ──────────────────────────────────────────
f_sessPair() =>
    string s = sessPreset == SessionPreset.NewYork ? "0930-1600" : sessPreset == SessionPreset.London ? "0800-1630" : sessPreset == SessionPreset.Tokyo ? "0900-1500" : customSess
    string z = sessPreset == SessionPreset.NewYork ? "America/New_York" : sessPreset == SessionPreset.London ? "Europe/London" : sessPreset == SessionPreset.Tokyo ? "Asia/Tokyo" : customTz
    [s, z]

f_short(simple string raw) =>
    string out = "—"
    if str.length(raw) > 0
        int colon = str.pos(raw, ":")
        string body = na(colon) ? raw : str.substring(raw, colon + 1)
        int bang = str.pos(body, "!")
        out := na(bang) ? body : str.substring(body, 0, bang)
    out

f_isChart(simple string s) =>
    str.length(s) == 0 or str.upper(s) == str.upper(syminfo.tickerid) or str.upper(s) == str.upper(syminfo.ticker)

f_relVol(int len) =>
    float sma = ta.sma(volume, len)
    na(volume) or na(sma) or sma <= 0 ? na : volume / sma

f_orStep(float prevOrh, float prevOrl, int prevBars, bool prevLock, bool prevUp, bool prevDn, float h, float l, float c, bool newSess, bool inSess, int lockBars, bool invert) =>
    float orh = prevOrh
    float orl = prevOrl
    int bars = prevBars
    bool locked = prevLock
    bool up = prevUp
    bool dn = prevDn
    bool dead = na(h) or na(l) or na(c)
    if newSess
        orh := dead ? na : h
        orl := dead ? na : l
        bars := dead ? 0 : 1
        locked := not dead and (1 >= lockBars)
        up := false
        dn := false
    else if inSess and not locked and not dead
        orh := math.max(nz(orh, h), h)
        orl := math.min(nz(orl, l), l)
        bars += 1
        locked := bars >= lockBars
    if inSess and locked and not dead and not na(orh) and not na(orl)
        bool rawUp = invert ? c < orl : c > orh
        bool rawDn = invert ? c > orh : c < orl
        if rawUp
            up := true
        if rawDn
            dn := true
    [orh, orl, bars, locked, up, dn]

f_mark(bool on, bool live, bool up, bool dn) =>
    not on ? "—" : not live ? "✗" : up and dn ? "↕" : up ? "↑" : dn ? "↓" : "·"

// ── session clock ──────────────────────────────────────────────────────────
[sessStr, tzStr] = f_sessPair()
bool inSess  = not na(time(timeframe.period, sessStr, tzStr))
bool newSess = inSess and not inSess[1]

float atrNow = ta.atr(atrLen)
bool  atrOk  = not na(atrNow) and atrNow > 0

float relV     = f_relVol(volLen)
bool  volAvail = not na(relV)
bool  volOk    = not useVol or not volAvail or relV >= volMin

// ── same-TF basket OHLC (do not put barstate.isconfirmed in the expression)
[s1o, s1h, s1l, s1c] = request.security(sym1, timeframe.period, [open, high, low, close], barmerge.gaps_off, barmerge.lookahead_off, true)
[s2o, s2h, s2l, s2c] = request.security(sym2, timeframe.period, [open, high, low, close], barmerge.gaps_off, barmerge.lookahead_off, true)
[s3o, s3h, s3l, s3c] = request.security(sym3, timeframe.period, [open, high, low, close], barmerge.gaps_off, barmerge.lookahead_off, true)
[s4o, s4h, s4l, s4c] = request.security(sym4, timeframe.period, [open, high, low, close], barmerge.gaps_off, barmerge.lookahead_off, true)

bool s1On = use1 and str.length(sym1) > 0 and not f_isChart(sym1)
bool s2On = use2 and str.length(sym2) > 0 and not f_isChart(sym2)
bool s3On = use3 and str.length(sym3) > 0 and not f_isChart(sym3)
bool s4On = use4 and str.length(sym4) > 0 and not f_isChart(sym4)

bool s1Live = s1On and not na(s1c) and not na(s1h)
bool s2Live = s2On and not na(s2c) and not na(s2h)
bool s3Live = s3On and not na(s3c) and not na(s3h)
bool s4Live = s4On and not na(s4c) and not na(s4h)

// ── opening-range state (global var, mutated only in global scope) ─────────
var float cOrh = na
var float cOrl = na
var int   cBars = 0
var bool  cLock = false
var bool  cUp = false
var bool  cDn = false

var float o1h = na
var float o1l = na
var int   b1 = 0
var bool  k1 = false
var bool  u1 = false
var bool  d1 = false

var float o2h = na
var float o2l = na
var int   b2 = 0
var bool  k2 = false
var bool  u2 = false
var bool  d2 = false

var float o3h = na
var float o3l = na
var int   b3 = 0
var bool  k3 = false
var bool  u3 = false
var bool  d3 = false

var float o4h = na
var float o4l = na
var int   b4 = 0
var bool  k4 = false
var bool  u4 = false
var bool  d4 = false

[nextCOrh, nextCOrl, nextCBars, nextCLock, nextCUp, nextCDn] = f_orStep(cOrh, cOrl, cBars, cLock, cUp, cDn, high, low, close, newSess, inSess, orBars, false)
[nextO1h, nextO1l, nextB1, nextK1, nextU1, nextD1] = f_orStep(o1h, o1l, b1, k1, u1, d1, s1h, s1l, s1c, newSess, inSess, orBars, inv1)
[nextO2h, nextO2l, nextB2, nextK2, nextU2, nextD2] = f_orStep(o2h, o2l, b2, k2, u2, d2, s2h, s2l, s2c, newSess, inSess, orBars, inv2)
[nextO3h, nextO3l, nextB3, nextK3, nextU3, nextD3] = f_orStep(o3h, o3l, b3, k3, u3, d3, s3h, s3l, s3c, newSess, inSess, orBars, inv3)
[nextO4h, nextO4l, nextB4, nextK4, nextU4, nextD4] = f_orStep(o4h, o4l, b4, k4, u4, d4, s4h, s4l, s4c, newSess, inSess, orBars, inv4)

cOrh := nextCOrh
cOrl := nextCOrl
cBars := nextCBars
cLock := nextCLock
cUp := nextCUp
cDn := nextCDn

o1h := nextO1h
o1l := nextO1l
b1 := nextB1
k1 := nextK1
u1 := nextU1
d1 := nextD1

o2h := nextO2h
o2l := nextO2l
b2 := nextB2
k2 := nextK2
u2 := nextU2
d2 := nextD2

o3h := nextO3h
o3l := nextO3l
b3 := nextB3
k3 := nextK3
u3 := nextU3
d3 := nextD3

o4h := nextO4h
o4l := nextO4l
b4 := nextB4
k4 := nextK4
u4 := nextU4
d4 := nextD4

int onN   = (s1On ? 1 : 0) + (s2On ? 1 : 0) + (s3On ? 1 : 0) + (s4On ? 1 : 0)
int liveN = (s1Live ? 1 : 0) + (s2Live ? 1 : 0) + (s3Live ? 1 : 0) + (s4Live ? 1 : 0)
int bullVotes = (s1Live and u1 ? 1 : 0) + (s2Live and u2 ? 1 : 0) + (s3Live and u3 ? 1 : 0) + (s4Live and u4 ? 1 : 0)
int bearVotes = (s1Live and d1 ? 1 : 0) + (s2Live and d2 ? 1 : 0) + (s3Live and d3 ? 1 : 0) + (s4Live and d4 ? 1 : 0)

bool chartOnly = liveN == 0
bool prevUp = cUp[1] == true
bool prevDn = cDn[1] == true
bool chartImpUp = inSess and barstate.isconfirmed and cLock and cUp and not prevUp and atrOk
bool chartImpDn = inSess and barstate.isconfirmed and cLock and cDn and not prevDn and atrOk

// ── signal state machine (global only) ─────────────────────────────────────
var int   armed  = 0
var bool  fired  = false
var float sigPx  = na
var float t1Px   = na
var float t2Px   = na
var float invPx  = na
var int   sigDir = 0
var int   sessStartBar = na
var bool  invalid = false

if newSess
    armed := 0
    fired := false
    sigPx := na
    t1Px := na
    t2Px := na
    invPx := na
    sigDir := 0
    sessStartBar := bar_index
    invalid := false

bool bullSig = false
bool bearSig = false

if barstate.isconfirmed and inSess and not fired and atrOk and volOk
    if chartImpUp
        armed := 1
    if chartImpDn
        armed := -1
    bool bullReady = armed == 1 and (chartOnly or bullVotes >= minK)
    bool bearReady = armed == -1 and (chartOnly or bearVotes >= minK)
    if bullReady
        bullSig := true
        fired := true
        sigDir := 1
        sigPx := close
        t1Px := cOrh + atrNow * t1Mul
        t2Px := cOrh + atrNow * t2Mul
        invPx := cOrl
    else if bearReady
        bearSig := true
        fired := true
        sigDir := -1
        sigPx := close
        t1Px := cOrl - atrNow * t1Mul
        t2Px := cOrl - atrNow * t2Mul
        invPx := cOrh

if fired and not invalid and inSess and barstate.isconfirmed and not na(invPx)
    if sigDir == 1 and close < invPx
        invalid := true
    if sigDir == -1 and close > invPx
        invalid := true

// ── drawings ───────────────────────────────────────────────────────────────
var line lnOrh = na
var line lnOrl = na
var line lnT1  = na
var line lnT2  = na
var line lnInv = na
var box  bxOr  = na
var label lbSig = na

if newSess
    // Drop the active handles without deleting their objects. TradingView's
    // drawing limits retain the most recent historical sessions automatically.
    lnOrh := na
    lnOrl := na
    lnT1 := na
    lnT2 := na
    lnInv := na
    bxOr := na
    lbSig := na

if inSess and showOr and not na(cOrh) and not na(cOrl) and not na(sessStartBar)
    color orCol = armed == -1 or sigDir == -1 ? bearCol : bullCol
    if na(lnOrh)
        lnOrh := line.new(sessStartBar, cOrh, bar_index, cOrh, xloc = xloc.bar_index, color = color.new(orCol, 0), style = line.style_dashed, width = 1)
        lnOrl := line.new(sessStartBar, cOrl, bar_index, cOrl, xloc = xloc.bar_index, color = color.new(orCol, 0), style = line.style_dashed, width = 1)
    else
        line.set_xy1(lnOrh, sessStartBar, cOrh)
        line.set_xy2(lnOrh, bar_index, cOrh)
        line.set_color(lnOrh, color.new(orCol, 0))
        line.set_xy1(lnOrl, sessStartBar, cOrl)
        line.set_xy2(lnOrl, bar_index, cOrl)
        line.set_color(lnOrl, color.new(orCol, 0))
    if showBox
        if na(bxOr)
            bxOr := box.new(sessStartBar, cOrh, bar_index, cOrl, xloc = xloc.bar_index, bgcolor = color.new(orCol, 92), border_color = color.new(orCol, 65), border_style = line.style_dotted, border_width = 1)
        else
            box.set_lefttop(bxOr, sessStartBar, cOrh)
            box.set_rightbottom(bxOr, bar_index, cOrl)
            box.set_bgcolor(bxOr, color.new(orCol, 92))
            box.set_border_color(bxOr, color.new(orCol, 65))

if fired and inSess and showTgt and not na(t1Px) and not na(invPx) and not na(sessStartBar)
    color sigCol = sigDir == 1 ? bullCol : bearCol
    if na(lnT1)
        lnT1 := line.new(bar_index, t1Px, bar_index, t1Px, xloc = xloc.bar_index, color = color.new(sigCol, 20), style = line.style_dotted, width = 1)
        lnT2 := line.new(bar_index, t2Px, bar_index, t2Px, xloc = xloc.bar_index, color = color.new(sigCol, 45), style = line.style_dotted, width = 1)
        lnInv := line.new(bar_index, invPx, bar_index, invPx, xloc = xloc.bar_index, color = color.new(bearCol, 10), style = line.style_dashed, width = 1)
    else
        line.set_xy2(lnT1, bar_index, t1Px)
        line.set_xy2(lnT2, bar_index, t2Px)
        line.set_xy2(lnInv, bar_index, invPx)

if (bullSig or bearSig) and showSig
    color sc = bullSig ? bullCol : bearCol
    string st = bullSig ? "XSIE ▲" : "XSIE ▼"
    float sigY = bullSig ? low - atrNow * 0.20 : high + atrNow * 0.20
    lbSig := label.new(bar_index, sigY, st, xloc = xloc.bar_index, yloc = yloc.price, style = bullSig ? label.style_label_up : label.style_label_down, color = color.new(sc, 0), textcolor = color.white, size = size.small)

// ── dashboard ──────────────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 7, frame_color = color.new(#2A2E39, 0), frame_width = 1, border_width = 0)

string tblSz = tblEnum == TableSz.Tiny ? size.tiny : tblEnum == TableSz.Small ? size.small : size.normal

if showDash
    string orState = not inSess ? "OUT" : not cLock ? "BUILD " + str.tostring(cBars) + "/" + str.tostring(orBars) : "LOCKED"
    string chartSt = not inSess ? "—" : cUp and cDn ? "BOTH" : cUp ? "BULL BREAK" : cDn ? "BEAR BREAK" : cLock ? "WAIT" : "OR BUILD"
    string brTxt = chartOnly ? "chart-only" : str.tostring(armed == -1 ? bearVotes : bullVotes) + "/" + str.tostring(minK) + "  (" + str.tostring(liveN) + " live)"
    string bskTxt = f_short(sym1) + f_mark(s1On, s1Live, u1, d1) + " " + f_short(sym2) + f_mark(s2On, s2Live, u2, d2) + " " + f_short(sym3) + f_mark(s3On, s3Live, u3, d3) + (s4On ? " " + f_short(sym4) + f_mark(s4On, s4Live, u4, d4) : "")
    string volTxt = volAvail ? str.tostring(relV, "#.00") + "x" : "N/A"
    string modeTxt = "All-plan · " + str.tostring(liveN) + "/" + str.tostring(onN) + " live · Vol " + volTxt
    if useVol and not volAvail
        modeTxt := modeTxt + " · vol gate skipped"
    if chartOnly and onN > 0
        modeTxt := "All-plan · basket failed · chart-only"
    string sigTxt = invalid ? "INVALIDATED" : fired and sigDir == 1 ? "CONFIRMED LONG" : fired and sigDir == -1 ? "CONFIRMED SHORT" : armed == 1 ? "ARMED LONG" : armed == -1 ? "ARMED SHORT" : "—"
    color sigC = invalid ? bearCol : fired and sigDir == 1 ? bullCol : fired and sigDir == -1 ? bearCol : dashTx
    string sessName = sessPreset == SessionPreset.NewYork ? "NY" : sessPreset == SessionPreset.London ? "LON" : sessPreset == SessionPreset.Tokyo ? "TYO" : "CUS"

    table.cell(dash, 0, 0, "XSIE", text_color = dashTx, bgcolor = dashBg, text_size = tblSz, text_halign = text.align_left, text_formatting = text.format_bold)
    table.cell(dash, 1, 0, sessName + " " + sessStr, text_color = dashTx, bgcolor = dashBg, text_size = tblSz, text_halign = text.align_right)
    table.cell(dash, 0, 1, "OR", text_color = dashTx, bgcolor = dashBg, text_size = tblSz, text_halign = text.align_left)
    table.cell(dash, 1, 1, orState, text_color = cLock ? bullCol : dashTx, bgcolor = dashBg, text_size = tblSz, text_halign = text.align_right)
    table.cell(dash, 0, 2, "Chart", text_color = dashTx, bgcolor = dashBg, text_size = tblSz, text_halign = text.align_left)
    table.cell(dash, 1, 2, chartSt, text_color = cUp ? bullCol : cDn ? bearCol : dashTx, bgcolor = dashBg, text_size = tblSz, text_halign = text.align_right)
    table.cell(dash, 0, 3, "Breadth", text_color = dashTx, bgcolor = dashBg, text_size = tblSz, text_halign = text.align_left)
    table.cell(dash, 1, 3, brTxt, text_color = dashTx, bgcolor = dashBg, text_size = tblSz, text_halign = text.align_right)
    table.cell(dash, 0, 4, "Basket", text_color = dashTx, bgcolor = dashBg, text_size = tblSz, text_halign = text.align_left)
    table.cell(dash, 1, 4, bskTxt, text_color = dashTx, bgcolor = dashBg, text_size = tblSz, text_halign = text.align_right)
    table.cell(dash, 0, 5, "Data", text_color = dashTx, bgcolor = dashBg, text_size = tblSz, text_halign = text.align_left)
    table.cell(dash, 1, 5, modeTxt, text_color = dashTx, bgcolor = dashBg, text_size = tblSz, text_halign = text.align_right)
    table.cell(dash, 0, 6, "Signal", text_color = dashTx, bgcolor = dashBg, text_size = tblSz, text_halign = text.align_left, text_formatting = text.format_bold)
    table.cell(dash, 1, 6, sigTxt, text_color = sigC, bgcolor = dashBg, text_size = tblSz, text_halign = text.align_right, text_formatting = text.format_bold)
else
    table.clear(dash, 0, 0, 1, 6)

// ── plots / shapes / alerts (screener + both directions) ───────────────────
// Invisible price proxies force XSIE's visual coordinate system to follow the
// chart symbol's visible high/low range. They are fully transparent but remain
// pane-displayed so TradingView includes them in scale calibration.
plot(high, "XSIE Price Anchor High", color = color.new(color.white, 100), linewidth = 1, editable = false, display = display.pane)
plot(low, "XSIE Price Anchor Low", color = color.new(color.white, 100), linewidth = 1, editable = false, display = display.pane)

plotshape(bullSig and showSig ? low - atrNow * 0.10 : na, title = "XSIE Bull Confirmed", style = shape.triangleup, location = location.absolute, color = bullCol, size = size.small)
plotshape(bearSig and showSig ? high + atrNow * 0.10 : na, title = "XSIE Bear Confirmed", style = shape.triangledown, location = location.absolute, color = bearCol, size = size.small)
plotshape(chartImpUp and not bullSig and showRaw ? low - atrNow * 0.05 : na, title = "XSIE Raw Bull", style = shape.circle, location = location.absolute, color = color.new(bullCol, 50), size = size.tiny)
plotshape(chartImpDn and not bearSig and showRaw ? high + atrNow * 0.05 : na, title = "XSIE Raw Bear", style = shape.circle, location = location.absolute, color = color.new(bearCol, 50), size = size.tiny)

plot(bullVotes - bearVotes, "XSIE Breadth Net", display = display.data_window)
plot(bullSig ? 1 : bearSig ? -1 : 0, "XSIE Signal", display = display.data_window)
plot(armed, "XSIE Armed", display = display.data_window)

alertcondition(bullSig, title = "XSIE Bullish Impulse Confirmed", message = "XSIE: bullish session impulse confirmed by basket breadth")
alertcondition(bearSig, title = "XSIE Bearish Impulse Confirmed", message = "XSIE: bearish session impulse confirmed by basket breadth")
````
