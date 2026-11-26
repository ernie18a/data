# Asian Range Liquidity Sweep - Kill Zone Reversal

- url: https://www.tradingview.com/script/1ZcOyqs5-Asian-Range-Liquidity-Sweep-Kill-Zone-Reversal/
- type: indicator
- pine_id: PUB;4d8d017301ce46e9b1ce2ae649dd4919
- version: 1.0

## Description

ASIAN RANGE LIQUIDITY SWEEP — the complete ICT Asian Range liquidity model in one indicator

The Asia session builds a small, quiet range. London opens, runs the stops sitting above or below that range, and then walks the price the other way. That single move is one of the most repeatable things in FX, and this indicator is the full rule set for it: the range, the liquidity raid, the higher-timeframe point of interest that makes the raid tradeable, the entry, the stop, the targets — and, just as important, the days on which the raid will NOT happen.

Everything is drawn in New York time, the way the model is defined.


━━━ WHAT IT DOES ━━━

① ASIAN RANGE (20:00 – 00:00 New York)
A time based range, not a structural one. The box, its high, its low and its 50 % are projected forward into the whole trading day. The high is buy side liquidity, the low is sell side liquidity. Direction is mechanical and never inverts: above the range this model only sells, below the range it only buys.

② HIGHER TIMEFRAME POI ENGINE — the filter that decides everything
A raid of the Asian high on its own is, most of the time, a trap. The raid only becomes high probability when it lands inside a higher-timeframe point of interest. The indicator scans three timeframes at once (15m / 1h / 4h by default) for
· Fair Value Gaps
· Order Blocks
· Breaker Blocks (a demand block that price closed through and that now acts as resistance)
· Inverse Fair Value Gaps (a bullish gap that got closed through and flipped bearish)
Every zone is anchored to the exact candles that built it, is extended while it is alive, and is dropped once it is used up or once it sits too far from the daily range to matter. On top of that, the higher-timeframe structure itself has to agree: bearish structure for shorts, bullish for longs.

③ LONDON KILL ZONE (02:00 – 05:00, optional 01:30 start) — Trade 1
Between those hours the indicator waits for price to raid the Asian high (or low) INTO one of those zones. A raid is not even accepted as valid until price has traded back into a fair value gap. Then it waits for a lower-timeframe confirmation and enters at a point of interest — never at market:
· MSS + FVG — market structure shift, entry on the retracement into the gap
· CISD — change in state of delivery, entry back at the CISD level itself
· FVG tap — proximal edge on small gaps, 50 % on big ones
· HIDDEN ORDER BLOCK — the opposite-colour candle trapped between two same-direction fair value gaps. The block almost nobody marks, and the sharpest entry in the whole model
That list is a risk ladder: 1m MSS+FVG is the most aggressive and pays the most, 15m FVG is the safest, wins most often and pays the least. Pick the timeframe you actually want to trade and run the indicator there.
Stop goes on the protective structure that belongs to the entry zone. Target 1 is always the opposite side of the Asian range. Target 2 extends to the next inducement swing — the draw for the day.

④ NEW YORK KILL ZONE (07:00 – 10:00) — Trade 2, the continuation
When the London raid then breaks the OPPOSITE side of the Asian range with displacement, the London extreme is very likely the high or the low of the day. The indicator draws the optimal trade entry fibonacci over that impulse — 0.5 / 0.618 / 0.705 / 0.79 — and takes the continuation from the retracement into it, with the stop beyond 0.79 or 1.0. The setup is strongest when the origin zone was a 4h zone, because the whole day is then a 4h market-maker model running internal to external. If the draw on liquidity was already reached before New York opens, the day is flagged as low probability and skipped.

⑤ THE NO-SWEEP FILTERS — the part almost nobody explains
Two situations mean the raid you are waiting for will never come:
· HTF POI ALREADY TAPPED IN ASIA — price worked into the zone during the Asian session and then broke structure against the range. The Asian high is now protected. The indicator says so on the chart and points you at the fallbacks instead: the 50 % of the range, an internal range high (trend line liquidity), or a fair value gap built inside the Asian session.
· STRONG HIGH / STRONG LOW INSIDE THE RANGE — a sweep immediately followed by a break of structure. That extreme is protected. What looks like equal highs later on is a rejection-block reversal, not a raid. Wait for the sweep and you miss the trade.

⑥ NEWS FILTER
High-impact US news in the New York session turns London into a range or a one-way run with no reversal. Pine cannot read a news feed, so paste the dates and those days are skipped.


━━━ WHY EVERY SIGNAL EXPLAINS ITSELF ━━━

Hover any signal pill and you get the full reasoning, not a label:
the range and its size, the exact price the liquidity was raided at, which point of interest it landed in, what the higher timeframe structure was doing, which confirmation fired, whether the raid was validated by a fair value gap, plus entry, stop, both targets, risk in pips, reward in pips and the R multiple.

Setups that were found but rejected are explained too. A "NO TRADE" tag tells you the raid, the zone and the confirmation were all there but the reward did not pay for the stop — so you learn the filter instead of wondering why nothing fired.

Every zone, every structure event, the range lines, the OTE levels and both education cards carry the same kind of tooltip. There is a HOW TO READ THIS card and an honest BEFORE YOU TRADE THIS card on the chart.


━━━ COCKPIT PANEL ━━━

Live session state, symbol, chart timeframe, higher-timeframe bias, the full Asian range with a PROTECTED / OPEN flag on each side, an eight-step checklist that fills in as the setup builds, the open position with stop and target, a large status line, a rough win / loss / break-even tracker and the timestamp of the last signal.


━━━ ALERTS AND AUTOMATION ━━━

Every event fires a clean JSON payload ready for a webhook — entry, stop, both targets, the range boundaries, the point of interest that produced the signal, symbol, exchange, timeframe, volume and an optional account field. Events: ENTRY, TP1, SL, BE, SWEEP, RANGE. Five plain-language alertconditions are included as well for anybody who just wants a notification.


━━━ SETTINGS WORTH KNOWING ━━━

· Sessions are fully configurable if your broker feed needs a different reference
· Turn individual POI types and POI timeframes on and off
· Choose one confirmation model or let it take the first valid trigger
· Four stop modes, two-target management, break-even at a chosen R
· Full chart theme with navy background, mint / red candles and session shading — or switch it off and keep your own


━━━ HONEST NOTES ━━━

This model is mechanical up to the trigger. Direction is fixed and never inverts, the windows are fixed, the filters are fixed — but the final judgement, is this really the high of the session, stays discretionary. Anybody telling you a setup is 100 % mechanical is selling you something.

Expect zero to four setups a day across two pairs, roughly 20 pips average per trade, and losing days. Judge it weekly and monthly, never daily. The safest entry model fires rarely by design; the aggressive ones fire more and stop out more.

The win / loss counter in the panel is a rough on-chart tracker that assumes a fill at the marked price and resolves target before stop within the same bar. It is not a backtest and it is not a performance claim.

This indicator is a study tool. It is not financial advice.


━━━ CREDIT ━━━

The rule set follows the well-known ICT Asian-sweep model as it is taught publicly in the ICT community. The implementation, the point-of-interest engine, the no-sweep filters, the panel and the design are original work.

Open source — read it, change it, learn from it.


WHY THESE PARTS BELONG TOGETHER

The session range, the higher-timeframe point of interest and the lower-timeframe confirmation form
a single filter chain, and the model does not work with any link missing. The range supplies the
liquidity pool that is going to be raided, the higher-timeframe zone decides whether that raid is a
reversal or a trap, and the lower-timeframe trigger decides when. A raid without a zone is noise,
a zone without a raid has nothing to react to, and both without a trigger have no entry.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════════════════════
//  ASIA SESSION SWEEP PRO
//  ICT Asian Range liquidity-raid model
//  Asian Range 20:00-00:00 NY  ->  London kill zone sweep INTO a higher-timeframe POI
//  ->  reversal to the opposite side of the range  ->  New York OTE continuation
//  Open source. Educational study tool - not financial advice.
// ═══════════════════════════════════════════════════════════════════════════════════════════
indicator("Asian Range Liquidity Sweep", "ASIAN RANGE SWEEP", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 1500)

var string G_SES = "① SESSIONS  ·  Asian Range & Kill Zones"
var string G_POI = "② HTF POI ENGINE  ·  the high-probability filter"
var string G_ENT = "③ LTF ENTRY MODEL  ·  the risk ladder"
var string G_TRD = "④ TRADE 1  ·  London Asian-Sweep Reversal"
var string G_CON = "⑤ TRADE 2  ·  New York OTE Continuation"
var string G_FLT = "⑥ NO-SWEEP FILTERS & NEWS"
var string G_DSN = "⑦ DESIGN  ·  Dark chart theme"
var string G_PAN = "⑧ COCKPIT PANEL"
var string G_EDU = "⑩ ON-CHART EDUCATION"
var string G_HOK = "⑪ WEBHOOK / AUTOMATION"

// ─────────────────────────────────────────────────────────────────────────────────────────
//  ① SESSIONS
// ─────────────────────────────────────────────────────────────────────────────────────────
i_tz        = input.string("America/New_York", "Strategy timezone", options = ["America/New_York", "Europe/London", "Europe/Berlin", "UTC", "Asia/Tokyo", "Australia/Sydney"], group = G_SES, tooltip = "The whole model is defined in NEW YORK time. Only change this if you really need a different reference.")
i_asiaSes   = input.session("2000-0000", "Asian Range        (default 20:00-00:00)", group = G_SES, tooltip = "A time based range. Everything this model does is measured against the HIGH, the LOW and the 50% of this window.")
i_lonSes    = input.session("0200-0500", "London Kill Zone   (default 02:00-05:00)", group = G_SES, tooltip = "Trade 1 window. The Asian sweep and its reversal are only valid inside this window.")
i_early     = input.bool(true, "Allow the 01:30 early start", group = G_SES, tooltip = "The raid sometimes fires at 01:30 instead of 02:00.")
i_nySes     = input.session("0700-1000", "New York Kill Zone (default 07:00-10:00)", group = G_SES, tooltip = "Trade 2 window: the OTE continuation.")
i_arDays    = input.int(6, "Keep Asian Ranges on chart", minval = 1, maxval = 40, group = G_SES)
i_showSesBg = input.bool(true, "Shade the sessions", group = G_SES)
i_showAR    = input.bool(true, "Draw the Asian Range box", group = G_SES)
i_showMid   = input.bool(true, "Draw the 50% of the Asian Range", group = G_SES, tooltip = "The 50% is the fallback entry for the days on which the Asian high or low is protected.")

// ─────────────────────────────────────────────────────────────────────────────────────────
//  ② HTF POI
// ─────────────────────────────────────────────────────────────────────────────────────────
i_usePoi    = input.bool(true,  "Require a HTF POI at the sweep", group = G_POI, tooltip = "THE core filter of the model. A raid of the Asian high that does not tap a higher timeframe point of interest is most of the time simply a trap.")
i_tf1On     = input.bool(true,  "POI timeframe 1", inline = "tf1", group = G_POI)
i_tf1       = input.timeframe("15", "", inline = "tf1", group = G_POI)
i_tf2On     = input.bool(true,  "POI timeframe 2", inline = "tf2", group = G_POI)
i_tf2       = input.timeframe("60", "", inline = "tf2", group = G_POI)
i_tf3On     = input.bool(true,  "POI timeframe 3", inline = "tf3", group = G_POI)
i_tf3       = input.timeframe("240", "", inline = "tf3", group = G_POI)
i_poiFvg    = input.bool(true,  "Fair Value Gap",   inline = "pt1", group = G_POI)
i_poiOb     = input.bool(true,  "Order Block",      inline = "pt1", group = G_POI)
i_poiBrk    = input.bool(true,  "Breaker Block",    inline = "pt2", group = G_POI)
i_poiIfvg   = input.bool(true,  "Inverse FVG",      inline = "pt2", group = G_POI)
i_poiMaxAtr = input.float(4.0,  "Discard POIs further away than (ATR)", minval = 1.0, maxval = 40.0, step = 0.5, group = G_POI, tooltip = "A point of interest that sits far outside the daily range is not tradeable today - 'this one is way too low compared to this range'.")
i_poiKeep   = input.int(10, "Max POI zones kept", minval = 2, maxval = 40, group = G_POI)
i_showPoi   = input.bool(true, "Draw the POI zones", inline = "pz", group = G_POI)
i_keepDead  = input.bool(false, "keep expired ones greyed out", inline = "pz", group = G_POI, tooltip = "Every zone is anchored to the candles that built it and is extended until it is used up. Switch this on if you also want to see the zones that already died - useful for studying, noisy for trading.")
i_biasOn    = input.bool(true,  "Require HTF structure alignment", inline = "bias", group = G_POI)
i_biasTf    = input.timeframe("240", "", inline = "bias", group = G_POI, tooltip = "Short setups want a bearish higher timeframe structure, long setups a bullish one.")

// ─────────────────────────────────────────────────────────────────────────────────────────
//  ③ LTF ENTRY MODEL
// ─────────────────────────────────────────────────────────────────────────────────────────
i_model     = input.string("AUTO - first valid trigger", "Confirmation model", options = ["AUTO - first valid trigger", "MSS + FVG - most risk, most R", "CISD - change in state of delivery", "FVG - fair value gap tap", "HIDDEN OB - between two FVGs"], group = G_ENT, tooltip = "Risk ladder of the original model, riskiest first:\n1m MSS+FVG  >  5m CISD  >  5m FVG  >  15m CISD  >  15m FVG.\nRun the indicator on the timeframe you want to enter on.")
i_needFvg   = input.bool(true, "Validate the sweep with a fair value gap", group = G_ENT, tooltip = "A liquidity sweep is not validated until price has traded into a fair value gap.")
i_swing     = input.int(2, "Swing pivot strength", minval = 1, maxval = 6, group = G_ENT)
i_fvgMinAtr = input.float(0.10, "Minimum FVG size (ATR)", minval = 0.0, maxval = 2.0, step = 0.05, group = G_ENT)
i_fvgEntry  = input.string("Proximal edge (small gaps)", "FVG entry price", options = ["Proximal edge (small gaps)", "50% of the gap", "Distal edge (deepest)"], group = G_ENT, tooltip = "On a small gap take the beginning of the gap so you do not miss the trade, on a big gap take the 50%.")
i_confBars  = input.int(30, "Bars allowed between sweep and trigger", minval = 3, maxval = 200, group = G_ENT)
i_hobLook   = input.int(25, "Hidden-OB lookback between two FVGs", minval = 4, maxval = 120, group = G_ENT)
i_showLtf   = input.bool(true, "Draw LTF structure events", group = G_ENT)

// ─────────────────────────────────────────────────────────────────────────────────────────
//  ④ TRADE 1
// ─────────────────────────────────────────────────────────────────────────────────────────
i_t1On      = input.bool(true, "Enable Trade 1 (London reversal)", group = G_TRD)
i_slMode    = input.string("Structure above/below the entry POI", "Stop loss", options = ["Structure above/below the entry POI", "Above/below the sweep candle", "Above/below the sweep extreme", "Above/below the trigger candle"], group = G_TRD, tooltip = "Default: the protective extreme that belongs to the point of interest you are entering from - 'stops not above the swing high but above this candle'. Parking the stop at the session sweep instead makes late entries unusable, because the reward to the other side of the range no longer pays for the risk.")
i_slBuf     = input.float(0.15, "Stop buffer (ATR)", minval = 0.0, maxval = 2.0, step = 0.05, group = G_TRD)
i_tp2On     = input.bool(true, "Second target beyond the range", group = G_TRD, tooltip = "TP1 is always the opposite side of the Asian range. TP2 extends to the next inducement swing - the target for the day.")
i_tp2Look   = input.int(120, "Inducement lookback for TP2", minval = 20, maxval = 480, group = G_TRD)
i_minRR     = input.float(1.0, "Minimum reward/risk to fire", minval = 0.0, maxval = 20.0, step = 0.1, group = G_TRD, tooltip = "Measured to TP1 only. The source model happily takes trades around 1.2R on the safe entries because the runner beyond the range is where the rest of the reward is.")
i_beOn      = input.bool(true, "Move to break even at", inline = "be", group = G_TRD)
i_beAt      = input.float(1.0, "R", minval = 0.2, maxval = 10.0, step = 0.1, inline = "be", group = G_TRD)

// ─────────────────────────────────────────────────────────────────────────────────────────
//  ⑤ TRADE 2
// ─────────────────────────────────────────────────────────────────────────────────────────
i_t2On      = input.bool(true, "Enable Trade 2 (New York OTE continuation)", group = G_CON)
i_oteEntry  = input.float(0.618, "OTE limit level", options = [0.5, 0.618, 0.705, 0.79], group = G_CON, tooltip = "The original model places the limit order at 61.8%.")
i_oteSl     = input.string("Above/below 0.79", "OTE stop", options = ["Above/below 0.79", "Above/below 1.0"], group = G_CON, tooltip = "Stop below the 79 or below the 1.0 - roughly 1.7R versus 3.2R in the worked example of the source.")
i_t2Need4h  = input.bool(false, "Only when the origin POI was a 4H POI", group = G_CON, tooltip = "A 4H point of interest turns the day into a 4H market maker model - internal to external - and produces the biggest continuations.")
i_t2Skip    = input.bool(true, "Skip if the draw is already reached before New York", group = G_CON, tooltip = "External to internal instead of internal to external is a low probability day.")
i_showFib   = input.bool(true, "Draw the OTE fibonacci", group = G_CON)

// ─────────────────────────────────────────────────────────────────────────────────────────
//  ⑥ FILTERS
// ─────────────────────────────────────────────────────────────────────────────────────────
i_protect   = input.bool(true, "No-Sweep filter A: HTF POI already tapped during Asia", group = G_FLT, tooltip = "If price already worked into the higher timeframe POI during the Asian session and then broke structure against the range, the Asian high (or low) is PROTECTED. Do not wait for the raid - trade the 50% of the range, an internal range high, or an Asian session fair value gap instead.")
i_strong    = input.bool(true, "No-Sweep filter B: strong high / low inside the range", group = G_FLT, tooltip = "A sweep immediately followed by a break of structure INSIDE the Asian range builds a strong high. It will most likely be protected. The pull back into it looks like equal highs but it is a rejection block reversal.")
i_bosCnt    = input.int(2, "Structure breaks required for filter A", minval = 1, maxval = 5, group = G_FLT)
i_strongZone = input.float(0.70, "A strong high/low only counts in the outer part of the range", minval = 0.0, maxval = 1.0, step = 0.05, group = G_FLT, tooltip = "In the source model the sweep-then-break pattern sits right at the range boundary. Counting every little pivot inside the range would flag almost every day as protected and the core setup would never fire.")
i_newsOn    = input.bool(false, "News filter: skip London on these dates", group = G_FLT, tooltip = "High impact US news in the New York session means London either ranges or runs one way without a reversal. Pine cannot read a news feed - paste the dates yourself.")
i_newsList  = input.string("", "High impact days  YYYY-MM-DD, comma separated", group = G_FLT)
i_altPoi    = input.bool(true, "Show the fallback entries when a side is protected", group = G_FLT)

// ─────────────────────────────────────────────────────────────────────────────────────────
//  ⑦ DESIGN
// ─────────────────────────────────────────────────────────────────────────────────────────
i_theme     = input.bool(true,  "Dark chart theme (navy background)", group = G_DSN)
i_barCol    = input.bool(true,  "Recolour the candles mint / red", group = G_DSN)
i_margin    = input.bool(true,  "Future margin on the right", group = G_DSN)
i_grid      = input.bool(true,  "Day separators", group = G_DSN)
i_pillSize  = input.string("normal", "Signal pill size", options = ["small", "normal", "large"], group = G_DSN)

// ─────────────────────────────────────────────────────────────────────────────────────────
//  ⑧ - ⑫
// ─────────────────────────────────────────────────────────────────────────────────────────
i_panOn     = input.bool(true, "Show the cockpit panel", group = G_PAN)
i_panPos    = input.string("Middle Left", "Panel position", options = ["Middle Left", "Middle Right", "Bottom Left", "Bottom Right", "Top Right"], group = G_PAN)
i_panSize   = input.string("normal", "Panel headline size", options = ["tiny", "small", "normal"], group = G_PAN)
i_eduCard   = input.bool(true, "Beginner card + how to read", group = G_EDU)
i_eduEvent  = input.bool(true, "Explain every event on the chart", group = G_EDU)
i_hookOn    = input.bool(true, "Fire webhook alerts", group = G_HOK)
i_hookId    = input.string("ASIASWEEP", "Webhook strategy id", group = G_HOK)
i_hookLot   = input.string("0.01", "Webhook volume field", group = G_HOK)
i_hookAcc   = input.string("", "Webhook account field (optional)", group = G_HOK)

// ─────────────────────────────────────────────────────────────────────────────────────────
//  PALETTE
// ─────────────────────────────────────────────────────────────────────────────────────────
cNavy   = color.rgb(6, 17, 30)
cPanel  = color.rgb(10, 29, 46)
cSect   = color.rgb(15, 44, 66)
cMint   = color.rgb(126, 224, 208)
cRed    = color.rgb(244, 44, 58)
cCyan   = color.rgb(53, 200, 255)
cGold   = color.rgb(255, 215, 40)
cGoldA  = color.rgb(255, 236, 130)
cGoldB  = color.rgb(238, 190, 30)
cGoldC  = color.rgb(210, 160, 20)
cGoldD  = color.rgb(170, 125, 12)
cGlint  = color.rgb(255, 252, 214)
cPink   = color.rgb(255, 62, 130)
cLime   = color.rgb(214, 228, 78)
cSupply = color.rgb(196, 66, 92)
cDemand = color.rgb(64, 196, 140)
cSell   = color.rgb(126, 32, 36)
cBuy    = color.rgb(120, 154, 52)
cTxt    = color.rgb(235, 235, 235)
cGrey   = color.rgb(176, 182, 192)

// ─────────────────────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────────────────────
atr     = ta.atr(14)
hi300   = ta.highest(high, 300)
lo300   = ta.lowest(low, 300)
pipSize = syminfo.mintick * (syminfo.type == "forex" ? 10 : 1)
barMs   = timeframe.in_seconds(timeframe.period) * 1000

f_pips(float d) => str.tostring(math.round(math.abs(d) / pipSize, 1))
f_px(float p)   => str.tostring(p, format.mintick)
f_tfUp(t) => timeframe.in_seconds(t) < timeframe.in_seconds(timeframe.period) ? timeframe.period : t

f_tfLbl(t) =>
    s = timeframe.in_seconds(t)
    s >= 86400 ? str.tostring(math.round(s / 86400)) + "D" : s >= 3600 ? str.tostring(math.round(s / 3600)) + "H" : str.tostring(math.round(s / 60)) + "M"

f_sizeOf(s) => s == "tiny" ? size.tiny : s == "small" ? size.small : s == "large" ? size.large : size.normal
f_posOf(s) => s == "Middle Left" ? position.middle_left : s == "Middle Right" ? position.middle_right : s == "Bottom Left" ? position.bottom_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Center" ? position.bottom_center : position.top_right

// ─────────────────────────────────────────────────────────────────────────────────────────
//  SESSION STATE
// ─────────────────────────────────────────────────────────────────────────────────────────
inAsia   = not na(time(timeframe.period, i_asiaSes, i_tz))
inLonRaw = not na(time(timeframe.period, i_lonSes, i_tz))
inEarly  = not na(time(timeframe.period, "0130-0200", i_tz))
inLon    = inLonRaw or (i_early and inEarly)
inNy     = not na(time(timeframe.period, i_nySes, i_tz))

asiaOpen  = inAsia and not inAsia[1]
asiaClose = not inAsia and inAsia[1]

mm = month(time, i_tz)
dd = dayofmonth(time, i_tz)
dateStr = str.tostring(year(time, i_tz)) + "-" + (mm < 10 ? "0" : "") + str.tostring(mm) + "-" + (dd < 10 ? "0" : "") + str.tostring(dd)
newsDay = i_newsOn and str.length(i_newsList) > 2 and str.contains(i_newsList, dateStr)

// ─────────────────────────────────────────────────────────────────────────────────────────
//  HTF SCANNERS
// ─────────────────────────────────────────────────────────────────────────────────────────
f_scan() =>
    bearFvg = low[3] > high[1]
    bullFvg = high[3] < low[1]
    bearOb  = close[2] > open[2] and close[1] < low[2]
    bullOb  = close[2] < open[2] and close[1] > high[2]
    [bearFvg ? low[3] : na, bearFvg ? high[1] : na, bullFvg ? low[1] : na, bullFvg ? high[3] : na, bearOb ? high[2] : na, bearOb ? low[2] : na, bullOb ? high[2] : na, bullOb ? low[2] : na, time[2], time]

f_bias() =>
    p1 = ta.pivothigh(2, 2)
    p2 = ta.pivotlow(2, 2)
    var float lph = na
    var float lpl = na
    var int   bs  = 0
    lph := not na(p1) ? p1 : lph
    lpl := not na(p2) ? p2 : lpl
    if not na(lpl) and close < lpl
        bs := -1
    if not na(lph) and close > lph
        bs := 1
    bs

tfA = f_tfUp(i_tf1)
tfB = f_tfUp(i_tf2)
tfC = f_tfUp(i_tf3)

[aBfT, aBfB, aUfT, aUfB, aBoT, aBoB, aUoT, aUoB, aOrg, aNow] = request.security(syminfo.tickerid, tfA, f_scan(), lookahead = barmerge.lookahead_off)
[bBfT, bBfB, bUfT, bUfB, bBoT, bBoB, bUoT, bUoB, bOrg, bNow] = request.security(syminfo.tickerid, tfB, f_scan(), lookahead = barmerge.lookahead_off)
[cBfT, cBfB, cUfT, cUfB, cBoT, cBoB, cUoT, cUoB, cOrg, cNow] = request.security(syminfo.tickerid, tfC, f_scan(), lookahead = barmerge.lookahead_off)
htfBias = request.security(syminfo.tickerid, f_tfUp(i_biasTf), f_bias(), lookahead = barmerge.lookahead_off)

// ─────────────────────────────────────────────────────────────────────────────────────────
//  POI STORE
// ─────────────────────────────────────────────────────────────────────────────────────────
var array<float>  pTop = array.new_float()
var array<float>  pBot = array.new_float()
var array<int>    pDir = array.new_int()      //  1 = supply / bearish     -1 = demand / bullish
var array<string> pTyp = array.new_string()
var array<string> pTf  = array.new_string()
var array<int>    pOrg = array.new_int()
var array<box>    pBox = array.new_box()
var array<box>    pDead = array.new_box()

f_poiLabel(string tf, string ty, int d) => tf + " " + ty + (d == 1 ? "  SUPPLY" : "  DEMAND")

// a zone that is done is frozen where it died - it is never deleted, so you can always see
// which candles produced it
f_retire(box bx) =>
    if not na(bx)
        if i_keepDead
            box.set_right(bx, time)
            box.set_bgcolor(bx, color.new(cGrey, 94))
            box.set_border_color(bx, color.new(cGrey, 78))
            box.set_text_color(bx, color.new(cGrey, 50))
            array.push(pDead, bx)
            if array.size(pDead) > 20
                box.delete(array.shift(pDead))
        else
            box.delete(bx)
    0

f_poiAdd(float t, float b, int d, string ty, string tf, int org) =>
    ok = not na(t) and not na(b) and t > b and i_showPoi
    if ok
        col = d == 1 ? cSupply : cDemand
        bx = box.new(org, t, time + barMs * 2, b, xloc = xloc.bar_time, border_color = color.new(col, 30), border_width = 1, bgcolor = color.new(col, 85), text = f_poiLabel(tf, ty, d), text_color = color.new(col, 5), text_size = size.tiny, text_halign = text.align_right, text_valign = text.align_center)
        array.push(pTop, t)
        array.push(pBot, b)
        array.push(pDir, d)
        array.push(pTyp, ty)
        array.push(pTf, tf)
        array.push(pOrg, org)
        array.push(pBox, bx)
        if array.size(pTop) > i_poiKeep
            f_retire(array.shift(pBox))
            array.shift(pTop)
            array.shift(pBot)
            array.shift(pDir)
            array.shift(pTyp)
            array.shift(pTf)
            array.shift(pOrg)
    ok

if i_tf1On and aNow != aNow[1]
    if i_poiFvg
        f_poiAdd(aBfT, aBfB,  1, "FVG", f_tfLbl(tfA), aOrg)
        f_poiAdd(aUfT, aUfB, -1, "FVG", f_tfLbl(tfA), aOrg)
    if i_poiOb
        f_poiAdd(aBoT, aBoB,  1, "OB", f_tfLbl(tfA), aOrg)
        f_poiAdd(aUoT, aUoB, -1, "OB", f_tfLbl(tfA), aOrg)

if i_tf2On and bNow != bNow[1]
    if i_poiFvg
        f_poiAdd(bBfT, bBfB,  1, "FVG", f_tfLbl(tfB), bOrg)
        f_poiAdd(bUfT, bUfB, -1, "FVG", f_tfLbl(tfB), bOrg)
    if i_poiOb
        f_poiAdd(bBoT, bBoB,  1, "OB", f_tfLbl(tfB), bOrg)
        f_poiAdd(bUoT, bUoB, -1, "OB", f_tfLbl(tfB), bOrg)

if i_tf3On and cNow != cNow[1]
    if i_poiFvg
        f_poiAdd(cBfT, cBfB,  1, "FVG", f_tfLbl(tfC), cOrg)
        f_poiAdd(cUfT, cUfB, -1, "FVG", f_tfLbl(tfC), cOrg)
    if i_poiOb
        f_poiAdd(cBoT, cBoB,  1, "OB", f_tfLbl(tfC), cOrg)
        f_poiAdd(cUoT, cUoB, -1, "OB", f_tfLbl(tfC), cOrg)

// violated POIs flip into breakers / inverse FVGs, dead or far away ones are dropped
if array.size(pTop) > 0
    for k = array.size(pTop) - 1 to 0
        d    = array.get(pDir, k)
        tp   = array.get(pTop, k)
        bt   = array.get(pBot, k)
        ty   = array.get(pTyp, k)
        bx   = array.get(pBox, k)
        kill = false
        flip = false
        if d == -1 and close < bt
            if ty == "OB" and i_poiBrk
                array.set(pDir, k, 1)
                array.set(pTyp, k, "BREAKER")
                flip := true
            else if ty == "FVG" and i_poiIfvg
                array.set(pDir, k, 1)
                array.set(pTyp, k, "IFVG")
                flip := true
            else
                kill := true
        else if d == 1 and close > tp
            if ty == "OB" and i_poiBrk
                array.set(pDir, k, -1)
                array.set(pTyp, k, "BREAKER")
                flip := true
            else if ty == "FVG" and i_poiIfvg
                array.set(pDir, k, -1)
                array.set(pTyp, k, "IFVG")
                flip := true
            else
                kill := true
        if math.abs((tp + bt) / 2 - close) > i_poiMaxAtr * atr
            kill := true
        if kill
            f_retire(bx)
            array.remove(pTop, k)
            array.remove(pBot, k)
            array.remove(pDir, k)
            array.remove(pTyp, k)
            array.remove(pTf, k)
            array.remove(pOrg, k)
            array.remove(pBox, k)
        else if not na(bx)
            nd = array.get(pDir, k)
            nc = nd == 1 ? cSupply : cDemand
            box.set_right(bx, time + barMs * 2)
            if flip
                box.set_bgcolor(bx, color.new(nc, 85))
                box.set_border_color(bx, color.new(nc, 30))
                box.set_text_color(bx, color.new(nc, 5))
                box.set_text(bx, f_poiLabel(array.get(pTf, k), array.get(pTyp, k), nd))

f_poiAt(float px, int d) =>
    string hit = ""
    if array.size(pTop) > 0
        for k = 0 to array.size(pTop) - 1
            if array.get(pDir, k) == d and hit == ""
                if px >= array.get(pBot, k) and px <= array.get(pTop, k)
                    hit := array.get(pTf, k) + " " + array.get(pTyp, k)
    hit

// ─────────────────────────────────────────────────────────────────────────────────────────
//  ASIAN RANGE ENGINE
// ─────────────────────────────────────────────────────────────────────────────────────────
var float arH   = na
var float arL   = na
var float arMid = na
var int   arT0  = na
var int   arT1  = na
var bool  arOk  = false

var float arIntHi     = na
var float arIntLo     = na
var bool  strongHi    = false
var bool  strongLo    = false
var int   asiaBosDn   = 0
var int   asiaBosUp   = 0
var bool  poiEarlyBr  = false
var bool  poiEarlyBl  = false
var bool  asiaFvgUp   = false
var bool  asiaFvgDn   = false

// ─────────────────────────────────────────────────────────────────────────────────────────
//  CHART TIMEFRAME STRUCTURE
// ─────────────────────────────────────────────────────────────────────────────────────────
ph = ta.pivothigh(i_swing, i_swing)
pl = ta.pivotlow(i_swing, i_swing)
var float swHi     = na
var float swLo     = na
var float prevSwHi = na
var float prevSwLo = na
if not na(ph)
    prevSwHi := swHi
    swHi := ph
if not na(pl)
    prevSwLo := swLo
    swLo := pl

bosDown = not na(swLo) and close < swLo and close[1] >= swLo
bosUp   = not na(swHi) and close > swHi and close[1] <= swHi

fvgMin     = i_fvgMinAtr * atr
bearFvgNew = low[2] > high and (low[2] - high) >= fvgMin
bullFvgNew = high[2] < low and (low - high[2]) >= fvgMin

var array<float> fT = array.new_float()
var array<float> fB = array.new_float()
var array<int>   fD = array.new_int()
var array<int>   fI = array.new_int()
if bearFvgNew
    array.push(fT, low[2])
    array.push(fB, high)
    array.push(fD, 1)
    array.push(fI, bar_index)
if bullFvgNew
    array.push(fT, low)
    array.push(fB, high[2])
    array.push(fD, -1)
    array.push(fI, bar_index)
if array.size(fT) > 60
    array.shift(fT)
    array.shift(fB)
    array.shift(fD)
    array.shift(fI)

f_fvgPrice(float t, float b, int d) => i_fvgEntry == "50% of the gap" ? (t + b) / 2 : i_fvgEntry == "Distal edge (deepest)" ? (d == 1 ? t : b) : (d == 1 ? b : t)

f_fvgTapped(int d, int sinceBar) =>
    bool res = false
    if array.size(fT) > 0 and not na(sinceBar)
        for k = 0 to array.size(fT) - 1
            if array.get(fD, k) == d and array.get(fI, k) >= sinceBar and not res
                if low <= array.get(fT, k) and high >= array.get(fB, k)
                    res := true
    res

f_lastFvg(int d, int sinceBar) =>
    float t = na
    float b = na
    int   i = na
    if array.size(fT) > 0 and not na(sinceBar)
        for k = array.size(fT) - 1 to 0
            if na(t) and array.get(fD, k) == d and array.get(fI, k) >= sinceBar
                t := array.get(fT, k)
                b := array.get(fB, k)
                i := array.get(fI, k)
    [t, b, i]

// CISD - change in state of delivery
var float upRunOpen = na
var float dnRunOpen = na
if close > open
    upRunOpen := (close[1] > open[1] and not na(upRunOpen)) ? upRunOpen : open
if close < open
    dnRunOpen := (close[1] < open[1] and not na(dnRunOpen)) ? dnRunOpen : open
cisdDown = not na(upRunOpen) and close < open and close < upRunOpen and close[1] >= upRunOpen
cisdUp   = not na(dnRunOpen) and close > open and close > dnRunOpen and close[1] <= dnRunOpen

// protective extreme belonging to a point of interest
f_protHi(int fromBar) =>
    float h = na
    if not na(fromBar)
        int o = bar_index - fromBar
        if o >= 0 and o < 400
            for j = 0 to o
                h := na(h) ? high[j] : math.max(h, high[j])
    h

f_protLo(int fromBar) =>
    float l = na
    if not na(fromBar)
        int o = bar_index - fromBar
        if o >= 0 and o < 400
            for j = 0 to o
                l := na(l) ? low[j] : math.min(l, low[j])
    l

// hidden order block: the opposite colour candle sitting between two same direction FVGs
f_hiddenOb(int d) =>
    float t = na
    float b = na
    int   ob = na
    int   n = array.size(fT)
    if n >= 2
        int i2 = na
        int i1 = na
        for k = n - 1 to 0
            if array.get(fD, k) == d
                if na(i2)
                    i2 := array.get(fI, k)
                else if na(i1)
                    i1 := array.get(fI, k)
        if not na(i1) and not na(i2) and i2 > i1 and i2 - i1 <= i_hobLook
            int o1 = bar_index - i2
            int o2 = bar_index - i1
            if o1 >= 0 and o2 < 480
                float best = na
                for off = o1 to o2
                    up = close[off] > open[off]
                    if d == 1 and up and (na(best) or high[off] > best)
                        best := high[off]
                        t := high[off]
                        b := math.min(open[off], close[off])
                        ob := bar_index - off
                    if d == -1 and not up and (na(best) or low[off] < best)
                        best := low[off]
                        t := math.max(open[off], close[off])
                        b := low[off]
                        ob := bar_index - off
    [t, b, ob]

// strong high / low  =  sweep followed by a break of structure
var float pendHi  = na
var int   pendHiB = na
var float pendLo  = na
var int   pendLoB = na
if not na(swHi) and high > swHi and close < swHi
    pendHi := swHi
    pendHiB := bar_index
if not na(swLo) and low < swLo and close > swLo
    pendLo := swLo
    pendLoB := bar_index
newStrongHi = not na(pendHi) and bosDown and bar_index - pendHiB <= 20
newStrongLo = not na(pendLo) and bosUp and bar_index - pendLoB <= 20

// ─────────────────────────────────────────────────────────────────────────────────────────
//  ASIAN RANGE ACCUMULATION + INSIDE-RANGE OBSERVATIONS
// ─────────────────────────────────────────────────────────────────────────────────────────
if asiaOpen
    arH := high
    arL := low
    arT0 := time
    arOk := false
    arIntHi := na
    arIntLo := na
    strongHi := false
    strongLo := false
    asiaBosDn := 0
    asiaBosUp := 0
    poiEarlyBr := false
    poiEarlyBl := false
    asiaFvgUp := false
    asiaFvgDn := false
else if inAsia
    arH := math.max(arH, high)
    arL := math.min(arL, low)

if inAsia
    if f_poiAt(high, 1) != ""
        poiEarlyBr := true
    if f_poiAt(low, -1) != ""
        poiEarlyBl := true
    if bosDown
        asiaBosDn := asiaBosDn + 1
    if bosUp
        asiaBosUp := asiaBosUp + 1
    rngNow = arH - arL
    if newStrongHi and rngNow > 0 and pendHi >= arL + i_strongZone * rngNow
        strongHi := true
    if newStrongLo and rngNow > 0 and pendLo <= arL + (1.0 - i_strongZone) * rngNow
        strongLo := true
    if not na(ph)
        arIntHi := na(arIntHi) ? ph : math.max(arIntHi, ph)
    if not na(pl)
        arIntLo := na(arIntLo) ? pl : math.min(arIntLo, pl)
    if bearFvgNew
        asiaFvgDn := true
    if bullFvgNew
        asiaFvgUp := true

if asiaClose
    arMid := (arH + arL) / 2
    arT1 := time
    arOk := true

arRange = arOk ? arH - arL : na
highProtected = arOk and ((i_protect and poiEarlyBr and asiaBosDn >= i_bosCnt) or (i_strong and strongHi))
lowProtected  = arOk and ((i_protect and poiEarlyBl and asiaBosUp >= i_bosCnt) or (i_strong and strongLo))

// ─────────────────────────────────────────────────────────────────────────────────────────
//  TRADE 1 STATE MACHINE
// ─────────────────────────────────────────────────────────────────────────────────────────
var int    setupDir = 0
var bool   swept    = false
var float  swpExt   = na
var int    swpBar   = na
var float  swpHi    = na
var float  swpLo    = na
var string swpPoi   = ""
var bool   swpPoi4h = false
var bool   swpFvgOk = false
var bool   swpTag   = false
var bool   mssTag   = false
var bool   cisdTag  = false
var bool   hobTag   = false
var bool   t1Fired  = false
var bool   t1Live   = false
var float  t1Ent    = na
var float  t1Sl     = na
var float  t1Tp1    = na
var float  t1Tp2    = na
var float  t1RrVal  = na
var string t1Trig   = ""
var bool   t1Be     = false
var string t1State  = "FLAT"
var string blockMsg = ""
var bool   blockTag = false
var int    wins     = 0
var int    losses   = 0
var int    bes      = 0
var int    lastSigT = na
var string lastSigS = ""

if asiaOpen
    setupDir := 0
    swept := false
    swpExt := na
    swpBar := na
    swpPoi := ""
    swpPoi4h := false
    swpFvgOk := false
    swpTag := false
    mssTag := false
    cisdTag := false
    hobTag := false
    t1Fired := false
    t1Live := false
    t1Be := false
    t1RrVal := na
    t1State := "FLAT"
    blockMsg := ""
    blockTag := false

tradableLon = i_t1On and arOk and inLon and not newsDay
biasShortOk = not i_biasOn or htfBias <= 0
biasLongOk  = not i_biasOn or htfBias >= 0

if tradableLon and not swept
    if high > arH and close < arH and not highProtected and biasShortOk
        hitS = f_poiAt(high, 1)
        if not i_usePoi or hitS != ""
            swept := true
            setupDir := -1
            swpExt := high
            swpBar := bar_index
            swpHi := high
            swpLo := low
            swpPoi := hitS
            swpPoi4h := str.contains(hitS, "4H")
            t1State := "SWEPT"
    else if low < arL and close > arL and not lowProtected and biasLongOk
        hitL = f_poiAt(low, -1)
        if not i_usePoi or hitL != ""
            swept := true
            setupDir := 1
            swpExt := low
            swpBar := bar_index
            swpHi := high
            swpLo := low
            swpPoi := hitL
            swpPoi4h := str.contains(hitL, "4H")
            t1State := "SWEPT"

if swept and not t1Fired
    if setupDir == -1 and high > swpExt
        swpExt := high
        swpHi := high
        swpLo := low
        swpBar := bar_index
    if setupDir == 1 and low < swpExt
        swpExt := low
        swpHi := high
        swpLo := low
        swpBar := bar_index

dirPoi = setupDir == -1 ? 1 : -1
if swept and not swpFvgOk and f_fvgTapped(dirPoi, swpBar)
    swpFvgOk := true

// the structure event only ARMS the setup - the entry itself is always taken at a point of
// interest (fair value gap, hidden order block, CISD level), never at market
mssNow  = setupDir == -1 ? bosDown : setupDir == 1 ? bosUp : false
cisdNow = setupDir == -1 ? cisdDown : setupDir == 1 ? cisdUp : false

var bool  armMss  = false
var bool  armCisd = false
var float cisdLvl = na
var int   cisdBar = na
if asiaOpen
    armMss := false
    armCisd := false
    cisdLvl := na
    cisdBar := na
if swept and not t1Fired
    if mssNow
        armMss := true
    if cisdNow
        armCisd := true
        cisdLvl := setupDir == -1 ? upRunOpen : dnRunOpen
        cisdBar := bar_index

[lfT, lfB, lfI] = f_lastFvg(dirPoi, swpBar)
tapFvg = not na(lfT) and bar_index > lfI and low <= lfT and high >= lfB
[hobT, hobB, hobBar] = f_hiddenOb(dirPoi)
tapHob = not na(hobT) and low <= hobT and high >= hobB
tapCisd = armCisd and not na(cisdLvl) and not na(cisdBar) and bar_index > cisdBar and (setupDir == -1 ? high >= cisdLvl : low <= cisdLvl)

useMssFvg = armMss and tapFvg
useFvg = tapFvg
useHob = tapHob
useCisd = tapCisd

modelOk = switch i_model
    "MSS + FVG - most risk, most R"       => useMssFvg
    "CISD - change in state of delivery"  => useCisd
    "FVG - fair value gap tap"            => useFvg
    "HIDDEN OB - between two FVGs"        => useHob
    => useMssFvg or useFvg or useHob or useCisd

trigName = useMssFvg ? "MSS + FVG" : useFvg ? "FVG TAP" : useHob ? "HIDDEN OB" : useCisd ? "CISD" : "STRUCTURE"
fireT1 = swept and not t1Fired and tradableLon and modelOk and bar_index - swpBar <= i_confBars and (not i_needFvg or swpFvgOk or tapFvg or tapHob)

entRefBar = useFvg and not na(lfI) ? lfI - 3 : useHob and not na(hobBar) ? hobBar - 1 : useCisd and not na(cisdBar) ? cisdBar - 1 : bar_index - 1
if fireT1
    poiRef = setupDir == -1 ? f_protHi(entRefBar) : f_protLo(entRefBar)
    slRef = switch i_slMode
        "Above/below the sweep extreme"  => swpExt
        "Above/below the trigger candle" => setupDir == -1 ? high : low
        "Above/below the sweep candle"   => setupDir == -1 ? swpHi : swpLo
        => na(poiRef) ? (setupDir == -1 ? high : low) : poiRef
    entPx = useFvg ? f_fvgPrice(lfT, lfB, dirPoi) : useHob ? (setupDir == -1 ? hobB : hobT) : useCisd ? cisdLvl : close
    slPx  = setupDir == -1 ? math.max(slRef, high) + i_slBuf * atr : math.min(slRef, low) - i_slBuf * atr
    tp1Px = setupDir == -1 ? arL : arH
    float tp2Px = na
    if i_tp2On
        float best = na
        for j = 1 to i_tp2Look
            if setupDir == -1 and low[j] < tp1Px and (na(best) or low[j] < best)
                best := low[j]
            if setupDir == 1 and high[j] > tp1Px and (na(best) or high[j] > best)
                best := high[j]
        tp2Px := best
    risk = math.abs(entPx - slPx)
    rr = risk > 0 ? math.abs(tp1Px - entPx) / risk : 0
    if rr >= i_minRR and risk > 0
        t1Fired := true
        t1Live := true
        t1Ent := entPx
        t1Sl := slPx
        t1Tp1 := tp1Px
        t1Tp2 := tp2Px
        t1RrVal := rr
        t1Trig := trigName
        t1State := setupDir == -1 ? "SHORT LIVE" : "LONG LIVE"
        lastSigT := time
        lastSigS := (setupDir == -1 ? "SELL " : "BUY ") + trigName
    else
        blockMsg := "SKIPPED · R/R " + str.tostring(rr, "#.00") + " below the required " + str.tostring(i_minRR, "#.00")

hitTp = false
hitSl = false
hitBe = false
if t1Live and not fireT1
    if setupDir == -1
        if i_beOn and not t1Be and low <= t1Ent - i_beAt * math.abs(t1Ent - t1Sl)
            t1Be := true
        if low <= t1Tp1
            hitTp := true
        else if high >= (t1Be ? t1Ent : t1Sl)
            hitSl := not t1Be
            hitBe := t1Be
    else if setupDir == 1
        if i_beOn and not t1Be and high >= t1Ent + i_beAt * math.abs(t1Ent - t1Sl)
            t1Be := true
        if high >= t1Tp1
            hitTp := true
        else if low <= (t1Be ? t1Ent : t1Sl)
            hitSl := not t1Be
            hitBe := t1Be

if hitTp
    wins := wins + 1
    t1Live := false
    t1State := "TP1 HIT"
else if hitSl
    losses := losses + 1
    t1Live := false
    t1State := "SL HIT"
else if hitBe
    bes := bes + 1
    t1Live := false
    t1State := "BE"

// ─────────────────────────────────────────────────────────────────────────────────────────
//  TRADE 2  ·  NEW YORK OTE CONTINUATION
// ─────────────────────────────────────────────────────────────────────────────────────────
var bool  rangeBroken = false
var float contA       = na
var float contB       = na
var int   contBarA    = na
var int   contBarB    = na
var bool  t2Fired     = false
var bool  t2Live      = false
var float t2Ent       = na
var float t2Sl        = na
var float t2Tp        = na
var bool  drawReached = false

if asiaOpen
    rangeBroken := false
    contA := na
    contB := na
    t2Fired := false
    t2Live := false
    drawReached := false

if arOk and swept and not rangeBroken
    if setupDir == -1 and close < arL
        rangeBroken := true
        contA := swpExt
        contBarA := swpBar
        contB := low
        contBarB := bar_index
    else if setupDir == 1 and close > arH
        rangeBroken := true
        contA := swpExt
        contBarA := swpBar
        contB := high
        contBarB := bar_index

if rangeBroken and not t2Fired
    if setupDir == -1 and low < contB
        contB := low
        contBarB := bar_index
    if setupDir == 1 and high > contB
        contB := high
        contBarB := bar_index
    if i_tp2On and not na(t1Tp2) and not inNy
        if setupDir == -1 and low <= t1Tp2
            drawReached := true
        if setupDir == 1 and high >= t1Tp2
            drawReached := true

f_fib(float x) => rangeBroken ? contA + (contB - contA) * x : na
oteEnt = f_fib(i_oteEntry)
oteStp = f_fib(i_oteSl == "Above/below 1.0" ? 1.0 : 0.79)

t2Ok = i_t2On and rangeBroken and inNy and not t2Fired and not na(oteEnt) and (not i_t2Need4h or swpPoi4h) and not (i_t2Skip and drawReached)
fireT2 = t2Ok and high >= oteEnt and low <= oteEnt

if fireT2
    t2Fired := true
    t2Live := true
    t2Ent := oteEnt
    t2Sl := setupDir == -1 ? oteStp + i_slBuf * atr : oteStp - i_slBuf * atr
    t2Tp := not na(t1Tp2) ? t1Tp2 : contB + (contB - contA) * 0.5
    lastSigT := time
    lastSigS := (setupDir == -1 ? "SELL " : "BUY ") + "NY OTE"

if t2Live and not fireT2
    if setupDir == -1
        if low <= t2Tp
            t2Live := false
            wins := wins + 1
        else if high >= t2Sl
            t2Live := false
            losses := losses + 1
    else
        if high >= t2Tp
            t2Live := false
            wins := wins + 1
        else if low <= t2Sl
            t2Live := false
            losses := losses + 1

// ═════════════════════════════════════════════════════════════════════════════════════════
//  DRAWING
// ═════════════════════════════════════════════════════════════════════════════════════════
bgcolor(i_theme ? cNavy : na, title = "Theme background")
barcolor(i_barCol ? (close >= open ? cMint : cRed) : na, title = "Theme candles")
bgcolor(i_grid and timeframe.change("D") ? color.new(cCyan, 88) : na, title = "Day separator")
bgcolor(i_showSesBg and inAsia ? color.new(cGold, 92) : na, title = "Asian session")
bgcolor(i_showSesBg and inLon ? color.new(cCyan, 92) : na, title = "London kill zone")
bgcolor(i_showSesBg and inNy ? color.new(cPink, 93) : na, title = "New York kill zone")

var box marginBox = na
if i_margin and barstate.islast and not na(hi300)
    rng = hi300 - lo300
    box.delete(marginBox)
    marginBox := box.new(bar_index + 1, hi300 + 0.6 * rng, bar_index + 60, lo300 - 0.6 * rng, border_color = color.new(cNavy, 100), bgcolor = i_theme ? cNavy : color.new(cNavy, 100))

// --- Asian range: boxes are kept per day, the projections belong to the current range only
var box   arBox = na
var line  arHL  = na
var line  arLL  = na
var line  arML  = na
var label arHLb = na
var label arLLb = na
var label arMLb = na
var array<box> arOld = array.new_box()

if asiaClose and i_showAR
    line.delete(arHL)
    line.delete(arLL)
    line.delete(arML)
    label.delete(arHLb)
    label.delete(arLLb)
    label.delete(arMLb)
    arBox := box.new(arT0, arH, arT1, arL, xloc = xloc.bar_time, border_color = color.new(cGold, 40), border_width = 1, bgcolor = color.new(cGold, 90), text = "ASIAN RANGE  " + f_pips(arRange) + " pips", text_color = color.new(cGold, 25), text_size = size.tiny, text_halign = text.align_center, text_valign = text.align_top)
    array.push(arOld, arBox)
    if array.size(arOld) > i_arDays
        box.delete(array.shift(arOld))
    arHL := line.new(arT1, arH, arT1 + 1, arH, xloc = xloc.bar_time, color = color.new(cSupply, 15), width = 2, style = line.style_dashed)
    arLL := line.new(arT1, arL, arT1 + 1, arL, xloc = xloc.bar_time, color = color.new(cDemand, 15), width = 2, style = line.style_dashed)
    arHLb := label.new(arT1, arH, "AR HIGH  " + f_px(arH), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(cSect, 15), textcolor = cSupply, size = size.tiny, tooltip = "ASIAN RANGE HIGH - buy side liquidity.\nThe model only ever SELLS above this line. It never buys there.\nA raid of this high inside the London kill zone that lands in a bearish higher timeframe POI is Trade 1.")
    arLLb := label.new(arT1, arL, "AR LOW  " + f_px(arL), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(cSect, 15), textcolor = cDemand, size = size.tiny, tooltip = "ASIAN RANGE LOW - sell side liquidity.\nThe model only ever BUYS below this line. It never sells there.\nIt is also the first target of a short taken from the Asian high.")
    if i_showMid
        arML := line.new(arT1, arMid, arT1 + 1, arMid, xloc = xloc.bar_time, color = color.new(cPink, 30), width = 1, style = line.style_dotted)
        arMLb := label.new(arT1, arMid, "AR 50%  " + f_px(arMid), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(cSect, 25), textcolor = cPink, size = size.tiny, tooltip = "50% OF THE ASIAN RANGE\nThe fallback entry. On the days when the Asian high or low is protected and will not be raided, this is the level the London move is picked up from instead.")

if arOk and i_showAR and not na(arBox)
    xr = time + barMs * 3
    line.set_x2(arHL, xr)
    line.set_x2(arLL, xr)
    label.set_x(arHLb, xr)
    label.set_x(arLLb, xr)
    if i_showMid and not na(arML)
        line.set_x2(arML, xr)
        label.set_x(arMLb, xr)

// --- LTF fair value gaps (budgeted so they never push signals out of the object limit)
var array<box> ltfBox = array.new_box()
f_ltfBox(float t, float b, color col) =>
    bx = box.new(bar_index - 2, t, bar_index + 2, b, border_color = color.new(col, 100), bgcolor = color.new(col, 88))
    array.push(ltfBox, bx)
    if array.size(ltfBox) > 40
        box.delete(array.shift(ltfBox))
    bx
if i_showLtf and bearFvgNew
    f_ltfBox(low[2], high, cSupply)
if i_showLtf and bullFvgNew
    f_ltfBox(low, high[2], cDemand)

// --- event labels (budgeted)
var array<label> evLab = array.new_label()
f_ev(float px, string txt, bool dn, color col, string tip) =>
    lb = label.new(bar_index, px, txt, style = dn ? label.style_label_down : label.style_label_up, color = color.new(cSect, 15), textcolor = col, size = size.tiny, tooltip = tip)
    array.push(evLab, lb)
    if array.size(evLab) > 80
        label.delete(array.shift(evLab))
    lb

if i_eduEvent and swept and not swpTag
    swpTag := true
    f_ev(setupDir == -1 ? high : low, setupDir == -1 ? "SWEEP ▲" : "SWEEP ▼", setupDir == -1, cGold, "LIQUIDITY SWEEP\nPrice traded through the Asian " + (setupDir == -1 ? "HIGH" : "LOW") + " and closed back inside the range.\n" + (swpPoi != "" ? "It did so INSIDE a " + swpPoi + " point of interest - that is the high probability version of this raid.\n" : "No higher timeframe POI was tapped - reduced probability.\n") + "The model now waits for a lower timeframe confirmation before it fires.")

if i_showLtf and i_eduEvent and swept and not t1Fired
    if mssNow and not mssTag
        mssTag := true
        f_ev(setupDir == -1 ? low : high, "MSS", setupDir != -1, cCyan, "MARKET STRUCTURE SHIFT\nPrice closed through the last protected swing in the direction of the setup. Displacement right after a raid is what turns the raid into a reversal.\nThe shift only ARMS the setup - the entry itself is taken on the retracement into a point of interest.")
    if cisdNow and not cisdTag
        cisdTag := true
        f_ev(setupDir == -1 ? low : high, "CISD", setupDir != -1, cLime, "CHANGE IN STATE OF DELIVERY\nPrice closed beyond the OPEN of the first candle of the last opposing run. The order flow that produced the sweep has been cancelled.\nThe CISD level itself becomes the entry: the model waits for price to trade back to it.")
    if tapHob and not hobTag
        hobTag := true
        f_ev(setupDir == -1 ? high : low, "HIDDEN OB", setupDir == -1, cGold, "HIDDEN ORDER BLOCK\nTwo fair value gaps in the same direction with an opposite colour candle between them. That candle is the order block almost nobody marks and it is the refined entry of this model.")

if i_eduEvent and inAsia and newStrongHi
    f_ev(high, "STRONG HIGH", true, cGold, "STRONG HIGH INSIDE THE ASIAN RANGE\nA sweep immediately followed by a break of structure down.\nThis high is PROTECTED - most of the time it will not be taken again.\nWhat looks like equal highs later is a rejection block reversal, not a raid. Do not wait for a sweep that will never come.")
if i_eduEvent and inAsia and newStrongLo
    f_ev(low, "STRONG LOW", false, cGold, "STRONG LOW INSIDE THE ASIAN RANGE\nA sweep immediately followed by a break of structure up.\nThis low is PROTECTED - it will most likely not be taken again.")

// --- a setup that was found but rejected is explained too
if i_eduEvent and blockMsg != "" and not blockTag
    blockTag := true
    f_ev(setupDir == -1 ? high : low, "NO TRADE", setupDir == -1, cGrey, "SETUP FOUND BUT NOT TAKEN\n" + blockMsg + "\n\nThe raid, the point of interest and the confirmation were all there, but the distance from the entry to the opposite side of the Asian range was not worth the stop. The model would rather skip the day than pay for a target it cannot reach.\nLower 'Minimum reward/risk to fire' in the settings if you want to see these trades.")

// --- protected side note
var label protLab = na
if i_altPoi and asiaClose and (highProtected or lowProtected)
    label.delete(protLab)
    protLab := label.new(time, highProtected ? arH : arL, (highProtected ? "AR HIGH PROTECTED" : "AR LOW PROTECTED") + "  ·  trade the fallbacks", xloc = xloc.bar_time, style = highProtected ? label.style_label_down : label.style_label_up, color = color.new(cSell, 10), textcolor = cGold, size = size.small, tooltip = "NO SWEEP DAY\n" + (poiEarlyBr or poiEarlyBl ? "The higher timeframe POI was already worked into during the Asian session and structure broke against the range " + str.tostring(math.max(asiaBosDn, asiaBosUp)) + " times.\n" : "") + (strongHi or strongLo ? "A strong " + (strongHi ? "high" : "low") + " formed inside the range - sweep followed by break of structure.\n" : "") + "\nDo NOT wait for the Asian " + (highProtected ? "high" : "low") + " to be raided. Trade from:\n1) the 50% of the Asian range\n2) an internal range " + (highProtected ? "high" : "low") + " - trend line liquidity\n3) a fair value gap built inside the Asian session" + ((highProtected and asiaFvgDn) or (lowProtected and asiaFvgUp) ? "  (one exists today)" : ""))

// --- trade 1 levels
var line  lEnt  = na
var line  lSl   = na
var line  lTp1  = na
var line  lTp2  = na
var label lEntL = na
var label lSlL  = na
var label lTp1L = na
var label lTp2L = na
if fireT1 and t1Fired
    line.delete(lEnt)
    line.delete(lSl)
    line.delete(lTp1)
    line.delete(lTp2)
    label.delete(lEntL)
    label.delete(lSlL)
    label.delete(lTp1L)
    label.delete(lTp2L)
    lEnt := line.new(bar_index, t1Ent, bar_index + 45, t1Ent, color = cGold, width = 2, style = line.style_dashed)
    lSl := line.new(bar_index, t1Sl, bar_index + 45, t1Sl, color = cPink, width = 1, style = line.style_dashed)
    lTp1 := line.new(bar_index, t1Tp1, bar_index + 45, t1Tp1, color = cMint, width = 1, style = line.style_dashed)
    lEntL := label.new(bar_index + 45, t1Ent, "ENTRY " + f_px(t1Ent), style = label.style_label_left, color = color.new(cSect, 20), textcolor = cGold, size = size.tiny)
    lSlL := label.new(bar_index + 45, t1Sl, "SL " + f_px(t1Sl) + "   " + f_pips(t1Ent - t1Sl) + " pips", style = label.style_label_left, color = color.new(cSect, 20), textcolor = cPink, size = size.tiny)
    lTp1L := label.new(bar_index + 45, t1Tp1, "TP1 " + f_px(t1Tp1) + "   AR " + (setupDir == -1 ? "LOW" : "HIGH"), style = label.style_label_left, color = color.new(cSect, 20), textcolor = cMint, size = size.tiny)
    if not na(t1Tp2)
        lTp2 := line.new(bar_index, t1Tp2, bar_index + 45, t1Tp2, color = color.new(cMint, 45), width = 1, style = line.style_dotted)
        lTp2L := label.new(bar_index + 45, t1Tp2, "TP2 " + f_px(t1Tp2) + "   inducement", style = label.style_label_left, color = color.new(cSect, 35), textcolor = color.new(cMint, 30), size = size.tiny)

// --- OTE fibonacci
var array<line>  fibL = array.new_line()
var array<label> fibB = array.new_label()
if rangeBroken and i_showFib and barstate.islast and not na(contA) and not na(contB)
    if array.size(fibL) > 0
        for k = 0 to array.size(fibL) - 1
            line.delete(array.get(fibL, k))
        array.clear(fibL)
    if array.size(fibB) > 0
        for k = 0 to array.size(fibB) - 1
            label.delete(array.get(fibB, k))
        array.clear(fibB)
    lv = array.from(0.0, 0.5, 0.618, 0.705, 0.79, 1.0)
    for k = 0 to array.size(lv) - 1
        x = array.get(lv, k)
        px = contA + (contB - contA) * x
        isOte = math.abs(x - i_oteEntry) < 0.0001
        col = x == 0.0 or x == 1.0 ? color.new(cGrey, 35) : isOte ? cGold : color.new(cPink, 25)
        array.push(fibL, line.new(contBarA, px, bar_index + 28, px, color = col, width = isOte ? 2 : 1, style = isOte ? line.style_solid : line.style_dotted))
        array.push(fibB, label.new(bar_index + 28, px, str.tostring(x) + (isOte ? "   OTE LIMIT" : ""), style = label.style_label_left, color = color.new(cSect, 35), textcolor = col, size = size.tiny, tooltip = "OPTIMAL TRADE ENTRY\n0 = the London extreme, most likely the high or low of the day\n1 = the extreme reached after the Asian range was broken\nThe continuation is picked up between the 0.5 and the 0.79 during the New York kill zone."))
    array.push(fibB, label.new(contBarA, contA, setupDir == -1 ? "HIGH OF DAY?" : "LOW OF DAY?", style = setupDir == -1 ? label.style_label_down : label.style_label_up, color = color.new(cSect, 20), textcolor = cGold, size = size.tiny, tooltip = "A raid of the Asian range followed by a break of structure through the OPPOSITE side makes this extreme the likely high or low of the day. That is exactly what makes the New York continuation tradeable."))

// --- signal pills
pillSz = f_sizeOf(i_pillSize)
biasTxt = htfBias > 0 ? "bullish" : htfBias < 0 ? "bearish" : "neutral"
whyT1 = "WHY THIS TRADE?\n1) Asian range " + f_px(arL) + " - " + f_px(arH) + " (" + f_pips(arRange) + " pips) built in " + i_asiaSes + " New York time.\n2) Price raided the AR " + (setupDir == -1 ? "HIGH" : "LOW") + " at " + f_px(swpExt) + (swpPoi != "" ? " directly into a " + swpPoi + " point of interest." : " without a higher timeframe POI - reduced probability.") + "\n3) Higher timeframe structure on " + f_tfLbl(f_tfUp(i_biasTf)) + " is " + biasTxt + ".\n4) Confirmation: " + trigName + (swpFvgOk ? ", and the raid was validated by a fair value gap." : ".") + "\n5) Direction is mechanical: above the range this model only sells, below it only buys.\n\nENTRY " + f_px(t1Ent) + "    SL " + f_px(t1Sl) + "    TP1 " + f_px(t1Tp1) + "\nRisk " + f_pips(t1Ent - t1Sl) + " pips    Reward " + f_pips(t1Tp1 - t1Ent) + " pips    " + str.tostring(t1RrVal, "#.00") + "R"

if fireT1 and t1Fired and setupDir == -1
    label.new(bar_index, high, "  SELL ▼  \n" + str.tostring(t1RrVal, "#.0") + "R · ASIA SWEEP + " + t1Trig, style = label.style_label_down, color = cSell, textcolor = cTxt, size = pillSz, tooltip = whyT1)
if fireT1 and t1Fired and setupDir == 1
    label.new(bar_index, low, "  BUY ▲  \n" + str.tostring(t1RrVal, "#.0") + "R · ASIA SWEEP + " + t1Trig, style = label.style_label_up, color = cBuy, textcolor = cTxt, size = pillSz, tooltip = whyT1)

whyT2 = "WHY THIS CONTINUATION?\n1) The London raid broke the OPPOSITE side of the Asian range with displacement.\n2) That makes " + f_px(contA) + " the likely high or low of the day - a strong extreme built by a sweep followed by a break of structure.\n3) New York retraced into the " + str.tostring(i_oteEntry) + " optimal trade entry of the impulse " + f_px(contA) + " to " + f_px(contB) + ".\n4) " + (swpPoi4h ? "The origin POI was a 4H POI, so the whole day is a 4H market maker model running internal to external." : "The origin POI was not a 4H POI, so expect a smaller continuation.") + "\n\nENTRY " + f_px(oteEnt) + "    SL " + f_px(setupDir == -1 ? oteStp + i_slBuf * atr : oteStp - i_slBuf * atr) + "\nTarget is the draw on liquidity beyond the range."

if fireT2 and setupDir == -1
    label.new(bar_index, high, "  SELL ▼  \nNY OTE " + str.tostring(i_oteEntry) + " · CONTINUATION", style = label.style_label_down, color = cSell, textcolor = cTxt, size = pillSz, tooltip = whyT2)
if fireT2 and setupDir == 1
    label.new(bar_index, low, "  BUY ▲  \nNY OTE " + str.tostring(i_oteEntry) + " · CONTINUATION", style = label.style_label_up, color = cBuy, textcolor = cTxt, size = pillSz, tooltip = whyT2)

plotshape(fireT1 and t1Fired and setupDir == -1, "SELL London sweep", shape.triangledown, location.abovebar, cRed, size = size.tiny, display = display.pane)
plotshape(fireT1 and t1Fired and setupDir == 1, "BUY London sweep", shape.triangleup, location.belowbar, cMint, size = size.tiny, display = display.pane)
plotshape(fireT2 and setupDir == -1, "SELL NY OTE", shape.triangledown, location.abovebar, cPink, size = size.tiny, display = display.pane)
plotshape(fireT2 and setupDir == 1, "BUY NY OTE", shape.triangleup, location.belowbar, cLime, size = size.tiny, display = display.pane)

// --- education cards
var label cardA = na
var label cardB = na
if i_eduCard and barstate.islast
    label.delete(cardA)
    label.delete(cardB)
    cardA := label.new(bar_index + 14, hi300, "HOW TO READ THIS", style = label.style_label_left, color = color.new(cSect, 15), textcolor = cGold, size = size.small, tooltip = "HOW TO READ ASIA SESSION SWEEP PRO\n\n1  GOLD BOX = the Asian range, 20:00 to 00:00 New York. Its high and its low are the two liquidity pools the rest of the day was built to attack.\n\n2  RED AND GREEN ZONES = higher timeframe points of interest on 15m, 1h and 4h: fair value gap, order block, breaker block, inverse fair value gap. A raid that lands inside one of them is the high probability version of the trade.\n\n3  CYAN SHADE = the London kill zone, 02:00 to 05:00. Trade 1 can only fire inside it.\n\n4  PINK SHADE = the New York kill zone, 07:00 to 10:00, where the OTE continuation is taken.\n\n5  PILL = the signal. Hover it and it lists every single reason the trade exists, plus entry, stop and both targets.\n\n6  DASHED GOLD, PINK AND MINT = entry, stop, targets. TP1 is always the opposite side of the Asian range.\n\n7  AR HIGH PROTECTED = a no sweep day. The raid you are waiting for will most likely never come. Trade the 50% of the range instead.\n\n8  Every label on this chart carries a tooltip that explains what it is and why it matters.")
    cardB := label.new(bar_index + 14, lo300, "BEFORE YOU TRADE THIS", style = label.style_label_left, color = color.new(cSect, 15), textcolor = cCyan, size = size.small, tooltip = "HONEST EXPECTATIONS\n\n· The model is mechanical only up to the trigger. Direction is fixed - sell above the range, buy below it, never the other way round. The final decision, is this really the high of the session, stays discretionary.\n\n· You will not be good at this on day one. The sweep needs screen time on the 15m and 5m of the Asian range before the pattern becomes obvious.\n\n· Expect zero to four trades a day across two pairs, roughly 20 pips average per trade, and losing days. Judge the model weekly and monthly, never daily.\n\n· The safest entry, a 15m fair value gap, has the highest hit rate and the smallest reward. The riskiest, a 1m market structure shift with a fair value gap, has the biggest reward and the most stop outs. Pick one and stay with it.\n\n· High impact US news in the New York session: do not trade London that day.\n\nThis indicator is a study tool. It is not financial advice.")

// ═════════════════════════════════════════════════════════════════════════════════════════
//  COCKPIT PANEL
// ═════════════════════════════════════════════════════════════════════════════════════════
f_stat(bool ok, bool run) => ok ? "OK" : run ? "RUN" : "‥"
f_statc(bool ok, bool run) => ok ? cMint : run ? cGold : cGrey

// live ticker for the animated chevron row in the panel header
varip int glint = 0
if barstate.isrealtime
    glint := (glint + 1) % 8

var table pan = na
if i_panOn and barstate.islast
    psz = f_sizeOf(i_panSize)
    if na(pan)
        pan := table.new(f_posOf(i_panPos), 8, 30, bgcolor = cPanel, frame_color = color.new(cGold, 60), frame_width = 1, border_color = color.new(cSect, 40), border_width = 1)
    for r = 0 to 29
        for c = 0 to 7
            table.cell(pan, c, r, "", bgcolor = cPanel, text_size = size.tiny)

    table.cell(pan, 0, 0, "ASIA SESSION SWEEP PRO", text_color = cGold, text_size = psz, bgcolor = cSect, text_halign = text.align_left)
    table.merge_cells(pan, 0, 0, 6, 0)
    table.cell(pan, 7, 0, barstate.isrealtime ? "●" : "○", text_color = cCyan, text_size = psz, bgcolor = cSect)
    table.cell(pan, 0, 1, "ICT asian range liquidity model", text_color = cCyan, text_size = size.tiny, bgcolor = cPanel)
    table.merge_cells(pan, 0, 1, 7, 1)

    string anim = ""
    for c = 0 to 7
        anim := anim + (c == glint ? "◆" : "▲")
    table.cell(pan, 0, 2, anim, text_color = cMint, text_size = size.tiny, bgcolor = cPanel)
    table.merge_cells(pan, 0, 2, 7, 2)

    sesTxt = inAsia ? "ASIAN RANGE FORMING" : inLon ? "LONDON KILL ZONE" : inNy ? "NEW YORK KILL ZONE" : "OUT OF SESSION"
    sesCol = inAsia ? cGold : inLon ? cCyan : inNy ? cPink : cGrey
    table.cell(pan, 0, 3, sesTxt, text_color = sesCol, text_size = psz, bgcolor = cSect)
    table.merge_cells(pan, 0, 3, 7, 3)

    table.cell(pan, 0, 4, "SYMBOL", text_color = cGrey, text_size = size.tiny, bgcolor = cPanel, text_halign = text.align_left)
    table.merge_cells(pan, 0, 4, 1, 4)
    table.cell(pan, 2, 4, syminfo.ticker, text_color = cTxt, text_size = size.tiny, bgcolor = cPanel, text_halign = text.align_left)
    table.merge_cells(pan, 2, 4, 3, 4)
    table.cell(pan, 4, 4, "CHART TF", text_color = cGrey, text_size = size.tiny, bgcolor = cPanel, text_halign = text.align_left)
    table.merge_cells(pan, 4, 4, 5, 4)
    table.cell(pan, 6, 4, f_tfLbl(timeframe.period), text_color = cTxt, text_size = size.tiny, bgcolor = cPanel, text_halign = text.align_left)
    table.merge_cells(pan, 6, 4, 7, 4)

    table.cell(pan, 0, 5, "HTF BIAS", text_color = cGrey, text_size = size.tiny, bgcolor = cPanel, text_halign = text.align_left)
    table.merge_cells(pan, 0, 5, 1, 5)
    table.cell(pan, 2, 5, htfBias > 0 ? "BULLISH" : htfBias < 0 ? "BEARISH" : "NEUTRAL", text_color = htfBias > 0 ? cMint : htfBias < 0 ? cRed : cGrey, text_size = size.tiny, bgcolor = cPanel, text_halign = text.align_left)
    table.merge_cells(pan, 2, 5, 3, 5)
    table.cell(pan, 4, 5, "ENTRY", text_color = cGrey, text_size = size.tiny, bgcolor = cPanel, text_halign = text.align_left)
    table.merge_cells(pan, 4, 5, 5, 5)
    table.cell(pan, 6, 5, str.substring(i_model, 0, 4), text_color = cTxt, text_size = size.tiny, bgcolor = cPanel, text_halign = text.align_left)
    table.merge_cells(pan, 6, 5, 7, 5)

    table.cell(pan, 0, 6, "", bgcolor = color.rgb(6, 17, 30))
    table.merge_cells(pan, 0, 6, 7, 6)

    table.cell(pan, 0, 7, "ASIAN RANGE", text_color = cGold, text_size = size.tiny, bgcolor = cSect, text_halign = text.align_left)
    table.merge_cells(pan, 0, 7, 7, 7)
    table.cell(pan, 0, 8, "HIGH", text_color = cGrey, text_size = size.tiny, bgcolor = cPanel, text_halign = text.align_left)
    table.merge_cells(pan, 0, 8, 2, 8)
    table.cell(pan, 3, 8, arOk ? f_px(arH) : "—", text_color = cSupply, text_size = size.tiny, bgcolor = cPanel)
    table.merge_cells(pan, 3, 8, 5, 8)
    table.cell(pan, 6, 8, highProtected ? "PROT" : "OPEN", text_color = highProtected ? cGold : cMint, text_size = size.tiny, bgcolor = cPanel)
    table.merge_cells(pan, 6, 8, 7, 8)
    table.cell(pan, 0, 9, "50%", text_color = cGrey, text_size = size.tiny, bgcolor = cPanel, text_halign = text.align_left)
    table.merge_cells(pan, 0, 9, 2, 9)
    table.cell(pan, 3, 9, arOk ? f_px(arMid) : "—", text_color = cPink, text_size = size.tiny, bgcolor = cPanel)
    table.merge_cells(pan, 3, 9, 7, 9)
    table.cell(pan, 0, 10, "LOW", text_color = cGrey, text_size = size.tiny, bgcolor = cPanel, text_halign = text.align_left)
    table.merge_cells(pan, 0, 10, 2, 10)
    table.cell(pan, 3, 10, arOk ? f_px(arL) : "—", text_color = cDemand, text_size = size.tiny, bgcolor = cPanel)
    table.merge_cells(pan, 3, 10, 5, 10)
    table.cell(pan, 6, 10, lowProtected ? "PROT" : "OPEN", text_color = lowProtected ? cGold : cMint, text_size = size.tiny, bgcolor = cPanel)
    table.merge_cells(pan, 6, 10, 7, 10)
    table.cell(pan, 0, 11, "SIZE", text_color = cGrey, text_size = size.tiny, bgcolor = cPanel, text_halign = text.align_left)
    table.merge_cells(pan, 0, 11, 2, 11)
    table.cell(pan, 3, 11, arOk ? f_pips(arRange) + " pips" : "—", text_color = cTxt, text_size = size.tiny, bgcolor = cPanel)
    table.merge_cells(pan, 3, 11, 7, 11)

    table.cell(pan, 0, 12, "", bgcolor = color.rgb(6, 17, 30))
    table.merge_cells(pan, 0, 12, 7, 12)

    table.cell(pan, 0, 13, "CHECKLIST", text_color = cGold, text_size = size.tiny, bgcolor = cSect, text_halign = text.align_left)
    table.merge_cells(pan, 0, 13, 7, 13)
    chkTxt = array.from("❶ Asian range built", "❷ HTF structure aligned", "❸ HTF POI available", "❹ Kill zone open", "❺ Liquidity raided", "❻ FVG validation", "❼ LTF confirmation", "❽ Range broken (T2)")
    chkOk = array.from(arOk, htfBias != 0, array.size(pTop) > 0, inLon or inNy, swept, swpFvgOk, t1Fired, rangeBroken)
    chkRun = array.from(inAsia, false, false, false, false, swept, swept, swept)
    for r = 0 to 7
        table.cell(pan, 0, 14 + r, array.get(chkTxt, r), text_color = cTxt, text_size = size.tiny, bgcolor = cPanel, text_halign = text.align_left)
        table.merge_cells(pan, 0, 14 + r, 5, 14 + r)
        table.cell(pan, 6, 14 + r, f_stat(array.get(chkOk, r), array.get(chkRun, r)), text_color = f_statc(array.get(chkOk, r), array.get(chkRun, r)), text_size = size.tiny, bgcolor = cPanel)
        table.merge_cells(pan, 6, 14 + r, 7, 14 + r)

    table.cell(pan, 0, 22, "", bgcolor = color.rgb(6, 17, 30))
    table.merge_cells(pan, 0, 22, 7, 22)

    posTxt = t1Live ? (setupDir == -1 ? "SHORT " : "LONG ") + f_px(t1Ent) + "  SL " + f_px(t1Sl) + "  TP " + f_px(t1Tp1) : t2Live ? (setupDir == -1 ? "SHORT " : "LONG ") + "OTE " + f_px(t2Ent) + "  SL " + f_px(t2Sl) : "NO POSITION"
    table.cell(pan, 0, 23, posTxt, text_color = t1Live or t2Live ? cGold : cGrey, text_size = size.tiny, bgcolor = cSect)
    table.merge_cells(pan, 0, 23, 7, 23)

    sigTxt = t1State == "TP1 HIT" ? "TP HIT" : t1State == "SL HIT" ? "SL HIT" : t1State == "BE" ? "BREAK EVEN" : t1Live ? (setupDir == -1 ? "SHORT RUNNING" : "LONG RUNNING") : t2Live ? "OTE RUNNING" : blockMsg != "" ? "SKIPPED" : swept ? "SWEPT · WAIT TRIGGER" : inLon and arOk ? "HUNTING" : arOk ? "ARMED" : "BUILDING RANGE"
    sigCol = t1State == "TP1 HIT" ? cMint : t1State == "SL HIT" ? cRed : t1Live or t2Live ? cGold : swept ? cCyan : cGrey
    table.cell(pan, 0, 24, sigTxt, text_color = sigCol, text_size = size.large, bgcolor = cPanel)
    table.merge_cells(pan, 0, 24, 7, 24)

    table.cell(pan, 0, 25, blockMsg != "" ? blockMsg : "POI " + str.tostring(array.size(pTop)) + "   ·   W " + str.tostring(wins) + "   L " + str.tostring(losses) + "   BE " + str.tostring(bes) + (newsDay ? "   ·   NEWS DAY" : ""), text_color = blockMsg != "" ? cGold : newsDay ? cGold : cGrey, text_size = size.tiny, bgcolor = cPanel)
    table.merge_cells(pan, 0, 25, 7, 25)

    table.cell(pan, 0, 26, "", bgcolor = color.rgb(6, 17, 30))
    table.merge_cells(pan, 0, 26, 7, 26)

    table.cell(pan, 0, 27, "", bgcolor = color.rgb(6, 17, 30))
    table.merge_cells(pan, 0, 27, 7, 27)

    table.cell(pan, 0, 28, na(lastSigT) ? "● LIVE  ·  webhook JSON ready" : "LAST SIGNAL  " + lastSigS + "  ·  " + str.format_time(lastSigT, "dd MMM HH:mm", i_tz), text_color = cCyan, text_size = size.tiny, bgcolor = cPanel)
    table.merge_cells(pan, 0, 28, 7, 28)
    table.cell(pan, 0, 29, "study tool  ·  not financial advice", text_color = cGrey, text_size = size.tiny, bgcolor = cPanel)
    table.merge_cells(pan, 0, 29, 7, 29)

// ═════════════════════════════════════════════════════════════════════════════════════════
//  WEBHOOK / ALERTS
// ═════════════════════════════════════════════════════════════════════════════════════════
f_json(string ev, string side, float ent, float sl, float tp1, float tp2, string note) =>
    '{"strategy":"' + i_hookId + '","event":"' + ev + '","side":"' + side + '","symbol":"' + syminfo.ticker + '","exchange":"' + syminfo.prefix + '","tf":"' + timeframe.period + '","price":' + str.tostring(close, format.mintick) + ',"entry":' + (na(ent) ? "null" : str.tostring(ent, format.mintick)) + ',"sl":' + (na(sl) ? "null" : str.tostring(sl, format.mintick)) + ',"tp1":' + (na(tp1) ? "null" : str.tostring(tp1, format.mintick)) + ',"tp2":' + (na(tp2) ? "null" : str.tostring(tp2, format.mintick)) + ',"volume":"' + i_hookLot + '","account":"' + i_hookAcc + '","ar_high":' + (na(arH) ? "null" : str.tostring(arH, format.mintick)) + ',"ar_low":' + (na(arL) ? "null" : str.tostring(arL, format.mintick)) + ',"poi":"' + swpPoi + '","note":"' + note + '","time":' + str.tostring(time) + '}'

if i_hookOn and fireT1 and t1Fired
    alert(f_json("ENTRY", setupDir == -1 ? "SELL" : "BUY", t1Ent, t1Sl, t1Tp1, t1Tp2, "London asian sweep " + t1Trig), alert.freq_once_per_bar_close)
if i_hookOn and fireT2
    alert(f_json("ENTRY", setupDir == -1 ? "SELL" : "BUY", t2Ent, t2Sl, t2Tp, na, "New York OTE continuation"), alert.freq_once_per_bar_close)
if i_hookOn and hitTp
    alert(f_json("TP1", setupDir == -1 ? "SELL" : "BUY", t1Ent, t1Sl, t1Tp1, t1Tp2, "target reached"), alert.freq_once_per_bar_close)
if i_hookOn and hitSl
    alert(f_json("SL", setupDir == -1 ? "SELL" : "BUY", t1Ent, t1Sl, t1Tp1, t1Tp2, "stop hit"), alert.freq_once_per_bar_close)
if i_hookOn and hitBe
    alert(f_json("BE", setupDir == -1 ? "SELL" : "BUY", t1Ent, t1Ent, t1Tp1, t1Tp2, "moved to break even"), alert.freq_once_per_bar_close)
if i_hookOn and swept and bar_index == swpBar
    alert(f_json("SWEEP", setupDir == -1 ? "SELL" : "BUY", na, na, na, na, "asian " + (setupDir == -1 ? "high" : "low") + " raided" + (swpPoi != "" ? " into " + swpPoi : "")), alert.freq_once_per_bar_close)
if i_hookOn and asiaClose
    alert(f_json("RANGE", "NONE", na, na, na, na, "asian range set"), alert.freq_once_per_bar_close)

alertcondition(fireT1 and setupDir == -1, "SELL · London asian sweep", "ASIA SWEEP PRO: SELL - the asian high was raided into a HTF POI")
alertcondition(fireT1 and setupDir == 1, "BUY · London asian sweep", "ASIA SWEEP PRO: BUY - the asian low was raided into a HTF POI")
alertcondition(fireT2, "OTE continuation", "ASIA SWEEP PRO: New York OTE continuation")
alertcondition(swept and bar_index == swpBar, "Asian liquidity raided", "ASIA SWEEP PRO: the asian range liquidity has been raided")
alertcondition(asiaClose, "Asian range complete", "ASIA SWEEP PRO: the asian range is set")

plot(arOk ? arH : na, "AR High", color.new(cSupply, 100), display = display.data_window)
plot(arOk ? arL : na, "AR Low", color.new(cDemand, 100), display = display.data_window)
plot(arOk ? arMid : na, "AR 50%", color.new(cPink, 100), display = display.data_window)
````
