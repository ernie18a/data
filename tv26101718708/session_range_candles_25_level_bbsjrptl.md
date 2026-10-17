# Session Range Candles + 25% Level

- url: https://www.tradingview.com/script/BBSJrpTl-Session-Range-Candles-25-Level/
- type: indicator
- pine_id: PUB;d7f968ddc3dc48debdca0c085073f9ac
- version: 2.0

## Description

# Session Range Candles + 25% Level (SRC25)

** Session Range Candles + 25% Level (SRC25)**, also known as The Essence Model, is a multi-session analysis tool for futures and forex traders who use an ICT-influenced or session-based framework. It consolidates the three primary trading sessions — Asia, London, and New York — into a single, clean overlay that surfaces the session structure, key price levels, and historical behavioural statistics without requiring you to switch timeframes or manually draw levels each day.

The indicator is built around one core idea: that understanding the relationship between how Asia and London sessions form relative to each other, and how New York then behaves within that context, gives you a repeatable, statistical basis for anticipating price delivery. Everything the indicator draws and measures flows from that relationship.

---

## How It Works — Core Concepts

### Session Candles

For each of the three sessions, the indicator builds a composite candlestick representing the full session range — open, high, low, and close — updated live as each session progresses. These session candles are displayed to the right of the current price in the chart's future space, positioned side by side so you can see all three sessions at a glance without cluttering the main chart.

Asia runs 18:00–02:00 ET. 
London runs 02:00–08:00 ET. 
New York runs 08:00–17:00 ET.

Each candle shows its body (semi-transparent fill), upper and lower wicks, and high/low price labels. The candles are monochrome — direction is read from body position (open vs close) rather than colour, keeping the display uncluttered.

**Candle display rules by session phase:**

During the **Asia session**, only the live Asia candle is shown. London and NY slots are empty — no stale prior-day candles carry over into a new cycle.

During the **London session**, the completed Asia candle is shown alongside the live London candle. The NY slot remains empty until NY opens.

During the **NY session**, all three candles are visible: the completed Asia, the completed London, and the live NY updating in real time.

**Between sessions** (after NY closes and before the next Asia opens), all three completed candles remain visible until the next Asia session starts the cycle fresh.

### The 25% Level

For each completed session candle, the indicator calculates a **25% level** based on the candle's body (the open-to-close range), direction-aware:

On a **bullish candle** (close ≥ open), the level sits in the upper quarter of the body — body top minus 25% of the body range. This marks the zone above which the candle is considered to have delivered into premium.

On a **bearish candle** (close < open), the level sits in the lower quarter of the body — body bottom plus 25% of the body range. This marks the zone below which the candle has delivered into discount.

The 25% level appears in two places. First, as a short horizontal tick extending rightward from the candle body in the session candle panel. Second, as a horizontal line drawn across the main price chart, running from the session's opening bar to the current bar, labelled with the session name and "25%".

The chart line is what traders interact with in real time. It shows where the 25% level sits relative to live price action. The stats table then quantifies — historically and filtered by today's regime — how NY tends to interact with that London 25% level, making it the primary reference for intraday entry context.

### Session H/M/L/O Lines

The indicator also draws up to four horizontal reference lines extending from the session's opening bar to the current bar: the session **High**, the session **Mid** (arithmetic midpoint of high and low), the session **Low**, and the session **Open**. Each is independently togglable and labelled at the right edge. These lines give you the most relevant reference prices from completed sessions without needing to draw them manually.

### Session Open Vertical Lines

At the exact bar where each session opens, a vertical line is drawn extending the full height of the chart, labelled with the session name. These act as visual dividers making session boundaries immediately clear.

---

## Session Structure (Regime)

The core analytical concept driving the statistics table is the structural relationship between Asia and London — specifically, how London's high and low relate to Asia's high and low. The indicator classifies each completed Asia→London pair into one of five regimes, compared wick-to-wick (full session highs and lows, not bodies):

**London Engulfs Asia** — London's high exceeded Asia's high AND London's low went below Asia's low. London expanded beyond Asia in both directions.

**Asia Engulfs London** — Asia's high was at or above London's high AND Asia's low was at or below London's low. London formed entirely within Asia's range.

**London Partial Up** — London's high exceeded Asia's high, but London's low held at or above Asia's low. London broke out to the upside only.

**London Partial Down** — London's low went below Asia's low, but London's high stayed at or below Asia's high. London broke out to the downside only.

**Inside** — London's range fell entirely within Asia's range without touching either extreme.

**Important:** the regime is only confirmed once London has fully closed (i.e. when NY opens). During the Asia and London sessions, the Structure row in the stats table displays "Pending (London open)" to prevent showing an incomplete or misleading classification. The regime shown in the table always refers to the completed Asia→London pair for the current trading day.

---

## Stats Table

The stats table is the indicator's most powerful feature. It answers the question: given today's Asia-London structure, how has New York historically behaved?

### How the History Is Built

Each time a full Asia→London→NY cycle completes — detected at the opening bar of the next Asia session — that cycle's data is committed to a historical array. The number of sessions retained is controlled by the Lookback input (default 252, approximately one trading year). Every percentage shown in the table is derived from this rolling history.

The stats loop filters the history to only those cycles where the Asia-London regime **matches today's current regime**, then calculates frequencies across that filtered subset.

### REGIME Section

**Structure** shows today's Asia-London regime classification, or "Pending (London open)" while London is still active.

**Occurrences** shows how many times this regime has appeared in the lookback window, displayed as N / total sessions analysed. This is your sample size indicator — treat regimes with fewer than 15–20 occurrences with caution.

**Asia Range (avg | cur)** shows the average Asia session range across all sessions in the lookback period, followed by today's Asia range in points.

**London Range (avg | cur)** shows the same for London — historical average versus today's current range in points.

### NY BEHAVIOUR Section

All percentages here are filtered to sessions where the Asia-London regime matches today's.

**NY Bullish** — the percentage of matching sessions where NY closed above its open.

**London High Taken** — the percentage where NY's high reached or exceeded London's session high.

**London Low Taken** — the percentage where NY's low reached or went below London's session low.

**Sequential H+L** — the percentage where NY took both London's high and London's low in the same session. A high reading here suggests NY tends to run both sides of the London range under this regime, implying choppier or more two-sided price action.

**NY Open Above Lon Mid** — the percentage where NY's opening price was above the London session midpoint. This can be read alongside NY Bullish to understand whether the open position tends to predict the close direction.

### Wick Interaction Rows

These rows adapt based on whether today's London session closed bullish or bearish, measuring how NY interacted with the London 25% level. The denominator for all wick rows is the number of bullish (or bearish) London sessions within the regime-matched set — not the total regime count.

**When London closed bullish:**

*NY Stays Above Lon 25%* — the percentage of bullish London sessions (within the regime) where NY's low never traded below the London 25% level. NY respected the upper quarter of the London body throughout the session.

*Wick < Lon 25% → Close Above* — NY wicked below the London 25% level at some point but ultimately closed above it. This is the classic liquidity sweep and recovery pattern — historically the most operationally useful row for identifying long entry context when NY trades into that zone.

*Wick < Lon 25% → Close Below* — NY wicked below the London 25% level and failed to recover. A high reading here would warn that trading below the 25% zone is a bearish continuation signal rather than a sweep.

*Wick < Lon Low → Close Above* — NY extended below London's full session low (a complete sweep of the London low) but closed back above it. A high reading here indicates the London low is frequently swept as a stop-hunt before NY recovers.

**When London closed bearish:**

*NY Stays Below Lon 25%* — NY's high never reached the London 25% level. The bearish delivery was uninterrupted.

*Wick > Lon 25% → Close Below* — NY wicked above the London 25% level but closed below it. The mirror of the bullish sweep pattern — potential short entry context when NY rallies into that zone.

*Wick > Lon 25% → Close Above* — NY wicked above the 25% level and failed to close below it. A high reading signals that moves above the 25% zone tend to hold, warning against fading rallies.

*Wick > Lon High → Close Below* — NY extended above London's full high but closed back below it. A high reading indicates the London high is frequently swept before NY resumes lower.

### TODAY Section

**London 25%** — whether the completed London session's close was above its open ("Above (bull)") or below its open ("Below (bear)"). This determines which set of wick interaction rows is shown.

**NY Open** — whether NY's opening price was above or below the London session midpoint. Updated once NY opens.

**London High** — whether NY has taken London's high yet ("Taken ✓") or not yet ("Pending"). Updates live during the NY session.

**London Low** — whether NY has taken London's low yet ("Taken ✓") or not yet ("Pending"). Updates live during the NY session.

---

## Interpreting the Stats Table

**Step 1 — Check the regime and sample size.** Once London closes, read the Structure row. Then check Occurrences. A regime appearing 40 or more times in 252 sessions gives you a meaningful base rate. Fewer than 15 occurrences is too thin to trade mechanically from.

**Step 2 — Read the directional bias.** NY Bullish gives you the baseline expectation for NY's close direction under this regime. Combine it with NY Open Above Lon Mid — if NY opens above the London midpoint AND NY Bullish is high, the probability of a bullish close is further supported by position. If they diverge, the session is more likely to be contested.

**Step 3 — Set the 25% level expectation.** This is the most operationally useful step. If London closed bullish, look at the three wick rows. A high "Wick < Lon 25% → Close Above" reading (e.g. 60%+) tells you that historically, when NY dips below that upper quarter of the London body, it tends to recover above it. This provides a framework for anticipating where NY might seek liquidity before continuing higher, and gives you a probabilistic basis for a long setup in that zone.

**Step 4 — Assess the London level take rates.** High London High Taken combined with low London Low Taken suggests NY tends to run to the upside of the London range. High Sequential H+L suggests NY routinely sweeps both extremes — in that case, plan for multiple liquidity events rather than a clean one-directional move.

**Step 5 — Track the TODAY section during NY.** Once NY is open, the London High and London Low rows tell you in real time whether the key liquidity levels have been swept. Cross-reference with the historical rates from the behaviour section to assess whether NY is behaving consistently with its historical pattern or deviating from it.

---

## Input Configuration

### Asia, London, and NY Sessions

Each session has an identical set of inputs configured independently:

**Show [Session] Candle** enables or disables the session candle in the right-side panel.

**Show Session Open Line** draws a vertical line at the moment the session opens. The line colour, style (Solid / Dashed / Dotted), and width are configurable. An optional label can be shown alongside the line, with size options of tiny, small, or normal.

**Show H/M/L/O Lines** enables the horizontal reference lines on the main chart. Each of the four levels — High, Mid, Low, and Open — has its own toggle so you can show only the levels relevant to your workflow. The line colour, style, and width are shared across the four levels for that session. Label size is also configurable.

**Show 25% Line on Chart** enables the horizontal 25% level line on the main chart. Colour, line style, width, and label size are independently configurable per session.

*Note: NY does not have H/M/L/O or 25% chart lines while the NY session is live — those lines only appear once NY has closed, so they do not interfere with reading the active session.*

### Session Candles (shared settings)

**Offset from chart (bars)** — how far to the right of the last price bar the candle panel begins. Increase this if the candles overlap with your price action or labels.

**Candle width (bars)** — the width of each session candle box measured in bar units. Adjust to taste based on your chart zoom level.

**Spacing between candles** — the gap between adjacent session candles in bar units.

**Body fill transparency** — controls how transparent the candle body fill is. 0 is fully opaque, 100 is invisible. Default 85 gives a subtle fill.

**Show wicks** — enables the upper and lower wick lines on each session candle.

**Show high/low labels** — shows price labels at the high and low of each session candle.

**Label size** — applies to the candle price labels (tiny / small / normal).

**Show 25% tick on candle** — draws a short horizontal tick at the 25% level extending rightward from the candle body in the panel.

### Stats Table

**Show Stats Table** — master toggle for the entire table.

**Lookback (sessions)** — the number of completed Asia→London→NY cycles to include in the historical analysis. Default is 252 (approximately one trading year). Minimum 10, maximum 2000. A longer lookback smooths out regime-specific anomalies but may include structural market conditions that are no longer relevant. A shorter lookback is more reactive but produces smaller sample sizes per regime.

**Table Position** — nine position options covering all corners and edge midpoints of the chart.

**Text Size** — Tiny, Small, or Normal. Small is the default and works well on most monitor sizes.

**Background** — background colour and transparency of the table panel.

**Text colour** — colour applied to all table text.

**Border** — colour of the table cell borders and outer frame.

---

## Chart Elements Summary

**Vertical lines** at each session open, labelled Asia, London, or NY — mark the session boundaries across the full chart height.

**Session candle panel** to the right of price — three side-by-side composite candles showing the OHLC of each session, with wicks, price labels, and 25% ticks.

**Horizontal lines on the main chart** — H/M/L/O and 25% lines from completed sessions, each starting from the session's opening bar and extending to the current bar, labelled at the right edge.

**Stats table** — historical frequency analysis conditioned on today's Asia-London regime, showing NY behavioural tendencies and live session tracking.

---

## Recommended Usage

**Timeframe:** The indicator is designed for intraday charts, typically 1-minute through 15-minute. Session detection is time-based, not candle-count-based, so it works correctly on any timeframe as long as your chart covers the relevant session hours.

**Instrument:** Originally developed for NQ (Nasdaq 100 E-mini Futures). Works on any instrument that trades during the defined session windows. All session times are referenced to the America/New_York timezone.

**Daily workflow:**

During Asia — observe the Asia candle building. The H/M/L/O lines begin plotting from the Asia open. Note the range size relative to the historical average shown in the table.

At the London open — Asia is now complete. The regime begins forming as London trades relative to the Asia range. Monitor London's progress.

At the NY open — London is complete. The regime is confirmed and the stats table populates with the full historical analysis. Read the NY Behaviour section to set your expectations for the session. Note whether NY opened above or below the London midpoint, and note the current London 25% level on the chart.

During NY — use the wick interaction rows to frame entries. Watch the London High and London Low rows in the TODAY section to track whether liquidity levels are being swept. Assess NY's behaviour against the historical tendencies for this regime.

---

## Notes and Limitations

**Sample size matters.** Regimes with fewer than 15–20 occurrences in your lookback window should be treated with caution. The percentages are directionally informative but not statistically robust at small sample sizes. Always read Occurrences before relying on the behaviour rows.

**The 25% level uses candle bodies, not wicks.** It measures where price closed relative to the open, not the full session range. This is intentional — body-based levels represent committed directional delivery, while wicked extremes may represent temporary liquidity events that the body then rejected.

**Regime is confirmed at NY open only.** Showing a regime mid-London-session would compare a developing candle against a completed Asia candle, producing classifications that can change as London continues. The "Pending (London open)" display is by design.

**History is built session by session.** If you add the indicator mid-session, the current incomplete session will not be committed to history until the next Asia open. All statistics reflect only fully completed Asia→London→NY cycles.

**The wick interaction row denominators are direction-matched, not regime-total.** The bullish wick rows divide by the count of bullish London sessions within the regime. The bearish wick rows divide by bearish London sessions. This means these rows cannot be compared directly against NY Bullish or the London take-rate rows, which use the full regime count as their denominator.

## Source Code

````pine
//@version=5
indicator("Session Range Candles + 25% Level", "SRC25", true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════════
// INPUT GROUPS
// ═══════════════════════════════════════════════════════════════════

var g_ASIA   = "════════════ Asia Session ════════════"
var g_LON    = "══════════ London Session ══════════"
var g_NY     = "════════════ NY Session ════════════"
var g_CANDLE = "═══════════ Session Candles ═══════════"
var g_25     = "══════════════ 25% Level ══════════════"
var g_HML    = "═══════════ H/M/L/O Lines ═══════════"
var g_STATS  = "══════════════ Stats Table ══════════════"

// ═══════════════════════════════════════════════════════════════════
// INPUTS — ASIA
// ═══════════════════════════════════════════════════════════════════

asia_start        = input.string("1800", "Session Start (HHMM)",
     tooltip="24-hour time in New York timezone, e.g. 1800 = 6:00 PM",
                                                                      group=g_ASIA)
asia_end          = input.string("0200", "Session End   (HHMM)",
     tooltip="24-hour time in New York timezone, e.g. 0200 = 2:00 AM",
                                                                      group=g_ASIA)
asia_enabled      = input.bool(true,    "Show Asia Candle",           group=g_ASIA)
asia_vline_show   = input.bool(true,    "Show Session Open Line",     group=g_ASIA)
asia_vline_col    = input.color(color.new(color.black, 70), "  Line Colour", group=g_ASIA)
asia_vline_style  = input.string("Solid", "  Line Style",
     options=["Solid","Dashed","Dotted"],                             group=g_ASIA)
asia_vline_width  = input.int(1, "  Line Width", minval=1, maxval=4,  group=g_ASIA)
asia_vlabel_show  = input.bool(true,    "  Show Label",               group=g_ASIA)
asia_vlabel_size  = input.string("tiny", "  Label Size",
     options=["tiny","small","normal"],                               group=g_ASIA)
asia_hml_show     = input.bool(true,    "Show H/M/L/O Lines",         group=g_ASIA)
asia_hml_high     = input.bool(true,    "  High",                     group=g_ASIA)
asia_hml_mid      = input.bool(true,    "  Mid",                      group=g_ASIA)
asia_hml_low      = input.bool(true,    "  Low",                      group=g_ASIA)
asia_hml_open     = input.bool(true,    "  Open",                     group=g_ASIA)
asia_hml_col      = input.color(color.new(color.gray, 30), "  Line Colour", group=g_ASIA)
asia_hml_style    = input.string("Dotted", "  Line Style",
     options=["Solid","Dashed","Dotted"],                             group=g_ASIA)
asia_hml_width    = input.int(1, "  Line Width", minval=1, maxval=4,  group=g_ASIA)
asia_hml_lbl_size = input.string("tiny", "  Label Size",
     options=["tiny","small","normal"],                               group=g_ASIA)
asia_25_show      = input.bool(true,    "Show 25% Line on Chart",     group=g_ASIA)
asia_25_col       = input.color(color.blue, "  25% Colour",           group=g_ASIA)
asia_25_style     = input.string("Solid", "  25% Style",
     options=["Solid","Dashed","Dotted"],                             group=g_ASIA)
asia_25_width     = input.int(1, "  25% Width", minval=1, maxval=4,   group=g_ASIA)
asia_25_lbl_size  = input.string("tiny", "  25% Label Size",
     options=["tiny","small","normal"],                               group=g_ASIA)

// ═══════════════════════════════════════════════════════════════════
// INPUTS — LONDON
// ═══════════════════════════════════════════════════════════════════

lon_start        = input.string("0200", "Session Start (HHMM)",
     tooltip="24-hour time in New York timezone, e.g. 0200 = 2:00 AM",
                                                                      group=g_LON)
lon_end          = input.string("0800", "Session End   (HHMM)",
     tooltip="24-hour time in New York timezone, e.g. 0800 = 8:00 AM",
                                                                      group=g_LON)
lon_enabled      = input.bool(true,    "Show London Candle",          group=g_LON)
lon_vline_show   = input.bool(true,    "Show Session Open Line",      group=g_LON)
lon_vline_col    = input.color(color.new(color.black, 70), "  Line Colour", group=g_LON)
lon_vline_style  = input.string("Solid", "  Line Style",
     options=["Solid","Dashed","Dotted"],                             group=g_LON)
lon_vline_width  = input.int(1, "  Line Width", minval=1, maxval=4,   group=g_LON)
lon_vlabel_show  = input.bool(true,    "  Show Label",                group=g_LON)
lon_vlabel_size  = input.string("tiny", "  Label Size",
     options=["tiny","small","normal"],                               group=g_LON)
lon_hml_show     = input.bool(true,    "Show H/M/L/O Lines",          group=g_LON)
lon_hml_high     = input.bool(true,    "  High",                      group=g_LON)
lon_hml_mid      = input.bool(true,    "  Mid",                       group=g_LON)
lon_hml_low      = input.bool(true,    "  Low",                       group=g_LON)
lon_hml_open     = input.bool(true,    "  Open",                      group=g_LON)
lon_hml_col      = input.color(color.new(color.gray, 30), "  Line Colour", group=g_LON)
lon_hml_style    = input.string("Dotted", "  Line Style",
     options=["Solid","Dashed","Dotted"],                             group=g_LON)
lon_hml_width    = input.int(1, "  Line Width", minval=1, maxval=4,   group=g_LON)
lon_hml_lbl_size = input.string("tiny", "  Label Size",
     options=["tiny","small","normal"],                               group=g_LON)
lon_25_show      = input.bool(true,    "Show 25% Line on Chart",      group=g_LON)
lon_25_col       = input.color(color.blue, "  25% Colour",            group=g_LON)
lon_25_style     = input.string("Solid", "  25% Style",
     options=["Solid","Dashed","Dotted"],                             group=g_LON)
lon_25_width     = input.int(1, "  25% Width", minval=1, maxval=4,    group=g_LON)
lon_25_lbl_size  = input.string("tiny", "  25% Label Size",
     options=["tiny","small","normal"],                               group=g_LON)

// ═══════════════════════════════════════════════════════════════════
// INPUTS — NY
// ═══════════════════════════════════════════════════════════════════

ny_start        = input.string("0800", "Session Start (HHMM)",
     tooltip="24-hour time in New York timezone, e.g. 0800 = 8:00 AM",
                                                                      group=g_NY)
ny_end          = input.string("1700", "Session End   (HHMM)",
     tooltip="24-hour time in New York timezone, e.g. 1700 = 5:00 PM",
                                                                      group=g_NY)
ny_enabled      = input.bool(true,    "Show NY Candle",               group=g_NY)
ny_vline_show   = input.bool(true,    "Show Session Open Line",       group=g_NY)
ny_vline_col    = input.color(color.new(color.black, 70), "  Line Colour", group=g_NY)
ny_vline_style  = input.string("Solid", "  Line Style",
     options=["Solid","Dashed","Dotted"],                             group=g_NY)
ny_vline_width  = input.int(1, "  Line Width", minval=1, maxval=4,    group=g_NY)
ny_vlabel_show  = input.bool(true,    "  Show Label",                 group=g_NY)
ny_vlabel_size  = input.string("tiny", "  Label Size",
     options=["tiny","small","normal"],                               group=g_NY)

// ═══════════════════════════════════════════════════════════════════
// INPUTS — SESSION CANDLES (shared candle appearance)
// ═══════════════════════════════════════════════════════════════════

candle_offset  = input.int(15,  "Offset from chart (bars)", minval=1,            group=g_CANDLE)
candle_width   = input.int(4,  "Candle width (bars)",      minval=1, maxval=20,  group=g_CANDLE)
candle_spacing = input.int(4,  "Spacing between candles",  minval=1, maxval=10,  group=g_CANDLE)
body_transp    = input.int(85, "Body fill transparency",   minval=0, maxval=100, group=g_CANDLE)
show_wick      = input.bool(true,    "Show wicks",                               group=g_CANDLE)
show_hl_labels = input.bool(true,    "Show high/low labels",                     group=g_CANDLE)
lbl_size_inp   = input.string("tiny", "Label size",
     options=["tiny","small","normal"],                                           group=g_CANDLE)
show_25_candle = input.bool(true,    "Show 25% tick on candle",                  group=g_CANDLE)

// ═══════════════════════════════════════════════════════════════════
// INPUTS — STATS TABLE
// ═══════════════════════════════════════════════════════════════════

show_stats     = input.bool(true, "Show Stats Table", group=g_STATS)
stats_lookback = input.int(252, "Lookback (sessions)", minval=10, maxval=2000,   group=g_STATS)
stats_pos      = input.string("Bottom Right", "Table Position",
     options=["Top Left","Top Center","Top Right",
              "Middle Left","Middle Center","Middle Right",
              "Bottom Left","Bottom Center","Bottom Right"],                      group=g_STATS)
stats_txt_size = input.string("Small", "Text Size",
     options=["Tiny","Small","Normal"],                                           group=g_STATS)
stats_bg       = input.color(color.new(color.white, 10), "Background",           group=g_STATS)
stats_txt_col  = input.color(color.black, "Text colour",                         group=g_STATS)
stats_bdr_col  = input.color(color.black, "Border",                              group=g_STATS)

// ── Fixed candle colour (monochrome) ──
col_candle = color.black

// ═══════════════════════════════════════════════════════════════════
// SESSION TIME STRING BUILDER
// ═══════════════════════════════════════════════════════════════════

// Pads a 1–4 digit HHMM string to exactly 4 digits, e.g. "200" → "0200"
f_pad4(s) =>
    n = str.length(s)
    n == 1 ? "000" + s :
     n == 2 ? "00"  + s :
     n == 3 ? "0"   + s : s

// Builds a "HHMM-HHMM" session string from two HHMM strings
f_sess(start_str, end_str) =>
    f_pad4(start_str) + "-" + f_pad4(end_str)

asia_sess_str = f_sess(asia_start, asia_end)
lon_sess_str  = f_sess(lon_start,  lon_end)
ny_sess_str   = f_sess(ny_start,   ny_end)

// ═══════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════

tz = "America/New_York"

f_lstyle(s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        =>          line.style_solid

f_lsize(s) =>
    switch s
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        =>          size.tiny

// ═══════════════════════════════════════════════════════════════════
// SESSION TIME DETECTION  (now uses dynamic strings)
// ═══════════════════════════════════════════════════════════════════

tf        = timeframe.period
is_asia   = math.sign(nz(time(tf, asia_sess_str, tz)))
is_london = math.sign(nz(time(tf, lon_sess_str,  tz)))
is_ny     = math.sign(nz(time(tf, ny_sess_str,   tz)))

// ═══════════════════════════════════════════════════════════════════
// SESSION OHLC TRACKING (live)
// ═══════════════════════════════════════════════════════════════════

var float asia_o    = na
var float asia_h    = na
var float asia_l    = na
var float asia_c    = na
var int   asia_sbar = na

var float lon_o    = na
var float lon_h    = na
var float lon_l    = na
var float lon_c    = na
var int   lon_sbar = na

var float ny_o    = na
var float ny_h    = na
var float ny_l    = na
var float ny_c    = na
var int   ny_sbar = na

if is_asia > is_asia[1]
    asia_o    := open
    asia_h    := high
    asia_l    := low
    asia_c    := close
    asia_sbar := bar_index
else if is_asia
    asia_h := math.max(asia_h, high)
    asia_l := math.min(asia_l, low)
    asia_c := close

if is_london > is_london[1]
    lon_o    := open
    lon_h    := high
    lon_l    := low
    lon_c    := close
    lon_sbar := bar_index
else if is_london
    lon_h := math.max(lon_h, high)
    lon_l := math.min(lon_l, low)
    lon_c := close

if is_ny > is_ny[1]
    ny_o    := open
    ny_h    := high
    ny_l    := low
    ny_c    := close
    ny_sbar := bar_index
else if is_ny
    ny_h := math.max(ny_h, high)
    ny_l := math.min(ny_l, low)
    ny_c := close

// ═══════════════════════════════════════════════════════════════════
// COMPLETED SESSION SNAPSHOTS
// ═══════════════════════════════════════════════════════════════════

var float p_ao  = na
var float p_ah  = na
var float p_al  = na
var float p_ac  = na
var int   p_asb = na

var float p_lo  = na
var float p_lh  = na
var float p_ll  = na
var float p_lc  = na
var int   p_lsb = na

var float p_no  = na
var float p_nh  = na
var float p_nl  = na
var float p_nc  = na
var int   p_nsb = na

var float reg_ah = na
var float reg_al = na
var float reg_lh = na
var float reg_ll = na

var float pending_ah = na
var float pending_al = na

if is_london > is_london[1] and not na(asia_o)
    p_ao  := asia_o
    p_ah  := asia_h
    p_al  := asia_l
    p_ac  := asia_c
    p_asb := asia_sbar

    pending_ah := asia_h
    pending_al := asia_l

if is_ny > is_ny[1] and not na(lon_o)
    p_lo  := lon_o
    p_lh  := lon_h
    p_ll  := lon_l
    p_lc  := lon_c
    p_lsb := lon_sbar

    if not na(pending_ah)
        reg_ah := pending_ah
        reg_al := pending_al
        reg_lh := lon_h
        reg_ll := lon_l

// Commit NY snapshot at NY close
if is_ny[1] > 0 and is_ny == 0 and not na(ny_o)
    p_no  := ny_o
    p_nh  := ny_h
    p_nl  := ny_l
    p_nc  := ny_c
    p_nsb := ny_sbar

// Update NY snapshot at next Asia open and London display until the new NY session opens.
if is_asia > is_asia[1] and not na(p_ao) and not na(p_lo) and not na(p_no)
    p_no  := ny_o
    p_nh  := ny_h
    p_nl  := ny_l
    p_nc  := ny_c
    p_nsb := ny_sbar

// ═══════════════════════════════════════════════════════════════════
// DRAWING HANDLES
// ═══════════════════════════════════════════════════════════════════

var box   bx_a    = na
var line  wk_a_up = na
var line  wk_a_dn = na
var label lbh_a   = na
var label lbl_a   = na
var label lbn_a   = na
var line  l25c_a  = na
var label lb25c_a = na
var line  l25p_a  = na
var label lb25p_a = na
var line  lH_a    = na
var line  lM_a    = na
var line  lL_a    = na
var line  lO_a    = na
var label lbH_a   = na
var label lbM_a   = na
var label lbL_a   = na
var label lbO_a   = na

var box   bx_l    = na
var line  wk_l_up = na
var line  wk_l_dn = na
var label lbh_l   = na
var label lbl_l   = na
var label lbn_l   = na
var line  l25c_l  = na
var label lb25c_l = na
var line  l25p_l  = na
var label lb25p_l = na
var line  lH_l    = na
var line  lM_l    = na
var line  lL_l    = na
var line  lO_l    = na
var label lbH_l   = na
var label lbM_l   = na
var label lbL_l   = na
var label lbO_l   = na

var box   bx_n    = na
var line  wk_n_up = na
var line  wk_n_dn = na
var label lbh_n   = na
var label lbl_n   = na
var label lbn_n   = na
var line  l25c_n  = na
var label lb25c_n = na
var line  l25p_n  = na
var label lb25p_n = na
var line  lH_n    = na
var line  lM_n    = na
var line  lL_n    = na
var line  lO_n    = na
var label lbH_n   = na
var label lbM_n   = na
var label lbL_n   = na
var label lbO_n   = na

// ═══════════════════════════════════════════════════════════════════
// MAIN DRAW FUNCTION
// ═══════════════════════════════════════════════════════════════════

f_draw(o, h, l, c, sbar,
       x1, x2, lbl_x,
       bx, wk_up, wk_dn, lbh, lbll, lbn,
       l25c, lb25c, l25p, lb25p,
       lH, lM, lL, lO, lbH, lbM, lbL, lbO,
       enabled, sess_name,
       do_25_chart, col_25, style_25, width_25, lbl_size_25,
       do_hml, show_high, show_mid, show_low, show_open,
       col_hml, style_hml, width_hml, lbl_size_hml) =>

    box.delete(bx)
    line.delete(wk_up)
    line.delete(wk_dn)
    label.delete(lbh)
    label.delete(lbll)
    label.delete(lbn)
    line.delete(l25c)
    label.delete(lb25c)
    line.delete(l25p)
    label.delete(lb25p)
    line.delete(lH)
    line.delete(lM)
    line.delete(lL)
    line.delete(lO)
    label.delete(lbH)
    label.delete(lbM)
    label.delete(lbL)
    label.delete(lbO)

    new_bx    = box(na)
    new_wk_up = line(na)
    new_wk_dn = line(na)
    new_lbh   = label(na)
    new_lbll  = label(na)
    new_lbn   = label(na)
    new_l25c  = line(na)
    new_lb25c = label(na)
    new_l25p  = line(na)
    new_lb25p = label(na)
    new_lH    = line(na)
    new_lM    = line(na)
    new_lL    = line(na)
    new_lO    = line(na)
    new_lbH   = label(na)
    new_lbM   = label(na)
    new_lbL   = label(na)
    new_lbO   = label(na)

    if enabled and not na(o)
        body_top   = math.max(o, c)
        body_bot   = math.min(o, c)
        body_range = body_top - body_bot
        is_bull    = c >= o
        xmid       = math.round((x1 + x2) / 2)
        lsz        = f_lsize(lbl_size_inp)
        cur        = bar_index

        new_bx :=
             box.new(x1, body_top, x2, body_bot,
                     bgcolor      = color.new(col_candle, body_transp),
                     border_color = col_candle,
                     border_width = 1,
                     xloc         = xloc.bar_index)

        if show_wick
            if h > body_top
                new_wk_up :=
                     line.new(xmid, body_top, xmid, h,
                              color=col_candle, width=1, xloc=xloc.bar_index)
            if l < body_bot
                new_wk_dn :=
                     line.new(xmid, body_bot, xmid, l,
                              color=col_candle, width=1, xloc=xloc.bar_index)

        if show_hl_labels
            new_lbh :=
                 label.new(xmid, h, str.tostring(math.round(h, 2)),
                           xloc             = xloc.bar_index,
                           style            = label.style_none,
                           textcolor        = col_candle,
                           size             = lsz,
                           textalign        = text.align_center,
                           text_font_family = font.family_monospace)
            new_lbll :=
                 label.new(xmid, l, str.tostring(math.round(l, 2)),
                           xloc             = xloc.bar_index,
                           style            = label.style_none,
                           textcolor        = col_candle,
                           size             = lsz,
                           textalign        = text.align_center,
                           text_font_family = font.family_monospace)

        new_lbn :=
             label.new(xmid, h, sess_name,
                       xloc             = xloc.bar_index,
                       style            = label.style_label_down,
                       color            = color.new(col_candle, 90),
                       textcolor        = col_candle,
                       size             = lsz,
                       text_font_family = font.family_monospace)

        if body_range > 0
            level_25 =
                 is_bull ? body_top - body_range * 0.25
                         : body_bot + body_range * 0.25
            ls25 = f_lstyle(style_25)

            if show_25_candle and do_25_chart
                tick_end = x2 + candle_spacing
                new_l25c :=
                     line.new(x2, level_25, tick_end, level_25,
                              color=col_25, style=ls25, width=width_25,
                              xloc=xloc.bar_index)
                new_lb25c :=
                     label.new(tick_end + 1, level_25, "25%",
                               xloc             = xloc.bar_index,
                               style            = label.style_none,
                               textcolor        = col_25,
                               size             = f_lsize(lbl_size_25),
                               textalign        = text.align_left,
                               text_font_family = font.family_monospace)

            if do_25_chart and not na(sbar)
                new_l25p :=
                     line.new(sbar, level_25, cur, level_25,
                              color=col_25, style=ls25, width=width_25,
                              xloc=xloc.bar_index)
                new_lb25p :=
                     label.new(lbl_x, level_25, sess_name + " 25%",
                               xloc             = xloc.bar_index,
                               style            = label.style_none,
                               textcolor        = col_25,
                               size             = f_lsize(lbl_size_25),
                               textalign        = text.align_left,
                               text_font_family = font.family_monospace)

        if do_hml and not na(sbar)
            mid     = (h + l) / 2
            ls_hml  = f_lstyle(style_hml)
            lsz_hml = f_lsize(lbl_size_hml)

            if show_high
                new_lH :=
                     line.new(sbar, h, cur, h,
                              color=col_hml, style=ls_hml, width=width_hml,
                              xloc=xloc.bar_index)
                new_lbH :=
                     label.new(lbl_x, h, sess_name + " High",
                               xloc             = xloc.bar_index,
                               style            = label.style_none,
                               textcolor        = col_hml,
                               size             = lsz_hml,
                               textalign        = text.align_left,
                               text_font_family = font.family_monospace)

            if show_mid
                new_lM :=
                     line.new(sbar, mid, cur, mid,
                              color=col_hml, style=ls_hml, width=width_hml,
                              xloc=xloc.bar_index)
                new_lbM :=
                     label.new(lbl_x, mid, sess_name + " Mid",
                               xloc             = xloc.bar_index,
                               style            = label.style_none,
                               textcolor        = col_hml,
                               size             = lsz_hml,
                               textalign        = text.align_left,
                               text_font_family = font.family_monospace)

            if show_low
                new_lL :=
                     line.new(sbar, l, cur, l,
                              color=col_hml, style=ls_hml, width=width_hml,
                              xloc=xloc.bar_index)
                new_lbL :=
                     label.new(lbl_x, l, sess_name + " Low",
                               xloc             = xloc.bar_index,
                               style            = label.style_none,
                               textcolor        = col_hml,
                               size             = lsz_hml,
                               textalign        = text.align_left,
                               text_font_family = font.family_monospace)

            if show_open
                new_lO :=
                     line.new(sbar, o, cur, o,
                              color=col_hml, style=ls_hml, width=width_hml,
                              xloc=xloc.bar_index)
                new_lbO :=
                     label.new(lbl_x, o, sess_name + " Open",
                               xloc             = xloc.bar_index,
                               style            = label.style_none,
                               textcolor        = col_hml,
                               size             = lsz_hml,
                               textalign        = text.align_left,
                               text_font_family = font.family_monospace)

    [new_bx, new_wk_up, new_wk_dn, new_lbh, new_lbll, new_lbn,
     new_l25c, new_lb25c, new_l25p, new_lb25p,
     new_lH, new_lM, new_lL, new_lO, new_lbH, new_lbM, new_lbL, new_lbO]

// ═══════════════════════════════════════════════════════════════════
// SESSION OPEN VERTICAL LINES
// ═══════════════════════════════════════════════════════════════════

if is_asia > is_asia[1] and asia_vline_show
    line.new(bar_index, high, bar_index, low,
             color  = asia_vline_col,
             style  = f_lstyle(asia_vline_style),
             width  = asia_vline_width,
             extend = extend.both,
             xloc   = xloc.bar_index)
    if asia_vlabel_show
        label.new(bar_index, high, "Asia",
                  xloc             = xloc.bar_index,
                  style            = label.style_label_down,
                  color            = asia_vline_col,
                  textcolor        = color.black,
                  size             = f_lsize(asia_vlabel_size),
                  text_font_family = font.family_monospace)

if is_london > is_london[1] and lon_vline_show
    line.new(bar_index, high, bar_index, low,
             color  = lon_vline_col,
             style  = f_lstyle(lon_vline_style),
             width  = lon_vline_width,
             extend = extend.both,
             xloc   = xloc.bar_index)
    if lon_vlabel_show
        label.new(bar_index, high, "London",
                  xloc             = xloc.bar_index,
                  style            = label.style_label_down,
                  color            = lon_vline_col,
                  textcolor        = color.black,
                  size             = f_lsize(lon_vlabel_size),
                  text_font_family = font.family_monospace)

if is_ny > is_ny[1] and ny_vline_show
    line.new(bar_index, high, bar_index, low,
             color  = ny_vline_col,
             style  = f_lstyle(ny_vline_style),
             width  = ny_vline_width,
             extend = extend.both,
             xloc   = xloc.bar_index)
    if ny_vlabel_show
        label.new(bar_index, high, "NY",
                  xloc             = xloc.bar_index,
                  style            = label.style_label_down,
                  color            = ny_vline_col,
                  textcolor        = color.black,
                  size             = f_lsize(ny_vlabel_size),
                  text_font_family = font.family_monospace)

// ═══════════════════════════════════════════════════════════════════
// MAIN — redraw every realtime bar and on the last historical bar
// ═══════════════════════════════════════════════════════════════════

if barstate.islast or barstate.isrealtime

    a_x1 = bar_index + candle_offset
    a_x2 = a_x1 + candle_width
    l_x1 = a_x2 + candle_spacing
    l_x2 = l_x1 + candle_width
    n_x1 = l_x2 + candle_spacing
    n_x2 = n_x1 + candle_width

    use_a = (is_asia   > 0) and not na(asia_o)
    use_l = (is_london > 0) and not na(lon_o)
    use_n = (is_ny     > 0) and not na(ny_o)

    show_l_candle = use_l or (is_ny > 0) or (is_ny[1] > 0 and is_ny == 0)
    show_n_candle = use_n or (is_ny[1] > 0 and is_ny == 0)

    ao  = use_a ? asia_o    : p_ao
    ah  = use_a ? asia_h    : p_ah
    al  = use_a ? asia_l    : p_al
    ac  = use_a ? asia_c    : p_ac
    asb = use_a ? asia_sbar : p_asb

    lo  = show_l_candle ? (use_l ? lon_o    : p_lo)  : na
    lh  = show_l_candle ? (use_l ? lon_h    : p_lh)  : na
    ll  = show_l_candle ? (use_l ? lon_l    : p_ll)  : na
    lc  = show_l_candle ? (use_l ? lon_c    : p_lc)  : na
    lsb = show_l_candle ? (use_l ? lon_sbar : p_lsb) : na

    no  = show_n_candle ? (use_n ? ny_o    : p_no)  : na
    nh  = show_n_candle ? (use_n ? ny_h    : p_nh)  : na
    nl  = show_n_candle ? (use_n ? ny_l    : p_nl)  : na
    nc  = show_n_candle ? (use_n ? ny_c    : p_nc)  : na
    nsb = show_n_candle ? (use_n ? ny_sbar : p_nsb) : na

    chart_lbl_x = bar_index

    draw_25_n = asia_25_show and not use_n
    draw_hml_n = not use_n

    [r_bx_a, r_wu_a, r_wd_a, r_lbh_a, r_lbl_a, r_lbn_a,
     r_l25c_a, r_lb25c_a, r_l25p_a, r_lb25p_a,
     r_lH_a, r_lM_a, r_lL_a, r_lO_a, r_lbH_a, r_lbM_a, r_lbL_a, r_lbO_a] =
         f_draw(ao, ah, al, ac, asb,
                 a_x1, a_x2, chart_lbl_x,
                 bx_a, wk_a_up, wk_a_dn, lbh_a, lbl_a, lbn_a,
                 l25c_a, lb25c_a, l25p_a, lb25p_a,
                 lH_a, lM_a, lL_a, lO_a, lbH_a, lbM_a, lbL_a, lbO_a,
                 asia_enabled, "Asia",
                 asia_25_show, asia_25_col, asia_25_style, asia_25_width, asia_25_lbl_size,
                 asia_hml_show, asia_hml_high, asia_hml_mid, asia_hml_low, asia_hml_open,
                 asia_hml_col, asia_hml_style, asia_hml_width, asia_hml_lbl_size)
    bx_a    := r_bx_a
    wk_a_up := r_wu_a
    wk_a_dn := r_wd_a
    lbh_a   := r_lbh_a
    lbl_a   := r_lbl_a
    lbn_a   := r_lbn_a
    l25c_a  := r_l25c_a
    lb25c_a := r_lb25c_a
    l25p_a  := r_l25p_a
    lb25p_a := r_lb25p_a
    lH_a    := r_lH_a
    lM_a    := r_lM_a
    lL_a    := r_lL_a
    lO_a    := r_lO_a
    lbH_a   := r_lbH_a
    lbM_a   := r_lbM_a
    lbL_a   := r_lbL_a
    lbO_a   := r_lbO_a

    [r_bx_l, r_wu_l, r_wd_l, r_lbh_l, r_lbl_l, r_lbn_l,
     r_l25c_l, r_lb25c_l, r_l25p_l, r_lb25p_l,
     r_lH_l, r_lM_l, r_lL_l, r_lO_l, r_lbH_l, r_lbM_l, r_lbL_l, r_lbO_l] =
         f_draw(lo, lh, ll, lc, lsb,
                 l_x1, l_x2, chart_lbl_x,
                 bx_l, wk_l_up, wk_l_dn, lbh_l, lbl_l, lbn_l,
                 l25c_l, lb25c_l, l25p_l, lb25p_l,
                 lH_l, lM_l, lL_l, lO_l, lbH_l, lbM_l, lbL_l, lbO_l,
                 lon_enabled, "London",
                 lon_25_show, lon_25_col, lon_25_style, lon_25_width, lon_25_lbl_size,
                 lon_hml_show, lon_hml_high, lon_hml_mid, lon_hml_low, lon_hml_open,
                 lon_hml_col, lon_hml_style, lon_hml_width, lon_hml_lbl_size)
    bx_l    := r_bx_l
    wk_l_up := r_wu_l
    wk_l_dn := r_wd_l
    lbh_l   := r_lbh_l
    lbl_l   := r_lbl_l
    lbn_l   := r_lbn_l
    l25c_l  := r_l25c_l
    lb25c_l := r_lb25c_l
    l25p_l  := r_l25p_l
    lb25p_l := r_lb25p_l
    lH_l    := r_lH_l
    lM_l    := r_lM_l
    lL_l    := r_lL_l
    lO_l    := r_lO_l
    lbH_l   := r_lbH_l
    lbM_l   := r_lbM_l
    lbL_l   := r_lbL_l
    lbO_l   := r_lbO_l

    [r_bx_n, r_wu_n, r_wd_n, r_lbh_n, r_lbl_n, r_lbn_n,
     r_l25c_n, r_lb25c_n, r_l25p_n, r_lb25p_n,
     r_lH_n, r_lM_n, r_lL_n, r_lO_n, r_lbH_n, r_lbM_n, r_lbL_n, r_lbO_n] =
         f_draw(no, nh, nl, nc, nsb,
                 n_x1, n_x2, chart_lbl_x,
                 bx_n, wk_n_up, wk_n_dn, lbh_n, lbl_n, lbn_n,
                 l25c_n, lb25c_n, l25p_n, lb25p_n,
                 lH_n, lM_n, lL_n, lO_n, lbH_n, lbM_n, lbL_n, lbO_n,
                 ny_enabled, "NY",
                 draw_25_n, lon_25_col, lon_25_style, lon_25_width, lon_25_lbl_size,
                 draw_hml_n, lon_hml_high, lon_hml_mid, lon_hml_low, lon_hml_open,
                 lon_hml_col, lon_hml_style, lon_hml_width, lon_hml_lbl_size)
    bx_n    := r_bx_n
    wk_n_up := r_wu_n
    wk_n_dn := r_wd_n
    lbh_n   := r_lbh_n
    lbl_n   := r_lbl_n
    lbn_n   := r_lbn_n
    l25c_n  := r_l25c_n
    lb25c_n := r_lb25c_n
    l25p_n  := r_l25p_n
    lb25p_n := r_lb25p_n
    lH_n    := r_lH_n
    lM_n    := r_lM_n
    lL_n    := r_lL_n
    lO_n    := r_lO_n
    lbH_n   := r_lbH_n
    lbM_n   := r_lbM_n
    lbL_n   := r_lbL_n
    lbO_n   := r_lbO_n

// ═══════════════════════════════════════════════════════════════════
// STATS — HISTORY ARRAYS
// ═══════════════════════════════════════════════════════════════════

var array<float> h_ah = array.new<float>()
var array<float> h_al = array.new<float>()
var array<float> h_lh = array.new<float>()
var array<float> h_ll = array.new<float>()
var array<float> h_lo = array.new<float>()
var array<float> h_lc = array.new<float>()
var array<float> h_nh = array.new<float>()
var array<float> h_nl = array.new<float>()
var array<float> h_no = array.new<float>()
var array<float> h_nc = array.new<float>()

if is_asia > is_asia[1] and not na(p_ao) and not na(p_lo) and not na(p_no)
    array.push(h_ah, p_ah)
    array.push(h_al, p_al)
    array.push(h_lh, p_lh)
    array.push(h_ll, p_ll)
    array.push(h_lo, p_lo)
    array.push(h_lc, p_lc)
    array.push(h_nh, p_nh)
    array.push(h_nl, p_nl)
    array.push(h_no, p_no)
    array.push(h_nc, p_nc)

// ═══════════════════════════════════════════════════════════════════
// STATS — HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════

f_regime(ah, al, lh, ll) =>
    if lh > ah and ll < al
        "London Engulfs Asia"
    else if ah >= lh and al <= ll
        "Asia Engulfs London"
    else if lh > ah and ll >= al
        "London Partial Up"
    else if ll < al and lh <= ah
        "London Partial Down"
    else
        "Inside"

f_25(o, c) =>
    body_top   = math.max(o, c)
    body_bot   = math.min(o, c)
    body_range = body_top - body_bot
    is_bull    = c >= o
    if body_range > 0
        is_bull ? body_top - body_range * 0.25 : body_bot + body_range * 0.25
    else
        (body_top + body_bot) / 2

f_pct(num, den) =>
    den > 0 ? str.tostring(math.round(num / den * 100, 1)) + "%" : "n/a"

f_tpos(s) =>
    switch s
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        =>                 position.bottom_right

f_tsz(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        =>          size.small

// ═══════════════════════════════════════════════════════════════════
// STATS — TABLE RENDERING
// ═══════════════════════════════════════════════════════════════════

var table stats_tbl = na

if show_stats and barstate.islast

    london_closed_today = (is_ny > 0) or (is_ny[1] > 0 and is_ny == 0 and not na(p_lo))

    cur_regime =
         not na(reg_ah) and not na(reg_lh) ?
         (london_closed_today ?
          f_regime(reg_ah, reg_al, reg_lh, reg_ll) :
          "Pending (London open)") :
         "n/a"

    cur_asia_range =
         not na(p_ah) and not na(p_al) ?
         str.tostring(math.round(p_ah - p_al, 1)) : "n/a"
    cur_lon_range =
         not na(p_lh) and not na(p_ll) ?
         str.tostring(math.round(p_lh - p_ll, 1)) : "n/a"

    n_total = array.size(h_ah)
    n_look  = math.min(n_total, stats_lookback)
    start_i = n_total - n_look

    n_regime             = 0
    n_ny_bull            = 0
    n_lon_h_taken        = 0
    n_lon_l_taken        = 0
    n_sequential         = 0
    n_ny_open_above      = 0
    n_wick_lon25_bull    = 0
    n_wick_lon25_fail    = 0
    n_above_lon25        = 0
    n_wick_lon_low_bull  = 0
    n_bull_sessions      = 0
    n_wick_lon25_bear    = 0
    n_wick_lon25_bear_fail = 0
    n_below_lon25        = 0
    n_wick_lon_high_bear = 0
    n_bear_sessions      = 0
    asia_range_sum       = 0.0
    lon_range_sum        = 0.0

    loop_regime = not na(reg_ah) and not na(reg_lh) and london_closed_today ?
         f_regime(reg_ah, reg_al, reg_lh, reg_ll) : "n/a"

    for i = start_i to n_total - 1
        i_ah = array.get(h_ah, i)
        i_al = array.get(h_al, i)
        i_lh = array.get(h_lh, i)
        i_ll = array.get(h_ll, i)
        i_lo = array.get(h_lo, i)
        i_lc = array.get(h_lc, i)
        i_nh = array.get(h_nh, i)
        i_nl = array.get(h_nl, i)
        i_no = array.get(h_no, i)
        i_nc = array.get(h_nc, i)

        asia_range_sum := asia_range_sum + (i_ah - i_al)
        lon_range_sum  := lon_range_sum  + (i_lh - i_ll)

        if f_regime(i_ah, i_al, i_lh, i_ll) == loop_regime
            n_regime := n_regime + 1

            if i_nc > i_no
                n_ny_bull := n_ny_bull + 1

            lon_h_taken = i_nh >= i_lh
            lon_l_taken = i_nl <= i_ll
            if lon_h_taken
                n_lon_h_taken := n_lon_h_taken + 1
            if lon_l_taken
                n_lon_l_taken := n_lon_l_taken + 1
            if lon_h_taken and lon_l_taken
                n_sequential := n_sequential + 1

            if i_no > (i_lh + i_ll) / 2
                n_ny_open_above := n_ny_open_above + 1

            lon_25_level = f_25(i_lo, i_lc)
            lon_is_bull  = i_lc > i_lo
            if lon_is_bull
                n_bull_sessions := n_bull_sessions + 1
                if i_nl < lon_25_level
                    if i_nc > lon_25_level
                        n_wick_lon25_bull := n_wick_lon25_bull + 1
                    else
                        n_wick_lon25_fail := n_wick_lon25_fail + 1
                else
                    n_above_lon25 := n_above_lon25 + 1
                if i_nl < i_ll and i_nc > i_ll
                    n_wick_lon_low_bull := n_wick_lon_low_bull + 1
            else
                n_bear_sessions := n_bear_sessions + 1
                if i_nh > lon_25_level
                    if i_nc < lon_25_level
                        n_wick_lon25_bear := n_wick_lon25_bear + 1
                    else
                        n_wick_lon25_bear_fail := n_wick_lon25_bear_fail + 1
                else
                    n_below_lon25 := n_below_lon25 + 1
                if i_nh > i_lh and i_nc < i_lh
                    n_wick_lon_high_bear := n_wick_lon_high_bear + 1

    avg_asia_range =
         n_look > 0 ?
         str.tostring(math.round(asia_range_sum / n_look, 1)) : "n/a"
    avg_lon_range =
         n_look > 0 ?
         str.tostring(math.round(lon_range_sum / n_look, 1)) : "n/a"

    cur_lon_25_txt =
         not na(p_lo) and not na(p_lc) ?
         (p_lc > p_lo ? "Above (bull)" : "Below (bear)") : "n/a"
    cur_ny_pos_txt =
         not na(p_lh) and not na(p_ll) and not na(ny_o) ?
         (ny_o > (p_lh + p_ll) / 2 ? "Above London Mid" : "Below London Mid") : "n/a"

    live_ny_h = (is_ny > 0) and not na(ny_h) ? ny_h : p_nh
    live_ny_l = (is_ny > 0) and not na(ny_l) ? ny_l : p_nl

    cur_lon_h_txt =
         not na(p_lh) and not na(live_ny_h) ?
         (live_ny_h >= p_lh ? "Taken ✓" : "Pending") : "n/a"
    cur_lon_l_txt =
         not na(p_ll) and not na(live_ny_l) ?
         (live_ny_l <= p_ll ? "Taken ✓" : "Pending") : "n/a"

    table.delete(stats_tbl)
    tsz = f_tsz(stats_txt_size)

    stats_tbl :=
         table.new(f_tpos(stats_pos), 2, 28,
                   bgcolor      = stats_bg,
                   border_color = stats_bdr_col,
                   border_width = 1,
                   frame_color  = stats_bdr_col,
                   frame_width  = 1)

    row = 0

    table.cell(stats_tbl, 0, row, "REGIME",
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    table.cell(stats_tbl, 1, row, "",
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    row := row + 1

    table.cell(stats_tbl, 0, row, "Structure",
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    table.cell(stats_tbl, 1, row, cur_regime,
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    row := row + 1

    table.cell(stats_tbl, 0, row, "Occurrences",
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    table.cell(stats_tbl, 1, row,
               str.tostring(n_regime) + " / " + str.tostring(n_look),
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    row := row + 1

    table.cell(stats_tbl, 0, row, "Asia Range (avg | cur)",
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    table.cell(stats_tbl, 1, row,
               avg_asia_range + " | " + cur_asia_range + " pts",
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    row := row + 1

    table.cell(stats_tbl, 0, row, "London Range (avg | cur)",
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    table.cell(stats_tbl, 1, row,
               avg_lon_range + " | " + cur_lon_range + " pts",
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    row := row + 1

    table.cell(stats_tbl, 0, row, "─────────────────────────",
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    table.cell(stats_tbl, 1, row, "──────────────────",
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    row := row + 1

    table.cell(stats_tbl, 0, row, "NY BEHAVIOUR",
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    table.cell(stats_tbl, 1, row, "(this regime)",
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    row := row + 1

    table.cell(stats_tbl, 0, row, "NY Bullish",
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    table.cell(stats_tbl, 1, row, f_pct(n_ny_bull, n_regime),
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    row := row + 1

    table.cell(stats_tbl, 0, row, "London High Taken",
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    table.cell(stats_tbl, 1, row, f_pct(n_lon_h_taken, n_regime),
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    row := row + 1

    table.cell(stats_tbl, 0, row, "London Low Taken",
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    table.cell(stats_tbl, 1, row, f_pct(n_lon_l_taken, n_regime),
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    row := row + 1

    table.cell(stats_tbl, 0, row, "Sequential H+L",
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    table.cell(stats_tbl, 1, row, f_pct(n_sequential, n_regime),
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    row := row + 1

    table.cell(stats_tbl, 0, row, "NY Open Above Lon Mid",
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    table.cell(stats_tbl, 1, row, f_pct(n_ny_open_above, n_regime),
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    row := row + 1

    cur_lon_bull = not na(p_lo) and not na(p_lc) and p_lc > p_lo
    if cur_lon_bull
        table.cell(stats_tbl, 0, row, "NY Stays Above Lon 25%",
                   text_color=stats_txt_col, text_size=tsz,
                   text_font_family=font.family_monospace, bgcolor=stats_bg)
        table.cell(stats_tbl, 1, row, f_pct(n_above_lon25, n_bull_sessions),
                   text_color=stats_txt_col, text_size=tsz,
                   text_font_family=font.family_monospace, bgcolor=stats_bg)
        row := row + 1
        table.cell(stats_tbl, 0, row, "Wick < Lon 25% → Close Above",
                   text_color=stats_txt_col, text_size=tsz,
                   text_font_family=font.family_monospace, bgcolor=stats_bg)
        table.cell(stats_tbl, 1, row, f_pct(n_wick_lon25_bull, n_bull_sessions),
                   text_color=stats_txt_col, text_size=tsz,
                   text_font_family=font.family_monospace, bgcolor=stats_bg)
        row := row + 1
        table.cell(stats_tbl, 0, row, "Wick < Lon 25% → Close Below",
                   text_color=stats_txt_col, text_size=tsz,
                   text_font_family=font.family_monospace, bgcolor=stats_bg)
        table.cell(stats_tbl, 1, row, f_pct(n_wick_lon25_fail, n_bull_sessions),
                   text_color=stats_txt_col, text_size=tsz,
                   text_font_family=font.family_monospace, bgcolor=stats_bg)
        row := row + 1
        table.cell(stats_tbl, 0, row, "Wick < Lon Low → Close Above",
                   text_color=stats_txt_col, text_size=tsz,
                   text_font_family=font.family_monospace, bgcolor=stats_bg)
        table.cell(stats_tbl, 1, row, f_pct(n_wick_lon_low_bull, n_bull_sessions),
                   text_color=stats_txt_col, text_size=tsz,
                   text_font_family=font.family_monospace, bgcolor=stats_bg)
        row := row + 1
    else
        table.cell(stats_tbl, 0, row, "NY Stays Below Lon 25%",
                   text_color=stats_txt_col, text_size=tsz,
                   text_font_family=font.family_monospace, bgcolor=stats_bg)
        table.cell(stats_tbl, 1, row, f_pct(n_below_lon25, n_bear_sessions),
                   text_color=stats_txt_col, text_size=tsz,
                   text_font_family=font.family_monospace, bgcolor=stats_bg)
        row := row + 1
        table.cell(stats_tbl, 0, row, "Wick > Lon 25% → Close Below",
                   text_color=stats_txt_col, text_size=tsz,
                   text_font_family=font.family_monospace, bgcolor=stats_bg)
        table.cell(stats_tbl, 1, row, f_pct(n_wick_lon25_bear, n_bear_sessions),
                   text_color=stats_txt_col, text_size=tsz,
                   text_font_family=font.family_monospace, bgcolor=stats_bg)
        row := row + 1
        table.cell(stats_tbl, 0, row, "Wick > Lon 25% → Close Above",
                   text_color=stats_txt_col, text_size=tsz,
                   text_font_family=font.family_monospace, bgcolor=stats_bg)
        table.cell(stats_tbl, 1, row, f_pct(n_wick_lon25_bear_fail, n_bear_sessions),
                   text_color=stats_txt_col, text_size=tsz,
                   text_font_family=font.family_monospace, bgcolor=stats_bg)
        row := row + 1
        table.cell(stats_tbl, 0, row, "Wick > Lon High → Close Below",
                   text_color=stats_txt_col, text_size=tsz,
                   text_font_family=font.family_monospace, bgcolor=stats_bg)
        table.cell(stats_tbl, 1, row, f_pct(n_wick_lon_high_bear, n_bear_sessions),
                   text_color=stats_txt_col, text_size=tsz,
                   text_font_family=font.family_monospace, bgcolor=stats_bg)
        row := row + 1

    table.cell(stats_tbl, 0, row, "─────────────────────────",
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    table.cell(stats_tbl, 1, row, "──────────────────",
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    row := row + 1

    table.cell(stats_tbl, 0, row, "TODAY",
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    table.cell(stats_tbl, 1, row, "",
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    row := row + 1

    table.cell(stats_tbl, 0, row, "London 25%",
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    table.cell(stats_tbl, 1, row, cur_lon_25_txt,
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    row := row + 1

    table.cell(stats_tbl, 0, row, "NY Open",
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    table.cell(stats_tbl, 1, row, cur_ny_pos_txt,
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    row := row + 1

    table.cell(stats_tbl, 0, row, "London High",
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    table.cell(stats_tbl, 1, row, cur_lon_h_txt,
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    row := row + 1

    table.cell(stats_tbl, 0, row, "London Low",
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
    table.cell(stats_tbl, 1, row, cur_lon_l_txt,
               text_color=stats_txt_col, text_size=tsz,
               text_font_family=font.family_monospace, bgcolor=stats_bg)
````
