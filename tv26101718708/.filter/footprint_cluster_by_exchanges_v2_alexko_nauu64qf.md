# Footprint: Cluster by Exchanges v2 [AlexKo]

- url: https://www.tradingview.com/script/Nauu64QF-footprint-cluster-by-exchanges-v2-alexko/
- type: indicator
- pine_id: PUB;910032cc8ced4dbb90121e1fb28ecfa0
- version: 2.0

## Description

Footprint: Cluster by Exchanges v2


What the Indicator Does

Detects buy and sell clusters from footprint data (POC level + delta) and draws a **stacked set of colored boxes** at each cluster — one box per connected exchange. Box height is proportional to that exchange's volume relative to its own average, so you can instantly see **which exchanges participated in forming the cluster**.

How It Works

1. Cluster Detection

A cluster is confirmed on bar close when all of the following conditions pass:

| Condition | Buy Cluster | Sell Cluster |
|-----------|-------------|--------------|
| POC position | ≤ N% from candle bottom | ≥ (100−N)% from bottom |
| Delta (optional) | > 0 | < 0 |
| Min delta % | ≥ threshold | ≥ threshold |
| Min candle volume | ≥ threshold | ≥ threshold |
| Min range (ATR %) | ≥ threshold | ≥ threshold |

2. Fetching Exchange Volumes

Once a cluster is detected, volume is pulled from each enabled exchange via `request.security()`, automatically substituting the current chart ticker.

3. Visualization — Stacked Boxes

```
▲ ← label (hover → tooltip with full details)
┌──────────┐
│ OKX │ ← h = ATR × scale × (vol_okx / avg_okx)
├──────────┤
│ Bybit │ ← height reflects relative volume
├──────────┤
│ Binance │ ← bottom box = Exchange 1 in settings
● ← POC level of the cluster candle
```

Buy cluster** → stack grows **upward** from POC
Sell cluster** → stack grows **downward** from POC
- Each box is labeled with the exchange name
- Hovering the ▲/▼ marker shows the full tooltip

---

Tooltip (example)

```
▲ BUY CLUSTER
─────────────────────────
POC: 65 420.00 (18% from bottom)
Delta: +12 450 (+8.3%)
Buy: 54.2% │ Sell: 45.8%
─────────────────────────
Exchange Volume ×avg
─────────────────────────
Binance 1.2M ×2.3
Bybit 890K ×1.8
OKX 450K ×0.9
─────────────────────────
∑ Total: 2.5M
```

---

Parameters

Footprint Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| Ticks per Row | 100 | Footprint row size in ticks |
| Value Area (%) | 70 | Value area percentage for POC calculation |

Clusters

| Parameter | Default | Description |
|-----------|---------|-------------|
| Cluster Zone (%) | 35 | POC in bottom/top N% of range = cluster. Recommended: 30–40% |
| Show Buy / Sell Clusters | true / true | Toggle each cluster type on/off |
| Accent Color: Buys / Sells | orange / blue | Color for the ▲/▼ label and frame |

Filters

| Parameter | Default | Description |
|-----------|---------|-------------|
| Confirm with Delta | true | Main filter. Buy cluster only when delta > 0 |
| Min Delta (% of Volume) | 0 | Minimum delta strength as % of volume. 0 = disabled |
| Min Candle Volume | 0 | Ignore low-activity bars. 0 = disabled |
| Min Candle Range (ATR %) | 0 | Doji filter. 0 = disabled |

Exchanges 1–5

| Parameter | Description |
|-----------|-------------|
| Enable | Toggle this exchange on/off |
| Prefix | TradingView exchange prefix: `BINANCE`, `BYBIT`, `OKX`, `BITGET`, `KRAKEN`, `COINBASE`, `BITMEX`, etc. |
| Ticker | Empty = current chart ticker. Fill manually if the exchange uses a different format (e.g. `XBTUSD` for Kraken) |
| Name | Text shown on boxes and in the tooltip |
| Color | Box fill and border color |


Bar Visualization

| Parameter | Default | Description |
|-----------|---------|-------------|
| Normalization Mode | % of Average | How bar heights are calculated (see below) |
| SMA Period (bars) | 20 | Moving average period for normalization. Volume / SMA = relative size |
| Height Scale (× ATR) | 0.08 | Base height when volume equals average. Increase if bars look too small |
| Max Multiplier | 5.0 | Growth cap. Volume > 5×average does not increase height further |
| Fill Transparency | 25 | 0 = fully opaque, 95 = nearly invisible |
| Info Label (exchanges + volumes) | true | Show per-exchange volume label outside the candle |
| Label Text Size | small | Text size for the label: tiny / small / normal |
| Label Offset (× ATR) | 0.5 | Distance from candle high/low in ATR units. 0 = flush with candle |

Normalization Modes

| Mode | Description |
|------|-------------|
| **% of Average** | Each exchange bar is scaled against its own SMA. Height = base when volume = average; capped at Max Multiplier × base |
| **% of Total** | Bar width represents the exchange's share of combined volume across all active exchanges on that bar |
| **Absolute** | All exchanges normalized against the combined average of all active exchanges |


Limitations

Object limit:** `max_boxes_count = 500`. With 3 active exchanges you can see ~165 cluster bars; with 5 exchanges ~100. Older objects are removed automatically.
Footprint data:** requires a TradingView subscription that includes Order Flow / Footprint access.
Box labels:** may not be visible if a box is very thin (small ATR or low scale). The hover tooltip always works.
Cluster detection** is based on the current chart's exchange only. Exchanges 1–5 provide volume breakdowns but do not affect whether a cluster is detected.


Alerts

| Alert Name | Trigger |
|------------|---------|
| Buy Cluster | Buy cluster detected on bar close |
| Sell Cluster | Sell cluster detected on bar close |

Alert message format: `{{ticker}} {{interval}} | Buy/Sell cluster by exchanges`

## Source Code

````pine
//@version=6
indicator("Footprint: Exchange Clusters v3.3.2 [AlexKo]", overlay = true,
         max_boxes_count  = 500,
         max_labels_count = 500)

// ─── GROUPS ──────────────────────────────────────────────────────────────────
var string GRP_TH   = "Theme"
var string GRP_FP   = "Footprint settings"
var string GRP_CLU  = "Clusters"
var string GRP_FLT  = "Filters"
var string GRP_EX1  = "Exchange 1"
var string GRP_EX2  = "Exchange 2"
var string GRP_EX3  = "Exchange 3"
var string GRP_EX4  = "Exchange 4"
var string GRP_EX5  = "Exchange 5"
var string GRP_VIZ  = "Volume stack visuals"
var string GRP_ANOM = "Volume anomalies"
var string GRP_SUM  = "Summary table"

// ─── THEME ───────────────────────────────────────────────────────────────────
// Everything here is drawn on top of the chart, so the palette of the table,
// the labels and the stacked bars depends on whether the chart background is
// light or dark. Auto mode reads it from chart.bg_color; it can also be fixed.
i_theme = input.string("Auto", "Theme", group = GRP_TH,
     options = ["Auto", "Dark", "Light"],
     tooltip = "Auto: the theme is taken from the chart background colour (chart.bg_color),\n" +
               "using perceived brightness with a threshold of 128.\n" +
               "Dark / Light: force one palette when auto detection guesses wrong, for\n" +
               "example on a custom background of medium brightness.")
i_adaptClr = input.bool(true, "Adapt colours to the light theme", group = GRP_TH,
     tooltip = "ON: exchange, cluster and anomaly colours are darkened while the light theme\n" +
               "is active, so bright yellow or cyan stays readable on a white background.\n" +
               "OFF: your colours are drawn exactly as picked.\n" +
               "On the dark theme this switch changes nothing.")
i_darkenPct = input.int(35, "Darkening strength (%)", minval = 0, maxval = 60, step = 5, group = GRP_TH,
     tooltip = "How much those colours are darkened on the light theme: every RGB channel is\n" +
               "multiplied by 1 - N/100, transparency is kept. 0 leaves colours untouched.\n" +
               "25-40 works for most palettes; above that colours drift towards black.")

// Perceived brightness of the chart background (0..255)
float thBgLuma = 0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)
bool  thIsDark = i_theme == "Dark" ? true : i_theme == "Light" ? false : thBgLuma < 128

// Darkening for the light theme, transparency preserved
thAdapt(color c) =>
    if thIsDark or not i_adaptClr or i_darkenPct <= 0 or na(c)
        c
    else
        float k = 1.0 - i_darkenPct / 100.0
        color.rgb(color.r(c) * k, color.g(c) * k, color.b(c) * k, color.t(c))

// Base text and backing colours for the active theme
color thText    = thIsDark ? color.white : #10161F                  // primary text
color thTextDim = thIsDark ? color.new(color.white, 40) : #57616F   // muted text
int   thLblAlpha = thIsDark ? 80 : 70                               // label backing transparency

// ─── FOOTPRINT SETTINGS ───────────────────────────────────────────────────────
i_tickSize  = input.int(100, "Ticks per row", minval = 1, step = 10, group = GRP_FP,
     tooltip = "THE MAIN SETTING. Height of one footprint row in ticks: it decides how finely\n" +
               "volume is split by price and therefore where the POC lands.\n" +
               "Too small and the POC jumps between neighbouring rows on every bar, too large\n" +
               "and the whole bar collapses into two or three rows.\n" +
               "Pick it from the instrument: a few dozen ticks on liquid futures, hundreds on\n" +
               "crypto pairs with a small tick. Start at 100 and adjust until the POC looks stable.")
i_valueArea = input.int(70,  "Value Area (%)", minval = 1, maxval = 100, group = GRP_FP,
     tooltip = "Share of the bar volume around the POC that forms the Value Area of the native\n" +
               "footprint request. 70 is the classic market-profile value.\n" +
               "This script uses the POC only, so the setting affects the footprint data\n" +
               "request itself, not the cluster or anomaly detection.")

// ─── CLUSTER SETTINGS ─────────────────────────────────────────────────────────
i_pocZone  = input.float(35.0, "Cluster zone (%)", minval = 5.0, maxval = 49.0, step = 5.0, group = GRP_CLU,
     tooltip = "POC inside the lower N% of the bar range makes it a buy cluster,\n" +
               "POC inside the upper N% makes it a sell cluster. Recommended 30-40.\n" +
               "Lower values mean stricter selection and fewer clusters.\n" +
               "Used by the Clusters only detection mode; it is ignored in All bars mode.")
i_showBuy  = input.bool(true,  "Show buy clusters",  group = GRP_CLU, inline = "vis",
     tooltip = "ON: bars whose POC sits low in the range are treated as buy clusters.\n" +
               "OFF: they are skipped everywhere, including the summary table and alerts.")
i_showSell = input.bool(true,  "Show sell clusters",   group = GRP_CLU, inline = "vis",
     tooltip = "ON: bars whose POC sits high in the range are treated as sell clusters.\n" +
               "OFF: they are skipped everywhere, including the summary table and alerts.")
i_buyClr   = input.color(#FF8C00, "Accent colour: buys",  group = GRP_CLU,
     tooltip = "Frame of the info label and the buy column of the summary table on a\n" +
               "non-anomalous buy event.")
i_sellClr  = input.color(#1E6FD9, "Accent colour: sells",  group = GRP_CLU,
     tooltip = "Frame of the info label and the sell column of the summary table on a\n" +
               "non-anomalous sell event.")

// ─── FILTERS ──────────────────────────────────────────────────────────────────
i_deltaFilter = input.bool(true, "Confirm with delta", group = GRP_FLT,
     tooltip = "ON: a buy cluster also needs delta above zero and a sell cluster needs delta\n" +
               "below zero, so POC position and aggression have to agree.\n" +
               "OFF: POC position alone is enough, which gives more clusters and more noise.\n" +
               "Applies to cluster detection only.")
i_minDeltaPct = input.float(0.0, "Min. delta (% of volume)", minval = 0.0, maxval = 80.0, step = 5.0, group = GRP_FLT,
     tooltip = "The absolute delta must be at least N% of the bar volume, which filters out\n" +
               "clusters where buyers and sellers were nearly balanced. 0 disables the check.\n" +
               "Reasonable values are 10-30; above 40 very few bars qualify.")
i_minVolume   = input.float(0, "Min. bar volume", minval = 0, group = GRP_FLT,
     tooltip = "Bars whose footprint volume is below this level are ignored for clusters.\n" +
               "Set it in the volume units of the chart instrument. 0 disables the check.\n" +
               "Useful on thin sessions where a tiny bar can still show a perfect POC.")
i_minRange    = input.float(0, "Min. bar range (ATR %)", minval = 0, maxval = 100, step = 5, group = GRP_FLT,
     tooltip = "Bars with a high-low range below N% of ATR(14) are ignored for clusters:\n" +
               "on a doji the POC position carries no information. 0 disables the check.\n" +
               "Try 30-50 if too many indecision bars are being marked.")

// ─── EXCHANGES ────────────────────────────────────────────────────────────────
buildSym(string prefix, string override) =>
    t = str.length(override) > 0 ? override : syminfo.ticker
    prefix + ":" + t

i_ex1_on     = input.bool(true,        "Enable", group = GRP_EX1, inline = "ex1",
     tooltip = "ON: volume of this exchange is requested, drawn as a block of the stack and\n" +
               "added to the summary table.\n" +
               "OFF: the exchange is skipped completely and costs no data request.")
i_ex1_prefix = input.string("BINANCE", "Prefix",  group = GRP_EX1, inline = "ex1",
     tooltip = "TradingView exchange prefix: BINANCE, BYBIT, OKX, BITGET, KRAKEN, COINBASE,\n" +
               "BITMEX and so on. The symbol is assembled as PREFIX:TICKER.")
i_ex1_ticker = input.string("", "Ticker (empty = auto)", group = GRP_EX1,
     tooltip = "Empty means the ticker of the current chart is reused.\n" +
               "Fill it in when the exchange writes the same instrument differently,\n" +
               "for example BTCUSD.P or XBTUSD. An unknown symbol is ignored silently.")
i_ex1_label  = input.string("Binance", "Name", group = GRP_EX1, inline = "ex1c",
     tooltip = "Short name shown in the info label and in the summary table row.\n" +
               "Names longer than 12 characters are trimmed inside the label.")
i_ex1_color  = input.color(#F0B90B,    "Colour",     group = GRP_EX1, inline = "ex1c",
     tooltip = "Colour of this block in the stack and of its row in the summary table.")

i_ex2_on     = input.bool(true,       "Enable", group = GRP_EX2, inline = "ex2",
     tooltip = "ON: volume of this exchange is requested and drawn as a block of the stack.\n" +
               "OFF: the exchange is skipped completely.")
i_ex2_prefix = input.string("BYBIT",  "Prefix",  group = GRP_EX2, inline = "ex2",
     tooltip = "TradingView exchange prefix; the symbol is assembled as PREFIX:TICKER.")
i_ex2_ticker = input.string("", "Ticker (empty = auto)", group = GRP_EX2,
     tooltip = "Empty means the ticker of the current chart is reused.\n" +
               "Fill it in when this exchange spells the instrument differently.")
i_ex2_label  = input.string("Bybit",  "Name", group = GRP_EX2, inline = "ex2c",
     tooltip = "Short name shown in the info label and in the summary table row.")
i_ex2_color  = input.color(#F7A600,   "Colour",     group = GRP_EX2, inline = "ex2c",
     tooltip = "Colour of this block in the stack and of its row in the summary table.")

i_ex3_on     = input.bool(true,     "Enable", group = GRP_EX3, inline = "ex3",
     tooltip = "ON: volume of this exchange is requested and drawn as a block of the stack.\n" +
               "OFF: the exchange is skipped completely.")
i_ex3_prefix = input.string("OKX",  "Prefix",  group = GRP_EX3, inline = "ex3",
     tooltip = "TradingView exchange prefix; the symbol is assembled as PREFIX:TICKER.")
i_ex3_ticker = input.string("", "Ticker (empty = auto)", group = GRP_EX3,
     tooltip = "Empty means the ticker of the current chart is reused.\n" +
               "Fill it in when this exchange spells the instrument differently.")
i_ex3_label  = input.string("OKX",  "Name", group = GRP_EX3, inline = "ex3c",
     tooltip = "Short name shown in the info label and in the summary table row.")
i_ex3_color  = input.color(#0ECBFF, "Colour",     group = GRP_EX3, inline = "ex3c",
     tooltip = "Colour of this block in the stack and of its row in the summary table.")

i_ex4_on     = input.bool(false,      "Enable", group = GRP_EX4, inline = "ex4",
     tooltip = "ON: volume of this exchange is requested and drawn as a block of the stack.\n" +
               "OFF (default): the exchange is skipped completely.")
i_ex4_prefix = input.string("BITGET", "Prefix",  group = GRP_EX4, inline = "ex4",
     tooltip = "TradingView exchange prefix; the symbol is assembled as PREFIX:TICKER.")
i_ex4_ticker = input.string("", "Ticker (empty = auto)", group = GRP_EX4,
     tooltip = "Empty means the ticker of the current chart is reused.\n" +
               "Fill it in when this exchange spells the instrument differently.")
i_ex4_label  = input.string("Bitget", "Name", group = GRP_EX4, inline = "ex4c",
     tooltip = "Short name shown in the info label and in the summary table row.")
i_ex4_color  = input.color(#00C076,   "Colour",     group = GRP_EX4, inline = "ex4c",
     tooltip = "Colour of this block in the stack and of its row in the summary table.")

i_ex5_on     = input.bool(false,       "Enable", group = GRP_EX5, inline = "ex5",
     tooltip = "ON: volume of this exchange is requested and drawn as a block of the stack.\n" +
               "OFF (default): the exchange is skipped completely.")
i_ex5_prefix = input.string("BITMEX",  "Prefix",  group = GRP_EX5, inline = "ex5",
     tooltip = "TradingView exchange prefix; the symbol is assembled as PREFIX:TICKER.")
i_ex5_ticker = input.string("", "Ticker (empty = auto)", group = GRP_EX5,
     tooltip = "Empty means the ticker of the current chart is reused.\n" +
               "Fill it in when this exchange spells the instrument differently,\n" +
               "for example XBTUSD on BITMEX.")
i_ex5_label  = input.string("Bitmex",  "Name", group = GRP_EX5, inline = "ex5c",
     tooltip = "Short name shown in the info label and in the summary table row.")
i_ex5_color  = input.color(#7B68EE,    "Colour",     group = GRP_EX5, inline = "ex5c",
     tooltip = "Colour of this block in the stack and of its row in the summary table.")

// ─── VOLUME STACK VISUALS ─────────────────────────────────────────────────────
i_normMode  = input.string("% of average", "Normalisation mode", group = GRP_VIZ,
     options = ["% of average", "% of total", "Absolute"],
     tooltip = "How the height of each exchange block is calculated.\n" +
               "% of average (default): height relative to the own SMA of that exchange, so\n" +
               "every exchange is compared with itself and a small venue stays visible.\n" +
               "% of total: height is the share of that exchange in the summed volume, which\n" +
               "shows composition but hides how unusual the bar is.\n" +
               "Absolute: every block is scaled by the average summed volume, so blocks stay\n" +
               "comparable across exchanges of very different size.")
i_sizeRef   = input.int(20, "SMA length (bars)", minval = 5, maxval = 200, group = GRP_VIZ,
     tooltip = "Window of the moving average that each exchange volume is measured against,\n" +
               "and the baseline of the xavg column in the summary table.\n" +
               "It only scales the drawing and the x-values; it does not filter or delay any\n" +
               "signal. Shorter reacts to recent activity, longer keeps a stable reference.")
i_sizeScale = input.float(0.08, "Height scale (x ATR)", minval = 0.01, maxval = 0.5, step = 0.01, group = GRP_VIZ,
     tooltip = "Overall size of the stack, expressed in ATR(14): a block at its reference\n" +
               "volume is drawn this tall. Raise it to make the stack readable on a wide\n" +
               "chart, lower it when stacks cover the candles.")
i_sizeMax   = input.float(5.0, "Max. factor", minval = 1.0, maxval = 20.0, step = 0.5, group = GRP_VIZ,
     tooltip = "Upper clamp on the ratio used for the block height, so one extreme bar cannot\n" +
               "draw a stack across the whole screen. A block that hits the clamp is drawn at\n" +
               "the clamp height while the label still prints the real multiple.")
i_fillAlpha = input.int(25, "Fill transparency", minval = 0, maxval = 95, group = GRP_VIZ,
     tooltip = "Transparency of the block fill: 0 is solid, 95 is nearly invisible.\n" +
               "Borders keep the exchange colour at full strength either way.")
// Info label mode: always, off, or only on anomalous bars.
// Anomalies only makes sense with anomaly detection enabled (GRP_ANOM): with the
// detector off isAnomaly is always false, so no label would ever be drawn.
i_markMode  = input.string("Always", "Info label (exchanges + volumes)", group = GRP_VIZ,
     options = ["Always", "Off", "Anomalies only"],
     tooltip = "Always (default): a label on every event.\n" +
               "Off: no labels, the stack and the alerts still work.\n" +
               "Anomalies only: a label just on events flagged as anomalies, which requires\n" +
               "volume anomaly detection to be enabled, otherwise nothing is drawn.")
i_textSz    = input.string(size.small, "Label text size", group = GRP_VIZ,
     options = [size.tiny, size.small, size.normal],
     tooltip = "Font size of the info label. Tiny keeps a busy chart readable, normal suits\n" +
               "screenshots and high-resolution screens.")
i_labelOffset = input.float(0.5, "Label offset (x ATR)", minval = 0.0, maxval = 5.0, step = 0.1, group = GRP_VIZ,
     tooltip = "Distance between the bar and its info label, measured in ATR(14).\n" +
               "Raise it when labels overlap the candles, lower it to keep them close.")

// ─── VOLUME ANOMALIES ─────────────────────────────────────────────────────────
// Two detection modes:
//  • Clusters only (v3.2) - an anomaly is searched among cluster bars, compared
//     with a rolling window of the last N clusters of the same side.
//  • All bars (by volume) (v3.3) - a volume anomaly on ANY bar: the current
//     volume is compared with a rolling window of the last N bars.
//     No POC or cluster is needed; the side comes from the sign of delta.
i_anomOn     = input.bool(true, "Enable volume anomaly detection", group = GRP_ANOM,
     tooltip = "ON: bars are checked against the rolling window and flagged as anomalies.\n" +
               "OFF: nothing is flagged, the highlight and the anomaly alert stay silent, and\n" +
               "in All bars mode no events are produced at all because the spike is the event.")
i_anomMode   = input.string("All bars (by volume)", "Detection mode", group = GRP_ANOM,
     options = ["Clusters only", "All bars (by volume)"],
     tooltip = "All bars (default): a spike of volume on any closed bar, no POC required, side\n" +
               "taken from the sign of delta. This is the mode to use for volume research.\n" +
               "Clusters only: events are POC clusters, and an anomaly is a cluster whose\n" +
               "volume is unusual among the last N clusters of the same side.")
i_anomMetric = input.string("Sum across exchanges", "Volume metric", group = GRP_ANOM,
     options = ["Footprint bar volume", "Sum across exchanges", "Absolute delta"],
     tooltip = "Which number is treated as the size of the bar when hunting for an anomaly.\n" +
               "Footprint bar volume: total volume of the footprint bar on this symbol.\n" +
               "Sum across exchanges (default): vol1..vol5 added together, so a spike has to\n" +
               "show up across venues rather than on one feed.\n" +
               "Absolute delta: |buy - sell|, which reacts to one-sided aggression instead of\n" +
               "raw turnover.")
i_anomBase   = input.string("Average", "Comparison base", group = GRP_ANOM,
     options = ["Average", "Maximum"],
     tooltip = "What the current bar or cluster is compared with.\n" +
               "Average (default): mean of the last N values, so a strong bar stands out early.\n" +
               "Maximum: the largest of the last N values, a much stricter base that only\n" +
               "flags a new record for the window.")
i_anomLen    = input.int(20, "Window (bars / clusters)", minval = 2, maxval = 500, group = GRP_ANOM,
     tooltip = "How many recent bars (All bars mode) or clusters (Clusters only mode) form the\n" +
               "comparison base. The current bar is excluded from the window.\n" +
               "Short windows adapt to the session, long windows keep a slower reference.")
i_anomPct    = input.float(150.0, "Excess threshold (%)", minval = 0.0, step = 10.0, group = GRP_ANOM,
     tooltip = "THE MAIN ANOMALY SETTING. How far the volume must exceed the base to count:\n" +
               "150 means current >= base x 2.5. Lower gives more and earlier flags, higher\n" +
               "keeps only rare extremes. Sensible range is roughly 100-300.\n" +
               "Example: recent bars printed 10 and 30 (average 20), the new bar prints 100,\n" +
               "which is +400% and therefore an anomaly.")
i_anomHl       = input.bool(true, "Highlight anomalous bars", group = GRP_ANOM,
     tooltip = "ON: the background of an anomalous bar is tinted green for long or red for\n" +
               "short.\n" +
               "OFF: no tint; labels, table and alerts are unaffected.")
i_anomColorBuy = input.color(#00E676, "Anomaly colour: long",  group = GRP_ANOM, inline = "ahl",
     tooltip = "Highlight and accent colour for a buy anomaly (long, delta >= 0).")
i_anomColorSell = input.color(#FF1744, "Anomaly colour: short", group = GRP_ANOM, inline = "ahl",
     tooltip = "Highlight and accent colour for a sell anomaly (short, delta < 0).")
i_anomAlpha    = input.int(70, "Highlight transparency", minval = 0, maxval = 95, group = GRP_ANOM,
     tooltip = "Transparency of the background tint: 0 is solid, 95 is barely visible.\n" +
               "Around 70 keeps candles readable through the highlight.")

i_alertOnEvent = input.bool(true, "Send alert() on every cluster/event", group = "Alerts",
     tooltip = "ON: the JSON payload is sent on every cluster or volume spike.\n" +
               "OFF: only anomalies can fire, if the switch below is on.")
i_alertOnAnom  = input.bool(true, "Send alert() when an anomaly is found", group = "Alerts",
     tooltip = "ON: the JSON payload is sent when a bar is flagged as a volume anomaly.\n" +
               "Leave only this one on to receive anomaly alerts and nothing else.\n" +
               "At most one message per bar is sent even if both switches match.")
alertHash = input.string("2", "Channel Hash", group = "Alerts",
     tooltip = "Free-form routing key copied into the channel_hash field of the JSON payload,\n" +
               "so a receiving bot can tell this chart apart from others.")

// ─── SUMMARY TABLE: SETTINGS ──────────────────────────────────────────────────
i_showTable = input.bool(true, "Show summary table", group = GRP_SUM,
     tooltip = "ON: the statistics panel is drawn on the last bar.\n" +
               "OFF: no panel; accumulation keeps running, so switching it back on shows the\n" +
               "same numbers.")
i_tableMode = input.string("From date", "Accumulation period", group = GRP_SUM,
     options = ["All loaded bars", "From date"],
     tooltip = "All loaded bars: everything the chart has loaded, which depends on the\n" +
               "timeframe and the account history depth.\n" +
               "From date (default): accumulation starts at the date below, which makes the\n" +
               "numbers comparable between symbols and sessions.")
i_fromDate  = input.time(timestamp("2025-01-01 00:00"), "Start date", group = GRP_SUM,
     tooltip = "First bar counted when the accumulation period is set to From date.\n" +
               "Bars before it are drawn as usual but stay out of the table totals.")
i_tblPos    = input.string("Top right", "Table position", group = GRP_SUM,
     options = ["Top left", "Top right", "Bottom left", "Bottom right", "Top centre", "Bottom centre"],
     tooltip = "Corner of the chart the summary table is docked to.\n" +
               "Move it away from the price scale or from other panels when they overlap.")
i_tblTextSz = input.string(size.small, "Table text size", group = GRP_SUM,
     options = [size.tiny, size.small, size.normal],
     tooltip = "Font size of the summary table. Tiny fits a crowded chart, normal is easier to\n" +
               "read on screenshots.")

// ─── THEME-AWARE COLOURS ─────────────────────────────────────────────────────
color exClr1     = thAdapt(i_ex1_color)
color exClr2     = thAdapt(i_ex2_color)
color exClr3     = thAdapt(i_ex3_color)
color exClr4     = thAdapt(i_ex4_color)
color exClr5     = thAdapt(i_ex5_color)
color buyClr     = thAdapt(i_buyClr)
color sellClr    = thAdapt(i_sellClr)
color anomClrBuy = thAdapt(i_anomColorBuy)
color anomClrSell= thAdapt(i_anomColorSell)

// ─── FOOTPRINT DATA ──────────────────────────────────────────────────────────
footprint fp = request.footprint(i_tickSize, i_valueArea)

float buyVol   = na
float sellVol  = na
float delta    = na
float totalVol = na
float pocMid   = na

if not na(fp)
    buyVol   := fp.buy_volume()
    sellVol  := fp.sell_volume()
    delta    := fp.delta()
    totalVol := fp.total_volume()
    volume_row pocRow = fp.poc()
    pocMid := (pocRow.up_price() + pocRow.down_price()) / 2.0

// ─── EXCHANGE VOLUMES ────────────────────────────────────────────────────────
float vol1 = i_ex1_on ? request.security(buildSym(i_ex1_prefix, i_ex1_ticker), timeframe.period, volume, ignore_invalid_symbol = true) : na
float vol2 = i_ex2_on ? request.security(buildSym(i_ex2_prefix, i_ex2_ticker), timeframe.period, volume, ignore_invalid_symbol = true) : na
float vol3 = i_ex3_on ? request.security(buildSym(i_ex3_prefix, i_ex3_ticker), timeframe.period, volume, ignore_invalid_symbol = true) : na
float vol4 = i_ex4_on ? request.security(buildSym(i_ex4_prefix, i_ex4_ticker), timeframe.period, volume, ignore_invalid_symbol = true) : na
float vol5 = i_ex5_on ? request.security(buildSym(i_ex5_prefix, i_ex5_ticker), timeframe.period, volume, ignore_invalid_symbol = true) : na

float avg1 = ta.sma(vol1, i_sizeRef)
float avg2 = ta.sma(vol2, i_sizeRef)
float avg3 = ta.sma(vol3, i_sizeRef)
float avg4 = ta.sma(vol4, i_sizeRef)
float avg5 = ta.sma(vol5, i_sizeRef)

float sumExVol = nz(vol1) + nz(vol2) + nz(vol3) + nz(vol4) + nz(vol5)
float avgTotal = ta.sma(sumExVol, i_sizeRef)

// ─── BASE CALCULATIONS ───────────────────────────────────────────────────────
float candleRange = high - low
float atrVal      = ta.atr(14)
float base        = atrVal * i_sizeScale
float pocRelPos   = candleRange > 0 and not na(pocMid) ? (pocMid - low) / candleRange : na

// ─── FILTERS ─────────────────────────────────────────────────────────────────
bool rangeOk     = i_minRange <= 0 or (atrVal > 0 and candleRange >= atrVal * (i_minRange / 100.0))
bool volOk       = i_minVolume <= 0 or (not na(totalVol) and totalVol >= i_minVolume)
bool deltaOkBuy  = not i_deltaFilter or (not na(delta) and delta > 0)
bool deltaOkSell = not i_deltaFilter or (not na(delta) and delta < 0)
bool ratioOkBuy  = i_minDeltaPct <= 0 or (not na(delta) and not na(totalVol) and totalVol > 0 and (delta / totalVol * 100) >= i_minDeltaPct)
bool ratioOkSell = i_minDeltaPct <= 0 or (not na(delta) and not na(totalVol) and totalVol > 0 and ((-delta) / totalVol * 100) >= i_minDeltaPct)

// ─── CLUSTER DETECTION ───────────────────────────────────────────────────────
float thresh      = i_pocZone / 100.0
bool  pocAtBottom = not na(pocRelPos) and pocRelPos <= thresh
bool  pocAtTop    = not na(pocRelPos) and pocRelPos >= (1.0 - thresh)

bool isBuyCluster  = barstate.isconfirmed and not na(fp) and pocAtBottom and volOk and rangeOk and deltaOkBuy  and ratioOkBuy  and i_showBuy
bool isSellCluster = barstate.isconfirmed and not na(fp) and pocAtTop    and volOk and rangeOk and deltaOkSell and ratioOkSell and i_showSell

// ─── VOLUME ANOMALY DETECTION ────────────────────────────────────────────────
bool clusterMode = i_anomMode == "Clusters only"

// Size metric chosen by the user
float anomMetricVal = i_anomMetric == "Footprint bar volume" ? nz(totalVol) :
                       i_anomMetric == "Sum across exchanges" ? sumExVol    :
                       math.abs(nz(delta))

// Base over all bars (All bars mode) - window of the last N bars, current bar
// excluded ([1]). ta.* are called unconditionally to keep the series consistent.
float volBaseSma  = ta.sma(anomMetricVal, i_anomLen)[1]
float volBaseHigh = ta.highest(anomMetricVal, i_anomLen)[1]
float volBaseAll  = i_anomBase == "Maximum" ? volBaseHigh : volBaseSma

// Separate rolling windows of clusters (Clusters only mode)
var array<float> anomHistBuy  = array.new_float()
var array<float> anomHistSell = array.new_float()

// Anomaly side: sign of delta, falling back to the candle body
bool barIsBuy = not na(delta) ? delta >= 0 : close >= open

bool  isAnomaly = false
float anomBase  = na
float anomRatio = na
bool  eventBuy  = false
bool  eventSell = false

if clusterMode
    // Events are clusters; an anomaly is a spike against previous clusters of the same side
    eventBuy  := isBuyCluster
    eventSell := isSellCluster
    if i_anomOn and (isBuyCluster or isSellCluster)
        array<float> hist = isBuyCluster ? anomHistBuy : anomHistSell
        float curVal = anomMetricVal
        if array.size(hist) > 0 and curVal > 0
            float baseVal = i_anomBase == "Maximum" ? array.max(hist) : array.avg(hist)
            anomBase := baseVal
            if not na(baseVal) and baseVal > 0
                anomRatio := curVal / baseVal
                if curVal >= baseVal * (1.0 + i_anomPct / 100.0)
                    isAnomaly := true
        array.push(hist, curVal)
        if array.size(hist) > i_anomLen
            array.shift(hist)
else
    // All bars mode: the event is a volume spike on any closed bar
    if i_anomOn and barstate.isconfirmed and anomMetricVal > 0 and not na(volBaseAll) and volBaseAll > 0
        anomBase  := volBaseAll
        anomRatio := anomMetricVal / volBaseAll
        if anomMetricVal >= volBaseAll * (1.0 + i_anomPct / 100.0)
            isAnomaly := true
            eventBuy  := barIsBuy
            eventSell := not barIsBuy

// Anomaly colour by side: long is green, short is red
color anomClr = eventBuy ? anomClrBuy : anomClrSell

// ─── FORMATTING ──────────────────────────────────────────────────────────────
fmtVol(float v) =>
    na(v) or v == 0 ? "—" :
     v >= 1e9  ? str.tostring(math.round(v / 1e9, 2)) + "B" :
     v >= 1e6  ? str.tostring(math.round(v / 1e6, 2)) + "M" :
     v >= 1e3  ? str.tostring(math.round(v / 1e3, 1)) + "K" :
     str.tostring(math.round(v, 0))

fmtVolSigned(float v) =>
    na(v) ? "—" : (v >= 0 ? "+" : "") + fmtVol(math.abs(v)) + (v < 0 ? " " : "")

// Table position: string to constant
tblPos(string s) =>
    switch s
        "Top left"      => position.top_left
        "Top right"     => position.top_right
        "Bottom left"   => position.bottom_left
        "Bottom right"  => position.bottom_right
        "Top centre"    => position.top_center
        "Bottom centre" => position.bottom_center
        => position.top_right

// Block height for the selected normalisation mode
calcH(float v, float avg) =>
    if i_normMode == "% of average"
        v > 0 and avg > 0 ? base * math.min(v / avg, i_sizeMax) : 0.0
    else if i_normMode == "% of total"
        v > 0 and sumExVol > 0 ? base * (v / sumExVol) * 5.0 : 0.0
    else
        v > 0 and avgTotal > 0 ? base * math.min(v / avgTotal, i_sizeMax) : 0.0

// One line of the label or tooltip
exLine(string lbl, float v, float avg, float sumV) =>
    string suffix = ""
    if i_normMode == "% of average"
        float ratio = avg > 0 and not na(v) ? v / avg : na
        suffix := na(ratio) ? "" : "  x" + str.tostring(math.round(ratio, 1))
    else if i_normMode == "% of total"
        float pct = sumV > 0 and not na(v) ? v / sumV * 100 : na
        suffix := na(pct) ? "" : "  " + str.tostring(math.round(pct, 1)) + "%"
    string padded = str.length(lbl) < 12 ? lbl + str.repeat(" ", 12 - str.length(lbl)) : str.substring(lbl, 0, 12)
    padded + "  " + fmtVol(v) + suffix

// ─── DRAWING THE VOLUME STACK ────────────────────────────────────────────────
if eventBuy or eventSell
    bool  isBuy    = eventBuy
    int   dir      = isBuy ? 1 : -1
    color frameClr = isAnomaly ? anomClr : (isBuy ? buyClr : sellClr)

    float h1 = i_ex1_on and not na(vol1) ? calcH(vol1, avg1) : 0.0
    float h2 = i_ex2_on and not na(vol2) ? calcH(vol2, avg2) : 0.0
    float h3 = i_ex3_on and not na(vol3) ? calcH(vol3, avg3) : 0.0
    float h4 = i_ex4_on and not na(vol4) ? calcH(vol4, avg4) : 0.0
    float h5 = i_ex5_on and not na(vol5) ? calcH(vol5, avg5) : 0.0

    // Stack anchor: the POC when available, otherwise hl2 (All bars mode)
    float y = not na(pocMid) ? pocMid : hl2

    if h1 > 0
        float bTop = dir > 0 ? y + h1 : y
        float bBot = dir > 0 ? y : y - h1
        box.new(bar_index, bTop, bar_index + 1, bBot,
             bgcolor = color.new(exClr1, i_fillAlpha), border_color = exClr1, border_width = 1)
        y := y + h1 * dir

    if h2 > 0
        float bTop = dir > 0 ? y + h2 : y
        float bBot = dir > 0 ? y : y - h2
        box.new(bar_index, bTop, bar_index + 1, bBot,
             bgcolor = color.new(exClr2, i_fillAlpha), border_color = exClr2, border_width = 1)
        y := y + h2 * dir

    if h3 > 0
        float bTop = dir > 0 ? y + h3 : y
        float bBot = dir > 0 ? y : y - h3
        box.new(bar_index, bTop, bar_index + 1, bBot,
             bgcolor = color.new(exClr3, i_fillAlpha), border_color = exClr3, border_width = 1)
        y := y + h3 * dir

    if h4 > 0
        float bTop = dir > 0 ? y + h4 : y
        float bBot = dir > 0 ? y : y - h4
        box.new(bar_index, bTop, bar_index + 1, bBot,
             bgcolor = color.new(exClr4, i_fillAlpha), border_color = exClr4, border_width = 1)
        y := y + h4 * dir

    if h5 > 0
        float bTop = dir > 0 ? y + h5 : y
        float bBot = dir > 0 ? y : y - h5
        box.new(bar_index, bTop, bar_index + 1, bBot,
             bgcolor = color.new(exClr5, i_fillAlpha), border_color = exClr5, border_width = 1)
        y := y + h5 * dir

    // Label is drawn per mode: always, or only on anomalous events
    bool showMark = i_markMode == "Always" or (i_markMode == "Anomalies only" and isAnomaly)

    if showMark
        float deltaPct = not na(totalVol) and totalVol > 0 ? delta / totalVol * 100 : 0.0
        float buyPct   = not na(totalVol) and totalVol > 0 ? buyVol  / totalVol * 100 : 0.0
        float sellPct  = not na(totalVol) and totalVol > 0 ? sellVol / totalVol * 100 : 0.0

        string normHdr = i_normMode == "% of average" ? "xavg" : i_normMode == "% of total" ? "share" : ""
        string colHdr  = "Exchange       Volume   " + normHdr

        // Anomaly marker in the label header
        string anomTag = isAnomaly ? "  🔥x" + str.tostring(math.round(nz(anomRatio), 1)) : ""

        string infoText = (isBuy ? "▲" : "▼") + anomTag
        if i_ex1_on and not na(vol1)
            infoText := infoText + "\n" + exLine(i_ex1_label, vol1, avg1, sumExVol)
        if i_ex2_on and not na(vol2)
            infoText := infoText + "\n" + exLine(i_ex2_label, vol2, avg2, sumExVol)
        if i_ex3_on and not na(vol3)
            infoText := infoText + "\n" + exLine(i_ex3_label, vol3, avg3, sumExVol)
        if i_ex4_on and not na(vol4)
            infoText := infoText + "\n" + exLine(i_ex4_label, vol4, avg4, sumExVol)
        if i_ex5_on and not na(vol5)
            infoText := infoText + "\n" + exLine(i_ex5_label, vol5, avg5, sumExVol)
        if sumExVol > 0
            infoText := infoText + "\n─────────────\n∑ " + fmtVol(sumExVol)

        string tipAnom = isAnomaly
             ? "🔥 VOLUME ANOMALY\n" +
               "Metric: " + i_anomMetric + "\n" +
               "Volume: " + fmtVol(anomMetricVal) + "  vs base " + fmtVol(anomBase) + "\n" +
               "Excess: x" + str.tostring(math.round(nz(anomRatio), 2)) +
               "  (threshold x" + str.tostring(math.round(1.0 + i_anomPct / 100.0, 2)) + ")\n" +
               "─────────────────────────\n"
             : ""

        string hdrTxt = clusterMode
             ? (isBuy ? "▲ BUY CLUSTER" : "▼ SELL CLUSTER")
             : (isBuy ? "▲ VOLUME SPIKE (long)" : "▼ VOLUME SPIKE (short)")
        string pocTxt = na(pocMid)
             ? "POC:    —\n"
             : "POC:    " + str.tostring(pocMid, format.mintick) +
               "  (" + str.tostring(math.round(pocRelPos * 100, 0)) + "% from low)\n"

        string tipMain =
             tipAnom +
             hdrTxt + "\n" +
             "─────────────────────────\n" +
             pocTxt +
             "Delta:  " + (delta >= 0 ? "+" : "") + str.tostring(math.round(nz(delta), 0)) +
             "  (" + (deltaPct >= 0 ? "+" : "") + str.tostring(math.round(deltaPct, 1)) + "%)\n" +
             "Buy:    " + str.tostring(math.round(buyPct, 1)) +
             "%  │  Sell: " + str.tostring(math.round(sellPct, 1)) + "%\n" +
             "─────────────────────────\n" +
             colHdr + "\n" +
             "─────────────────────────"
        string tipEx = ""
        if i_ex1_on and not na(vol1)
            tipEx := tipEx + "\n" + exLine(i_ex1_label, vol1, avg1, sumExVol)
        if i_ex2_on and not na(vol2)
            tipEx := tipEx + "\n" + exLine(i_ex2_label, vol2, avg2, sumExVol)
        if i_ex3_on and not na(vol3)
            tipEx := tipEx + "\n" + exLine(i_ex3_label, vol3, avg3, sumExVol)
        if i_ex4_on and not na(vol4)
            tipEx := tipEx + "\n" + exLine(i_ex4_label, vol4, avg4, sumExVol)
        if i_ex5_on and not na(vol5)
            tipEx := tipEx + "\n" + exLine(i_ex5_label, vol5, avg5, sumExVol)
        string tipSum = sumExVol > 0 ? "\n─────────────────────────\n∑ Total:      " + fmtVol(sumExVol) : ""

        float labelY = isBuy ? low - atrVal * i_labelOffset : high + atrVal * i_labelOffset
        label.new(
             x         = bar_index,
             y         = labelY,
             text      = infoText,
             tooltip   = tipMain + tipEx + tipSum,
             color     = color.new(frameClr, thLblAlpha),
             style     = isBuy ? label.style_label_upper_left : label.style_label_lower_left,
             textcolor = thText,
             size      = i_textSz)

    float _dPct = not na(totalVol) and totalVol > 0 ? delta   / totalVol * 100 : 0.0
    float _bPct = not na(totalVol) and totalVol > 0 ? buyVol  / totalVol * 100 : 0.0
    float _sPct = not na(totalVol) and totalVol > 0 ? sellVol / totalVol * 100 : 0.0

    string _e1 = i_ex1_on and not na(vol1) ? '{"n":"' + i_ex1_label + '","v":' + str.tostring(int(math.round(nz(vol1), 0))) + '}' : ""
    string _e2 = i_ex2_on and not na(vol2) ? '{"n":"' + i_ex2_label + '","v":' + str.tostring(int(math.round(nz(vol2), 0))) + '}' : ""
    string _e3 = i_ex3_on and not na(vol3) ? '{"n":"' + i_ex3_label + '","v":' + str.tostring(int(math.round(nz(vol3), 0))) + '}' : ""
    string _e4 = i_ex4_on and not na(vol4) ? '{"n":"' + i_ex4_label + '","v":' + str.tostring(int(math.round(nz(vol4), 0))) + '}' : ""
    string _e5 = i_ex5_on and not na(vol5) ? '{"n":"' + i_ex5_label + '","v":' + str.tostring(int(math.round(nz(vol5), 0))) + '}' : ""

    string _ea = ""
    if str.length(_e1) > 0
        _ea := _e1
    if str.length(_e2) > 0
        _ea := str.length(_ea) > 0 ? _ea + "," + _e2 : _e2
    if str.length(_e3) > 0
        _ea := str.length(_ea) > 0 ? _ea + "," + _e3 : _e3
    if str.length(_e4) > 0
        _ea := str.length(_ea) > 0 ? _ea + "," + _e4 : _e4
    if str.length(_e5) > 0
        _ea := str.length(_ea) > 0 ? _ea + "," + _e5 : _e5

    string _json =
         '{"signal":"'      + (isBuy ? "buy" : "sell") + '"' +
         ',"mode":"'        + (clusterMode ? "cluster" : "volume") + '"' +
         ',"ticker":"'      + syminfo.ticker + '"' +
         ',"tf":"'          + timeframe.period + '"' +
         ',"poc":'          + (na(pocMid) ? "null" : str.tostring(pocMid, format.mintick)) +
         ',"poc_pct":'      + str.tostring(math.round(nz(pocRelPos) * 100, 0)) +
         ',"delta":'        + str.tostring(int(math.round(nz(delta), 0))) +
         ',"delta_pct":'    + str.tostring(math.round(_dPct, 1)) +
         ',"buy_pct":'      + str.tostring(math.round(_bPct, 1)) +
         ',"sell_pct":'     + str.tostring(math.round(_sPct, 1)) +
         ',"vol_fp":'       + str.tostring(int(math.round(nz(totalVol), 0))) +
         ',"exchanges":['   + _ea + ']' +
         ',"vol_sum":'      + str.tostring(int(math.round(sumExVol, 0))) +
         ',"anomaly":'      + (isAnomaly ? "true" : "false") +
         ',"anomaly_metric":"' + i_anomMetric + '"' +
         ',"anomaly_val":'  + str.tostring(int(math.round(nz(anomMetricVal), 0))) +
         ',"anomaly_base":' + str.tostring(int(math.round(nz(anomBase), 0))) +
         ',"anomaly_ratio":' + str.tostring(math.round(nz(anomRatio), 2)) +
         ',"price":'         + str.tostring(close, format.mintick) +
         ',"channel_hash":"' + alertHash + '"' +
         '}'

    // Alert on the event and/or on the anomaly (at most one message per bar)
    if i_alertOnEvent or (i_alertOnAnom and isAnomaly)
        alert(_json, alert.freq_once_per_bar_close)

// Background highlight of anomalous bars (long is green, short is red)
bgcolor(i_anomHl and isAnomaly ? color.new(anomClr, i_anomAlpha) : na, title = "Volume anomaly")

// ─── SUMMARY TABLE ACCUMULATORS ──────────────────────────────────────────────
// Footprint volumes and delta accumulate ONLY on cluster bars: otherwise hundreds
// of ordinary bars with a small positive delta bury one large sell cluster.
// Exchange volumes (vol1..5) accumulate on every bar of the period as context.
var float acc_buyVol       = 0.0   // fp.buy_volume() summed over cluster bars
var float acc_sellVol      = 0.0   // fp.sell_volume() summed over cluster bars
var float acc_delta        = 0.0   // fp.delta() summed over cluster bars (cluster CVD)
var int   acc_buyCnt       = 0
var int   acc_sellCnt      = 0
var int   acc_anomCnt      = 0     // number of volume anomalies in the period
var float acc_vol1         = 0.0
var float acc_vol2         = 0.0
var float acc_vol3         = 0.0
var float acc_vol4         = 0.0
var float acc_vol5         = 0.0
var int   acc_bars         = 0
var int   acc_firstTime    = 0
var float acc_maxBuyDelta  = 0.0
var float acc_maxSellDelta = 0.0

bool inPeriod = i_tableMode == "From date" ? time >= i_fromDate : true

// Every bar: exchange volumes plus the bar counter
if barstate.isconfirmed and inPeriod
    acc_bars += 1
    if acc_firstTime == 0
        acc_firstTime := time
    if i_ex1_on and not na(vol1)
        acc_vol1 += vol1
    if i_ex2_on and not na(vol2)
        acc_vol2 += vol2
    if i_ex3_on and not na(vol3)
        acc_vol3 += vol3
    if i_ex4_on and not na(vol4)
        acc_vol4 += vol4
    if i_ex5_on and not na(vol5)
        acc_vol5 += vol5

// Cluster bars only: footprint volumes and delta
if isBuyCluster and inPeriod
    acc_buyCnt += 1
    if not na(fp)
        acc_buyVol  += nz(buyVol)
        acc_sellVol += nz(sellVol)
        acc_delta   += nz(delta)
    if not na(delta)
        acc_maxBuyDelta := math.max(acc_maxBuyDelta, delta)

if isSellCluster and inPeriod
    acc_sellCnt += 1
    if not na(fp)
        acc_buyVol  += nz(buyVol)
        acc_sellVol += nz(sellVol)
        acc_delta   += nz(delta)
    if not na(delta)
        acc_maxSellDelta := math.max(acc_maxSellDelta, math.abs(delta))

if isAnomaly and inPeriod
    acc_anomCnt += 1

// ─── SUMMARY TABLE ───────────────────────────────────────────────────────────
var table summaryTbl = na

if i_showTable and barstate.islast
    float totFP     = acc_buyVol + acc_sellVol
    float deltaPct  = totFP > 0 ? acc_delta / totFP * 100 : 0.0
    float buyShare  = totFP > 0 ? acc_buyVol  / totFP * 100 : 0.0
    float sellShare = totFP > 0 ? acc_sellVol / totFP * 100 : 0.0
    int   totClu    = acc_buyCnt + acc_sellCnt
    float buyRatio  = totClu > 0 ? acc_buyCnt  / totClu * 100.0 : 50.0
    float avgDelta  = totClu > 0 ? acc_delta   / totClu : 0.0
    bool  bullish   = acc_delta >= 0
    float sumExAcc  = nz(acc_vol1) + nz(acc_vol2) + nz(acc_vol3) + nz(acc_vol4) + nz(acc_vol5)

    // The number of enabled exchanges defines the number of table rows
    int nEx   = (i_ex1_on ? 1 : 0) + (i_ex2_on ? 1 : 0) + (i_ex3_on ? 1 : 0) + (i_ex4_on ? 1 : 0) + (i_ex5_on ? 1 : 0)
    // rows: title(1) + columns(1) + clusters(1) + volume(1) + delta(1) +
    //       avg/max delta(1) + exchange header(1) + exchanges(nEx) + total(1) + period(1) = 9 + nEx
    int nRows = 9 + nEx

    // Table palette for the active theme: on a light background the cell backings are
    // opaque, otherwise candles show through the cells and the text becomes unreadable.
    color bgDark  = thIsDark ? color.new(color.black, 15) : #E4EAF2
    color bgMid   = thIsDark ? color.new(color.black, 45) : #EFF2F7
    color bgLight = thIsDark ? color.new(color.black, 65) : #FAFBFD
    color bgHead  = thIsDark ? color.new(#0d1b2a,    5)   : #D6E0EE
    color cWhite  = thText
    color cGray   = thTextDim
    color cBuy    = buyClr
    color cSell   = sellClr

    summaryTbl := table.new(tblPos(i_tblPos), 4, nRows,
         border_width = 1, border_color = thIsDark ? color.new(color.gray, 65) : color.new(#8A94A6, 55),
         frame_width  = 1, frame_color  = thIsDark ? color.new(color.gray, 30) : color.new(#5A6472, 30))

    // -- Row 0: title -----------------------------------------------------------
    string fromLbl = i_tableMode == "From date"
         ? str.format_time(i_fromDate, "dd.MM.yy")
         : (acc_firstTime > 0 ? str.format_time(acc_firstTime, "dd.MM.yy") : "start")
    string toLbl   = str.format_time(time, "dd.MM.yy")
    string titleTxt = "SUMMARY  ·  " + syminfo.ticker + " " + timeframe.period + "  ·  " + fromLbl + " -> " + toLbl
    table.cell(summaryTbl, 0, 0, titleTxt,
         text_color = cWhite, bgcolor = bgHead,
         text_size = i_tblTextSz, text_halign = text.align_center)
    table.merge_cells(summaryTbl, 0, 0, 3, 0)

    // -- Row 1: column headers --------------------------------------------------
    table.cell(summaryTbl, 0, 1, "",           text_color = cGray,  bgcolor = bgDark, text_size = i_tblTextSz)
    table.cell(summaryTbl, 1, 1, "▲ BUYS",     text_color = cBuy,   bgcolor = bgDark, text_size = i_tblTextSz, text_halign = text.align_center)
    table.cell(summaryTbl, 2, 1, "▼ SELLS",    text_color = cSell,  bgcolor = bgDark, text_size = i_tblTextSz, text_halign = text.align_center)
    table.cell(summaryTbl, 3, 1, "TOTAL / Δ",  text_color = cGray,  bgcolor = bgDark, text_size = i_tblTextSz, text_halign = text.align_center)

    // -- Row 2: clusters --------------------------------------------------------
    string cluRatio = str.tostring(math.round(buyRatio, 0)) + "% / " + str.tostring(math.round(100 - buyRatio, 0)) + "%"
    table.cell(summaryTbl, 0, 2, "Clusters",          text_color = cGray, bgcolor = bgLight, text_size = i_tblTextSz)
    table.cell(summaryTbl, 1, 2, str.tostring(acc_buyCnt),  text_color = cBuy,  bgcolor = bgLight, text_size = i_tblTextSz, text_halign = text.align_center)
    table.cell(summaryTbl, 2, 2, str.tostring(acc_sellCnt), text_color = cSell, bgcolor = bgLight, text_size = i_tblTextSz, text_halign = text.align_center)
    table.cell(summaryTbl, 3, 2, cluRatio,             text_color = cGray, bgcolor = bgLight, text_size = i_tblTextSz, text_halign = text.align_center)

    // -- Row 3: footprint volume ------------------------------------------------
    string bVolTxt  = fmtVol(acc_buyVol)  + " (" + str.tostring(math.round(buyShare,  1)) + "%)"
    string sVolTxt  = fmtVol(acc_sellVol) + " (" + str.tostring(math.round(sellShare, 1)) + "%)"
    table.cell(summaryTbl, 0, 3, "Cluster volume",    text_color = cGray, bgcolor = bgMid, text_size = i_tblTextSz)
    table.cell(summaryTbl, 1, 3, bVolTxt,         text_color = cBuy,  bgcolor = bgMid, text_size = i_tblTextSz, text_halign = text.align_center)
    table.cell(summaryTbl, 2, 3, sVolTxt,         text_color = cSell, bgcolor = bgMid, text_size = i_tblTextSz, text_halign = text.align_center)
    table.cell(summaryTbl, 3, 3, fmtVol(totFP),  text_color = cGray, bgcolor = bgMid, text_size = i_tblTextSz, text_halign = text.align_center)

    // -- Row 4: delta -----------------------------------------------------------
    string dPctTxt  = (deltaPct >= 0 ? "+" : "") + str.tostring(math.round(deltaPct, 1)) + "%"
    color  biasBg   = thIsDark ? color.new(bullish ? color.green : color.red, 45) : color.new(bullish ? #1B9E5A : #D23B3B, 65)
    string biasText = bullish ? "BULLISH" : "BEARISH"
    table.cell(summaryTbl, 0, 4, "Δ Cluster delta",    text_color = cGray, bgcolor = bgLight, text_size = i_tblTextSz)
    table.cell(summaryTbl, 1, 4, fmtVolSigned(acc_delta), text_color = bullish ? cBuy : cSell, bgcolor = bgLight, text_size = i_tblTextSz, text_halign = text.align_center)
    table.cell(summaryTbl, 2, 4, dPctTxt,                 text_color = bullish ? cBuy : cSell, bgcolor = bgLight, text_size = i_tblTextSz, text_halign = text.align_center)
    table.cell(summaryTbl, 3, 4, biasText,                text_color = cWhite,                 bgcolor = biasBg,  text_size = i_tblTextSz, text_halign = text.align_center)

    // -- Row 5: average/max delta and the anomaly counter ------------------------
    string statRight = str.tostring(totClu) + " clu." + (i_anomOn ? " · 🔥" + str.tostring(acc_anomCnt) + " anom." : "")
    table.cell(summaryTbl, 0, 5, "Avg / Max Δ clu.",   text_color = cGray,                          bgcolor = bgMid, text_size = i_tblTextSz)
    table.cell(summaryTbl, 1, 5, fmtVolSigned(avgDelta) + " / +" + fmtVol(acc_maxBuyDelta),  text_color = cBuy,  bgcolor = bgMid, text_size = i_tblTextSz, text_halign = text.align_center)
    table.cell(summaryTbl, 2, 5, "—" + fmtVol(acc_maxSellDelta),                             text_color = cSell, bgcolor = bgMid, text_size = i_tblTextSz, text_halign = text.align_center)
    table.cell(summaryTbl, 3, 5, statRight,                                                   text_color = cGray, bgcolor = bgMid, text_size = i_tblTextSz, text_halign = text.align_center)

    // -- Row 6: exchange section header ------------------------------------------
    table.cell(summaryTbl, 0, 6, "EXCHANGE",  text_color = cGray, bgcolor = bgDark, text_size = i_tblTextSz, text_halign = text.align_center)
    table.cell(summaryTbl, 1, 6, "Volume ∑",  text_color = cGray, bgcolor = bgDark, text_size = i_tblTextSz, text_halign = text.align_center)
    table.cell(summaryTbl, 2, 6, "Share",     text_color = cGray, bgcolor = bgDark, text_size = i_tblTextSz, text_halign = text.align_center)
    table.cell(summaryTbl, 3, 6, "Avg xavg",  text_color = cGray, bgcolor = bgDark, text_size = i_tblTextSz, text_halign = text.align_center)

    // -- Exchange rows (dynamic) --------------------------------------------------
    int exRow = 7

    if i_ex1_on
        float sh = sumExAcc > 0 ? acc_vol1 / sumExAcc * 100 : 0.0
        float xa = not na(avg1) and avg1 > 0 and acc_bars > 0 ? acc_vol1 / acc_bars / avg1 : 0.0
        table.cell(summaryTbl, 0, exRow, i_ex1_label,                                       text_color = exClr1,     bgcolor = bgLight, text_size = i_tblTextSz)
        table.cell(summaryTbl, 1, exRow, fmtVol(acc_vol1),                                  text_color = exClr1,     bgcolor = bgLight, text_size = i_tblTextSz, text_halign = text.align_center)
        table.cell(summaryTbl, 2, exRow, str.tostring(math.round(sh, 1)) + "%",              text_color = cGray,       bgcolor = bgLight, text_size = i_tblTextSz, text_halign = text.align_center)
        table.cell(summaryTbl, 3, exRow, "x" + str.tostring(math.round(xa, 2)),              text_color = cGray,       bgcolor = bgLight, text_size = i_tblTextSz, text_halign = text.align_center)
        exRow += 1

    if i_ex2_on
        float sh = sumExAcc > 0 ? acc_vol2 / sumExAcc * 100 : 0.0
        float xa = not na(avg2) and avg2 > 0 and acc_bars > 0 ? acc_vol2 / acc_bars / avg2 : 0.0
        table.cell(summaryTbl, 0, exRow, i_ex2_label,                                       text_color = exClr2,     bgcolor = bgLight, text_size = i_tblTextSz)
        table.cell(summaryTbl, 1, exRow, fmtVol(acc_vol2),                                  text_color = exClr2,     bgcolor = bgLight, text_size = i_tblTextSz, text_halign = text.align_center)
        table.cell(summaryTbl, 2, exRow, str.tostring(math.round(sh, 1)) + "%",              text_color = cGray,       bgcolor = bgLight, text_size = i_tblTextSz, text_halign = text.align_center)
        table.cell(summaryTbl, 3, exRow, "x" + str.tostring(math.round(xa, 2)),              text_color = cGray,       bgcolor = bgLight, text_size = i_tblTextSz, text_halign = text.align_center)
        exRow += 1

    if i_ex3_on
        float sh = sumExAcc > 0 ? acc_vol3 / sumExAcc * 100 : 0.0
        float xa = not na(avg3) and avg3 > 0 and acc_bars > 0 ? acc_vol3 / acc_bars / avg3 : 0.0
        table.cell(summaryTbl, 0, exRow, i_ex3_label,                                       text_color = exClr3,     bgcolor = bgLight, text_size = i_tblTextSz)
        table.cell(summaryTbl, 1, exRow, fmtVol(acc_vol3),                                  text_color = exClr3,     bgcolor = bgLight, text_size = i_tblTextSz, text_halign = text.align_center)
        table.cell(summaryTbl, 2, exRow, str.tostring(math.round(sh, 1)) + "%",              text_color = cGray,       bgcolor = bgLight, text_size = i_tblTextSz, text_halign = text.align_center)
        table.cell(summaryTbl, 3, exRow, "x" + str.tostring(math.round(xa, 2)),              text_color = cGray,       bgcolor = bgLight, text_size = i_tblTextSz, text_halign = text.align_center)
        exRow += 1

    if i_ex4_on
        float sh = sumExAcc > 0 ? acc_vol4 / sumExAcc * 100 : 0.0
        float xa = not na(avg4) and avg4 > 0 and acc_bars > 0 ? acc_vol4 / acc_bars / avg4 : 0.0
        table.cell(summaryTbl, 0, exRow, i_ex4_label,                                       text_color = exClr4,     bgcolor = bgLight, text_size = i_tblTextSz)
        table.cell(summaryTbl, 1, exRow, fmtVol(acc_vol4),                                  text_color = exClr4,     bgcolor = bgLight, text_size = i_tblTextSz, text_halign = text.align_center)
        table.cell(summaryTbl, 2, exRow, str.tostring(math.round(sh, 1)) + "%",              text_color = cGray,       bgcolor = bgLight, text_size = i_tblTextSz, text_halign = text.align_center)
        table.cell(summaryTbl, 3, exRow, "x" + str.tostring(math.round(xa, 2)),              text_color = cGray,       bgcolor = bgLight, text_size = i_tblTextSz, text_halign = text.align_center)
        exRow += 1

    if i_ex5_on
        float sh = sumExAcc > 0 ? acc_vol5 / sumExAcc * 100 : 0.0
        float xa = not na(avg5) and avg5 > 0 and acc_bars > 0 ? acc_vol5 / acc_bars / avg5 : 0.0
        table.cell(summaryTbl, 0, exRow, i_ex5_label,                                       text_color = exClr5,     bgcolor = bgLight, text_size = i_tblTextSz)
        table.cell(summaryTbl, 1, exRow, fmtVol(acc_vol5),                                  text_color = exClr5,     bgcolor = bgLight, text_size = i_tblTextSz, text_halign = text.align_center)
        table.cell(summaryTbl, 2, exRow, str.tostring(math.round(sh, 1)) + "%",              text_color = cGray,       bgcolor = bgLight, text_size = i_tblTextSz, text_halign = text.align_center)
        table.cell(summaryTbl, 3, exRow, "x" + str.tostring(math.round(xa, 2)),              text_color = cGray,       bgcolor = bgLight, text_size = i_tblTextSz, text_halign = text.align_center)
        exRow += 1

    // -- Exchange total -------------------------------------------------------------
    table.cell(summaryTbl, 0, exRow, "∑ Exchanges", text_color = cGray,  bgcolor = bgMid, text_size = i_tblTextSz)
    table.cell(summaryTbl, 1, exRow, fmtVol(sumExAcc), text_color = cWhite, bgcolor = bgMid, text_size = i_tblTextSz, text_halign = text.align_center)
    table.cell(summaryTbl, 2, exRow, "100%",        text_color = cGray,  bgcolor = bgMid, text_size = i_tblTextSz, text_halign = text.align_center)
    table.cell(summaryTbl, 3, exRow, "",             text_color = cGray,  bgcolor = bgMid, text_size = i_tblTextSz)
    exRow += 1

    // -- Period -----------------------------------------------------------------
    string pFrom = i_tableMode == "From date"
         ? str.format_time(i_fromDate,    "dd.MM.yyyy")
         : (acc_firstTime > 0 ? str.format_time(acc_firstTime, "dd.MM.yyyy") : "—")
    string pTo   = str.format_time(time, "dd.MM.yyyy")
    table.cell(summaryTbl, 0, exRow, "Period",                    text_color = cGray, bgcolor = bgDark, text_size = i_tblTextSz)
    table.cell(summaryTbl, 1, exRow, pFrom + " -> " + pTo,         text_color = cGray, bgcolor = bgDark, text_size = i_tblTextSz, text_halign = text.align_center)
    table.cell(summaryTbl, 2, exRow, str.tostring(acc_bars) + " bars",  text_color = cGray, bgcolor = bgDark, text_size = i_tblTextSz, text_halign = text.align_center)
    table.cell(summaryTbl, 3, exRow, "",                           text_color = cGray, bgcolor = bgDark, text_size = i_tblTextSz)

// ─── DATA WINDOW (DEBUG) ─────────────────────────────────────────────────────
plot(pocMid,   "POC",        color = color.orange, display = display.data_window)
plot(delta,    "Delta",      color = color.teal,   display = display.data_window)
plot(totalVol, "FP volume",  color = color.gray,   display = display.data_window)
plot(vol1,     "Vol exch. 1", color = color.yellow, display = display.data_window)
plot(vol2,     "Vol exch. 2", color = color.yellow, display = display.data_window)
plot(vol3,     "Vol exch. 3", color = color.yellow, display = display.data_window)
plot(vol4,     "Vol exch. 4", color = color.yellow, display = display.data_window)
plot(vol5,     "Vol exch. 5", color = color.yellow, display = display.data_window)
plot(sumExVol,      "∑ Exchanges",      color = color.aqua,    display = display.data_window)
plot(anomMetricVal, "Anomaly metric",   color = color.fuchsia, display = display.data_window)
plot(volBaseAll,    "Base (window)",    color = color.gray,    display = display.data_window)
plot(anomRatio,     "Excess x",         color = color.fuchsia, display = display.data_window)

// ─── ALERTS ──────────────────────────────────────────────────────────────────
alertcondition(isBuyCluster,  "Buy cluster",    "{{ticker}} {{interval}} | Buy cluster with exchange volumes")
alertcondition(isSellCluster, "Sell cluster",   "{{ticker}} {{interval}} | Sell cluster with exchange volumes")
alertcondition(isAnomaly,     "Volume anomaly", "{{ticker}} {{interval}} | 🔥 VOLUME ANOMALY: current volume far above the recent bars")
````
