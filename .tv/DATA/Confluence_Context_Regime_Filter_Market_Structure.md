<!-- tradingview-pine-id: PUB;2e22bb433ba149dc87664699d8544848 -->
<!-- tradingviewscripts-format: 1 -->
# Confluence Context — Regime Filter + Market Structure

Source: https://www.tradingview.com/script/ythg5kq5-Confluence-Context-Regime-Filter-Market-Structure/

## Description

🎯 CONFLUENCE CONTEXT — REGIME FILTER + MARKET STRUCTURE

Your signal tool tells you WHEN. This tells you WHETHER.

Confluence Context — Regime Filter + Market Structure is the companion layer that sits on top of whatever you already trade and answers the one question that wrecks most setups: does the context actually agree? It draws no zones and fires no entries — it reads the environment, scores it, and hands you a single glance-readable verdict. 📊

🔥 WHY IT EXISTS

Most signal tools fire identically in every environment — trending, ranging, dead, or violent. The killer is the clean-looking signal taken in the wrong context: a breakout in a dead session, a continuation against structure, a trend entry while volatility is flatlined. Confluence Context — Regime Filter + Market Structure gates your entry with the four things signal tools love to ignore.

🧩 THE FOUR LAYERS

📐 Market Structure — Swing pivots labeled BOS (Break of Structure, with the trend) and CHoCH (Change of Character, against it), with a running bias: Bullish, Bearish, or Neutral. Confirmed-bar only, capped label history so the chart doesn't clutter.

🌊 Volatility Regime — ATR vs its own moving average, sorting the tape into Low, Normal, or Extreme. This is the regime filter — it tells you whether you're in the environment your strategy was actually built for. Flip on H1 mode to inherit a higher-timeframe regime read from the prior closed 60-min bar, no repaint.

🕐 Session Filter — London / New York / Asia with pair presets (JPY, USD majors, AUD/NZD) or fully custom windows + timezone. Reads the live wall clock, so it flips to "Closed" the moment the market closes instead of freezing on the last in-session bar.

📈 Trend — Price vs a configurable EMA. Simple, and it earns its weight.

These four checks are fused into two weighted tallies instead of shipped as four separate indicators because context only breaks down as a whole — a bullish structure read means nothing if the session is dead and volatility is flat. Splitting them apart would just recreate the blind spot this indicator exists to close.

⚡ HOW THEY STACK (the scoring engine)

Every layer casts a weighted vote into TWO independent tallies — a bull score and a bear score, scored separately so you can actually see when context is fighting itself instead of just being quiet. A fifth slot — External Zone Hit — is a manual toggle (bull and bear separately) you flip the moment YOUR zone or level tool confirms a touch. That's what makes this a companion, not a standalone: it lets your existing setup feed the one input it can't infer.

🎯 THE HIGHLIGHTER

Clear your threshold on the dominant side and the Highlighter collapses both scores into one verdict — Stacked Long, Leaning Long, Balanced, Leaning Short, or Stacked Short. Paint it on the candles, the background, or both. Two candle modes: Verdict Tint paints every bar by net confluence, or BOS/CHoCH Candle paints only the single bar where a structure break confirms, in that event's own label color — a quieter option if you just want structure flips to pop. It confirms context, it doesn't call trades, so it speaks BULLISH / BEARISH, never BUY / SELL.

📋 THE LIVE TABLE

A full breakdown, not just a verdict — all six weighted conditions get their own row with a pass/fail check for both bull and bear, plus ATR, active session, and bias/regime context underneath. An optional oversized headline row sits on top: CONTEXT: BULLISH · Stacked Long · 9 / 2. Six position options, so it never collides with your other panels.

🔔 ALERTS

Structure breaks, all four regime transitions, session opens and full-close, and confluence threshold crosses — all confirmed-bar only. The threshold alerts carry a full payload (symbol, timeframe, direction, score, bias, ATR, session, regime, timestamp) so your webhook or notification has enough context to act on without opening the chart. An optional toggle also alerts when a score drops back below threshold.

🛠️ HOW TO USE IT

Slap it on top of whatever you trade. Tune the EMA, regime multipliers, and session windows to your instrument. Read the verdict off the table or the candle tint — filter your primary signal so you only pull the trigger when context agrees, or let the confluence alert ping you when the dominant side clears threshold.

⏱️ BEST TIMEFRAMES

Built to shine on M15 through H4 — enough structure to mean something, fast enough to act on.

♾️ The whole idea: it stays useful after it's been on your chart for a while. 

Repaint policy: structure, regime, and score history evaluate on confirmed bars; the HTF regime read uses a closed-bar offset and doesn't repaint; the session display is live by design and doesn't touch history. Settings are starting points, not advice — tune them to your market and validate before risking capital.

---

## Source Code

````pine
//@version=6
// =============================================================================
// CONFLUENCE CONTEXT
// Companion indicator — context & confirmation only. Does NOT draw zones.
// Sections:
//   1. Market Structure (BOS / CHoCH / Bias)
//   2. Volatility Regime (ATR vs ATR-MA, optional H1 mode)
//   3. Session Filter (London / NY / Asia + presets)
//   4. Confluence Scoring Engine (independent bull / bear scores + table)
// Repaint policy: structure/regime/score history on confirmed bars only; HTF
//   values via lookahead_on with [1] shift. Session display reads the wall clock
//   on the LIVE bar (HUD-style) so it goes "Closed" after market close instead of
//   freezing on the last in-session bar — history off the live bar is unchanged.
// =============================================================================

indicator("Confluence Context — Regime Filter + Market Structure", "Confluence Context", overlay=true,
     max_labels_count=500)

// =============================================================================
// SECTION 1 — MARKET STRUCTURE • INPUTS
// =============================================================================
g_ms = "1) Market Structure"
pivotLen        = input.int(5, "Pivot Length", minval=2, group=g_ms,
     tooltip="Number of bars on each side required to confirm a swing pivot")
maxLabels       = input.int(20, "Max Structure Labels on Chart", minval=1, maxval=200, group=g_ms,
     tooltip="Older BOS/CHoCH labels are auto-deleted")
showStructure   = input.bool(true, "Show BOS / CHoCH Labels", group=g_ms)
bullBosColor    = input.color(color.new(#26a69a, 0), "Bullish BOS Color",   group=g_ms)
bearBosColor    = input.color(color.new(#ef5350, 0), "Bearish BOS Color",   group=g_ms)
bullChochColor  = input.color(color.new(#00e676, 0), "Bullish CHoCH Color", group=g_ms)
bearChochColor  = input.color(color.new(#d50000, 0), "Bearish CHoCH Color", group=g_ms)

// =============================================================================
// SECTION 2 — VOLATILITY REGIME • INPUTS
// =============================================================================
g_vol = "2) Volatility Regime"
atrLen       = input.int(14, "ATR Length", minval=1, group=g_vol)
atrMaLen     = input.int(50, "ATR MA Length", minval=1, group=g_vol,
     tooltip="Moving average of ATR used as the regime baseline")
useH1Vol     = input.bool(false, "Use H1 Volatility (instead of chart timeframe)", group=g_vol,
     tooltip="Pulls ATR from 60-min chart with no repainting (uses prior closed H1 bar)")
lowMult      = input.float(0.7, "Low Regime Multiplier",     minval=0.05, step=0.05, group=g_vol,
     tooltip="ATR < ATR_MA × this value → Low regime")
extremeMult  = input.float(1.5, "Extreme Regime Multiplier", minval=0.5,  step=0.05, group=g_vol,
     tooltip="ATR > ATR_MA × this value → Extreme regime")
showRegimeBg    = input.bool(true, "Color Background by Regime", group=g_vol)
showRegimeLabel = input.bool(true, "Show Regime Label",          group=g_vol)

// =============================================================================
// SECTION 3 — SESSION FILTER • INPUTS
// =============================================================================
g_sess = "3) Session Filter"
preset       = input.string("Custom", "Pair Preset",
     options=["Custom", "JPY Pairs", "USD Majors", "AUD/NZD Pairs"], group=g_sess,
     tooltip="Selecting a preset overrides the custom session strings below")
useLondon    = input.bool(true, "Enable London Session",   group=g_sess)
useNY        = input.bool(true, "Enable New York Session", group=g_sess)
useAsia      = input.bool(true, "Enable Asia Session",     group=g_sess)
londonInput  = input.session("0800-1700", "London Session (custom)",   group=g_sess)
nyInput      = input.session("1300-2200", "New York Session (custom)", group=g_sess)
asiaInput    = input.session("0000-0900", "Asia Session (custom)",     group=g_sess)
sessionTz    = input.string("UTC", "Session Timezone", group=g_sess,
     tooltip="IANA / shorthand timezone, e.g. UTC, America/New_York, Europe/London")
showSessionBg    = input.bool(true, "Shade Background When Session Active", group=g_sess)
showSessionLabel = input.bool(true, "Show Active Session Label",            group=g_sess)

// Resolve preset → session string. "Custom" falls through to user input.
londonSess = switch preset
    "JPY Pairs"     => "0700-1600"
    "USD Majors"    => "0800-1700"
    "AUD/NZD Pairs" => "0700-1600"
    => londonInput

nySess = switch preset
    "JPY Pairs"     => "1200-2100"
    "USD Majors"    => "1300-2200"
    "AUD/NZD Pairs" => "1300-2200"
    => nyInput

asiaSess = switch preset
    "JPY Pairs"     => "2300-0800"
    "USD Majors"    => "0000-0900"
    "AUD/NZD Pairs" => "2100-0600"
    => asiaInput

// =============================================================================
// SECTION 4 — CONFLUENCE SCORING • INPUTS
// =============================================================================
g_score = "4) Confluence Scoring"
emaLen      = input.int(50, "Trend EMA Length", minval=1, group=g_score)
wTrend      = input.int(2, "Weight: Price vs Trend EMA",          minval=0, group=g_score)
wBias       = input.int(2, "Weight: Structure Bias Aligned",      minval=0, group=g_score)
wBosChoch   = input.int(3, "Weight: BOS / CHoCH (current or prior bar)", minval=0, group=g_score)
wRegime     = input.int(1, "Weight: Volatility Regime is Normal", minval=0, group=g_score)
wSession    = input.int(1, "Weight: Active Trading Session",      minval=0, group=g_score)
wExtZone    = input.int(3, "Weight: External Zone Hit",           minval=0, group=g_score,
     tooltip="Applied separately to bull and bear sides via the toggles below")
extZoneBull = input.bool(false, "External Zone Hit — Bull (manual)", group=g_score,
     tooltip="Toggle ON when your primary zone indicator confirms a bullish zone interaction")
extZoneBear = input.bool(false, "External Zone Hit — Bear (manual)", group=g_score,
     tooltip="Toggle ON when your primary zone indicator confirms a bearish zone interaction")
threshold   = input.int(8, "Confluence Alert Threshold", minval=1, group=g_score)
fireExitAlert = input.bool(false, "Also Alert When Score Drops Back Below Threshold", group=g_score)
showTable   = input.bool(true, "Show Live Confluence Table", group=g_score)
tablePos    = input.string("top_right", "Table Position",
     options=["top_right","top_left","bottom_right","bottom_left","middle_right","middle_left"],
     group=g_score)
tblColW     = input.float(9.0, "Bull/Bear Column Width (% of pane)", minval=1, maxval=40, step=0.5, group=g_score,
     tooltip="Forces the Bull and Bear columns to the SAME width so they split evenly instead of auto-sizing to their text. Label column stays auto. Tune to match the old footprint (8–12 typical).")

// =============================================================================
// SECTION 5 — CONFLUENCE HIGHLIGHTER • INPUTS
// =============================================================================
// The "SuperTrend layer": collapses the two scores into one glance-readable verdict,
// rendered ON the price (candles / background) plus a headline row in the table.
g_hl = "5) Confluence Highlighter"
useHighlighter  = input.bool(true, "Enable Confluence Highlighter", group=g_hl,
     tooltip="One-glance verdict layer driven by net confluence (bull score vs bear score)")
hlMode          = input.string("Candles", "Highlighter Style",
     options=["Candles", "Background", "Both"], group=g_hl,
     tooltip="Candles tints the bars (most SuperTrend-like); Background tints behind price")
hlCandleMode    = input.string("BOS / CHoCH Candle", "Candle Paint Mode",
     options=["BOS / CHoCH Candle", "Verdict Tint"], group=g_hl,
     tooltip="BOS / CHoCH Candle: paints ONLY the single bar where a structure break confirms, in that event's label color. Verdict Tint: the original continuous net-confluence tint across every bar. (Background tint, if enabled, always follows the verdict.)")
hlSuppressOther = input.bool(true, "Dim Regime/Session Background while Highlighter On", group=g_hl,
     tooltip="Stops the regime and session backgrounds from muddying the confluence tint")
showHeadline    = input.bool(true, "Show Headline Verdict Row in Table", group=g_hl,
     tooltip="Adds an oversized merged verdict row at the top of the confluence table")

// =============================================================================
// SHARED HELPERS
// =============================================================================
f_check(bool b) => b ? "✓" : "✗"
f_cellBg(bool b) => b ? color.new(color.green, 60) : color.new(color.red, 70)

// --- Session freshness helpers (wall-clock, used on the live bar only) ---------
// Bar-relative time() detection reports the SESSION OF THE LAST BAR, so after a
// market close (Fri 22:00, holidays, feed gaps) it freezes on the final in-session
// bar and never re-checks. These helpers test `timenow` against the real window so
// the HUD/score go dark the moment the wall clock leaves the session.
//
// [open, close] ms of `sess` for the calendar day of `anchor`, in `tz`.
// DST-safe (timestamp() resolves the offset); overnight windows wrap to next day.
f_sessMs(string sess, string tz, int anchor) =>
    oH = int(str.tonumber(str.substring(sess, 0, 2)))
    oM = int(str.tonumber(str.substring(sess, 2, 4)))
    cH = int(str.tonumber(str.substring(sess, 5, 7)))
    cM = int(str.tonumber(str.substring(sess, 7, 9)))
    y  = year(anchor, tz)
    mo = month(anchor, tz)
    d  = dayofmonth(anchor, tz)
    o  = timestamp(tz, y, mo, d, oH, oM)
    c  = timestamp(tz, y, mo, d, cH, cM)
    [o, c <= o ? c + 86400000 : c]

// Is `timenow` inside `sess` right now? Checks today's window AND yesterday's, so
// an overnight window opened the previous calendar day is still caught.
f_liveIn(bool use, string sess, string tz) =>
    r = false
    if use
        [oT, cT] = f_sessMs(sess, tz, timenow)
        [oY, cY] = f_sessMs(sess, tz, timenow - 86400000)
        r := (timenow >= oT and timenow < cT) or (timenow >= oY and timenow < cY)
    r

// =============================================================================
// SECTION 1 — MARKET STRUCTURE • LOGIC
// =============================================================================
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low,  pivotLen, pivotLen)

var float lastPH    = na
var float lastPL    = na
var bool  phBroken  = false
var bool  plBroken  = false

if not na(ph)
    lastPH   := ph
    phBroken := false
if not na(pl)
    lastPL   := pl
    plBroken := false

// 1 = bullish, -1 = bearish, 0 = neutral
var int bias = 0

bullBOS   = false
bearBOS   = false
bullCHoCH = false
bearCHoCH = false

// A break ABOVE the most recent unbroken swing high
if barstate.isconfirmed and not na(lastPH) and not phBroken and close > lastPH
    if bias == 1
        bullBOS := true
    else
        bullCHoCH := true     // counter-bias break = Change of Character
    bias     := 1
    phBroken := true

// A break BELOW the most recent unbroken swing low
if barstate.isconfirmed and not na(lastPL) and not plBroken and close < lastPL
    if bias == -1
        bearBOS := true
    else
        bearCHoCH := true
    bias     := -1
    plBroken := true

// Manage chart labels — keep most recent N
var array<label> structLabels = array.new<label>()

f_pushLabel(float _y, string _txt, color _bg, string _style) =>
    if showStructure
        lbl = label.new(bar_index, _y, _txt, color=_bg, textcolor=color.white,
             style=_style, size=size.small)
        array.push(structLabels, lbl)
        while array.size(structLabels) > maxLabels
            label.delete(array.shift(structLabels))

if bullBOS
    f_pushLabel(high, "BOS ▲",   bullBosColor,   label.style_label_down)
if bearBOS
    f_pushLabel(low,  "BOS ▼",   bearBosColor,   label.style_label_up)
if bullCHoCH
    f_pushLabel(high, "CHoCH ▲", bullChochColor, label.style_label_down)
if bearCHoCH
    f_pushLabel(low,  "CHoCH ▼", bearChochColor, label.style_label_up)

biasStr = bias == 1 ? "Bullish" : bias == -1 ? "Bearish" : "Neutral"

// =============================================================================
// SECTION 2 — VOLATILITY REGIME • LOGIC
// =============================================================================
// Chart-TF ATR (calculated once, reused below)
chartAtr   = ta.atr(atrLen)
chartAtrMa = ta.sma(chartAtr, atrMaLen)

// H1 ATR — non-repainting: lookahead_on + [1] returns the last fully-closed H1 bar.
// Helper computes the ATR series once (instead of evaluating ta.atr twice inline).
f_h1AtrPair(int len, int maLen) =>
    a = ta.atr(len)
    [a[1], ta.sma(a, maLen)[1]]

[h1Atr, h1AtrMa] = request.security(syminfo.tickerid, "60",
     f_h1AtrPair(atrLen, atrMaLen),
     lookahead = barmerge.lookahead_on)

atrVal   = useH1Vol ? h1Atr   : chartAtr
atrMaVal = useH1Vol ? h1AtrMa : chartAtrMa

// Regime: 0=Low, 1=Normal, 2=Extreme
int regimeCode = 1
if not na(atrVal) and not na(atrMaVal) and atrMaVal > 0
    if atrVal < atrMaVal * lowMult
        regimeCode := 0
    else if atrVal > atrMaVal * extremeMult
        regimeCode := 2
    else
        regimeCode := 1

regimeStr   = regimeCode == 0 ? "Low" : regimeCode == 2 ? "Extreme" : "Normal"
regimeBgCol = regimeCode == 0 ? color.new(color.blue, 92) : regimeCode == 2 ? color.new(color.red, 92) : color.new(color.gray, 96)

// Highlighter can take over the background to avoid stacking three tints at once.
suppressBg = useHighlighter and hlSuppressOther
bgcolor(showRegimeBg and not suppressBg ? regimeBgCol : na, title="Regime BG")

// Regime label (single floating label, refreshed on last bar)
var label regimeLbl = na
if showRegimeLabel and barstate.islast
    if not na(regimeLbl)
        label.delete(regimeLbl)
    regimeLbl := label.new(bar_index + 2, high,
         "Regime: " + regimeStr, style=label.style_label_left,
         color=color.new(color.black, 30), textcolor=color.white, size=size.small)

// Regime transitions (gated to confirmed bars to prevent flickering alerts)
var int prevRegime = 1
regimeLowToNormal     = barstate.isconfirmed and prevRegime == 0 and regimeCode == 1
regimeNormalToExtreme = barstate.isconfirmed and prevRegime == 1 and regimeCode == 2
regimeExtremeToNormal = barstate.isconfirmed and prevRegime == 2 and regimeCode == 1
regimeNormalToLow     = barstate.isconfirmed and prevRegime == 1 and regimeCode == 0
if barstate.isconfirmed
    prevRegime := regimeCode

// =============================================================================
// SECTION 3 — SESSION FILTER • LOGIC
// =============================================================================
// Bar-relative detection: time(tf, session, tz) is non-na when THIS bar's open
// falls in the window. Weekend-guarded so weekend-printing instruments (crypto)
// don't register a weekday session. Drives the open/close edge alerts and is the
// non-live basis for the Eff booleans below — kept bar-aligned & non-repainting.
isWeekend = dayofweek == dayofweek.saturday or dayofweek == dayofweek.sunday
inLondon = useLondon and not na(time(timeframe.period, londonSess, sessionTz)) and not isWeekend
inNY     = useNY     and not na(time(timeframe.period, nySess,     sessionTz)) and not isWeekend
inAsia   = useAsia   and not na(time(timeframe.period, asiaSess,   sessionTz)) and not isWeekend

sessBarActive = inLondon or inNY or inAsia   // bar-relative — drives edge alerts

// Live-aware override (display + score): on the LAST bar, test the wall clock so a
// frozen post-close bar reads "Closed" instead of staying on its final session.
// Off the last bar, Eff == bar-relative, so history stays identical / non-repainting.
liveWknd = dayofweek(timenow, sessionTz) == dayofweek.saturday or dayofweek(timenow, sessionTz) == dayofweek.sunday
liveLon  = not liveWknd and f_liveIn(useLondon, londonSess, sessionTz)
liveNY   = not liveWknd and f_liveIn(useNY,     nySess,     sessionTz)
liveAsia = not liveWknd and f_liveIn(useAsia,   asiaSess,   sessionTz)

inLondonEff = barstate.islast ? liveLon  : inLondon
inNYEff     = barstate.islast ? liveNY   : inNY
inAsiaEff   = barstate.islast ? liveAsia : inAsia

sessionActive = inLondonEff or inNYEff or inAsiaEff   // drives display + score

// Compose human-readable label, including overlaps
string activeSessionStr = "Closed"
if inLondonEff and inNYEff
    activeSessionStr := "London + NY"
else if inLondonEff and inAsiaEff
    activeSessionStr := "London + Asia"
else if inNYEff and inAsiaEff
    activeSessionStr := "NY + Asia"
else if inLondonEff
    activeSessionStr := "London"
else if inNYEff
    activeSessionStr := "New York"
else if inAsiaEff
    activeSessionStr := "Asia"

// Open / close edges (bar-relative — fire on confirmed bars, no live-bar repaint)
londonOpen = inLondon and not inLondon[1]
nyOpen     = inNY     and not inNY[1]
asiaOpen   = inAsia   and not inAsia[1]
allClosed  = not sessBarActive and sessBarActive[1]

bgcolor(showSessionBg and sessionActive and not suppressBg ? color.new(color.yellow, 95) : na, title="Session BG")

var label sessionLbl = na
if showSessionLabel and barstate.islast
    if not na(sessionLbl)
        label.delete(sessionLbl)
    sessionLbl := label.new(bar_index + 2, low,
         "Session: " + activeSessionStr, style=label.style_label_left,
         color=color.new(color.navy, 30), textcolor=color.white, size=size.small)

// =============================================================================
// SECTION 4 — CONFLUENCE SCORING • LOGIC
// =============================================================================
trendEma       = ta.ema(close, emaLen)
priceAboveEma  = close > trendEma
priceBelowEma  = close < trendEma

// BOS or CHoCH on current OR previous confirmed bar in the aligned direction
bullStruct = bullBOS or bullCHoCH or bullBOS[1] or bullCHoCH[1]
bearStruct = bearBOS or bearCHoCH or bearBOS[1] or bearCHoCH[1]

biasBull       = bias ==  1
biasBear       = bias == -1
regimeNormal   = regimeCode == 1

// Per-condition booleans (also fed to the on-chart table)
c_bull_trend   = priceAboveEma
c_bull_bias    = biasBull
c_bull_struct  = bullStruct
c_bull_regime  = regimeNormal
c_bull_session = sessionActive
c_bull_zone    = extZoneBull

c_bear_trend   = priceBelowEma
c_bear_bias    = biasBear
c_bear_struct  = bearStruct
c_bear_regime  = regimeNormal
c_bear_session = sessionActive
c_bear_zone    = extZoneBear

bullScore = (c_bull_trend ? wTrend : 0) + (c_bull_bias ? wBias : 0) + (c_bull_struct ? wBosChoch : 0) + (c_bull_regime ? wRegime : 0) + (c_bull_session ? wSession : 0) + (c_bull_zone ? wExtZone : 0)

bearScore = (c_bear_trend ? wTrend : 0) + (c_bear_bias ? wBias : 0) + (c_bear_struct ? wBosChoch : 0) + (c_bear_regime ? wRegime : 0) + (c_bear_session ? wSession : 0) + (c_bear_zone ? wExtZone : 0)

// Threshold edge detection
bullThreshHit = bullScore >= threshold and bullScore[1] <  threshold
bearThreshHit = bearScore >= threshold and bearScore[1] <  threshold
bullDropOff   = bullScore <  threshold and bullScore[1] >= threshold
bearDropOff   = bearScore <  threshold and bearScore[1] >= threshold

// =============================================================================
// SECTION 5 — CONFLUENCE HIGHLIGHTER • LOGIC
// =============================================================================
// One verdict from the two independent scores. Tiers:
//   +2 Stacked Long · +1 Leaning Long · 0 Balanced · -1 Leaning Short · -2 Stacked Short
// "Stacked" = the dominant side has cleared the alert threshold.
bullDom = bullScore > bearScore
bearDom = bearScore > bullScore

int verdictState = bullScore >= threshold and bullDom ?  2 :
                   bearScore >= threshold and bearDom ? -2 :
                   bullDom                             ?  1 :
                   bearDom                             ? -1 :
                                                          0

verdictStr = verdictState ==  2 ? "Stacked Long"  :
             verdictState ==  1 ? "Leaning Long"  :
             verdictState == -1 ? "Leaning Short" :
             verdictState == -2 ? "Stacked Short" :
                                  "Balanced"

// Context-honest wording. CC confirms context — it never calls a trade, so this
// stays "BULLISH/BEARISH", never "BUY/SELL".
contextStr = verdictState > 0 ? "BULLISH" : verdictState < 0 ? "BEARISH" : "BALANCED"

// Palettes — candles saturated (the hero), background ambient (very transparent).
hlBarCol = verdictState ==  2 ? color.new(#00e676, 0)  :
           verdictState ==  1 ? color.new(#26a69a, 30) :
           verdictState == -1 ? color.new(#ef5350, 30) :
           verdictState == -2 ? color.new(#d50000, 0)  :
                               na

hlBgCol  = verdictState ==  2 ? color.new(color.green, 82) :
           verdictState ==  1 ? color.new(color.green, 90) :
           verdictState == -1 ? color.new(color.red,   90) :
           verdictState == -2 ? color.new(color.red,   82) :
                               na

doCandles = useHighlighter and (hlMode == "Candles" or hlMode == "Both")
doBg      = useHighlighter and (hlMode == "Background" or hlMode == "Both")

// Single-candle structure paint — colors ONLY the bar where a BOS/CHoCH confirms,
// reusing the Section 1 label colors so the candle matches its label. Bull events
// take precedence over bear on the (rare) bar that breaks both extremes.
hlStructBarCol = bullBOS   ? bullBosColor   :
                 bullCHoCH ? bullChochColor :
                 bearBOS   ? bearBosColor   :
                 bearCHoCH ? bearChochColor :
                                          na

hlCandlePaint = hlCandleMode == "BOS / CHoCH Candle" ? hlStructBarCol : hlBarCol

barcolor(doCandles ? hlCandlePaint : na, title="Confluence Highlighter — Candles")
bgcolor(doBg ? hlBgCol : na, title="Confluence Highlighter — Background")

// -----------------------------------------------------------------------------
// LIVE TABLE
// -----------------------------------------------------------------------------
var table cTable = na
if showTable and barstate.islast
    pos = switch tablePos
        "top_right"    => position.top_right
        "top_left"     => position.top_left
        "bottom_right" => position.bottom_right
        "bottom_left"  => position.bottom_left
        "middle_right" => position.middle_right
        "middle_left"  => position.middle_left
        => position.top_right

    if na(cTable)
        cTable := table.new(pos, 3, 12, border_width=1)

    // Headline verdict row (row 0, merged across all 3 columns) — the one-glance hero
    if showHeadline
        hlHeadBg = verdictState ==  2 ? color.new(color.green, 10) :
                   verdictState ==  1 ? color.new(color.green, 35) :
                   verdictState == -1 ? color.new(color.red,   35) :
                   verdictState == -2 ? color.new(color.red,   10) :
                                       color.new(color.gray,  20)
        table.cell(cTable, 0, 0,
             "CONTEXT: " + contextStr + "   ·   " + verdictStr + "   ·   " + str.tostring(bullScore) + " / " + str.tostring(bearScore),
             bgcolor=hlHeadBg, text_color=color.white, text_size=size.normal)
        table.merge_cells(cTable, 0, 0, 2, 0)

    // Header
    table.cell(cTable, 0, 1, "Confluence", bgcolor=color.new(color.black, 0), text_color=color.white, text_size=size.small)
    table.cell(cTable, 1, 1, "Bull",       bgcolor=color.new(color.black, 0), text_color=color.white, text_size=size.small, width=tblColW)
    table.cell(cTable, 2, 1, "Bear",       bgcolor=color.new(color.black, 0), text_color=color.white, text_size=size.small, width=tblColW)

    // Score row
    table.cell(cTable, 0, 2, "Score", bgcolor=color.new(color.gray, 60), text_color=color.white, text_size=size.small)
    table.cell(cTable, 1, 2, str.tostring(bullScore),
         bgcolor=bullScore >= threshold ? color.new(color.green, 20) : color.new(color.green, 70),
         text_color=color.white, text_size=size.small, width=tblColW)
    table.cell(cTable, 2, 2, str.tostring(bearScore),
         bgcolor=bearScore >= threshold ? color.new(color.red, 20) : color.new(color.red, 70),
         text_color=color.white, text_size=size.small, width=tblColW)

    // Conditions
    table.cell(cTable, 0, 3, "Trend (EMA)",   text_color=color.white, text_size=size.small)
    table.cell(cTable, 1, 3, f_check(c_bull_trend),   text_color=color.white, bgcolor=f_cellBg(c_bull_trend),   text_size=size.small, width=tblColW)
    table.cell(cTable, 2, 3, f_check(c_bear_trend),   text_color=color.white, bgcolor=f_cellBg(c_bear_trend),   text_size=size.small, width=tblColW)

    table.cell(cTable, 0, 4, "Bias Aligned",  text_color=color.white, text_size=size.small)
    table.cell(cTable, 1, 4, f_check(c_bull_bias),    text_color=color.white, bgcolor=f_cellBg(c_bull_bias),    text_size=size.small, width=tblColW)
    table.cell(cTable, 2, 4, f_check(c_bear_bias),    text_color=color.white, bgcolor=f_cellBg(c_bear_bias),    text_size=size.small, width=tblColW)

    table.cell(cTable, 0, 5, "BOS / CHoCH",   text_color=color.white, text_size=size.small)
    table.cell(cTable, 1, 5, f_check(c_bull_struct),  text_color=color.white, bgcolor=f_cellBg(c_bull_struct),  text_size=size.small, width=tblColW)
    table.cell(cTable, 2, 5, f_check(c_bear_struct),  text_color=color.white, bgcolor=f_cellBg(c_bear_struct),  text_size=size.small, width=tblColW)

    table.cell(cTable, 0, 6, "Regime Normal", text_color=color.white, text_size=size.small)
    table.cell(cTable, 1, 6, f_check(c_bull_regime),  text_color=color.white, bgcolor=f_cellBg(c_bull_regime),  text_size=size.small, width=tblColW)
    table.cell(cTable, 2, 6, f_check(c_bear_regime),  text_color=color.white, bgcolor=f_cellBg(c_bear_regime),  text_size=size.small, width=tblColW)

    table.cell(cTable, 0, 7, "Session Active",text_color=color.white, text_size=size.small)
    table.cell(cTable, 1, 7, f_check(c_bull_session), text_color=color.white, bgcolor=f_cellBg(c_bull_session), text_size=size.small, width=tblColW)
    table.cell(cTable, 2, 7, f_check(c_bear_session), text_color=color.white, bgcolor=f_cellBg(c_bear_session), text_size=size.small, width=tblColW)

    table.cell(cTable, 0, 8, "Ext Zone Hit",  text_color=color.white, text_size=size.small)
    table.cell(cTable, 1, 8, f_check(c_bull_zone),    text_color=color.white, bgcolor=f_cellBg(c_bull_zone),    text_size=size.small, width=tblColW)
    table.cell(cTable, 2, 8, f_check(c_bear_zone),    text_color=color.white, bgcolor=f_cellBg(c_bear_zone),    text_size=size.small, width=tblColW)

    // Context rows
    atrTxt = na(atrVal) ? "—" : str.tostring(atrVal, format.mintick)
    table.cell(cTable, 0, 9,  "ATR",     text_color=color.white, text_size=size.small)
    table.cell(cTable, 1, 9,  atrTxt,    text_color=color.white, text_size=size.small, width=tblColW)
    table.cell(cTable, 2, 9,  useH1Vol ? "(H1)" : "(TF)", text_color=color.white, text_size=size.small, width=tblColW)

    table.cell(cTable, 0, 10, "Session", text_color=color.white, text_size=size.small)
    table.cell(cTable, 1, 10, activeSessionStr, text_color=color.white, text_size=size.small, width=tblColW)
    table.cell(cTable, 2, 10, "",         text_size=size.small, width=tblColW)

    table.cell(cTable, 0, 11, "Bias / Regime", text_color=color.white, text_size=size.small)
    table.cell(cTable, 1, 11, biasStr,         text_color=color.white, text_size=size.small, width=tblColW)
    table.cell(cTable, 2, 11, regimeStr,       text_color=color.white, text_size=size.small, width=tblColW)

// =============================================================================
// SECTION 6 — WATERMARK • fixed author attribution, pinned to a chart corner
// =============================================================================
// Always-on corner stamp — no toggle, no inputs. Corner-anchored table stays put
// on scroll/zoom (unlike a bar-anchored label); transparent cell bg → the text
// floats like a watermark. To reposition (e.g. for a thumbnail capture), change
// `position.bottom_right` below — default is the opposite corner from the
// confluence table's default top_right so the two never collide.
var table wmTable = na
if barstate.islast
    if na(wmTable)
        wmTable := table.new(position.bottom_right, 1, 1)
    table.cell(wmTable, 0, 0, "SlatinaTrades",
         text_color=color.new(color.gray, 35), text_size=size.normal,
         bgcolor=color.new(color.black, 100))

// =============================================================================
// ALERTS
// =============================================================================
// --- Section 1: Structure ---
alertcondition(bullBOS,   "Bullish BOS confirmed",   "Bullish BOS confirmed on {{ticker}} {{interval}}")
alertcondition(bearBOS,   "Bearish BOS confirmed",   "Bearish BOS confirmed on {{ticker}} {{interval}}")
alertcondition(bullCHoCH, "Bullish CHoCH confirmed", "Bullish CHoCH confirmed on {{ticker}} {{interval}}")
alertcondition(bearCHoCH, "Bearish CHoCH confirmed", "Bearish CHoCH confirmed on {{ticker}} {{interval}}")

// --- Section 2: Regime transitions ---
alertcondition(regimeLowToNormal,     "Volatility: Low → Normal",     "Volatility shifted Low → Normal on {{ticker}} {{interval}}")
alertcondition(regimeNormalToExtreme, "Volatility: Normal → Extreme", "Volatility shifted Normal → Extreme on {{ticker}} {{interval}}")
alertcondition(regimeExtremeToNormal, "Volatility: Extreme → Normal", "Volatility dropped Extreme → Normal on {{ticker}} {{interval}}")
alertcondition(regimeNormalToLow,     "Volatility: Normal → Low",     "Volatility dropped Normal → Low on {{ticker}} {{interval}}")

// --- Section 3: Session edges ---
alertcondition(londonOpen, "London session opens",   "London session opened on {{ticker}}")
alertcondition(nyOpen,     "New York session opens", "New York session opened on {{ticker}}")
alertcondition(asiaOpen,   "Asia session opens",     "Asia session opened on {{ticker}}")
alertcondition(allClosed,  "All sessions closed",    "All sessions closed on {{ticker}}")

// --- Section 4: Confluence threshold (rich dynamic message via alert()) ---
if barstate.isconfirmed and bullThreshHit
    msg = "BULL Confluence | Symbol: " + syminfo.tickerid +
          " | TF: "        + timeframe.period +
          " | Direction: BULL" +
          " | Score: "     + str.tostring(bullScore) +
          " | Bias: "      + biasStr +
          " | ATR: "       + (na(atrVal) ? "n/a" : str.tostring(atrVal, format.mintick)) +
          " | Session: "   + activeSessionStr +
          " | Regime: "    + regimeStr +
          " | Time: "      + str.format_time(time, "yyyy-MM-dd HH:mm", sessionTz)
    alert(msg, alert.freq_once_per_bar_close)

if barstate.isconfirmed and bearThreshHit
    msg = "BEAR Confluence | Symbol: " + syminfo.tickerid +
          " | TF: "        + timeframe.period +
          " | Direction: BEAR" +
          " | Score: "     + str.tostring(bearScore) +
          " | Bias: "      + biasStr +
          " | ATR: "       + (na(atrVal) ? "n/a" : str.tostring(atrVal, format.mintick)) +
          " | Session: "   + activeSessionStr +
          " | Regime: "    + regimeStr +
          " | Time: "      + str.format_time(time, "yyyy-MM-dd HH:mm", sessionTz)
    alert(msg, alert.freq_once_per_bar_close)

if fireExitAlert and barstate.isconfirmed and bullDropOff
    alert("Bull confluence dropped below threshold on " + syminfo.tickerid + " " + timeframe.period,
         alert.freq_once_per_bar_close)
if fireExitAlert and barstate.isconfirmed and bearDropOff
    alert("Bear confluence dropped below threshold on " + syminfo.tickerid + " " + timeframe.period,
         alert.freq_once_per_bar_close)

// Static counterparts for users who prefer the alertcondition picker
alertcondition(bullThreshHit, "Bullish confluence threshold reached", "Bullish confluence threshold reached on {{ticker}} {{interval}}")
alertcondition(bearThreshHit, "Bearish confluence threshold reached", "Bearish confluence threshold reached on {{ticker}} {{interval}}")
alertcondition(bullDropOff,   "Bull score dropped below threshold",   "Bull confluence score dropped below threshold on {{ticker}} {{interval}}")
alertcondition(bearDropOff,   "Bear score dropped below threshold",   "Bear confluence score dropped below threshold on {{ticker}} {{interval}}")
````
