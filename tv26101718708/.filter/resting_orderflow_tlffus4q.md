# Resting OrderFlow

- url: https://www.tradingview.com/script/TlFFus4Q-Resting-OrderFlow/
- type: indicator
- pine_id: PUB;dc52d5941e4f433fb230fb9cc921b58e
- version: 1.0

## Description

Resting OrderFlow — The Complete Guide

See where the buying and selling is still sitting. Then trade the reaction.
Resting OrderFlow is a TradingView overlay that turns the volume footprint into a map of resting liquidity: the price rows where buyers or sellers dominated and price has not yet traded back through. It draws the strongest of those rows as gradient nodes that reach toward the current bar, merges nearby rows into clusters, tracks the period Point of Control as its own node, and shows the live bar's order flow in a pressure column beside price.

This guide covers what the indicator measures, how every node is built, every setting, how to read the chart, and the honest limits of the data.

1. What It Measures — And What It Doesn't

Start with the one thing every user must know: Pine Script has no access to the order book. There is no DOM, no bid/ask depth, no queue. What TradingView does provide is the volume footprint: for every bar, the buy volume and sell volume that actually traded at each price row.

Resting OrderFlow builds its map from that executed volume:

Every price row accumulates buy volume and sell volume each time price trades there.
A row's resting size is its net delta, buy minus sell. Positive delta means buyers dominated at that price; negative means sellers did.
Orders in a label is the number of bars that printed volume at that row. It is a count of prints, not a count of limit orders.
Value is that resting size expressed in currency: volume × price × point value.
So a BUY node is a price where buyers absorbed selling and price has since moved above it. The thesis is simple: participants who defended a price once tend to be interested there again. The indicator shows you where those prices are. Whether they hold is for you to judge, bar by bar.

Data requirements
The footprint request needs a Premium or Ultimate TradingView plan and a symbol with real volume. Stocks, ETFs, futures, and crypto work. Cash indices report a synthetic volume; see the Value Shown setting.
Footprint data is not available in Bar Replay. The indicator has a proxy mode for that, covered in section 9.
Footprint history is built from intrabar data whose granularity depends on the chart timeframe and how deep into history a bar sits. Recent bars are the most precise.

2. Reading the Chart

BUY nodes (green)
Rows at or below price where buyers dominated. Think of them as absorbed selling, the places buyers stepped in. They sit under price as candidate support.

SELL nodes (red)
Rows at or above price where sellers dominated. Absorbed buying, sitting over price as candidate resistance.

The node shape
Each node is a horizontal band centered on its price row:

Height and opacity scale with size. The strongest node on each side is drawn tallest and most opaque; weaker nodes shrink and fade toward the edge settings. The fill is strongest at the level itself and fades toward the top and bottom edges, so the exact price reads as the brightest line.
The node starts in front of the candle that last touched it. It never sits on top of the bar that created it.
The node ends a few bars short of the current bar while price is far away, and the gap closes as price approaches. Inside the snap distance the gap is zero, so the node and the candle meet at the level.
Fresh nodes extend forward. A node touched on the current bar has no room behind it, so it projects to the right past price instead of collapsing to a sliver.
Nodes are kept out of the pressure column automatically. A node that would run into the column is clipped just short of it, or moved to start after it if too little would remain.

The label

The label is text only, centered inside the node, bold, and formatted by what the node contains:

Single print: + $4.9M for a buy node, - $4.9M for a sell node.
Several prints: (23) + $4.9M. The number is the count of bars that printed volume there.
Cluster: (23,c) + $4.9M. The c means several nearby rows were merged into one node.
POC node: POC · (24) $513M, where the value is the period volume at that row.
Hover the label for the full tooltip: rank, price range, resting size, buy and sell volume, delta, total, orders, strength, when it was last touched, when it was first created, how many breaks it has absorbed, and its distance from price.

Absorption and expiry

When price closes through a node, a share of its size is treated as filled. The default is 50%, so a support that gets closed below keeps half its weight, then a quarter, and so on. The tooltip shows how many breaks a node has absorbed.
Rows untouched for the Level Memory window are forgotten, and the weakest rows are dropped if the tracked set exceeds the cap.

3. Cluster Nodes

Real liquidity rarely sits in a single tick. With clustering on, same-side rows are merged into one node when the whole cluster fits inside the Cluster Range, set as a percentage of price and defaulting to 0.05%.

Rows are walked from lowest to highest. A row joins the current cluster only if the span from the cluster's bottom to that row's top stays within the range; otherwise it starts a new cluster. The span is bounded, so rows never chain into a block far larger than the setting.
The cluster's size is the summed delta, its order count is the summed prints, and its range runs from the lowest row bottom to the highest row top.
A cluster is drawn centered on that range and is never shorter than the range it spans.
Ranking happens after merging, so a band of moderate rows can outrank a single large row. That is intended. A band is what resting interest usually looks like.
The tooltip of a cluster starts with CLUSTER NODE, lists how many rows were merged, and gives the delta-weighted center price.
On a $770 stock the default 0.05% is about 38 cents, or four ten-cent rows. On ES at 7700 it is about 3.85 points. Turn clustering off and every node is a single row.

4. The Period POC Node

The Point of Control is the price row with the most total volume over a period. Resting OrderFlow builds a volume profile from the same footprint rows and draws the POC as a yellow node with the same engine as the buy and sell nodes: touch-anchored start, closing gap, minimum width, column keep-out, gradient fill, label, tooltip, and alert.

Period
Session (default), Weekly, Monthly, or Quarterly. Session resets on the chart's daily boundary, which for futures is the exchange day rather than the cash open.

POC Row Size
The profile uses its own, coarser grid: a multiple of Ticks per Row. A period POC on a ten-cent row is noise; on a dollar row it is a level. Use 5 to 10 on stocks and 50 to 100 on crypto with penny ticks. ES is fine at 1 or 2.

POC Profile Data
By default the profile uses footprint bars only. Bars where the footprint request returned nothing are skipped rather than filled by the proxy, because the proxy can put an entire minute's volume, an opening auction print for instance, into one row and shift the POC in a way that changes with chart timeframe. Choose "All bars" only in Bar Replay, where every bar is proxy.

The tooltip shows the profile's composition: how many bars came from the footprint and how many were proxy, and whether those were skipped or included. If two timeframes disagree on the POC, this line tells you why.

5. The Pressure Column

A single column to the right of price shows the current bar's order flow so you can see, live, who is in control of the bar you are trading.

Rows mode (default)
The bar's footprint rows are merged into at most Max Display Rows so the text stays readable. Each display row is split into a sell cell on top and a buy cell below, sized by their volumes, with the numbers in a label beside the row. Cell shading follows volume. The row containing the bar's POC is outlined in the POC color.

Pressure mode
Two stacked blocks, SELL over BUY, whose heights follow the bar's sell versus buy share. Each block shows its percentage. "SELL volume" sits directly above the sell block and "BUY volume" directly below the buy block. With the summary on, delta, total, and imbalance counts stack on whichever side holds 51% or more.

Guides

POC guide: a line through the bar's highest-volume row. Hover its center for the row range, value, volume with the buy and sell split, and share of the bar.
Value Area guides: dotted lines at the top and bottom of the value area, using the Value Area percentage from the data settings.
Imbalance counts in the summary follow the footprint definition: a buy imbalance when a row's buy volume is at least the Imbalance percentage of the sell volume one row below, and the mirror for sells.
The column starts at Column Offset bars right of price. Move it further right if it collides with other tools; the nodes will keep out of wherever it lands.

6. Settings — Data Source

Data Source. Auto uses the footprint when available and the proxy for bars where it is not. Footprint (Live) never uses the proxy. Proxy (Bar Replay) never calls the footprint request at all, which is required in Replay.
Ticks per Row. Price size of one row. ES: 4 ticks is one point. Stocks: 10 ticks is ten cents. Crypto with penny ticks needs 500 to 1000. Aim for roughly 10 to 40 rows per bar on your working timeframe. Too fine and every node is a single print; too coarse and the column loses its shape.
Value Area %. Used by the column guides. 70 is the industry standard.
Imbalance %. Diagonal imbalance threshold. 300 means one side must be three times the other.
Proxy Intrabar Timeframe. The lower timeframe used to rebuild rows in proxy mode. Auto picks 1 minute for charts up to 4 hours, 5 minutes above that, 15 minutes on daily, and 60 minutes on weekly and higher. Seconds timeframes need a plan that supports them.
Level Memory / Calc Window. Rows untouched for this many bars are forgotten, and nothing at all is calculated further back. This is also the runtime governor: lower it if the script runs heavy.

7. Settings — Resting Nodes

Show BUY Nodes / Show SELL Nodes with the count for each side. Default 3 and 3, up to 10.
Only Nodes Touched in Last N Bars. Limits candidates to rows touched recently. 0 turns it off. 75 is a good match for what fits on a zoomed-in intraday screen.
Max Tracked Rows. Safety cap on the row set. Weakest rows go first.
Break Absorption %. Share of a node's size treated as filled on each close-through. 100 erases a node on its first break; 0 never absorbs.
Cluster Nearby Nodes with the range percentage. See section 3.
Left Offset. Bars between the last touching candle and the node's start.
Min Node Width. A node is never narrower than this; fresh nodes extend forward to reach it.
Forward Node Extra Offset. Nodes that start in front of the current bar are pushed this many more bars to the right, clear of the candle.
Right Gap. The gap between a node's end and the current bar when price is far away.
Proximity Range (ATR ×). The distance, in ATR(14), over which that gap closes to zero.
Snap Distance (rows). Within this many rows of the node the gap is zero and the node touches the candle.

8. Settings — Node Style, Column, and POC

Node Style

Buy / Sell colors.
Strength Scale. Per side gives each side's strongest node full size, so buy nodes stay visible even during a sell-off where sell nodes are thirty times larger. Shared uses one scale so sizes are directly comparable across sides, at the cost of the weaker side fading.
Height Basis. ATR scales node height with volatility. Row fixes it as a multiple of the row size.
Node Height for each basis, given as the half-height of the strongest node.
Min Height Fraction. The weakest displayed node's height as a fraction of the strongest.
Opacity: Strongest, Weakest, Edge. Transparency at the level for the strongest and weakest nodes, and at every node's outer edge.
Gradient Steps. Fills per side between the level and the edge. More is smoother.
Outline Outer Lines. Off by default; on draws the node's top and bottom faintly.
Node Label, Label Size, Label Color.
Value Shown. Notional is volume × price × point value: real dollars on ES, stocks, and ETFs. Volume shows raw volume. Custom multiplies by your own factor. Auto shows volume on index symbols, because an index's "volume" is the summed share volume of its constituents and a dollar figure from it is meaningless.
Pressure Column
Show toggle, mode, offset, width, max display rows, text size, colors, POC guide, Value Area guides, and the summary toggle. See section 5.

POC Node
Show toggle, period, profile data source, row size multiplier, and color. See section 4.

9. Bar Replay and the Proxy

Footprint data does not exist in Bar Replay, and requesting it there is a known cause of memory errors. Set Data Source to Proxy (Bar Replay) before replaying.

The proxy rebuilds each bar's rows from intrabar OHLCV at the Proxy Intrabar Timeframe, classifying each intrabar as buy or sell with the same rule the footprint uses: close above open is buy, below is sell, and a flat intrabar takes the direction of its move from the previous close. Each intrabar's volume is spread across the price rows it covers. If intrabar data has run out, the bar's volume is split by where the close sits in the range.

The proxy is an approximation. Node tooltips say includes proxy whenever any of a node's volume came from it, and the POC profile skips proxy bars by default in live mode.

10. Alerts

Three alert conditions, all evaluated on the live bar:

Price at top BUY node — price is trading into one of the displayed buy nodes.
Price at top SELL node — price is trading into one of the displayed sell nodes.
Price at period POC node — price is trading into the POC node.
Create them from the TradingView alert dialog with the indicator selected. They fire on a touch of the node's range, so a wick counts.

11. Ways to Use It
These are usage frames, not signals. The indicator marks locations; the trade is your read of the reaction.

A. Reaction at a fresh node
Price comes down into a rank 1 buy cluster for the first time since it formed. Watch the pressure column as the bar develops. Buy share rising into the level with the node holding on the close is the reaction you are looking for. A close through the node is the failure, and the node's absorbed size tells you it just gave up half its weight.

B. Retest after a break
A sell node gets closed above, absorbs half its size, and price returns to it from above. It is now a smaller node and it is below price, so it no longer qualifies as resistance and disappears. What often appears instead is a buy node at the breakout candle. That flip is worth watching.

C. POC as the session's anchor
Session POC is where the day did the most business. Price above it with the column showing buy dominance reads differently from price above it while sell share climbs. Weekly POC on the same chart gives you the larger frame without changing timeframes.

D. Node against the column
The most useful single view is a node meeting the current candle with the column beside it. The node says where interest sat before; the column says who is in control now. Agreement is the setup. Disagreement is the warning.

12. Choosing Timeframe and Row Size

Match the row to the instrument. ES: 4 to 10 ticks on 1 to 5 minute charts, 20 to 40 ticks on 15 minutes and above. Stocks: 10 ticks intraday. BTC: 500 to 1000 ticks.
Check rows per bar. Hover the POC guide or watch the column: if you see one row per bar, the row is too coarse for that timeframe; if you see hundreds, it is far too fine and every node will be a single print.
Higher timeframes thin the footprint. Deep history on 60 minute and above is built from coarser intrabars, and some symbols return no footprint on some bars there. The tooltip's "includes proxy" flag and the POC's profile line will tell you when that is happening.
Level Memory is your runtime budget. 1000 bars is comfortable on intraday charts. If the script warns that it is heavy, lower it before anything else.

13. Design Principles & Honest Behavior Notes

Inferred, not observed. Resting size comes from executed footprint volume. The indicator does not see the order book and never claims to.
Fixed price grid. TradingView anchors each bar's footprint rows to that bar's low. The indicator re-bins every row onto a fixed grid so a price means the same row on every bar and every timeframe.
Confirmed bars build the map. Levels and the POC profile update on bar close only, so live ticks are never double counted. Node drawing and the column update live.

Timeframe dependence is real. The footprint's intrabar granularity varies with chart timeframe and history depth. Two timeframes can disagree on a POC when two rows are close in volume. The coarse POC row and the footprint-only profile exist to minimize that.

Repainting by design. Like the footprint itself, recent bars can be recalculated with finer or coarser intrabar data as history loads. Nodes on the latest bars are the most precise and the most likely to adjust.
Resource-safe. All requests and calculations are gated to the calc window, drawings are redrawn from scratch each update, and the POC map prunes itself before hitting Pine's limits.

Everything is configurable. Every default here was chosen to read well on a 5 to 15 minute futures or stock chart. Change them for your instrument.

Nothing here is financial advice. Markets carry risk; past behavior of any level or pattern does not guarantee future results. Trade your own plan.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © nyejason

//@version=6
indicator("Resting OrderFlow", "Resting OF", overlay = true, max_boxes_count = 200, max_labels_count = 100, max_lines_count = 500, max_bars_back = 3200)

// ─────────────────────────────────────────────────────────────────────────────
//  RESTING ORDERFLOW
//
//  Builds a per-price delta map from TradingView's volume footprint and shows
//  where the strongest buying and selling is still resting relative to price:
//    • BUY nodes  – rows at or below price where buyers dominated (support).
//    • SELL nodes – rows at or above price where sellers dominated (resistance).
//  Rows accumulate volume every time price trades there. A close through a
//  node absorbs part of it. Nearby rows are merged into cluster nodes. A period
//  Point of Control (Session / Weekly / Monthly / Quarterly) is drawn the same
//  way, and a current-bar pressure column shows the live bar's order flow.
//
//  Notes
//  • Pine Script has no order-book (DOM) access. "Resting" size is inferred
//    from executed footprint volume: node size = |buy − sell| at that price,
//    "orders" = number of bars that printed volume there.
//  • request.footprint() needs a Premium or Ultimate plan and a symbol with
//    volume. It is not available in Bar Replay: choose "Proxy (Bar Replay)",
//    which rebuilds rows from intrabar data without calling it.
//  • Footprint rows are anchored to each bar's low. They are re-binned onto a
//    fixed price grid so levels are comparable across bars and timeframes.
// ─────────────────────────────────────────────────────────────────────────────

// ═══════════════════════════════════════ CONSTANTS ═══════════════════════════
int    MAX_ROWS_PER_BAR = 200
int    MAX_POC_ROWS     = 40000
string SRC_FP           = "Footprint"
string SRC_LTF          = "Proxy LTF"
string SRC_OHLC         = "Proxy OHLC"
string SRC_NONE         = "No data"

// ═══════════════════════════════════════ INPUTS ══════════════════════════════
string grpData = "Data Source"
string dataMode    = input.string("Auto", "Data Source", options = ["Auto", "Footprint (Live)", "Proxy (Bar Replay)"], group = grpData,
     tooltip = "Auto: footprint when available, proxy on bars where it is not. Footprint (Live): footprint only. Proxy (Bar Replay): never calls request.footprint(); rebuilds rows from intrabar OHLCV. Required for Bar Replay.")
int    ticksPerRow = input.int(10, "Ticks per Row", minval = 1, group = grpData,
     tooltip = "Price size of one row in ticks. ES: 4 ticks = 1 point. Stocks: 10 ticks = $0.10. Crypto with $0.01 ticks needs 500–1000. Aim for 10–40 rows per bar.")
int    vaPct       = input.int(70, "Value Area %", minval = 1, maxval = 100, group = grpData)
float  imbPct      = input.float(300, "Imbalance %", minval = 100, step = 50, group = grpData,
     tooltip = "Diagonal imbalance threshold: buy volume vs the sell volume one row below, sell volume vs the buy volume one row above.")
string proxyTfIn   = input.string("Auto", "Proxy Intrabar Timeframe", options = ["Auto", "1S", "5S", "15S", "30S", "1", "3", "5", "15", "60"], group = grpData,
     tooltip = "Lower timeframe used to rebuild rows in proxy mode. Auto: 1 min for charts up to 4H, 5 min above, 15 min daily, 60 min weekly and higher. Must be lower than the chart timeframe.")
int    memoryBars  = input.int(1000, "Level Memory / Calc Window (bars)", minval = 50, maxval = 3000, group = grpData,
     tooltip = "Rows untouched for this many bars are forgotten, and nothing is calculated further back. Lower is faster.")

string grpNodes = "Resting Nodes"
bool   showBuys     = input.bool(true, "Show BUY Nodes", inline = "b", group = grpNodes)
int    nBuys        = input.int(3, "", minval = 1, maxval = 10, inline = "b", group = grpNodes, tooltip = "Number of top BUY nodes to display.")
bool   showSells    = input.bool(true, "Show SELL Nodes", inline = "s", group = grpNodes)
int    nSells       = input.int(3, "", minval = 1, maxval = 10, inline = "s", group = grpNodes, tooltip = "Number of top SELL nodes to display.")
int    recentBars   = input.int(75, "Only Nodes Touched in Last N Bars (0 = off)", minval = 0, maxval = 3000, group = grpNodes)
int    maxLevels    = input.int(1000, "Max Tracked Rows", minval = 20, maxval = 1000, group = grpNodes, tooltip = "Weakest rows are dropped first.")
float  breakKeepPct = input.float(50, "Break Absorption %", minval = 0, maxval = 100, step = 5, group = grpNodes,
     tooltip = "Share of a node's size treated as filled each time price closes through it. 100 = erased on first break, 0 = never absorbed.")
bool   clusterOn    = input.bool(true, "Cluster Nearby Nodes", inline = "c", group = grpNodes)
float  clusterPct   = input.float(0.05, "", minval = 0, step = 0.01, inline = "c", group = grpNodes,
     tooltip = "Maximum total price span of a cluster as a % of price. Same-side rows are merged while the whole cluster stays within this span. Cluster labels show (N,c).")
int    leftOffset   = input.int(1, "Left Offset (bars after last touch)", minval = 0, maxval = 50, group = grpNodes)
int    minNodeWidth = input.int(7, "Min Node Width (bars)", minval = 1, maxval = 100, group = grpNodes,
     tooltip = "A fresh node keeps its start in front of the touching candle and extends forward to reach this width.")
int    fwdExtra     = input.int(4, "Forward Node Extra Offset (bars)", minval = 0, maxval = 50, group = grpNodes,
     tooltip = "Nodes that start in front of the current bar are pushed this many extra bars to the right.")
int    rightGap     = input.int(5, "Right Gap (bars before current bar)", minval = 0, maxval = 50, group = grpNodes,
     tooltip = "Gap between a node's end and the current bar when price is far away. It closes as price approaches.")
float  proxAtrMult  = input.float(1.0, "Proximity Range (ATR ×)", minval = 0.1, step = 0.25, group = grpNodes,
     tooltip = "Distance in ATR(14) over which the right gap closes to zero.")
float  snapRows     = input.float(3.0, "Snap Distance (rows)", minval = 0, step = 0.5, group = grpNodes,
     tooltip = "Within this many rows of the node the gap is zero, so node and candle meet.")

string grpStyle = "Node Style"
color  buyCol        = input.color(#00e676, "Buy", inline = "col", group = grpStyle)
color  sellCol       = input.color(#ff1744, "Sell", inline = "col", group = grpStyle)
string strengthScale = input.string("Per side", "Strength Scale", options = ["Per side", "Shared"], group = grpStyle,
     tooltip = "Per side: each side's strongest node gets full size, so both sides stay readable. Shared: one scale across both sides.")
string heightBasis   = input.string("ATR", "Height Basis", options = ["ATR", "Row"], group = grpStyle)
float  nodeHalfAtr   = input.float(0.15, "Node Height (ATR × half-height)", minval = 0.01, step = 0.005, group = grpStyle)
float  nodeHalfRows  = input.float(0.25, "Node Height (rows × half-height)", minval = 0.05, step = 0.05, group = grpStyle)
float  minHeightFrac = input.float(0.25, "Min Height Fraction", minval = 0.05, maxval = 1, step = 0.05, group = grpStyle,
     tooltip = "Weakest displayed node height as a fraction of the strongest.")
int    alphaStrong   = input.int(10, "Opacity  Strongest", minval = 0, maxval = 95, inline = "a", group = grpStyle, tooltip = "Transparency at the level of the strongest node.")
int    alphaWeak     = input.int(85, "Weakest", minval = 0, maxval = 95, inline = "a", group = grpStyle, tooltip = "Transparency at the level of the weakest displayed node.")
int    alphaEdge     = input.int(95, "Edge", minval = 0, maxval = 100, inline = "a", group = grpStyle, tooltip = "Transparency at the top and bottom edge of every node.")
int    gradSlices    = input.int(6, "Gradient Steps (per side)", minval = 1, maxval = 6, group = grpStyle)
bool   showNodeEdge  = input.bool(false, "Outline Outer Lines", group = grpStyle)
bool   showNodeText  = input.bool(true, "Node Label", group = grpStyle)
string nodeTextSize  = input.string("Normal", "Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpStyle)
color  nodeTextCol   = input.color(#ffffff, "Label Color", group = grpStyle)
string valueMode     = input.string("Auto", "Value Shown", options = ["Auto", "Notional", "Volume", "Custom"], group = grpStyle,
     tooltip = "Notional: volume × price × point value. Volume: raw volume. Custom: volume × price × multiplier. Auto: Volume on index symbols (their volume is summed constituent shares), Notional otherwise.")
float  customMult    = input.float(1.0, "Custom Value Multiplier", minval = 0, step = 0.5, group = grpStyle)

string grpCol = "Pressure Column"
bool   showColumn  = input.bool(true, "Show Current-Bar Column", group = grpCol)
string colMode     = input.string("Rows (footprint, merged)", "Column Mode", options = ["Pressure (Sell block over Buy block)", "Rows (footprint, merged)"], group = grpCol,
     tooltip = "Pressure: two stacked blocks whose heights follow sell vs buy volume. Rows: per-row footprint merged into readable display rows, each split sell-top / buy-bottom.")
int    colOffset   = input.int(3, "Column Offset (bars right of price)", minval = 1, maxval = 100, group = grpCol, tooltip = "Resting nodes are kept out of the column automatically.")
int    colWidth    = input.int(3, "Column Width (bars)", minval = 1, maxval = 30, group = grpCol)
int    maxColRows  = input.int(10, "Max Display Rows (Rows mode)", minval = 2, maxval = 30, group = grpCol)
string colTextSize = input.string("Normal", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpCol)
color  colBuyCol   = input.color(#00c853, "Buy", inline = "cc", group = grpCol)
color  colSellCol  = input.color(#ff1744, "Sell", inline = "cc", group = grpCol)
color  colTextCol  = input.color(#ffffff, "Text", inline = "cc", group = grpCol)
bool   showPoc     = input.bool(true, "POC Guide", inline = "p", group = grpCol)
color  pocCol      = input.color(#ffd600, "", inline = "p", group = grpCol)
bool   showVA      = input.bool(true, "Value Area Guides", inline = "v", group = grpCol)
color  vaCol       = input.color(#9e9e9e, "", inline = "v", group = grpCol)
bool   showSummary = input.bool(false, "Delta / Total / Imbalance Summary", group = grpCol)

string grpPoc = "POC Node"
bool   showPocNode = input.bool(true, "Show Period POC Node", group = grpPoc,
     tooltip = "Row with the highest total footprint volume this period, drawn with the same engine as the buy and sell nodes.")
string pocPeriod   = input.string("Session", "POC Period", options = ["Session", "Weekly", "Monthly", "Quarterly"], group = grpPoc,
     tooltip = "Session resets on the chart's daily boundary.")
string pocSource   = input.string("Footprint bars only", "POC Profile Data", options = ["Footprint bars only", "All bars (footprint + proxy)"], group = grpPoc,
     tooltip = "Footprint bars only: bars without footprint data are skipped, so the POC does not change with chart timeframe. All bars: include proxy bars (needed in Proxy / Bar Replay mode).")
int    pocMult     = input.int(1, "POC Row Size (× Ticks per Row)", minval = 1, maxval = 1000, group = grpPoc,
     tooltip = "Row width for the period profile as a multiple of Ticks per Row. Use 5–10 on stocks and 50–100 on crypto so the POC is a meaningful price band.")
color  pocNodeCol  = input.color(color.yellow, "POC Node Color", group = grpPoc)

// ═══════════════════════════════════════ TYPES ═══════════════════════════════
// One tracked price row. Bounds are key × rowSize … (key + 1) × rowSize.
type Level
    int   key
    float buyVol       = 0.0
    float sellVol      = 0.0
    int   prints       = 0
    int   firstBar     = 0
    int   lastPrintBar = -1
    int   lastTouchBar = 0
    int   breaks       = 0
    bool  proxy        = false

method delta(Level self) =>
    self.buyVol - self.sellVol

// A displayed node: one row, a cluster of nearby rows, or the period POC.
type Node
    string side
    float  d
    float  u
    float  delta
    float  buyVol
    float  sellVol
    int    prints
    int    members
    int    firstBar
    int    lastTouchBar
    int    breaks
    bool   proxy
    float  wSum
    float  wpSum
    int    rank = 0
    float  pvol = 0.0

// ═══════════════════════════════════════ SETTINGS ════════════════════════════
float rowSize      = ticksPerRow * syminfo.mintick
float pocRowSize   = rowSize * pocMult
bool  useFootprint = dataMode != "Proxy (Bar Replay)"
bool  allowProxy   = dataMode != "Footprint (Live)"

int    chartSec = timeframe.in_seconds()
string autoTf   = chartSec <= 4 * 3600 ? "1" : timeframe.isintraday ? "5" : timeframe.isdaily ? "15" : "60"
string proxyTf  = proxyTfIn == "Auto" ? autoTf : proxyTfIn
bool   useLtf   = allowProxy and timeframe.in_seconds(proxyTf) < chartSec

bool  inWindow = last_bar_index - bar_index <= memoryBars
float atr      = ta.atr(14)
float keepFrac = 1.0 - breakKeepPct / 100.0

bool pocReset = switch pocPeriod
    "Session"   => timeframe.change("D")
    "Weekly"    => timeframe.change("W")
    "Monthly"   => timeframe.change("M")
    "Quarterly" => timeframe.change("3M")
    => false

// ═══════════════════════════════════════ HELPERS ═════════════════════════════
sizeOf(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.small

fmtVol(float v) =>
    str.tostring(v, format.volume)

fmtMoney(float v) =>
    string cur = na(syminfo.currency) ? "" : syminfo.currency == "USD" ? "$" : syminfo.currency + " "
    cur + str.tostring(v, format.volume)

fmtPct(float frac) =>
    str.tostring(frac * 100, "#") + "%"

valueOf(float vol, float price) =>
    string mode = valueMode == "Auto" ? (syminfo.type == "index" ? "Volume" : "Notional") : valueMode
    switch mode
        "Volume" => fmtVol(vol) + " vol"
        "Custom" => fmtMoney(vol * price * customMult)
        => fmtMoney(vol * price * syminfo.pointvalue)

keyOf(float price) =>
    math.floor(price / rowSize + 1e-7)

// Distribute buy/sell volume of the range [lo, hi] over grid bins by overlap.
spread(array<float> pb, array<float> ps, int baseKey, int nRows, float lo, float hi, float bv, float sv) =>
    int k0 = math.min(math.max(keyOf(lo) - baseKey, 0), nRows - 1)
    int k1 = math.min(math.max(keyOf(hi) - baseKey, k0), nRows - 1)
    if hi <= lo or k0 == k1
        pb.set(k0, pb.get(k0) + bv)
        ps.set(k0, ps.get(k0) + sv)
    else
        float span = hi - lo
        for k = k0 to k1
            float rd = (baseKey + k) * rowSize
            float ru = rd + rowSize
            float ov = math.max(0.0, math.min(hi, ru) - math.max(lo, rd)) / span
            pb.set(k, pb.get(k) + bv * ov)
            ps.set(k, ps.get(k) + sv * ov)

// ═══════════════════════════════════════ STATE ═══════════════════════════════
var map<int, Level>  levelMap   = map.new<int, Level>()
var map<int, float>  pocProfile = map.new<int, float>()
var int   pocKey    = -1
var float pocVol    = 0.0
var int   pocStart  = 0
var int   pocFpBars = 0
var int   pocPxBars = 0

var array<line>     nodeLines  = array.new<line>()
var array<linefill> nodeFills  = array.new<linefill>()
var array<label>    nodeLabels = array.new<label>()
var array<box>      nodeBoxes  = array.new<box>()
var array<box>      colBoxes   = array.new<box>()
var array<line>     colLines   = array.new<line>()
var array<label>    colLabels  = array.new<label>()

// ═══════════════════════════════════════ CURRENT-BAR ROWS ════════════════════
array<float> rDown = array.new<float>()
array<float> rUp   = array.new<float>()
array<float> rBuy  = array.new<float>()
array<float> rSell = array.new<float>()
array<int>   rKey  = array.new<int>()
string       srcTag = SRC_NONE

// Footprint rows, re-binned onto the fixed grid.
footprint fp = inWindow and useFootprint ? request.footprint(ticksPerRow, vaPct) : na
if not na(fp)
    array<volume_row> rows = fp.rows()
    if rows.size() > 0
        float lo = na
        float hi = na
        for r in rows
            float d = r.down_price()
            float u = r.up_price()
            if na(d) or na(u)
                continue
            lo := na(lo) ? d : math.min(lo, d)
            hi := na(hi) ? u : math.max(hi, u)
        if not na(lo) and not na(hi) and hi > lo
            int baseKey = keyOf(lo)
            int nRows   = math.min(keyOf(hi - syminfo.mintick * 0.5) - baseKey + 1, MAX_ROWS_PER_BAR)
            array<float> pb = array.new<float>(nRows, 0.0)
            array<float> ps = array.new<float>(nRows, 0.0)
            for r in rows
                float d = r.down_price()
                float u = r.up_price()
                if na(d) or na(u)
                    continue
                spread(pb, ps, baseKey, nRows, d, u, nz(r.buy_volume()), nz(r.sell_volume()))
            for i = 0 to nRows - 1
                float d = (baseKey + i) * rowSize
                rDown.push(d)
                rUp.push(d + rowSize)
                rBuy.push(pb.get(i))
                rSell.push(ps.get(i))
                rKey.push(baseKey + i)
            srcTag := SRC_FP

// Proxy rows from intrabar OHLCV (footprint classification rule), else a
// single-bar split by the close's position in the range.
array<float> iO = array.new<float>()
array<float> iH = array.new<float>()
array<float> iL = array.new<float>()
array<float> iC = array.new<float>()
array<float> iV = array.new<float>()
if inWindow and useLtf and rDown.size() == 0
    [o_, h_, l_, c_, v_] = request.security_lower_tf(syminfo.tickerid, proxyTf, [open, high, low, close, volume])
    iO := o_
    iH := h_
    iL := l_
    iC := c_
    iV := v_

if inWindow and rDown.size() == 0 and allowProxy and nz(volume) > 0 and high >= low
    int baseKey = keyOf(low)
    int nRows   = math.min(keyOf(high) - baseKey + 1, MAX_ROWS_PER_BAR)
    array<float> pb = array.new<float>(nRows, 0.0)
    array<float> ps = array.new<float>(nRows, 0.0)
    bool didLtf = false
    if iC.size() > 0
        float prevC    = nz(close[1], open)
        int   prevSide = 1
        for j = 0 to iC.size() - 1
            float o = iO.get(j)
            float h = iH.get(j)
            float l = iL.get(j)
            float c = iC.get(j)
            float v = iV.get(j)
            if na(v) or v <= 0 or na(c) or na(o)
                continue
            int side = c > o ? 1 : c < o ? -1 : c > prevC ? 1 : c < prevC ? -1 : prevSide
            spread(pb, ps, baseKey, nRows, math.max(l, low), math.min(h, high), side == 1 ? v : 0.0, side == 1 ? 0.0 : v)
            prevC    := c
            prevSide := side
            didLtf   := true
    if not didLtf
        float bf = high > low ? (close - low) / (high - low) : 0.5
        spread(pb, ps, baseKey, nRows, low, high, volume * bf, volume * (1.0 - bf))
    for i = 0 to nRows - 1
        float d = (baseKey + i) * rowSize
        rDown.push(d)
        rUp.push(d + rowSize)
        rBuy.push(pb.get(i))
        rSell.push(ps.get(i))
        rKey.push(baseKey + i)
    srcTag := didLtf ? SRC_LTF : SRC_OHLC

int  nRowsBar  = rDown.size()
bool colActive = showColumn and nRowsBar > 0
int  colX1     = bar_index + colOffset
int  colX2     = colX1 + colWidth - 1

// ═══════════════════════════════════════ LEVEL MAP ═══════════════════════════
if barstate.isconfirmed and inWindow
    // Accumulate this bar's rows.
    if nRowsBar > 0
        for i = 0 to nRowsBar - 1
            int key = rKey.get(i)
            Level l = levelMap.get(key)
            if na(l)
                l := Level.new(key = key, firstBar = bar_index, lastTouchBar = bar_index, proxy = srcTag != SRC_FP)
                levelMap.put(key, l)
            l.buyVol  := l.buyVol + rBuy.get(i)
            l.sellVol := l.sellVol + rSell.get(i)
            if l.lastPrintBar != bar_index
                l.prints       := l.prints + 1
                l.lastPrintBar := bar_index
            l.lastTouchBar := bar_index
            if srcTag != SRC_FP
                l.proxy := true

    // Period POC profile.
    if showPocNode
        if pocReset
            pocProfile.clear()
            pocKey    := -1
            pocVol    := 0.0
            pocStart  := bar_index
            pocFpBars := 0
            pocPxBars := 0
        bool useBar = nRowsBar > 0 and (srcTag == SRC_FP or pocSource != "Footprint bars only" or not useFootprint)
        if nRowsBar > 0
            if srcTag == SRC_FP
                pocFpBars += 1
            else
                pocPxBars += 1
        if useBar
            for i = 0 to nRowsBar - 1
                int   key = math.floor((rDown.get(i) + rUp.get(i)) * 0.5 / pocRowSize + 1e-7)
                float v   = nz(pocProfile.get(key), 0.0) + rBuy.get(i) + rSell.get(i)
                pocProfile.put(key, v)
                if v > pocVol
                    pocVol := v
                    pocKey := key
        if pocProfile.size() > MAX_POC_ROWS
            array<int> ks = pocProfile.keys()
            for k in ks
                if pocProfile.get(k) < pocVol * 0.02
                    pocProfile.remove(k)

    // Touches, break absorption, expiry.
    array<Level> lvls  = levelMap.values()
    array<int>   stale = array.new<int>()
    for lvl in lvls
        float d = lvl.key * rowSize
        float u = d + rowSize
        if high >= d and low <= u
            lvl.lastTouchBar := bar_index
        float dl = lvl.delta()
        bool brokeBuy  = dl > 0 and close < d and nz(close[1], close) >= d
        bool brokeSell = dl < 0 and close > u and nz(close[1], close) <= u
        if brokeBuy or brokeSell
            lvl.buyVol  := lvl.buyVol * keepFrac
            lvl.sellVol := lvl.sellVol * keepFrac
            lvl.breaks  := lvl.breaks + 1
        if bar_index - lvl.lastTouchBar > memoryBars or lvl.buyVol + lvl.sellVol <= 0
            stale.push(lvl.key)
    for k in stale
        levelMap.remove(k)

    // Overflow: drop the weakest rows.
    if levelMap.size() > maxLevels
        array<Level> vals = levelMap.values()
        array<float> absd = array.new<float>()
        for lvl in vals
            absd.push(math.abs(lvl.delta()))
        array<float> sorted = absd.copy()
        sorted.sort(order.ascending)
        float thr = sorted.get(vals.size() - maxLevels - 1)
        for [i, lvl] in vals
            if levelMap.size() > maxLevels and absd.get(i) <= thr
                levelMap.remove(lvl.key)

// ═══════════════════════════════════════ NODE SELECTION ══════════════════════
// Eligible rows → clusters (bounded span) → top n by |delta|.
buildNodes(bool buySide, int n) =>
    string side = buySide ? "B" : "S"
    array<int> keys = array.new<int>()
    for [k, lvl] in levelMap
        float dl = lvl.delta()
        float d  = k * rowSize
        float u  = d + rowSize
        bool ok  = buySide ? (dl > 0 and d <= close) : (dl < 0 and u >= close)
        if ok and recentBars > 0
            ok := bar_index - lvl.lastTouchBar <= recentBars
        if ok
            keys.push(k)
    keys.sort(order.ascending)
    float maxSpan = clusterOn ? clusterPct / 100.0 * close : 0.0
    array<Node> nodes = array.new<Node>()
    Node cur = na
    for k in keys
        Level lvl = levelMap.get(k)
        float d   = k * rowSize
        float u   = d + rowSize
        float dl  = lvl.delta()
        float w   = math.abs(dl)
        if not na(cur) and u - cur.d <= maxSpan + 1e-9
            cur.u            := math.max(cur.u, u)
            cur.delta        := cur.delta + dl
            cur.buyVol       := cur.buyVol + lvl.buyVol
            cur.sellVol      := cur.sellVol + lvl.sellVol
            cur.prints       := cur.prints + lvl.prints
            cur.members      := cur.members + 1
            cur.firstBar     := math.min(cur.firstBar, lvl.firstBar)
            cur.lastTouchBar := math.max(cur.lastTouchBar, lvl.lastTouchBar)
            cur.breaks       := cur.breaks + lvl.breaks
            cur.proxy        := cur.proxy or lvl.proxy
            cur.wSum         := cur.wSum + w
            cur.wpSum        := cur.wpSum + w * (d + u) * 0.5
        else
            if not na(cur)
                nodes.push(cur)
            cur := Node.new(side = side, d = d, u = u, delta = dl, buyVol = lvl.buyVol, sellVol = lvl.sellVol, prints = lvl.prints, members = 1, firstBar = lvl.firstBar, lastTouchBar = lvl.lastTouchBar, breaks = lvl.breaks, proxy = lvl.proxy, wSum = w, wpSum = w * (d + u) * 0.5)
    if not na(cur)
        nodes.push(cur)
    array<float> strn = array.new<float>()
    for nd in nodes
        strn.push(math.abs(nd.delta))
    array<Node> out = array.new<Node>()
    for r = 1 to n
        if nodes.size() == 0
            break
        int best = strn.indexof(strn.max())
        Node nd  = nodes.get(best)
        nd.rank := r
        out.push(nd)
        nodes.remove(best)
        strn.remove(best)
    out

touchedNow(Node nd) =>
    high >= nd.d and low <= nd.u

array<Node> topBuys  = array.new<Node>()
array<Node> topSells = array.new<Node>()
Node pocNode = na
bool touchBuyNow  = false
bool touchSellNow = false
bool touchPocNow  = false

if barstate.islast
    if showBuys
        topBuys := buildNodes(true, nBuys)
    if showSells
        topSells := buildNodes(false, nSells)
    for nd in topBuys
        if touchedNow(nd)
            touchBuyNow := true
    for nd in topSells
        if touchedNow(nd)
            touchSellNow := true
    if showPocNode and pocKey >= 0
        float d = pocKey * pocRowSize
        float u = d + pocRowSize
        Level lvl = levelMap.get(keyOf((d + u) * 0.5))
        if na(lvl)
            pocNode := Node.new(side = "P", d = d, u = u, delta = 0.0, buyVol = 0.0, sellVol = 0.0, prints = 0, members = 1, firstBar = pocStart, lastTouchBar = pocStart, breaks = 0, proxy = false, wSum = 0.0, wpSum = 0.0, rank = 1, pvol = pocVol)
        else
            pocNode := Node.new(side = "P", d = d, u = u, delta = lvl.delta(), buyVol = lvl.buyVol, sellVol = lvl.sellVol, prints = lvl.prints, members = 1, firstBar = lvl.firstBar, lastTouchBar = lvl.lastTouchBar, breaks = lvl.breaks, proxy = lvl.proxy, wSum = 0.0, wpSum = 0.0, rank = 1, pvol = pocVol)
        touchPocNow := touchedNow(pocNode)

// ═══════════════════════════════════════ DRAWING ═════════════════════════════
clearDrawings() =>
    for f in nodeFills
        f.delete()
    nodeFills.clear()
    for l in nodeLines
        l.delete()
    nodeLines.clear()
    for l in nodeLabels
        l.delete()
    nodeLabels.clear()
    for b in nodeBoxes
        b.delete()
    nodeBoxes.clear()
    for b in colBoxes
        b.delete()
    colBoxes.clear()
    for l in colLines
        l.delete()
    colLines.clear()
    for l in colLabels
        l.delete()
    colLabels.clear()

hLine(int x1, float y, int x2, color c) =>
    line.new(x1, y, x2, y, xloc.bar_index, extend.none, c, line.style_solid, 1)

// One node: invisible centre line at the level, outer lines at ± half-height,
// gradient fills strongest at the level, centred label, hover tooltip.
drawNode(Node nd, string kind, float norm, int total) =>
    bool  isBuy     = kind == "B"
    bool  isPoc     = kind == "P"
    bool  isCluster = nd.members > 1
    float d   = nd.d
    float u   = nd.u
    float mid = (d + u) * 0.5
    float dl  = nd.delta
    float sz  = math.abs(dl)

    // Horizontal extent.
    int   effTouch = touchedNow(nd) ? bar_index : nd.lastTouchBar
    float dist     = close > u ? close - u : close < d ? d - close : 0.0
    float snapDist = snapRows * rowSize
    float proxRng  = proxAtrMult * nz(atr, 0.0)
    float ratio    = dist <= snapDist ? 0.0 : proxRng > 0 ? math.min(1.0, (dist - snapDist) / proxRng) : 1.0
    int   gap      = math.round(rightGap * ratio)
    int   left     = math.max(effTouch + leftOffset, bar_index - 3100)
    int   right    = math.max(bar_index - gap, left + minNodeWidth)
    if colActive and right >= colX1 and left <= colX2
        if colX1 - 1 - left >= 3
            right := colX1 - 1
        else
            left  := colX2 + 2
            right := left + minNodeWidth
    if left > bar_index
        left  += fwdExtra
        right := math.max(right, left + minNodeWidth)

    // Vertical extent and opacity from strength.
    float hFrac = minHeightFrac + (1.0 - minHeightFrac) * norm
    float half  = math.max((heightBasis == "ATR" ? nodeHalfAtr * nz(atr, rowSize) : nodeHalfRows * rowSize) * hFrac, syminfo.mintick)
    half       := math.max(half, (u - d) * 0.5)
    int   coreA = math.round(alphaWeak - (alphaWeak - alphaStrong) * norm)
    color base  = isPoc ? pocNodeCol : isBuy ? buyCol : sellCol
    color invis = color.new(base, 100)

    line centre = hLine(left, mid, right, invis)
    nodeLines.push(centre)
    line prevUp = centre
    line prevDn = centre
    for s = 1 to gradSlices
        float f     = s * 1.0 / gradSlices
        bool  outer = s == gradSlices
        color lc    = outer and showNodeEdge ? color.new(base, 60) : invis
        line  upL   = hLine(left, mid + half * f, right, lc)
        line  dnL   = hLine(left, mid - half * f, right, lc)
        nodeLines.push(upL)
        nodeLines.push(dnL)
        int a = math.min(100, math.round(coreA + (alphaEdge - coreA) * ((s - 0.5) / gradSlices)))
        nodeFills.push(linefill.new(prevUp, upL, color.new(base, a)))
        nodeFills.push(linefill.new(prevDn, dnL, color.new(base, a)))
        prevUp := upL
        prevDn := dnL

    if showNodeText
        string sign = isBuy ? "+ " : "- "
        string txt  = nd.prints <= 1 and not isCluster ? sign + valueOf(sz, mid) : "(" + str.tostring(nd.prints) + (isCluster ? ",c" : "") + ") " + sign + valueOf(sz, mid)
        if isPoc
            txt := "POC · (" + str.tostring(nd.prints) + ") " + valueOf(nd.pvol, mid)
        string tip = ""
        if isPoc
            tip := str.upper(pocPeriod) + " POC  (highest-volume row this period)"
              + "\nRange: " + str.tostring(d, format.mintick) + " – " + str.tostring(u, format.mintick)
              + "\nPeriod volume at row: " + fmtVol(nd.pvol) + "  ≈ " + valueOf(nd.pvol, mid)
              + "\nTracked row (all-time, after absorption) — buy: " + fmtVol(nd.buyVol) + "  sell: " + fmtVol(nd.sellVol) + "  delta: " + fmtVol(dl)
              + "\nOrders (bars with volume): " + str.tostring(nd.prints)
              + "\nLast touched: " + str.tostring(bar_index - effTouch) + " bars ago  (node starts here)"
              + "\nFirst created: " + str.tostring(bar_index - nd.firstBar) + " bars ago"
              + "\nPeriod started: " + str.tostring(bar_index - pocStart) + " bars ago"
              + "\nProfile bars: " + str.tostring(pocFpBars) + " footprint · " + str.tostring(pocPxBars) + " proxy " + (pocSource == "Footprint bars only" and useFootprint ? "(skipped)" : "(included)")
              + "\nDistance: " + str.tostring(dist, format.mintick) + "  (gap " + str.tostring(gap) + " bars)"
              + "\nData: " + (nd.proxy ? "includes proxy" : "footprint only")
        else
            tip := (isCluster ? "CLUSTER NODE · " : "") + (isBuy ? "RESTING BUY  (bid zone)" : "RESTING SELL  (offer zone)")
              + (isCluster ? "\nRows merged: " + str.tostring(nd.members) + "   Weighted centre: " + str.tostring(nd.wSum > 0 ? nd.wpSum / nd.wSum : mid, format.mintick) : "")
              + "\nRank: " + str.tostring(nd.rank) + " / " + str.tostring(total)
              + "\nRange: " + str.tostring(d, format.mintick) + " – " + str.tostring(u, format.mintick)
              + "\nResting size (|delta|): " + fmtVol(sz) + "  ≈ " + valueOf(sz, mid)
              + "\nBuy vol: " + fmtVol(nd.buyVol) + "   Sell vol: " + fmtVol(nd.sellVol)
              + "\nDelta: " + fmtVol(dl) + "   Total: " + fmtVol(nd.buyVol + nd.sellVol)
              + "\nOrders (bars with volume): " + str.tostring(nd.prints)
              + "\nStrength: " + str.tostring(norm, "#.##")
              + "\nLast touched: " + str.tostring(bar_index - effTouch) + " bars ago  (node starts here)"
              + "\nFirst created: " + str.tostring(bar_index - nd.firstBar) + " bars ago"
              + "\nBreaks absorbed: " + str.tostring(nd.breaks) + " (×" + str.tostring(keepFrac, "#.##") + " each)"
              + "\nDistance: " + str.tostring(dist, format.mintick) + "  (gap " + str.tostring(gap) + " bars)"
              + "\nData: " + (nd.proxy ? "includes proxy" : "footprint only")
        nodeBoxes.push(box.new(left, mid + half, right, mid - half, border_color = invis, bgcolor = invis, text = txt, text_size = sizeOf(nodeTextSize), text_color = nodeTextCol, text_halign = text.align_center, text_valign = text.align_center, xloc = xloc.bar_index, text_formatting = text.format_bold))
        nodeLabels.push(label.new(math.round((left + right) * 0.5), mid, txt, xloc.bar_index, yloc.price, color.new(color.white, 100), label.style_label_center, color.new(nodeTextCol, 100), sizeOf(nodeTextSize), text.align_center, tip))

// ═══════════════════════════════════════ PRESSURE COLUMN ═════════════════════
calcVA(array<float> tot, int pocIdx) =>
    int   n      = tot.size()
    float target = tot.sum() * vaPct / 100.0
    int   lo     = pocIdx
    int   hi     = pocIdx
    float acc    = tot.get(pocIdx)
    while acc < target and (lo > 0 or hi < n - 1)
        float upV = hi < n - 1 ? tot.get(hi + 1) : -1.0
        float dnV = lo > 0     ? tot.get(lo - 1) : -1.0
        if upV >= dnV
            hi  += 1
            acc += upV
        else
            lo  -= 1
            acc += dnV
    [lo, hi]

blockText(int x1, int x2, float top, float bottom, color base, string txt, string ts) =>
    colBoxes.push(box.new(x1, top, x2, bottom, border_color = color.new(colTextCol, 70), border_width = 1, bgcolor = color.new(base, 25), text = txt, text_size = ts, text_color = colTextCol, text_halign = text.align_center, text_valign = text.align_center, xloc = xloc.bar_index, text_formatting = text.format_bold))

stackLabel(int x, float y, bool above, string txt, color txtCol, string ts, string tip) =>
    colLabels.push(label.new(x, y, txt, xloc.bar_index, yloc.price, color.new(#000000, 25), above ? label.style_label_down : label.style_label_up, txtCol, ts, text.align_center, tip, text_formatting = text.format_bold))

drawColumn() =>
    if nRowsBar > 0
        int    x1  = colX1
        int    x2  = colX2
        int    xm  = math.round((x1 + x2) * 0.5)
        string ts  = sizeOf(colTextSize)
        float  tb  = rBuy.sum()
        float  tsl = rSell.sum()
        float  tot = tb + tsl
        if tot > 0
            array<float> rt = array.new<float>()
            int nBuyImb  = 0
            int nSellImb = 0
            for i = 0 to nRowsBar - 1
                rt.push(rBuy.get(i) + rSell.get(i))
                float b = rBuy.get(i)
                float s = rSell.get(i)
                if i > 0 and b > 0 and b >= imbPct / 100.0 * rSell.get(i - 1)
                    nBuyImb += 1
                if i < nRowsBar - 1 and s > 0 and s >= imbPct / 100.0 * rBuy.get(i + 1)
                    nSellImb += 1
            int pocIdx = rt.indexof(rt.max())
            [vaLo, vaHi] = calcVA(rt, pocIdx)
            float top    = rUp.last()
            float bottom = rDown.first()

            float  dlt    = tb - tsl
            string sumTxt = "Δ " + (dlt >= 0 ? "+" : "") + fmtVol(dlt) + "  (" + fmtPct(dlt / tot) + ")"
              + "\nTotal " + fmtVol(tot)
              + "\nImb  ▲" + str.tostring(nBuyImb) + "  ▼" + str.tostring(nSellImb)
            string sumTip = "Current bar order flow · source: " + srcTag
              + "\nBuy " + fmtVol(tb) + " · Sell " + fmtVol(tsl)
              + "\nPOC " + str.tostring(rDown.get(pocIdx), format.mintick) + "–" + str.tostring(rUp.get(pocIdx), format.mintick)
              + "\nVA " + str.tostring(rDown.get(vaLo), format.mintick) + "–" + str.tostring(rUp.get(vaHi), format.mintick)
              + "\nRows " + str.tostring(nRowsBar)
            color sumCol = dlt >= 0 ? colBuyCol : colSellCol

            if colMode == "Pressure (Sell block over Buy block)"
                float minSpan = nz(atr, rowSize) * 0.5
                if top - bottom < minSpan
                    float c = (top + bottom) * 0.5
                    top    := c + minSpan * 0.5
                    bottom := c - minSpan * 0.5
                float sellFrac = tsl / tot
                float buyFrac  = 1.0 - sellFrac
                float split    = top - (top - bottom) * sellFrac
                blockText(x1, x2, top,   split,  colSellCol, fmtPct(sellFrac), ts)
                blockText(x1, x2, split, bottom, colBuyCol,  fmtPct(buyFrac),  ts)
                bool   sellDom = sellFrac >= 0.51
                string sellTxt = "SELL " + fmtVol(tsl)
                string buyTxt  = "BUY " + fmtVol(tb)
                if showSummary and sellDom
                    stackLabel(xm, top, true, sumTxt + "\n\n" + sellTxt, colSellCol, ts, sumTip)
                else
                    stackLabel(xm, top, true, sellTxt, colSellCol, ts, "Sell volume " + fmtVol(tsl) + " (" + fmtPct(sellFrac) + ")")
                if showSummary and not sellDom
                    stackLabel(xm, bottom, false, buyTxt + "\n\n" + sumTxt, colBuyCol, ts, sumTip)
                else
                    stackLabel(xm, bottom, false, buyTxt, colBuyCol, ts, "Buy volume " + fmtVol(tb) + " (" + fmtPct(buyFrac) + ")")
            else
                int nDisp = math.min(nRowsBar, maxColRows)
                int g     = math.ceil(nRowsBar * 1.0 / nDisp)
                float maxGroupTot = 0.0
                array<float> gB = array.new<float>()
                array<float> gS = array.new<float>()
                array<float> gD = array.new<float>()
                array<float> gU = array.new<float>()
                array<bool>  gP = array.new<bool>()
                int i0 = 0
                while i0 < nRowsBar
                    int i1 = math.min(i0 + g - 1, nRowsBar - 1)
                    float sb = 0.0
                    float ss = 0.0
                    bool hasPoc = false
                    for i = i0 to i1
                        sb += rBuy.get(i)
                        ss += rSell.get(i)
                        if i == pocIdx
                            hasPoc := true
                    gB.push(sb)
                    gS.push(ss)
                    gD.push(rDown.get(i0))
                    gU.push(rUp.get(i1))
                    gP.push(hasPoc)
                    maxGroupTot := math.max(maxGroupTot, sb + ss)
                    i0 := i1 + 1
                for gi = 0 to gB.size() - 1
                    float b  = gB.get(gi)
                    float s  = gS.get(gi)
                    float gd = gD.get(gi)
                    float gu = gU.get(gi)
                    float gt = b + s
                    float sf = gt > 0 ? s / gt : 0.5
                    float sp = gu - (gu - gd) * sf
                    int   al = gt > 0 ? math.round(75 - 60 * gt / math.max(maxGroupTot, 1e-9)) : 90
                    bool  isPocRow = gP.get(gi) and showPoc
                    color bc = isPocRow ? pocCol : color.new(colTextCol, 75)
                    int   bw = isPocRow ? 2 : 1
                    colBoxes.push(box.new(x1, gu, x2, sp, border_color = bc, border_width = bw, bgcolor = color.new(colSellCol, al), xloc = xloc.bar_index))
                    colBoxes.push(box.new(x1, sp, x2, gd, border_color = bc, border_width = bw, bgcolor = color.new(colBuyCol,  al), xloc = xloc.bar_index))
                    color tc = b > s ? colBuyCol : s > b ? colSellCol : colTextCol
                    colLabels.push(label.new(x2 + 1, (gu + gd) * 0.5, "S " + fmtVol(s) + "  B " + fmtVol(b), xloc.bar_index, yloc.price, color.new(#000000, 35), label.style_label_left, tc, ts, text.align_left))
                if showSummary
                    stackLabel(xm, bottom, false, sumTxt, sumCol, ts, sumTip)

            if showPoc
                float py = (rDown.get(pocIdx) + rUp.get(pocIdx)) * 0.5
                colLines.push(line.new(x1, py, x2, py, xloc.bar_index, extend.none, pocCol, line.style_solid, 2))
                float pb = rBuy.get(pocIdx)
                float ps = rSell.get(pocIdx)
                string pTip = "CURRENT BAR POC"
                  + "\nRow: " + str.tostring(rDown.get(pocIdx), format.mintick) + " – " + str.tostring(rUp.get(pocIdx), format.mintick)
                  + "\nValue: " + valueOf(pb + ps, py)
                  + "\nVolume: " + fmtVol(pb + ps) + "   (buy " + fmtVol(pb) + " · sell " + fmtVol(ps) + ")"
                  + "\nShare of bar: " + fmtPct((pb + ps) / tot)
                colLabels.push(label.new(xm, py, "POC", xloc.bar_index, yloc.price, color.new(color.white, 100), label.style_label_center, color.new(colTextCol, 100), size.small, text.align_center, pTip))
            if showVA
                colLines.push(line.new(x1, rUp.get(vaHi),   x2, rUp.get(vaHi),   xloc.bar_index, extend.none, vaCol, line.style_dotted, 1))
                colLines.push(line.new(x1, rDown.get(vaLo), x2, rDown.get(vaLo), xloc.bar_index, extend.none, vaCol, line.style_dotted, 1))

// ═══════════════════════════════════════ RENDER ══════════════════════════════
if barstate.islast
    clearDrawings()
    float maxB = 0.0
    float maxS = 0.0
    for nd in topBuys
        maxB := math.max(maxB, math.abs(nd.delta))
    for nd in topSells
        maxS := math.max(maxS, math.abs(nd.delta))
    float maxAll = math.max(maxB, maxS)
    float scaleB = strengthScale == "Per side" ? maxB : maxAll
    float scaleS = strengthScale == "Per side" ? maxS : maxAll
    if scaleB > 0
        for nd in topBuys
            drawNode(nd, "B", math.abs(nd.delta) / scaleB, topBuys.size())
    if scaleS > 0
        for nd in topSells
            drawNode(nd, "S", math.abs(nd.delta) / scaleS, topSells.size())
    if not na(pocNode)
        drawNode(pocNode, "P", 1.0, 1)
    if showColumn
        drawColumn()

// ═══════════════════════════════════════ ALERTS ══════════════════════════════
alertcondition(touchBuyNow,  "Price at top BUY node",    "Resting OF: price is trading into a top resting BUY node")
alertcondition(touchSellNow, "Price at top SELL node",   "Resting OF: price is trading into a top resting SELL node")
alertcondition(touchPocNow,  "Price at period POC node", "Resting OF: price is trading into the period POC node")
````
