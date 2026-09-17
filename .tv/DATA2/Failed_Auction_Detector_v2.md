<!-- tradingview-pine-id: PUB;981490bf8d804fe6ac0646aa60407e0d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Failed Auction Detector v2

Source: https://www.tradingview.com/script/rDboLLir-Failed-Auction-Detector/

## Description

Failed Auction Detector — footprint-confirmed rejection at swept reference levels

Every push through a level is the market asking a question: is there real business up here, or was that just noise wearing conviction's clothes? Most of the time nobody answers the question properly. A wick forms, the candle closes back inside the level, and every "stop hunt" or "liquidity sweep" indicator on the platform declares victory — because that's all they ever look at: the shape left behind, not what actually traded while it was being made.

That's the gap this script was built to close. A market is a two-sided auction. When price extends beyond a reference level — a swing extreme, a session high or low, the prior day's high or low — the auction is testing whether new business exists at the new price. It either finds acceptance and the range expands, or it finds nothing and snaps back. The candle can't tell you which one happened; the volume that traded during the extension can.

The problem with wicks

A wick past a level that closes back inside is a necessary condition for a failed auction. It is nowhere near sufficient. Thin resting liquidity, a single oversized print, plain noise — all of these can leave the exact same shadow on a chart with no real shift in who was willing to transact at the new price. Build a rule on candle shape alone and you're building a rule that mostly detects candle shapes, not auctions failing.

How a signal earns its place

I decomposed "failed auction" into three conditions, checked in order, not one threshold:

Sweep — price trades through a reference level you've enabled (a confirmed swing pivot, the developing session high/low, and/or the prior day's high/low; run any combination at once).
Rejection in the footprint — the part that actually does the work. "Rejection" isn't one observable event; it's a state that several distinct microstructure mechanisms can each produce on their own, so instead of one blanket volume-and-range test, the script checks four independent ways an auction can lose its nerve: an aggressive imbalance stepping in against the move, exhaustion of the side that pushed the extreme (its own volume thinning out relative to the session's point of control), absorption (heavy volume at the extreme that produced no further ground given), or an outright reversal in net delta at the extreme itself. A signal needs the sweep and reclaim plus any one of these four — alternative evidence for the same event, not four boxes that all have to tick, because real failures don't always announce themselves the same way twice.
Reclaim — the bar closes back inside the level. The extension didn't hold.

Conviction, not a coin flip

Two failed auctions can carry very different weight, and collapsing that to a plain yes/no throws away exactly the information that separates them. Every confirmed signal earns a 0–6 score from reclaim distance in ATR, rejection-wick size, whether the footprint imbalance fired, whether any rejection mechanism was present at all, volume significance against its recent average, and confluence with the prior day's level. That resolution is what lets a score bucket be tested against forward outcomes later, instead of trusted on faith because it's printed on the chart. Score ≥ 5 gets marked separately as high conviction.

You choose which levels are worth defending

Not every reference level deserves the same attention on every instrument. Rather than hardcoding one definition, the level itself is a checkbox input — swing pivot, session extreme, prior-day high/low, any combination. That turns "which level construction actually produces the more reliable signal" into something you get to test on your own market, not an assumption baked into the code before you ever loaded it. A freshness filter keeps the script from re-flagging a level the market is only drifting through, and each level fires once until it's freshly swept again, so the chart doesn't fill with the same tired flag on a level nobody's testing anymore.

Where the real work is: levels that hold, and levels that give way

The script reads buy and sell volume off each traded price row directly from TradingView's footprint engine — not the bar's high or low, the actual rows underneath it. That's the difference between a level that's genuinely protected (swept, then rejected by real opposing size) and one that was merely visited on the way through. The script signals only the protected case, on purpose: when a level is swept and the footprint shows the opposite picture — the aggressing side still winning at the extreme, no imbalance, no exhaustion, no absorption — that's the auction finding real business at the new price, and it isn't a separate detector, it's the same evidence read the other way. I use that same row-level data, sitting in the on-chart table and the data window, to make that read myself.

From evidence to a trade

The shaded zone on each signal and the dotted reclaim line aren't decoration — their edges are built from the same executed volume the detection ran on, so they sit exactly where the auction actually failed, not where a candle makes it look like it failed. That gives two of the three numbers a trade needs, for free:

Invalidation sits beyond the genuine sweep extreme — the specific high or low the market actually rejected — instead of a generic ATR multiple bolted on afterward with no connection to the real event.
Entry is typically the reclaim itself, or a retest of the reclaimed level, because that's the exact price where the failure got confirmed.

The same table reporting the signal also reports the trade data behind it — bar delta, delta at the extreme, top or bottom-zone volume against the point-of-control row, whether the imbalance flag fired — so a given entry's conviction is graded from real orderflow, not taken on the label's word alone. "Precise" here means anchored to where actual buying and selling happened. It isn't a claim about win rate, and the next section is exactly what would earn the right to make one.

No time travel

Swing levels use a confirmed pivot lag, never the current unconfirmed bar. Session levels reference only bars before the current one. Prior-day levels come through with lookahead explicitly switched off. Every plotted value and every signal only ever sees what was actually knowable at the time it fired.

What's proven, and what isn't yet

This is a rule-based detector, not a validated statistical signal — an honest hypothesis about how orderflow behaves at rejected levels, not a claim that it has forward-return content. That claim gets earned with a conditional event study: forward returns at several horizons for every fired signal, split by score bucket, testing whether score actually rank-orders the outcome instead of just looking like it should — plus a placebo run of the same logic against price levels that were never real reference points, to make sure the signature isn't just "high volume happened here" dressed up in more specific language. Until that's done, treat this as what it is: a discretionary confirmation tool that flags a failed auction with a graded conviction score, not a system that manages your entries, stops, targets, or size. A level's past reaction is not a promise about its next one.

Limitations

[*]Requires a TradingView Premium or Ultimate plan — the footprint API is gated to those plans.
[*]Built for standard candlestick charts. Sweep and reclaim logic will misread the market on Heikin Ashi, Renko, or other synthetic chart types.
[*]Default thresholds for imbalance, exhaustion, absorption, and volume significance are tuned for a liquid futures instrument; thinner symbols or very low timeframes may need the detection inputs adjusted.

---

## Source Code

````pine
//@version=6
// =====================================================================
//  FAILED AUCTION DETECTOR v2  —  Orderflow (request.footprint, Pine v6)
// ---------------------------------------------------------------------
//  WHAT A FAILED AUCTION ACTUALLY IS (the model this script encodes):
//  The market is a two-sided auction. When price probes BEYOND an
//  established reference level, the auction tries to find new business
//  at the new price. It either:
//     (a) finds acceptance  -> continuation / range extension  (SUCCESS)
//     (b) finds no responsive size -> snaps back inside        (FAILURE)
//  A *failed auction* therefore needs THREE things, in order:
//     1. A reference level that gets swept (the auction extends).
//     2. The footprint at the extreme showing the probe REJECTED:
//        - aggressive sellers stepping in (sell imbalance), OR
//        - buying drying up at the high (exhaustion), OR
//        - heavy buying that gets absorbed (trapped longs).
//     3. Price RECLAIMING the level (close back inside) = the auction
//        failed to hold its excess.
//  Reference levels are CHECKBOXES: tick any combination of swing,
//  session, and prior-day high/low. A signal fires on whichever enabled
//  level the bar sweeps and reclaims. Each signal is graded 0-6.
// =====================================================================

indicator(
     title            = "Failed Auction Detector v2",
     shorttitle       = "FA v2",
     overlay          = true,
     max_labels_count = 500,
     max_boxes_count  = 300,
     max_lines_count  = 300)

// ── INPUT GROUPS ─────────────────────────────────────────────────
var string G1 = "Footprint Engine"
var string G2 = "Reference Levels (the auction that must fail)"
var string G3 = "Failed-Auction Logic"
var string G4 = "Scoring & Gating"
var string G5 = "Display"
var string G6 = "Alerts"

// Footprint engine (ONE request.footprint call is allowed per script)
int ticksPerRow = input.int(5,   "Ticks per row", group=G1, minval=1,
     tooltip="Match your footprint chart. GC tick = 0.1, so 5 = 0.5-wide rows.")
int vaPct       = input.int(70,  "Value area %",  group=G1, minval=1, maxval=99)
int imbPct      = input.int(300, "Imbalance %",   group=G1, minval=100,
     tooltip="Drives has_buy_imbalance()/has_sell_imbalance(). 300 = a row's volume is 3x the diagonally-adjacent opposite side.")

// Reference levels — TICK the levels a failed auction may sweep & reclaim.
// Multiple can be on at once; a signal fires on whichever enabled level
// the bar sweeps and reclaims.
bool   useSwing     = input.bool(true,  "Trigger: Swing high/low",     group=G2,
     tooltip="Most recent confirmed pivot (uses Swing length below).")
bool   useSession   = input.bool(false, "Trigger: Session high/low",   group=G2,
     tooltip="The developing session high/low (uses the session window below). Only fires inside the session.")
bool   usePDay      = input.bool(false, "Trigger: Prior-day high/low",  group=G2,
     tooltip="Yesterday's completed high/low.")
int    swingLen     = input.int(10, "Swing length / fresh-extreme window", group=G2, minval=2,
     tooltip="Pivot lookback for Swing mode, and the window for the 'fresh local extreme' guard below.")
string sessionInput = input.session("1700-2000", "Session window (HHMM-HHMM)", group=G2,
     tooltip="For Session mode. Default = 5-8 PM UAE London/NY overlap, read in the timezone below.")
string sessionTz    = input.string("GMT+4", "Session timezone", group=G2,
     options=["GMT+4", "GMT+0", "America/New_York", "America/Chicago", "Europe/London"])
bool   reqFresh     = input.bool(true,  "Require fresh local extreme", group=G2,
     tooltip="Swing/Prior-day signals require the bar to make a new high/low over the window above (filters drift-throughs). Session signals are exempt (a new session extreme is fresh by definition). Turn off if session-focused and you want every session-extreme rejection.")
bool   oncePerLevel = input.bool(true, "One signal per level", group=G2,
     tooltip="Prevents re-firing on the same untouched reference across consecutive bars.")
bool   useHTFContext= input.bool(true, "Add conviction at prior-day high/low", group=G2,
     tooltip="Scoring bonus when the swept level coincides with the prior-day high/low.")
int    htfTolTicks  = input.int(20, "Prior-day tolerance (ticks)", group=G2, minval=0)

// Detection thresholds
int   topRows      = input.int(2, "Rows to inspect at the extreme", group=G3, minval=1,
     tooltip="How many footprint rows from the high (or low) define the rejection zone. Keep >=2 so a sell/buy imbalance can register (the top row has no row above it to compare against).")
int   minPokeTicks = input.int(1, "Min sweep depth (ticks past level)", group=G3, minval=0,
     tooltip="The high must exceed the reference by at least this, to ignore float-equality noise.")
bool  reqReclaim   = input.bool(true, "Require reclaim (close back inside level)", group=G3,
     tooltip="The definition of a failed auction. Off only for experimentation.")
bool  reqOFReject  = input.bool(true, "Require orderflow rejection at extreme", group=G3,
     tooltip="At least one of: sell/buy imbalance, side lost the extreme on delta, buying/selling exhaustion, or absorption.")
float exhaustFac   = input.float(0.30, "Exhaustion factor", group=G3, minval=0.05, maxval=1.0, step=0.05,
     tooltip="Short: top-zone BUY volume <= this x POC-row buy volume => buyers dried up at the high. Lower = stricter.")
float absorbFac    = input.float(1.30, "Absorption factor", group=G3, minval=1.0, step=0.1,
     tooltip="Top-zone total volume >= this x avg row volume WITH aggressive opposing delta => the probe was absorbed (trapped traders).")
float minWickFrac  = input.float(0.50, "Min rejection-wick fraction", group=G3, minval=0.0, maxval=1.0, step=0.05,
     tooltip="(high-close)/(high-low) for shorts. 0.50 = the rejection wick is at least half the bar.")
float volFactor    = input.float(1.0, "Min bar volume (x SMA)", group=G3, minval=0.0, step=0.1)
int   volLen       = input.int(20, "Volume SMA length", group=G3, minval=1)

// Scoring & gating
int minScore  = input.int(3, "Min score to signal (0-6)", group=G4, minval=0, maxval=6)
int starScore = input.int(5, "High-conviction score (★)", group=G4, minval=1, maxval=6)

// Display
color colShort  = input.color(color.new(#FF3B5C, 0), "Short colour", group=G5)
color colLong   = input.color(color.new(#00E5A0, 0), "Long colour",  group=G5)
bool  showLabels= input.bool(true,  "Show labels",        group=G5)
bool  showZone  = input.bool(true,  "Shade rejected excess", group=G5)
int   zoneBars  = input.int(20,     "Zone extend (bars)", group=G5, minval=1)
bool  showLine  = input.bool(true,  "Draw level line",    group=G5)
int   lineBars  = input.int(50,     "Line extend (bars)", group=G5, minval=1)
bool  colorBars = input.bool(true,  "Colour signal bars", group=G5)
bool  showTable = input.bool(true,  "Show data table",    group=G5)

// Alerts
bool enableJson = input.bool(false, "Emit JSON alert() for webhook", group=G6)

// ── BASELINES ────────────────────────────────────────────────────
float atr    = ta.atr(14)
float volSma = ta.sma(volume, volLen)

// ── ONE FOOTPRINT REQUEST ────────────────────────────────────────
footprint fp   = request.footprint(ticksPerRow, vaPct, imbPct)
bool      fpOK = not na(fp)

float barBuy   = fpOK ? fp.buy_volume()   : na
float barSell  = fpOK ? fp.sell_volume()  : na
float barDelta = fpOK ? fp.delta()        : na
float barTot   = fpOK ? fp.total_volume() : na

// ── EXTREME-ZONE ROW STATISTICS ──────────────────────────────────
// rows() is sorted ascending by price: index 0 = lowest, last = highest.
float topBuy  = 0.0
float topSell = 0.0
float topTot  = 0.0
float botBuy  = 0.0
float botSell = 0.0
float botTot  = 0.0
bool  topSellImb = false
bool  botBuyImb  = false
float pocBuy    = na
float pocSell   = na
float avgRowTot = na

if fpOK
    array<volume_row> rows = fp.rows()
    int n = rows.size()
    if n > 0
        avgRowTot := barTot / n
        volume_row pocR = fp.poc()
        pocBuy  := pocR.buy_volume()
        pocSell := pocR.sell_volume()
        int k = math.min(topRows, n)
        // Top k rows (the high) — last k elements
        for i = 0 to k - 1
            volume_row r = rows.get(n - 1 - i)
            topBuy     += r.buy_volume()
            topSell    += r.sell_volume()
            topTot     += r.total_volume()
            topSellImb := topSellImb or r.has_sell_imbalance()
        // Bottom k rows (the low) — first k elements
        for i = 0 to k - 1
            volume_row r = rows.get(i)
            botBuy    += r.buy_volume()
            botSell   += r.sell_volume()
            botTot    += r.total_volume()
            botBuyImb := botBuyImb or r.has_buy_imbalance()

float topDelta = topBuy - topSell
float botDelta = botBuy - botSell

// ── REFERENCE LEVELS ─────────────────────────────────────────────
// 1) Swing high/low — most recent CONFIRMED pivot (lags swingLen bars,
//    which is what makes it a genuine prior reference, not the last candle).
float ph = ta.pivothigh(high, swingLen, swingLen)
float pl = ta.pivotlow(low,  swingLen, swingLen)
var float swHigh = na
var float swLow  = na
swHigh := na(ph) ? swHigh : ph
swLow  := na(pl) ? swLow  : pl

// 2) Session high/low — developing session extreme, EXCLUDING the current
//    bar so the current bar can sweep it.
bool inSess  = not na(time(timeframe.period, sessionInput, sessionTz))
bool newSess = inSess and not inSess[1]
var float sessHi = na
var float sessLo = na
float refSessHigh = newSess ? na : sessHi          // reference = prior bars' session high
float refSessLow  = newSess ? na : sessLo
if newSess
    sessHi := high
    sessLo := low
else if inSess
    sessHi := na(sessHi) ? high : math.max(sessHi, high)
    sessLo := na(sessLo) ? low  : math.min(sessLo, low)

// 3) Prior-day high/low — previous completed day (non-repainting).
[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_off)

float pokeTick = minPokeTicks * syminfo.mintick
float htfTol   = htfTolTicks  * syminfo.mintick
float rng      = math.max(high - low, syminfo.mintick)

// Per-reference sweep (+ optional reclaim) tests
faShortHit(bool en, float ref) =>
    en and not na(ref) and high > ref + pokeTick and (not reqReclaim or close < ref)
faLongHit(bool en, float ref) =>
    en and not na(ref) and low < ref - pokeTick and (not reqReclaim or close > ref)

bool swHitS = faShortHit(useSwing, swHigh)
bool seHitS = faShortHit(useSession and inSess, refSessHigh)
bool pdHitS = faShortHit(usePDay, pdh)
bool swHitL = faLongHit(useSwing, swLow)
bool seHitL = faLongHit(useSession and inSess, refSessLow)
bool pdHitL = faLongHit(usePDay, pdl)

// Representative reference = highest swept level (short) / lowest (long)
float refHigh = na
if swHitS
    refHigh := na(refHigh) ? swHigh : math.max(refHigh, swHigh)
if seHitS
    refHigh := na(refHigh) ? refSessHigh : math.max(refHigh, refSessHigh)
if pdHitS
    refHigh := na(refHigh) ? pdh : math.max(refHigh, pdh)
float refLow = na
if swHitL
    refLow := na(refLow) ? swLow : math.min(refLow, swLow)
if seHitL
    refLow := na(refLow) ? refSessLow : math.min(refLow, refSessLow)
if pdHitL
    refLow := na(refLow) ? pdl : math.min(refLow, pdl)

// 'Fresh local extreme' guard. Session hits are inherently fresh (exceeding
// the developing session high is already a new extreme), so they are exempt.
bool freshGuardHigh = high > ta.highest(high, swingLen)[1]
bool freshGuardLow  = low  < ta.lowest(low,  swingLen)[1]
bool qualShort = seHitS or ((swHitS or pdHitS) and (not reqFresh or freshGuardHigh))
bool qualLong  = seHitL or ((swHitL or pdHitL) and (not reqFresh or freshGuardLow))

// ── SHORT: failed auction at the HIGH ────────────────────────────
bool reclaimHigh = not na(refHigh) and close < refHigh
bool wickShort   = (high - close) / rng >= minWickFrac
bool volOK       = na(volSma) or volume >= volFactor * volSma

// Orderflow rejection signatures at the high (three distinct mechanisms)
bool exhaustShort = not na(pocBuy) and pocBuy > 0 and topBuy <= exhaustFac * pocBuy          // buyers thinned out
bool absorbShort  = not na(avgRowTot) and avgRowTot > 0 and topTot >= absorbFac * avgRowTot and topDelta > 0 // aggressive buyers absorbed
bool sellWonTop   = topDelta <= 0                                                            // sellers won the extreme
bool ofRejectS    = topSellImb or sellWonTop or exhaustShort or absorbShort

bool coreShort = fpOK and qualShort and (not reqOFReject or ofRejectS)

int scoreShort = 0
if coreShort
    scoreShort += (not na(atr) and (refHigh - close) >= 0.10 * atr) ? 1 : 0                  // decisive reclaim
    scoreShort += wickShort ? 1 : 0                                                          // strong rejection wick
    scoreShort += topSellImb ? 1 : 0                                                         // aggressive sellers at top
    scoreShort += (sellWonTop or exhaustShort or absorbShort) ? 1 : 0                        // orderflow mechanism present
    scoreShort += volOK ? 1 : 0                                                              // volume significance
    scoreShort += (useHTFContext and not na(pdh) and high >= pdh - htfTol) ? 1 : 0           // confluence with prior-day high

// ── LONG: failed auction at the LOW ──────────────────────────────
bool reclaimLow  = not na(refLow) and close > refLow
bool wickLong    = (close - low) / rng >= minWickFrac

bool exhaustLong = not na(pocSell) and pocSell > 0 and botSell <= exhaustFac * pocSell       // sellers thinned out
bool absorbLong  = not na(avgRowTot) and avgRowTot > 0 and botTot >= absorbFac * avgRowTot and botDelta < 0 // aggressive sellers absorbed
bool buyWonBot   = botDelta >= 0                                                             // buyers won the extreme
bool ofRejectL   = botBuyImb or buyWonBot or exhaustLong or absorbLong

bool coreLong = fpOK and qualLong and (not reqOFReject or ofRejectL)

int scoreLong = 0
if coreLong
    scoreLong += (not na(atr) and (close - refLow) >= 0.10 * atr) ? 1 : 0
    scoreLong += wickLong ? 1 : 0
    scoreLong += botBuyImb ? 1 : 0
    scoreLong += (buyWonBot or exhaustLong or absorbLong) ? 1 : 0
    scoreLong += volOK ? 1 : 0
    scoreLong += (useHTFContext and not na(pdl) and low <= pdl + htfTol) ? 1 : 0

// ── FIRE (confirmed bars only; de-dupe per level) ────────────────
var float lastFiredHigh = na
var float lastFiredLow  = na

bool sigShort = coreShort and scoreShort >= minScore and barstate.isconfirmed
     and (not oncePerLevel or na(lastFiredHigh) or refHigh != lastFiredHigh)
bool sigLong  = coreLong  and scoreLong  >= minScore and barstate.isconfirmed
     and (not oncePerLevel or na(lastFiredLow)  or refLow  != lastFiredLow)

if sigShort
    lastFiredHigh := refHigh
if sigLong
    lastFiredLow := refLow

// ── VISUALS ──────────────────────────────────────────────────────
if showLabels and sigShort
    string txt = (scoreShort >= starScore ? "FA ★ " : "FA ") + str.tostring(scoreShort) + "/6"
         + "\n" + str.tostring(math.round(topSell)) + "S / " + str.tostring(math.round(topBuy)) + "B"
    label.new(bar_index, high, txt, style=label.style_label_down,
         color=colShort, textcolor=color.white,
         size = scoreShort >= starScore ? size.normal : size.small)

if showLabels and sigLong
    string txt = (scoreLong >= starScore ? "FA ★ " : "FA ") + str.tostring(scoreLong) + "/6"
         + "\n" + str.tostring(math.round(botBuy)) + "B / " + str.tostring(math.round(botSell)) + "S"
    label.new(bar_index, low, txt, style=label.style_label_up,
         color=colLong, textcolor=color.white,
         size = scoreLong >= starScore ? size.normal : size.small)

// Shade the rejected excess (from the swept level up to the probe high)
if showZone and sigShort
    box.new(bar_index, high, bar_index + zoneBars, refHigh,
         border_color=colShort, bgcolor=color.new(colShort, 85),
         border_width=1, border_style=line.style_dashed)
if showZone and sigLong
    box.new(bar_index, refLow, bar_index + zoneBars, low,
         border_color=colLong, bgcolor=color.new(colLong, 85),
         border_width=1, border_style=line.style_dashed)

// Reclaimed level line
if showLine and sigShort
    line.new(bar_index, refHigh, bar_index + lineBars, refHigh,
         color=color.new(colShort, 40), width=1, style=line.style_dotted)
if showLine and sigLong
    line.new(bar_index, refLow, bar_index + lineBars, refLow,
         color=color.new(colLong, 40), width=1, style=line.style_dotted)

barcolor(colorBars ? (sigShort ? color.new(colShort, 55) : sigLong ? color.new(colLong, 55) : na) : na)

// ── DATA TABLE ───────────────────────────────────────────────────
string trigStr = (useSwing ? "SW " : "") + (useSession ? "SE " : "") + (usePDay ? "PD" : "")

var table tbl = table.new(position.bottom_right, 2, 12,
     bgcolor=color.new(color.black, 65), border_color=color.new(color.gray, 60), border_width=1)

if showTable and barstate.islast and fpOK
    table.cell(tbl, 0, 0, "Footprint", text_color=color.gray, text_size=size.small, bgcolor=color.new(color.black,40))
    table.cell(tbl, 1, 0, "Value",     text_color=color.gray, text_size=size.small, bgcolor=color.new(color.black,40))
    table.cell(tbl, 0, 1, "Triggers on", text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 1, trigStr == "" ? "none" : trigStr, text_color=color.aqua, text_size=size.small)
    table.cell(tbl, 0, 2, "Bar delta", text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 2, str.tostring(math.round(barDelta)), text_color=barDelta>=0?color.lime:color.red, text_size=size.small)
    table.cell(tbl, 0, 3, "Bar volume", text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 3, str.tostring(math.round(barTot)), text_color=color.white, text_size=size.small)
    table.cell(tbl, 0, 4, "Top Δ (high)", text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 4, str.tostring(math.round(topDelta)), text_color=topDelta<=0?color.red:color.lime, text_size=size.small)
    table.cell(tbl, 0, 5, "Bot Δ (low)", text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 5, str.tostring(math.round(botDelta)), text_color=botDelta>=0?color.lime:color.red, text_size=size.small)
    table.cell(tbl, 0, 6, "Top buy / POC buy", text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 6, na(pocBuy) or pocBuy==0 ? "—" : str.tostring(topBuy/pocBuy, "#.##"), text_color=color.white, text_size=size.small)
    table.cell(tbl, 0, 7, "Sell imb @top", text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 7, topSellImb ? "yes" : "no", text_color=topSellImb?color.red:color.gray, text_size=size.small)
    table.cell(tbl, 0, 8, "Buy imb @low", text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 8, botBuyImb ? "yes" : "no", text_color=botBuyImb?color.lime:color.gray, text_size=size.small)
    table.cell(tbl, 0, 9, "Ref high", text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 9, na(refHigh) ? "—" : str.tostring(refHigh, format.mintick), text_color=color.red, text_size=size.small)
    table.cell(tbl, 0, 10, "Ref low", text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 10, na(refLow) ? "—" : str.tostring(refLow, format.mintick), text_color=color.lime, text_size=size.small)
    table.cell(tbl, 0, 11, "Last score S/L", text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 11, str.tostring(scoreShort) + " / " + str.tostring(scoreLong), text_color=color.white, text_size=size.small)

// ── ALERTS ───────────────────────────────────────────────────────
alertcondition(sigShort, "Failed Auction — Short", "FAILED AUCTION SHORT {{ticker}} {{interval}} @ {{close}}")
alertcondition(sigLong,  "Failed Auction — Long",  "FAILED AUCTION LONG {{ticker}} {{interval}} @ {{close}}")
alertcondition(sigShort and scoreShort >= starScore, "Failed Auction ★ Short", "HIGH-CONVICTION FA SHORT {{ticker}} {{interval}} @ {{close}}")
alertcondition(sigLong  and scoreLong  >= starScore, "Failed Auction ★ Long",  "HIGH-CONVICTION FA LONG {{ticker}} {{interval}} @ {{close}}")

// Rich JSON for your webhook -> bridge -> broker stack (string concat avoids brace-escaping)
if enableJson and sigShort
    string m = '{"strategy":"failed_auction","side":"short","symbol":"' + syminfo.ticker
         + '","tf":"' + timeframe.period + '","price":' + str.tostring(close)
         + ',"ref":' + str.tostring(refHigh) + ',"score":' + str.tostring(scoreShort) + '}'
    alert(m, alert.freq_once_per_bar_close)
if enableJson and sigLong
    string m = '{"strategy":"failed_auction","side":"long","symbol":"' + syminfo.ticker
         + '","tf":"' + timeframe.period + '","price":' + str.tostring(close)
         + ',"ref":' + str.tostring(refLow) + ',"score":' + str.tostring(scoreLong) + '}'
    alert(m, alert.freq_once_per_bar_close)

// Data-window diagnostics
plot(barDelta, "Bar delta", display=display.data_window)
plot(topDelta, "Top delta", display=display.data_window)
plot(botDelta, "Bot delta", display=display.data_window)
````
