# Path-Based Session Volume Profile [CLEVER]

- url: https://www.tradingview.com/script/Hb3CrKMt-Path-Based-Session-Volume-Profile-CLEVER/
- type: indicator
- pine_id: PUB;d30df1c77bbd490f9aca7869c1156762
- version: 1.0

## Description

📌 Overview

Path-Based Session Volume Profile is a session-focused analytical tool designed to visualize how trading volume is distributed across price levels within a defined market session. Unlike simplified allocation models that assign an entire candle’s volume to a single closing price or midpoint, this script incorporates the intrabar price path (Open–High–Low–Close behavior) to distribute volume across multiple price segments inside each bar.

The objective of this approach is not to generate predictions or trading signals, but to present a structured representation of session-based market participation. By accounting for the price traversal that occurs within each bar, the indicator aims to provide a more granular view of how volume may be interacting with different price zones during the session.

From the beginning of the selected session, the script incrementally accumulates volume data and distributes it across predefined price rows. With each confirmed bar close, the internal distribution matrix updates to reflect developing session structure. This allows users to observe how volume concentration evolves over time, rather than only seeing a finalized static profile at session end.

Through this structure, users can visually assess:

Areas of relatively higher volume concentration
Areas of relatively lower participation
The Developing and Final Point of Control (POC)
Value Area High (VAH) and Value Area Low (VAL)
Shifts in participation as the session progresses

The calculation model does not rely on future data and does not make performance claims. All outputs are derived from available historical and real-time bar data and update in accordance with bar confirmations. The script is designed as a structural visualization tool rather than an automated decision-making system.

The path-based distribution logic is intended to reduce oversimplification in volume allocation by considering the internal price movement of each candle. This allows traders to integrate session-level volume context into their existing analytical frameworks, such as market structure analysis, liquidity studies, range evaluation, or breakout observation.

This tool may be relevant for intraday traders, futures and forex participants, and any user interested in session-specific volume dynamics. Its design emphasizes clarity, modularity, and customization flexibility so that users can adapt the visualization to their preferred workflow.

In summary, Path-Based Session Volume Profile provides a structured, session-oriented visualization of price–volume interaction using a path-aware distribution method, enabling objective analysis of market participation within defined trading sessions.

📐 Core Concept

The core concept of Path-Based Session Volume Profile is to represent session-level volume distribution using a path-aware allocation model instead of a simplified single-price assignment approach.

Traditional volume profile methods often allocate an entire candle’s volume to one reference price (such as the close, typical price, or midpoint). While computationally efficient, that method may not fully reflect the internal price traversal that occurred during the bar. This script introduces a structured distribution model that considers the Open–High–Low–Close (OHLC) path to distribute volume across multiple price levels inside each candle’s range.

1️⃣ Session-Based Data Accumulation

At the start of a defined trading session, the script initializes a price grid composed of fixed-height rows. These rows act as containers for accumulating volume data.

As each confirmed bar closes within the session:

The candle’s high–low range is mapped against the predefined price rows.
Only the rows intersecting the candle’s price range participate in volume allocation.
The session matrix is updated incrementally rather than recalculated from scratch.

This process continues until the session ends, at which point the final distribution represents the cumulative session profile.

2️⃣ Path-Aware Volume Distribution Logic

Instead of assigning total volume to a single price point, the script distributes volume proportionally across the price levels traversed by the candle.

The internal logic follows these structural ideas:

The candle’s total range (High − Low) is divided into segments aligned with profile rows.
Volume is proportionally distributed based on how much of the candle overlaps each price row.
This results in a multi-level allocation rather than a single-node assignment.

By doing so, the indicator attempts to reduce concentration bias that can occur when all volume is attributed to a single reference price.

This is not a tick-level reconstruction and does not simulate actual transaction flow. Instead, it is a structured approximation based strictly on available OHLC data.

3️⃣ Development of Structural Reference Points

As volume accumulates across price rows during the session, structural reference levels are derived:

Point of Control (POC): The row containing the highest accumulated volume.
Value Area: A percentage-based range around the POC representing a specified share of total session volume.
High and Low Volume Zones: Areas where participation is relatively concentrated or comparatively light.

These levels update dynamically during the session and stabilize once the session completes.

4️⃣ Incremental Update Model

The script operates using an incremental accumulation model:

At each confirmed bar close, new volume is added to the session matrix.
Historical rows remain intact and are not retroactively modified beyond logical recalculation.
The profile visually evolves throughout the session, allowing users to observe structural development.

This approach ensures consistency between historical and real-time behavior.

5️⃣ Design Philosophy

The design philosophy behind this indicator emphasizes:

Structural clarity over signal generation
Objective visualization over predictive modeling
Session-specific context rather than full-chart aggregation

It does not attempt to forecast market direction, guarantee outcomes, or replicate order book data. Instead, it provides a systematic framework for observing how volume is distributed across price within a defined session window.

Conceptual Summary

In essence, the core concept is built on three foundations:

Session isolation – Volume is segmented strictly within defined session boundaries.
Path-based allocation – Volume is distributed across price levels using OHLC range overlap.
Structural extraction – Key reference levels (POC, value range, participation clusters) are derived from accumulated session data.

This structure allows users to analyze price–volume interaction within a session using a method that extends beyond single-price volume assignment, while remaining grounded in available bar data.

⚙️ How to Use

The Path-Based Session Volume Profile is designed as a structural analysis tool. It is not intended to generate automated trade signals or directional forecasts. Instead, it provides session-based volume context that users may incorporate into their own analytical framework.

Below is a structured guide on how the tool can be applied effectively.

1️⃣ Select the Appropriate Session

Begin by defining the trading session you want to analyze (for example: regular market hours, London session, New York session, or a custom intraday window).

Each session is treated independently. The profile:

Resets at the beginning of the selected session
Accumulates volume only within that session
Stops updating once the session closes

Using clearly defined sessions allows you to evaluate participation dynamics specific to that market period.

2️⃣ Observe the Developing Profile During the Session

As the session progresses, the profile builds incrementally.

Users can monitor:

Where volume is gradually concentrating
Whether the Point of Control (POC) is shifting upward or downward
How the Value Area expands or contracts

The developing profile can provide structural context about how participation is evolving, rather than waiting for the session to complete.

It is important to interpret this as structural information, not as a standalone trading signal.

3️⃣ Analyze High and Low Volume Zones

The profile highlights relative volume concentration across price levels.

Users may study:

High Volume Nodes (HVNs) as areas where price previously experienced sustained interaction
Low Volume Zones (LVNs) as areas of comparatively lighter participation

These areas can be used to evaluate how price behaves when revisiting prior session structure. However, outcomes are not guaranteed, and interpretation should remain contextual.

4️⃣ Use the Point of Control (POC) as a Structural Reference

The POC represents the price row with the highest accumulated volume during the session.

Traders may observe:

Whether price remains near the POC (indicating balance-like behavior)
Whether price moves away from the POC and fails to return
Whether the POC shifts significantly during the session

The POC is best used as a reference level within broader market structure analysis rather than as an isolated decision trigger.

5️⃣ Evaluate the Value Area (VAH & VAL)

The Value Area defines a percentage-based region around the POC that contains the majority of session volume.

Users may examine:

Whether price trades inside or outside the Value Area
How price reacts when re-entering the Value Area
Whether the session appears rotational (within value) or directional (outside value)

Again, this should be interpreted as contextual structure rather than predictive confirmation.

6️⃣ Integrate With Your Existing Strategy

This indicator is designed to complement—not replace—other analytical methods.

It can be combined with:

Market structure analysis
Liquidity zone identification
Breakout or range-based strategies
Multi-timeframe bias evaluation

The volume profile provides structural context that may enhance decision-making, but it should not be treated as a complete trading system on its own.

7️⃣ Adjust Settings to Fit Your Workflow

Users may customize:

Number of price rows (profile resolution)
Value Area percentage
Visual styling preferences
Session timing inputs
Higher row counts may provide more granular distribution, while lower counts may improve clarity and performance on lower-powered devices.
Adjust these settings according to your chart timeframe and personal workflow preferences.

Practical Usage Considerations

The profile reflects approximated distribution based on OHLC data, not tick-level transaction data.
Real-time structure may evolve until the session completes.
Historical sessions remain fixed once completed.
The tool does not provide entry/exit instructions or financial advice.

Summary

To use the Path-Based Session Volume Profile effectively:
Define your session clearly.
Monitor developing structure during the session.
Observe POC, Value Area, and volume concentration shifts.
Integrate these observations into a broader analytical framework.
The indicator’s primary purpose is to provide structured visibility into session-level price–volume interaction, allowing users to analyze participation dynamics within defined market windows.

⚙️ How It Works

The Path-Based Session Volume Profile operates using a structured, session-isolated accumulation engine that distributes volume across price levels using OHLC-based range overlap logic. The internal workflow can be understood in five core stages:

1️⃣ Session Initialization

When a new user-defined session begins:

The script identifies the session start timestamp.
All previous session data is finalized.
A fresh internal volume matrix is initialized.
A fixed price grid (rows) is created to segment the session’s price range.

Each row represents a defined price interval. These rows act as containers that will accumulate volume as the session progresses.

The profile is therefore isolated strictly within session boundaries and does not mix volume across sessions.

2️⃣ Dynamic Price Range Tracking

During the session:

The script continuously tracks the evolving session high and session low.
If a new extreme is formed, the internal price boundaries adjust.
The row grid recalibrates logically to maintain structural consistency.

This ensures that the profile remains aligned with the true price range of the active session rather than a static predefined range.

3️⃣ Path-Based Volume Allocation Per Bar

When a bar closes inside the session:

The candle’s high–low range is identified.
The script determines which price rows intersect with that range.
Instead of assigning total volume to a single price point, the script distributes volume proportionally across all overlapping rows.

The proportional allocation is based on:

The size of overlap between the candle’s range and each price row.
The total range of the candle.

This produces a segmented volume distribution across price levels rather than a single concentration node.

Important clarification:

This method is an OHLC-based approximation.
It does not reconstruct tick-by-tick execution data or actual order flow.
It distributes volume logically based on available bar data only.

4️⃣ Incremental Accumulation Model

After distribution:

The allocated volume is added to each corresponding row’s cumulative total.
Previously accumulated rows remain unchanged except for new additions.
The matrix grows progressively throughout the session.

This incremental structure ensures:

Stability between historical and real-time behavior
No reliance on forward-looking data
Logical consistency across bars

The developing profile updates only as new confirmed bars close.

5️⃣ Structural Level Derivation

Once the volume matrix updates, structural reference levels are computed:

▪ Point of Control (POC)

The row containing the highest accumulated volume becomes the session’s POC.

This level may shift during the session as distribution evolves.

▪ Value Area (VAH & VAL)

The script calculates a user-defined percentage (commonly 70%) of total session volume.

It then:

Expands outward from the POC
Includes adjacent rows
Stops once the target percentage threshold is reached

The upper boundary becomes the Value Area High (VAH).
The lower boundary becomes the Value Area Low (VAL).

▪ High and Low Participation Zones

By comparing relative row totals, the script visually distinguishes:

Higher concentration clusters
Comparatively lighter participation zones

These are descriptive structural outputs, not predictive signals.

6️⃣ Session Completion

When the session ends:

Accumulation stops.
Structural levels stabilize.
The profile becomes fixed for that session.

A new session triggers a complete reset and the process repeats independently.

Technical Design Characteristics

The internal architecture emphasizes:

Session isolation
Path-aware proportional allocation
Incremental accumulation
Deterministic level calculation

The script does not:

Use future bars
Modify past completed sessions
Provide trade automation
Guarantee market behavior

It is a visualization framework built on available OHLC and volume data.

Conceptual Summary

In simplified terms, the workflow is:

Create session grid
Track evolving session range
Distribute each bar’s volume across overlapped price rows
Accumulate totals incrementally
Derive structural reference levels
Finalize profile at session end

The result is a session-based structural representation of how volume is distributed across price using a path-aware allocation method grounded in confirmed bar data.

🎯 Key Features
📊 Session-Based Volume Isolation

The Path-Based Session Volume Profile is built to provide a structured view of volume distribution within a defined trading session by combining session isolation with a path-aware allocation model. Instead of assigning volume to a single price reference such as the close or typical price, the script distributes each bar’s volume across multiple price levels based on how the candle’s high–low range interacts with a predefined price grid. This allows the indicator to present a more granular representation of where participation may have occurred during the session, strictly using available OHLC and volume data.

🔄 Independent Session Processing

A core feature of the script is its session-based isolation system. Each session is treated independently, meaning volume data is accumulated only within the selected time window and does not carry over into other sessions. At the start of a new session, all internal calculations reset, ensuring that each profile reflects only that specific market period. This structure allows users to analyze volume behavior in a clean, segmented format that is aligned with intraday or session-based trading workflows.

📈 Developing Profile Structure

The indicator also features a developing profile mechanism, where volume distribution is updated incrementally as each bar closes. This allows the profile to evolve in real time, showing how volume concentration shifts during the session rather than only presenting a finalized end-of-session structure. As new bars are confirmed, the internal matrix is updated and structural levels are recalculated accordingly, providing continuous feedback on session development.

🎯 Point of Control (POC) Behavior

Another important component is the Point of Control (POC), which is derived from the price level containing the highest accumulated volume within the session. This level is not static during the session and may shift as new volume is added, reflecting changes in participation distribution. Once the session concludes, the final POC stabilizes and represents the completed session’s highest activity zone.

📐 Value Area Calculation (VAH & VAL)

The script also calculates a configurable Value Area based on a user-defined percentage of total session volume. Starting from the POC, the Value Area expands outward until the specified volume threshold is reached, forming upper and lower boundaries known as the Value Area High (VAH) and Value Area Low (VAL). These levels represent the portion of the session where a majority of activity is concentrated, based purely on accumulated volume distribution.

🧭 Volume Concentration Zones

In addition to these core levels, the profile visually distinguishes areas of relatively higher and lower participation across price. These zones are derived from comparative volume density across rows and help represent structural variation within the session. Higher concentration areas and lower participation zones are displayed as part of the overall profile structure, without implying directional bias or predictive significance.

⚙️ Customization and Flexibility

The script is also designed with flexibility in mind, allowing users to adjust the number of price rows, visual style, and session parameters according to their trading environment. This makes it adaptable across different instruments and timeframes, from lower timeframe intraday charts to higher timeframe session analysis.

🧠 Design Philosophy

Overall, the key features focus on presenting a session-based, structurally consistent view of volume distribution using a deterministic, OHLC-based allocation model. The indicator emphasizes transparency, modularity, and analytical context rather than prediction or automated decision-making, making it suitable for users who study market structure and volume behavior within defined trading sessions.

⚙️ Settings & Customization

The Path-Based Session Volume Profile provides a highly configurable settings structure that allows users to adapt the indicator’s behavior, visual output, and session logic according to different trading styles, instruments, and timeframe requirements. The customization system is designed to modify how the profile is displayed and how data is interpreted visually, without changing the core calculation logic of the volume distribution engine.

📊 Profile Mode Configuration

The indicator offers two primary operational modes: Session Mode and Fixed Range Mode. In Session Mode, the profile automatically resets at the beginning of each defined trading session and builds continuously until the session ends. This mode is typically used for intraday analysis where each session represents a distinct market period. In Fixed Range Mode, users can manually define a start and end timestamp, allowing the profile to be constructed over a custom-selected range rather than an automatically detected session. This provides flexibility for analyzing specific price movements or historical events within a defined time window.

🕒 Session Timing Controls

In Fixed Range Mode, users can define both the start and end time of the analysis window. These inputs determine the exact portion of price data included in the profile calculation. If only a start time is defined, the profile continues until manually stopped or until the chart data ends. This allows partial or open-ended analysis depending on user preference. These controls are particularly useful for isolating specific market events, volatility expansions, or reaction periods around key levels.

📐 Number of Rows (Profile Resolution)

The Number of Rows setting defines the vertical resolution of the volume profile. Each row represents a fixed price interval within the session’s high–low range. Increasing the number of rows results in a more detailed and granular distribution of volume across price levels, while reducing the number of rows produces a smoother and more simplified structure. This setting directly affects how detailed the volume concentration visualization appears and should be adjusted based on chart timeframe and analysis depth.

📍 Profile Placement Control

The Placement setting allows users to choose whether the profile is drawn on the left or right side of the chart. This does not affect the underlying calculations but changes the visual alignment of the profile relative to price action. Right-side placement is commonly used for real-time analysis, while left-side placement may be preferred for comparative or historical visual structuring.

🎨 Visual Style Modes

The indicator provides two main visualization styles: Split Volume and Delta Heatmap. In Split Volume mode, buy and sell volume are visually separated within each price row, allowing users to observe relative participation balance. In Delta Heatmap mode, the script emphasizes the difference between buying and selling pressure within each row, using intensity-based shading to represent dominance. These modes offer different perspectives on the same underlying volume data without altering the core distribution logic.

🌈 Color Customization System

Users can fully customize the visual appearance of the profile through a flexible color input system. Separate colors are assigned to buy volume, sell volume, Point of Control (POC), Value Area boundaries, High Volume Nodes (HVN), and Low Volume Nodes (LVN). This allows traders to visually distinguish different structural elements of the profile according to their preference or visual clarity needs. Adjusting colors does not impact calculations and is purely for readability and chart integration.

🌫️ Transparency & Heatmap Sensitivity

The Base Transparency (bgAlpha) setting controls the overall opacity of volume nodes, allowing users to emphasize or soften the visual intensity of the profile. Lower values create more solid visual blocks, while higher values produce a lighter appearance. The optional Heatmap Mode dynamically adjusts transparency based on relative volume density, meaning high-activity zones appear more prominent while low-activity areas become more transparent. This enhances structural contrast without altering underlying data.

📊 Value Area Percentage Control

The Value Area setting defines what portion of total session volume is used to construct the Value Area High (VAH) and Value Area Low (VAL). The default value is typically set around 70%, but users can adjust it between 50% and 90%. A higher percentage expands the value area to include more of the session’s volume distribution, while a lower percentage creates a more concentrated and narrow value zone around the Point of Control.

📌 Structural Display Toggles

Users can enable or disable multiple structural elements such as the developing POC, final POC line, Value Area boundaries, and HVN/LVN zones. These toggles allow traders to simplify or enrich the visual output depending on their analysis requirements. For example, some users may prefer only POC and Value Area visibility, while others may activate full structural visualization for deeper market context.

🧠 Customization Philosophy

The customization system is designed to support flexibility without altering the core logic of the indicator. All settings influence visual representation or session boundaries, while the underlying OHLC-based path distribution model remains consistent. This ensures that analytical integrity is preserved while allowing users to tailor the indicator to different markets, timeframes, and personal trading workflows.

🧠 Design Rationale & Component Interaction (How Everything Works Together)

The Path-Based Session Volume Profile combines multiple analytical components into a single structured framework to represent session-based volume distribution in a more detailed and layered form. Each feature is not designed in isolation; instead, all modules operate on the same underlying dataset (OHLC + Volume) and contribute to a unified session profile representation.

The reason these elements are combined is to move from a simple volume-at-price representation toward a structured session model that reflects different dimensions of participation: distribution, concentration, balance, and relative strength across price levels.

📊 1️⃣ Core Engine: Path-Based Volume Distribution

At the foundation of the script is the path-based allocation engine, which distributes each candle’s volume across multiple price rows based on OHLC range interaction. This is the primary data transformation layer.

All other features depend on this stage because it creates the base structure of:

Volume per price level
Session-wide accumulation matrix
Relative participation across rows

Without this layer, the indicator would reduce to a simple single-price volume aggregation, which would lose internal structure.

🧩 2️⃣ Session-Based Segmentation Layer

Session logic acts as a boundary system that isolates data into distinct time windows. This ensures that:

Each session is processed independently
Volume does not mix across different market periods
Structural calculations remain context-specific

This layer is essential because volume profile interpretation is highly dependent on time segmentation. Without session separation, structural levels like POC and Value Area would lose contextual meaning.

🎯 3️⃣ Point of Control (POC) Calculation Layer

The POC is derived from the same volume matrix created by the distribution engine. It identifies the price row with the highest accumulated participation.

It works as:

A reference equilibrium level of the session
A dynamic output during session formation
A stabilized structural level after session completion

The POC does not operate independently; it is a direct result of the aggregated distribution process.

📐 4️⃣ Value Area Construction Layer (VAH / VAL)

The Value Area is built on top of the same cumulative volume data used for POC calculation. It expands outward from the POC until a defined percentage of total volume is included.

This means:

It depends entirely on the existing distribution matrix
It uses cumulative row volumes as input
It defines a bounded region of high participation

This layer provides a secondary structural boundary around the POC, representing concentration range rather than a single level.

🧭 5️⃣ Volume Concentration Classification (HVN / LVN Logic)

High Volume Nodes (HVN) and Low Volume Nodes (LVN) are derived by comparing adjacent row volumes within the same distribution structure.

They function as:

Relative peaks and troughs within the session profile
Structural variation indicators across price levels
Contextual zones of interest, not standalone signals

These elements do not introduce new data; they analyze the same dataset from a comparative perspective.

📈 6️⃣ Developing Profile Layer

The developing profile system continuously updates the same underlying matrix as new bars close. This ensures:

Real-time structural evolution
Progressive refinement of POC and Value Area
Live reflection of market participation changes

This layer is not separate from the core engine; it is a temporal update mechanism applied to the same dataset.

🎨 7️⃣ Visualization Layer (Heatmap / Split View)

The visual system is a presentation layer built on top of calculated data. It does not affect calculations but changes how results are displayed:

Split Volume shows directional distribution (buy vs sell approximation)
Delta Heatmap shows imbalance intensity visually
Color and transparency reflect relative participation

This layer only enhances readability and does not modify logic.

🔗 How All Components Work Together

All parts of the script are connected through a single flow:

OHLC + Volume data is collected per bar
Path-based logic distributes volume across price rows
A cumulative session matrix is built
POC is extracted from highest volume concentration
Value Area is derived around POC using cumulative thresholds
HVN/LVN zones are identified through relative comparisons
Visualization layer renders the structure dynamically

Each module is dependent on the same underlying dataset, but each serves a different analytical purpose within the session structure.

🧠 Design Logic Summary

These components are combined because the goal is not to create separate indicators, but to build a unified session-based volume framework. Each layer adds a different perspective on the same data:

Distribution → where activity occurred
POC → where maximum acceptance occurred
Value Area → where majority participation occurred
HVN/LVN → how structure varies across price
Development → how structure evolves over time

Together, they form a structured view of session-based market participation using only OHLC and volume data, without predictive assumptions or external data sources.

⚠️ Disclaimer

The Path-Based Session Volume Profile is a technical analysis tool designed to visualize and structure volume distribution across price levels within a defined trading session. It is based entirely on historical and real-time OHLC (Open, High, Low, Close) data and volume data provided by the trading platform. The calculations performed by this script are deterministic and rely strictly on available market data without using any forward-looking information.

This indicator is developed for educational and analytical purposes only. It is intended to help users better understand how volume may be distributed across price levels within a session and how structural elements such as Point of Control (POC), Value Area (VAH/VAL), and volume concentration zones are formed. It does not generate trading signals, does not provide financial advice, and does not recommend any buy or sell decisions.

All outputs shown by the indicator represent derived calculations based on historical price movement and volume activity. These outputs should be interpreted as contextual market structure information rather than predictive indicators of future price behavior. Market conditions are dynamic, and past volume distribution does not guarantee or imply any future performance, outcome, or market direction.

The script does not use tick-level order flow data, broker-level execution data, or any external order book information. Instead, it uses an OHLC-based approximation method to distribute volume across price levels. As such, the results should be understood as a structured representation of market activity rather than a precise reconstruction of actual traded volume at each price.

Users are solely responsible for any trading or investment decisions made based on this indicator. It is strongly recommended that this tool be used in combination with other forms of analysis, risk management techniques, and personal judgment. No indicator or analytical tool can eliminate risk or ensure profitability in financial markets.

Under no circumstances should this script be considered a guaranteed or accurate predictor of market behavior. All trading involves risk, including the possible loss of capital, and users should fully understand these risks before making any trading decisions.

By using this indicator, the user acknowledges that it is provided “as is,” without any warranties of performance, accuracy, or fitness for a particular purpose. The developer assumes no responsibility or liability for any financial losses or decisions made based on its output.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/

//@version=5
indicator("Path-Based Session Volume Profile [CLEVER]", shorttitle="PBSVP", overlay=true, max_boxes_count=500, max_lines_count=500)

// ══════════════════════════════════════════════════════════════════════════════
// ⚙️ SETTINGS
// ══════════════════════════════════════════════════════════════════════════════
grp_core = "═══ 📊 PROFILE SETTINGS ═══"
profMode = input.string("Session", "Profile Mode", options=["Session", "Fixed Range"], group=grp_core)
frStart  = input.time(0, "Fixed Range Start", confirm=true, group=grp_core, tooltip="Only active in Fixed Range Mode")
frEnd    = input.time(0, "Fixed Range End", confirm=true, group=grp_core, tooltip="Only active in Fixed Range Mode")
numRows  = input.int(24, "Number of Rows", minval=8, maxval=100, group=grp_core)
placeSide = input.string("Right", "Profile Placement", options=["Left", "Right"], group=grp_core)
visMode   = input.string("Split Volume", "Visual Style", options=["Split Volume", "Delta Heatmap"], group=grp_core)
showDPOC = input.bool(true, "Developing POC Tracking", group=grp_core)
showPOC  = input.bool(true, "Show POC Line", group=grp_core)
showVAH  = input.bool(true, "Show VAH / VAL", group=grp_core)
showNodes    = input.bool(true, "Show HVN / LVN Zones", group=grp_core)
showOverlay  = input.bool(false, "Overlay Previous Profile", group=grp_core)
showPrevLvls = input.bool(true, "Extend Previous VAH/VAL/POC", group=grp_core)
valuePct     = input.float(70, "Value Area %", minval=50, maxval=90, step=5, group=grp_core)

grp_col = "═══ 🎨 COLORS ═══"
colBuy   = input.color(#00BCD4, "Buy Volume Color", group=grp_col)
colSell  = input.color(#E91E63, "Sell Volume Color", group=grp_col)
colPOC   = input.color(#FFD600, "POC Line Color", group=grp_col, tooltip="Using Yellow for better dark mode visibility") 
colVA    = input.color(#FF6F00, "Value Area Color", group=grp_col)
colHVN   = input.color(#00BCD4, "HVN Zone Color", group=grp_col)
colLVN   = input.color(#E91E63, "LVN Zone Color", group=grp_col)
bgAlpha  = input.int(40, "Base Transparency", minval=0, maxval=100, group=grp_col, tooltip="Opacity for the thickest volume nodes (POC). 0 is solid, 100 invisible.")
useHeatmap = input.bool(true, "Heatmap-Style Shading", group=grp_col, tooltip="Vary row transparency dynamically based on volume density.")

// ══════════════════════════════════════════════════════════════════════════════
// 🕐 SESSION DETECTION
// ══════════════════════════════════════════════════════════════════════════════
var string tf = timeframe.isintraday ? "D" : timeframe.isdaily ? "M" : "12M"

int pStart = frStart == 0 ? 0 : (frEnd == 0 ? frStart : math.min(frStart, frEnd))
int pEnd   = frEnd == 0 ? 0 : (frStart == 0 ? frEnd : math.max(frStart, frEnd))

bool inFixedRange = profMode == "Fixed Range" and pStart != 0 and time >= pStart and (pEnd == 0 or time <= pEnd)
bool fixedRangeStart = profMode == "Fixed Range" and pStart != 0 and time >= pStart and time[1] < pStart

bool isNewSession = profMode == "Session" ? ta.change(time(tf)) != 0 : fixedRangeStart

// ══════════════════════════════════════════════════════════════════════════════
// 📊 SESSION DATA TYPES & STORAGE
// ══════════════════════════════════════════════════════════════════════════════
type SessionData
    float[] closes
    float[] opens
    float[] highs
    float[] lows
    float[] volumes
    int startBar
    int endBar
    float highPrice
    float lowPrice

method clone(SessionData data) =>
    SessionData.new(array.copy(data.closes), array.copy(data.opens), array.copy(data.highs), array.copy(data.lows), array.copy(data.volumes), data.startBar, data.endBar, data.highPrice, data.lowPrice)

var SessionData curSess = SessionData.new(array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_float(), bar_index, bar_index, high, low)
var SessionData prevSess = na

var box[] histBoxes = array.new_box()
var line[] histLines = array.new_line()

var box[] liveBoxes = array.new_box()
var line[] liveLines = array.new_line()

// ══════════════════════════════════════════════════════════════════════════════
// 🧹 UTILITY FUNCTIONS
// ══════════════════════════════════════════════════════════════════════════════
clearLive() =>
    while array.size(liveBoxes) > 0
        box.delete(array.pop(liveBoxes))
    while array.size(liveLines) > 0
        line.delete(array.pop(liveLines))

cleanHist(int maxB) =>
    while array.size(histBoxes) > maxB
        box.delete(array.shift(histBoxes))
    while array.size(histLines) > maxB
        line.delete(array.shift(histLines))

// ══════════════════════════════════════════════════════════════════════════════
// 📊 PROFILE CALCULATION
// ══════════════════════════════════════════════════════════════════════════════
method calcProfile(SessionData data) =>
    float[] bVols = array.new_float(numRows, 0)
    float[] sVols = array.new_float(numRows, 0)
    float rowH = 0.0
    int pocIdx = 0
    float maxRowVol = 0.0
    float totalVol = 0.0
    
    if data.highPrice > data.lowPrice and array.size(data.volumes) > 0
        rowH := (data.highPrice - data.lowPrice) / numRows
        
        // 1. True volume distribution over collected arrays (order-book style OHLC weight split)
        for i = 0 to array.size(data.volumes) - 1
            c = array.get(data.closes, i)
            o = array.get(data.opens, i)
            h = array.get(data.highs, i)
            l = array.get(data.lows, i)
            v = array.get(data.volumes, i)
            
            if h == l
                idx = int(math.max(0, math.min(numRows - 1, math.floor((c - data.lowPrice) / rowH))))
                buyV = c > o ? v : (c == o ? v * 0.5 : 0.0)
                sellV = c < o ? v : (c == o ? v * 0.5 : 0.0)
                array.set(bVols, idx, array.get(bVols, idx) + buyV)
                array.set(sVols, idx, array.get(sVols, idx) + sellV)
            else
                // OHLC Intra-bar Path Approximation
                float d1 = 0.0
                float d2 = 0.0
                float d3 = 0.0
                float p0 = 0.0
                float p1 = 0.0
                float p2 = 0.0
                float p3 = 0.0
                bool up1 = false
                bool up2 = false
                bool up3 = false
                
                if c >= o
                    // Positive/Doji candle: Open -> Low -> High -> Close
                    p0 := o
                    p1 := l
                    p2 := h
                    p3 := c
                    d1 := o - l
                    d2 := h - l
                    d3 := h - c
                    up1 := false
                    up2 := true
                    up3 := false
                else
                    // Negative candle: Open -> High -> Low -> Close
                    p0 := o
                    p1 := h
                    p2 := l
                    p3 := c
                    d1 := h - o
                    d2 := h - l
                    d3 := c - l
                    up1 := true
                    up2 := false
                    up3 := true
                    
                float pathTot = d1 + d2 + d3
                
                // Segment 1
                if d1 > 0
                    v1 = v * (d1 / pathTot)
                    sBot1 = math.min(p0, p1)
                    sTop1 = math.max(p0, p1)
                    startIdx1 = int(math.max(0, math.floor((sBot1 - data.lowPrice) / rowH)))
                    endIdx1 = int(math.min(numRows - 1, math.floor((sTop1 - data.lowPrice) / rowH)))
                    for j = startIdx1 to endIdx1
                        rowBot = data.lowPrice + j * rowH
                        rowTop = rowBot + rowH
                        overlap = math.max(0, math.min(sTop1, rowTop) - math.max(sBot1, rowBot))
                        if overlap > 0
                            cellV = v1 * (overlap / d1)
                            if up1
                                array.set(bVols, j, array.get(bVols, j) + cellV)
                            else
                                array.set(sVols, j, array.get(sVols, j) + cellV)
                
                // Segment 2
                if d2 > 0
                    v2 = v * (d2 / pathTot)
                    sBot2 = math.min(p1, p2)
                    sTop2 = math.max(p1, p2)
                    startIdx2 = int(math.max(0, math.floor((sBot2 - data.lowPrice) / rowH)))
                    endIdx2 = int(math.min(numRows - 1, math.floor((sTop2 - data.lowPrice) / rowH)))
                    for j = startIdx2 to endIdx2
                        rowBot = data.lowPrice + j * rowH
                        rowTop = rowBot + rowH
                        overlap = math.max(0, math.min(sTop2, rowTop) - math.max(sBot2, rowBot))
                        if overlap > 0
                            cellV = v2 * (overlap / d2)
                            if up2
                                array.set(bVols, j, array.get(bVols, j) + cellV)
                            else
                                array.set(sVols, j, array.get(sVols, j) + cellV)

                // Segment 3
                if d3 > 0
                    v3 = v * (d3 / pathTot)
                    sBot3 = math.min(p2, p3)
                    sTop3 = math.max(p2, p3)
                    startIdx3 = int(math.max(0, math.floor((sBot3 - data.lowPrice) / rowH)))
                    endIdx3 = int(math.min(numRows - 1, math.floor((sTop3 - data.lowPrice) / rowH)))
                    for j = startIdx3 to endIdx3
                        rowBot = data.lowPrice + j * rowH
                        rowTop = rowBot + rowH
                        overlap = math.max(0, math.min(sTop3, rowTop) - math.max(sBot3, rowBot))
                        if overlap > 0
                            cellV = v3 * (overlap / d3)
                            if up3
                                array.set(bVols, j, array.get(bVols, j) + cellV)
                            else
                                array.set(sVols, j, array.get(sVols, j) + cellV)
                        
        // 2. Identify max volume row (Point of Control)
        for i = 0 to numRows - 1
            rV = array.get(bVols, i) + array.get(sVols, i)
            totalVol += rV
            if rV > maxRowVol
                maxRowVol := rV
                pocIdx := i
                
    [bVols, sVols, pocIdx, totalVol, maxRowVol, rowH]


// ══════════════════════════════════════════════════════════════════════════════
// 📐 DRAWING FUNCTION
// ══════════════════════════════════════════════════════════════════════════════
method drawProfile(SessionData data, bool isLive, int customStart = na, int customEnd = na, bool isOverlay = false) =>
    [bVols, sVols, pocIdx, totalVol, maxRowVol, rowH] = data.calcProfile()
    
    if maxRowVol > 0
        sBar = na(customStart) ? data.startBar : customStart
        eBar = na(customEnd) ? data.endBar : customEnd
        sessionBars = math.max(1, eBar - sBar)
        
        // 3. Draw rows
        for i = 0 to numRows - 1
            bv = array.get(bVols, i)
            sv = array.get(sVols, i)
            rowTotal = bv + sv
            if rowTotal > 0
                pct = rowTotal / maxRowVol
                // Dynamic width limited to 70% of session width to leave visual gap
                totalBarW = math.max(1, math.round(pct * sessionBars * 0.70))
                buyBarW = math.max(0, math.round(totalBarW * (bv / rowTotal)))
                sellBarW = math.max(0, totalBarW - buyBarW)
                
                rowBot = data.lowPrice + i * rowH
                rowTop = rowBot + rowH
                
                rowAlpha = isOverlay ? 85 : (useHeatmap ? int(math.max(bgAlpha, math.min(92, 92 - (92 - bgAlpha) * math.sqrt(pct)))) : bgAlpha)
                
                if visMode == "Delta Heatmap"
                    delta = bv - sv
                    deltaPct = math.abs(delta) / rowTotal
                    // Delta transparency scale: 100% delta = highly visible/solid, near 0% delta = highly transparent
                    deltaAlpha = int(math.max(10, math.min(90, 90 - (80 * deltaPct))))
                    finalAlpha = isOverlay ? 85 : (useHeatmap ? int(math.max(rowAlpha, deltaAlpha - 10)) : deltaAlpha)
                    boxColor = delta > 0 ? color.new(colBuy, finalAlpha) : color.new(colSell, finalAlpha)
                    
                    if isOverlay
                        boxColor := color.new(color.gray, 85)
                    
                    if placeSide == "Left"
                        bx = box.new(sBar, rowTop, sBar + totalBarW, rowBot, bgcolor=boxColor, border_color=na)
                        if isLive
                            array.push(liveBoxes, bx)
                        else
                            array.push(histBoxes, bx)
                    else
                        bx = box.new(eBar - totalBarW, rowTop, eBar, rowBot, bgcolor=boxColor, border_color=na)
                        if isLive
                            array.push(liveBoxes, bx)
                        else
                            array.push(histBoxes, bx)
                else
                    curColBuy = isOverlay ? color.new(color.gray, rowAlpha) : color.new(colBuy, rowAlpha)
                    curColSell = isOverlay ? color.new(color.gray, rowAlpha) : color.new(colSell, rowAlpha)
                    
                    if placeSide == "Left"
                        if buyBarW > 0
                            bx = box.new(sBar, rowTop, sBar + buyBarW, rowBot, bgcolor=curColBuy, border_color=na)
                            if isLive
                                array.push(liveBoxes, bx)
                            else
                                array.push(histBoxes, bx)
                        if sellBarW > 0
                            bx2 = box.new(sBar + buyBarW, rowTop, sBar + buyBarW + sellBarW, rowBot, bgcolor=curColSell, border_color=na)
                            if isLive
                                array.push(liveBoxes, bx2)
                            else
                                array.push(histBoxes, bx2)
                    else // Right
                        if buyBarW > 0
                            bx = box.new(eBar - buyBarW - sellBarW, rowTop, eBar - sellBarW, rowBot, bgcolor=curColBuy, border_color=na)
                            if isLive
                                array.push(liveBoxes, bx)
                            else
                                array.push(histBoxes, bx)
                        if sellBarW > 0
                            bx2 = box.new(eBar - sellBarW, rowTop, eBar, rowBot, bgcolor=curColSell, border_color=na)
                            if isLive
                                array.push(liveBoxes, bx2)
                            else
                                array.push(histBoxes, bx2)
            
        // 4. Draw POC Line
        if showPOC and not isOverlay
            pocPrice = data.lowPrice + pocIdx * rowH + (rowH / 2)
            pocL = line.new(sBar, pocPrice, eBar, pocPrice, color=colPOC, width=2)
            if isLive
                array.push(liveLines, pocL)
            else
                array.push(histLines, pocL)
                
        // 5. Draw Value Area (VAH / VAL)
        if showVAH and not isOverlay
            targetVol = totalVol * (valuePct / 100)
            cumVol = array.get(bVols, pocIdx) + array.get(sVols, pocIdx)
            upperIdx = pocIdx
            lowerIdx = pocIdx
            while cumVol < targetVol and (upperIdx < numRows - 1 or lowerIdx > 0)
                addU = upperIdx < numRows - 1 ? (array.get(bVols, upperIdx + 1) + array.get(sVols, upperIdx + 1)) : 0.0
                addL = lowerIdx > 0 ? (array.get(bVols, lowerIdx - 1) + array.get(sVols, lowerIdx - 1)) : 0.0
                if addU >= addL and upperIdx < numRows - 1
                    upperIdx += 1
                    cumVol += addU
                else if lowerIdx > 0
                    lowerIdx -= 1
                    cumVol += addL
                else
                    break
            
            vahP = data.lowPrice + (upperIdx + 1) * rowH
            valP = data.lowPrice + lowerIdx * rowH
            
            vahL = line.new(sBar, vahP, eBar, vahP, color=colVA, width=1, style=line.style_dashed)
            valL = line.new(sBar, valP, eBar, valP, color=colVA, width=1, style=line.style_dashed)
            if isLive
                array.push(liveLines, vahL)
                array.push(liveLines, valL)
            else
                array.push(histLines, vahL)
                array.push(histLines, valL)
                
        // 6. Draw HVN / LVN Zones
        if showNodes and not isOverlay
            for i = 1 to numRows - 2
                prevV = array.get(bVols, i - 1) + array.get(sVols, i - 1)
                currV = array.get(bVols, i) + array.get(sVols, i)
                nextV = array.get(bVols, i + 1) + array.get(sVols, i + 1)
                
                isPeak = currV > prevV and currV > nextV
                isValley = currV < prevV and currV < nextV
                
                // Exclude the actual POC from being highlighted as a regular HVN
                if isPeak and currV >= (maxRowVol * 0.65) and i != pocIdx
                    rowBot = data.lowPrice + i * rowH
                    rowTop = rowBot + rowH
                    hB = box.new(sBar, rowTop, eBar, rowBot, bgcolor=color.new(colHVN, 85), border_color=color.new(colHVN, 60), border_style=line.style_dotted)
                    if isLive
                        array.push(liveBoxes, hB)
                    else
                        array.push(histBoxes, hB)
                        
                if isValley and currV <= (maxRowVol * 0.40)
                    rowBot = data.lowPrice + i * rowH
                    rowTop = rowBot + rowH
                    lB = box.new(sBar, rowTop, eBar, rowBot, bgcolor=color.new(colLVN, 90), border_color=color.new(colLVN, 70), border_style=line.style_dotted)
                    if isLive
                        array.push(liveBoxes, lB)
                    else
                        array.push(histBoxes, lB)

// ══════════════════════════════════════════════════════════════════════════════
// 🔄 MAIN EXECUTION LOOP
// ══════════════════════════════════════════════════════════════════════════════

if isNewSession
    // 1. Draw completed history session properly
    if bar_index > 0
        curSess.drawProfile(false)
        prevSess := curSess.clone()
        cleanHist(400) // Keep objects within TradingView 500 limit
    
    // 2. Reset UDT Tracker for new session
    array.clear(curSess.closes)
    array.clear(curSess.opens)
    array.clear(curSess.highs)
    array.clear(curSess.lows)
    array.clear(curSess.volumes)
    curSess.startBar  := bar_index
    curSess.highPrice := high
    curSess.lowPrice  := low

// Accumulate data for the current bar in UDT Arrays
bool shouldAccumulate = profMode == "Session" or inFixedRange
if shouldAccumulate
    array.push(curSess.closes, close)
    array.push(curSess.opens, open)
    array.push(curSess.highs, high)
    array.push(curSess.lows, low)
    array.push(curSess.volumes, volume)
    if array.size(curSess.closes) == 1
        curSess.highPrice := high
        curSess.lowPrice  := low
    else
        curSess.highPrice := math.max(curSess.highPrice, high)
        curSess.lowPrice  := math.min(curSess.lowPrice, low)
    curSess.endBar    := bar_index

// Only draw the LIVE profile box shapes on the actual LAST visual bar
if barstate.islast
    clearLive()               // Delete old live drawing
    
    // Draw Overlay of Previous Profile if enabled
    if profMode == "Session" and showOverlay and not na(prevSess)
        prevSess.drawProfile(true, curSess.startBar, curSess.endBar, true)

    if array.size(curSess.volumes) > 0
        curSess.drawProfile(true) // Render new updated live drawing
    
    // Draw Extended Previous Day Levels (PDPOC / PDVAH / PDVAL)
    if profMode == "Session" and showPrevLvls and not na(prevSess)
        [pB, pS, pIdx, pTV, pMax, pRH] = prevSess.calcProfile()
        pPOC = prevSess.lowPrice + pIdx * pRH + (pRH / 2)
        array.push(liveLines, line.new(curSess.startBar, pPOC, curSess.endBar, pPOC, color=color.new(colPOC, 35), width=2, style=line.style_dashed))
        
        targetVol = pTV * (valuePct / 100)
        cumVol = array.get(pB, pIdx) + array.get(pS, pIdx)
        uIdx = pIdx
        lIdx = pIdx
        while cumVol < targetVol and (uIdx < numRows - 1 or lIdx > 0)
            addU = uIdx < numRows - 1 ? (array.get(pB, uIdx + 1) + array.get(pS, uIdx + 1)) : 0.0
            addL = lIdx > 0 ? (array.get(pB, lIdx - 1) + array.get(pS, lIdx - 1)) : 0.0
            if addU >= addL and uIdx < numRows - 1
                uIdx += 1
                cumVol += addU
            else if lIdx > 0
                lIdx -= 1
                cumVol += addL
            else
                break
                
        pVAH = prevSess.lowPrice + (uIdx + 1) * pRH
        pVAL = prevSess.lowPrice + lIdx * pRH
        array.push(liveLines, line.new(curSess.startBar, pVAH, curSess.endBar, pVAH, color=color.new(colVA, 45), width=1, style=line.style_dashed))
        array.push(liveLines, line.new(curSess.startBar, pVAL, curSess.endBar, pVAL, color=color.new(colVA, 45), width=1, style=line.style_dashed))


// DPOC Shift Tracking (Traced historically)
float dpoc = na
if showDPOC and shouldAccumulate
    [bV, sV, pIdx, tV, maxV, rH] = curSess.calcProfile()
    if maxV > 0
        dpoc := curSess.lowPrice + pIdx * rH + (rH / 2)

plot(dpoc, title="Developing POC", color=isNewSession ? na : colPOC, style=plot.style_stepline, linewidth=2)
````
