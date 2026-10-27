# BarrettFVG HTF Pivot Reaction Model

- url: https://www.tradingview.com/script/pEE621v3-BarrettFVG-HTF-Pivot-Reaction-Model/
- type: indicator
- pine_id: PUB;0e960c2d9d004033b941d4fc67d57c71
- version: 16.0

## Description

**BarrettFVG HTF Pivot Reaction Model**

Higher-timeframe swing levels that have to **earn** their place before they can produce a signal. Rather than plotting every pivot high and low from a higher timeframe and treating them all as equally valid, this indicator tracks how price has actually behaved at each level and only qualifies the ones price has demonstrably reacted to.

---

### The core idea

Most multi-timeframe S/R tools draw every HTF pivot as a level. The problem is that a swing high is just a price where the market happened to turn once — and one turn doesn't make an area meaningful. Some of those levels get respected repeatedly; most get cut straight through and never mattered.

This indicator separates the two by observation rather than assumption. Every 1H, 30m, and 15m pivot is tracked from the moment it forms, but it starts as a **Potential Level** — visible, monitored, and unable to produce any signal. It only becomes a qualified level once price has come back and genuinely reacted at it.

A **reaction** is defined mechanically:

1. Price enters the level's tolerance band
2. Price then moves away from it — in the direction the level should push it (down from a resistance, up from a support)
3. That move reaches a configurable distance, measured in multiples of the higher timeframe's ATR

Direction is enforced deliberately. A candle spiking straight through a level covers plenty of distance, but that's the opposite of respecting it, so only movement on the correct side counts. A sharp rejection and a slow stall-then-drift-away both qualify, as long as price eventually clears the required distance within the reaction window.

Each level displays its running reaction count, so you can see exactly how many times price has responded there.

---

### Levels

- **Three source timeframes**: 1H, 30m, and 15m by default, each individually toggleable and configurable
- **Automatic merging**: pivots from different timeframes landing within the same tolerance band become one level tagged with all of its sources (`15m+30m+1H`), keeping the accumulated reaction history rather than double-counting
- **Extended across the chart**: levels run in both directions, so a level formed days ago stays visible as a flat reference — a level is a price that stays relevant, not a segment tied to when it formed
- **Proximity display**: only the closest levels to current price are drawn, so the chart shows what's in play rather than every level in history
- **Two display modes**: a clean midpoint line, or the full tolerance band shown as a zone box so you can see exactly what the logic is using

**Timeframe consistency:** all sizing, ageing, and reaction timing is anchored to the higher timeframe's ATR and to real clock time rather than to chart bars. This means the same levels appear whether you're on a 1-minute chart or a 15-minute one. A bar-based implementation would silently produce different level sets on different chart timeframes from identical source data.

---

### Entry model

Two paths, both requiring a Break of Structure to fire:

**1 — TAP**
Price reaches a qualified level, taps it or slightly overshoots within a configurable tolerance, then breaks structure in the reversal direction. The overshoot allowance is what separates a tap from a break; beyond it, the level is treated as broken and only the reclaim path remains available.

**2 — RECLAIM (break and retest)**
Price breaks through the level, **builds structure on the far side**, then returns to the level and breaks structure back in the reversal direction.

The far-side structure requirement is the important part. A break only counts as significant once a confirmed swing forms beyond the level — for a broken resistance, that means a swing low printing above it, showing price pulled back up there and held. This is deliberately a *structural* test rather than a candle-size threshold: a single large wick through a level doesn't qualify, while a slow grind that builds a genuine swing does.

Both paths then wait for the same Break of Structure confirmation within a configurable bar window, using independent pivot tracking rather than the level's own geometry — so the confirmation is a real structural event, not a restatement of the level that armed it.

**Level flipping:** when a reclaim confirms, the level inverts its polarity. A resistance that price broke above and then held as support becomes a support level, marked with a flip indicator. This changes its behaviour, not just its appearance — future taps arm the correct direction from that point on.

---

### Signals and alerts

Entry markers plot as directional arrows on the confirming candle, with a dotted line showing the swing that broke to produce the BOS — anchored at the swing's actual formation bar so it points at the structure it's referencing.

Alerts carry the full context of what fired:

`MNQ1! — LONG RECLAIM | 1H+15m level @ 29,437.75 | 3 reactions`

Which entry path fired, which timeframes formed the level, the level's price, and how many times price has reacted there.

Signals are restricted to configurable trading session windows, with a cooldown preventing repeated same-direction entries off a single move.

**This indicator does not plot stop-loss or take-profit levels.** It identifies levels and signals entries; risk placement is left to the trader.

---

### Settings

Grouped by how often you'd change them:

1. **HTF Levels** — source timeframes, pivot length, band width, storage limits, level age
2. **Reaction Qualification** — minimum reactions, move-away distance, reaction window
3. **Entry Model** — path toggles, BOS pivot length and window, overshoot tolerance, cooldown
4. **Reclaim Structure** — far-side pivot length, retest window
5. **Sessions** — trading windows
6. **Display** — level visibility, colours, markers, labels

Every input has a tooltip explaining what it does and how it interacts with the rest.

---

### Notes on defaults

Defaults are **starting points, not optimised values.** They have not been backtested or tuned for any particular instrument or timeframe. The reaction distance, band width, and BOS window in particular will likely need adjusting for whatever you trade — start with Potential Levels visible so you can see what's being tracked and how quickly levels accumulate reactions before tightening anything.

Because reactions are earned through observed price behaviour rather than assumed from pivot geometry, levels start unqualified and accumulate history as the chart loads. Expect fewer qualified levels near the left edge of a freshly-loaded chart.

---

## Disclaimer

*This script is provided for educational and informational purposes only. It does not constitute financial, investment, or trading advice, nor a recommendation or solicitation to buy or sell any financial instrument.*

*Trading futures, forex, stocks, cryptocurrencies, and other leveraged instruments carries a substantial risk of loss and is not suitable for every investor. You may lose some or all of your invested capital, and with leveraged products you can lose more than your initial deposit. You should not trade with money you cannot afford to lose.*

*No indicator, system, or method can predict future price movement. The signals produced by this script are pattern-based observations derived from historical price data — they describe what has already happened, not what will happen next. Levels identified as "qualified" have met a mechanical definition of prior reaction; this does not imply price will react at them again.*

*Past performance, backtested results, hypothetical results, and historical signals are not indicative of future results. Backtested and hypothetical performance carries inherent limitations, including the benefit of hindsight and the absence of real execution factors such as slippage, spread, commissions, liquidity constraints, and the psychological pressures of live trading.*

*The default settings included with this script are unoptimised starting points. They have not been tuned or validated for any specific market, timeframe, account size, or risk tolerance. Test thoroughly on historical data and in simulation before considering any use with real capital.*

*This script does not plot or calculate stop-loss or take-profit levels. Position sizing, risk management, and trade management decisions are entirely the responsibility of the user.*

*You are solely responsible for your own trading decisions and for any outcomes resulting from them. The author makes no representations or warranties as to the accuracy, completeness, or suitability of this script for any purpose, and accepts no liability whatsoever for any losses, damages, or costs incurred through its use.*

## Source Code

````pine
// Author: barrettfvg
// BarrettFVG HTF Pivot Reaction Model
//
// Marks major swing pivots from three higher timeframes (1H / 30m / 4H by
// default) onto the chart timeframe, but
// only treats a level as tradeable once price has demonstrably REACTED at it
// a minimum number of times. A reaction is observed behaviour, not assumed
// geometry: price enters the level's band, then moves away from it by a
// meaningful distance — a bounce, or a stall-and-consolidate, both count.
//
// Three entry paths:
//   1. TAP     — price reaches a qualified level, taps or slightly overshoots
//                it, then BOS in the reversal direction.
//   2. RECLAIM — price breaks through the level and BUILDS STRUCTURE on the
//                far side (forms a confirmed swing beyond it — not merely a
//                wick or a single close), then returns to the level, then
//                BOS back in the reversal direction. The structure
//                requirement is what makes the break "significant" without
//                relying on candle size.
//   3. ACCUM   — after a tap, price consolidates in a tight range; the entry
//                fires when price closes outside that range, in whichever
//                direction it leaves. No BOS required for this path.
//@version=6
// max_bars_back = 5000 is REQUIRED, not tuning. The trendline engine's
// invalidation sweep walks back to an earlier pivot bar using low[i],
// high[i] and bar_index[i]. Pine's default history buffer is 300 bars —
// reach past it and those series return na instead of data. The comparison
// then evaluates false, the sweep silently stops working, and no error is
// raised. The standalone Trendline indicator sets this for the same reason.
indicator("BarrettFVG HTF Pivot Reaction Model", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 5000)

// ============================================================
//                         INPUTS
// ============================================================

// ---------- 1 · LEVELS ----------
string grpLvl = "1 · HTF Levels"
bool useTf1 = input.bool(true, "Timeframe 1", inline = "tf1", group = grpLvl, tooltip = "Timeframe 1 is also the ATR reference for the volatility-scaled settings — reaction distance, tap overshoot and accumulation width are multiples of its ATR(14). Changing it rescales those three, so raising it to 4H or 1D widens them substantially. Level merge and touch tolerances are fixed in ticks and are not affected.")
string tf1 = input.timeframe("60", "", inline = "tf1", group = grpLvl)
bool useTf2 = input.bool(true, "Timeframe 2", inline = "tf2", group = grpLvl)
string tf2 = input.timeframe("30", "", inline = "tf2", group = grpLvl)
bool useTf3 = input.bool(true, "Timeframe 3", inline = "tf3", group = grpLvl)
string tf3 = input.timeframe("240", "", inline = "tf3", group = grpLvl)
int htfPivotLen = input.int(5, "HTF Pivot Length (L/R)", minval = 2, maxval = 30, tooltip = "Bars either side required to confirm a swing on each higher timeframe. Higher = fewer, more major pivots.", group = grpLvl)
int mergeTicks = input.int(48, "Level Merge Tolerance (ticks)", minval = 1, maxval = 400, tooltip = "How close two pivots must be to merge into a single level. 48 ticks is 12 points on MNQ. Fixed rather than ATR-scaled on purpose: whether two pivots are the same level or two different levels is a question about chart precision, not market energy, and a volatility-scaled threshold would reshuffle the level set as ATR drifts — taking accumulated reaction history with it. Applies across all three timeframes; a 30m and a 4H pivot this close merge into one. Does NOT control what counts as price tapping a level; that is the setting below.", group = grpLvl)
int touchTicks = input.int(24, "Level Touch Tolerance (ticks)", minval = 0, maxval = 100, tooltip = "Price must come within this many ticks of a level to arm an entry. 24 ticks is 6 points on MNQ. Fixed in ticks rather than ATR-scaled so it does not silently widen when volatility rises. A merged level has a single price, and price must come within this tolerance of THAT price regardless of how widely the original pivots were spread.", group = grpLvl)
int maxLevels = input.int(80, "Max Stored Levels Per Side", minval = 5, maxval = 300, tooltip = "How many levels each side retains before the weakest is dropped. Raised to sit comfortably above what a 30-day window accumulates, so age rather than capacity decides what ages out. Eviction removes the fewest-reaction level first, so what goes is always the least-proven.", group = grpLvl)
float levelMaxAgeDays = input.float(30.0, "Level Max Age (days)", minval = 0.5, maxval = 365.0, step = 0.5, tooltip = "Levels older than this are dropped. Measured in real days rather than bars so the same levels survive on a 1m chart and a 15m chart — a bar count would age levels out roughly 15x faster on the lower timeframe.", group = grpLvl)

// ---------- 2 · REACTION QUALIFICATION ----------
string grpReact = "2 · Reaction Qualification"
int minTimeframes = input.int(2, "Min Timeframes to Qualify", minval = 1, maxval = 3, tooltip = "How many of the three source timeframes must have printed a swing at this price before the level can arm an entry.\n\nAt 2 a bare 30m level stays Potential and never fires; only levels with 1H or 4H agreement behind them are tradeable. This is the least ambiguous significance measure available here — two timeframes independently marking the same price means more than one did, with nothing to interpret. Unlike reaction count it is known the moment the level forms, so a genuinely significant fresh level is not held back waiting to earn it.\n\nLevels below the threshold still DRAW as Potential, so they remain visible as context.", group = grpReact)
int minReactions = input.int(1, "Min Reactions to Qualify", minval = 1, maxval = 10, tooltip = "How many times price must react at a level before its taps can produce entry signals. A reaction is counted when price enters the level's band and then moves away by the distance below. 1 means a level qualifies after its first genuine reaction; raise it to require a level price has responded to repeatedly.", group = grpReact)
float reactMoveAtr = input.float(0.5, "Reaction Move-Away Distance (ATR)", minval = 0.1, step = 0.05, tooltip = "After entering a level's band, price must move this far away from it — in the direction the level should push it — for the visit to count as a reaction. Measured in multiples of the Primary Timeframe's ATR, so on a 1H primary this is already a substantial move. Lower it if levels aren't accumulating reactions; raise it to demand a stronger rejection.", group = grpReact)
int reactMaxMins = input.int(240, "Reaction Window (minutes)", minval = 5, maxval = 5000, tooltip = "How long after entering a band price has to achieve the move-away distance. If price is still hovering near the band after this long, the visit doesn't count as a reaction. Measured in real minutes so reactions are counted identically on any chart timeframe.", group = grpReact)

// ---------- 3 · ENTRY MODEL ----------
string grpEntry = "3 · Entry Model"
bool useTapEntry = input.bool(true, "Enable TAP entries", tooltip = "Price reaches a qualified level, taps or slightly overshoots it, then BOS in the reversal direction.", group = grpEntry)
bool useReclaimEntry = input.bool(true, "Enable RECLAIM (break & retest) entries", tooltip = "Price breaks through the level and builds structure on the far side, then returns to the level, then BOS back in the reversal direction.", group = grpEntry)
float tapOvershootAtr = input.float(0.25, "Max Overshoot on TAP (ATR)", minval = 0.0, step = 0.05, tooltip = "How far beyond a level price may trade and still count as a tap rather than a break. Beyond this, the level is treated as broken and only the RECLAIM path can fire.", group = grpEntry)
int bosPivotLen = input.int(3, "BOS Pivot Length", minval = 2, maxval = 20, tooltip = "Pivot length for the chart-timeframe swing that must break to confirm an entry. Higher = a more significant swing must break, but confirmation arrives later since each pivot needs this many bars after it forms to confirm.", group = grpEntry)
int bosWindowMins = input.int(15, "Max Minutes From Tap to BOS", minval = 1, maxval = 600, tooltip = "How long a pending entry stays live waiting for BOS. BOS asks price to clear a swing extreme, which is a real move and needs room to develop — a short window here mostly produces setups that expire unconfirmed rather than being rejected on merit.", group = grpEntry)
int armCooldownMins = input.int(15, "Arm Cooldown Per Direction (minutes)", minval = 0, maxval = 600, tooltip = "After a bullish setup arms, no other bullish setup can arm for this long — and the same separately for bearish. Scoped per direction rather than per level on purpose: with several levels clustered near price, a per-level cooldown still lets each one arm the same direction in turn. Longs and shorts are tracked independently, so a short can still arm while longs are on cooldown.", group = grpEntry)
int bosBufferTicks = input.int(1, "BOS Buffer (ticks)", minval = 0, tooltip = "Close must clear the BOS pivot by this many ticks rather than an exact zero-distance cross.", group = grpEntry)
int cooldownBars = input.int(15, "Signal Cooldown Bars", minval = 0, tooltip = "Minimum bars between two signals in the same direction.", group = grpEntry)

// ---------- 4 · RECLAIM STRUCTURE ----------
string grpReclaim = "4 · Reclaim Structure"
int reclaimPivotLen = input.int(3, "Far-Side Structure Pivot Length", minval = 2, maxval = 20, tooltip = "A confirmed swing of this pivot length must form beyond the level for the break to count as significant. This is the structural definition of a real break — deliberately not based on candle size, so a slow grind that builds a genuine swing qualifies while a single large wick does not.", group = grpReclaim)
int reclaimMaxMins = input.int(100, "Max Minutes From Break to Retest", minval = 5, maxval = 2000, tooltip = "How long after breaking a level the reclaim setup stays valid waiting for price to return. In real minutes so it means the same thing on any chart timeframe.", group = grpReclaim)


// ---------- 5 · ACCUMULATION ----------
string grpAcc = "5 · Accumulation"
bool useAccEntry = input.bool(true, "Enable ACCUMULATION entries", tooltip = "A third entry path independent of TAP and RECLAIM: after a level tap, price often goes sideways in a tight range rather than resolving immediately, and the entry fires when price closes outside that range. No direction bias — it fires whichever way price leaves, so a break back through the tapped level counts as continuation rather than a failed setup.", group = grpAcc)
bool showAccBox = input.bool(true, "Draw Accumulation Box", tooltip = "Draws a box around the range price is consolidating in after a level tap. Only the most recent one is kept. Independent of the entry toggle above — you can draw the boxes without enabling entries, or enable entries without drawing anything.", group = grpAcc)
int accMinMins = input.int(5, "Min Minutes to Form Accumulation", minval = 1, maxval = 240, tooltip = "How long price must spend building the range before it counts as accumulation rather than a brief pause. The range expands during this period, then freezes and waits for price to leave it.", group = grpAcc)
float accMaxWidthAtr = input.float(0.8, "Max Accumulation Width (ATR)", minval = 0.05, step = 0.05, tooltip = "How wide the range may get, in multiples of Timeframe 1's ATR, and still count as consolidation. Widened from 0.4 — the tap path handles fast rejections, so accumulation is meant to catch the slower, looser consolidations that follow a level tap. Too tight and it only sees the rare textbook range.", group = grpAcc)
int accMaxMins = input.int(30, "Max Minutes From Tap to Breakout", minval = 2, maxval = 600, tooltip = "The whole accumulation must form AND break out within this many minutes of the tap. If it has not resolved by then the range is discarded and price must tap the level again to start a new one.", group = grpAcc)
bool accRequireVolume = input.bool(true, "Require Above-Average Volume on Breakout", tooltip = "The candle that breaks the range must trade more than its recent average volume. A range that leaks out on thin volume is drift; a real breakout brings participation.", group = grpAcc)
float accVolMult = input.float(1.2, "    ↳ Volume Multiple", minval = 0.5, step = 0.1, tooltip = "Breakout candle volume must exceed this multiple of the recent average.", group = grpAcc)
int accVolLen = input.int(20, "    ↳ Volume Average Length", minval = 2, maxval = 200, group = grpAcc)
color accBoxColor = input.color(color.new(color.orange, 82), "Accumulation Box Color", group = grpAcc)

// ---------- 6 · KEY LEVELS & VWAPS ----------
// Display-only context. None of this gates or arms an entry — the pivot
// levels above remain the only thing the entry model reads.
string grpKey = "6 · Key Levels & VWAPs"
bool showKeyLevels = input.bool(true, "Show Key Levels", tooltip = "Previous day high/low, previous week high/low, and the True Day Open. Drawn as dotted lines extending across the chart.", group = grpKey)
bool includePw = input.bool(true, "    ↳ Include Prev Week High/Low", group = grpKey)
bool includeTdo = input.bool(true, "    ↳ Include True Day Open", tooltip = "The 18:00 EST open — where the trading day actually began for futures.", group = grpKey)
color pdColor = input.color(color.black, "    ↳ Prev Day Color", group = grpKey)
color pwColor = input.color(color.new(color.gray, 0), "    ↳ Prev Week Color", group = grpKey)
color tdoLineColor = input.color(color.new(color.teal, 0), "    ↳ True Day Open Color", group = grpKey)
int keyLabelClearTicks = input.int(40, "    ↳ Label Clearance (ticks)", minval = 0, maxval = 200, tooltip = "Two key level labels closer together than this are treated as colliding, and each one after the first is pushed further right into its own column. The lines never move — only the text.", group = grpKey)
int keyLabelBaseBars = input.int(33, "    ↳ Label Lane Offset (bars)", minval = 0, maxval = 200, tooltip = "How far right the key level labels sit. Kept clear of the pivot level labels at 15 bars, so the two sets never occupy the same space regardless of price.", group = grpKey)
int keyLabelShiftBars = input.int(16, "    ↳ Column Spacing (bars)", minval = 4, maxval = 60, tooltip = "Horizontal gap between stacked key level labels when several sit at similar prices.", group = grpKey)

bool showVwaps = input.bool(false, "Show VWAPs", tooltip = "TDO VWAP anchors at 18:00 EST and runs continuously until the next day's anchor. NY VWAP anchors at 09:30 EST and disappears outside the NY session rather than persisting as a flat line.", group = grpKey)
color tdoVwapColor = input.color(color.blue, "    ↳ TDO VWAP Color (18:00 EST)", group = grpKey)
color nyVwapColor = input.color(#9c27b0, "    ↳ NY Session VWAP Color", group = grpKey)

// ---------- 7 · SESSIONS ----------
string grpSess = "7 · Sessions"
bool useSess = input.bool(true, "Gate signals by session", group = grpSess)
string sess1 = input.session("1800-0000", "Trading Time Window 1 (EST)", group = grpSess)
string sess2 = input.session("0700-1600", "Trading Time Window 2 (EST)", group = grpSess)

// ---------- 8 · DISPLAY ----------
string grpDisp = "8 · Display"
bool showLevels = input.bool(true, "Show Qualified Levels", tooltip = "Draws levels that have met the reaction minimum. Unqualified levels are tracked internally but not drawn.", group = grpDisp)
int visiblePerSide = input.int(3, "    ↳ Visible Levels Per Side", minval = 1, maxval = 10, tooltip = "Draws this many levels ABOVE price and this many BELOW it, chosen by actual position relative to price. Qualified and potential levels are counted separately, so at 2 you get 2 qualified plus 2 potential on each side. Every level is tracked and can fire entries whether or not it is drawn.", group = grpDisp)
bool showUnqualified = input.bool(false, "Also Show Potential Levels", tooltip = "Draws levels that have not yet qualified — not enough source timeframes, or not enough reactions — in the Potential Level colour with a dotted line. These are tracked either way — showing them just lets you see what's queued up before it qualifies.", group = grpDisp)
string labelSizeIn = input.string("Normal", "Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], tooltip = "Text size for the level and key level labels.", group = grpDisp)
int maxEntryLabels = input.int(50, "Entry Markers Kept", minval = 1, maxval = 100, tooltip = "How many past entry markers stay on the chart before the oldest are deleted. These share the 500-label budget with level labels, so this cap keeps entry history from crowding out the levels themselves.", group = grpDisp)
bool showBosLine = input.bool(true, "Draw BOS Line", tooltip = "Dotted line from the swing that broke to confirm the entry, running across to the candle the signal fired on and tagged at its midpoint. Shows exactly what the BOS was measured against.", group = grpDisp)
bool weightByTimeframes = input.bool(true, "Thicken Multi-Timeframe Levels", tooltip = "Levels confirmed by more than one higher timeframe draw thicker. Three independent timeframes printing a swing at the same price is the least ambiguous strength signal available — unlike volume or reaction count, more agreement has only one reading.", group = grpDisp)
string levelDisplay = input.string("Midpoint line only", "Level Display", options = ["Midpoint line only", "Zone box"], tooltip = "Midpoint line only: a single line at the pivot price, extending across the whole chart in both directions. Zone box: additionally shades the tolerance band the logic actually uses — price entering that band is what counts as reaching the level. The band applies either way; this only changes whether it's visible.", group = grpDisp)
color unqualColor = input.color(color.new(color.gray, 0), "Potential Level Color", tooltip = "Colour for levels that haven't yet earned enough reactions to qualify. These are drawn only if 'Also Show Potential Levels' is on — they're tracked either way, they just can't fire entries until they've reacted.", group = grpDisp)
color resColor = input.color(color.black, "Resistance Level Color", group = grpDisp)
color supColor = input.color(color.black, "Support Level Color", group = grpDisp)
color longColor = input.color(color.green, "Long Entry Color", group = grpDisp)
color shortColor = input.color(color.red, "Short Entry Color", group = grpDisp)

// ---------- 9 · TRENDLINES ----------
// Ported verbatim from the standalone Trendline indicator — same pivot
// detection, same channel construction, same padding. None of that
// indicator's gates (BOS, displacement, delta, sessions) come with it; this
// is the raw trendline geometry only, so a break here means exactly what a
// break means on that chart.
string grpTL = "9 · Trendlines"
bool showTrendlines = input.bool(true, "Draw Trendlines", group = grpTL)
int tlLen = input.int(5, "Pivot Period", minval = 2, maxval = 50, tooltip = "Pivot lookback used to detect the swings that form each trendline. Matches the Trendline indicator's Period setting — keep them equal or the two charts will disagree.", group = grpTL)
float tlSpace = input.float(2, "Channel Padding", minval = 0, step = 0.5, tooltip = "ATR-based buffer forming the channel width around each trendline. Matches the Trendline indicator's Padding.", group = grpTL)
int tlKeepHist = input.int(5, "Broken Trendlines Kept Per Side", minval = 0, maxval = 50, tooltip = "How many broken channels stay drawn on each side before the oldest are removed.", group = grpTL)
color tlBearColor = input.color(#ff2b00, "Bearish (descending) Channel", group = grpTL)
color tlBullColor = input.color(#0044ff, "Bullish (ascending) Channel", group = grpTL)

// ---------- 10 · CONFLUENCE ----------
string grpConf = "10 · Confluence"
int confLookback = input.int(5, "Trendline Break Already Happened (bars)", minval = 0, maxval = 50, tooltip = "How recently an opposing trendline can have broken and still count. A long needs a BEARISH channel broken upward within this many bars.", group = grpConf)
int confForward = input.int(2, "Wait For Trendline Break (bars)", minval = 0, maxval = 20, tooltip = "If the entry signal fires first, how many bars to keep waiting for the opposing trendline to break. The confluence marker prints on the break bar.", group = grpConf)
bool confMajorLevels = input.bool(true, "Major Level Exception", tooltip = "PDH, PDL, PWH and PWL are treated as strong enough on their own: an entry signal moving away from one of them counts as confluence with no trendline break required. TDO is deliberately excluded. Only levels currently drawn on the chart qualify.", group = grpConf)
int confMajorBars = input.int(5, "    ↳ Major Level Tap Window (bars)", minval = 1, maxval = 50, tooltip = "How recently price must have tapped the major level for the exception to apply.", group = grpConf)
color confColor = input.color(#D4AF37, "Confluence Marker Color", group = grpConf)

// ---------- 11 · SL / TP LINES ----------
string grpSlTp = "11 · SL / TP Lines"
bool showSlTp = input.bool(true, "Draw SL / TP on Signals", tooltip = "Stop at the entry candle's extreme plus a buffer; target at the nearest reference price in the trade's direction. R:R therefore varies per signal depending on where the next level sits.", group = grpSlTp)
float targetRR = input.float(1.0, "Target R:R", minval = 0.5, maxval = 10.0, step = 0.5, tooltip = "Fixed multiple of the stop distance — a ratio, not a level, so the target moves with however wide the stop turns out to be.\n\nThis replaces targeting the nearest reference price. A level-based target varied wildly depending on where the next shelf happened to sit, which meant the reward on a trade had little to do with the trade itself.", group = grpSlTp)
int slStructLen = input.int(5, "Structure Pivot Length", minval = 1, maxval = 30, tooltip = "Swing length used to find the structure the entry leg launched from — the last confirmed swing low below entry for a long, swing high above it for a short.\n\nThis replaces stopping beyond the level itself. Entry fires on the BOS candle, up to the full confirmation window after the tap, so by then price has moved away and the level sits well behind — protecting something price has already left. The structure the move began from is the real invalidation for a confirmed entry: if price takes out the low the leg launched from, the leg is over.\n\nHigher finds the origin of the larger move; lower finds the nearest minor swing, which sits closer to entry and gives a tighter stop.", group = grpSlTp)
int slBufTicks = input.int(4, "SL Buffer (ticks)", minval = 0, maxval = 100, tooltip = "Room beyond the stop reference. 8 ticks is 2 points on MNQ.\n\nThe reference itself depends on which path fired. TAP and RECLAIM entries stop beyond the LEVEL that produced them — that is the actual invalidation point, since the thesis is that the level holds. ACCUMULATION entries stop beyond the FAR SIDE OF THE RANGE, because there the thesis is that price has left the range for good; trading back through to the opposite edge means it has not.", group = grpSlTp)
color slColor = input.color(color.orange, "SL Color", group = grpSlTp)
color tpColor = input.color(color.blue, "TP Color", group = grpSlTp)

// ============================================================
//                     SETUP
// ============================================================
bool inSess1 = not na(time(timeframe.period, sess1, "America/New_York"))
bool inSess2 = not na(time(timeframe.period, sess2, "America/New_York"))
bool inSession = not useSess or inSess1 or inSess2

// ============================================================
//                 KEY LEVELS & VWAPS (display only)
// ============================================================
// Prior day/week values use the [1] offset so they reference the COMPLETED
// period — the still-forming current day is never used, which is what keeps
// these from repainting.
[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

// True Day Open: the 18:00 EST open, where the futures trading day begins.
bool isTdoStart = hour(time, "America/New_York") >= 18 and hour(time[1], "America/New_York") < 18
var float trueDayOpen = na
if isTdoStart or na(trueDayOpen)
    trueDayOpen := open

// TDO VWAP anchors at 18:00 EST and runs continuously. NY VWAP anchors at
// 09:30 EST; the isNySession gate on its plot() is what makes it disappear
// outside the session rather than persisting as a flat line.
get_anchored_vwap(cond) =>
    var float sumSrcVol = 0.0
    var float sumVol = 0.0
    if cond
        sumSrcVol := hlc3 * volume
        sumVol := volume
    else
        sumSrcVol += hlc3 * volume
        sumVol += volume
    sumVol > 0 ? sumSrcVol / sumVol : na

bool isNyStart = hour(time, "America/New_York") == 9 and minute(time, "America/New_York") == 30
bool isNySession = not na(time(timeframe.period, "0930-1600", "America/New_York"))

float tdoVwap = get_anchored_vwap(isTdoStart or barstate.isfirst)
float nyVwap = get_anchored_vwap(isNyStart or barstate.isfirst)

plot(showVwaps ? tdoVwap : na, title = "TDO VWAP", color = tdoVwapColor, linewidth = 2)
plot(showVwaps and isNySession ? nyVwap : na, title = "NY Session VWAP", color = nyVwapColor, linewidth = 2)

// ============================================================
//                     HTF PIVOT COLLECTION
// ============================================================
// Renders a timeframe input as a short readable tag for level labels, so the
// tag follows whatever the user actually selected rather than a hardcoded name.
f_tfLabel(string tf) =>
    tf == "15" ? "15m" : tf == "30" ? "30m" : tf == "60" ? "1H" : tf == "120" ? "2H" : tf == "240" ? "4H" : tf == "D" ? "1D" : tf == "W" ? "1W" : tf

f_htfPh() => ta.pivothigh(high, htfPivotLen, htfPivotLen)
f_htfPl() => ta.pivotlow(low, htfPivotLen, htfPivotLen)

[ph1, pl1, htfAtr] = request.security(syminfo.tickerid, tf1, [f_htfPh(), f_htfPl(), ta.atr(14)], lookahead = barmerge.lookahead_off)
[ph2, pl2] = request.security(syminfo.tickerid, tf2, [f_htfPh(), f_htfPl()], lookahead = barmerge.lookahead_off)
[ph3, pl3] = request.security(syminfo.tickerid, tf3, [f_htfPh(), f_htfPl()], lookahead = barmerge.lookahead_off)

// The volatility-scaled distances below come from TIMEFRAME 1's ATR, not the
// chart's. That is what keeps behaviour identical across chart timeframes —
// a chart ATR would make the same setting mean something different on 1m
// than on 15m from the same source data.
labelSize = switch labelSizeIn
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Large"  => size.large
    "Huge"   => size.huge
    => size.normal

float chartAtr = ta.atr(14)
float refAtr = nz(htfAtr, chartAtr)

// Structure reference for the stop — the swing the entry leg launched from.
// Evaluated unconditionally: ta.pivot* is stateful and skipping it on some
// bars corrupts the sequence.
var float slStructLow = na
var float slStructHigh = na
float slPl = ta.pivotlow(low, slStructLen, slStructLen)
float slPh = ta.pivothigh(high, slStructLen, slStructLen)
if not na(slPl)
    slStructLow := slPl
if not na(slPh)
    slStructHigh := slPh

// Merge distance is fixed in ticks, deliberately NOT derived from refAtr —
// this is the one distance here that is about chart precision rather than
// volatility, and keeping it independent means the level set stays stable
// regardless of what sits in Timeframe 1.
float band = math.max(mergeTicks * syminfo.mintick, syminfo.mintick)
// Touch tolerance is fixed in ticks and separate from the merge band above:
// merging wants a wide net so nearby pivots consolidate, while arming an
// entry should mean price genuinely arrived at the line.
float touchBand = touchTicks * syminfo.mintick
// These two DO scale with volatility — how far price must travel to count as
// a reaction, and how far past a level it may go and still be a tap, both
// depend on how much the market is moving.
float reactMove = math.max(refAtr * reactMoveAtr, syminfo.mintick)
float tapOvershoot = math.max(refAtr * tapOvershootAtr, 0.0)

// A level tracks its own reaction history and break/reclaim state. Each
// level is an independent state machine — several can be pending different
// things at the same time.
type Level
    float price
    bool  isRes
    int   createdTime    // ms timestamp, not bar index — see age check
    int   reactions      // completed reactions (entered band, then moved away)
    bool  inBand         // price currently inside the band
    int   enteredTime    // ms timestamp price entered the band this visit
    float extremeSince   // furthest price has travelled from the level this visit
    bool  broken         // price has traded decisively beyond the level
    int   brokenTime     // ms timestamp the break was registered
    int   anchorTfSec    // seconds of the timeframe whose pivot set the current price
    bool  farStructure   // a confirmed swing has formed beyond the level
    bool  approachAbove  // price was ABOVE this level when the current visit opened
    string tfTag

var array<Level> resLevels = array.new<Level>()
var array<Level> supLevels = array.new<Level>()

// ---- Key level drawing ----
// Placed after the Level arrays because the label-collision check reads
// them; the key level VALUES are still computed earlier, alongside the
// other market data.
var array<line> keyLines = array.new_line()
var array<label> keyLabels = array.new_label()

// Key labels occupy their own horizontal lane, well clear of the pivot level
// labels at 25 bars — so those two sets can never overlap whatever the
// prices happen to be. Within the lane, each key label that lands near one
// already drawn is pushed into the next column along, so PDH sitting beside
// PWH or TDO stacks sideways rather than on top.
//
// Prices already drawn this redraw. Cleared at the start of each pass.
var array<float> keyDrawnPrices = array.new<float>()

f_drawKey(float price, string txt, color col) =>
    if not na(price)
        keyLines.push(line.new(bar_index, price, bar_index + 1, price, xloc = xloc.bar_index, extend = extend.both, color = col, style = line.style_dotted, width = 2))
        // Column index = how many already-drawn key labels sit near this price.
        int col_i = 0
        float tol = keyLabelClearTicks * syminfo.mintick
        if keyDrawnPrices.size() > 0
            for i = 0 to keyDrawnPrices.size() - 1
                if math.abs(keyDrawnPrices.get(i) - price) <= tol
                    col_i += 1
        keyDrawnPrices.push(price)
        int xOff = keyLabelBaseBars + col_i * keyLabelShiftBars
        keyLabels.push(label.new(bar_index + xOff, price, txt, xloc = xloc.bar_index, color = color.new(color.white, 100), textcolor = col, style = label.style_label_down, size = labelSize))
    0

if barstate.islast and showKeyLevels
    keyDrawnPrices.clear()
    while keyLines.size() > 0
        line.delete(keyLines.pop())
    while keyLabels.size() > 0
        label.delete(keyLabels.pop())
    f_drawKey(pdh, "PDH", pdColor)
    f_drawKey(pdl, "PDL", pdColor)
    if includePw
        f_drawKey(pwh, "PWH", pwColor)
        f_drawKey(pwl, "PWL", pwColor)
    if includeTdo
        f_drawKey(trueDayOpen, "TDO", tdoLineColor)


// Drops the WEAKEST level when an array is over capacity, not the oldest.
// arr.shift() removed from the front, which is the oldest — but the oldest
// levels are the ones that have had the most time to accumulate reactions,
// so that systematically evicted the best-proven levels first. Fewest
// reactions goes, with the older one dropped on a tie.
f_evictWeakest(array<Level> arr, int cap) =>
    while arr.size() > cap
        int worstIdx = 0
        int worstRx = arr.get(0).reactions
        int worstTime = arr.get(0).createdTime
        for i = 1 to arr.size() - 1
            Level lv = arr.get(i)
            if lv.reactions < worstRx or (lv.reactions == worstRx and lv.createdTime < worstTime)
                worstIdx := i
                worstRx := lv.reactions
                worstTime := lv.createdTime
        arr.remove(worstIdx)
    0

// Folds a new pivot into an existing level.
//
// The level's price re-anchors to the HIGHER timeframe's pivot. Every source
// on multi-timeframe S/R agrees higher-timeframe levels are the more reliable
// ones, but the old code kept whichever price registered FIRST — so a 30m
// pivot could permanently own a level that a 4H pivot later confirmed.
f_mergeInto(Level lv, float price, string tag, int tfSec) =>
    if not str.contains(lv.tfTag, tag)
        lv.tfTag := lv.tfTag + "+" + tag
    if tfSec > lv.anchorTfSec
        lv.price := price
        lv.anchorTfSec := tfSec
    0

// Registers a new HTF pivot, searching BOTH arrays for something to merge
// into. Previously each array was searched in isolation, so a resistance
// pivot and a support pivot a couple of points apart stayed as two separate
// levels stacked on top of each other despite being well inside the merge
// tolerance. Price does not care which pivot type produced a level — if two
// are the same price, they are the same level.
f_register(float price, bool isRes, string tag, int tfSec) =>
    if not na(price)
        int hitRes = -1
        int hitSup = -1
        if resLevels.size() > 0
            for i = 0 to resLevels.size() - 1
                if math.abs(resLevels.get(i).price - price) <= band
                    hitRes := i
                    break
        if hitRes < 0 and supLevels.size() > 0
            for i = 0 to supLevels.size() - 1
                if math.abs(supLevels.get(i).price - price) <= band
                    hitSup := i
                    break

        if hitRes >= 0
            f_mergeInto(resLevels.get(hitRes), price, tag, tfSec)
        else if hitSup >= 0
            f_mergeInto(supLevels.get(hitSup), price, tag, tfSec)
        else if isRes
            resLevels.push(Level.new(price, true, time, 0, false, na, na, false, na, tfSec, false, false, tag))
        else
            supLevels.push(Level.new(price, false, time, 0, false, na, na, false, na, tfSec, false, false, tag))

        f_evictWeakest(resLevels, maxLevels)
        f_evictWeakest(supLevels, maxLevels)
    0

if useTf1
    f_register(ph1, true, f_tfLabel(tf1), timeframe.in_seconds(tf1))
    f_register(pl1, false, f_tfLabel(tf1), timeframe.in_seconds(tf1))
if useTf2
    f_register(ph2, true, f_tfLabel(tf2), timeframe.in_seconds(tf2))
    f_register(pl2, false, f_tfLabel(tf2), timeframe.in_seconds(tf2))
if useTf3
    f_register(ph3, true, f_tfLabel(tf3), timeframe.in_seconds(tf3))
    f_register(pl3, false, f_tfLabel(tf3), timeframe.in_seconds(tf3))

// ============================================================
//              FAR-SIDE STRUCTURE (for RECLAIM path)
// ============================================================
// Chart-timeframe pivots used to decide whether price built genuine structure
// beyond a broken level. This is the "significant break" test — a confirmed
// swing on the far side, not a candle-size threshold.
float structPh = ta.pivothigh(high, reclaimPivotLen, reclaimPivotLen)
float structPl = ta.pivotlow(low, reclaimPivotLen, reclaimPivotLen)

// ============================================================
//              LEVEL STATE MACHINE
// ============================================================
// Runs on confirmed bars only. Each level independently tracks: whether price
// is in its band, how far price has travelled since entering, whether a
// completed reaction should be counted, whether the level has been broken,
// and whether structure has formed beyond it.
int  tapDir = 0          // 1 = tapped support (long setup), -1 = tapped resistance
float tapLevel = na
string tapTag = ""
int  tapReactions = 0
int  reclaimDir = 0
float reclaimLevel = na
string reclaimTag = ""
int  reclaimReactions = 0

// Number of source timeframes that confirmed this level, read off the tag
// ("30m+1H+4H" = 3). Used for line weight.
f_tfCount(string tag) =>
    int n = 1
    if str.length(tag) > 0
        for i = 0 to str.length(tag) - 1
            if str.substring(tag, i, i + 1) == "+"
                n += 1
    n

// The isRes parameter is gone deliberately — levels can now flip polarity
// individually, so every decision below reads lv.isRes rather than an
// array-wide assumption. A resistance that became support lives in the
// resistance array but behaves as support.
f_updateLevels(array<Level> arr) =>
    int  firedTapDir = 0
    float firedTapLevel = na
    string firedTapTag = ""
    int firedTapReactions = 0
    float firedTapDist = na
    int  firedReclaimDir = 0
    float firedReclaimLevel = na
    string firedReclaimTag = ""
    int firedReclaimReactions = 0
    float firedReclaimDist = na

    if arr.size() > 0
        for i = arr.size() - 1 to 0
            Level lv = arr.get(i)

            // Age out stale levels. Pine has no `continue`, so the rest of
            // the per-level work sits inside the else branch instead.
            if time - lv.createdTime > levelMaxAgeDays * 86400000
                arr.remove(i)
            else
                bool touching = high >= lv.price - touchBand and low <= lv.price + touchBand

                // --- Reaction tracking ---
                // Two independent steps, deliberately NOT if/else-if: a visit
                // opens when price first touches, and the distance check then
                // runs on EVERY subsequent bar including ones still inside the
                // band. Chaining them as else-if (the earlier version) meant
                // nothing measured while price sat in the band, so visits never
                // resolved and counts stayed at zero on levels price was
                // visibly respecting.
                if touching and not lv.inBand
                    lv.inBand := true
                    lv.enteredTime := time
                    lv.extremeSince := 0.0
                    // Which side price came from, captured ONCE when the
                    // visit opens rather than read off the tapping candle.
                    // A candle can pierce a level from below and still close
                    // above it — reading the close would call that a long
                    // off a level price was approaching from underneath.
                    // The previous bar's close is where price actually was
                    // before it reached the level.
                    lv.approachAbove := nz(close[1], close) > lv.price

                if lv.inBand
                    // Measure how far price has got from the level in the
                    // direction the level should push it. Uses the bar's
                    // extreme rather than its close so a sharp rejection
                    // registers on the bar it happens.
                    //
                    // Direction matters: a resistance should push price DOWN,
                    // so only distance below it counts. Absolute distance would
                    // let a bar spiking straight through register as a
                    // reaction, which is the opposite of what happened.
                    float awayThisBar = lv.isRes ? math.max(lv.price - low, 0.0) : math.max(high - lv.price, 0.0)
                    lv.extremeSince := math.max(nz(lv.extremeSince), awayThisBar)
                    if lv.extremeSince >= reactMove
                        // Price got far enough away — visit counts.
                        lv.reactions += 1
                        lv.inBand := false
                        lv.enteredTime := na
                        lv.extremeSince := na
                    else if time - lv.enteredTime > reactMaxMins * 60000
                        // Hung around too long without resolving — discard.
                        lv.inBand := false
                        lv.enteredTime := na
                        lv.extremeSince := na

                bool qualified = lv.reactions >= minReactions and f_tfCount(lv.tfTag) >= minTimeframes

                // --- Break detection ---
                // A break needs price beyond the band by more than the allowed
                // tap overshoot; within that, it's still a tap.
                bool beyond = lv.isRes ? close > lv.price + touchBand + tapOvershoot : close < lv.price - touchBand - tapOvershoot
                if beyond and not lv.broken
                    lv.broken := true
                    lv.brokenTime := time
                    lv.farStructure := false

                // --- Far-side structure ---
                // The break only becomes "significant" once a confirmed swing
                // forms beyond the level. For a broken resistance that's a swing
                // LOW above it (price pulled back and held higher) — genuine
                // structure, not just a spike through.
                if lv.broken and not lv.farStructure
                    if lv.isRes and not na(structPl) and structPl > lv.price + touchBand
                        lv.farStructure := true
                    else if not lv.isRes and not na(structPh) and structPh < lv.price - touchBand
                        lv.farStructure := true

                // Reclaim expires if price never comes back in time.
                if lv.broken and time - lv.brokenTime > reclaimMaxMins * 60000
                    lv.broken := false
                    lv.farStructure := false

                // --- Entry arming ---
                if qualified and inSession
                    if lv.broken and lv.farStructure and useReclaimEntry
                        // RECLAIM: price returned to the level after building
                        // structure beyond it. Direction is the reversal back
                        // through the level.
                        // Nearest qualifying level wins. The old code simply
                        // overwrote on each iteration, so the LAST level
                        // processed won — index 0, the oldest in the array —
                        // which is arbitrary when several levels qualify at
                        // once. Price is interacting with the closest one.
                        float dRec = math.abs(close - lv.price)
                        if touching and (na(firedReclaimDist) or dRec < firedReclaimDist)
                            firedReclaimDist := dRec
                            // Same approach-side rule as the tap path: a
                            // broken resistance revisited from above becomes
                            // support and fires long, a broken support
                            // revisited from below becomes resistance and
                            // fires short.
                            firedReclaimDir := lv.approachAbove ? 1 : -1
                            firedReclaimLevel := lv.price
                            firedReclaimTag := lv.tfTag
                            firedReclaimReactions := lv.reactions
                            lv.broken := false
                            lv.farStructure := false
                            // The level has now proven it works from the other
                            // side — a resistance price broke above and came
                            // back to is acting as support. isRes drives
                            // reaction direction, break detection, far-side
                            // structure and the overshoot bounds, so this
                            // genuinely changes behaviour.
                            lv.isRes := not lv.isRes
                    else if not lv.broken and useTapEntry
                        // TAP: price reached the level without breaking it.
                        bool overshootOk = lv.isRes ? high <= lv.price + touchBand + tapOvershoot : low >= lv.price - touchBand - tapOvershoot

                        float dTap = math.abs(close - lv.price)
                        if touching and overshootOk and (na(firedTapDist) or dTap < firedTapDist)
                            firedTapDist := dTap
                            // Level BELOW price (approached from above) can
                            // only produce a long; level ABOVE price
                            // (approached from below) can only produce a
                            // short. Uses the side captured when the visit
                            // opened, so a candle that pierces the level and
                            // closes through it cannot flip the direction.
                            firedTapDir := lv.approachAbove ? 1 : -1
                            firedTapLevel := lv.price
                            firedTapTag := lv.tfTag
                            firedTapReactions := lv.reactions

                arr.set(i, lv)

    [firedTapDir, firedTapLevel, firedTapTag, firedTapReactions, firedTapDist, firedReclaimDir, firedReclaimLevel, firedReclaimTag, firedReclaimReactions, firedReclaimDist]

if barstate.isconfirmed
    [rTapDir, rTapLvl, rTapTag, rTapRx, rTapD, rRecDir, rRecLvl, rRecTag, rRecRx, rRecD] = f_updateLevels(resLevels)
    [sTapDir, sTapLvl, sTapTag, sTapRx, sTapD, sRecDir, sRecLvl, sRecTag, sRecRx, sRecD] = f_updateLevels(supLevels)

    // Pick between the two arrays by distance too. The old code always
    // preferred the resistance array when both fired, which is not a
    // deliberate choice — the level price is actually closest to is.
    bool takeResTap = rTapDir != 0 and (sTapDir == 0 or na(sTapD) or (not na(rTapD) and rTapD <= sTapD))
    tapDir := takeResTap ? rTapDir : sTapDir
    tapLevel := takeResTap ? rTapLvl : sTapLvl
    tapTag := takeResTap ? rTapTag : sTapTag
    tapReactions := takeResTap ? rTapRx : sTapRx

    bool takeResRec = rRecDir != 0 and (sRecDir == 0 or na(sRecD) or (not na(rRecD) and rRecD <= sRecD))
    reclaimDir := takeResRec ? rRecDir : sRecDir
    reclaimLevel := takeResRec ? rRecLvl : sRecLvl
    reclaimTag := takeResRec ? rRecTag : sRecTag
    reclaimReactions := takeResRec ? rRecRx : sRecRx

// ============================================================
//                     BOS CONFIRMATION
// ============================================================
float bosPh = ta.pivothigh(high, bosPivotLen, bosPivotLen)
float bosPl = ta.pivotlow(low, bosPivotLen, bosPivotLen)
var float lastBosPH = na
var float lastBosPL = na
// Bar the pivot actually formed on — ta.pivothigh confirms bosPivotLen bars
// late, so the true pivot bar is offset back by that amount. Needed to anchor
// the BOS line at the swing rather than at its confirmation bar.
var int lastBosPHBar = na
var int lastBosPLBar = na
if not na(bosPh)
    lastBosPH := bosPh
    lastBosPHBar := bar_index - bosPivotLen
if not na(bosPl)
    lastBosPL := bosPl
    lastBosPLBar := bar_index - bosPivotLen

float bosBuffer = bosBufferTicks * syminfo.mintick

// ta.crossover/crossunder are STATEFUL — each compares this bar against what
// it saw on the previous one. Calling them inside an `and` expression means
// short-circuiting can skip them on some bars, leaving that internal
// reference stale so the next execution compares against the wrong bar and
// can miss a genuine cross. Evaluated unconditionally here, with the na
// guard applied afterwards to the result.
bool bosCrossUp = ta.crossover(close, lastBosPH + bosBuffer)
bool bosCrossDn = ta.crossunder(close, lastBosPL - bosBuffer)
bool bosUp = not na(lastBosPH) and bosCrossUp
bool bosDn = not na(lastBosPL) and bosCrossDn


// Pending state — armed by either entry path, resolved by BOS or timeout.
var int pendLongTime = na
var int pendShortTime = na
var float pendLongLevel = na
var float pendShortLevel = na
var string pendLongTag = ""
var string pendShortTag = ""
var int pendLongRx = 0
var int pendShortRx = 0
var string pendLongType = ""
var string pendShortType = ""

// Arm cooldown, scoped per direction. Lives here rather than inside the
// level loop because Pine functions cannot reassign globals — which works
// out cleaner anyway, since this is exactly where an arm actually happens.
var int lastArmLongTime = na
var int lastArmShortTime = na
bool armLongOk = na(lastArmLongTime) or time - lastArmLongTime >= armCooldownMins * 60000
bool armShortOk = na(lastArmShortTime) or time - lastArmShortTime >= armCooldownMins * 60000

if (tapDir == 1 or reclaimDir == 1) and armLongOk
    lastArmLongTime := time
    pendLongTime := time
    pendLongLevel := reclaimDir == 1 ? reclaimLevel : tapLevel
    pendLongTag := reclaimDir == 1 ? reclaimTag : tapTag
    pendLongRx := reclaimDir == 1 ? reclaimReactions : tapReactions
    pendLongType := reclaimDir == 1 ? "RECLAIM" : "TAP"
if (tapDir == -1 or reclaimDir == -1) and armShortOk
    lastArmShortTime := time
    pendShortTime := time
    pendShortLevel := reclaimDir == -1 ? reclaimLevel : tapLevel
    pendShortTag := reclaimDir == -1 ? reclaimTag : tapTag
    pendShortRx := reclaimDir == -1 ? reclaimReactions : tapReactions
    pendShortType := reclaimDir == -1 ? "RECLAIM" : "TAP"

// Expire the pending entry once the BOS window has elapsed. After this a
// fresh tap of the level is required — the old setup does not linger.
if not na(pendLongTime) and time - pendLongTime > bosWindowMins * 60000
    pendLongTime := na
if not na(pendShortTime) and time - pendShortTime > bosWindowMins * 60000
    pendShortTime := na

// ============================================================
//                     ACCUMULATION
// ============================================================
// A third entry path. After a level tap, price often pulls back and goes
// sideways rather than resolving immediately. That range is tracked here and
// fires an entry when price closes outside it, in whichever direction it
// leaves — no direction bias, so a break back through the tapped level is
// continuation rather than a failure.
//
// Time-gated from the tap: the range must both form and break out within
// accMaxMins, otherwise it is discarded and price must tap the level again.
float accMaxWidth = math.max(refAtr * accMaxWidthAtr, syminfo.mintick)

var bool  accActive   = false   // range still forming
var bool  accFormed   = false   // range frozen, waiting for price to leave
var int   accStartBar = na
var int   accStartTime = na
var float accHigh     = na
var float accLow      = na
var float accLevel    = na
var string accTag     = ""
var int   accRx       = 0

// A tap or reclaim starts a fresh range, replacing any in progress — the most
// recent level interaction is the relevant one.
if tapDir != 0 or reclaimDir != 0
    accActive   := true
    accFormed   := false
    accStartBar := bar_index
    accStartTime := time
    accHigh     := high
    accLow      := low
    accLevel    := reclaimDir != 0 ? reclaimLevel : tapLevel
    accTag      := reclaimDir != 0 ? reclaimTag : tapTag
    accRx       := reclaimDir != 0 ? reclaimReactions : tapReactions

bool accBreakUp = false
bool accBreakDn = false

if barstate.isconfirmed
    // One overall deadline measured from the tap: the range must both form
    // and break within it. Checked before anything else so an unresolved
    // setup is discarded rather than lingering — after this a fresh tap is
    // required.
    bool accExpired = (accActive or accFormed) and not na(accStartTime) and time - accStartTime > accMaxMins * 60000
    if accExpired
        accActive := false
        accFormed := false

    if accActive
        float newHigh = math.max(accHigh, high)
        float newLow  = math.min(accLow, low)
        if newHigh - newLow > accMaxWidth
            // Spread too wide to be consolidation — price is moving.
            accActive := false
            accFormed := false
        else
            accHigh := newHigh
            accLow  := newLow
            if time - accStartTime >= accMinMins * 60000
                // Held long enough. Freeze the range and watch for a break.
                accActive := false
                accFormed := true
    else if accFormed
        if close > accHigh
            accBreakUp := true
            accFormed  := false
        else if close < accLow
            accBreakDn := true
            accFormed  := false

// Breakout volume. Applied to the ENTRY, not to the break itself — a weak
// break still ends the range (price did leave it), it just does not produce
// a trade. This is the accumulation path's equivalent of the tap path's
// speed requirement: tap entries prove themselves by rejecting fast,
// accumulation entries by breaking out on real participation.
float accAvgVol = ta.sma(volume, accVolLen)
bool accVolOk = not accRequireVolume or (not na(accAvgVol) and accAvgVol > 0 and volume >= accAvgVol * accVolMult)

// No direction gate — price leaving the range is the signal, either way.
bool accLongEntry  = useAccEntry and accBreakUp and accVolOk
bool accShortEntry = useAccEntry and accBreakDn and accVolOk

// Box for the most recent range only.
var box accBox = na
if showAccBox and (accActive or accFormed) and not na(accStartBar)
    if na(accBox)
        accBox := box.new(accStartBar, accHigh, bar_index, accLow, xloc = xloc.bar_index, border_color = color.new(accBoxColor, 40), border_width = 1, bgcolor = accBoxColor)
    else
        box.set_left(accBox, accStartBar)
        box.set_right(accBox, bar_index)
        box.set_top(accBox, accHigh)
        box.set_bottom(accBox, accLow)

var int lastLongBar = na
var int lastShortBar = na
bool longCooldownOk = na(lastLongBar) or bar_index - lastLongBar >= cooldownBars
bool shortCooldownOk = na(lastShortBar) or bar_index - lastShortBar >= cooldownBars

bool bosLongEntry  = not na(pendLongTime) and bosUp
bool bosShortEntry = not na(pendShortTime) and bosDn

bool longEntry = (bosLongEntry or accLongEntry) and inSession and longCooldownOk and barstate.isconfirmed
bool shortEntry = (bosShortEntry or accShortEntry) and inSession and shortCooldownOk and barstate.isconfirmed

// Which path fired, for the alert text.
string longPathType  = accLongEntry ? "ACCUMULATION" : pendLongType
string shortPathType = accShortEntry ? "ACCUMULATION" : pendShortType
float longPathLevel  = accLongEntry ? accLevel : pendLongLevel
float shortPathLevel = accShortEntry ? accLevel : pendShortLevel
string longPathTag   = accLongEntry ? accTag : pendLongTag
string shortPathTag  = accShortEntry ? accTag : pendShortTag
int longPathRx       = accLongEntry ? accRx : pendLongRx
int shortPathRx      = accShortEntry ? accRx : pendShortRx



// ============================================================
//                     TRENDLINES
// ============================================================
// Verbatim port of the Trendline indicator's channel engine. The pivot
// detection, the four-pivot validity test, the retroactive invalidation
// sweep and the ATR padding are all unchanged, so the channels drawn here
// are the same channels that indicator draws.
//
// ONE deliberate difference: the break test. The source fires on `low >`
// (up) and `high <` (down) — the whole candle clearing the channel. Here a
// break requires the CLOSE to finish beyond the channel's far edge, which is
// the definition being traded: a full shift to the other side rather than a
// probe that leaves a wick behind.
// Rise-over-run of a line, used to walk each channel edge forward one bar at
// a time. Not a built-in — ported from the Trendline indicator alongside the
// engine that depends on it.
method slope(line ln) =>
    float x = ln.get_x2() - ln.get_x1()
    float y = ln.get_y2() - ln.get_y1()
    x == 0 ? 0.0 : y / x

type tlStore
    float src
    int   n

type tlDraw
    line[] upln
    line[] dnln

var tlStore[] tlUpBin = array.new<tlStore>()
var tlStore[] tlDnBin = array.new<tlStore>()
var tlDraw    tlD     = tlDraw.new(array.new<line>(), array.new<line>())

var line[] tlHistUp = array.new<line>()
var line[] tlHistDn = array.new<line>()

float tlAtr200 = ta.atr(200)
float tlVolNow = math.min(tlAtr200 * 0.1, close * (0.1 / 100))

float tlPh = ta.pivothigh(high, tlLen, tlLen)
float tlPl = ta.pivotlow(low, tlLen, tlLen)

// Broken channels are retained per side so "kept per side" means what it says.
f_tlRetire(line a, line c, bool isUp) =>
    if tlKeepHist > 0
        if isUp
            tlHistUp.push(a)
            tlHistUp.push(c)
            while tlHistUp.size() > tlKeepHist * 2
                line.delete(tlHistUp.shift())
        else
            tlHistDn.push(a)
            tlHistDn.push(c)
            while tlHistDn.size() > tlKeepHist * 2
                line.delete(tlHistDn.shift())
    else
        line.delete(a)
        line.delete(c)
    0

var bool tlBroken = false
bool tlBreakUp = false
bool tlBreakDn = false

// ---- Bearish (descending) channel, built from pivot highs ----
if not na(tlPh)
    bool remove = false
    var bool valid = false

    tlUpBin.unshift(tlStore.new(high[tlLen], bar_index[tlLen]))
    if tlUpBin.size() > 1
        tlStore current = tlUpBin.get(0)
        tlStore before  = tlUpBin.get(1)
        if current.src < before.src
            if tlBroken
                valid := true
            else
                valid := false
                if tlUpBin.size() > 3
                    tlStore pastold = tlUpBin.get(3)
                    tlStore pastcur = tlUpBin.get(2)
                    tlStore now     = tlUpBin.get(1)
                    tlStore late    = tlUpBin.get(0)
                    if now.src < pastcur.src and now.src < pastold.src and late.src < pastcur.src and late.src < pastold.src
                        valid := true
                    else
                        valid := false
                else
                    valid := false

            if valid
                tlD.upln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src, y2 = current.src, color = showTrendlines ? tlBearColor : na))
                tlD.upln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src - tlVolNow * tlSpace, y2 = current.src - tlVolNow * tlSpace, color = showTrendlines ? tlBearColor : na))

                line ln = tlD.upln.get(1)
                for i = 0 to (bar_index - before.n)
                    float slope = ln.slope()
                    ln.set_x2(bar_index[i])
                    ln.set_y2(ln.get_y2() - slope)
                    if low[i] > ln.get_y2()
                        remove := true
                        break

                if remove
                    tlD.upln.get(0).delete()
                    tlD.upln.get(1).delete()
                    tlD.upln.clear()
                    tlUpBin.clear()
                    tlBroken := true
                else
                    tlD.upln.get(0).delete()
                    tlD.upln.get(1).delete()
                    tlD.upln.clear()
                    tlD.upln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src, y2 = current.src, color = showTrendlines ? tlBearColor : na))
                    tlD.upln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src - tlVolNow * tlSpace, y2 = current.src - tlVolNow * tlSpace, color = showTrendlines ? tlBearColor : na))
                    if showTrendlines
                        linefill.new(tlD.upln.get(0), tlD.upln.get(1), color = color.new(tlBearColor, 75))
                    tlUpBin.clear()
                    tlBroken := false

if tlD.upln.size() > 1
    line ubtm = tlD.upln.get(0)
    line utop = tlD.upln.get(1)

    // Far edge of a descending channel approached from below is its TOP.
    if close > utop.get_y2()
        f_tlRetire(ubtm, utop, true)
        tlD.upln.clear()
        tlBroken := true
        tlUpBin.clear()
        tlBreakUp := true

    if tlD.upln.size() > 1
        float slup = utop.slope()
        float sldn = ubtm.slope()
        utop.set_x2(bar_index)
        utop.set_y2(utop.get_y2() + slup)
        ubtm.set_x2(bar_index)
        ubtm.set_y2(ubtm.get_y2() + sldn)

// ---- Bullish (ascending) channel, built from pivot lows ----
if not na(tlPl)
    bool remove = false
    var bool valid = false

    tlDnBin.unshift(tlStore.new(low[tlLen], bar_index[tlLen]))
    if tlDnBin.size() > 1
        tlStore current = tlDnBin.get(0)
        tlStore before  = tlDnBin.get(1)
        if current.src > before.src
            if tlBroken
                valid := true
            else
                valid := false
                if tlDnBin.size() > 3
                    tlStore pastold = tlDnBin.get(3)
                    tlStore pastcur = tlDnBin.get(2)
                    tlStore now     = tlDnBin.get(1)
                    tlStore late    = tlDnBin.get(0)
                    if now.src > pastcur.src and now.src > pastold.src and late.src > pastcur.src and late.src > pastold.src
                        valid := true
                    else
                        valid := false
                else
                    valid := false

            if valid
                tlD.dnln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src, y2 = current.src, color = showTrendlines ? tlBullColor : na))
                tlD.dnln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src + tlVolNow * tlSpace, y2 = current.src + tlVolNow * tlSpace, color = showTrendlines ? tlBullColor : na))

                line ln = tlD.dnln.get(1)
                for i = 0 to (bar_index - before.n)
                    float slope = ln.slope()
                    ln.set_x2(bar_index[i])
                    ln.set_y2(ln.get_y2() - slope)
                    if high[i] < ln.get_y2()
                        remove := true
                        break

                if remove
                    tlD.dnln.get(0).delete()
                    tlD.dnln.get(1).delete()
                    tlD.dnln.clear()
                    tlDnBin.clear()
                    tlBroken := true
                else
                    tlD.dnln.get(0).delete()
                    tlD.dnln.get(1).delete()
                    tlD.dnln.clear()
                    tlD.dnln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src, y2 = current.src, color = showTrendlines ? tlBullColor : na))
                    tlD.dnln.unshift(line.new(x1 = before.n, x2 = current.n, y1 = before.src + tlVolNow * tlSpace, y2 = current.src + tlVolNow * tlSpace, color = showTrendlines ? tlBullColor : na))
                    if showTrendlines
                        linefill.new(tlD.dnln.get(0), tlD.dnln.get(1), color = color.new(tlBullColor, 75))
                    tlDnBin.clear()
                    tlBroken := false

if tlD.dnln.size() > 1
    line dupper = tlD.dnln.get(0)
    line dbase  = tlD.dnln.get(1)

    // Far edge of an ascending channel approached from above is its BASE —
    // index 1 here, since the offset line was unshifted on top of it. The
    // source tests index 0 on this side, which is the near edge; using the
    // far edge keeps both directions symmetrical.
    if close < dbase.get_y2()
        f_tlRetire(dupper, dbase, false)
        tlD.dnln.clear()
        tlBroken := true
        tlDnBin.clear()
        tlBreakDn := true

    if tlD.dnln.size() > 1
        float slup = dbase.slope()
        float sldn = dupper.slope()
        dbase.set_x2(bar_index)
        dbase.set_y2(dbase.get_y2() + slup)
        dupper.set_x2(bar_index)
        dupper.set_y2(dupper.get_y2() + sldn)

// ============================================================
//                     SL / TP
// ============================================================
// One trade's levels on the chart at a time. A new signal replaces the
// previous drawing rather than adding to it, so what is displayed is always
// the trade currently in play.
var int   tDir = 0
var float tSl = na
var float tTp = na
var line  tSlLine = na
var line  tTpLine = na
var label tSlLab = na
var label tTpLab = na

// Extend the live trade and clear it once either side is reached. Runs before
// any new signal can draw, so a trade resolving on the same bar a new one
// fires does not wipe the new levels.
if tDir != 0
    bool tDone = tDir == 1 ? (low <= tSl or high >= tTp) : (high >= tSl or low <= tTp)
    if tDone
        line.delete(tSlLine)
        line.delete(tTpLine)
        label.delete(tSlLab)
        label.delete(tTpLab)
        tDir := 0
    else
        line.set_x2(tSlLine, bar_index + 5)
        line.set_x2(tTpLine, bar_index + 5)
        label.set_x(tSlLab, bar_index + 5)
        label.set_x(tTpLab, bar_index + 5)




// Every signal on a bar contributes to ONE message, sent by a single alert()
// call at the end of the bar.
//
// This is structural, not stylistic. alert.freq_all fires on every execution
// that reaches the call and a bar gets executed more than once, so the same
// signal alerted twice. A per-bar guard variable cannot fix that either:
// Pine rolls var values back on each realtime tick, so the guard resets
// before it can block anything.
//
// One call per bar makes freq_once_per_bar exact — and the reason freq_all
// was needed in the first place (a long and a short both firing on one bar
// competing for separate calls) disappears, because they now share a message
// instead of competing.
string alertMsg = ""

// ============================================================
//                     ENTRY MARKERS
// ============================================================
// Markers and BOS reference lines only — no SL/TP calculation or plotting.
// Risk levels are placed manually.
var array<line> bosLines = array.new<line>()


// Dotted line from the reference that was broken across to the signal bar,
// tagged at its midpoint with the method that produced it. Capped alongside
// the entry markers so the two stay in step — an entry still on the chart
// keeps its reference.
var array<label> bosLabels = array.new<label>()

f_bosLine(float lvl, int fromBar, color col, bool isLong) =>
    if showBosLine and not na(lvl) and not na(fromBar)
        bosLines.push(line.new(fromBar, lvl, bar_index, lvl, xloc = xloc.bar_index, color = col, style = line.style_dotted, width = 1))
        // Midpoint of the line, so the tag sits over the span rather than
        // crowding either end.
        int midBar = math.ceil(math.avg(fromBar, bar_index))
        bosLabels.push(label.new(midBar, lvl, "BOS", xloc = xloc.bar_index, yloc = yloc.price, style = isLong ? label.style_label_up : label.style_label_down, color = color.new(color.white, 100), textcolor = col, size = size.tiny))
        while bosLines.size() > maxEntryLabels
            line.delete(bosLines.shift())
        while bosLabels.size() > maxEntryLabels
            label.delete(bosLabels.shift())
    0


float slBuf = slBufTicks * syminfo.mintick

if longEntry
    lastLongBar := bar_index
    // No line on an accumulation entry — there is no reference behind it.
    if bosLongEntry
        f_bosLine(lastBosPH, lastBosPHBar, longColor, true)
    pendLongTime := na

if shortEntry
    lastShortBar := bar_index
    if bosShortEntry
        f_bosLine(lastBosPL, lastBosPLBar, shortColor, false)
    pendShortTime := na


// ============================================================
//                     CONFLUENCE
// ============================================================
// Two independent routes to a confirmed entry.
//
// 1. Trendline — a pivot entry paired with the OPPOSING channel breaking:
//    a long needs the bearish (descending) channel broken upward. The pairing
//    is allowed a window in both directions, because in practice either can
//    lead: the break may already have happened, or the entry may fire first
//    and the break follow a bar or two later.
//
// 2. Major level — PDH / PDL / PWH / PWL are treated as strong enough alone.
//    An entry moving AWAY from one of them qualifies with no trendline
//    involved. TDO is excluded; it is an open price, not a level price has
//    repeatedly respected.
var int lastTlUpBar = na
var int lastTlDnBar = na
if tlBreakUp
    lastTlUpBar := bar_index
if tlBreakDn
    lastTlDnBar := bar_index

bool tlUpRecent = not na(lastTlUpBar) and bar_index - lastTlUpBar <= confLookback
bool tlDnRecent = not na(lastTlDnBar) and bar_index - lastTlDnBar <= confLookback

// Entry fired without a break yet — hold it open for confForward bars.
var int waitLongBar = na
var int waitShortBar = na
// Major level proximity. Only levels actually drawn on the chart count, so
// the exception can never fire off something invisible.
// Same tolerance AND the same test as the pivot levels: the bar's range
// against the band, not its close. Testing the close would miss a wick that
// reached the level and closed away from it — which is precisely the
// rejection this exception exists to catch.
float majTouchBand = touchTicks * syminfo.mintick
f_nearMajor(float lvl) =>
    not na(lvl) and high >= lvl - majTouchBand and low <= lvl + majTouchBand

bool nearPdh = showKeyLevels and f_nearMajor(pdh)
bool nearPdl = showKeyLevels and f_nearMajor(pdl)
bool nearPwh = showKeyLevels and includePw and f_nearMajor(pwh)
bool nearPwl = showKeyLevels and includePw and f_nearMajor(pwl)
bool nearMajor = nearPdh or nearPdl or nearPwh or nearPwl

var int lastMajorBar = na
var float lastMajorPx = na
if nearMajor
    lastMajorBar := bar_index
    lastMajorPx := nearPdh ? pdh : nearPdl ? pdl : nearPwh ? pwh : pwl

bool majorRecent = not na(lastMajorBar) and bar_index - lastMajorBar <= confMajorBars
// Away from the level: a long needs price above it, a short below.
bool majorLongOk = confMajorLevels and majorRecent and not na(lastMajorPx) and close > lastMajorPx
bool majorShortOk = confMajorLevels and majorRecent and not na(lastMajorPx) and close < lastMajorPx

// Only wait if the entry did not already confirm — otherwise a major-level
// entry would still open a wait, and a trendline break a bar later would
// print a second marker for the same signal.
if longEntry and not tlUpRecent and not majorLongOk
    waitLongBar := bar_index
if shortEntry and not tlDnRecent and not majorShortOk
    waitShortBar := bar_index
if not na(waitLongBar) and bar_index - waitLongBar > confForward
    waitLongBar := na
if not na(waitShortBar) and bar_index - waitShortBar > confForward
    waitShortBar := na


// Both routes require a CLOSED bar. The first already did, via longEntry.
// The second did not: tlBreakUp comes from the trendline engine, which runs
// on every tick, so an intrabar close through a channel could fire the
// forward-window confluence mid-candle and then again at the bar's close.
// Pine rolls var values back on each realtime tick, so a per-bar guard
// cannot catch that — the condition itself has to be bar-close only.
bool confLong = barstate.isconfirmed and ((longEntry and (tlUpRecent or majorLongOk)) or (not na(waitLongBar) and tlBreakUp))
bool confShort = barstate.isconfirmed and ((shortEntry and (tlDnRecent or majorShortOk)) or (not na(waitShortBar) and tlBreakDn))

var array<label> confLabels = array.new<label>()

f_confLabel(bool isLong, float y, string src) =>
    label lb = label.new(bar_index, y, isLong ? "▲▲" : "▼▼", yloc = isLong ? yloc.belowbar : yloc.abovebar, style = isLong ? label.style_label_up : label.style_label_down, color = confColor, textcolor = color.black, size = size.small, tooltip = src)
    confLabels.push(lb)
    while confLabels.size() > maxEntryLabels
        label.delete(confLabels.shift())
    0

if confLong
    f_confLabel(true, low, majorLongOk and not tlUpRecent ? "Major level" : "Trendline break")
    alertMsg := alertMsg + (alertMsg == "" ? "" : "\n") + syminfo.ticker + " — CONFLUENCE LONG" + (majorLongOk and not tlUpRecent ? " | major level" : " | trendline break")
    if showSlTp
        // Stop beyond the structure the entry leg launched from, for every
        // path including accumulation. Falls back to the path's own reference
        // only when no usable structure exists — usable meaning on the
        // correct side of entry, since a swing low above the close is no use
        // as a long's stop.
        float fbL = accLongEntry and not na(accLow) ? accLow : (not na(longPathLevel) ? longPathLevel : low)
        float refL = (not na(slStructLow) and slStructLow < close) ? slStructLow : fbL
        float slLc2 = math.min(refL, low) - slBuf
        float riskLc2 = close - slLc2
        if riskLc2 > 0
            float tpLc2 = close + riskLc2 * targetRR
            if not na(tpLc2)
                // Drawn inline rather than in a function: Pine cannot
                // reassign globals from inside one, and the single-slot
                // tracker above is global state.
                line.delete(tSlLine)
                line.delete(tTpLine)
                label.delete(tSlLab)
                label.delete(tTpLab)
                float rrL2 = (tpLc2 - close) / riskLc2
                tSlLine := line.new(bar_index, slLc2, bar_index + 5, slLc2, xloc = xloc.bar_index, color = slColor, style = line.style_solid, width = 2)
                tTpLine := line.new(bar_index, tpLc2, bar_index + 5, tpLc2, xloc = xloc.bar_index, color = tpColor, style = line.style_solid, width = 2)
                tSlLab := label.new(bar_index + 5, slLc2, "SL " + str.tostring(slLc2, format.mintick), xloc = xloc.bar_index, color = color.new(slColor, 0), textcolor = color.white, style = label.style_label_left, size = size.small)
                tTpLab := label.new(bar_index + 5, tpLc2, "TP " + str.tostring(tpLc2, format.mintick) + "  (" + str.tostring(rrL2, "#.#") + "R)", xloc = xloc.bar_index, color = color.new(tpColor, 0), textcolor = color.white, style = label.style_label_left, size = size.small)
                tDir := 1
                tSl := slLc2
                tTp := tpLc2
    waitLongBar := na

if confShort
    f_confLabel(false, high, majorShortOk and not tlDnRecent ? "Major level" : "Trendline break")
    alertMsg := alertMsg + (alertMsg == "" ? "" : "\n") + syminfo.ticker + " — CONFLUENCE SHORT" + (majorShortOk and not tlDnRecent ? " | major level" : " | trendline break")
    if showSlTp
        float fbS = accShortEntry and not na(accHigh) ? accHigh : (not na(shortPathLevel) ? shortPathLevel : high)
        float refS = (not na(slStructHigh) and slStructHigh > close) ? slStructHigh : fbS
        float slSc2 = math.max(refS, high) + slBuf
        float riskSc2 = slSc2 - close
        if riskSc2 > 0
            float tpSc2 = close - riskSc2 * targetRR
            if not na(tpSc2)
                line.delete(tSlLine)
                line.delete(tTpLine)
                label.delete(tSlLab)
                label.delete(tTpLab)
                float rrS2 = (close - tpSc2) / riskSc2
                tSlLine := line.new(bar_index, slSc2, bar_index + 5, slSc2, xloc = xloc.bar_index, color = slColor, style = line.style_solid, width = 2)
                tTpLine := line.new(bar_index, tpSc2, bar_index + 5, tpSc2, xloc = xloc.bar_index, color = tpColor, style = line.style_solid, width = 2)
                tSlLab := label.new(bar_index + 5, slSc2, "SL " + str.tostring(slSc2, format.mintick), xloc = xloc.bar_index, color = color.new(slColor, 0), textcolor = color.white, style = label.style_label_left, size = size.small)
                tTpLab := label.new(bar_index + 5, tpSc2, "TP " + str.tostring(tpSc2, format.mintick) + "  (" + str.tostring(rrS2, "#.#") + "R)", xloc = xloc.bar_index, color = color.new(tpColor, 0), textcolor = color.white, style = label.style_label_left, size = size.small)
                tDir := -1
                tSl := slSc2
                tTp := tpSc2
    waitShortBar := na



// ============================================================
//                     LEVEL DISPLAY
// ============================================================
// Draws only the closest N levels above and below price, chosen purely by
// distance rather than by source timeframe — a nearer lower-timeframe level
// is more immediately relevant than a distant higher-timeframe one.
// Selection is display-only: every level still tracks reactions and can
// still arm entries whether or not it is drawn.
var array<line> lvlLines = array.new_line()
var array<label> lvlLabels = array.new_label()
var array<box> lvlBoxes = array.new_box()

// Colour follows the level's CURRENT polarity, not the array it lives in —
// red for resistance, green for support, per its CURRENT polarity.
f_levelColor(Level lv) =>
    lv.isRes ? resColor : supColor

f_drawOne(Level lv, bool qualified) =>
    // Unqualified levels get their own colour rather than a faded version of
    // the qualified one, so "potential" reads as a different category at a
    // glance rather than just a dimmer version of the same thing.
    color base = qualified ? f_levelColor(lv) : unqualColor
    color c = base
    if levelDisplay == "Zone box"
        // The box spans exactly the tolerance band the logic uses, so what's
        // drawn matches what counts as price reaching the level. Anchored to
        // a wide bar range rather than extended, since boxes cannot extend.
        lvlBoxes.push(box.new(bar_index - 5000, lv.price + touchBand, bar_index + 500, lv.price - touchBand, xloc = xloc.bar_index, border_color = color.new(base, qualified ? 40 : 80), border_width = 1, bgcolor = color.new(base, qualified ? 88 : 94)))
    // extend.both keeps the level visible across the whole chart regardless
    // of when the swing that created it formed — a level is a price that
    // stays relevant, not a segment tied to its origin bar.
    // Multi-timeframe levels draw thicker: 1 timeframe = 2, 2 = 3, 3+ = 4.
    int tfN = weightByTimeframes ? f_tfCount(lv.tfTag) : 1
    int lw = qualified ? math.min(2 + (tfN - 1), 4) : 1
    lvlLines.push(line.new(bar_index, lv.price, bar_index + 1, lv.price, xloc = xloc.bar_index, extend = extend.both, color = c, style = qualified ? line.style_solid : line.style_dotted, width = lw))
    // label.style_label_down anchors from the top, putting the label body
    // ABOVE the line. Stacked onto two lines — identity on top, price below.
    // Unqualified levels are labelled "Potential" rather than by timeframe,
    // since what matters about them is that they haven't earned a reaction
    // yet, not where they came from.
    string idLine = qualified ? lv.tfTag : "Potential " + lv.tfTag
    string txt = idLine + "\n" + str.tostring(lv.price, format.mintick)
    lvlLabels.push(label.new(bar_index + 15, lv.price, txt, xloc = xloc.bar_index, color = color.new(color.white, 100), textcolor = c, style = label.style_label_down, size = labelSize))
    0

// Picks the N nearest levels ABOVE price and N nearest BELOW price.
//
// Searches BOTH arrays together rather than N from each. A level keeps the
// array it was created in and never moves, so a resistance price has since
// risen above still lives in resLevels while
// sitting below price. Drawing N from each array therefore does NOT give N
// per side of price — it can put everything on one side. Selecting by actual
// position relative to price is what "2 per side" has to mean to be useful.
f_drawSide(bool wantAbove, int count, bool qualifiedOnly) =>
    array<int> usedRes = array.new<int>()
    array<int> usedSup = array.new<int>()
    for pick = 0 to count - 1
        float bestDist = na
        int bestIdx = na
        bool bestIsRes = true

        if resLevels.size() > 0
            for i = 0 to resLevels.size() - 1
                bool taken = false
                if usedRes.size() > 0
                    for u = 0 to usedRes.size() - 1
                        if usedRes.get(u) == i
                            taken := true
                            break
                if not taken
                    Level lv = resLevels.get(i)
                    bool qual = lv.reactions >= minReactions and f_tfCount(lv.tfTag) >= minTimeframes
                    bool passQual = qualifiedOnly ? qual : not qual
                    bool rightSide = wantAbove ? lv.price >= close : lv.price < close
                    if passQual and rightSide
                        float d = math.abs(lv.price - close)
                        if na(bestDist) or d < bestDist
                            bestDist := d
                            bestIdx := i
                            bestIsRes := true

        if supLevels.size() > 0
            for i = 0 to supLevels.size() - 1
                bool taken = false
                if usedSup.size() > 0
                    for u = 0 to usedSup.size() - 1
                        if usedSup.get(u) == i
                            taken := true
                            break
                if not taken
                    Level lv = supLevels.get(i)
                    bool qual = lv.reactions >= minReactions and f_tfCount(lv.tfTag) >= minTimeframes
                    bool passQual = qualifiedOnly ? qual : not qual
                    bool rightSide = wantAbove ? lv.price >= close : lv.price < close
                    if passQual and rightSide
                        float d = math.abs(lv.price - close)
                        if na(bestDist) or d < bestDist
                            bestDist := d
                            bestIdx := i
                            bestIsRes := false

        if not na(bestIdx)
            if bestIsRes
                usedRes.push(bestIdx)
                f_drawOne(resLevels.get(bestIdx), qualifiedOnly)
            else
                usedSup.push(bestIdx)
                f_drawOne(supLevels.get(bestIdx), qualifiedOnly)
    0

if barstate.islast
    while lvlLines.size() > 0
        line.delete(lvlLines.pop())
    while lvlLabels.size() > 0
        label.delete(lvlLabels.pop())
    while lvlBoxes.size() > 0
        box.delete(lvlBoxes.pop())

    // Qualified and potential are drawn independently, so you always get the
    // configured count of each per side rather than them competing.
    if showLevels
        f_drawSide(true, visiblePerSide, true)
        f_drawSide(false, visiblePerSide, true)
    if showUnqualified
        f_drawSide(true, visiblePerSide, false)
        f_drawSide(false, visiblePerSide, false)

// ============================================================
//                     ALERT DISPATCH
// ============================================================
// One call, once per bar, carrying whatever fired. Gated on a closed bar so
// it cannot dispatch mid-candle.
if barstate.isconfirmed and alertMsg != ""
    alert(alertMsg, alert.freq_once_per_bar)

// Alerts run entirely through the single alert() call above — one setup covers every entry,
// both directions and all three paths, with the direction and path named in
// the message itself.
//
// The separate alertcondition() entries were removed deliberately. They
// appeared as distinct LONG and SHORT items in the condition dropdown, so
// picking one silently gave that direction only — a long-only alert would
// never fire on a short no matter how correct the code was.
//
// Set up with: Add Alert -> Condition -> this indicator -> "Alert() function
// calls only".
````
