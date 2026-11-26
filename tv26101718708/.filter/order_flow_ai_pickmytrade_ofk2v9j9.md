# Order Flow AI [Pickmytrade]

- url: https://www.tradingview.com/script/ofk2v9j9-Order-Flow-AI-Pickmytrade/
- type: indicator
- pine_id: PUB;d25674735a3d4b78bb85e89b0b505113
- version: 2.0

## Description

Does strong estimated buying or selling move price, or meet limited response? Order Flow AI compares directional activity with candle movement, maps its price distribution, and learns what followed similar marked events.

――――――――――――――――――――

🔷 WHAT THE CHART SHOWS
🔸 Blue represents estimated buying, orange selling, and grey unresolved neutral volume. Lower-timeframe up/down candles classify volume as buying/selling. Dojis compare with the previous intrabar close, then inherit the last resolved direction; initially unresolved observations remain neutral.
🔸 Circles mark DRIVE: strong estimated pressure with aligned candle-body movement. Diamonds mark RESISTED: pressure with limited or opposing movement. Buying resisted can accompany falling price; selling resisted can accompany rising price. Neither confirms absorption or instructs an entry.
🔸 Default marks require ≥25% absolute estimated imbalance and ≥1.2× relative volume. DRIVE requires ≥0.35 prior ATR aligned response; RESISTED requires ≤0.10 ATR. Intermediate responses receive no mark. Shared spacing is three bars.
🔸 The response measures close minus open, normalized by the previous bar’s 14-period ATR. Opening gaps are excluded. Relative volume compares with the 30 immediately preceding chart bars, all requiring usable source data.

――――――――――――――――――――

🔷 PROFILE AND DISTRIBUTION RIBBON
🔸 The profile places selling left, buying right, and neutral volume in grey. A pale outline marks the highest-volume approximate bin. Peak-row depth faces are decorative, not confidence readings.
🔸 Contributions are allocated once to intrabar HLC3, or cached side-group weighted HLC3. This approximates volume at price. Both sides share a width scale; rounding and minimum one-bar widths enlarge tiny segments.
🔸 The ribbon shows a rolling volume-weighted HLC3 mean and three translucent layers extending to one weighted standard deviation. At least 80% of its window needs usable source data. Colour follows net classified volume, grey near balance. Its bounds are descriptive, not defended levels or projected targets; its mean is not session-anchored VWAP.
🔸 The default profile samples 48 chart bars ending at the rightmost visible closed candle. Panning rebuilds this sample and selects historical dashboard readings; it does not profile every visible candle.

――――――――――――――――――――

🔷 REAL OUTCOME LEARNING
🔸 AI here means an optional, distance-weighted k-nearest-neighbour ML classifier that learns from resolved DRIVE/RESISTED cases, collecting eligible examples during warm-up and abstention. No external classifier or pretrained AI model is imported. Its historical similarity vote is not a guarantee of future movement.
🔸 Seven features, normalized to 0–1: absolute imbalance, relative activity, aligned body response, pressure-side wick, aligned close location, signed distance from flow mean, and aligned rolling volume share. Buying/selling use comparable pressure-relative coordinates.
🔸 Features, origin close and prior ATR freeze at the confirmed event close. From the NEXT bar, ±0.75 frozen ATR barriers define continuation if the pressure-side barrier is first, opposition if the other is first. The twelfth later bar counts. Same-candle double touches, timeouts and invalid outcome prices are discarded.
🔸 Only already-resolved cases train the classifier. Exact K nearest cases use mean log(1 + absolute feature difference) across seven features. This Lorentzian-style similarity does not model spacetime or detect news.
🔸 Inverse-distance weights favour nearer cases. Effective neighbour weight count controls shrinkage toward base rate (continuations + 1) / (library size + 2). The library retains the latest 240 resolved cases.
🔸 Warm-up requires 40 resolved cases and both outcomes. All selected neighbours must pass the 0.16 mean log-distance ceiling; otherwise the engine reports LEARNING, NEED BOTH OUTCOMES or NO CLOSE ANALOGUE.

――――――――――――――――――――

🔷 READING THE ML VALUE
🔸 C means historical continuation vote in the original pressure direction; lower values favour opposition. Discarded cases do not vote: the reading is CONDITIONAL on a decisive outcome within the deadline, not a calibrated probability for every event or a trade win rate.
🔸 Vote and baseline freeze at the event close and are never backfilled. The dashboard identifies that event’s age and spells out its continuation vote. Between the two configured thresholds it says “no threshold met”. Optional diagnostics show library, base and decisive/discarded counts. C badges preserve pressure colour; circles/diamonds still describe observed response.
🔸 The chart guide explains all four markers. Blue circle: buying pressure moved price up. Orange circle: selling pressure moved price down. Blue diamond: buying met small or opposing response. Orange diamond: selling met small or opposing response. Colours describe estimated pressure, not automatic entry orders.
🔸 Short shaded rectangles highlight past resisted candles. Profile rectangles represent estimated volume at price. “SELL VOL” / “BUY VOL” identify the volume sides; neither the shelves nor profile bars are entry signals. The guide can be hidden independently of the dashboard.
🔸 Research diagnostics compare saved votes with later outcomes using Brier error and the frozen base. Overlapping cases are dependent. A fixed 30-day BTCUSDT/ETHUSDT 15m reconstruction did not outperform the baseline on either symbol; no trading edge is established.

――――――――――――――――――――

🔷 ALERTS AND AUTOMATION
🔸 Six informational conditions: Buying pressure drives price; Selling pressure drives price; Buying pressure resisted; Selling pressure resisted; ML continuation vote above threshold; ML opposition vote above threshold.
🔸 Create the required TradingView alert using Once Per Bar Close. Default ML thresholds are C ≥65% for continuation and C ≤35% for opposition. Messages identify the ticker and interval.
🔸 External automation requires compatible messages, execution rules and receiver testing. There are no orders, stops, targets or built-in execution payloads; no execution integration was tested. Outcome barriers are learning labels, not trade exits.

――――――――――――――――――――

🔷 SETTINGS AND PRACTICAL USE
🔸 Defaults: Automatic source on / Custom 1m; ribbon window 20; profile 48 bars / 24 rows; Inside chart placement / half-width 18 / offset 6.
🔸 Pressure defaults: imbalance 0.25; relative volume 1.2; drive response 0.35; resisted ceiling 0.10; spacing 3 bars.
🔸 ML defaults: learning on; K 9; library 240; warm-up 40; shrinkage 4; distance ceiling 0.16; barrier 0.75 prior ATR; deadline 12 bars; vote threshold 0.65; historical badges off.
🔸 Ribbon, profile, depth, shelves, dashboard and chart guide default on; diagnostics default off. Blue/orange colours are configurable. Shelves annotate eight recent resisted events, extending up to eight bars; they are not validated levels. The guide draws above candles; inside-chart profile shading is kept lighter to preserve candle visibility.
🔸 Publication cover mode defaults off. It replaces the large dashboard with a short viewport-anchored title and a compact colour/shape key, strengthens ribbon contrast and places the profile to the right of candles. Leave sufficient right margin. It does not alter pressure events, ML features, outcomes, training or alerts. Switch it off to restore the full chart guide.
🔸 Use standard candles and inspect diagnostics first. Inside chart keeps the profile visible; Right of candles needs right margin. Shelves/dashboard can be hidden.
🔸 Cover: BTCUSDT 15m / 1m source, profile 72 bars / 24 rows, width 22 / offset 3, cover title 64 pixels and enough right margin for the profile; shelves hidden. The heading and compact key are generated by Pine. These display settings illustrate the tool, not optimized trading parameters.

――――――――――――――――――――

🔷 REQUIREMENTS AND LIMITATIONS
🔸 Volume direction is inferred, not measured bid/ask, native footprint, resting liquidity or identified institutions. Some feeds supply tick volume.
🔸 Automatic selects 1m through 1h charts, 5m through 4h, 15m through 1D, 60m through 1W, and daily above 1W. The source must be strictly smaller than the chart timeframe; charts of 1m or faster require a supported finer custom source.
🔸 Missing/invalid source bars receive no fabricated volume. Bars above 3,000 intrabars are excluded. Profile caching uses at most 120 consecutive groups per chart bar, preserving side totals while reducing price detail. Index-based drawings are limited to roughly 4,900 bars back, within an explicitly reserved time buffer.
🔸 Marks/ML commit at confirmed closes; open candles retain the previous closed ribbon. Learning is chronological and viewport-independent. Intrabar history requests cap at 100,000, subject to account/feed availability; returned counts do not prove completeness. Reloads, more history, settings and feed corrections can alter reconstruction.

Built in Pine Script v6 under Mozilla Public License 2.0. This original implementation applies established price-based volume classification, weighted distributions and nearest-neighbour learning. It makes no claim of unique invention, guaranteed performance or Editor’s Choice selection.

## Source Code

````pine
//@version=6
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0.
// © PickMyTrade
// Original implementation, version 2.0.0. 10 October 2026. Managed model entries and exits.
// Buy/sell volume is inferred from intrabar price movement, not measured bid/ask trades.
// Profile bins intrabar HLC3 or cached side-group weighted HLC3. No order-book claim.
// ML uses only already-resolved cases. Its vote is conditional on decisive outcomes.
indicator("Order Flow AI [Pickmytrade]", "Flow AI", overlay = true, behind_chart = false, max_boxes_count = 180, max_lines_count = 30, max_labels_count = 240, max_polylines_count = 30)
// Index-based drawings internally need time history. Reserve it explicitly for
// historical shelves/profile anchors, whose age is not inferable on early bars.
max_bars_back(time, 5000)

const string G_DATA = "01 · Intrabar data"
const string G_IMPACT = "02 · Effort and response"
const string G_VIEW = "03 · Chart presentation"
const string G_ML = "04 · Outcome learning (ML)"
const string G_PUB = "05 · Publication presentation"
const string G_PLAN = "06 · Managed entry plan"
const string G_RISK = "07 · Model exit plan"

bool autoTfInput = input.bool(true, "Automatic intrabar timeframe", group = G_DATA, tooltip = "1 minute on charts above 1m through 1h; 5m through 4h; 15m through 1D; 60m through 1W; 1D above 1W. On 1m or faster charts choose a smaller custom timeframe supported by your account.")
string customTfInput = input.timeframe("1", "Custom intrabar timeframe", group = G_DATA, tooltip = "Used when Automatic is off. Must be strictly smaller than the chart timeframe. Seconds data depends on plan and feed availability.")
int flowWindowInput = input.int(20, "Flow distribution window", minval = 5, maxval = 80, group = G_DATA, tooltip = "Rolling chart bars for the volume-weighted intrabar HLC3 mean and standard deviation. The ribbon requires complete valid data on at least 80% of these bars.")
int profileWindowInput = input.int(48, "Side profile window", minval = 12, maxval = 120, group = G_DATA, tooltip = "Exactly this many most recent closed chart bars, including missing-data bars. At most 120 consecutive intrabar groups per chart bar are cached; group side volumes use separate weighted prices.")
float dominanceInput = input.float(0.25, "Minimum directional volume share", minval = 0.05, maxval = 0.9, step = 0.05, group = G_IMPACT, tooltip = "Absolute estimated delta divided by buy + sell + neutral volume. 0.25 means a 25% net imbalance in classified volume, not a future probability.")
float rvolInput = input.float(1.2, "Minimum relative volume", minval = 0.5, maxval = 4, step = 0.1, group = G_IMPACT, tooltip = "Current classified volume divided by its prior 30-bar average. Missing or invalid source bars disable events until a full valid baseline is available.")
float driveInput = input.float(0.35, "Drive response (ATR)", minval = 0.15, maxval = 2, step = 0.05, group = G_IMPACT, tooltip = "A DRIVE needs the chart candle body to move with estimated delta by at least this multiple of the prior candle's ATR.")
float resistedInput = input.float(0.10, "Resisted response ceiling (ATR)", minval = 0, maxval = 0.3, step = 0.05, group = G_IMPACT, tooltip = "Heavy directional activity with a body response no greater than this amount in its direction. Includes movement AGAINST the pressure. This is inferred resistance, not proven absorption or a reversal signal.")
int spacingInput = input.int(3, "Minimum bars between event marks", minval = 1, maxval = 20, group = G_IMPACT, tooltip = "One shared spacing rule across all four event types. An event can fire again when at least this many bars have passed.")
bool ribbonInput = input.bool(true, "Flow distribution ribbon", group = G_VIEW, tooltip = "Neutral mean plus three translucent layers out to one volume-weighted standard deviation. These describe intrabar HLC3 distribution, not support/resistance or predicted bounds.")
bool profileInput = input.bool(true, "Buy / sell side profile", group = G_VIEW, tooltip = "Rolling classified intrabar HLC3 profile. Orange sell left; blue buy right; grey neutral appended to the right. Widths use one shared maximum. Positive widths have a one-bar minimum for visibility.")
string placementInput = input.string("Inside chart", "Profile placement", options = ["Inside chart", "Right of candles"], group = G_VIEW, tooltip = "Inside chart stays within the visible candle area and reduces width when zoomed in. Right of candles requires extra right margin. The profile follows the rightmost visible closed candle when you pan.")
int rowsInput = input.int(24, "Profile rows", minval = 12, maxval = 36, group = G_VIEW, tooltip = "Fixed equal-price bins across the cached intrabar sample range. Volume is allocated once per side group to its weighted price; this is an approximation of volume-at-price.")
int widthInput = input.int(18, "Profile half-width (bars)", minval = 8, maxval = 28, group = G_VIEW)
int offsetInput = input.int(6, "Space after candles (bars)", minval = 2, maxval = 20, group = G_VIEW)
bool depthInput = input.bool(true, "Profile depth shading", group = G_VIEW, tooltip = "Decorative top and side faces on peak-row segments only. Faces do not encode confidence or additional volume.")
bool zonesInput = input.bool(true, "Resisted-event highlights", group = G_VIEW, tooltip = "Show the latest eight event markers as short translucent shelves around their candle bodies. They are historical annotations, not tested future trading levels.")
bool dashboardInput = input.bool(true, "Dashboard and chart guide", group = G_VIEW, tooltip = "Shows the managed plan, active risk references, last exit reason, chart key and last raw event's frozen ML read. The ML vote belongs to that historical pressure event, not every later candle or broker position.")
bool researchInput = input.bool(false, "Show model and data diagnostics", group = G_VIEW, tooltip = "Adds library size, decisive/discarded counts, historical base rate/Brier score, managed entry/exit counts, suppressed same-side events and ambiguous stop-first counts. These are diagnostics, not broker performance.")
color buyInput = input.color(#246BFF, "Classified buying", group = G_VIEW)
color sellInput = input.color(#FF8A18, "Classified selling", group = G_VIEW)
bool mlInput = input.bool(true, "Learn pressure outcomes", group = G_ML, tooltip = "A distance-weighted k-nearest-neighbour classifier learns from the DRIVE / RESISTED events marked by this script. It compares prior resolved cases only. No trained external AI, native bid/ask feed or guaranteed predictive edge.")
int neighboursInput = input.int(9, "K neighbours", minval = 3, maxval = 21, group = G_ML, tooltip = "The exact K nearest feature vectors vote. Every selected neighbour must pass the distance ceiling. Equal-distance ties favour newer resolved cases.")
int libraryInput = input.int(240, "Resolved-case library", minval = 100, maxval = 400, group = G_ML, tooltip = "Keep this many most recently resolved cases. Ambiguous and timed-out cases never enter this library. A chart reload rebuilds it from available intrabar history.")
int warmupInput = input.int(40, "Minimum resolved cases", minval = 20, maxval = 100, group = G_ML, tooltip = "Below this count the engine reads LEARNING. Both outcome classes must also be present. Sample collection continues while the model abstains.")
float shrinkInput = input.float(4.0, "Base-rate shrinkage", minval = 0, maxval = 20, step = 0.5, group = G_ML, tooltip = "Pull the weighted vote toward the library's smoothed continuation base rate. Uses effective neighbour weight count to account for weight concentration. Neighbour cases can overlap; they are not independent observations.")
float distanceInput = input.float(0.16, "Maximum mean log-distance", minval = 0.01, maxval = 0.70, step = 0.01, group = G_ML, tooltip = "Average of log(1 + absolute feature difference) over seven features scaled to 0–1. If the Kth nearest case exceeds this ceiling, say NO CLOSE ANALOGUE. Smaller is stricter; this is not a learned or optimized distance threshold.")
float barrierInput = input.float(0.75, "Outcome distance (prior ATR)", minval = 0.25, maxval = 3, step = 0.05, group = G_ML, tooltip = "Freeze symmetric barriers this far from the event's CLOSE, using its prior-bar ATR. From the NEXT bar: pressure-side first = continuation, opposite-side first = opposition. Both touched on one candle = ambiguous; no assumed intrabar order. These are labels, not trade targets or stops.")
int horizonInput = input.int(12, "Outcome deadline (bars)", minval = 3, maxval = 50, group = G_ML, tooltip = "A case must touch one barrier within this many later chart bars. Touches on the final bar still count. Otherwise discard it as a timeout. Votes describe decisive cases, not all pressure events.")
float convictionInput = input.float(0.65, "Historical vote threshold", minval = 0.55, maxval = 0.90, step = 0.05, group = G_ML, tooltip = "When the optional managed ML gate is on, this event needs a continuation vote at/above this threshold. The historical vote is not a calibrated probability; no raw-pressure ML trading alert is emitted.")
bool mlBadgesInput = input.bool(false, "Historical ML badges", group = G_ML, tooltip = "Optional compact percentages beside scored event marks. At most 24 recent badges. Frozen when the event closes; never filled in later after warmup. Colour still denotes the original pressure side. Hidden by default to keep the cover readable.")
bool legendInput = input.bool(true, "Explain chart marks in dashboard", group = G_VIEW, tooltip = "Explains BUY, SELL, EXIT BUY and EXIT SELL model labels, optional raw-pressure marks, profile bars and risk references. Profile colours classify estimated volume; an orange profile bar is not a SELL entry.")
bool publicationInput = input.bool(false, "Publication cover mode", group = G_PUB, tooltip = "A short, viewport-anchored heading, stronger ribbon contrast and a compact action-text key replace the large research dashboard. Right-side profile placement gives the histogram its own space; leave enough chart margin. Changes presentation only: events, ML features, training and alerts are unchanged. Turn it off for the full chart guide.")
int coverTitleSizeInput = input.int(52, "Cover title size", minval = 32, maxval = 80, step = 4, group = G_PUB, tooltip = "Font size in pixels for the short ORDER FLOW AI heading. It is anchored to the chart viewport rather than a price/date. 64 is intended for a full-width publication chart; reduce it if using a small window.")

bool managedInput = input.bool(true, "Managed BUY / SELL and exits", group = G_PLAN, tooltip = "One hypothetical position plan at a time. BUY/SELL are confirmed-close entry intents; model fills use the NEXT bar open. EXIT BUY/EXIT SELL close the plan separately. This indicator cannot observe broker fills or positions.")
bool rawMarksInput = input.bool(false, "Show raw pressure circles / diamonds", group = G_VIEW, tooltip = "Optional v1 analysis marks. These are pressure observations, not managed entries or exits; they do not generate trading alerts.")
bool planLevelsInput = input.bool(true, "Show active entry / SL / TP references", group = G_VIEW, tooltip = "Show only the active model's levels at the visible endpoint. Broker-native orders can fill differently; a line is not a working broker order.")
bool exitReasonsInput = input.bool(false, "Show reason under EXIT text (optional)", group = G_VIEW, tooltip = "Off by default for minimal single-line labels. The reason remains in the EXIT hover tooltip and dashboard. Enable to add a second text line.")
int actionTextSizeInput = input.int(12, "BUY / SELL / EXIT text size", minval = 8, maxval = 24, step = 2, group = G_VIEW, tooltip = "Pixel size of the four plain-text action labels. Default 12 keeps them similar to BUY VOL / SELL VOL. Increase it for readability; presentation only, no change to signal rules.")
float entryShareInput = input.float(0.35, "Entry minimum imbalance", minval = 0.05, maxval = 0.9, step = 0.05, group = G_PLAN, tooltip = "Additional gate on v1 DRIVE events. Does not alter raw ML collection. Default 35% absolute estimated net volume share.")
float entryRvolInput = input.float(1.5, "Entry minimum relative volume", minval = 0.5, maxval = 5, step = 0.1, group = G_PLAN)
float entryFlowInput = input.float(0.05, "Aligned rolling pressure", minval = 0.01, maxval = 0.5, step = 0.01, group = G_PLAN, tooltip = "Require rolling classified pressure to agree with entry direction by this amount; also require close beyond the flow mean and its slope aligned.")
int slopeBarsInput = input.int(3, "Flow mean slope bars", minval = 1, maxval = 10, group = G_PLAN)
float stretchInput = input.float(1.5, "Maximum distance from mean (ATR)", minval = 0.25, maxval = 5, step = 0.25, group = G_PLAN, tooltip = "Avoid entries far from the descriptive mean. This is a rule, not a proven optimal threshold.")
bool entryMlInput = input.bool(false, "Require this event's ML continuation vote", group = G_PLAN, tooltip = "When on, this same confirmed event must have a valid vote at/above Historical vote threshold. LEARNING or no close analogue blocks entry. Off by default: the v1 validation did not establish an ML advantage. Stored dashboard votes cannot trigger later entries.")
int cooldownInput = input.int(8, "Bars after exit before another entry", minval = 0, maxval = 100, group = G_PLAN)
int resetBarsInput = input.int(3, "Quiet DRIVE bars to re-arm a side", minval = 1, maxval = 20, group = G_PLAN, tooltip = "Count only consecutive usable FLAT bars with no pending entry and without that side's UNSPACED v1 DRIVE regime. Open/pending or missing-volume bars reset the count. Rearm requires cooldown to finish; exit bars cannot supply entry/reset evidence.")
bool allowBuyInput = input.bool(true, "Allow BUY plans", group = G_PLAN)
bool allowSellInput = input.bool(true, "Allow SELL plans", group = G_PLAN)
int planStartInput = input.time(0, "Managed plan start time", group = G_PLAN, tooltip = "Default epoch means all loaded history. For alert setup you can choose a future start while the broker is flat. Existing alerts keep their old script/settings and must be recreated. This does not synchronize broker positions.")
float stopAtrInput = input.float(1.5, "Initial model risk (prior ATR)", minval = 0.25, maxval = 5, step = 0.25, group = G_RISK, tooltip = "Freeze signal-bar PRIOR ATR times this value; round up to ticks, minimum two ticks. R is this initial distance. It never widens later.")
float targetRInput = input.float(2.0, "Fixed model target (R)", minval = 0.5, maxval = 8, step = 0.25, group = G_RISK)
bool beInput = input.bool(true, "Activate break-even reference", group = G_RISK, tooltip = "Tighten only after favorable excursion reaches the threshold. New protection applies from the NEXT bar. Entry-level protection does not cover every fee, slippage or gap.")
float beAtInput = input.float(0.75, "Break-even activation (R)", minval = 0.25, maxval = 4, step = 0.25, group = G_RISK)
float beBufferInput = input.float(0.05, "Break-even reference buffer (R)", minval = 0, maxval = 0.25, step = 0.05, group = G_RISK)
bool trailInput = input.bool(true, "Activate trailing reference", group = G_RISK)
float trailAtInput = input.float(1.0, "Trail activation (R)", minval = 0.25, maxval = 5, step = 0.25, group = G_RISK)
float trailRInput = input.float(0.75, "Trail distance (R)", minval = 0.25, maxval = 4, step = 0.25, group = G_RISK, tooltip = "Follows the favorable high/low extreme after activation. Updates tighten only and apply NEXT bar, so current-bar high cannot retrospectively stop at current-bar low.")
bool oppositeExitInput = input.bool(true, "Exit on a qualified opposite DRIVE", group = G_RISK, tooltip = "Close only. Never close and open the opposite plan on the same bar. A repeated same-side event does not reset the position or risk levels.")
bool flowExitInput = input.bool(true, "Exit when flow context is invalidated", group = G_RISK)
int flowExitBarsInput = input.int(2, "Adverse flow closes before exit", minval = 1, maxval = 10, group = G_RISK, tooltip = "Consecutive usable closes against the mean with rolling pressure at least Aligned rolling pressure in the opposite direction. Missing data resets this confirmation, not the protective risk checks.")
int maxHoldInput = input.int(48, "Maximum model holding bars", minval = 4, maxval = 500, group = G_RISK, tooltip = "Time exit independent of new pressure signals. Counts the next-open fill bar as bar one. All model exits are emitted at a confirmed CLOSE, including earlier price touches; use native broker protection for intrabar execution.")

string profilePlacement = publicationInput ? "Right of candles" : placementInput

if barstate.isfirst and resistedInput >= driveInput
    runtime.error("Resisted response ceiling must be smaller than Drive response.")

// Evaluated in the lower-timeframe context. Dojis inherit the last known direction
// only after open/close and previous-close comparisons also fail to resolve them.
f_direction() =>
    var int direction = 0
    if close > open
        direction := 1
    else if close < open
        direction := -1
    else if not na(close[1]) and close > close[1]
        direction := 1
    else if not na(close[1]) and close < close[1]
        direction := -1
    direction

float chartSeconds = timeframe.in_seconds()
string autoTf = chartSeconds <= 3600 ? "1" : chartSeconds <= 14400 ? "5" : chartSeconds <= 86400 ? "15" : chartSeconds <= 604800 ? "60" : "1D"
string lowerTf = autoTfInput ? autoTf : customTfInput
bool validTf = not na(chartSeconds) and timeframe.in_seconds(lowerTf) < chartSeconds
[intraPrice, intraVolume, intraDirection] = request.security_lower_tf(syminfo.tickerid, lowerTf, [hlc3, volume, f_direction()], ignore_invalid_timeframe = true, calc_bars_count = 100000)
int sourceCount = validTf and not na(intraPrice) and not na(intraVolume) and not na(intraDirection) ? intraPrice.size() : 0
bool manageable = sourceCount <= 3000
bool standard = chart.is_standard
float buyVolume = 0.0
float sellVolume = 0.0
float neutralVolume = 0.0
float priceMoment = 0.0
float squareMoment = 0.0
int validSources = 0
bool invalidSource = false
if validTf and standard and manageable and sourceCount > 0
    for i = 0 to sourceCount - 1
        float samplePrice = intraPrice.get(i)
        float sampleVolume = intraVolume.get(i)
        if na(samplePrice) or na(sampleVolume) or sampleVolume < 0
            invalidSource := true
        else
            validSources += 1
            int side = intraDirection.get(i)
            buyVolume += side == 1 ? sampleVolume : 0.0
            sellVolume += side == -1 ? sampleVolume : 0.0
            neutralVolume += side == 0 ? sampleVolume : 0.0
            priceMoment += samplePrice * sampleVolume
            squareMoment += samplePrice * samplePrice * sampleVolume
float classifiedTotal = buyVolume + sellVolume + neutralVolume
bool usable = validTf and standard and manageable and sourceCount > 0 and not invalidSource and classifiedTotal > 0
float netShare = usable ? (buyVolume - sellVolume) / classifiedTotal : na
float observedVolume = usable ? classifiedTotal : na
float priorAverage = ta.sma(observedVolume, 30)[1]
float priorValidBars = math.sum(usable ? 1.0 : 0.0, 30)[1]
float priorAtr = ta.atr(14)[1]
float relativeVolume = usable and priorValidBars == 30 and priorAverage > 0 ? classifiedTotal / priorAverage : na
float bodyResponse = usable and priorAtr > 0 ? math.sign(netShare) * (close - open) / priorAtr : na

// Source statistics are computed every bar, but plotted values and event state commit
// on confirmed closes. Open bars carry the last closed reading, not a new signal.
float windowVolume = math.sum(usable ? classifiedTotal : 0.0, flowWindowInput)
float windowMoment = math.sum(usable ? priceMoment : 0.0, flowWindowInput)
float windowSquare = math.sum(usable ? squareMoment : 0.0, flowWindowInput)
float windowBuy = math.sum(usable ? buyVolume : 0.0, flowWindowInput)
float windowSell = math.sum(usable ? sellVolume : 0.0, flowWindowInput)
float windowValid = math.sum(usable ? 1.0 : 0.0, flowWindowInput)
bool windowReady = windowValid >= math.ceil(flowWindowInput * 0.8) and windowVolume > 0
float rawMean = windowReady ? windowMoment / windowVolume : na
float rawDeviation = windowReady ? math.sqrt(math.max(0, windowSquare / windowVolume - rawMean * rawMean)) : na
float windowShare = windowReady ? (windowBuy - windowSell) / windowVolume : na
float flowMean = barstate.isconfirmed ? rawMean : rawMean[1]
float flowDeviation = barstate.isconfirmed ? rawDeviation : rawDeviation[1]
float flowShare = barstate.isconfirmed ? windowShare : windowShare[1]
color flowInk = na(flowShare) or math.abs(flowShare) < 0.05 ? #8090A6 : flowShare > 0 ? buyInput : sellInput
float meanShown = ribbonInput ? flowMean : na
pMean = plot(meanShown, "Flow mean (intrabar HLC3)", #CFD8E6, 2, plot.style_linebr)
pUpper1 = plot(ribbonInput ? flowMean + flowDeviation : na, "Upper distribution", color.new(flowInk, publicationInput ? 45 : 80), 1, plot.style_linebr)
pLower1 = plot(ribbonInput ? flowMean - flowDeviation : na, "Lower distribution", color.new(flowInk, publicationInput ? 45 : 80), 1, plot.style_linebr)
pUpper2 = plot(ribbonInput ? flowMean + flowDeviation * 0.67 : na, "Upper inner", color.new(flowInk, 100), 1, plot.style_linebr, display = display.none)
pLower2 = plot(ribbonInput ? flowMean - flowDeviation * 0.67 : na, "Lower inner", color.new(flowInk, 100), 1, plot.style_linebr, display = display.none)
pUpper3 = plot(ribbonInput ? flowMean + flowDeviation * 0.33 : na, "Upper core", color.new(flowInk, 100), 1, plot.style_linebr, display = display.none)
pLower3 = plot(ribbonInput ? flowMean - flowDeviation * 0.33 : na, "Lower core", color.new(flowInk, 100), 1, plot.style_linebr, display = display.none)
fill(pUpper1, pLower1, color.new(flowInk, publicationInput ? 88 : 94), title = "Distribution outer", fillgaps = false)
fill(pUpper2, pLower2, color.new(flowInk, publicationInput ? 78 : 91), title = "Distribution middle", fillgaps = false)
fill(pUpper3, pLower3, color.new(flowInk, publicationInput ? 62 : 85), title = "Distribution core", fillgaps = false)

type FlowBar
    int index
    int stamp
    int samples
    bool available
    array<float> pricesBuy
    array<float> pricesSell
    array<float> pricesNeutral
    array<float> volumesBuy
    array<float> volumesSell
    array<float> volumesNeutral

type Highlight
    int index
    int side
    float top
    float bottom

type LearnedCase
    array<float> features
    int outcome

type PendingCase
    int index
    float origin
    float atr
    int side
    array<float> features
    float vote
    float base

type ModelBadge
    int index
    float price
    int side
    float vote
    float base
    int librarySize
    float distance

f_clip(float value, float lower, float upper) =>
    math.max(lower, math.min(upper, value))

// All seven features are bounded on fixed scales, never fitted on future history.
// Buying and selling cases use the same pressure-relative coordinates.
f_features(int side, float share, float activity, float response, float mean, float atr, float rollingShare) =>
    float span = high - low
    float alignedWick = side == 1 ? (high - math.max(open, close)) / span : (math.min(open, close) - low) / span
    float alignedClose = side == 1 ? (close - low) / span : (high - close) / span
    array.from(math.abs(share), activity / (1.0 + activity), (f_clip(response, -2.0, 2.0) + 2.0) / 4.0, f_clip(alignedWick, 0.0, 1.0), f_clip(alignedClose, 0.0, 1.0), (f_clip(side * (close - mean) / atr, -3.0, 3.0) + 3.0) / 6.0, f_clip((side * rollingShare + 1.0) / 2.0, 0.0, 1.0))

// Mean logarithmic L1 distance. Often called Lorentzian distance in similarity
// literature; no spacetime geometry and no imported classifier/library code.
f_distance(array<float> current, array<float> past) =>
    float distance = 0.0
    for feature = 0 to 6
        distance += math.log(1.0 + math.abs(current.get(feature) - past.get(feature)))
    distance / 7.0

f_model(array<float> features, array<LearnedCase> library) =>
    int count = library.size()
    int wins = 0
    if count > 0
        for example in library
            wins += example.outcome
    float base = count > 0 ? (wins + 1.0) / (count + 2.0) : na
    float vote = na
    float farthest = na
    float effective = na
    string state = count < math.max(warmupInput, neighboursInput) ? "LEARNING" : wins == 0 or wins == count ? "NEED BOTH OUTCOMES" : "NO CLOSE ANALOGUE"
    if count >= math.max(warmupInput, neighboursInput) and wins > 0 and wins < count
        array<float> distances = array.new<float>()
        array<int> outcomes = array.new<int>()
        // Maintain sorted exact-nearest K. Newer cases win exact distance ties.
        for example in library
            float distance = f_distance(features, example.features)
            int place = distances.size()
            if distances.size() > 0
                for j = 0 to distances.size() - 1
                    if distance <= distances.get(j)
                        place := j
                        break
            if place < neighboursInput
                distances.insert(place, distance)
                outcomes.insert(place, example.outcome)
                if distances.size() > neighboursInput
                    distances.pop()
                    outcomes.pop()
        farthest := distances.last()
        if farthest <= distanceInput
            float weightSum = 0.0
            float squareWeights = 0.0
            float weightedOutcome = 0.0
            for j = 0 to distances.size() - 1
                float weight = 1.0 / math.max(0.01, distances.get(j))
                weightSum += weight
                squareWeights += weight * weight
                weightedOutcome += weight * outcomes.get(j)
            effective := weightSum * weightSum / squareWeights
            float neighbourVote = weightedOutcome / weightSum
            float blend = effective / (effective + shrinkInput)
            vote := base + (neighbourVote - base) * blend
            state := "HISTORICAL VOTE"
    [vote, base, farthest, effective, state]

var array<LearnedCase> caseLibrary = array.new<LearnedCase>()
var array<PendingCase> pending = array.new<PendingCase>()
var array<ModelBadge> badges = array.new<ModelBadge>()
var int resolvedCount = 0
var int timeoutCount = 0
var int ambiguousCount = 0
var int invalidOutcomeCount = 0
var int scoredCount = 0
var float brierSum = 0.0
var float baseBrierSum = 0.0
var float modelVote = na
var float modelBase = na
var float modelDistance = na
var float modelEffective = na
var string modelState = "WAITING FOR EVENT"
var int modelIndex = na
var int modelSide = 0
var int modelLibrarySize = 0
// Freeze the dashboard at the visible endpoint too: scrolling never displays a
// library or validation score learned from bars to the right of that endpoint.
var float viewVote = na
var float viewBase = na
var float viewDistance = na
var float viewEffective = na
var string viewModelState = "WAITING FOR EVENT"
var int viewModelAge = na
var int viewModelSide = 0
var int viewQuerySize = 0
var int viewLibrary = 0
var int viewResolved = 0
var int viewTimeout = 0
var int viewAmbiguous = 0
var int viewInvalid = 0
var int viewPending = 0
var int viewScored = 0
var float viewBrier = na
var float viewBaseBrier = na

var array<FlowBar> history = array.new<FlowBar>()
var array<Highlight> highlights = array.new<Highlight>()
var int lastEvent = na
var int lastStamp = na
var string lastState = "WAITING FOR DATA"
var float lastShare = na
var float lastRvol = na
var float lastResponse = na
var int lastSamples = 0
var bool lastUsable = false
var bool lastPartial = false
var int visibleLeft = na
var int visibleRight = na
if time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time
    visibleLeft := na(visibleLeft) ? bar_index : visibleLeft
    visibleRight := bar_index
bool buyDrive = false
bool sellDrive = false
bool buyResisted = false
bool sellResisted = false
bool mlContinuation = false
bool mlOpposition = false
float eventVote = na
float eventDistance = na

if barstate.isconfirmed
    // Resolve before querying the current close. Only observations already known
    // by this close can train it. A case cannot resolve on its own birth candle.
    if mlInput
        int cursor = 0
        while cursor < pending.size()
            PendingCase candidate = pending.get(cursor)
            int age = bar_index - candidate.index
            bool invalidPrice = na(high) or na(low) or high < low
            bool withPressure = not invalidPrice and (candidate.side == 1 ? high >= candidate.origin + barrierInput * candidate.atr : low <= candidate.origin - barrierInput * candidate.atr)
            bool againstPressure = not invalidPrice and (candidate.side == 1 ? low <= candidate.origin - barrierInput * candidate.atr : high >= candidate.origin + barrierInput * candidate.atr)
            bool complete = age > 0 and (invalidPrice or withPressure or againstPressure or age >= horizonInput)
            if complete
                if invalidPrice
                    invalidOutcomeCount += 1
                else if withPressure and againstPressure
                    ambiguousCount += 1
                else if withPressure or againstPressure
                    int outcome = withPressure ? 1 : 0
                    caseLibrary.push(LearnedCase.new(candidate.features, outcome))
                    if caseLibrary.size() > libraryInput
                        caseLibrary.shift()
                    resolvedCount += 1
                    if not na(candidate.vote)
                        scoredCount += 1
                        brierSum += math.pow(candidate.vote - outcome, 2)
                        baseBrierSum += math.pow(candidate.base - outcome, 2)
                else
                    timeoutCount += 1
                pending.remove(cursor)
            else
                cursor += 1
    // Preserve all source volume; consecutive aggregation affects profile detail only.
    array<float> pb = array.new<float>()
    array<float> ps = array.new<float>()
    array<float> pn = array.new<float>()
    array<float> vb = array.new<float>()
    array<float> vs = array.new<float>()
    array<float> vn = array.new<float>()
    if usable and time <= chart.right_visible_bar_time
        int stride = int(math.max(1, math.ceil(sourceCount / 120.0)))
        for start = 0 to sourceCount - 1 by stride
            int finish = math.min(sourceCount - 1, start + stride - 1)
            float bv = 0.0
            float sv = 0.0
            float nv = 0.0
            float bm = 0.0
            float sm = 0.0
            float nm = 0.0
            for i = start to finish
                float v = intraVolume.get(i)
                float p = intraPrice.get(i)
                int side = intraDirection.get(i)
                if side == 1
                    bv += v
                    bm += v * p
                else if side == -1
                    sv += v
                    sm += v * p
                else
                    nv += v
                    nm += v * p
            vb.push(bv)
            vs.push(sv)
            vn.push(nv)
            pb.push(bv > 0 ? bm / bv : na)
            ps.push(sv > 0 ? sm / sv : na)
            pn.push(nv > 0 ? nm / nv : na)
    if time <= chart.right_visible_bar_time
        history.push(FlowBar.new(bar_index, time, sourceCount, usable, pb, ps, pn, vb, vs, vn))
        if history.size() > profileWindowInput
            history.shift()
        lastStamp := time_close
        lastShare := netShare
        lastRvol := relativeVolume
        lastResponse := bodyResponse
        lastSamples := sourceCount
        lastUsable := usable
        lastPartial := invalidSource
    bool pressure = usable and not na(relativeVolume) and relativeVolume >= rvolInput and math.abs(netShare) >= dominanceInput and priorAtr > 0
    bool drive = pressure and bodyResponse >= driveInput
    bool resisted = pressure and bodyResponse <= resistedInput
    if time <= chart.right_visible_bar_time
        lastState := not standard ? "STANDARD CANDLES REQUIRED" : not validTf ? "CHOOSE A SMALLER TIMEFRAME" : not manageable ? "COARSEN INTRABAR TIMEFRAME" : not usable ? (invalidSource ? "INVALID / PARTIAL SOURCE" : "NO INTRABAR VOLUME") : na(relativeVolume) ? "BUILDING VOLUME BASELINE" : drive ? (netShare > 0 ? "BUYING DRIVE" : "SELLING DRIVE") : resisted ? (netShare > 0 ? "BUYING RESISTED" : "SELLING RESISTED") : pressure ? "PRESSURE / MIXED RESPONSE" : "BALANCED / BELOW THRESHOLDS"
    if (drive or resisted) and (na(lastEvent) or bar_index - lastEvent >= spacingInput)
        buyDrive := drive and netShare > 0
        sellDrive := drive and netShare < 0
        buyResisted := resisted and netShare > 0
        sellResisted := resisted and netShare < 0
        lastEvent := bar_index
        if mlInput
            modelIndex := bar_index
            modelSide := netShare > 0 ? 1 : -1
            modelLibrarySize := caseLibrary.size()
            modelVote := na
            modelBase := na
            modelDistance := na
            modelEffective := na
            modelState := "CONTEXT NOT READY"
            if windowReady and not na(rawMean) and not na(windowShare) and high > low
                array<float> features = f_features(modelSide, netShare, relativeVolume, bodyResponse, rawMean, priorAtr, windowShare)
                [vote, base, distance, effective, state] = f_model(features, caseLibrary)
                modelVote := vote
                modelBase := base
                modelDistance := distance
                modelEffective := effective
                modelState := state
                eventVote := vote
                eventDistance := distance
                mlContinuation := not na(vote) and vote >= convictionInput
                mlOpposition := not na(vote) and vote <= 1.0 - convictionInput
                // Collection is unconditional on model readiness or its vote.
                pending.push(PendingCase.new(bar_index, close, priorAtr, modelSide, features, vote, base))
                if not na(vote) and time <= chart.right_visible_bar_time
                    float badgePrice = (sellDrive or buyResisted) ? high + priorAtr * 0.55 : low - priorAtr * 0.55
                    badges.push(ModelBadge.new(bar_index, badgePrice, modelSide, vote, base, caseLibrary.size(), distance))
                    if badges.size() > 24
                        badges.shift()
        if resisted and time <= chart.right_visible_bar_time
            highlights.push(Highlight.new(bar_index, netShare > 0 ? 1 : -1, math.max(open, close) + priorAtr * 0.12, math.min(open, close) - priorAtr * 0.12))
            if highlights.size() > 8
                highlights.shift()
    if time <= chart.right_visible_bar_time
        viewVote := modelVote
        viewBase := modelBase
        viewDistance := modelDistance
        viewEffective := modelEffective
        viewModelState := mlInput ? modelState : "ML OFF"
        viewModelAge := na(modelIndex) ? na : bar_index - modelIndex
        viewModelSide := modelSide
        viewQuerySize := modelLibrarySize
        viewLibrary := caseLibrary.size()
        viewResolved := resolvedCount
        viewTimeout := timeoutCount
        viewAmbiguous := ambiguousCount
        viewInvalid := invalidOutcomeCount
        viewPending := pending.size()
        viewScored := scoredCount
        viewBrier := scoredCount > 0 ? brierSum / scoredCount : na
        viewBaseBrier := scoredCount > 0 ? baseBrierSum / scoredCount : na


// Managed plan is independent of the observation/ML population and viewport.
// All prices below are hypothetical references, not broker fills or working orders.
bool rawDriveRegime = usable and not na(relativeVolume) and relativeVolume >= rvolInput and math.abs(netShare) >= dominanceInput and priorAtr > 0 and bodyResponse >= driveInput
bool rawBuyRegime = rawDriveRegime and netShare > 0
bool rawSellRegime = rawDriveRegime and netShare < 0
bool planContext = usable and windowReady and not na(rawMean[slopeBarsInput]) and priorAtr > 0 and math.abs(close - rawMean) / priorAtr <= stretchInput
bool longContext = planContext and windowShare >= entryFlowInput and close > rawMean and rawMean > rawMean[slopeBarsInput]
bool shortContext = planContext and windowShare <= -entryFlowInput and close < rawMean and rawMean < rawMean[slopeBarsInput]
bool currentMlPass = not entryMlInput or (mlInput and not na(eventVote) and eventVote >= convictionInput)
bool strongerEvent = not na(relativeVolume) and relativeVolume >= entryRvolInput and math.abs(netShare) >= entryShareInput
bool qualifiedBuy = buyDrive and strongerEvent and longContext and currentMlPass
bool qualifiedSell = sellDrive and strongerEvent and shortContext and currentMlPass
f_up(float price) =>
    math.ceil(price / syminfo.mintick) * syminfo.mintick
f_down(float price) =>
    math.floor(price / syminfo.mintick) * syminfo.mintick

var int planSide = 0
var int pendingPlanSide = 0
var int pendingPlanBar = na
var float pendingPlanRisk = na
var float planEntry = na
var float planRisk = na
var float planStop = na
var float planTarget = na
var float favorablePrice = na
var int planEntryBar = na
var string stopKind = "Initial stop"
var int lastPlanExit = na
var string lastPlanReason = "NONE"
var int buyQuietBars = 0
var int sellQuietBars = 0
var bool buyArmed = true
var bool sellArmed = true
var int adverseFlowBars = 0
var int managedEntryCount = 0
var int managedExitCount = 0
var int ambiguousPlanExits = 0
var int invalidPlanReferences = 0
var int suppressedSameSide = 0
var int viewPlanSide = 0
var int viewPendingSide = 0
var float viewPlanEntry = na
var float viewPlanStop = na
var float viewPlanTarget = na
var int viewPlanEntryBar = na
var string viewPlanReason = "NONE"
var string viewStopKind = "Initial stop"
var int viewPlanExitAge = na
var int viewManagedEntries = 0
var int viewManagedExits = 0
var int viewSameSide = 0
var int viewPlanAmbiguous = 0
bool managedBuy = false
bool managedSell = false
bool exitBuy = false
bool exitSell = false
string exitReason = ""
float modelExitReference = na
float signalRisk = na

if barstate.isconfirmed and managedInput
    bool validPrices = not na(open) and not na(high) and not na(low) and not na(close) and high >= low and open >= low and open <= high and close >= low and close <= high
    buyQuietBars := planSide == 0 and pendingPlanSide == 0 and usable ? (rawBuyRegime ? 0 : buyQuietBars + 1) : 0
    sellQuietBars := planSide == 0 and pendingPlanSide == 0 and usable ? (rawSellRegime ? 0 : sellQuietBars + 1) : 0
    bool exitedThisBar = false
    // BUY/SELL already fired on the preceding close. Materialize only the next open.
    if pendingPlanSide != 0 and bar_index > pendingPlanBar
        if validPrices and bar_index == pendingPlanBar + 1
            planSide := pendingPlanSide
            planEntry := open
            planRisk := pendingPlanRisk
            planStop := planEntry - planSide * planRisk
            planTarget := planSide == 1 ? f_up(planEntry + planRisk * targetRInput) : f_down(planEntry - planRisk * targetRInput)
            favorablePrice := open
            planEntryBar := bar_index
            stopKind := "Initial stop"
            adverseFlowBars := 0
        else
            // No fictional later fill. Emit a close intent for the prior entry intent.
            exitBuy := pendingPlanSide == 1
            exitSell := pendingPlanSide == -1
            exitReason := "Invalid fill reference"
            invalidPlanReferences += 1
            managedExitCount += 1
            lastPlanExit := bar_index
            lastPlanReason := exitReason
            exitedThisBar := true
        pendingPlanSide := 0
        pendingPlanBar := na
        pendingPlanRisk := na
    if planSide != 0
        int heldSide = planSide
        // These levels were active BEFORE this candle's high/low was observed.
        float oldStop = planStop
        float oldTarget = planTarget
        if validPrices
            bool gapStop = heldSide == 1 ? open <= oldStop : open >= oldStop
            bool gapTarget = heldSide == 1 ? open >= oldTarget : open <= oldTarget
            bool touchStop = heldSide == 1 ? low <= oldStop : high >= oldStop
            bool touchTarget = heldSide == 1 ? high >= oldTarget : low <= oldTarget
            if gapStop
                exitReason := stopKind + " touched: gap"
                modelExitReference := open
            else if gapTarget
                exitReason := "Target touched: gap"
                modelExitReference := oldTarget
            else if touchStop
                exitReason := touchTarget ? "Both touched: stop first" : stopKind + " touched"
                modelExitReference := oldStop
                ambiguousPlanExits += touchTarget ? 1 : 0
            else if touchTarget
                exitReason := "Target touched"
                modelExitReference := oldTarget
            else
                favorablePrice := heldSide == 1 ? math.max(favorablePrice, high) : math.min(favorablePrice, low)
                float favorableR = heldSide * (favorablePrice - planEntry) / planRisk
                if beInput and favorableR >= beAtInput
                    float proposedBe = heldSide == 1 ? f_down(planEntry + planRisk * beBufferInput) : f_up(planEntry - planRisk * beBufferInput)
                    if heldSide * (proposedBe - planStop) > 0
                        planStop := proposedBe
                        stopKind := "Break-even reference"
                if trailInput and favorableR >= trailAtInput
                    float proposedTrail = heldSide == 1 ? f_down(favorablePrice - planRisk * trailRInput) : f_up(favorablePrice + planRisk * trailRInput)
                    if heldSide * (proposedTrail - planStop) > 0
                        planStop := proposedTrail
                        stopKind := "Trailing reference"
                // Tightened levels apply NEXT bar; no retroactive same-bar stop test.
                bool adverseFlow = usable and windowReady and heldSide * (close - rawMean) < 0 and heldSide * windowShare <= -entryFlowInput
                adverseFlowBars := adverseFlow ? adverseFlowBars + 1 : 0
                if oppositeExitInput and (heldSide == 1 ? qualifiedSell : qualifiedBuy)
                    exitReason := "Opposite qualified DRIVE"
                else if flowExitInput and adverseFlowBars >= flowExitBarsInput
                    exitReason := "Flow invalidated"
                else if bar_index - planEntryBar + 1 >= maxHoldInput
                    exitReason := "Time limit"
                if exitReason != ""
                    modelExitReference := close
        if exitReason != ""
            exitBuy := heldSide == 1
            exitSell := heldSide == -1
            managedExitCount += 1
            lastPlanExit := bar_index
            lastPlanReason := exitReason
            exitedThisBar := true
            planSide := 0
            planEntry := na
            planRisk := na
            planStop := na
            planTarget := na
            favorablePrice := na
            planEntryBar := na
            adverseFlowBars := 0
    bool coolingReady = na(lastPlanExit) or bar_index - lastPlanExit >= cooldownInput
    if planSide == 0 and pendingPlanSide == 0 and coolingReady and not exitedThisBar
        buyArmed := buyArmed or buyQuietBars >= resetBarsInput
        sellArmed := sellArmed or sellQuietBars >= resetBarsInput
        if validPrices and time >= planStartInput
            managedBuy := allowBuyInput and buyArmed and qualifiedBuy
            managedSell := allowSellInput and sellArmed and qualifiedSell
            if managedBuy or managedSell
                signalRisk := math.max(syminfo.mintick * 2, f_up(priorAtr * stopAtrInput))
                pendingPlanSide := managedBuy ? 1 : -1
                pendingPlanBar := bar_index
                pendingPlanRisk := signalRisk
                managedEntryCount += 1
                if managedBuy
                    buyArmed := false
                else
                    sellArmed := false
                buyQuietBars := 0
                sellQuietBars := 0
    else if (planSide == 1 and qualifiedBuy) or (planSide == -1 and qualifiedSell) or (pendingPlanSide == 1 and qualifiedBuy) or (pendingPlanSide == -1 and qualifiedSell)
        suppressedSameSide += 1
    if time <= chart.right_visible_bar_time
        viewPlanSide := planSide
        viewPendingSide := pendingPlanSide
        viewPlanEntry := planEntry
        viewPlanStop := planStop
        viewPlanTarget := planTarget
        viewPlanEntryBar := planEntryBar
        viewPlanReason := lastPlanReason
        viewStopKind := stopKind
        viewPlanExitAge := na(lastPlanExit) ? na : bar_index - lastPlanExit
        viewManagedEntries := managedEntryCount
        viewManagedExits := managedExitCount
        viewSameSide := suppressedSameSide
        viewPlanAmbiguous := ambiguousPlanExits

// Plain readable action tags. Historical model intents, not filled broker orders.
var array<label> planLabels = array.new<label>()
if barstate.isconfirmed and time <= chart.right_visible_bar_time and (managedBuy or managedSell or exitBuy or exitSell)
    bool lowerLabel = managedBuy or exitSell
    string caption = managedBuy ? "BUY" : managedSell ? "SELL" : exitBuy ? "EXIT BUY" : "EXIT SELL"
    string reasonText = (exitBuy or exitSell) and exitReasonsInput ? "\n" + exitReason : ""
    color labelInk = managedBuy ? buyInput : managedSell ? sellInput : #D9E1ED
    color labelText = managedSell ? #101824 : #FFFFFF
    float labelOffset = math.max(syminfo.mintick * 4, nz(priorAtr, high - low) * 0.65)
    float labelPrice = lowerLabel ? low - labelOffset : high + labelOffset
    string tip = managedBuy or managedSell ? "Confirmed-close model entry intent. Hypothetical reference fill: next candle OPEN. One plan at a time; repeated same-side pressure cannot replace it." : "Confirmed-close CLOSE intent: " + exitReason + ". Earlier intrabar touches are not broker fills at the shown reference. No immediate reversal. Broker position/fills are not observed."
    planLabels.push(label.new(bar_index, labelPrice, caption + reasonText, style = label.style_none, color = color.new(#0B111B, 100), textcolor = labelInk, size = actionTextSizeInput, tooltip = tip))
    if planLabels.size() > 120
        label.delete(planLabels.shift())
plot(managedBuy or managedSell ? close : na, "Entry price reference", display = display.data_window)
plot(managedBuy ? close - signalRisk : managedSell ? close + signalRisk : na, "Entry SL reference", display = display.data_window)
plot(managedBuy ? f_up(close + signalRisk * targetRInput) : managedSell ? f_down(close - signalRisk * targetRInput) : na, "Entry TP reference", display = display.data_window)

// Raw observation marks are optional and never managed-entry alerts.
plotshape(rawMarksInput and buyDrive, "Buying drive mark", shape.circle, location.belowbar, buyInput, size = size.small)
plotshape(rawMarksInput and sellDrive, "Selling drive mark", shape.circle, location.abovebar, sellInput, size = size.small)
plotshape(rawMarksInput and buyResisted, "Buying resisted mark", shape.diamond, location.abovebar, buyInput, size = size.small)
plotshape(rawMarksInput and sellResisted, "Selling resisted mark", shape.diamond, location.belowbar, sellInput, size = size.small)
plot(eventVote * 100.0, "ML continuation vote (%) · event close", display = display.data_window)
plot(eventDistance, "ML Kth mean log-distance · event close", display = display.data_window)

var array<box> drawnBoxes = array.new<box>()
var array<polyline> drawnFaces = array.new<polyline>()
var array<label> drawnLabels = array.new<label>()
var array<line> drawnLines = array.new<line>()
f_face(int x1, float y1, int x2, float y2, int x3, float y3, int x4, float y4, color ink) =>
    array<chart.point> points = array.from(chart.point.from_index(x1, y1), chart.point.from_index(x2, y2), chart.point.from_index(x3, y3), chart.point.from_index(x4, y4))
    drawnFaces.push(polyline.new(points, closed = true, fill_color = ink, line_color = color.new(ink, 100)))

f_segment(int left, int right, float top, float bottom, color ink, float intensity, bool peak) =>
    // The guide sits above candles. Keep an inside-chart profile much lighter so
    // its rectangles still allow the candle bodies underneath to be read.
    bool inside = profilePlacement == "Inside chart"
    int transparency = inside ? int(90 - 18 * math.sqrt(intensity)) : int(math.max(18, 70 - 48 * math.sqrt(intensity)))
    if depthInput and peak
        float lift = (top - bottom) * 0.18
        color light = color.rgb(int(math.min(255, color.r(ink) + 45)), int(math.min(255, color.g(ink) + 45)), int(math.min(255, color.b(ink) + 45)))
        f_face(left, top, left + 1, top + lift, right + 1, top + lift, right, top, color.new(light, inside ? 85 : 20))
        f_face(right, top, right + 1, top + lift, right + 1, bottom + lift, right, bottom, color.new(ink, inside ? 90 : 62))
    drawnBoxes.push(box.new(left, top, right, bottom, bgcolor = color.new(ink, transparency), border_color = peak ? color.new(#D5DFEE, inside ? 45 : 0) : color.new(ink, inside ? 85 : 70), border_width = 1))

f_label(int x, float y, string caption, color ink) =>
    drawnLabels.push(label.new(x, y, caption, style = label.style_none, textcolor = ink, size = size.small))

var table dash = table.new(position.top_right, 2, 28, bgcolor = #0C1424, frame_color = #2C3A50, frame_width = 1)
var table coverHeading = table.new(position.top_center, 1, 3)
var table coverKey = table.new(position.bottom_center, 2, 3, bgcolor = color.new(#142033, 28), frame_color = #253249, frame_width = 1)
if barstate.islast
    table.clear(coverHeading, 0, 0, 0, 2)
    table.clear(coverKey, 0, 0, 1, 2)
    if publicationInput
        table.cell(coverHeading, 0, 0, "", height = 7)
        table.cell(coverHeading, 0, 1, "ORDER FLOW AI", text_color = #F2F5FA, text_size = coverTitleSizeInput, text_formatting = text.format_bold)
        table.cell(coverHeading, 0, 2, managedInput ? "Estimated pressure · Entries and exits" : "Estimated pressure · Historical ML", text_color = #A9B6CA, text_size = 16)
        table.cell(coverKey, 0, 0, managedInput ? "BUY · open long" : "Blue · buying pressure", text_color = buyInput, text_size = 14)
        table.cell(coverKey, 1, 0, managedInput ? "SELL · open short" : "Orange · selling pressure", text_color = sellInput, text_size = 14)
        table.cell(coverKey, 0, 1, managedInput ? "EXIT BUY · close long" : "Circle · drive", text_color = #D9E1ED, text_size = 12)
        table.cell(coverKey, 1, 1, managedInput ? "EXIT SELL · close short" : "Diamond · resisted", text_color = #D9E1ED, text_size = 12)
        table.cell(coverKey, 0, 2, "Model actions · candle closes", text_color = #91A0B7, text_size = 11)
        table.cell(coverKey, 1, 2, "Execution may differ", text_color = #91A0B7, text_size = 11)
    while drawnBoxes.size() > 0
        box.delete(drawnBoxes.pop())
    while drawnFaces.size() > 0
        polyline.delete(drawnFaces.pop())
    while drawnLabels.size() > 0
        label.delete(drawnLabels.pop())
    while drawnLines.size() > 0
        line.delete(drawnLines.pop())
    if mlBadgesInput and rawMarksInput and badges.size() > 0
        for badge in badges
            if badge.index >= bar_index - 4900 and (na(visibleRight) or badge.index <= visibleRight)
                string tip = "Frozen historical continuation vote: " + str.tostring(badge.vote * 100, "#.#") + "%\nBase at birth: " + str.tostring(badge.base * 100, "#.#") + "% · library " + str.tostring(badge.librarySize) + "\nKth mean log-distance: " + str.tostring(badge.distance, "#.###") + "\nConditional on one barrier resolving within the deadline. Not a calibrated probability or trade win rate."
                drawnLabels.push(label.new(badge.index, badge.price, "C " + str.tostring(badge.vote * 100, "#") + "%", style = label.style_none, textcolor = badge.side == 1 ? buyInput : sellInput, size = size.small, tooltip = tip))
    if zonesInput and rawMarksInput and highlights.size() > 0
        for event in highlights
            if event.index >= bar_index - 4900
                color base = event.side == 1 ? buyInput : sellInput
                int right = math.min(event.index + 8, bar_index + 2)
                drawnBoxes.push(box.new(event.index, event.top, right, event.bottom, bgcolor = color.new(base, 90), border_color = color.new(base, 65)))
    float minimum = na
    float maximum = na
    int validBars = 0
    float sumBuy = 0.0
    float sumSell = 0.0
    float sumNeutral = 0.0
    if history.size() > 0
        for candle in history
            if candle.available
                validBars += 1
                sumBuy += candle.volumesBuy.sum()
                sumSell += candle.volumesSell.sum()
                sumNeutral += candle.volumesNeutral.sum()
                for i = 0 to candle.volumesBuy.size() - 1
                    if candle.volumesBuy.get(i) > 0
                        minimum := na(minimum) ? candle.pricesBuy.get(i) : math.min(minimum, candle.pricesBuy.get(i))
                        maximum := na(maximum) ? candle.pricesBuy.get(i) : math.max(maximum, candle.pricesBuy.get(i))
                    if candle.volumesSell.get(i) > 0
                        minimum := na(minimum) ? candle.pricesSell.get(i) : math.min(minimum, candle.pricesSell.get(i))
                        maximum := na(maximum) ? candle.pricesSell.get(i) : math.max(maximum, candle.pricesSell.get(i))
                    if candle.volumesNeutral.get(i) > 0
                        minimum := na(minimum) ? candle.pricesNeutral.get(i) : math.min(minimum, candle.pricesNeutral.get(i))
                        maximum := na(maximum) ? candle.pricesNeutral.get(i) : math.max(maximum, candle.pricesNeutral.get(i))
    float profileTotal = sumBuy + sumSell + sumNeutral
    bool profileInRange = na(visibleRight) or visibleRight >= bar_index - 4900
    if profileInput and profileTotal > 0 and not na(minimum) and profileInRange
        float unit = math.max((maximum - minimum) / rowsInput, syminfo.mintick)
        array<float> binsBuy = array.new<float>(rowsInput, 0.0)
        array<float> binsSell = array.new<float>(rowsInput, 0.0)
        array<float> binsNeutral = array.new<float>(rowsInput, 0.0)
        for candle in history
            if candle.available
                for i = 0 to candle.volumesBuy.size() - 1
                    if candle.volumesBuy.get(i) > 0
                        int bin = int(math.max(0, math.min(rowsInput - 1, math.floor((candle.pricesBuy.get(i) - minimum) / unit))))
                        binsBuy.set(bin, binsBuy.get(bin) + candle.volumesBuy.get(i))
                    if candle.volumesSell.get(i) > 0
                        int bin = int(math.max(0, math.min(rowsInput - 1, math.floor((candle.pricesSell.get(i) - minimum) / unit))))
                        binsSell.set(bin, binsSell.get(bin) + candle.volumesSell.get(i))
                    if candle.volumesNeutral.get(i) > 0
                        int bin = int(math.max(0, math.min(rowsInput - 1, math.floor((candle.pricesNeutral.get(i) - minimum) / unit))))
                        binsNeutral.set(bin, binsNeutral.get(bin) + candle.volumesNeutral.get(i))
        float peakSide = 0.0
        float peakTotal = 0.0
        int peakRow = 0
        for i = 0 to rowsInput - 1
            peakSide := math.max(peakSide, math.max(binsSell.get(i), binsBuy.get(i) + binsNeutral.get(i)))
            float rowTotal = binsBuy.get(i) + binsSell.get(i) + binsNeutral.get(i)
            if rowTotal > peakTotal
                peakTotal := rowTotal
                peakRow := i
        int anchor = na(visibleRight) ? bar_index : visibleRight
        int visibleBars = not na(visibleLeft) ? anchor - visibleLeft + 1 : profileWindowInput
        int profileWidth = profilePlacement == "Inside chart" ? int(math.max(2, math.min(widthInput, math.floor((visibleBars - 3) / 2.0)))) : widthInput
        int axis = profilePlacement == "Inside chart" ? anchor - profileWidth : anchor + offsetInput + profileWidth
        for i = 0 to rowsInput - 1
            float bottom = minimum + i * unit + unit * 0.07
            float top = minimum + (i + 1) * unit - unit * 0.07
            float buy = binsBuy.get(i)
            float sell = binsSell.get(i)
            float neutral = binsNeutral.get(i)
            int buyWidth = buy > 0 ? int(math.max(1, math.round(profileWidth * buy / peakSide))) : 0
            int sellWidth = sell > 0 ? int(math.max(1, math.round(profileWidth * sell / peakSide))) : 0
            int neutralWidth = neutral > 0 ? int(math.max(1, math.round(profileWidth * neutral / peakSide))) : 0
            if sellWidth > 0
                f_segment(axis - sellWidth, axis, top, bottom, sellInput, sell / peakSide, i == peakRow)
            if buyWidth > 0
                f_segment(axis, axis + buyWidth, top, bottom, buyInput, buy / peakSide, i == peakRow)
            if neutralWidth > 0
                f_segment(axis + buyWidth, axis + buyWidth + neutralWidth, top, bottom, #76849A, neutral / peakSide, i == peakRow)
        drawnLines.push(line.new(axis, minimum, axis, minimum + rowsInput * unit, color = #506079))
        f_label(axis - int(profileWidth * 0.5), minimum + (rowsInput + 1.1) * unit, "SELL VOL", sellInput)
        f_label(axis + int(profileWidth * 0.5), minimum + (rowsInput + 1.1) * unit, "BUY VOL", buyInput)
        string title = "VOLUME PROFILE · " + str.tostring(validBars) + "/" + str.tostring(history.size()) + " bars"
        f_label(axis, minimum - unit * 0.9, title, #A9B6CA)
        f_label(axis, minimum - unit * 1.8, "Intrabar estimate · grey = neutral", #78879E)

    if managedInput and planLevelsInput and viewPlanSide != 0 and not na(viewPlanEntryBar) and viewPlanEntryBar >= bar_index - 4900
        int riskRight = (na(visibleRight) ? bar_index : visibleRight) + 3
        drawnLines.push(line.new(viewPlanEntryBar, viewPlanEntry, riskRight, viewPlanEntry, color = #CFD8E6, style = line.style_dotted))
        drawnLines.push(line.new(viewPlanEntryBar, viewPlanStop, riskRight, viewPlanStop, color = #94A3B8, style = line.style_dashed))
        drawnLines.push(line.new(viewPlanEntryBar, viewPlanTarget, riskRight, viewPlanTarget, color = #94A3B8, style = line.style_dashed))
        f_label(riskRight, viewPlanStop, "SL ref · " + str.tostring(viewPlanStop, format.mintick), #A9B6CA)
        f_label(riskRight, viewPlanTarget, "TP ref · " + str.tostring(viewPlanTarget, format.mintick), #A9B6CA)
    table.clear(dash, 0, 0, 1, 27)
    if dashboardInput and not publicationInput
        string planState = not managedInput ? "MANAGED OFF" : viewPlanSide == 1 ? "BUY PLAN OPEN" : viewPlanSide == -1 ? "SELL PLAN OPEN" : viewPendingSide == 1 ? "BUY · NEXT OPEN REFERENCE" : viewPendingSide == -1 ? "SELL · NEXT OPEN REFERENCE" : "FLAT / WAITING"
        color planInk = viewPlanSide == 1 or viewPendingSide == 1 ? buyInput : viewPlanSide == -1 or viewPendingSide == -1 ? sellInput : #A9B6CA
        table.cell(dash, 0, 0, "ORDER FLOW AI", text_color = #EAF0FA, text_size = size.small)
        table.cell(dash, 1, 0, "V2 · MODEL PLAN", text_color = #A9B6CA, text_size = size.small)
        table.cell(dash, 0, 1, "Position plan", text_color = #91A0B7, text_size = size.small, text_halign = text.align_left)
        table.cell(dash, 1, 1, planState, text_color = planInk, text_size = size.small, text_halign = text.align_left)
        table.cell(dash, 0, 2, "SL / TP reference", text_color = #91A0B7, text_size = size.small, text_halign = text.align_left)
        table.cell(dash, 1, 2, viewPlanSide != 0 ? str.tostring(viewPlanStop, format.mintick) + " / " + str.tostring(viewPlanTarget, format.mintick) : "No active levels", text_color = #D9E1ED, text_size = size.small, text_halign = text.align_left)
        table.cell(dash, 0, 3, "Last model exit", text_color = #91A0B7, text_size = size.small, text_halign = text.align_left)
        table.cell(dash, 1, 3, viewPlanReason + (na(viewPlanExitAge) ? "" : " · " + str.tostring(viewPlanExitAge) + " bars ago"), text_color = #D9E1ED, text_size = size.small, text_halign = text.align_left)
        string historicalVote = mlInput ? (na(viewVote) ? viewModelState : str.tostring(viewVote * 100, "#.#") + "% continuation · " + (viewModelSide == 1 ? "BUY pressure" : "SELL pressure") + (na(viewModelAge) ? "" : " · " + str.tostring(viewModelAge) + " bars ago")) : "ML OFF"
        table.cell(dash, 0, 4, "ML · last pressure case", text_color = #91A0B7, text_size = size.small, text_halign = text.align_left)
        table.cell(dash, 1, 4, historicalVote, text_color = #A9B6CA, text_size = size.small, text_halign = text.align_left)
        int row = 5
        if legendInput
            array<string> left = array.from("CHART GUIDE", "BUY", "EXIT BUY", "SELL", "EXIT SELL", "SL / TP / trail", "Raw circles / diamonds", "Profile rectangles", "Model ≠ broker state")
            array<string> right = array.from("Text describes model actions", "Open long plan", "Close long plan · not SELL entry", "Open short plan", "Close short plan · not BUY entry", "Hypothetical references", "Optional pressure observations", "Estimated sell / buy volume", "Fills and native exits not observed")
            for i = 0 to left.size() - 1
                color ink = i == 1 ? buyInput : i == 3 ? sellInput : #D9E1ED
                table.cell(dash, 0, row, left.get(i), text_color = ink, text_size = size.small, text_halign = text.align_left)
                table.cell(dash, 1, row, right.get(i), text_color = #A9B6CA, text_size = size.small, text_halign = text.align_left)
                row += 1
        if researchInput
            array<string> names = array.from("Library / decisive", "Discarded / ambiguous", "Baseline / Brier", "Model entries / exits", "Same-side ignored", "Both-touch stop-first")
            array<string> values = array.from(str.tostring(viewLibrary) + " / " + str.tostring(viewResolved), str.tostring(viewTimeout + viewAmbiguous + viewInvalid) + " / " + str.tostring(viewAmbiguous), (na(viewBase) ? "—" : str.tostring(viewBase * 100, "#.#") + "%") + " / " + (na(viewBrier) ? "—" : str.tostring(viewBrier, "#.###")), str.tostring(viewManagedEntries) + " / " + str.tostring(viewManagedExits), str.tostring(viewSameSide), str.tostring(viewPlanAmbiguous))
            for i = 0 to names.size() - 1
                table.cell(dash, 0, row, names.get(i), text_color = #91A0B7, text_size = size.small, text_halign = text.align_left)
                table.cell(dash, 1, row, values.get(i), text_color = #A9B6CA, text_size = size.small, text_halign = text.align_left)
                row += 1
        table.cell(dash, 0, row, "Feed / closed pressure", text_color = #91A0B7, text_size = size.small, text_halign = text.align_left)
        table.cell(dash, 1, row, lastState, text_color = #A9B6CA, text_size = size.small, text_halign = text.align_left)

// Map BUY/SELL to entries and both EXIT events to close-only messages, never reversal.
// Configure Once Per Bar Close. Recreate old v1 alerts after upgrading.
alertcondition(managedBuy, "BUY — open long plan", "BUY | {{ticker}} {{interval}} | Model entry intent; next-open reference. Not a broker fill acknowledgement.")
alertcondition(managedSell, "SELL — open short plan", "SELL | {{ticker}} {{interval}} | Model entry intent; next-open reference. Not a broker fill acknowledgement.")
alertcondition(exitBuy, "EXIT BUY — close long plan", "EXIT BUY | {{ticker}} {{interval}} | Close-only intent, never a new SELL entry. Bar-close delivery; broker state not observed.")
alertcondition(exitSell, "EXIT SELL — close short plan", "EXIT SELL | {{ticker}} {{interval}} | Close-only intent, never a new BUY entry. Bar-close delivery; broker state not observed.")

// PUBLICATION DESCRIPTION — reference only; paste clean prose separately.
// Order Flow AI
//
// Order Flow AI compares estimated buying/selling activity with the price response it produces. Version 2 adds an explicit, one-position model plan: BUY, SELL, EXIT BUY and EXIT SELL. Repeated pressure observations no longer replace an existing plan.
//
// ――――――――――――――――――――――――――――――――――――――
//
// 🔷 WHAT IT MEASURES
// 🔸 Lower-timeframe volume classified by price direction. Rising intrabars contribute buying volume, falling intrabars selling volume; unresolved direction remains neutral. This is an OHLCV estimate, not exchange bid/ask aggressor data, an order book or a native footprint.
// 🔸 Directional effort: estimated net volume as a share of total classified volume, plus activity relative to the 30 immediately preceding chart bars, all requiring usable source data.
// 🔸 Price response: the chart candle's body movement in the pressure direction, measured against the previous candle's ATR. DRIVE means pressure accompanied movement; RESISTED means little or opposing movement. Neither observation alone is a trade instruction.
// 🔸 A rolling, volume-weighted intrabar HLC3 mean and distribution ribbon. This is a descriptive rolling mean, not session VWAP or predicted support/resistance.
// 🔸 A side profile: orange estimated selling volume on the left, blue estimated buying volume on the right, grey neutral volume appended to the right. It allocates volume to intrabar HLC3 or compressed side-group weighted prices rather than reconstructing every transaction at each price. Depth shading is decorative.
//
// ――――――――――――――――――――――――――――――――――――――
//
// 🔷 BUY, SELL AND EXITS — VERSION 2
// 🔸 BUY opens a hypothetical long plan. SELL opens a hypothetical short plan. These text labels require a confirmed DRIVE, stronger imbalance/activity, aligned rolling pressure, aligned mean slope and price position, and a limit on distance from the mean.
// 🔸 One plan at a time. Same-direction repeats do not close/reopen the plan, add size or reset its initial risk. An opposite qualified event can close the current plan; it cannot reverse the plan on the same candle.
// 🔸 EXIT BUY closes the long plan. EXIT SELL closes the short plan. Labels are minimal, single-line text without boxes, like BUY VOL / SELL VOL. The hover tooltip and dashboard identify the reason: a stop, target, break-even/trailing reference touched, qualified opposite DRIVE, flow invalidation or time limit. An optional input adds the reason as a second line.
// 🔸 After an exit, a cooldown and fresh reset evidence are required. A used side needs consecutive usable flat bars without its unspaced raw DRIVE regime before rearming. Open positions, pending entries and missing volume do not supply reset evidence.
// 🔸 Raw circles/diamonds are hidden by default and remain optional analytical observations. They do not generate v2 trading alerts. Profile bars continue to describe volume, even when their colour matches an entry label.
//
// ――――――――――――――――――――――――――――――――――――――
//
// 🔷 THE EXIT MODEL
// 🔸 A BUY/SELL on candle t schedules a reference entry at candle t+1's OPEN. Initial R is the signal's previous-bar ATR multiplied by the risk input, rounded upward to whole ticks with a two-tick minimum. The signal candle's range never resolves its own new plan.
// 🔸 The model starts with a fixed stop and target. Break-even and trailing references only tighten protection. A newly tightened level becomes active on the next candle; the script does not raise a stop using the current high and then retrospectively stop it using the same candle's low.
// 🔸 Existing boundaries are checked first. Adverse opening gaps use the opening price; favourable target gaps use the target conservatively. When an inside-open candle touches both boundaries, the model assumes stop first and counts the ambiguity.
// 🔸 Qualified opposite pressure, confirmed adverse flow and a holding deadline provide separate close events when the active price boundaries have not already ended the plan.
// 🔸 All labels and alerts arrive at confirmed CLOSE, including a boundary touched earlier in that candle. The touch price is a hypothetical reference, not an executable alert fill. Chart stop/target lines are not working broker orders. Broker-native protection is necessary for intrabar execution.
//
// ――――――――――――――――――――――――――――――――――――――
//
// 🔷 THE ML ENGINE
// 🔸 An instance-based, distance-weighted K-nearest-neighbour classifier learns seven normalized pressure/response features from already-resolved raw events. Its distance averages log(1 + absolute feature difference), commonly described as Lorentzian-style distance; this is an established algorithm, not a new model architecture or external AI service.
// 🔸 The event's features, prior ATR, vote and baseline freeze at its confirmed close. Symmetric outcome barriers are checked from the following candle. A pressure-side first touch labels continuation, an opposite first touch labels opposition; same-candle double touches and timeouts are discarded.
// 🔸 The exact K nearest resolved cases vote only when every selected neighbour passes the distance ceiling. Distance weights are shrunk toward the library's smoothed base rate using their effective weight count.
// 🔸 Below warmup/K the read says LEARNING; a sufficient library with only one outcome class says NEED BOTH OUTCOMES. Distant matches produce NO CLOSE ANALOGUE. The vote describes historical decisive cases, not a calibrated chance of profit.
// 🔸 Managed entries do not change the raw training population. The optional entry ML gate uses only the current event's valid continuation vote. It defaults OFF: existing validation has not demonstrated an ML advantage. The AI name refers to the real learning component, not a guarantee that every entry is AI-selected.
//
// ――――――――――――――――――――――――――――――――――――――
//
// 🔷 KEY INPUTS — DEFAULTS
// Intrabar timeframe — automatic 1m through 1h charts, then progressively larger intrabars; it must remain below the chart timeframe. On a 1m chart choose supported seconds data manually.
// Flow distribution / Side profile — 20 / 48 chart bars; 24 profile rows.
// Raw observation thresholds — 25% imbalance, 1.2× relative volume, 0.35 ATR DRIVE, 0.10 ATR RESISTED ceiling; shared 3-bar spacing.
// Managed entry thresholds — 35% imbalance, 1.5× relative volume, 5% aligned rolling pressure; 3-bar mean slope and maximum 1.5 ATR distance from the mean.
// Cooldown / Re-arm — 8 bars after exit / 3 consecutive usable flat quiet bars for a used side.
// Initial risk / Target — 1.5 prior ATR / 2R.
// Break-even reference — activates after 0.75R favourable excursion, with a 0.05R entry buffer; this does not guarantee costs are covered.
// Trail reference — activates after 1R favourable excursion, 0.75R distance from the favourable extreme.
// Flow invalidation / Holding deadline — 2 consecutive adverse usable closes / 48 bars, counting the reference fill candle as bar one.
// K / Library / Warmup — 9 / 240 / 40 resolved cases.
// Shrinkage / Maximum mean log-distance — 4.0 / 0.16.
// ML outcome barrier / Deadline — 0.75 prior ATR / 12 later bars. These train the pressure classifier; they are separate from managed trade risk.
// Optional entry ML gate — OFF; when enabled, current-event continuation vote must reach 0.65 by default.
// Managed plan start — all loaded history by default; a chosen future start can initialize a fresh plan, but cannot synchronize a broker position.
// Publication cover mode — a lower heading and compact text key; presentation does not change learning or action rules.
// Action text — plain labels at 12 pixels by default, adjustable; optional EXIT reason line defaults OFF.
//
// ――――――――――――――――――――――――――――――――――――――
//
// 🔷 ALERTS AND REQUIREMENTS
// 🔸 Automation compatible through four separate candle-close alertconditions: BUY — open long plan; SELL — open short plan; EXIT BUY — close long plan; EXIT SELL — close short plan. Use Once Per Bar Close. Both EXIT events are close-only intents, not opposite entries.
// 🔸 Old alerts retain their saved v1 script/settings. Recreate them after upgrading; updating a public script does not migrate running alerts.
// 🔸 Configure the chosen webhook receiver's documented entry/close messages and protective orders. Default messages are plain text, not receiver-specific order JSON. Automation compatibility refers to the separate alert intents; execution integration has not been tested. The indicator does not execute orders or observe acknowledgements, rejected/partial fills, manual trades or independent broker exits.
// 🔸 Use standard time-based candles with valid intrabar volume. Missing intrabar volume blocks new entries and new ML case collection; existing pending ML cases still resolve/train from valid chart prices, and existing reference risk checks continue when chart OHLC is valid. If a scheduled reference fill has invalid OHLC, the plan cancels and emits its named EXIT without inventing a fill.
// 🔸 Loaded-history changes rebuild the library and plan from the new starting point, so earlier votes/actions can differ after a reload. Within one run, closed actions do not borrow future candles. A historical label is not evidence that a realtime webhook was delivered.
//
// ――――――――――――――――――――――――――――――――――――――
//
// 🔷 VALIDATION AND LIMITATIONS
// 🔸 Independent offline validation covered a fixed 30-day BTC/ETH cash-market sample at 5m and 15m. All 29 synthetic lifecycle checks passed, including duplicate suppression, next-open references, long/short gap handling, cooldown, rearming and non-retrospective trailing updates.
// 🔸 Default entry counts fell from raw DRIVE counts of 743 to 50 on BTC 5m and 754 to 53 on ETH 5m. Fewer entries do not establish better profitability.
// 🔸 Three of the four managed samples were negative after illustrative fees of 4 basis points per side and adverse slippage of 2 basis points per side, with exits priced at the OPEN after the exit alert's CLOSE. This is neither a profitable-edge claim nor a futures/broker test.
// 🔸 Server compilation and an independent simulator do not establish native chart rendering, live alert delivery or broker synchronization. This indicator is a model and analysis tool; it cannot guarantee profit, prevent every loss or replace execution risk controls.
//
// Built in Pine Script v6. Open source — MPL 2.0.
````
