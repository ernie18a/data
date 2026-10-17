# VWAP Suite [ChartSmith]

- url: https://www.tradingview.com/script/oXHwS4UO-VWAP-Suite-ChartSmith/
- type: indicator
- pine_id: PUB;401d95dde12b42a5ae3d0511ab2c869f
- version: 2.0

## Description

[pine]
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>VWAP Suite — ChartSmith</title>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
      background: #0d1117;
      color: #c9d1d9;
      line-height: 1.7;
      padding: 48px 24px;
    }

    .container {
      max-width: 860px;
      margin: 0 auto;
    }

    /* ── Header ── */
    header {
      border-bottom: 1px solid #21262d;
      padding-bottom: 32px;
      margin-bottom: 40px;
    }

    header h1 {
      font-size: 2rem;
      font-weight: 700;
      color: #f0f6fc;
      letter-spacing: -0.5px;
      margin-bottom: 12px;
    }

    .meta {
      display: flex;
      flex-wrap: wrap;
      gap: 12px;
    }

    .badge {
      display: inline-block;
      font-size: 0.75rem;
      font-weight: 600;
      letter-spacing: 0.04em;
      text-transform: uppercase;
      padding: 3px 10px;
      border-radius: 20px;
      background: #1f2937;
      color: #94a3b8;
      border: 1px solid #374151;
    }

    /* ── Sections ── */
    section {
      margin-bottom: 48px;
    }

    h2 {
      font-size: 1.25rem;
      font-weight: 600;
      color: #f0f6fc;
      margin-bottom: 16px;
      padding-bottom: 8px;
      border-bottom: 1px solid #21262d;
    }

    h3 {
      font-size: 1rem;
      font-weight: 600;
      color: #e2e8f0;
      margin: 24px 0 10px;
    }

    p {
      margin-bottom: 14px;
      color: #c9d1d9;
    }

    /* ── Tables ── */
    .table-wrap {
      overflow-x: auto;
      margin-bottom: 14px;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      font-size: 0.9rem;
    }

    thead tr {
      background: #161b22;
    }

    th {
      text-align: left;
      padding: 10px 14px;
      font-weight: 600;
      color: #8b949e;
      font-size: 0.78rem;
      text-transform: uppercase;
      letter-spacing: 0.06em;
      border-bottom: 1px solid #21262d;
    }

    td {
      padding: 10px 14px;
      border-bottom: 1px solid #161b22;
      color: #c9d1d9;
      vertical-align: top;
    }

    tbody tr:last-child td {
      border-bottom: none;
    }

    tbody tr:hover td {
      background: #161b22;
    }

    td strong, td code {
      color: #e2e8f0;
    }

    /* ── Callout ── */
    .callout {
      background: #161b22;
      border-left: 3px solid #3b82f6;
      border-radius: 0 6px 6px 0;
      padding: 16px 20px;
      margin: 20px 0;
      font-size: 0.92rem;
    }

    .callout p {
      margin: 0;
      color: #c9d1d9;
    }

    /* ── Priority chain ── */
    .priority {
      display: flex;
      align-items: center;
      gap: 10px;
      flex-wrap: wrap;
      margin: 16px 0;
    }

    .priority-item {
      background: #1f2937;
      border: 1px solid #374151;
      border-radius: 6px;
      padding: 6px 14px;
      font-size: 0.85rem;
      font-weight: 600;
      color: #e2e8f0;
    }

    .priority-arrow {
      color: #4b5563;
      font-size: 1rem;
    }

    .priority-end {
      color: #6b7280;
      font-size: 0.85rem;
      font-style: italic;
    }

    /* ── Use case list ── */
    ul {
      list-style: none;
      padding: 0;
    }

    ul li {
      padding: 10px 0 10px 20px;
      border-bottom: 1px solid #161b22;
      position: relative;
      color: #c9d1d9;
      font-size: 0.92rem;
    }

    ul li:last-child {
      border-bottom: none;
    }

    ul li::before {
      content: "→";
      position: absolute;
      left: 0;
      color: #3b82f6;
      font-weight: 700;
    }

    ul li strong {
      color: #e2e8f0;
    }

    /* ── Default badge in table ── */
    .default-tag {
      font-size: 0.7rem;
      font-weight: 600;
      color: #3b82f6;
      background: #1e3a5f;
      border: 1px solid #2563eb44;
      border-radius: 4px;
      padding: 1px 6px;
      margin-left: 6px;
      vertical-align: middle;
      white-space: nowrap;
    }

    footer {
      margin-top: 64px;
      padding-top: 24px;
      border-top: 1px solid #21262d;
      font-size: 0.78rem;
      color: #484f58;
      text-align: center;
    }
  </style>
</head>
<body>
<div class="container">

  <!-- ── Header ── -->
  <header>
    <h1>VWAP Suite</h1>
    <div class="meta">
      <span class="badge">CS · VWAP</span>
      <span class="badge">TradingView · Pine Script v5</span>
      <span class="badge">Overlay</span>
      <span class="badge">ChartSmith</span>
    </div>
  </header>

  <!-- ── Overview ── -->
  <section>
    <h2>Overview</h2>
    <p>
      VWAP Suite is a professional-grade Volume Weighted Average Price indicator designed for traders who need
      precise session-aware VWAP anchoring with configurable standard deviation bands. The indicator supports
      six distinct anchor periods, up to three independently styled deviation bands with fill regions, and an
      optional candle-coloring system that visually signals price extension beyond any band level.
    </p>
  </section>

  <!-- ── Anchor Modes ── -->
  <section>
    <h2>Anchor Modes</h2>
    <p>
      The anchor determines when the VWAP calculation resets and begins accumulating a fresh volume-weighted
      average. All session-based anchors align to US Eastern Time.
    </p>
    <div class="table-wrap">
      <table>
        <thead>
          <tr>
            <th>Anchor</th>
            <th>Reset Point</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><strong>ETH Session</strong></td>
            <td>6:00 PM ET each evening (CME futures session open)</td>
          </tr>
          <tr>
            <td><strong>RTH Session</strong></td>
            <td>9:30 AM ET each trading day (NYSE / NASDAQ open)</td>
          </tr>
          <tr>
            <td><strong>Weekly</strong></td>
            <td>Sunday 6:00 PM ET (CME week open); falls back to Monday open on equity-only charts</td>
          </tr>
          <tr>
            <td><strong>Monthly</strong></td>
            <td>6:00 PM ET on the last calendar day of the month</td>
          </tr>
          <tr>
            <td><strong>Quarterly</strong></td>
            <td>First bar of each new calendar quarter</td>
          </tr>
          <tr>
            <td><strong>Yearly</strong></td>
            <td>First bar of each new calendar year</td>
          </tr>
        </tbody>
      </table>
    </div>

    <h3>RTH Session Behavior</h3>
    <p>
      When <strong>RTH Session</strong> is selected, the VWAP and all bands are displayed exclusively during
      Regular Trading Hours (9:30 AM – 4:15 PM ET). Outside of this window — including pre-market and
      after-hours bars — the indicator goes completely blank. A fresh VWAP begins drawing at each 9:30 AM open
      and stops cleanly at 4:15 PM, regardless of whether the chart itself is set to display extended or
      regular hours.
    </p>

    <h3>Manual Anchor Override</h3>
    <p>
      An optional time override allows the anchor reset to be set to any 24-hour ET time of your choosing,
      entered in HHMM format (e.g., <code>0930</code> for 9:30 AM, <code>1800</code> for 6:00 PM). When
      enabled, this overrides the selected anchor mode's default reset time.
    </p>
  </section>

  <!-- ── Standard Deviation Bands ── -->
  <section>
    <h2>Standard Deviation Bands</h2>
    <p>
      Up to three independent standard deviation bands can be displayed above and below VWAP. Each band is
      configured separately and can be enabled or disabled without affecting the others.
    </p>
    <p>Each band offers:</p>
    <ul>
      <li><strong>Show/Hide toggle</strong> — enables or disables the upper and lower band lines</li>
      <li><strong>Multiplier</strong> — controls the width of the band as a multiple of the session's volume-weighted standard deviation (e.g., 1.0×, 2.0×, 3.0×)</li>
      <li><strong>Line color</strong> — independently styled per band</li>
      <li><strong>Fill to the adjacent boundary</strong> — shades the region between the band and its inner neighbor (Band 1 fills to VWAP; Band 2 fills to Band 1; Band 3 fills to Band 2), each with its own fill color</li>
    </ul>
    <div class="callout">
      <p>Line weight and line style (solid, dashed, dotted) are adjusted via TradingView's built-in <strong>Style</strong> tab on the indicator settings panel.</p>
    </div>

    <h3>Default Band Configuration</h3>
    <div class="table-wrap">
      <table>
        <thead>
          <tr>
            <th>Band</th>
            <th>Default Multiplier</th>
            <th>Default State</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><strong>Band 1</strong></td>
            <td>1.0×</td>
            <td>Enabled</td>
          </tr>
          <tr>
            <td><strong>Band 2</strong></td>
            <td>2.0×</td>
            <td>Disabled</td>
          </tr>
          <tr>
            <td><strong>Band 3</strong></td>
            <td>3.0×</td>
            <td>Disabled</td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>

  <!-- ── Candle Coloring ── -->
  <section>
    <h2>Candle Coloring</h2>
    <p>
      Each band includes an optional <strong>Color Candles</strong> feature. When enabled for a given band,
      candles whose closing price lies outside that band's upper or lower boundary are painted with a
      user-defined color. This provides an immediate visual cue for price extension without requiring a
      separate indicator.
    </p>
    <p>Four candle color slots are available per band:</p>
    <ul>
      <li><strong>Above upper band — bullish candle</strong> (close ≥ open)</li>
      <li><strong>Above upper band — bearish candle</strong> (close &lt; open)</li>
      <li><strong>Below lower band — bullish candle</strong></li>
      <li><strong>Below lower band — bearish candle</strong></li>
    </ul>

    <h3>Priority</h3>
    <p>When multiple bands have candle coloring enabled, the outermost active signal takes precedence:</p>
    <div class="priority">
      <span class="priority-item">Band 3</span>
      <span class="priority-arrow">›</span>
      <span class="priority-item">Band 2</span>
      <span class="priority-arrow">›</span>
      <span class="priority-item">Band 1</span>
      <span class="priority-arrow">›</span>
      <span class="priority-end">default chart color</span>
    </div>
    <p>
      A candle that is outside Band 3 will display the Band 3 color regardless of Band 1 or Band 2 settings.
    </p>
    <div class="callout">
      <p>When <strong>RTH Session</strong> is selected as the anchor, candle coloring is automatically suspended outside of trading hours so that off-hours candles always render in their default chart color.</p>
    </div>
  </section>

  <!-- ── Price Source ── -->
  <section>
    <h2>Price Source</h2>
    <p>The price used as input to the VWAP calculation is configurable:</p>
    <div class="table-wrap">
      <table>
        <thead>
          <tr>
            <th>Option</th>
            <th>Formula</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><strong>OHLC/4</strong> <span class="default-tag">default</span></td>
            <td>(Open + High + Low + Close) ÷ 4</td>
          </tr>
          <tr>
            <td><strong>HLC/3</strong></td>
            <td>(High + Low + Close) ÷ 3</td>
          </tr>
          <tr>
            <td><strong>HL/2</strong></td>
            <td>(High + Low) ÷ 2</td>
          </tr>
          <tr>
            <td><strong>Close</strong></td>
            <td>Closing price</td>
          </tr>
          <tr>
            <td><strong>Open</strong></td>
            <td>Opening price</td>
          </tr>
          <tr>
            <td><strong>High</strong></td>
            <td>High price</td>
          </tr>
          <tr>
            <td><strong>Low</strong></td>
            <td>Low price</td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>

  <!-- ── Settings Reference ── -->
  <section>
    <h2>Settings Reference</h2>
    <div class="table-wrap">
      <table>
        <thead>
          <tr>
            <th>Group</th>
            <th>Setting</th>
            <th>Description</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>Anchor</td>
            <td><strong>Anchor To</strong></td>
            <td>Selects the VWAP reset period</td>
          </tr>
          <tr>
            <td>Anchor</td>
            <td><strong>Override Anchor Time</strong></td>
            <td>Enables a custom reset time</td>
          </tr>
          <tr>
            <td>Anchor</td>
            <td><strong>Manual Anchor Time</strong></td>
            <td>The custom reset time in HHMM, 24-hour ET</td>
          </tr>
          <tr>
            <td>VWAP</td>
            <td><strong>VWAP (toggle + color)</strong></td>
            <td>Shows or hides the VWAP line</td>
          </tr>
          <tr>
            <td>Band 1–3</td>
            <td><strong>Standard Deviation</strong></td>
            <td>Shows or hides the band lines; sets the multiplier and color</td>
          </tr>
          <tr>
            <td>Band 1–3</td>
            <td><strong>Fill</strong></td>
            <td>Enables the fill region and its color</td>
          </tr>
          <tr>
            <td>Band 1–3</td>
            <td><strong>Color Candles</strong></td>
            <td>Enables candle coloring for that band's boundary</td>
          </tr>
          <tr>
            <td>Band 1–3</td>
            <td><strong>▲ Up / Down</strong></td>
            <td>Colors for candles above the upper band</td>
          </tr>
          <tr>
            <td>Band 1–3</td>
            <td><strong>▼ Up / Down</strong></td>
            <td>Colors for candles below the lower band</td>
          </tr>
          <tr>
            <td>Source</td>
            <td><strong>Price Source</strong></td>
            <td>The OHLC formula used as the VWAP input</td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>

  <!-- ── Intended Use Cases ── -->
  <section>
    <h2>Intended Use Cases</h2>
    <ul>
      <li><strong>Intraday traders</strong> using RTH Session anchor to track the day's volume-weighted fair value with a clean visual reset at each session open and close</li>
      <li><strong>Futures traders</strong> using ETH Session anchor aligned to the CME open at 6:00 PM ET</li>
      <li><strong>Swing traders</strong> using Weekly or Monthly anchors to identify longer-term institutional value areas</li>
      <li><strong>Extended session traders</strong> who need the standard deviation bands to identify potential mean-reversion or breakout levels relative to the accumulated session VWAP</li>
      <li><strong>Active traders</strong> who want immediate candle-level feedback when price moves into statistically significant extension zones beyond one, two, or three standard deviations</li>
    </ul>
  </section>

  <footer>
    VWAP Suite [ChartSmith] &nbsp;·&nbsp; CS · VWAP &nbsp;·&nbsp; TradingView Pine Script v5
  </footer>

</div>
</body>
</html>

[/pine]

## Source Code

````pine
//@version=5
indicator(
     title          = "VWAP Suite [ChartSmith]",
     shorttitle     = "CS · VWAP",
     overlay        = true,
     max_lines_count = 500,
     max_labels_count = 50
 )

// ══════════════════════════════════════════════════════════════════════════════
// §1 ─ INPUTS
// ══════════════════════════════════════════════════════════════════════════════


// ─── Anchor ──────────────────────────────────────────────────────────────────
string GRP_ANC     = "Anchor"
string i_anchor    = input.string(
     defval  = "ETH Session",
     title   = "Anchor To",
     options = ["ETH Session", "RTH Session", "Weekly", "Monthly", "Quarterly", "Yearly"],
     group   = GRP_ANC,
     tooltip = "ETH Session: resets 18:00 ET the prior evening (CME session open).\n"
             + "RTH Session: resets at 9:30 AM US Eastern Time each trading day.\n"
             + "Weekly: resets Sunday 18:00 ET (CME week open).\n"
             + "Monthly: resets 18:00 ET on the last calendar day of the month.\n"
             + "Quarterly / Yearly: resets on the first bar of the new period.")
bool   i_useManual  = input.bool(
     defval  = false,
     title   = "Override Anchor Time",
     group   = GRP_ANC)
string i_manualTime = input.string(
     defval  = "1800",
     title   = "Manual Anchor Time (HHMM, 24-h ET)",
     group   = GRP_ANC,
     tooltip = "Only active when 'Override Anchor Time' is enabled.\n"
             + "Enter the reset time as HHMM in 24-hour US Eastern Time.\n"
             + "Examples:  1800 = 6:00 PM ET (CME session open)\n"
             + "           0930 = 9:30 AM ET (RTH open)\n"
             + "           0000 = midnight ET (calendar day reset)")

// ─── VWAP ────────────────────────────────────────────────────────────────────
string GRP_VWAP = "VWAP"
bool   i_vShow  = input.bool(true,                     "VWAP",
     group = GRP_VWAP, inline = "v1")
color  i_vClr   = input.color(color.new(#FFFFFF, 0),  "",
     group = GRP_VWAP, inline = "v1")

// ─── Band 1 ──────────────────────────────────────────────────────────────────
string GRP_B1   = "Band 1"
bool   i_b1Show = input.bool(true,                     "Standard Deviation",
     group = GRP_B1, inline = "b1a")
float  i_b1Mult = input.float(1.0,                     "×",
     group = GRP_B1, inline = "b1a", minval = 0.25, step = 0.25)
color  i_b1Clr  = input.color(color.new(#2196F3, 0),  "",
     group = GRP_B1, inline = "b1a")
bool   i_b1Fill = input.bool(true,                     "Fill to VWAP",
     group = GRP_B1, inline = "b1c",
     tooltip = "Shade the region between Band 1 and VWAP.")
color  i_b1FClr = input.color(color.new(#2196F3, 88), "Color",
     group = GRP_B1, inline = "b1c")
bool   i_b1Candle = input.bool(false,                  "Color Candles",
     group = GRP_B1,
     tooltip = "Paint candles when close is outside Band 1.\nBand 3 takes precedence over Band 2 over Band 1.")
color  i_b1AbvUp  = input.color(#26A69A,               "▲  Up",
     group = GRP_B1, inline = "b1_abv",
     tooltip = "Above upper band — up candle (close ≥ open).")
color  i_b1AbvDn  = input.color(#00796B,               "Down",
     group = GRP_B1, inline = "b1_abv")
color  i_b1BlwUp  = input.color(#B71C1C,               "▼  Up",
     group = GRP_B1, inline = "b1_blw",
     tooltip = "Below lower band — up candle (close ≥ open).")
color  i_b1BlwDn  = input.color(#EF5350,               "Down",
     group = GRP_B1, inline = "b1_blw")

// ─── Band 2 ──────────────────────────────────────────────────────────────────
string GRP_B2   = "Band 2"
bool   i_b2Show = input.bool(false,                    "Standard Deviation",
     group = GRP_B2, inline = "b2a")
float  i_b2Mult = input.float(2.0,                     "×",
     group = GRP_B2, inline = "b2a", minval = 0.25, step = 0.25)
color  i_b2Clr  = input.color(color.new(#9C27B0, 0),  "",
     group = GRP_B2, inline = "b2a")
bool   i_b2Fill = input.bool(true,                     "Fill to Band 1",
     group = GRP_B2, inline = "b2c",
     tooltip = "Shade the region between Band 2 and Band 1.")
color  i_b2FClr = input.color(color.new(#9C27B0, 88), "Color",
     group = GRP_B2, inline = "b2c")
bool   i_b2Candle = input.bool(false,                  "Color Candles",
     group = GRP_B2,
     tooltip = "Paint candles when close is outside Band 2.\nOverrides Band 1 candle colors.")
color  i_b2AbvUp  = input.color(#66BB6A,               "▲  Up",
     group = GRP_B2, inline = "b2_abv",
     tooltip = "Above upper band — up candle (close ≥ open).")
color  i_b2AbvDn  = input.color(#2E7D32,               "Down",
     group = GRP_B2, inline = "b2_abv")
color  i_b2BlwUp  = input.color(#880E4F,               "▼  Up",
     group = GRP_B2, inline = "b2_blw",
     tooltip = "Below lower band — up candle (close ≥ open).")
color  i_b2BlwDn  = input.color(#E91E63,               "Down",
     group = GRP_B2, inline = "b2_blw")

// ─── Band 3 ──────────────────────────────────────────────────────────────────
string GRP_B3   = "Band 3"
bool   i_b3Show = input.bool(false,                    "Standard Deviation",
     group = GRP_B3, inline = "b3a")
float  i_b3Mult = input.float(3.0,                     "×",
     group = GRP_B3, inline = "b3a", minval = 0.25, step = 0.25)
color  i_b3Clr  = input.color(color.new(#F44336, 0),  "",
     group = GRP_B3, inline = "b3a")
bool   i_b3Fill = input.bool(true,                     "Fill to Band 2",
     group = GRP_B3, inline = "b3c",
     tooltip = "Shade the region between Band 3 and Band 2.")
color  i_b3FClr = input.color(color.new(#F44336, 88), "Color",
     group = GRP_B3, inline = "b3c")
bool   i_b3Candle = input.bool(false,                  "Color Candles",
     group = GRP_B3,
     tooltip = "Paint candles when close is outside Band 3.\nHighest priority — overrides Band 1 and Band 2 candle colors.")
color  i_b3AbvUp  = input.color(#FDD835,               "▲  Up",
     group = GRP_B3, inline = "b3_abv",
     tooltip = "Above upper band — up candle (close ≥ open).")
color  i_b3AbvDn  = input.color(#F9A825,               "Down",
     group = GRP_B3, inline = "b3_abv")
color  i_b3BlwUp  = input.color(#4527A0,               "▼  Up",
     group = GRP_B3, inline = "b3_blw",
     tooltip = "Below lower band — up candle (close ≥ open).")
color  i_b3BlwDn  = input.color(#7B1FA2,               "Down",
     group = GRP_B3, inline = "b3_blw")

// ─── Source ──────────────────────────────────────────────────────────────────
string GRP_SRC = "Source"
string i_src   = input.string(
     defval  = "OHLC/4",
     title   = "Price Source",
     options = ["OHLC/4", "HLC/3", "HL/2", "Close", "Open", "High", "Low"],
     group   = GRP_SRC)

// ══════════════════════════════════════════════════════════════════════════════
// §2 ─ PRICE SOURCE
// ══════════════════════════════════════════════════════════════════════════════

float srcPrice =
     i_src == "OHLC/4" ? (open + high + low + close) / 4.0 :
     i_src == "HLC/3"  ? (high + low + close) / 3.0        :
     i_src == "HL/2"   ? (high + low) / 2.0                :
     i_src == "Close"  ? close                              :
     i_src == "Open"   ? open                               :
     i_src == "High"   ? high                               :
     i_src == "Low"    ? low                                :
                         (open + high + low + close) / 4.0

// ══════════════════════════════════════════════════════════════════════════════
// §3 ─ ANCHOR DETECTION
// Returns true on the first bar that crosses into a new anchor period.
//
// All session-based anchors align to 18:00 ET — the CME futures session open:
//   ETH  : fires every day at 18:00 ET
//   RTH  : fires at 9:30 AM ET (separate logic, unchanged)
//   Weekly  : fires at Sunday 18:00 ET; falls back to Monday open for equities
//   Monthly : fires at 18:00 ET on the last calendar day of the month;
//             falls back to the first bar of the new month for equity charts
//
// barstate.isfirst guarantees clean initialisation on the earliest history bar.
// ══════════════════════════════════════════════════════════════════════════════

// Integer HHMM of current and previous bar in US Eastern Time (e.g. 1800 = 18:00)
int etNow  = hour(time,    "America/New_York") * 100 + minute(time,    "America/New_York")
int etPrev = hour(time[1], "America/New_York") * 100 + minute(time[1], "America/New_York")
int manHHMM = int(str.tonumber(i_manualTime))

// Adding 25 h (90 000 000 ms) safely crosses midnight even during DST transitions,
// allowing us to test whether "tomorrow" falls in a different month.
bool tomorrowIsNewMonth = month(time + 90000000) != month(time)

bool isNewAnchor =
     i_useManual               ? etNow >= manHHMM and etPrev < manHHMM :

     // Daily CME session: resets at 18:00 ET each evening
     i_anchor == "ETH Session" ? etNow >= 1800 and etPrev < 1800 :

     // RTH open: unchanged
     i_anchor == "RTH Session" ? etNow >= 930  and etPrev < 930  :

     // Weekly: Sunday 18:00 ET; equity fallback = first Monday after Fri/Sat close
     i_anchor == "Weekly"      ?
         (dayofweek == dayofweek.sunday and etNow >= 1800 and etPrev < 1800) or
         (dayofweek == dayofweek.monday and
             (dayofweek[1] == dayofweek.friday or dayofweek[1] == dayofweek.saturday)) :

     // Monthly: 18:00 ET on the last calendar day; equity fallback = first bar of new month
     i_anchor == "Monthly"     ?
         (tomorrowIsNewMonth and etNow >= 1800 and etPrev < 1800) or
         (month(time) != month(time[1]) and not (month(time[1] + 90000000) != month(time[1]))) :

     i_anchor == "Quarterly"   ? math.ceil(month / 3.0) != math.ceil(month[1] / 3.0) :
     i_anchor == "Yearly"      ? year != year[1]                                       : false

bool doReset = isNewAnchor or barstate.isfirst

// True only during RTH window; gates plots when RTH Session is selected
bool isInRTH = etNow >= 930 and etNow < 1615
bool rthMask = i_anchor != "RTH Session" or isInRTH

// ══════════════════════════════════════════════════════════════════════════════
// §4 ─ VWAP & STANDARD DEVIATION
//
// Running sums are reset on every anchor boundary.
//
//   VWAP     = Σ(P · V) / ΣV
//   Variance = Σ(P² · V) / ΣV  −  VWAP²     (population variance, volume-weighted)
//   StdDev   = √Variance
//
// math.max(..., 0) guards against floating-point rounding that could produce
// a tiny negative variance, which would cause math.sqrt to return na.
// ══════════════════════════════════════════════════════════════════════════════

var float sumPV  = 0.0
var float sumPV2 = 0.0
var float sumV   = 0.0

float vol = math.max(nz(volume), 1e-10)  // prevent division by zero / na volume

if doReset
    sumPV  := srcPrice * vol
    sumPV2 := srcPrice * srcPrice * vol
    sumV   := vol
else
    sumPV  += srcPrice * vol
    sumPV2 += srcPrice * srcPrice * vol
    sumV   += vol

float vwap   = sumPV / sumV
float stdDev = math.sqrt(math.max(sumPV2 / sumV - vwap * vwap, 0.0))

// Symmetric band levels
float b1u = vwap + i_b1Mult * stdDev
float b1l = vwap - i_b1Mult * stdDev
float b2u = vwap + i_b2Mult * stdDev
float b2l = vwap - i_b2Mult * stdDev
float b3u = vwap + i_b3Mult * stdDev
float b3l = vwap - i_b3Mult * stdDev

// ══════════════════════════════════════════════════════════════════════════════
// §5 ─ PLOTS & FILLS
//
// Line width and style (solid / dashed / dotted) are controlled per-plot from
// TradingView's built-in Style tab — no input.*() overrides needed here.
//
// Each plot serves double duty as both the visible line and the fill() boundary,
// so no separate anchor plots are required.
//
// Fill regions:
//   Band 1 ↔ VWAP   (inner zone)
//   Band 2 ↔ Band 1 (middle zone)
//   Band 3 ↔ Band 2 (outer zone)
// ══════════════════════════════════════════════════════════════════════════════

// ─── VWAP ────────────────────────────────────────────────────────────────────
p_vwap = plot(i_vShow and rthMask ? vwap : na,
     title     = "VWAP",
     color     = i_vClr,
     linewidth = 2,
     style     = plot.style_linebr)

// ─── Band 1 ──────────────────────────────────────────────────────────────────
p_b1u = plot(i_b1Show and rthMask ? b1u : na, title = "Band 1 Upper", color = i_b1Clr, linewidth = 1, style = plot.style_linebr)
p_b1l = plot(i_b1Show and rthMask ? b1l : na, title = "Band 1 Lower", color = i_b1Clr, linewidth = 1, style = plot.style_linebr)

// ─── Band 2 ──────────────────────────────────────────────────────────────────
p_b2u = plot(i_b2Show and rthMask ? b2u : na, title = "Band 2 Upper", color = i_b2Clr, linewidth = 1, style = plot.style_linebr)
p_b2l = plot(i_b2Show and rthMask ? b2l : na, title = "Band 2 Lower", color = i_b2Clr, linewidth = 1, style = plot.style_linebr)

// ─── Band 3 ──────────────────────────────────────────────────────────────────
p_b3u = plot(i_b3Show and rthMask ? b3u : na, title = "Band 3 Upper", color = i_b3Clr, linewidth = 1, style = plot.style_linebr)
p_b3l = plot(i_b3Show and rthMask ? b3l : na, title = "Band 3 Lower", color = i_b3Clr, linewidth = 1, style = plot.style_linebr)

// ─── Fills ───────────────────────────────────────────────────────────────────

// Band 1 ↔ VWAP
fill(p_b1u, p_vwap, color = i_b1Show and i_b1Fill ? i_b1FClr : na, title = "B1 Upper Fill")
fill(p_b1l, p_vwap, color = i_b1Show and i_b1Fill ? i_b1FClr : na, title = "B1 Lower Fill")

// Band 2 ↔ Band 1
fill(p_b2u, p_b1u,  color = i_b2Show and i_b2Fill ? i_b2FClr : na, title = "B2 Upper Fill")
fill(p_b2l, p_b1l,  color = i_b2Show and i_b2Fill ? i_b2FClr : na, title = "B2 Lower Fill")

// Band 3 ↔ Band 2
fill(p_b3u, p_b2u,  color = i_b3Show and i_b3Fill ? i_b3FClr : na, title = "B3 Upper Fill")
fill(p_b3l, p_b2l,  color = i_b3Show and i_b3Fill ? i_b3FClr : na, title = "B3 Lower Fill")

// ══════════════════════════════════════════════════════════════════════════════
// §6 ─ CANDLE COLORING
//
// close >= open → up candle;  close < open → down candle.
// Band levels are always calculated regardless of line visibility, so candle
// coloring works even when a band's lines are turned off.
//
// Priority (highest wins): Band 3 → Band 2 → Band 1 → na (default chart color)
// ══════════════════════════════════════════════════════════════════════════════

bool  isUpCandle = close >= open
color candleClr  = na

// Band 1 — lowest priority
if i_b1Candle
    if close > b1u
        candleClr := isUpCandle ? i_b1AbvUp : i_b1AbvDn
    else if close < b1l
        candleClr := isUpCandle ? i_b1BlwUp : i_b1BlwDn

// Band 2 — overrides Band 1
if i_b2Candle
    if close > b2u
        candleClr := isUpCandle ? i_b2AbvUp : i_b2AbvDn
    else if close < b2l
        candleClr := isUpCandle ? i_b2BlwUp : i_b2BlwDn

// Band 3 — highest priority, overrides all
if i_b3Candle
    if close > b3u
        candleClr := isUpCandle ? i_b3AbvUp : i_b3AbvDn
    else if close < b3l
        candleClr := isUpCandle ? i_b3BlwUp : i_b3BlwDn

barcolor(rthMask ? candleClr : na)
````
