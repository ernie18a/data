# VP Trader Pro - Context & Execution Support

- url: https://www.tradingview.com/script/9cckfn7S/
- type: indicator
- pine_id: PUB;a032a4dfbc43494cad55224991770aba
- version: 3.0

## Description

VP Trader Pro is a profile-driven framework designed to help traders read auction structure, participation, and execution context inside a chosen market range.

The script is built to separate three important parts of profile-based trade evaluation:
• structural auction location
• participation and confirmation context
• execution support

Rather than functioning as a static volume profile with extra overlays, the script is designed to connect profile structure, node behavior, historical references, and participation signals into a more coherent trading workflow.

The script uses established profile and market references such as Point of Control, Value Area, HVNs, LVNs, LVGs, Anchored VWAP, and participation-based context because these are practical tools for reading acceptance, rejection, and price travel paths. The value of VP Trader Pro does not come from displaying these references individually, but from how they are organized and translated into a structured context model for execution.

Engine architecture

The framework is built around four main layers that work together to form a profile-based decision model.

1. Active Profile Construction

The script begins by defining an active working range. Depending on configuration, this can be based on a fixed lookback, visible range logic, session anchoring, or higher-timeframe structure.

Within that selected range, the script builds a volume distribution and derives key auction references such as:

• Point of Control
• Value Area High and Low
• profile extremes
• internal node structure
• nearby reference levels that can act as attraction or rejection points

These references are derived from the underlying distribution rather than being visually approximated.

2. Node and Gap Interpretation

The script identifies important internal structure inside the active profile.

This includes:

• HVNs to represent concentrated participation and acceptance
• LVNs to represent thinner participation and potential transition paths
• LVGs to represent broader low-volume voids inside the auction

These zones are not included as chart decoration. Their purpose is to help the trader distinguish between accepted value, inefficient travel space, and areas where price may either reject quickly or move through with less resistance.

The script can also retain unfinished or untested historical references such as NPOCs and prior profile-based reaction zones, since auction references often remain relevant after the original profile has ended.

3. Participation and Context Layer

A static profile alone does not explain whether current movement is supported by participation or whether it is occurring with weak conviction.

For that reason, the script adds a context layer that can evaluate participation through elements such as:

• delta-style pressure
• cumulative delta context
• open-interest change where available
• relative participation behavior around profile structure
• Anchored VWAP location as an additional fair-value reference

Where supported, the script can use more detailed underlying data paths. Where such data is not available, the script is designed to fall back more conservatively rather than presenting all markets as if they offer the same precision.

The purpose of this layer is not to create isolated orderflow signals, but to help the trader judge whether profile reactions are supported, weakening, or unstable.

4. Execution Support and Market State

The script also includes a higher-level context layer for interpreting whether the market is behaving more like:

• balance
• expansion
• breakout acceptance
• rejection
• elevated reversal or failure risk

This helps prevent one of the most common profile mistakes: applying the same logic to a balanced auction and to an initiative move.

The goal of this layer is not to automate trading decisions, but to help the trader align execution logic with the current auction condition.

Additional structure support

For added orientation, the script can preserve important historical levels, nearest magnets, and structurally relevant reference points from previous auctions. These elements are intended to keep the trader focused on actionable auction structure rather than on a static profile snapshot alone.

Practical workflow examples

Scenario 1: Accepted value rotation

Context: price remains inside value and repeatedly rotates around the Point of Control.
Participation: no strong initiative behavior appears and contextual participation remains balanced.
Action: the trader recognizes a rotational environment and avoids forcing breakout logic where acceptance remains dominant.

Scenario 2: Rejection from low-volume structure

Context: price approaches an LVN or LVG after leaving an accepted area.
Participation: the move shows weakening follow-through near the low-volume region.
Action: the script helps frame the area as a potential rejection or fast transition zone rather than as stable value.

Scenario 3: Breakout acceptance

Context: price moves away from prior value and begins to establish acceptance outside the old profile.
Participation: profile structure and supporting context suggest that the move is not simply a temporary excursion.
Action: the trader can treat the event as breakout acceptance and manage execution relative to the new auction structure rather than expecting automatic reversion back into prior value.

Summary

VP Trader Pro is not designed as a generic volume profile overlay. Its purpose is to organize auction structure, participation, and execution context into one practical framework so traders can judge whether price is accepted or rejected, what type of auction condition is active, and whether the current location supports participation.

## Source Code

````pine
//@version=6

// Volume Profile - Context & Execution Support

indicator('VolumeTrader Pro - Context & Execution Support', shorttitle = 'VCS', overlay = true, max_bars_back = 5000, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 150, dynamic_requests = true)
string grp_base = 'Cockpit'
string range_mode           = input.string('Fixed Lookback Bars', 'Range Mode', options = ['Visible Range', 'Visible Range (Right Anchored)', 'Fixed Lookback Bars', 'All Loaded Bars (Current TF)', 'Session (Current)', 'Session (Prev+Current)', 'Session Composite (N)', 'Bar Composite (N)', '4H (Prev+Current)', 'D (Prev+Current)', 'W (Prev+Current)', 'M (Prev+Current)', '3M (Prev+Current)', '12M (Prev+Current)'], group = grp_base,
                             tooltip = '• Select profile range mode.\n• Historical POCs are available only in:\n⠀- Bar Composite (N)\n⠀- 4H / D / W / M / 3M / 12M.\n• Useful when:\n⠀- map acceptance/rejection zones for\n⠀⠀entries, exits, and risk placement.')
bool current_candle_only    = input.bool(false, 'Current Candle Only', group = grp_base, tooltip = '• Applies only to Prev+Current modes.\n• Starts at the current HTF candle only.\n• Useful when:\n⠀- adapt behavior to your instrument\n⠀⠀volatility and execution style.')
int fixed_lookback          = input.int(1650, 'Fixed Lookback Bars', minval = 5, maxval = 5000, step = 10, group = grp_base, tooltip = '• Number of lookback bars used in Fixed\n⠀mode.\n• Useful when:\n⠀- adapt behavior to your instrument\n⠀⠀volatility and execution style.')
string bar_comp_tf          = input.timeframe('240', 'Bar Composite TF', inline = 'comp_bar', group = grp_base, tooltip = '• HTF base timeframe for Bar Composite (N).\n• Useful when:\n⠀- adapt behavior to your instrument\n⠀⠀volatility and execution style.')
int bar_comp_n              = input.int(5, '⠀Bar Composite N', inline = 'comp_bar', minval = 2, maxval = 200, group = grp_base, tooltip = '• Number of HTF bars used for Bar Composite.\n• Useful when:\n⠀- adapt behavior to your instrument\n⠀⠀volatility and execution style.')
string grp_session = 'Session Range'
string session_engine       = input.string('Rolling Trading Sessions (Auto)', 'Session Engine', options = ['Rolling Trading Sessions (Auto)', 'Single (use Session Preset)'], group = grp_session, tooltip = '• Session source selection:\n⠀- Rolling sessions (automatic)\n⠀- Single session (Preset/Custom).\n• Useful when:\n⠀- align session visuals and calculations\n⠀⠀with your trading hours.')
string session_preset   = input.string('Trading Sessions: London', 'Session Preset', options = ['Trading Sessions: London', 'Trading Sessions: New York', 'Trading Sessions: Tokyo', 'Trading Sessions: Sydney', 'Custom'], group = grp_session, tooltip = '• Only used when Session Engine = Single.\n• Choose a trading-session preset or Custom.\n• Useful when:\n⠀- align session visuals and calculations\n⠀⠀with your trading hours.')
string session_custom   = input.session('0800-1700:12345', 'Custom Session', group = grp_session, tooltip = '• Only used when Session Preset = Custom.\n• Useful when:\n⠀- align session visuals and calculations\n⠀⠀with your trading hours.')
string session_comp_opt = input.string('5', 'Composite Sessions (N)', options = ['2', '5', '20'], group = grp_session, tooltip = '• Number of sessions included in Session\n⠀Composite.\n• Useful when:\n⠀- align session visuals and calculations\n⠀⠀with your trading hours.')
string style_mode   = input.string('Heatmap (Pro)', 'Style', options = ['Heatmap (Pro)', 'Histogram (Classic)', 'Monochrome (No-Heatmap)'], group = grp_base, tooltip = '• Visual style of the volume profile.\n• Useful when:\n⠀- map acceptance/rejection zones for\n⠀⠀entries, exits, and risk placement.')
string grp_colors   = 'Color Overrides'
color line_color    = input.color(color.rgb(56, 97, 251), 'Line Color⠀⠀', inline = 'color', group = grp_colors, tooltip = '')
color area_color    = input.color(color.rgb(56, 97, 251), '⠀Area Color⠀⠀⠀', inline = 'color', group = grp_colors, tooltip = '• Dedicated base color for lines\n⠀- POC, VAH/VAL, HVN/LVN\n• Dedicated base color for filled areas\n⠀- Profile bars, LVG zones, panel border.\n• Useful when:\n⠀- tune node/void detection for fast\n⠀⠀markets vs ranging markets.')
color heat_low_col  = input.color(color.rgb(24, 72, 204), 'Heatmap Low', inline = 'heat', group = grp_colors, tooltip = '')
color heat_high_col = input.color(color.rgb(56, 97, 251), '⠀Heatmap High', inline = 'heat', group = grp_colors, tooltip = '• Heatmap colors for low/high intensity.\n• Useful when:\n⠀- improve visual contrast so key\n⠀⠀structures are easier to read quickly.')
string grp_dock = 'Dock / Layout'
int dock_gap_bars   = input.int(15, 'Dock Gap (bars)', minval = 0, maxval = 50, step = 1, group = grp_dock, inline = 'dock0', tooltip = '')
int dock_width_bars = input.int(50, '⠀Dock Width (bars)', minval = 8, maxval = 100, step = 1, group = grp_dock, inline = 'dock0', tooltip = '• Gap = right-side spacing.\n• Width = profile width in bars.\n• Useful when:\n⠀- map acceptance/rejection zones for\n⠀⠀entries, exits, and risk placement.')
int panel_bg_alpha  = 100
string grp_precision = 'Precision'
string precision_mode   = input.string('Intrabar (LTF Aggregation)', 'Precision Mode', options = ['Fast (Bar-Range Distribution)', 'Intrabar (LTF Aggregation)'], group = grp_precision, tooltip = '• Fast = bar-range distribution.\n• Intrabar = LTF aggregation.\n• Falls back to Fast when no valid LTF is\n⠀available.\n• Useful when:\n⠀- balance detail vs performance in\n⠀⠀orderflow-focused analysis.')
string ltf_tf           = input.string('Auto', 'Intrabar LTF', options = ['Auto', '1', '3', '5', '15', '30', '45', '60', '120', '240'], group = grp_precision, tooltip = '• LTF used for Intrabar mode.\n• Must be lower than chart timeframe.\n• Useful when:\n⠀- balance detail vs performance in\n⠀⠀orderflow-focused analysis.')
string dist_mode        = input.string('Uniform (High–Low)', 'Distribution', options = ['Uniform (High–Low)', 'Body Weighted'], group = grp_precision, tooltip = '• Per-candle distribution method:\n⠀- Uniform\n⠀- Body Weighted.\n• Useful when:\n⠀- adapt behavior to your instrument\n⠀⠀volatility and execution style.')
float body_weight_mult  = input.float(3.0, 'Body Weight Mult', minval = 1.0, maxval = 10.0, step = 0.5, group = grp_precision, tooltip = '• Body weight multiplier versus wicks\n⠀- Used only in Body Weighted mode.\n• Useful when:\n⠀- adapt behavior to your instrument\n⠀⠀volatility and execution style.')
string internal_bins_mode   = 'Auto'
int render_rows_in          = 450
int smoothing_bins          = 0
float intensity_gamma       = 0.8
string grp_levels = 'Levels'
bool show_poc           = input.bool(true, 'Show POC', group = grp_levels, tooltip = '• Show or hide the POC line.\n• Useful when:\n⠀- map acceptance/rejection zones for\n⠀⠀entries, exits, and risk placement.')
bool show_va            = input.bool(true, 'Show Value Area', group = grp_levels, tooltip = '• Show or hide the Value Area.\n• Useful when:\n⠀- map acceptance/rejection zones for\n⠀⠀entries, exits, and risk placement.')
float va_percent        = input.float(70.0, 'VA %', minval = 50.0, maxval = 99.0, step = 1, group = grp_levels, tooltip = '• Percentage of total volume inside Value\n⠀Area.\n• Useful when:\n⠀- map acceptance/rejection zones for\n⠀⠀entries, exits, and risk placement.')
bool show_profile_hilo  = input.bool(true, 'Show Profile High/Low', group = grp_levels, tooltip = '• Show profile high and low.\n• Useful when:\n⠀- map acceptance/rejection zones for\n⠀⠀entries, exits, and risk placement.')
bool show_level_labels  = input.bool(true, 'Show Level Labels', group = grp_levels, tooltip = '• Show level labels.\n• Useful when:\n⠀- adapt behavior to your instrument\n⠀⠀volatility and execution style.')
bool extend_level_rays  = input.bool(true, 'Extend Levels to VP Start', group = grp_levels, tooltip = '• Extend levels to VP start.\n• Historical out-of-period segments are\n⠀shown as dashed.\n• Useful when:\n⠀- map acceptance/rejection zones for\n⠀⠀entries, exits, and risk placement.')
string grp_nodes = 'Nodes & Zones'
bool show_hvn                   = input.bool(true, 'Show HVN⠀', inline="nod_z", group = grp_nodes, tooltip = '')
bool show_lvn                   = input.bool(true, 'Show LVN⠀', inline="nod_z", group = grp_nodes, tooltip = '')
bool show_lvg                   = input.bool(true, 'Show LVG', inline="nod_z", group = grp_nodes, tooltip = '• Visibility toggles for HVN / LVN / LVG.\n• Useful when:\n⠀- you want to focus only on one structure\n⠀⠀type (acceptance, rejection, or voids)\n⠀⠀instead of showing everything at once.')
int hvn_abs_count               = input.int(10, 'HVN Count (abs)', inline="nod_h", minval = 0, maxval = 25, group = grp_nodes, tooltip = '• Number of strongest absolute HVNs.\n• Higher values progressively include weaker\n⠀HVNs after the strongest ones. \n• Number of relative (local) HVNs.\n• Sorted from locally strongest to weaker\n⠀relative HVNs.')
int lvn_abs_count               = input.int(6, 'LVN Count (abs)', inline="nod_l", minval = 0, maxval = 25, group = grp_nodes, tooltip = '• Number of strongest absolute LVNs.\n• Higher values progressively include weaker\n⠀LVNs after the strongest ones. \n• Number of relative (local) LVNs.\n• Sorted from locally strongest to weaker\n⠀relative LVNs.')
int hvn_rel_count               = input.int(2, '⠀HVN Count (rel)', inline="nod_h", minval = 0, maxval = 25, group = grp_nodes, tooltip = '')
int lvn_rel_count               = input.int(2, '⠀LVN Count (rel)', inline="nod_l", minval = 0, maxval = 25, group = grp_nodes, tooltip = '')
string node_tuning_mode         = input.string('Auto (Count-driven)', 'Node Tuning', options = ['Auto (Count-driven)', 'Manual thresholds'], group = grp_nodes, tooltip = '• Auto: separation/prominence adapt from\n⠀⠀selected node counts.\n• Manual: use fixed values below.')
int node_min_separation_bins    = input.int(6, 'Node Min Separation (bins) [Manual]', minval = 1, maxval = 40, group = grp_nodes, tooltip = '• Used only in Manual thresholds mode.\n• Minimum spacing between detected nodes.')
float hvn_prominence_pct        = input.float(12.0, 'HVN Min Prominence % of max [Manual]', minval = 1.0, maxval = 60.0, step = 1, group = grp_nodes, tooltip = '• Used only in Manual thresholds mode.\n• Minimum HVN prominence threshold.')
float lvn_threshold_pct         = input.float(20.0, 'LVN Max % of max [Manual]', minval = 1.0, maxval = 80.0, step = 1, group = grp_nodes, tooltip = '• Used only in Manual thresholds mode.\n• Maximum LVN threshold.')
string lvg_threshold_mode       = input.string('PercentOfMax', 'LVG Threshold Mode', options = ['PercentOfMax', 'Quantile'], group = grp_nodes, tooltip = '• Detection logic for LVG zones.\n⠀- PercentOfMax uses a fixed % of max\n⠀⠀volume in the profile.\n⠀- Quantile adapts to the distribution shape.\n• Useful when:\n⠀- choose Quantile if symbols have unstable\n⠀⠀volume regimes.')
bool lvg_auto_scale             = input.bool(true, 'LVG Auto Normalize (TF)', group = grp_nodes, tooltip = '• Timeframe-aware LVG normalization.\n• Useful when:\n⠀- keep ON to get similar LVG sensitivity\n⠀⠀across 5m, 1h, and 4h charts.\n⠀- turn OFF if you want full manual control\n⠀⠀per timeframe.')
float lvg_threshold_value       = input.float(15.0, 'LVG Threshold', minval = 1.0, maxval = 50.0, step = 1, group = grp_nodes, tooltip = '• Base threshold for LVG detection.\n⠀- PercentOfMax: % of maximum volume\n⠀- Quantile: quantile × 100\n• With Auto Normalize, value adapts by TF\n⠀and distribution.\n• Useful when:\n⠀- increase to show only stronger voids.\n⠀- decrease to detect more early imbalance\n⠀⠀areas.')
int lvg_min_height_bins         = input.int(2, 'LVG Min Height (bins)', minval = 1, maxval = 20, group = grp_nodes, tooltip = '• Minimum height of an LVG zone (in bins).\n• Useful when:\n⠀- raise this to filter tiny micro-zones.\n⠀- keep lower for intraday charts where\n⠀⠀small gaps can still matter.')
int lvg_max_zones               = input.int(6, 'LVG Max Zones', minval = 1, maxval = 12, group = grp_nodes, tooltip = '• Maximum number of LVG zones.\n• Useful when:\n⠀- lower values prioritize only nearest/high\n⠀⠀priority zones.\n⠀- higher values preserve more historical\n⠀⠀context for swing planning.')
grp_sess      = "Trading Sessions"
sess_timezone = input.string("Europe/Berlin", title="Timezone", inline="ses", options=["Europe/Berlin", "Etc/UTC", "Europe/London", "America/New_York", "Asia/Tokyo", "Australia/Sydney"], tooltip = "", group=grp_sess)
sess_style    = input.string("Vertical Line", title="⠀Session Style", inline="ses", options=["Vertical Line", "Box", "Background", "Inv. Background"], group=grp_sess, tooltip = "• Session timezone and visual style.\n• Useful when:\n⠀- align session visuals and calculations\n⠀⠀with your trading hours.")
use_sess_rest   = input.bool(false, title="Session Restriction", inline="ses_rest", group=grp_sess)
sess_rest_time  = input.int(60, title="⠀⠀⠀⠀Time", inline="ses_rest", tooltip = "• Session restriction length in minutes.\n• Useful when:\n⠀- align session visuals and calculations\n⠀⠀with your trading hours.", group=grp_sess)
london_show   = input.bool(true, title="London Session ⠀⠀", group=grp_sess, inline="lon")
london_sess   = input.session("0900-1730", title="", group=grp_sess, inline="lon")
london_col    = input.color(color.new(color.orange, 90), title="", group=grp_sess, inline="lon", tooltip = "• London session settings:\n⠀- enabled\n⠀- time window\n⠀- color.\n• Useful when:\n⠀- align session visuals and calculations\n⠀⠀with your trading hours.")
ny_show       = input.bool(true, title="New York Session⠀", group=grp_sess, inline="ny")
ny_sess       = input.session("1530-2200", title="", group=grp_sess, inline="ny")
ny_col        = input.color(color.new(color.blue, 90), title="", group=grp_sess, inline="ny", tooltip = "• New York session settings:\n⠀- enabled\n⠀- time window\n⠀- color.\n• Useful when:\n⠀- align session visuals and calculations\n⠀⠀with your trading hours.")
tokyo_show    = input.bool(false, title="Tokyo Session ⠀⠀⠀", group=grp_sess, inline="tok")
tokyo_sess    = input.session("0100-0900", title="", group=grp_sess, inline="tok")
tokyo_col     = input.color(color.new(color.yellow, 90), title="", group=grp_sess, inline="tok", tooltip = "• Tokyo session settings:\n⠀- enabled\n⠀- time window\n⠀- color.\n• Useful when:\n⠀- align session visuals and calculations\n⠀⠀with your trading hours.")
sydney_show     = input.bool(false, title="Sydney Session ⠀⠀", group=grp_sess, inline="syd")
sydney_sess     = input.session("2200-0700", title="", group=grp_sess, inline="syd")
sydney_col      = input.color(color.new(color.red, 90), title="", group=grp_sess, inline="syd", tooltip = "• Sydney session settings:\n⠀- enabled\n⠀- time window\n⠀- color.\n• Useful when:\n⠀- align session visuals and calculations\n⠀⠀with your trading hours.")
sess_line_limit = 150
sess_box_limit  = 120
string grp_ads = 'ADS & Alerts'
bool ads_enable             = input.bool(true, 'Enable ADS', group = grp_ads, tooltip = '• Enable or disable ADS module (bar close).\n• Useful when:\n⠀- control how strict ADS confirmations and\n⠀⠀alerts should be.')
bool ads_show_panel         = input.bool(true, 'Show Panel', inline = 'ads_p', group = grp_ads, tooltip = '• Show ADS panel.\n• Calculations remain active.\n• Useful when:\n⠀- control how strict ADS confirmations and\n⠀⠀alerts should be.')
string panel_location       = input.string('Bottom Left', '⠀Panel Location', inline = 'ads_p', options = ['Top Right', 'Middle Left', 'Middle Right', 'Bottom Left', 'Bottom Right'], group = grp_ads, tooltip = '• Panel placement on the chart\n• Useful when:\n⠀- keep ADS context visible without\n⠀⠀covering your active execution area.')
bool ads_show_marker_legend = input.bool(false, 'Marker Legend', group = grp_ads, tooltip = '• Adds a marker legend row above the panel.\n• Uses colored symbols for quick decoding.\n• Useful when:\n⠀- reviewing signal/ADS markers without\n⠀⠀memorizing every abbreviation.')
bool ads_show_markers       = input.bool(true, 'Show Markers', group = grp_ads, tooltip = '• Show ADS event markers on price.\n• Useful when:\n⠀- control how strict ADS confirmations and\n⠀⠀alerts should be.')
string ads_strictness       = input.string('Auto', 'Strictness', inline = 'st_con', options = ['Auto', 'Loose', 'Normal', 'Strict'], group = grp_ads, tooltip = '')
int ads_accept_confirm      = input.int(2, '⠀Accept Confirm Bars', inline = 'st_con', minval = 1, maxval = 3, group = grp_ads, tooltip = '• Strictness profile and required\n⠀confirmation bars.\n• Useful when:\n⠀- map acceptance/rejection zones for\n⠀⠀entries, exits, and risk placement.')
bool ads_alert_accept       = input.bool(true, 'Accept⠀', group = grp_ads, inline = 'ads_al1')
bool ads_alert_fail         = input.bool(true, 'Fail⠀', group = grp_ads, inline = 'ads_al1')
bool ads_alert_reentry      = input.bool(true, 'Re-Entry', group = grp_ads, inline = 'ads_al1', tooltip = '• ADS alerts for A / F / R (bar close).\n• Useful when:\n⠀- control how strict ADS confirmations and\n⠀⠀alerts should be.')
bool ads_alert_new_value    = input.bool(true, 'New Value⠀', group = grp_ads, inline = 'ads_al2')
bool ads_alert_regime       = input.bool(false, 'Regime⠀', group = grp_ads, inline = 'ads_al2')
bool ads_alert_reversal     = input.bool(false, 'RevRisk', group = grp_ads, inline = 'ads_al2', tooltip = '• ADS alerts for New Value / Regime /\n⠀Reversal Risk (bar close).\n• Useful when:\n⠀- control how strict ADS confirmations and\n⠀⠀alerts should be.')
string grp_of = 'Orderflow / Delta'
bool of_enable              = input.bool(false, 'Enable OF/Delta', group = grp_of, tooltip = '• Enable or disable Orderflow/Delta path.\n• Useful when:\n⠀- balance detail vs performance in\n⠀⠀orderflow-focused analysis.')
string of_source_mode       = input.string('Auto', 'Orderflow Source', options = ['Auto', 'Native Only', 'Proxy Only'], group = grp_of, tooltip = '• Orderflow data source:\n⠀- Auto\n⠀- Native\n⠀- Proxy.\n• Useful when:\n⠀- balance detail vs performance in\n⠀⠀orderflow-focused analysis.')
int of_native_ticks_per_row = input.int(4, 'Native Ticks/Row', minval = 1, maxval = 64, group = grp_of, tooltip = '• Native footprint resolution per row.\n• Useful when:\n⠀- balance detail vs performance in\n⠀⠀orderflow-focused analysis.')
float of_native_imbalance   = input.float(300.0, 'Native Imbalance %', minval = 100.0, maxval = 1000.0, step = 10.0, group = grp_of, tooltip = '• Threshold for native imbalance.\n• Useful when:\n⠀- adapt behavior to your instrument\n⠀⠀volatility and execution style.')
string of_profile_type      = input.string('Delta (Net)', 'Profile Type', options = ['Total Volume (classic)', 'Bid/Ask Split', 'Delta (Net)'], group = grp_of, tooltip = '• Profile display mode:\n⠀- Total Volume\n⠀- Bid/Ask Split\n⠀- Delta.\n• Useful when:\n⠀- map acceptance/rejection zones for\n⠀⠀entries, exits, and risk placement.')
string of_require_intrabar  = input.string('Fallback to chart TF', 'Intrabar Rule', options = ['Strict (disable if no intrabar)', 'Fallback to chart TF'], group = grp_of, tooltip = '• Behavior when intrabar data is\n⠀unavailable.\n• Useful when:\n⠀- balance detail vs performance in\n⠀⠀orderflow-focused analysis.')
bool of_show_base_underlay  = input.bool(false, 'Show VP Underlay in OF', group = grp_of, tooltip = '• Show VP underlay in OF mode.\n• Useful when:\n⠀- adapt behavior to your instrument\n⠀⠀volatility and execution style.')
color of_buy_col            = input.color(color.rgb(38, 166, 91), 'OF Buy Color⠀⠀', group = grp_of, inline = 'ofc1', tooltip = '')
color of_sell_col           = input.color(color.rgb(229, 57, 53), '⠀OF Sell Color⠀⠀', group = grp_of, inline = 'ofc1', tooltip = '• Colors for OF Buy/Sell.\n• Useful when:\n⠀- improve visual contrast so key\n⠀⠀structures are easier to read quickly.')
color of_delta_pos_col      = input.color(color.rgb(0, 188, 212), 'OF Delta+ Color', group = grp_of, inline = 'ofc2', tooltip = '')
color of_delta_neg_col      = input.color(color.rgb(255, 112, 67), '⠀OF Delta- Color', group = grp_of, inline = 'ofc2', tooltip = '• Colors for OF Delta + / -.\n• Useful when:\n⠀- balance detail vs performance in\n⠀⠀orderflow-focused analysis.')
int of_fill_alpha_min       = 18
int of_fill_alpha_max       = 72
int OF_DELTA_SRC_MODE       = 0
int OF_NEUTRAL_MODE         = 0
string grp_ctx = 'Context Pack'
string ctx_pack_mode        = input.string('Standard', 'Mode', inline = 'mode_m', options = ['Off', 'Standard'], group = grp_ctx, tooltip = '')
int ctx_ib_minutes          = input.int(60, '⠀Initial Balance Minutes', inline = 'mode_m', minval = 15, maxval = 120, group = grp_ctx, tooltip = '• Context mode plus Initial Balance minutes\n⠀from session start.\n• Useful when:\n⠀- align session visuals and calculations\n⠀⠀with your trading hours.')
bool ctx_show_panel         = input.bool(true, 'Show Context Panel⠀', inline = 'con_pan', group = grp_ctx, tooltip = '• Show compact context panel at dock.\n• Useful when:\n⠀- adapt behavior to your instrument\n⠀⠀volatility and execution style.')
bool ctx_visual_extras      = input.bool(true, 'Visual Extras (optional)', inline = 'con_pan', group = grp_ctx, tooltip = '• Optional visual extras.\n• Useful when:\n⠀- adapt behavior to your instrument\n⠀⠀volatility and execution style.')
string ctx_pane_plot_mode   = input.string('None', 'Pane Plots', inline = 'spacer_p', options = ['None', 'Overlay (Band)'], group = grp_ctx, tooltip = '• Pane plot mode:\n⠀- None\n⠀- Overlay band.\n• Useful when:\n⠀- track value rotation, deviation\n⠀⠀extremes, and mean-reversion context.')
string grp_avwap = 'AVWAP (Anchored VWAP)'
bool avwap_enable           = input.bool(false, 'Enable AVWAP', group = grp_avwap, tooltip = '• Show Anchored VWAP in VP context.\n• Useful when:\n⠀- adapt behavior to your instrument\n⠀⠀volatility and execution style.')
string avwap_anchor         = input.string('Profile Start', 'Anchor⠀⠀⠀', options = ['Profile Start', 'Session Start (engine current)', 'Daily (TZ)', 'Weekly (TZ)', 'Manual (timestamp)'], group = grp_avwap, inline = 'avw0', tooltip = '')
string avwap_src            = input.string('HLC3', '⠀Source', options = ['HLC3', 'Close'], group = grp_avwap, inline = 'avw0', tooltip = '• Anchor defines start point.\n• Source defines price basis.\n• Useful when:\n⠀- adapt behavior to your instrument\n⠀⠀volatility and execution style.')
bool avwap_bands_enable     = input.bool(true, 'Enable ±σ Bands⠀', inline = 'band_l', group = grp_avwap, tooltip = '')
bool avwap_show_labels      = input.bool(true, 'Show Labels', inline = 'band_l', group = grp_avwap, tooltip = '• Show ±σ bands/labels around AVWAP.\n• Useful when:\n⠀- track value rotation, deviation\n⠀⠀extremes, and mean-reversion context.')
string avwap_band_mults     = input.string('±1σ,±2σ', 'Band Preset', inline = 'band', options = ['±1σ', '±1σ,±2σ', '±1σ,±2σ,±3σ'], group = grp_avwap, tooltip = '• Select which ±σ bands are drawn.\n• Useful when:\n⠀- track value rotation, deviation\n⠀⠀extremes, and mean-reversion context.')
string avwap_band_method    = input.string('Volume-Weighted', '⠀Band Method', inline = 'band', options = ['Volume-Weighted', 'Simple'], group = grp_avwap, tooltip = '• Band method:\n⠀- Volume-weighted\n⠀- Simple.\n• Useful when:\n⠀- track value rotation, deviation\n⠀⠀extremes, and mean-reversion context.')
int avwap_manual_ts         = input.time(timestamp('2025-01-01T00:00:00'), 'Anchor Timestamp', inline = 'at', group = grp_avwap, tooltip = '• Only relevant when Anchor = Manual.\n• Useful when:\n⠀- adapt behavior to your instrument\n⠀⠀volatility and execution style.')
string grp_npoc         = 'Naked POCs / Virgin Levels'
bool npoc_enable        = input.bool(false, 'Enable Naked POCs', group = grp_npoc, tooltip = '• Show Naked POCs.\n• Useful when:\n⠀- map acceptance/rejection zones for\n⠀⠀entries, exits, and risk placement.')
string npoc_source      = input.string('Both', 'Source', inline = 'spacer_1', options = ['Daily', 'Session', 'Both'], group = grp_npoc, tooltip = '• Source selection:\n⠀- Daily\n⠀- Session\n⠀- Both.\n• Useful when:\n⠀- align session visuals and calculations\n⠀⠀with your trading hours.')
int npoc_lookback       = input.int(10, 'Lookback Windows', minval = 5, maxval = 20, group = grp_npoc, inline = 'npoc0', tooltip = '')
int npoc_max_levels     = input.int(5, '⠀Max Active Levels', minval = 1, maxval = 10, group = grp_npoc, inline = 'npoc0', tooltip = '• Lookback window and maximum active levels.\n• Useful when:\n⠀- adapt behavior to your instrument\n⠀⠀volatility and execution style.')
string npoc_touch_rule  = input.string('Within X ticks', 'Touch Rule', options = ['Wick touch', 'Close touch', 'Within X ticks'], group = grp_npoc, inline = 'npoc1', tooltip = '')
int npoc_touch_ticks    = input.int(5, 'Touch Ticks (X)', minval = 1, maxval = 20, group = grp_npoc, inline = 'npoc1', tooltip = '• Touch rule and tick tolerance.\n• Useful when:\n⠀- adapt behavior to your instrument\n⠀⠀volatility and execution style.')
string npoc_prioritize  = input.string('Hybrid', 'Prioritize⠀', inline = 'spacer_2', options = ['Hybrid', 'Nearest', 'Most recent'], group = grp_npoc, tooltip = '• Sorting for visible levels.\n• Useful when:\n⠀- adapt behavior to your instrument\n⠀⠀volatility and execution style.')
bool npoc_fade_by_age   = input.bool(true, 'Fade by Age⠀', group = grp_npoc, inline = 'npoc2', tooltip = '')
bool npoc_labels        = input.bool(true, 'Show Labels', group = grp_npoc, inline = 'npoc2', tooltip = '• Fade by age and label display for NPOCs.\n• Useful when:\n⠀- map acceptance/rejection zones for\n⠀⠀entries, exits, and risk placement.')
string grp_hist_poc = 'Historical Period POCs'
bool hist_poc_enable = input.bool(false, 'Enable Historical POCs', group = grp_hist_poc, tooltip = '• Supported modes:\n⠀- Bar Composite (N)\n⠀- 4H / D / W / M / 3M / 12M\n• Historical POCs are red.\n• Base period is driven by Bar Composite TF.\n• Useful when:\n⠀- map acceptance/rejection zones for\n⠀⠀entries, exits, and risk placement.')
int hist_poc_count = input.int(6, 'Lookback Periods', minval = 1, maxval = 12, group = grp_hist_poc, tooltip = '• Lookback Periods = number of individual\n⠀historical periods.\n• Useful when:\n⠀- adapt behavior to your instrument\n⠀⠀volatility and execution style.')
bool hist_poc_show_labels = input.bool(true, 'Show Labels', group = grp_hist_poc, tooltip = '• Show labels for Historical POCs.\n• Useful when:\n⠀- map acceptance/rejection zones for\n⠀⠀entries, exits, and risk placement.')
bool hist_poc_fade_by_age = input.bool(true, 'Fade by Age', group = grp_hist_poc, tooltip = '• Older Historical POCs are rendered more\n⠀transparent.\n• Useful when:\n⠀- map acceptance/rejection zones for\n⠀⠀entries, exits, and risk placement.')
string grp_sig_main = 'Signals'
bool sig_enable = input.bool(false, 'Enable Signal Engine', group = grp_sig_main, inline = 'sig_engine', tooltip = '')
string bg_sig_select = input.string('None', '⠀⠀⠀⠀⠀⠀BG Mode⠀', inline = 'sig_engine', options = ['None', 'Signal Regime (Discrete)', 'Signal Bias', 'Signal Reversal Risk', 'Signal VA Location (Above/In/Below)', 'Signal LVG Zone', 'Signal Events Pulse'], group = grp_sig_main, tooltip = '• Signal engine runs on bar close.\n• BG Mode selects background source:\n⠀- Regime / Bias / Risk\n⠀- VA / LVG / Events.\n• Useful when:\n⠀- tune node/void detection for fast\n⠀⠀markets vs ranging markets.')
int bg_sig_transp           = input.int(82, 'BG Transp⠀⠀⠀', minval = 0, maxval = 100, group = grp_sig_main, inline = 'sig_bg1', tooltip = '')
int bg_event_hold_bars      = input.int(2, '⠀Hold Bars⠀', minval = 1, maxval = 8, group = grp_sig_main, inline = 'sig_bg1', tooltip = '• Background transparency and hold-bars for\n⠀event coloring.\n• Useful when:\n⠀- improve visual contrast so key\n⠀⠀structures are easier to read quickly.')
string sig_quality          = input.string('Balanced (Auto)', 'Signal Quality', options = ['Fast (Low CPU)', 'Balanced (Auto)', 'High (More detail)'], group = grp_sig_main, inline = 'sig_perf', tooltip = '• Performance preset for signal engine.\n• Useful when:\n⠀- adjust responsiveness vs noise in\n⠀⠀signal-driven workflows.')
bool sig_show_markers       = input.bool(false, 'Markers⠀', group = grp_sig_main, inline = 'sig_ver0', tooltip = '')
bool sig_expose_series      = input.bool(true, 'Data Window', group = grp_sig_main, inline = 'sig_ver0', tooltip = '• Show signal markers and Data Window\n⠀series.\n• Useful when:\n⠀- adjust responsiveness vs noise in\n⠀⠀signal-driven workflows.')
int MAX_BARS_BACK = 5000
var array<float> vol_internal = array.new_float(0)
var array<float> smt_internal = array.new_float(0)
var array<float> pref_internal = array.new_float(0)
var array<float> pref_buy = array.new_float(0)
var array<float> pref_sell = array.new_float(0)
var array<float> diff_internal = array.new_float(0)
var array<float> vol_render = array.new_float(0)
var array<float> diff_buy_internal = array.new_float(0)
var array<float> diff_sell_internal = array.new_float(0)
var array<float> buy_internal = array.new_float(0)
var array<float> sell_internal = array.new_float(0)
var array<float> buy_smt_internal = array.new_float(0)
var array<float> sell_smt_internal = array.new_float(0)
var array<float> buy_render = array.new_float(0)
var array<float> sell_render = array.new_float(0)
var array<float> delta_render = array.new_float(0)
var array<int> hvn_idx = array.new_int(0)
var array<int> lvn_idx = array.new_int(0)
var array<int> lvg_start = array.new_int(0)
var array<int> lvg_end = array.new_int(0)
var box panel_box = na
var array<box> row_boxes = array.new_box(0)
var array<box> delta_strip_boxes = array.new_box(0)
var array<box> split_buy_boxes = array.new_box(0)
var array<box> split_sell_boxes = array.new_box(0)
var array<box> lvg_boxes = array.new_box(0)
var line poc_line = na
var line vah_line = na
var line val_line = na
var line hi_line = na
var line lo_line = na
var array<line> hvn_lines = array.new_line(0)
var array<line> lvn_lines = array.new_line(0)
var array<box> hvn_boxes = array.new_box(0)
var array<box> lvn_boxes = array.new_box(0)
var label level_label = na
var label warn_label = na
var array<line> avwap_lines = array.new_line(0)
var array<label> avwap_labels = array.new_label(0)
var array<line> npoc_lines = array.new_line(0)
var array<label> npoc_labels_pool = array.new_label(0)
var array<line> hist_poc_lines_in_period = array.new_line(0)
var array<line> hist_poc_lines_extended = array.new_line(0)
var array<label> hist_poc_labels_pool = array.new_label(0)
var array<int> hist_240_start_series = array.new_int(12, na)
var array<int> hist_D_start_series = array.new_int(12, na)
var array<int> hist_W_start_series = array.new_int(12, na)
var array<int> hist_M_start_series = array.new_int(12, na)
var array<int> hist_3M_start_series = array.new_int(12, na)
var array<int> hist_12M_start_series = array.new_int(12, na)
var array<box> sess_boxes = array.new_box(0)
var box b_lon = na
var box b_ny = na
var box b_tok = na
var box b_syd = na
var array<float> npoc_price = array.new_float(0)
var array<int> npoc_start_idx = array.new_int(0)
var array<int> npoc_close_idx = array.new_int(0)
var array<string> npoc_kind = array.new_string(0)
var array<string> npoc_tag = array.new_string(0)
var array<int> npoc_tag_ord = array.new_int(0)
var array<int> npoc_ord = array.new_int(0)
var int npoc_ord_counter = 0
var array<bool> npoc_tested = array.new_bool(0)
var array<int> npoc_test_win_age = array.new_int(0)
var bool npoc_prev_enable = false
var array<float> npoc_d_lo = array.new_float(0)
var array<float> npoc_d_hi = array.new_float(0)
var array<float> npoc_d_vol = array.new_float(0)
var int npoc_d_start_idx = na
var array<float> npoc_s_lo = array.new_float(0)
var array<float> npoc_s_hi = array.new_float(0)
var array<float> npoc_s_vol = array.new_float(0)
var int npoc_s_start_idx = na
var string npoc_s_tag = ''
var int npoc_day_counter = 0
var int npoc_syd_counter = 0
var int npoc_tok_counter = 0
var int npoc_lon_counter = 0
var int npoc_ny_counter = 0
var int sess_box_cap_runtime = sess_box_limit
var int last_left_vis = na
var int last_right_vis = na
var int last_calc_left_idx = na
var int last_calc_right_idx = na
var bool last_range_fallback_used = false
var string last_cfg_hash = ''
var bool dirty = true
var float ads_poc = na
var float ads_vah = na
var float ads_val = na
var float ads_value_mid = na
var float ads_profile_w = na
var float ads_ref_poc = na
var float ads_ref_vah = na
var float ads_ref_val = na
var int ads_ref_bar_index = na
var int ads_last_session_left = na
var float ads_prev_sess_poc = na
var float ads_prev_sess_vah = na
var float ads_prev_sess_val = na
var string ads_state = 'N/A'
var int ads_bias = 0
var int ads_rotation = 0
var int ads_reversal_risk = 0
var string ads_shape = 'D'
var float ads_overlap = na
var float ads_shift = na
var float ads_tail_low = na
var float ads_tail_high = na
var float ads_sig_poc = na
var float ads_sig_vah = na
var float ads_sig_val = na
var float ads_sig_profile_w = na
var float ads_sig_value_mid = na
var float ads_sig_overlap = na
var float ads_sig_shift = na
var float ads_sig_tail_low = na
var float ads_sig_tail_high = na
var string ads_sig_shape = 'D'
var float ads_sig_ref_poc = na
var float ads_sig_ref_vah = na
var float ads_sig_ref_val = na
var float nv_ratio_series = 0.0
var int ads_out_up = 0
var int ads_out_dn = 0
var bool ads_was_outside = false
var int ads_last_event_bar = na
var array<label> ads_markers = array.new_label(0)
var array<int> ads_rot_buf = array.new_int(0)
var int ads_rot_count = 0
var bool ads_prev_enable = false
var bool ads_prev_show_markers = false
var bool ads_prev_toggle_init = false
var int ads_panel_last_update_bar = na
var string ads_panel_of_status = 'Off'
var string of_source_mode_active = 'Proxy'
var bool of_native_available = false
var bool of_native_used = false
var bool of_fallback_used = false
var int of_fallback_bars_last = 0
var string of_native_coverage = 'none'
var string of_status_text = 'OF Source: Proxy'
var string of_status_reason = ''
var float of_cvd = na
var float of_delta_at_poc = na
var float of_max_abs_delta = na
var float of_buy_pct_in_va = na
var float vp_poc_last = na
var float vp_vah_last = na
var float vp_val_last = na
var float ctx_cvd = 0.0
var float ctx_cvd_delta = 0.0
var float ctx_cvd_min = na
var float ctx_cvd_max = na
var int ctx_last_sign = 0
var int ctx_ib_start_ts = na
var int ctx_ib_end_ts = na
var float ctx_ib_hi = na
var float ctx_ib_lo = na
var bool ctx_ib_done = false
var float ctx_pd_poc = na
var float ctx_pd_vah = na
var float ctx_pd_val = na
var bool ctx_prev_valid = false
var array<float> ctx_win_lo = array.new_float(0)
var array<float> ctx_win_hi = array.new_float(0)
var array<float> ctx_win_vol = array.new_float(0)
var float ctx_oi = na
var float ctx_oi_delta = na
var float ctx_oi_sess_net = 0.0
var float ctx_oi_min = na
var float ctx_oi_max = na
var array<line> ctx_ib_lines = array.new_line(0)
var array<line> ctx_pd_lines = array.new_line(0)
var table vcd_panel = na
var int last_panel_rows = na
var float ctx_ph_p_prev = na
var float ctx_ph_c_prev = na
var float ctx_pl_p_prev = na
var float ctx_pl_c_prev = na
var int ctx_last_div_bar = na
var bool ctx_seen_session_start = false
f_ctx_extract_symbol(simple string symbol_raw) =>
    string symbol_clean = symbol_raw
    int key_pos = str.pos(symbol_raw, '"symbol":"')
    if not na(key_pos)
        int start_pos = key_pos + str.length('"symbol":"')
        string tail = str.substring(symbol_raw, start_pos)
        int end_rel = str.pos(tail, '"')
        if not na(end_rel) and end_rel > 0
            symbol_clean := str.substring(tail, 0, end_rel)
    symbol_clean
f_ctx_open_interest_futures(simple string symbol, simple bool gaps, simple bool repaint) =>
    string symbol_base = f_ctx_extract_symbol(symbol)
    string oi_symbol = symbol_base + '_OI'
    float oi_close = request.security(oi_symbol, timeframe.period, close, gaps = gaps ? barmerge.gaps_on : barmerge.gaps_off, lookahead = repaint ? barmerge.lookahead_on : barmerge.lookahead_off, ignore_invalid_symbol = true)
    float oi_rising = (not na(oi_close) and not na(oi_close[1])) ? (oi_close - oi_close[1]) : na
    [oi_close, oi_rising]
f_ctx_open_interest_crypto(simple string symbol, simple string tf, simple bool gaps, simple bool repaint) =>
    string symbol_base = f_ctx_extract_symbol(symbol)
    string oi_symbol = symbol_base + '_OI'
    float oi_open = request.security(oi_symbol, tf, open, gaps = gaps ? barmerge.gaps_on : barmerge.gaps_off, lookahead = repaint ? barmerge.lookahead_on : barmerge.lookahead_off, ignore_invalid_symbol = true)
    float oi_high = request.security(oi_symbol, tf, high, gaps = gaps ? barmerge.gaps_on : barmerge.gaps_off, lookahead = repaint ? barmerge.lookahead_on : barmerge.lookahead_off, ignore_invalid_symbol = true)
    float oi_low = request.security(oi_symbol, tf, low, gaps = gaps ? barmerge.gaps_on : barmerge.gaps_off, lookahead = repaint ? barmerge.lookahead_on : barmerge.lookahead_off, ignore_invalid_symbol = true)
    float oi_close = request.security(oi_symbol, tf, close, gaps = gaps ? barmerge.gaps_on : barmerge.gaps_off, lookahead = repaint ? barmerge.lookahead_on : barmerge.lookahead_off, ignore_invalid_symbol = true)
    float oi_rising = (not na(oi_close) and not na(oi_close[1])) ? (oi_close - oi_close[1]) : na
    [oi_open, oi_high, oi_low, oi_close, oi_rising]
var array<float> sig_bins = array.new_float(0)
var array<int> sig_lvg_start = array.new_int(0)
var array<int> sig_lvg_end = array.new_int(0)
var float sig_poc = na
var float sig_vah = na
var float sig_val = na
var float sig_value_mid = na
var float sig_profile_w = na
var float sig_pmin = na
var float sig_step = na
var float sig_ref_poc = na
var float sig_ref_vah = na
var float sig_ref_val = na
var int sig_ref_bar = na
var int sig_state_enum = 0
var int sig_bias = 0
var int sig_reversal_risk = 0
var float sig_overlap = na
var float sig_shift = na
var int sig_out_up = 0
var int sig_out_dn = 0
var bool sig_was_outside = false
var array<int> sig_rot_buf = array.new_int(0)
var int sig_rot_count = 0
var int sig_rotation = 0
var int bg_pulse_left = 0
var int bg_pulse_prio = 0
var color bg_pulse_col = na
var int sig_evt_priority = 0
var bool sig_in_lvg_zone = false
var bool sig_evt_accept_up = false
var bool sig_evt_accept_dn = false
var bool sig_evt_fail_up = false
var bool sig_evt_fail_dn = false
var bool sig_evt_reentry = false
var bool sig_evt_new_value = false
var bool sig_evt_regime = false
var bool sig_evt_reversal = false
var int sig_left_series = na
var int sig_right_series = na
var float sig_nv_ratio = 0.0
bool evt_accept_up = false
bool evt_accept_dn = false
bool evt_fail_up = false
bool evt_fail_dn = false
bool evt_reentry = false
bool evt_new_value = false
bool evt_regime_change = false
bool evt_reversal_high = false
bool ads_fire_accept_up = false
bool ads_fire_accept_dn = false
bool ads_fire_fail_up = false
bool ads_fire_fail_dn = false
bool ads_fire_reentry = false
bool ads_fire_new_value = false
bool ads_fire_regime = false
bool ads_fire_reversal = false
f_ensure_float_array(array<float> arr, int size) =>
    int cur = array.size(arr)
    if cur < size
        for _ = 0 to size - cur - 1 by 1
            array.push(arr, 0.0)
    else if cur > size
        for _ = 0 to cur - size - 1 by 1
            array.pop(arr)
    arr
f_evt_color(int prio) =>
    switch prio
        7 => color.green
        6 => color.orange
        5 => color.blue
        4 => color.purple
        3 => color.yellow
        2 => color.orange
        1 => color.gray
        => color.rgb(255, 130, 0)
f_hide_box(box bx) =>
    if not na(bx)
        box.set_bgcolor(bx, color.new(color.black, 100))
        box.set_border_color(bx, color.new(color.black, 100))
f_hide_line(line ln) =>
    if not na(ln)
        line.set_color(ln, color.new(color.black, 100))
f_hide_label(label lb) =>
    if not na(lb)
        label.set_text(lb, '')
        label.set_color(lb, color.new(color.black, 100))
        label.set_textcolor(lb, color.new(color.black, 100))
f_snap_tick(float p) =>
    float mt = syminfo.mintick
    mt > 0 ? math.round(p / mt) * mt : p
f_floor_tick(float p) =>
    float mt = syminfo.mintick
    mt > 0 ? math.floor(p / mt) * mt : p
f_ceil_tick(float p) =>
    float mt = syminfo.mintick
    mt > 0 ? math.ceil(p / mt) * mt : p
f_hash_color(color c) =>
    str.format('{0},{1},{2},{3}', color.r(c), color.g(c), color.b(c), color.t(c))
f_hide_all_visuals() =>
    f_hide_box(panel_box)
    int rb_n = array.size(row_boxes)
    if rb_n > 0
        for i = 0 to rb_n - 1 by 1
            f_hide_box(array.get(row_boxes, i))
    int zb_n = array.size(lvg_boxes)
    if zb_n > 0
        for i = 0 to zb_n - 1 by 1
            f_hide_box(array.get(lvg_boxes, i))
    int ds_n = array.size(delta_strip_boxes)
    if ds_n > 0
        for i = 0 to ds_n - 1 by 1
            f_hide_box(array.get(delta_strip_boxes, i))
    int sb_n = array.size(split_buy_boxes)
    if sb_n > 0
        for i = 0 to sb_n - 1 by 1
            f_hide_box(array.get(split_buy_boxes, i))
    int ss_n = array.size(split_sell_boxes)
    if ss_n > 0
        for i = 0 to ss_n - 1 by 1
            f_hide_box(array.get(split_sell_boxes, i))
    f_hide_line(poc_line)
    f_hide_line(vah_line)
    f_hide_line(val_line)
    f_hide_line(hi_line)
    f_hide_line(lo_line)
    int hn = array.size(hvn_lines)
    if hn > 0
        for i = 0 to hn - 1 by 1
            f_hide_line(array.get(hvn_lines, i))
    int ln = array.size(lvn_lines)
    if ln > 0
        for i = 0 to ln - 1 by 1
            f_hide_line(array.get(lvn_lines, i))
    int hb = array.size(hvn_boxes)
    if hb > 0
        for i = 0 to hb - 1 by 1
            f_hide_box(array.get(hvn_boxes, i))
    int lb = array.size(lvn_boxes)
    if lb > 0
        for i = 0 to lb - 1 by 1
            f_hide_box(array.get(lvn_boxes, i))
    f_hide_label(level_label)
    f_hide_label(warn_label)
    int al_n = array.size(avwap_lines)
    if al_n > 0
        for i = 0 to al_n - 1 by 1
            f_hide_line(array.get(avwap_lines, i))
    int apl_n = array.size(avwap_labels)
    if apl_n > 0
        for i = 0 to apl_n - 1 by 1
            f_hide_label(array.get(avwap_labels, i))
    int nl_n = array.size(npoc_lines)
    if nl_n > 0
        for i = 0 to nl_n - 1 by 1
            f_hide_line(array.get(npoc_lines, i))
    int npl_n = array.size(npoc_labels_pool)
    if npl_n > 0
        for i = 0 to npl_n - 1 by 1
            f_hide_label(array.get(npoc_labels_pool, i))
    int hpl_in_n = array.size(hist_poc_lines_in_period)
    if hpl_in_n > 0
        for i = 0 to hpl_in_n - 1 by 1
            f_hide_line(array.get(hist_poc_lines_in_period, i))
    int hpl_ext_n = array.size(hist_poc_lines_extended)
    if hpl_ext_n > 0
        for i = 0 to hpl_ext_n - 1 by 1
            f_hide_line(array.get(hist_poc_lines_extended, i))
    int hpll_n = array.size(hist_poc_labels_pool)
    if hpll_n > 0
        for i = 0 to hpll_n - 1 by 1
            f_hide_label(array.get(hist_poc_labels_pool, i))
    int ctx_ib_n = array.size(ctx_ib_lines)
    if ctx_ib_n > 0
        for i = 0 to ctx_ib_n - 1 by 1
            f_hide_line(array.get(ctx_ib_lines, i))
    int ctx_pd_n = array.size(ctx_pd_lines)
    if ctx_pd_n > 0
        for i = 0 to ctx_pd_n - 1 by 1
            f_hide_line(array.get(ctx_pd_lines, i))
f_ensure_row_boxes(int count) =>
    while array.size(row_boxes) < count
        array.push(row_boxes, box.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, bgcolor = color.new(color.black, 100), border_color = color.new(color.black, 100)))
    while array.size(row_boxes) > count
        box.delete(array.pop(row_boxes))
    int n = array.size(row_boxes)
    if n > 0
        for i = 0 to n - 1 by 1
            box rb = array.get(row_boxes, i)
            if na(rb)
                array.set(row_boxes, i, box.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, bgcolor = color.new(color.black, 100), border_color = color.new(color.black, 100)))
f_ensure_line_pool(array<line> pool, int count) =>
    while array.size(pool) < count
        array.push(pool, line.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, color = color.new(color.black, 100)))
    while array.size(pool) > count
        line.delete(array.pop(pool))
    int n = array.size(pool)
    if n > 0
        for i = 0 to n - 1 by 1
            line ln = array.get(pool, i)
            if na(ln)
                array.set(pool, i, line.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, color = color.new(color.black, 100)))
f_ensure_node_boxes(array<box> pool, int count) =>
    while array.size(pool) < count
        array.push(pool, box.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, bgcolor = color.new(color.black, 100), border_color = color.new(color.black, 100), extend = extend.none))
    while array.size(pool) > count
        box.delete(array.pop(pool))
    int n = array.size(pool)
    if n > 0
        for i = 0 to n - 1 by 1
            box bx = array.get(pool, i)
            if na(bx)
                array.set(pool, i, box.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, bgcolor = color.new(color.black, 100), border_color = color.new(color.black, 100), extend = extend.none))
f_ensure_lvg_boxes(int count) =>
    while array.size(lvg_boxes) < count
        array.push(lvg_boxes, box.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, bgcolor = color.new(color.black, 100), border_color = color.new(color.black, 100), extend = extend.none))
    while array.size(lvg_boxes) > count
        box.delete(array.pop(lvg_boxes))
    int n = array.size(lvg_boxes)
    if n > 0
        for i = 0 to n - 1 by 1
            box zb = array.get(lvg_boxes, i)
            if na(zb)
                array.set(lvg_boxes, i, box.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, bgcolor = color.new(color.black, 100), border_color = color.new(color.black, 100), extend = extend.none))
f_ensure_box_pool(array<box> pool, int count) =>
    while array.size(pool) < count
        array.push(pool, box.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, bgcolor = color.new(color.black, 100), border_color = color.new(color.black, 100)))
    while array.size(pool) > count
        box.delete(array.pop(pool))
    int n = array.size(pool)
    if n > 0
        for i = 0 to n - 1 by 1
            box bx = array.get(pool, i)
            if na(bx)
                array.set(pool, i, box.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, bgcolor = color.new(color.black, 100), border_color = color.new(color.black, 100)))
f_ensure_label_pool(array<label> pool, int count) =>
    while array.size(pool) < count
        array.push(pool, label.new(bar_index, close, '', xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.new(color.black, 100), size = size.small))
    while array.size(pool) > count
        label.delete(array.pop(pool))
    int n = array.size(pool)
    if n > 0
        for i = 0 to n - 1 by 1
            label lb = array.get(pool, i)
            if na(lb)
                array.set(pool, i, label.new(bar_index, close, '', xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.new(color.black, 100), size = size.small))
f_count_active_session_boxes() =>
    int n = 0
    n += not na(b_lon) ? 1 : 0
    n += not na(b_ny) ? 1 : 0
    n += not na(b_tok) ? 1 : 0
    n += not na(b_syd) ? 1 : 0
    n
f_delta_sign_i(float o, float c, float c_prev, int last_sign, int src_mode, int neut_mode) =>
    int sign = src_mode == 1 ? (c > c_prev ? 1 : c < c_prev ? -1 : 0) : (c > o ? 1 : c < o ? -1 : 0)
    if sign == 0
        if neut_mode == 1
            sign := last_sign
        else if neut_mode == 2
            sign := 99
    sign
f_of_native_available_for_bar(footprint_handle) =>
    not na(footprint_handle)
f_ctx_src_mode() =>
    OF_DELTA_SRC_MODE
f_ctx_neut_mode() =>
    OF_NEUTRAL_MODE
f_ctx_delta_for_bar(float o, float c, float c_prev, float vol, int src_mode, int neut_mode, int last_sign) =>
    int sign = f_delta_sign_i(o, c, c_prev, last_sign, src_mode, neut_mode)
    float delta = 0.0
    int next_last_sign = last_sign
    if sign == 1 or sign == -1
        delta := vol * sign
        next_last_sign := sign
    [delta, next_last_sign, sign]
f_npoc_touch(float lvl) =>
    float tol = syminfo.mintick * npoc_touch_ticks
    bool wick_touch = not na(lvl) and low <= lvl and high >= lvl
    bool close_cross = not na(lvl) and ((close >= lvl and close[1] < lvl) or (close <= lvl and close[1] > lvl) or math.abs(close - lvl) <= tol)
    bool close_within = not na(lvl) and math.abs(close - lvl) <= tol
    npoc_touch_rule == 'Wick touch' ? wick_touch : npoc_touch_rule == 'Close touch' ? close_cross : close_within
f_npoc_find_idx(int start_idx, string kind, string tag_txt) =>
    int out = -1
    int n = array.size(npoc_start_idx)
    if n > 0
        for i = 0 to n - 1 by 1
            if array.get(npoc_start_idx, i) == start_idx and array.get(npoc_kind, i) == kind and array.get(npoc_tag, i) == tag_txt
                out := i
                break
    out
f_npoc_compute_poc_from_buffer(array<float> lo_buf, array<float> hi_buf, array<float> vol_buf, int bins_desired) =>
    float poc = na
    int n = array.size(lo_buf)
    if n > 0
        float pmin_w = na
        float pmax_w = na
        for i = 0 to n - 1 by 1
            float lo = array.get(lo_buf, i)
            float hi = array.get(hi_buf, i)
            if not na(lo) and not na(hi)
                pmin_w := na(pmin_w) ? lo : math.min(pmin_w, lo)
                pmax_w := na(pmax_w) ? hi : math.max(pmax_w, hi)
        float span = (na(pmin_w) or na(pmax_w)) ? na : (pmax_w - pmin_w)
        if not na(span) and span > syminfo.mintick * 0.5
            int bins = math.min(600, math.max(120, bins_desired))
            float step = span / bins
            if step > 0
                float inv = 1.0 / step
                array<float> diff = array.new_float(bins + 1, 0.0)
                int cap = 4000
                int stride = math.max(1, int(math.ceil(float(n) / float(cap))))
                for i = 0 to n - 1 by stride
                    float lo = array.get(lo_buf, i)
                    float hi = array.get(hi_buf, i)
                    float vol = array.get(vol_buf, i) * stride
                    if not na(lo) and not na(hi) and not na(vol) and vol != 0
                        float a_lo = math.min(lo, hi)
                        float a_hi = math.max(lo, hi)
                        int lo_idx = int(math.floor((a_lo - pmin_w) * inv))
                        int hi_idx = int(math.floor((a_hi - pmin_w) * inv))
                        lo_idx := math.max(0, math.min(bins - 1, lo_idx))
                        hi_idx := math.max(0, math.min(bins - 1, hi_idx))
                        int span_i = hi_idx - lo_idx + 1
                        float add = vol / math.max(1, span_i)
                        array.set(diff, lo_idx, array.get(diff, lo_idx) + add)
                        if hi_idx + 1 < bins + 1
                            array.set(diff, hi_idx + 1, array.get(diff, hi_idx + 1) - add)
                float run = 0.0
                float vmax = -1.0
                int imax = 0
                for i = 0 to bins - 1 by 1
                    run += array.get(diff, i)
                    if run > vmax
                        vmax := run
                        imax := i
                poc := pmin_w + (imax + 0.5) * step
    poc
f_ctx_compute_prev_profile(array<float> lo_buf, array<float> hi_buf, array<float> vol_buf, int bins_desired, float va_frac) =>
    float poc = na
    float vah = na
    float val = na
    int n = math.min(array.size(lo_buf), math.min(array.size(hi_buf), array.size(vol_buf)))
    if n > 0
        float pmin_w = na
        float pmax_w = na
        for i = 0 to n - 1 by 1
            float lo = array.get(lo_buf, i)
            float hi = array.get(hi_buf, i)
            if not na(lo) and not na(hi)
                pmin_w := na(pmin_w) ? lo : math.min(pmin_w, lo)
                pmax_w := na(pmax_w) ? hi : math.max(pmax_w, hi)
        float span = (na(pmin_w) or na(pmax_w)) ? na : (pmax_w - pmin_w)
        if not na(span) and span > syminfo.mintick * 0.5
            int bins = math.min(220, math.max(80, bins_desired))
            float step = span / bins
            if step > 0
                float inv = 1.0 / step
                array<float> diff = array.new_float(bins + 1, 0.0)
                int cap = 4000
                int stride = math.max(1, int(math.ceil(float(n) / float(cap))))
                for i = 0 to n - 1 by stride
                    float lo = array.get(lo_buf, i)
                    float hi = array.get(hi_buf, i)
                    float vol = array.get(vol_buf, i) * stride
                    if not na(lo) and not na(hi) and not na(vol) and vol > 0
                        float a_lo = math.min(lo, hi)
                        float a_hi = math.max(lo, hi)
                        int lo_idx = int(math.floor((a_lo - pmin_w) * inv))
                        int hi_idx = int(math.floor((a_hi - pmin_w) * inv))
                        lo_idx := math.max(0, math.min(bins - 1, lo_idx))
                        hi_idx := math.max(0, math.min(bins - 1, hi_idx))
                        int span_i = hi_idx - lo_idx + 1
                        float add = vol / math.max(1, span_i)
                        array.set(diff, lo_idx, array.get(diff, lo_idx) + add)
                        if hi_idx + 1 < bins + 1
                            array.set(diff, hi_idx + 1, array.get(diff, hi_idx + 1) - add)
                array<float> vol_bins = array.new_float(bins, 0.0)
                float run = 0.0
                float vmax = -1.0
                int imax = 0
                float total_vol = 0.0
                for i = 0 to bins - 1 by 1
                    run += array.get(diff, i)
                    float vb = math.max(0.0, run)
                    array.set(vol_bins, i, vb)
                    total_vol += vb
                    if vb > vmax
                        vmax := vb
                        imax := i
                if total_vol > 0
                    float target = total_vol * math.max(0.01, math.min(1.0, va_frac))
                    int left = imax
                    int right = imax
                    float cum = array.get(vol_bins, imax)
                    while cum < target and (left > 0 or right < bins - 1)
                        float left_next = left > 0 ? array.get(vol_bins, left - 1) : -1.0
                        float right_next = right < bins - 1 ? array.get(vol_bins, right + 1) : -1.0
                        if right_next > left_next
                            right += 1
                            cum += math.max(0.0, right_next)
                        else
                            left -= 1
                            cum += math.max(0.0, left_next)
                    poc := pmin_w + (imax + 0.5) * step
                    val := pmin_w + left * step
                    vah := pmin_w + (right + 1.0) * step
    [poc, vah, val]
const int CTX_PREV_BINS = 160
const int CTX_PREV_MIN_BARS = 10
f_npoc_push_candidate(float lvl, int st, int en, string kind, string tag_txt, int tag_ord, int ord_counter) =>
    int ord_next = ord_counter
    if not na(lvl) and f_npoc_find_idx(st, kind, tag_txt) == -1
        ord_next += 1
        array.push(npoc_price, lvl)
        array.push(npoc_start_idx, st)
        array.push(npoc_close_idx, en)
        array.push(npoc_kind, kind)
        array.push(npoc_tag, tag_txt)
        array.push(npoc_tag_ord, tag_ord)
        array.push(npoc_ord, ord_next)
        array.push(npoc_tested, false)
        array.push(npoc_test_win_age, 0)
    ord_next
f_npoc_trim_cache(int cap) =>
    while array.size(npoc_price) > cap
        array.shift(npoc_price)
        array.shift(npoc_start_idx)
        array.shift(npoc_close_idx)
        array.shift(npoc_kind)
        array.shift(npoc_tag)
        array.shift(npoc_tag_ord)
        array.shift(npoc_ord)
        array.shift(npoc_tested)
        array.shift(npoc_test_win_age)
f_get_visible_indices() =>
    int right_idx = ta.valuewhen(time <= chart.right_visible_bar_time, bar_index, 0)
    int left_before = ta.valuewhen(time < chart.left_visible_bar_time, bar_index, 0)
    int left_idx = na(left_before) ? 0 : left_before + 1
    right_idx := na(right_idx) ? bar_index : right_idx
    left_idx := math.max(0, math.min(left_idx, right_idx))
    int span = right_idx - left_idx + 1
    if span > MAX_BARS_BACK
        left_idx := right_idx - (MAX_BARS_BACK - 1)
    [left_idx, right_idx]
f_resolve_range_indices(string mode, int vis_left_idx, int vis_right_idx, int fixed_lb, bool current_only, int cap_session, int session_comp_n, int sess_start0_idx, int sess_start1_idx, int sess_startN_idx, int bar_comp_start_idx) =>
    int avail_left = math.max(0, bar_index - (MAX_BARS_BACK - 1))
    int right_idx = last_bar_index
    int left_idx = avail_left
    int bars_in_range = 1
    bool anchored = true
    int reason_code = 8
    bool mode_vis = mode == 'Visible Range'
    bool mode_vis_anchor = mode == 'Visible Range (Right Anchored)'
    bool mode_fixed = mode == 'Fixed Lookback Bars'
    bool mode_all = mode == 'All Loaded Bars (Current TF)'
    bool mode_sess_cur = mode == 'Session (Current)'
    bool mode_sess_prevcur = mode == 'Session (Prev+Current)'
    bool mode_sess_comp = mode == 'Session Composite (N)'
    bool mode_bar_comp = mode == 'Bar Composite (N)'
    bool mode_4h = mode == '4H (Prev+Current)'
    bool mode_d = mode == 'D (Prev+Current)'
    bool mode_w = mode == 'W (Prev+Current)'
    bool mode_m = mode == 'M (Prev+Current)'
    bool mode_3m = mode == '3M (Prev+Current)'
    bool mode_12m = mode == '12M (Prev+Current)'
    bool mode_htf = mode_4h or mode_d or mode_w or mode_m or mode_3m or mode_12m
    if mode_all
        bars_in_range := math.min(MAX_BARS_BACK, last_bar_index + 1)
        left_idx := right_idx - bars_in_range + 1
        reason_code := 1
    else if mode_fixed
        bars_in_range := math.max(1, math.min(MAX_BARS_BACK, fixed_lb))
        left_idx := right_idx - bars_in_range + 1
        reason_code := 2
    else if mode_vis or mode_vis_anchor
        int right_vis = mode_vis ? (na(vis_right_idx) ? right_idx : vis_right_idx) : right_idx
        int left_vis = na(vis_left_idx) ? right_vis - 500 + 1 : vis_left_idx
        right_idx := math.max(0, math.min(last_bar_index, right_vis))
        left_idx := math.max(left_vis, right_idx - MAX_BARS_BACK + 1)
        bars_in_range := right_idx - left_idx + 1
        anchored := mode_vis_anchor
        reason_code := na(vis_left_idx) ? 4 : 3
    else if mode_sess_cur or mode_sess_prevcur or mode_sess_comp
        int sess_left =
             mode_sess_cur ? sess_start0_idx :
             mode_sess_prevcur ? sess_start1_idx :
             session_comp_n <= 2 ? sess_start1_idx : sess_startN_idx
        int sess_cap_bars = math.max(1, math.min(MAX_BARS_BACK, cap_session))
        int sess_cap_left = right_idx - sess_cap_bars + 1
        bool sess_fallback = na(sess_left)
        left_idx := sess_fallback ? sess_cap_left : math.max(sess_left, sess_cap_left)
        reason_code := sess_fallback ? 6 : 5
    else if mode_bar_comp
        left_idx := na(bar_comp_start_idx) ? avail_left : bar_comp_start_idx
        reason_code := 7
    else if mode_htf
        string htf_tf = mode_4h ? '240' : mode_d ? 'D' : mode_w ? 'W' : mode_m ? 'M' : mode_3m ? '3M' : '12M'
        int chart_sec = timeframe.in_seconds(timeframe.period)
        int htf_sec = timeframe.in_seconds(htf_tf)
        int htf_mult = current_only ? 1 : 2
        int htf_window_sec = (not na(htf_sec) and htf_sec > 0) ? htf_sec * htf_mult : na
        int bars_est = (not na(chart_sec) and chart_sec > 0 and not na(htf_window_sec)) ? int(math.ceil(float(htf_window_sec) / float(chart_sec))) + 2 : 1
        bars_in_range := math.max(1, math.min(MAX_BARS_BACK, bars_est))
        left_idx := right_idx - bars_in_range + 1
        reason_code := 7
    else
        bars_in_range := 1
        left_idx := right_idx
        reason_code := 8
    left_idx := math.max(avail_left, math.min(right_idx, left_idx))
    bars_in_range := right_idx - left_idx + 1
    bars_in_range := math.max(1, math.min(MAX_BARS_BACK, bars_in_range))
    left_idx := right_idx - bars_in_range + 1
    [left_idx, right_idx, bars_in_range, anchored, reason_code]
f_session_str(string preset, string custom) =>
    preset == 'Trading Sessions: London' ? london_sess :
     preset == 'Trading Sessions: New York' ? ny_sess :
     preset == 'Trading Sessions: Tokyo' ? tokyo_sess :
     preset == 'Trading Sessions: Sydney' ? sydney_sess :
     custom
f_session_tz() =>
    sess_timezone
f_in_session(string sess, string tz) =>
    not na(time(timeframe.period, sess, tz))
f_roll_is_weekend() =>
    bool is_24x7 = syminfo.type == 'crypto'
    bool is_weekend = dayofweek == dayofweek.saturday or dayofweek == dayofweek.sunday
    not is_24x7 and is_weekend
f_roll_enabled(string key) =>
    key == 'LON' ? london_show :
     key == 'NY' ? ny_show :
     key == 'TOK' ? tokyo_show :
     sydney_show
f_session_n(string opt) =>
    opt == '2' ? 2 : opt == '5' ? 5 : 20
f_session_window_seconds(string mode, int comp_n) =>
    mode == 'Session (Current)' ? 24 * 60 * 60 :
     mode == 'Session (Prev+Current)' ? 48 * 60 * 60 :
     mode == 'Session Composite (N)' ? math.max(1, comp_n) * 24 * 60 * 60 :
     na
f_is_full_day_session(string sess_str) =>
    str.length(sess_str) >= 9 and str.substring(sess_str, 0, 9) == '0000-0000'
f_bin_idx(float p, float p_min, float inv_step, int bins) =>
    int idx = int(math.floor((p - p_min) * inv_step))
    idx < 0 ? 0 : idx >= bins ? bins - 1 : idx
f_compute_internal_bins(float p_range) =>
    int b = internal_bins_mode == '800' ? 800 : internal_bins_mode == '1200' ? 1200 : internal_bins_mode == '1600' ? 1600 : internal_bins_mode == '2000' ? 2000 : int(math.round(p_range / syminfo.mintick))
    b := math.max(800, math.min(2000, b))
    b
f_is_ltf_valid(string ltf_resolved) =>
    int chart_sec = timeframe.in_seconds(timeframe.period)
    int ltf_sec = timeframe.in_seconds(ltf_resolved)
    not na(chart_sec) and not na(ltf_sec) and ltf_sec > 0 and ltf_sec < chart_sec
f_resample_sum(array<float> src, int src_n, array<float> dst, int dst_n) =>
    if src_n <= 0 or dst_n <= 0
        na
    else
        float scale = float(src_n) / float(dst_n)
        for r = 0 to dst_n - 1 by 1
            float a = r * scale
            float b = (r + 1) * scale
            int ia = int(math.floor(a))
            int ib = int(math.ceil(b)) - 1
            float sum = 0.0
            for i = ia to ib by 1
                if i >= 0 and i < src_n
                    float left = math.max(a, i)
                    float right = math.min(b, i + 1.0)
                    float w = math.max(0.0, right - left)
                    sum := sum + array.get(src, i) * w
                    sum
            array.set(dst, r, sum)
f_pick_nodes(array<int> out_idx, array<float> vol, int rows, bool maxima, int wanted, int min_sep, float thr_abs) =>
    array.clear(out_idx)
    array<int> cand_idx = array.new_int(0)
    array<float> cand_score = array.new_float(0)
    int win = math.max(2, min_sep)
    if rows >= 3 and wanted > 0
        for i = 1 to rows - 2 by 1
            float v1 = array.get(vol, i)
            int l = math.max(0, i - win)
            int r = math.min(rows - 1, i + win)
            float local_best = v1
            float local_worst = v1
            for k = l to r by 1
                if k != i
                    float vk = array.get(vol, k)
                    local_best := math.max(local_best, vk)
                    local_worst := math.min(local_worst, vk)
            bool is_ext = maxima ? (v1 >= local_best and v1 >= thr_abs) : (v1 <= local_worst and v1 <= thr_abs)
            if is_ext
                float prominence = maxima ? (v1 - local_worst) : (local_best - v1)
                if prominence > 0
                    array.push(cand_idx, i)
                    array.push(cand_score, prominence)
        int csz = array.size(cand_idx)
        int pick_count = math.min(wanted, csz)
        if pick_count > 0
            for _ = 0 to pick_count - 1 by 1
                int best_j = -1
                float best_s = na
                for j = 0 to csz - 1 by 1
                    int idx = array.get(cand_idx, j)
                    float sc = array.get(cand_score, j)
                    bool ok = true
                    int out_n = array.size(out_idx)
                    if out_n > 0
                        for p = 0 to out_n - 1 by 1
                            if math.abs(idx - array.get(out_idx, p)) < min_sep
                                ok := false
                                ok
                    if ok and (best_j == -1 or sc > best_s)
                        best_j := j
                        best_s := sc
                        best_s
                if best_j != -1
                    array.push(out_idx, array.get(cand_idx, best_j))
f_pick_relative_nodes(array<int> out_idx, array<float> vol, int rows, bool maxima, int wanted, int min_sep, float thr_abs) =>
    array.clear(out_idx)
    f_pick_nodes(out_idx, vol, rows, maxima, wanted, min_sep, thr_abs)
f_merge_unique_ranked(array<int> out_idx, array<int> abs_idx, array<int> rel_idx, int max_total) =>
    array.clear(out_idx)
    if max_total <= 0
        na
    else
        int a_n = array.size(abs_idx)
        int r_n = array.size(rel_idx)
        if a_n > 0
            for i = 0 to a_n - 1 by 1
                if array.size(out_idx) < max_total
                    array.push(out_idx, array.get(abs_idx, i))
        if r_n > 0
            for i = 0 to r_n - 1 by 1
                if array.size(out_idx) < max_total
                    int idx = array.get(rel_idx, i)
                    bool exists = false
                    int out_n = array.size(out_idx)
                    if out_n > 0
                        for j = 0 to out_n - 1 by 1
                            if array.get(out_idx, j) == idx
                                exists := true
                                exists
                    if not exists
                        array.push(out_idx, idx)
f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))
f_add_uniform_range(array<float> diff, float lo, float hi, float vol, float p_min, float inv_step, int bins) =>
    if na(lo) or na(hi) or na(vol)
        na
    else if vol == 0
        na
    else
        float a_lo = math.min(lo, hi)
        float a_hi = math.max(lo, hi)
        int lo_idx = f_bin_idx(a_lo, p_min, inv_step, bins)
        int hi_idx = f_bin_idx(a_hi, p_min, inv_step, bins)
        int span = hi_idx - lo_idx + 1
        float add = vol / math.max(1, span)
        array.set(diff, lo_idx, array.get(diff, lo_idx) + add)
        if hi_idx + 1 < bins + 1
            array.set(diff, hi_idx + 1, array.get(diff, hi_idx + 1) - add)
f_of_accumulate_native_row_into_bins(array<float> diff_total, array<float> diff_buy, array<float> diff_sell, float row_lo, float row_hi, float buy_vol, float sell_vol, bool include_sides, float p_min, float inv_step, int bins) =>
    if na(row_lo) or na(row_hi) or bins <= 0 or inv_step <= 0
        na
    else
        float a_lo = math.min(row_lo, row_hi)
        float a_hi = math.max(row_lo, row_hi)
        float step = 1.0 / inv_step
        float span = a_hi - a_lo
        float total_vol = nz(buy_vol) + nz(sell_vol)
        if span <= 0
            int idx = f_bin_idx(a_lo, p_min, inv_step, bins)
            array.set(diff_total, idx, array.get(diff_total, idx) + total_vol)
            if idx + 1 < bins + 1
                array.set(diff_total, idx + 1, array.get(diff_total, idx + 1) - total_vol)
            if include_sides
                array.set(diff_buy, idx, array.get(diff_buy, idx) + nz(buy_vol))
                array.set(diff_sell, idx, array.get(diff_sell, idx) + nz(sell_vol))
                if idx + 1 < bins + 1
                    array.set(diff_buy, idx + 1, array.get(diff_buy, idx + 1) - nz(buy_vol))
                    array.set(diff_sell, idx + 1, array.get(diff_sell, idx + 1) - nz(sell_vol))
        else
            int lo_idx = f_bin_idx(a_lo, p_min, inv_step, bins)
            int hi_idx = f_bin_idx(a_hi, p_min, inv_step, bins)
            for bi = lo_idx to hi_idx by 1
                float bin_lo = p_min + float(bi) * step
                float bin_hi = bin_lo + step
                float ov_lo = math.max(a_lo, bin_lo)
                float ov_hi = math.min(a_hi, bin_hi)
                float ov = math.max(0.0, ov_hi - ov_lo)
                if ov > 0
                    float ratio = ov / span
                    float t_part = total_vol * ratio
                    array.set(diff_total, bi, array.get(diff_total, bi) + t_part)
                    if bi + 1 < bins + 1
                        array.set(diff_total, bi + 1, array.get(diff_total, bi + 1) - t_part)
                    if include_sides
                        float b_part = nz(buy_vol) * ratio
                        float s_part = nz(sell_vol) * ratio
                        array.set(diff_buy, bi, array.get(diff_buy, bi) + b_part)
                        array.set(diff_sell, bi, array.get(diff_sell, bi) + s_part)
                        if bi + 1 < bins + 1
                            array.set(diff_buy, bi + 1, array.get(diff_buy, bi + 1) - b_part)
                            array.set(diff_sell, bi + 1, array.get(diff_sell, bi + 1) - s_part)
f_add_weighted_ohlc(array<float> diff, float o, float h, float l, float c, float vol, float p_min, float inv_step, int bins, float body_mult) =>
    if na(h) or na(l) or na(vol)
        na
    else if vol == 0
        na
    else
        float hi = math.max(h, l)
        float lo = math.min(h, l)
        if na(o) or na(c)
            f_add_uniform_range(diff, lo, hi, vol, p_min, inv_step, bins)
        else
            float b0 = f_clamp(math.min(o, c), lo, hi)
            float b1 = f_clamp(math.max(o, c), lo, hi)
            float body_len = b1 - b0
            float lw_len = b0 - lo
            float uw_len = hi - b1
            float denom = body_mult * body_len + lw_len + uw_len
            if denom <= 0
                f_add_uniform_range(diff, lo, hi, vol, p_min, inv_step, bins)
            else
                float v_body = vol * (body_mult * body_len) / denom
                float v_lw = vol * lw_len / denom
                float v_uw = vol * uw_len / denom
                if lw_len > 0 and v_lw > 0
                    f_add_uniform_range(diff, lo, b0, v_lw, p_min, inv_step, bins)
                if body_len > 0 and v_body > 0
                    f_add_uniform_range(diff, b0, b1, v_body, p_min, inv_step, bins)
                if uw_len > 0 and v_uw > 0
                    f_add_uniform_range(diff, b1, hi, v_uw, p_min, inv_step, bins)
f_idx_in_loaded_window(int bi) =>
    int off = bar_index - bi
    off >= 0 and off <= (MAX_BARS_BACK - 1)
f_collect_range_price_bounds(int left_idx, int right_idx) =>
    float pmin_w = na
    float pmax_w = na
    int sampled_bars = 0
    for bi = left_idx to right_idx by 1
        if f_idx_in_loaded_window(bi)
            int off = bar_index - bi
            float lo = low[off]
            float hi = high[off]
            if not na(lo) and not na(hi)
                sampled_bars += 1
                pmin_w := na(pmin_w) ? lo : math.min(pmin_w, lo)
                pmax_w := na(pmax_w) ? hi : math.max(pmax_w, hi)
    [pmin_w, pmax_w, sampled_bars]
f_clamp_loaded_bar_range(int left_idx, int right_idx) =>
    int oldest_idx = math.max(0, bar_index - (MAX_BARS_BACK - 1))
    int left_eff = not na(left_idx) ? math.max(oldest_idx, left_idx) : na
    int right_eff = not na(right_idx) ? math.min(bar_index, right_idx) : na
    bool range_ok = not na(left_eff) and not na(right_eff) and left_eff <= right_eff and left_eff >= 0
    [left_eff, right_eff, range_ok]
f_range_bins_clamped(int bins_desired, int min_bins) =>
    math.min(600, math.max(min_bins, bins_desired))
f_hist_poc_compute_range_poc(int left_idx, int right_idx, int bins_desired) =>
    float poc = na
    [left_eff, right_eff, range_ok] = f_clamp_loaded_bar_range(left_idx, right_idx)
    if range_ok
        int bar_count = right_eff - left_eff + 1
        [pmin_w, pmax_w, sampled_bars] = f_collect_range_price_bounds(left_eff, right_eff)
        bool range_non_empty = bar_count > 0 and sampled_bars > 0
        bool prices_ok = range_non_empty and not na(pmin_w) and not na(pmax_w) and pmax_w > pmin_w
        float span = prices_ok ? (pmax_w - pmin_w) : na
        bool span_ok = prices_ok and not na(span) and span > syminfo.mintick * 0.5
        if span_ok
            int bins = f_range_bins_clamped(bins_desired, 80)
            float step = span / bins
            if step > 0
                float inv = 1.0 / step
                array<float> diff = array.new_float(bins + 1, 0.0)
                int stride = math.max(1, int(math.ceil(float(bar_count) / float(4000))))
                bool weighted_dist = dist_mode == 'Body Weighted'
                for bi = left_eff to right_eff by stride
                    if f_idx_in_loaded_window(bi)
                        int off = bar_index - bi
                        float vol = volume[off] * stride
                        if weighted_dist
                            f_add_weighted_ohlc(diff, open[off], high[off], low[off], close[off], vol, pmin_w, inv, bins, body_weight_mult)
                        else
                            f_add_uniform_range(diff, low[off], high[off], vol, pmin_w, inv, bins)
                float run = 0.0
                float vmax = na
                int imax = 0
                for i = 0 to bins - 1 by 1
                    run += array.get(diff, i)
                    float v = math.max(0.0, run)
                    if na(vmax) or v > vmax
                        vmax := v
                        imax := i
                poc := f_snap_tick(pmin_w + (imax + 0.5) * step)
    poc
f_sorted_copy(array<float> vol, int rows) =>
    array<float> cp = array.new_float(0)
    for i = 0 to rows - 1 by 1
        array.push(cp, array.get(vol, i))
    array.sort(cp, order.ascending)
    cp
f_quantile_from_sorted(array<float> cp, int rows, float q) =>
    int qi = int(math.floor((rows - 1) * q))
    qi := math.max(0, math.min(rows - 1, qi))
    array.get(cp, qi)
f_lvg_tf_scale() =>
    int cs = timeframe.in_seconds(timeframe.period)
    if na(cs)
        1.0
    else
        cs <= 5 * 60 ? 1.15 :
         cs <= 60 * 60 ? 1.00 :
         cs <= 4 * 60 * 60 ? 0.92 :
         cs <= 24 * 60 * 60 ? 0.85 :
         cs <= 7 * 24 * 60 * 60 ? 0.75 :
         cs <= 31 * 24 * 60 * 60 ? 0.65 :
         0.60
f_lvg_dist_scale(float maxv, float median) =>
    float c = (maxv > 0 and not na(median)) ? (median / maxv) : 0.0
    c < 0.06 ? 0.75 :
     c < 0.10 ? 0.85 :
     c < 0.18 ? 0.95 :
     c < 0.28 ? 1.00 :
     1.08
bool engine_roll_series = session_engine == 'Rolling Trading Sessions (Auto)'
bool need_session_starts = str.contains(range_mode, 'Session') or (ctx_pack_mode != 'Off')
bool ts_weekend_block_series = f_roll_is_weekend()
bool ts_lon_in_base_series = not ts_weekend_block_series and f_in_session(london_sess, sess_timezone)
bool ts_ny_in_base_series = not ts_weekend_block_series and f_in_session(ny_sess, sess_timezone)
bool ts_tok_in_base_series = not ts_weekend_block_series and f_in_session(tokyo_sess, sess_timezone)
bool ts_syd_in_base_series = not ts_weekend_block_series and f_in_session(sydney_sess, sess_timezone)
bool sess_start_series = false
int sess_start0_series = na
int sess_start1_series = na
int sess_startN_occ_series = session_comp_opt == '2' ? 1 : session_comp_opt == '5' ? 4 : 19
int sess_startN_series = na
int roll_active_id = 0
bool in_sess_single_series = false
if need_session_starts
    if engine_roll_series
        bool roll_weekend = f_roll_is_weekend()
        bool roll_lon_en = f_roll_enabled('LON')
        bool roll_ny_en = f_roll_enabled('NY')
        bool roll_tok_en = f_roll_enabled('TOK')
        bool roll_syd_en = f_roll_enabled('SYD')
        bool roll_lon_in = roll_lon_en and not roll_weekend and ts_lon_in_base_series
        bool roll_ny_in = roll_ny_en and not roll_weekend and ts_ny_in_base_series
        bool roll_tok_in = roll_tok_en and not roll_weekend and ts_tok_in_base_series
        bool roll_syd_in = roll_syd_en and not roll_weekend and ts_syd_in_base_series
        bool roll_lon_start = roll_lon_in and not roll_lon_in[1]
        bool roll_ny_start = roll_ny_in and not roll_ny_in[1]
        bool roll_tok_start = roll_tok_in and not roll_tok_in[1]
        bool roll_syd_start = roll_syd_in and not roll_syd_in[1]
        int roll_lon_last = nz(ta.valuewhen(roll_lon_start, bar_index, 0), bar_index)
        int roll_ny_last = nz(ta.valuewhen(roll_ny_start, bar_index, 0), bar_index)
        int roll_tok_last = nz(ta.valuewhen(roll_tok_start, bar_index, 0), bar_index)
        int roll_syd_last = nz(ta.valuewhen(roll_syd_start, bar_index, 0), bar_index)
        int cand_best = na
        roll_active_id := 0
        if roll_syd_in
            cand_best := roll_syd_last
            roll_active_id := 1
        if roll_tok_in and (na(cand_best) or roll_tok_last >= cand_best)
            cand_best := roll_tok_last
            roll_active_id := 2
        if roll_lon_in and (na(cand_best) or roll_lon_last >= cand_best)
            cand_best := roll_lon_last
            roll_active_id := 3
        if roll_ny_in and (na(cand_best) or roll_ny_last >= cand_best)
            cand_best := roll_ny_last
            roll_active_id := 4
        sess_start_series := roll_active_id != 0 and roll_active_id != nz(roll_active_id[1], 0)
    else
        string sess_str_single_series = f_session_str(session_preset, session_custom)
        string sess_tz_single_series = f_session_tz()
        bool sess_full_day_single_series = f_is_full_day_session(sess_str_single_series)
        in_sess_single_series := not na(time(timeframe.period, sess_str_single_series, sess_tz_single_series))
        int day_bucket_single_series = time('D', '0000-0000:1234567', sess_tz_single_series)
        bool day_bucket_single_changed_series = ta.change(day_bucket_single_series) != 0
        bool day_start_single_series = not na(day_bucket_single_series) and day_bucket_single_changed_series
        sess_start_series := sess_full_day_single_series ? (in_sess_single_series and day_start_single_series) : (in_sess_single_series and not in_sess_single_series[1])
    sess_start0_series := ta.valuewhen(sess_start_series, bar_index, 0)
    sess_start1_series := ta.valuewhen(sess_start_series, bar_index, 1)
    sess_startN_series := ta.valuewhen(sess_start_series, bar_index, sess_startN_occ_series)
bool ctx_pack_on = ctx_pack_mode != 'Off'
bool ctx_extras_on = ctx_pack_on and ctx_visual_extras
bool ctx_plot_none_on = ctx_pack_on and (ctx_pane_plot_mode == 'None')
bool ctx_plot_overlay_band = ctx_pack_on and (ctx_pane_plot_mode == 'Overlay (Band)')
bool ctx_in_session_engine = engine_roll_series ? roll_active_id != 0 : in_sess_single_series
bool ctx_pane_reset = sess_start_series and ctx_in_session_engine
bool ctx_pane_break = ctx_pane_reset or ctx_pane_reset[1]
if barstate.isconfirmed
    if ctx_pack_on
        int ctx_src_mode = f_ctx_src_mode()
        int ctx_neut_mode = f_ctx_neut_mode()
        bool ctx_reset = sess_start_series and ctx_in_session_engine
        if ctx_reset
            ctx_seen_session_start := true
            ctx_prev_valid := false
            ctx_pd_poc := na
            ctx_pd_vah := na
            ctx_pd_val := na
            if array.size(ctx_win_vol) >= CTX_PREV_MIN_BARS
                [ctx_prev_poc, ctx_prev_vah, ctx_prev_val] = f_ctx_compute_prev_profile(ctx_win_lo, ctx_win_hi, ctx_win_vol, CTX_PREV_BINS, va_percent / 100.0)
                if not na(ctx_prev_poc) and not na(ctx_prev_vah) and not na(ctx_prev_val)
                    ctx_pd_poc := ctx_prev_poc
                    ctx_pd_vah := ctx_prev_vah
                    ctx_pd_val := ctx_prev_val
                    ctx_prev_valid := true
            array.clear(ctx_win_lo)
            array.clear(ctx_win_hi)
            array.clear(ctx_win_vol)
            array.push(ctx_win_lo, low)
            array.push(ctx_win_hi, high)
            array.push(ctx_win_vol, volume)
            ctx_cvd := 0.0
            ctx_cvd_delta := 0.0
            ctx_cvd_min := ctx_cvd
            ctx_cvd_max := ctx_cvd
            ctx_last_sign := 0
            ctx_ib_start_ts := time
            ctx_ib_end_ts := time + ctx_ib_minutes * 60 * 1000
            ctx_ib_hi := high
            ctx_ib_lo := low
            ctx_ib_done := false
        if ctx_in_session_engine
            [ctx_delta_tmp, ctx_last_sign_tmp, _] = f_ctx_delta_for_bar(open, close, close[1], volume, ctx_src_mode, ctx_neut_mode, ctx_last_sign)
            ctx_cvd += ctx_delta_tmp
            ctx_cvd_delta := ctx_delta_tmp
            ctx_last_sign := ctx_last_sign_tmp
            ctx_cvd_min := na(ctx_cvd_min) ? ctx_cvd : math.min(ctx_cvd_min, ctx_cvd)
            ctx_cvd_max := na(ctx_cvd_max) ? ctx_cvd : math.max(ctx_cvd_max, ctx_cvd)
            if not ctx_reset
                array.push(ctx_win_lo, low)
                array.push(ctx_win_hi, high)
                array.push(ctx_win_vol, volume)
        else
            ctx_cvd_delta := 0.0
        if ctx_in_session_engine and not ctx_ib_done and not na(ctx_ib_end_ts)
            if time <= ctx_ib_end_ts
                ctx_ib_hi := na(ctx_ib_hi) ? high : math.max(ctx_ib_hi, high)
                ctx_ib_lo := na(ctx_ib_lo) ? low : math.min(ctx_ib_lo, low)
            else
                ctx_ib_done := true
        if not ctx_in_session_engine and not ctx_ib_done and not na(ctx_ib_start_ts)
            ctx_ib_done := true
        if ctx_extras_on
            float oi_close = na
            bool oi_can_use = false
            if syminfo.type == 'futures'
                [oi_fut_close, _] = f_ctx_open_interest_futures(syminfo.tickerid, false, false)
                oi_close := oi_fut_close
                oi_can_use := true
            else if syminfo.type == 'crypto'
                string chart_symbol = f_ctx_extract_symbol(syminfo.tickerid)
                string ticker_upper = str.upper(chart_symbol)
                bool is_perp_symbol = str.contains(chart_symbol, '.P') or str.contains(ticker_upper, 'PERP')
                int chart_tf_sec = timeframe.in_seconds(timeframe.period)
                bool tf_valid_for_crypto_oi = not na(chart_tf_sec) and chart_tf_sec >= 60
                if is_perp_symbol and tf_valid_for_crypto_oi
                    [_, _, _, oi_crypto_close, _] = f_ctx_open_interest_crypto(chart_symbol, timeframe.period, false, false)
                    oi_close := oi_crypto_close
                    oi_can_use := true
            ctx_oi := oi_can_use ? oi_close : na
            ctx_oi_delta := (not na(ctx_oi) and not na(ctx_oi[1])) ? (ctx_oi - ctx_oi[1]) : na
            if ctx_reset
                ctx_oi_sess_net := 0.0
                ctx_oi_min := na(ctx_oi) ? na : ctx_oi
                ctx_oi_max := na(ctx_oi) ? na : ctx_oi
            else if ctx_in_session_engine
                ctx_oi_sess_net := nz(ctx_oi_sess_net) + nz(ctx_oi_delta)
            if ctx_in_session_engine and not na(ctx_oi)
                ctx_oi_min := na(ctx_oi_min) ? ctx_oi : math.min(ctx_oi_min, ctx_oi)
                ctx_oi_max := na(ctx_oi_max) ? ctx_oi : math.max(ctx_oi_max, ctx_oi)
        else
            ctx_oi := na
            ctx_oi_delta := na
    else
        ctx_cvd_delta := 0.0
const int CTX_OVL_WIN = 300
float ctx_pr_lo = ta.lowest(low, CTX_OVL_WIN)
float ctx_pr_hi = ta.highest(high, CTX_OVL_WIN)
float ctx_pr_rng = math.max(ctx_pr_hi - ctx_pr_lo, syminfo.mintick * 10)
float ctx_band_lo = ctx_pr_lo + ctx_pr_rng * 0.02
float ctx_band_hi = ctx_pr_lo + ctx_pr_rng * 0.22
float ctx_band_mid = (ctx_band_lo + ctx_band_hi) * 0.5
float ctx_band2_lo = ctx_pr_lo + ctx_pr_rng * 0.24
float ctx_band2_hi = ctx_pr_lo + ctx_pr_rng * 0.34
float ctx_cvd_rng = math.max(nz(ctx_cvd_max - ctx_cvd_min), 1e-9)
float ctx_cvd_n = math.min(math.max((ctx_cvd - ctx_cvd_min) / ctx_cvd_rng, 0.0), 1.0)
float ctx_cvd_ovl_y = (ctx_plot_overlay_band and ctx_in_session_engine and not ctx_pane_break) ? (ctx_band_lo + ctx_cvd_n * (ctx_band_hi - ctx_band_lo)) : na
float ctx_oi_rng = math.max(nz(ctx_oi_max - ctx_oi_min), 1e-9)
float ctx_oi_n = math.min(math.max((ctx_oi - ctx_oi_min) / ctx_oi_rng, 0.0), 1.0)
float ctx_oi_ovl_y = (ctx_plot_overlay_band and ctx_in_session_engine and not ctx_pane_break and not na(ctx_oi) and not na(ctx_oi_min) and not na(ctx_oi_max)) ? (ctx_band2_lo + ctx_oi_n * (ctx_band2_hi - ctx_band2_lo)) : na
const int CTX_DIV_P = 3
const int CTX_DIV_COOLDOWN = 20
float ctx_ph_p = ta.pivothigh(high, CTX_DIV_P, CTX_DIV_P)
float ctx_pl_p = ta.pivotlow(low, CTX_DIV_P, CTX_DIV_P)
bool ctx_new_ph = barstate.isconfirmed and not na(ctx_ph_p)
bool ctx_new_pl = barstate.isconfirmed and not na(ctx_pl_p)
float ctx_cvd_at_ph = ctx_cvd[CTX_DIV_P]
float ctx_cvd_at_pl = ctx_cvd[CTX_DIV_P]
bool ctx_div_cooldown_ok = na(ctx_last_div_bar) or (bar_index - ctx_last_div_bar > CTX_DIV_COOLDOWN)
bool ctx_div_ready = ctx_seen_session_start
bool ctx_bear_div = ctx_extras_on and ctx_div_ready and ctx_new_ph and not na(ctx_ph_p_prev) and not na(ctx_ph_c_prev) and ctx_ph_p > ctx_ph_p_prev and ctx_cvd_at_ph < ctx_ph_c_prev and ctx_div_cooldown_ok
bool ctx_bull_div = ctx_extras_on and ctx_div_ready and ctx_new_pl and not na(ctx_pl_p_prev) and not na(ctx_pl_c_prev) and ctx_pl_p < ctx_pl_p_prev and ctx_cvd_at_pl > ctx_pl_c_prev and ctx_div_cooldown_ok
if barstate.isconfirmed
    if ctx_new_ph
        ctx_ph_p_prev := ctx_ph_p
        ctx_ph_c_prev := ctx_cvd_at_ph
    if ctx_new_pl
        ctx_pl_p_prev := ctx_pl_p
        ctx_pl_c_prev := ctx_cvd_at_pl
    if ctx_bear_div or ctx_bull_div
        ctx_last_div_bar := bar_index - CTX_DIV_P
f_hist_poc_mode_supported(string mode) =>
    mode == 'Bar Composite (N)' or mode == '4H (Prev+Current)' or mode == 'D (Prev+Current)' or mode == 'W (Prev+Current)' or mode == 'M (Prev+Current)' or mode == '3M (Prev+Current)' or mode == '12M (Prev+Current)'
f_normalize_hist_tf(string tf_in) =>
    string tf_clean = str.upper(str.trim(tf_in))
    string tf_norm =
         tf_clean == '1W' ? 'W' :
         tf_clean == '1D' ? 'D' :
         tf_clean == '1M' ? 'M' :
         tf_clean == '4H' ? '240' :
         tf_clean == '240' ? '240' :
         tf_clean == '3M' ? '3M' :
         tf_clean == '12M' ? '12M' :
         tf_clean
    tf_norm
f_tf_boundary_changed(string tf) =>
    string tf_norm = f_normalize_hist_tf(tf)
    bool changed = false
    if tf_norm == '3M'
        int quarter_id_local = year(time) * 10 + int(math.floor((month(time) - 1) / 3)) + 1
        changed := ta.change(quarter_id_local) != 0
    else if tf_norm == '12M'
        int year_id_local = year(time)
        changed := ta.change(year_id_local) != 0
    else
        changed := ta.change(time(tf_norm)) != 0
    changed
f_hist_poc_base_tf(string mode, string comp_tf) =>
    string tf =
         mode == 'Bar Composite (N)' ? f_normalize_hist_tf(comp_tf) :
         mode == '4H (Prev+Current)' ? '240' :
         mode == 'D (Prev+Current)' ? 'D' :
         mode == 'W (Prev+Current)' ? 'W' :
         mode == 'M (Prev+Current)' ? 'M' :
         mode == '3M (Prev+Current)' ? '3M' :
         mode == '12M (Prev+Current)' ? '12M' :
         ''
    tf
f_hist_poc_tf_tag(string tf) =>
    string tf_norm = f_normalize_hist_tf(tf)
    tf_norm == '240' ? '4H' : tf_norm
f_hist_poc_tf_valid(string tf) =>
    string tf_norm = f_normalize_hist_tf(tf)
    tf_norm == '240' or tf_norm == 'D' or tf_norm == 'W' or tf_norm == 'M' or tf_norm == '3M' or tf_norm == '12M'
f_tf_occurrence_start_idx(string tf, int occ) =>
    int occ_safe = math.max(0, occ)
    bool new_tf = f_tf_boundary_changed(tf)
    ta.valuewhen(new_tf, bar_index, occ_safe)
f_hist_tf_occ_idx(string tf, series int age) =>
    string tf_norm = f_normalize_hist_tf(tf)
    int age_safe = math.max(0, math.min(11, age))
    int idx = na
    if tf_norm == '240'
        idx := array.get(hist_240_start_series, age_safe)
    else if tf_norm == 'D'
        idx := array.get(hist_D_start_series, age_safe)
    else if tf_norm == 'W'
        idx := array.get(hist_W_start_series, age_safe)
    else if tf_norm == 'M'
        idx := array.get(hist_M_start_series, age_safe)
    else if tf_norm == '3M'
        idx := array.get(hist_3M_start_series, age_safe)
    else if tf_norm == '12M'
        idx := array.get(hist_12M_start_series, age_safe)
    idx
f_hist_poc_start_idx_for_age(string tf, series int age) =>
    int age_safe = math.max(0, math.min(11, age))
    age_safe == 0 ? nz(f_hist_tf_occ_idx(tf, 0), 0) : f_hist_tf_occ_idx(tf, age_safe)
f_hist_poc_period_bounds(string tf, series int age) =>
    int age_safe = math.max(0, age)
    int start_idx = f_hist_poc_start_idx_for_age(tf, age_safe)
    int prev_start_idx = f_hist_poc_start_idx_for_age(tf, math.max(0, age_safe - 1))
    int newer_start_idx = age_safe > 0 ? prev_start_idx : na
    int end_idx = age_safe == 0 ? last_bar_index : (not na(newer_start_idx) and newer_start_idx > start_idx ? newer_start_idx - 1 : na)
    string tag = f_hist_poc_tf_tag(tf) + '-' + str.tostring(age_safe)
    [start_idx, end_idx, tag]
f_render_hist_pocs(bool hist_enable, string mode_in, string comp_tf_in, int bar_comp_n_in, int hist_count_in, bool show_labels_in, bool fade_by_age_in, int line_budget_eff_in, int label_budget_eff_in, int px1_in) =>
    bool hist_mode_active = hist_enable and f_hist_poc_mode_supported(mode_in)
    string hist_base_tf = f_hist_poc_base_tf(mode_in, comp_tf_in)
    bool hist_tf_ok = str.length(hist_base_tf) > 0 and f_hist_poc_tf_valid(hist_base_tf)
    int hist_count_eff = math.min(12, math.max(1, hist_count_in))
    int hist_line_headroom = math.max(0, line_budget_eff_in - 12)
    int hist_label_headroom = math.max(0, label_budget_eff_in - 4)
    int lines_per_period_budget = 2
    int hist_period_draw_pool = hist_mode_active and hist_tf_ok ? math.min(hist_count_eff, int(math.floor(float(hist_line_headroom) / float(lines_per_period_budget)))) : 0
    int hist_label_pool = hist_mode_active and show_labels_in ? math.min(hist_period_draw_pool, hist_label_headroom) : 0
    f_ensure_line_pool(hist_poc_lines_in_period, hist_period_draw_pool)
    f_ensure_line_pool(hist_poc_lines_extended, hist_period_draw_pool)
    f_ensure_label_pool(hist_poc_labels_pool, hist_label_pool)
    if hist_period_draw_pool > 0
        for i = 0 to hist_period_draw_pool - 1 by 1
            f_hide_line(array.get(hist_poc_lines_in_period, i))
            f_hide_line(array.get(hist_poc_lines_extended, i))
    if hist_label_pool > 0
        for i = 0 to hist_label_pool - 1 by 1
            f_hide_label(array.get(hist_poc_labels_pool, i))
    if hist_mode_active and hist_tf_ok and hist_period_draw_pool > 0
        int draw_period_i = 0
        int oldest_draw_idx = math.max(0, last_bar_index - 9999)
        for age = 0 to 11 by 1
            if age >= hist_count_eff
                break
            if draw_period_i >= hist_period_draw_pool
                break
            [period_start_idx, period_end_idx_raw, period_tag] = f_hist_poc_period_bounds(hist_base_tf, age)
            if not na(period_start_idx) and not na(period_end_idx_raw)
                int period_end_idx = math.min(period_end_idx_raw, last_bar_index)
                bool range_ok = period_start_idx <= period_end_idx and period_start_idx >= 0 and period_start_idx <= last_bar_index and period_end_idx >= oldest_draw_idx
                if range_ok
                    float hpoc = f_hist_poc_compute_range_poc(period_start_idx, period_end_idx, 240)
                    if not na(hpoc)
                        int solid_bi0 = math.max(period_start_idx, oldest_draw_idx)
                        int solid_bi1 = math.max(period_end_idx, oldest_draw_idx)
                        if solid_bi1 >= solid_bi0
                            int alpha = fade_by_age_in ? math.min(80, age * 14) : 8
                            color hist_col = color.new(color.red, alpha)
                            line hln_solid = array.get(hist_poc_lines_in_period, draw_period_i)
                            line.set_xloc(hln_solid, solid_bi0, solid_bi1, xloc.bar_index)
                            line.set_xy1(hln_solid, solid_bi0, hpoc)
                            line.set_xy2(hln_solid, solid_bi1, hpoc)
                            line.set_style(hln_solid, line.style_solid)
                            line.set_width(hln_solid, 1)
                            line.set_extend(hln_solid, extend.none)
                            line.set_color(hln_solid, hist_col)
                            line hln_dash = array.get(hist_poc_lines_extended, draw_period_i)
                            f_hide_line(hln_dash)
                            if extend_level_rays and last_bar_index > period_end_idx
                                int dash_x0 = math.max(period_end_idx, oldest_draw_idx)
                                line.set_xloc(hln_dash, dash_x0, last_bar_index, xloc.bar_index)
                                line.set_xy1(hln_dash, dash_x0, hpoc)
                                line.set_xy2(hln_dash, last_bar_index, hpoc)
                                line.set_style(hln_dash, line.style_dashed)
                                line.set_width(hln_dash, 1)
                                line.set_extend(hln_dash, extend.none)
                                line.set_color(hln_dash, hist_col)
                            if show_labels_in and draw_period_i < hist_label_pool
                                label hlb = array.get(hist_poc_labels_pool, draw_period_i)
                                int anchor_x_raw = extend_level_rays ? last_bar_index : period_end_idx
                                int anchor_x = math.max(anchor_x_raw, oldest_draw_idx)
                                int lxb = math.min(last_bar_index + 500, anchor_x + 1)
                                label.set_xy(hlb, lxb, hpoc)
                                label.set_text(hlb, period_tag + ' POC')
                                label.set_color(hlb, color.new(color.black, 75))
                                label.set_textcolor(hlb, color.new(color.red, 0))
                                label.set_size(hlb, size.tiny)
                            draw_period_i += 1
f_fill_occ12(array<int> arr, bool cond) =>
    array.set(arr, 0, ta.valuewhen(cond, bar_index, 0))
    array.set(arr, 1, ta.valuewhen(cond, bar_index, 1))
    array.set(arr, 2, ta.valuewhen(cond, bar_index, 2))
    array.set(arr, 3, ta.valuewhen(cond, bar_index, 3))
    array.set(arr, 4, ta.valuewhen(cond, bar_index, 4))
    array.set(arr, 5, ta.valuewhen(cond, bar_index, 5))
    array.set(arr, 6, ta.valuewhen(cond, bar_index, 6))
    array.set(arr, 7, ta.valuewhen(cond, bar_index, 7))
    array.set(arr, 8, ta.valuewhen(cond, bar_index, 8))
    array.set(arr, 9, ta.valuewhen(cond, bar_index, 9))
    array.set(arr, 10, ta.valuewhen(cond, bar_index, 10))
    array.set(arr, 11, ta.valuewhen(cond, bar_index, 11))
f_fill_hist_start_arrays(bool new_240, bool new_d, bool new_w, bool new_m, bool new_q, bool new_y) =>
    f_fill_occ12(hist_240_start_series, new_240)
    f_fill_occ12(hist_D_start_series, new_d)
    f_fill_occ12(hist_W_start_series, new_w)
    f_fill_occ12(hist_M_start_series, new_m)
    f_fill_occ12(hist_3M_start_series, new_q)
    f_fill_occ12(hist_12M_start_series, new_y)
int candle4h_prev_idx_series = f_tf_occurrence_start_idx('240', 1)
int candleD_prev_idx_series = f_tf_occurrence_start_idx('D', 1)
int candleW_prev_idx_series = f_tf_occurrence_start_idx('W', 1)
int candleM_prev_idx_series = f_tf_occurrence_start_idx('M', 1)
int candle4h_curr_idx_series = f_tf_occurrence_start_idx('240', 0)
int candleD_curr_idx_series = f_tf_occurrence_start_idx('D', 0)
int candleW_curr_idx_series = f_tf_occurrence_start_idx('W', 0)
int candleM_curr_idx_series = f_tf_occurrence_start_idx('M', 0)
int quarter_id_series = year(time) * 10 + int(math.floor((month(time) - 1) / 3)) + 1
bool new_quarter_series = ta.change(quarter_id_series) != 0
int candle3M_prev_idx_series = ta.valuewhen(new_quarter_series, bar_index, 1)
int candle3M_curr_idx_series = ta.valuewhen(new_quarter_series, bar_index, 0)
int year_id_series = year(time)
bool new_year_series = ta.change(year_id_series) != 0
int candle12M_prev_idx_series = ta.valuewhen(new_year_series, bar_index, 1)
int candle12M_curr_idx_series = ta.valuewhen(new_year_series, bar_index, 0)
int candleCompN_idx_series = f_tf_occurrence_start_idx(bar_comp_tf, math.max(0, bar_comp_n - 1))
bool hist_new_240_series = f_tf_boundary_changed('240')
bool hist_new_D_series = f_tf_boundary_changed('D')
bool hist_new_W_series = f_tf_boundary_changed('W')
bool hist_new_M_series = f_tf_boundary_changed('M')
f_fill_hist_start_arrays(hist_new_240_series, hist_new_D_series, hist_new_W_series, hist_new_M_series, new_quarter_series, new_year_series)
f_npoc_roll_tag(int roll_id) =>
    roll_id == 1 ? 'SYD' : roll_id == 2 ? 'TOK' : roll_id == 3 ? 'LON' : roll_id == 4 ? 'NY' : 'SES'
bool npoc_day_start_series = ta.change(time('D')) != 0
bool avwap_day_change_series = ta.change(time('D')) != 0
bool avwap_week_change_series = ta.change(time('W')) != 0
bool avwap_manual_hit_series = time >= avwap_manual_ts
int avwap_anchor_day_series = ta.valuewhen(avwap_day_change_series, bar_index, 0)
int avwap_anchor_week_series = ta.valuewhen(avwap_week_change_series, bar_index, 0)
int avwap_anchor_manual_series = ta.valuewhen(avwap_manual_hit_series, bar_index, 0)
bool npoc_sess_active_series = engine_roll_series ? roll_active_id != 0 : in_sess_single_series
bool npoc_sess_active_prev = bar_index > 0 ? npoc_sess_active_series[1] : false
bool npoc_sess_change_series = npoc_sess_active_series != npoc_sess_active_prev or (engine_roll_series and roll_active_id != nz(roll_active_id[1], 0))
string npoc_sess_tag_series = engine_roll_series ? f_npoc_roll_tag(roll_active_id) : 'SES'
if npoc_enable
    bool npoc_new_day = npoc_day_start_series
    if npoc_new_day
        if not na(npoc_d_start_idx) and array.size(npoc_d_lo) > 0
            float d_poc = f_npoc_compute_poc_from_buffer(npoc_d_lo, npoc_d_hi, npoc_d_vol, 240)
            npoc_ord_counter := f_npoc_push_candidate(d_poc, npoc_d_start_idx, bar_index - 1, 'D', 'D', npoc_day_counter, npoc_ord_counter)
        array.clear(npoc_d_lo)
        array.clear(npoc_d_hi)
        array.clear(npoc_d_vol)
        npoc_d_start_idx := bar_index
        npoc_day_counter += 1
    if na(npoc_d_start_idx)
        npoc_d_start_idx := bar_index
    array.push(npoc_d_lo, low)
    array.push(npoc_d_hi, high)
    array.push(npoc_d_vol, volume)
    bool npoc_sess_change = npoc_sess_change_series
    if npoc_sess_change
        if not na(npoc_s_start_idx) and array.size(npoc_s_lo) > 0
            float s_poc = f_npoc_compute_poc_from_buffer(npoc_s_lo, npoc_s_hi, npoc_s_vol, 240)
            int s_ord = npoc_s_tag == 'SYD' ? npoc_syd_counter : npoc_s_tag == 'TOK' ? npoc_tok_counter : npoc_s_tag == 'LON' ? npoc_lon_counter : npoc_s_tag == 'NY' ? npoc_ny_counter : 0
            npoc_ord_counter := f_npoc_push_candidate(s_poc, npoc_s_start_idx, bar_index - 1, 'S', npoc_s_tag, s_ord, npoc_ord_counter)
        array.clear(npoc_s_lo)
        array.clear(npoc_s_hi)
        array.clear(npoc_s_vol)
        npoc_s_start_idx := na
        npoc_s_tag := ''
    if npoc_sess_active_series
        if na(npoc_s_start_idx)
            npoc_s_start_idx := bar_index
            npoc_s_tag := npoc_sess_tag_series
            if npoc_s_tag == 'SYD'
                npoc_syd_counter += 1
            else if npoc_s_tag == 'TOK'
                npoc_tok_counter += 1
            else if npoc_s_tag == 'LON'
                npoc_lon_counter += 1
            else if npoc_s_tag == 'NY'
                npoc_ny_counter += 1
        array.push(npoc_s_lo, low)
        array.push(npoc_s_hi, high)
        array.push(npoc_s_vol, volume)
    int source_mult_live = npoc_source == 'Both' ? 2 : 1
    int npoc_cap_live = math.max(npoc_max_levels, npoc_lookback * source_mult_live)
    f_npoc_trim_cache(npoc_cap_live)
int npoc_all_n = array.size(npoc_price)
if npoc_all_n > 0
    for i = 0 to npoc_all_n - 1 by 1
        if not array.get(npoc_tested, i)
            float lvl = array.get(npoc_price, i)
            if f_npoc_touch(lvl)
                array.set(npoc_tested, i, true)
                array.set(npoc_test_win_age, i, npoc_day_counter)
f_ads_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))
f_ads_clamp01(float x) =>
    f_ads_clamp(x, 0.0, 1.0)
f_ads_safe_div(float a, float b, float fallback) =>
    math.abs(b) > 0 ? a / b : fallback
f_ads_overlap(float vah, float val, float ref_vah, float ref_val) =>
    float mt = math.max(syminfo.mintick, 1e-10)
    float inter = math.max(0.0, math.min(vah, ref_vah) - math.max(val, ref_val))
    float uni = math.max(math.max(vah, ref_vah) - math.min(val, ref_val), mt)
    f_ads_clamp01(inter / uni)
f_ads_shift(float poc, float ref_poc, float profile_w) =>
    float den = math.max(profile_w, syminfo.mintick)
    f_ads_safe_div(poc - ref_poc, den, 0.0)
f_ads_auto_thresholds(string strictness, float profile_w, int range_len) =>
    float overlap_high = 0.55
    float overlap_low = 0.35
    float shift_thr = 0.30
    float rot_high = 60.0
    float rot_low = 35.0
    float rev_thr = 70.0
    float skew_thr = 0.35
    float tail_pct = 0.07
    float dist_ref = math.max(profile_w, syminfo.mintick * 10.0)
    float new_value_thr = 0.25
    if strictness == 'Loose'
        overlap_high := 0.60
        overlap_low := 0.30
        shift_thr := 0.22
        rot_high := 65.0
        rot_low := 40.0
        rev_thr := 65.0
        skew_thr := 0.25
        new_value_thr := 0.20
    else if strictness == 'Strict'
        overlap_high := 0.50
        overlap_low := 0.40
        shift_thr := 0.38
        rot_high := 55.0
        rot_low := 30.0
        rev_thr := 75.0
        skew_thr := 0.45
        new_value_thr := 0.30
    else if strictness == 'Auto'
        float scale = f_ads_clamp01(f_ads_safe_div(profile_w, syminfo.mintick * 80.0, 0.0))
        overlap_high := 0.52 + 0.08 * (1.0 - scale)
        overlap_low := 0.30 + 0.10 * scale
        shift_thr := 0.22 + 0.18 * scale
        rot_high := 55.0 + 8.0 * (1.0 - scale)
        rot_low := 30.0 + 8.0 * scale
        rev_thr := 65.0 + 10.0 * scale
        skew_thr := 0.28 + 0.14 * scale
        new_value_thr := 0.20 + 0.10 * scale
    [overlap_high, overlap_low, shift_thr, rot_high, rot_low, rev_thr, skew_thr, tail_pct, dist_ref, new_value_thr]
f_ads_shape(array<float> bins, int n, float skew_thr) =>
    string shape = 'N/A'
    if n > 2
        float total = 0.0
        float mean = 0.0
        float m2 = 0.0
        float m3 = 0.0
        int p1 = 0
        int p2 = 0
        float v1 = -1.0
        float v2 = -1.0
        int min_sep = math.max(3, int(math.round(n * 0.08)))
        for i = 0 to n - 1 by 1
            float v = math.max(array.get(bins, i), 0.0)
            total += v
            mean += i * v
            if v > v1
                v2 := v1
                p2 := p1
                v1 := v
                p1 := i
            else if math.abs(i - p1) >= min_sep and v > v2
                v2 := v
                p2 := i
        if total > 0
            mean /= total
            for i = 0 to n - 1 by 1
                float v = math.max(array.get(bins, i), 0.0)
                float d = i - mean
                m2 += v * d * d
                m3 += v * d * d * d
            float variance = m2 / total
            float sd = math.sqrt(math.max(variance, 1e-10))
            float skew = m3 / total / math.pow(sd, 3)
            bool dd = false
            if v1 > 0 and v2 > 0 and math.abs(p1 - p2) >= min_sep
                int lo = math.min(p1, p2)
                int hi = math.max(p1, p2)
                float valley = v1
                for j = lo to hi by 1
                    valley := math.min(valley, math.max(array.get(bins, j), 0.0))
                dd := v2 >= v1 * 0.65 and valley <= math.min(v1, v2) * 0.45
            shape := dd ? 'DD' : skew > skew_thr ? 'b' : skew < -skew_thr ? 'P' : 'D'
    shape
f_ads_tails(array<float> bins, int n, float tail_pct) =>
    float low_tail = na
    float high_tail = na
    if n > 0
        int tb = math.max(1, int(math.round(n * tail_pct)))
        float sum_all = 0.0
        float sum_lo = 0.0
        float sum_hi = 0.0
        for i = 0 to n - 1 by 1
            float v = math.max(array.get(bins, i), 0.0)
            sum_all += v
            if i < tb
                sum_lo += v
            if i >= n - tb
                sum_hi += v
        if sum_all > 0
            low_tail := sum_lo / sum_all
            high_tail := sum_hi / sum_all
    [low_tail, high_tail]
f_ads_emit_marker(string txt, float y, color bg, float y_offset) =>
    label lb = label.new(bar_index + 1, y + y_offset, txt, xloc = xloc.bar_index, style = label.style_label_left, textcolor = color.white, color = bg, size = size.normal)
    array.push(ads_markers, lb)
    if array.size(ads_markers) > 30
        label oldest = array.shift(ads_markers)
        label.delete(oldest)
f_ads_clear_markers() =>
    int n = array.size(ads_markers)
    if n > 0
        for i = 0 to n - 1 by 1
            label.delete(array.get(ads_markers, i))
        array.clear(ads_markers)
f_panel_pos(string location) =>
    location == 'Top Right' ? position.top_right : location == 'Bottom Left' ? position.bottom_left : location == 'Middle Right' ? position.middle_right : location == 'Middle Left' ? position.middle_left : position.bottom_right
f_panel_tip(string desc, string use_case) =>
    '• Description:\n⠀- ' + desc + '\n• Useful when:\n⠀- ' + use_case
f_panel_key_tooltip(string k) =>
    string tip = k == 'VCD' ? f_panel_tip('Dashboard header with a compact\n⠀⠀overview.', 'you want a quick read of the\n⠀⠀current panel state.') :
      k == 'Range' ? f_panel_tip('Active profile range with bars\n⠀⠀and session/fallback context.', 'you want to validate the data\n⠀⠀window before interpreting values.') :
      k == 'VA Loc' ? f_panel_tip('Close location versus VAH/VAL.', 'you want an instant Above/In/Below\n⠀⠀Value read.') :
      k == 'POC Dist' ? f_panel_tip('Distance to POC in ticks\n⠀⠀(optionally shown as R).', 'you want to evaluate distance\n⠀⠀or mean-reversion setups.') :
      k == 'Magnet' ? f_panel_tip('Nearest magnet level from\n⠀⠀NPOC/HVN/LVN/LVG.', 'you want the next likely\n⠀⠀attraction level nearby.') :
      k == 'Regime' ? f_panel_tip('ADS market mode (Balance,\n⠀⠀Trend, Breakout, Risk).', 'you want to pre-filter entries\n⠀⠀by market phase.') :
      k == 'Bias/Rev' ? f_panel_tip('Directional bias plus\n⠀⠀reversal risk.', 'you want continuation vs.\n⠀⠀reversal context in one row.') :
      k == 'Shape' ? f_panel_tip('Profile shape and\n⠀⠀distribution character.', 'you want to assess acceptance\n⠀⠀vs. distribution structure fast.') :
      k == 'Rot/OVL' ? f_panel_tip('Rotation and overlap as\n⠀⠀balance metric.', 'you want to separate rotation\n⠀⠀from initiative moves.') :
      k == 'CVD(Sess)' ? f_panel_tip('Session CVD (proxy)\n⠀⠀accumulation.', 'you want to track intraday\n⠀⠀buy/sell pressure.') :
      k == 'Δ' ? f_panel_tip('Current delta change in the\n⠀⠀context block.', 'you want to spot short-term\n⠀⠀impulse shifts.') :
      k == 'OIΔ' ? f_panel_tip('Open-interest change\n⠀⠀(when available).', 'you want to assess position\n⠀⠀build-up/unwind context.') :
      k == 'Prev VA' ? f_panel_tip('Previous session value area\n⠀⠀as reference.', 'you want to check reaction\n⠀⠀at prior value boundaries.') :
      k == 'Sig' ? f_panel_tip('Signal status with mode,\n⠀⠀bins, and recompute.', 'you want signal quality and\n⠀⠀performance context.') :
      k == 'Legend' ? f_panel_tip('Marker-event colors and\n⠀⠀abbreviations.', 'you want to decode markers\n⠀⠀without memorization.') :
      k == 'AVWAP' ? f_panel_tip('Anchored VWAP plus\n⠀⠀current price side.', 'you want trend/mean-reversion\n⠀⠀context via AVWAP.') :
      k == 'OF' ? f_panel_tip('Orderflow mode and\n⠀⠀active data path.', 'you want to confirm whether\n⠀⠀native/proxy/fallback is used.') :
      k == 'OF Info' ? f_panel_tip('Coverage and fallback\n⠀⠀stats for OF path.', 'you want a quick data-quality\n⠀⠀check.') :
      k == 'OF Why' ? f_panel_tip('Reason for selected\n⠀⠀orderflow path.', 'you want to understand the\n⠀⠀active fallback logic.') :
      f_panel_tip('Panel metric.', 'you need immediate context\n⠀⠀for the current row.')
    tip
f_panel_put_row(table t, int row, string k, string v, color v_col, color key_bg, color val_bg) =>
    table.cell(t, 0, row, k, text_color = color.new(color.white, 0), text_size = size.small, bgcolor = key_bg, tooltip = f_panel_key_tooltip(k))
    table.cell(t, 1, row, v, text_color = v_col, text_size = size.small, bgcolor = val_bg)
    row + 1
f_panel_marker_legend_txt() =>
    '🟩▲ A+  Accept Up\n\n🟥▼ A-  Accept Down\n\n🟠 F+/F-  Fail\n\n🔷 R  Re-Entry\n\n🟪 NV  New Value\n\n🟨 RG  Regime\n\n🟧 RR  Reversal Risk'
f_panel_put_marker_legend(table t, int row, color row_bg) =>
    table.cell(t, 0, row, f_panel_marker_legend_txt(), text_color = color.new(color.white, 0), text_size = size.small, bgcolor = row_bg, text_halign = text.align_left, tooltip = f_panel_key_tooltip('Legend'))
    table.cell(t, 1, row, '', text_color = color.new(color.white, 0), text_size = size.small, bgcolor = row_bg)
    table.merge_cells(t, 0, row, 1, row)
    row + 1
f_panel_range_txt(string range_mode_in, int bars_in_range_in, string session_engine_in, string sess_tz_in, bool range_fallback_used_in, string range_reason_in) =>
    string mode_txt = range_mode_in == 'Fixed Lookback Bars' ? ('Fixed ' + str.tostring(fixed_lookback)) : range_mode_in == 'Session (Prev+Current)' ? 'Sess Prev+Cur' : range_mode_in
    string engine_txt = str.contains(session_engine_in, 'Rolling') ? 'Rolling' : 'Single'
    string txt = mode_txt + ' | eff ' + str.tostring(bars_in_range_in)
    if str.contains(range_mode_in, 'Session')
        txt := txt + ' | ' + engine_txt + ' | TZ ' + sess_tz_in
    if range_fallback_used_in
        txt := txt + ' | fb'
    txt
f_panel_of_why_txt(string reason_in) =>
    string txt = reason_in == '' ? '—' : reason_in
    txt := str.replace_all(txt, ' | ', '\n')
    txt := str.replace_all(txt, '. Native bars:', '\nNative bars:')
    txt := str.replace_all(txt, ' / Proxy bars:', '\nProxy bars:')
    txt := str.replace_all(txt, ' / Missing native bars:', '\nMissing native bars:')
    txt
f_panel_va_loc(float c, float vah, float val) =>
    na(vah) or na(val) ? 'n/a' : c > vah ? 'Above VAH' : c < val ? 'Below VAL' : 'In Value'
f_panel_poc_dist(float c, float poc, float value_w) =>
    if na(poc)
        'n/a'
    else
        float mt = math.max(syminfo.mintick, 1e-10)
        float d = c - poc
        int ticks = int(math.round(math.abs(d) / mt))
        string side = d > 0 ? '+' : d < 0 ? '-' : ''
        string txt = side + str.tostring(ticks) + 't'
        if not na(value_w) and value_w > 0
            txt := txt + ' (' + str.tostring(math.abs(d) / value_w, '#.00') + 'R)'
        txt
f_panel_nearest_magnet_txt(bool npoc_enable_in, bool show_hvn_in, bool show_lvn_in, bool show_lvg_in, float close_in, float pmin_in, float step_r_in) =>
    string best_txt = ''
    float best_dist = na
    if npoc_enable_in
        int n_npoc = array.size(npoc_price)
        if n_npoc > 0
            for i = 0 to n_npoc - 1 by 1
                if i < array.size(npoc_tested) and not array.get(npoc_tested, i)
                    float lvl = array.get(npoc_price, i)
                    float dist = math.abs(close_in - lvl)
                    if na(best_dist) or dist < best_dist
                        best_dist := dist
                        best_txt := 'NPOC ' + str.tostring(lvl, format.mintick)
    if show_hvn_in and step_r_in > 0
        int n_hvn = array.size(hvn_idx)
        if n_hvn > 0
            for i = 0 to n_hvn - 1 by 1
                int idx = array.get(hvn_idx, i)
                float lvl = f_snap_tick(pmin_in + (idx + 0.5) * step_r_in)
                float dist = math.abs(close_in - lvl)
                if na(best_dist) or dist < best_dist
                    best_dist := dist
                    best_txt := 'HVN ' + str.tostring(lvl, format.mintick)
    if show_lvn_in and step_r_in > 0
        int n_lvn = array.size(lvn_idx)
        if n_lvn > 0
            for i = 0 to n_lvn - 1 by 1
                int idx = array.get(lvn_idx, i)
                float lvl = f_snap_tick(pmin_in + (idx + 0.5) * step_r_in)
                float dist = math.abs(close_in - lvl)
                if na(best_dist) or dist < best_dist
                    best_dist := dist
                    best_txt := 'LVN ' + str.tostring(lvl, format.mintick)
    if show_lvg_in and step_r_in > 0
        int n_lvg = array.size(lvg_start)
        if n_lvg > 0
            for i = 0 to n_lvg - 1 by 1
                if i < array.size(lvg_end)
                    int zs = array.get(lvg_start, i)
                    int ze = array.get(lvg_end, i)
                    float zl = f_floor_tick(pmin_in + zs * step_r_in)
                    float zh = f_ceil_tick(pmin_in + (ze + 1) * step_r_in)
                    float dist = close_in >= zl and close_in <= zh ? 0.0 : math.min(math.abs(close_in - zl), math.abs(close_in - zh))
                    if na(best_dist) or dist < best_dist
                        best_dist := dist
                        best_txt := 'LVG ' + str.tostring(zl, format.mintick) + '-' + str.tostring(zh, format.mintick)
    best_txt
f_panel_rows_needed(bool vp_on, bool ads_panel_on, bool marker_legend_on, bool ctx_panel_on, bool ctx_oi_row_on, bool ctx_prev_ok, bool sig_on, bool avwap_on, bool avwap_ready, bool magnet_row_on, bool of_on) =>
    int rows = 1
    if marker_legend_on
        rows += 1
    if vp_on
        rows += 3
    if magnet_row_on
        rows += 1
    if ads_panel_on
        rows += 3
        if not na(ads_overlap)
            rows += 1
    if ctx_panel_on
        rows += 2
        if ctx_oi_row_on and not na(ctx_oi_delta)
            rows += 1
        if ctx_prev_ok
            rows += 1
    if sig_on
        rows += 1
    if avwap_on and avwap_ready
        rows += 1
    if of_on
        rows += 3
    rows
f_fmt_k(float n) =>
    float absv = math.abs(n)
    absv >= 1000000 ? str.tostring(n / 1000000.0, '#.0') + 'M' :
     absv >= 1000 ? str.tostring(n / 1000.0, '#.0') + 'K' :
     str.tostring(n, '#')
f_sig_clampi(int v, int lo, int hi) =>
    math.max(lo, math.min(hi, v))
f_sig_auto_bins(string quality, int render_rows_in) =>
    int base = quality == 'Fast (Low CPU)' ? 110 : quality == 'High (More detail)' ? 190 : 140
    int auto_target = int(math.round(render_rows_in * 0.33))
    int blended = int(math.round((base + auto_target) * 0.5))
    f_sig_clampi(blended, 80, 240)
f_sig_auto_recompute(string quality, int chart_tf_sec, int sig_len_pre) =>
    int base = quality == 'Fast (Low CPU)' ? (chart_tf_sec <= 300 ? 3 : 2) : quality == 'High (More detail)' ? 1 : (chart_tf_sec <= 300 ? 2 : 1)
    int extra = sig_len_pre > 1800 ? 2 : sig_len_pre > 1200 ? 1 : 0
    f_sig_clampi(base + extra, 1, 20)
f_sig_auto_ref_interval(string quality, int sig_len_pre) =>
    int base = quality == 'Fast (Low CPU)' ? 42 : quality == 'High (More detail)' ? 20 : 24
    int extra = sig_len_pre > 1800 ? 12 : sig_len_pre > 1200 ? 6 : 0
    f_sig_clampi(base + extra, 5, 200)
f_sig_resolve_range(string mode, int lookback_bars, int composite_n) =>
    int avail_left = math.max(0, bar_index - (MAX_BARS_BACK - 1))
    int right_idx = bar_index
    int candle4h_anchor_idx = current_candle_only ? candle4h_curr_idx_series : candle4h_prev_idx_series
    int candleD_anchor_idx = current_candle_only ? candleD_curr_idx_series : candleD_prev_idx_series
    int candleW_anchor_idx = current_candle_only ? candleW_curr_idx_series : candleW_prev_idx_series
    int candleM_anchor_idx = current_candle_only ? candleM_curr_idx_series : candleM_prev_idx_series
    int candle3M_anchor_idx = current_candle_only ? candle3M_curr_idx_series : candle3M_prev_idx_series
    int candle12M_anchor_idx = current_candle_only ? candle12M_curr_idx_series : candle12M_prev_idx_series
    int comp_left = composite_n <= 2 ? sess_start1_series : sess_startN_series
    int left_idx =
         mode == 'Fixed Lookback Bars' ? math.max(0, bar_index - lookback_bars + 1) :
         mode == 'Session (Current)' ? (na(sess_start0_series) ? avail_left : sess_start0_series) :
         mode == 'Session (Prev+Current)' ? (na(sess_start1_series) ? avail_left : sess_start1_series) :
         mode == 'Session Composite (N)' ? (na(comp_left) ? avail_left : comp_left) :
         mode == '4H (Prev+Current)' ? (na(candle4h_anchor_idx) ? avail_left : candle4h_anchor_idx) :
         mode == 'D (Prev+Current)' ? (na(candleD_anchor_idx) ? avail_left : candleD_anchor_idx) :
         mode == 'W (Prev+Current)' ? (na(candleW_anchor_idx) ? avail_left : candleW_anchor_idx) :
         mode == 'M (Prev+Current)' ? (na(candleM_anchor_idx) ? avail_left : candleM_anchor_idx) :
         mode == '3M (Prev+Current)' ? (na(candle3M_anchor_idx) ? avail_left : candle3M_anchor_idx) :
         mode == '12M (Prev+Current)' ? (na(candle12M_anchor_idx) ? avail_left : candle12M_anchor_idx) :
         0
    left_idx := math.max(avail_left, math.min(right_idx, left_idx))
    [left_idx, right_idx]
f_sig_profile_levels(array<float> bins, float pmin, float step, float va_pct) =>
    int n = array.size(bins)
    float tot = 0.0
    float maxv = 0.0
    int poc_idx = 0
    for i = 0 to n - 1 by 1
        float v = math.max(array.get(bins, i), 0.0)
        tot += v
        if v > maxv
            maxv := v
            poc_idx := i
    int va_lo = poc_idx
    int va_hi = poc_idx
    float cur = n > 0 ? array.get(bins, poc_idx) : 0.0
    float target = tot * va_pct
    for _ = 0 to n - 1 by 1
        if cur >= target
            break
        float up_v = va_hi < n - 1 ? array.get(bins, va_hi + 1) : -1.0
        float dn_v = va_lo > 0 ? array.get(bins, va_lo - 1) : -1.0
        if up_v >= dn_v and va_hi < n - 1
            va_hi += 1
            cur += up_v
        else if va_lo > 0
            va_lo -= 1
            cur += dn_v
    float poc = f_snap_tick(pmin + (poc_idx + 0.5) * step)
    float vah = f_snap_tick(pmin + (va_hi + 1.0) * step)
    float val = f_snap_tick(pmin + va_lo * step)
    [poc, vah, val, math.max(vah - val, syminfo.mintick), maxv]
f_sig_lvg_hit(array<int> starts, array<int> ends, float pmin, float step) =>
    bool hit = false
    int n = math.min(array.size(starts), array.size(ends))
    if n > 0
        for i = 0 to n - 1 by 1
            float zl = pmin + array.get(starts, i) * step
            float zh = pmin + (array.get(ends, i) + 1.0) * step
            if high >= zl and low <= zh
                hit := true
                break
    hit
bool need_visible = range_mode == 'Visible Range' or range_mode == 'Visible Range (Right Anchored)'
int vis_left = na
int vis_right = na
int vis_left_tmp = na
int vis_right_tmp = na
if need_visible
    [vis_left_tmp, vis_right_tmp] = f_get_visible_indices()
    vis_left := vis_left_tmp
    vis_right := vis_right_tmp
simple int chart_sec_req = timeframe.in_seconds(timeframe.period)
simple string ltf_resolved_req = ltf_tf != 'Auto' ? ltf_tf : chart_sec_req <= 1 * 60 ? '1' : chart_sec_req <= 3 * 60 ? '1' : chart_sec_req <= 5 * 60 ? '1' : chart_sec_req <= 15 * 60 ? '3' : chart_sec_req <= 60 * 60 ? '5' : chart_sec_req <= 4 * 60 * 60 ? '15' : chart_sec_req <= 12 * 60 * 60 ? '15' : chart_sec_req <= 24 * 60 * 60 ? '60' : '240'
string ltf_resolved_series = ltf_resolved_req
bool intrabar_on_series = precision_mode == 'Intrabar (LTF Aggregation)'
bool ltf_valid_series = intrabar_on_series and f_is_ltf_valid(ltf_resolved_series)
bool intrabar_request_on = intrabar_on_series and ltf_valid_series
int sess_comp_n = f_session_n(session_comp_opt)
simple int sess_comp_n_cap = session_comp_opt == '2' ? 2 : session_comp_opt == '5' ? 5 : 20
simple int ltf_sec_req = timeframe.in_seconds(ltf_resolved_req)
simple bool intrabar_on_req = precision_mode == 'Intrabar (LTF Aggregation)'
simple bool ltf_valid_req = intrabar_on_req and not na(chart_sec_req) and not na(ltf_sec_req) and ltf_sec_req > 0 and ltf_sec_req < chart_sec_req
simple bool intrabar_request_on_req = intrabar_on_req and ltf_valid_req
simple int ltf_per_chart = (not na(chart_sec_req) and not na(ltf_sec_req) and ltf_sec_req > 0) ? math.max(1, int(math.ceil(float(chart_sec_req) / float(ltf_sec_req)))) : 1
simple int ib_cap_req = math.max(1, int(math.floor(float(180000) / float(ltf_per_chart))))
simple int cap_all = MAX_BARS_BACK
simple int cap_fixed = math.max(1, math.min(MAX_BARS_BACK, fixed_lookback))
simple int cap_visible = math.max(1, math.min(MAX_BARS_BACK, 500))
simple int htf_win_sec_cap =
     range_mode == '4H (Prev+Current)' ? (current_candle_only ? 4 * 60 * 60 : 8 * 60 * 60) :
     range_mode == 'D (Prev+Current)' ? (current_candle_only ? 24 * 60 * 60 : 48 * 60 * 60) :
     range_mode == 'W (Prev+Current)' ? (current_candle_only ? 7 * 24 * 60 * 60 : 14 * 24 * 60 * 60) :
     range_mode == 'M (Prev+Current)' ? (current_candle_only ? 30 * 24 * 60 * 60 : 60 * 24 * 60 * 60) :
     range_mode == '3M (Prev+Current)' ? (current_candle_only ? 90 * 24 * 60 * 60 : 180 * 24 * 60 * 60) :
     range_mode == '12M (Prev+Current)' ? (current_candle_only ? 365 * 24 * 60 * 60 : 730 * 24 * 60 * 60) :
     na
simple int cap_htf = not na(htf_win_sec_cap) and not na(chart_sec_req) and chart_sec_req > 0 ? math.max(1, math.min(MAX_BARS_BACK, int(math.ceil(float(htf_win_sec_cap) / float(chart_sec_req))) + 2)) : 1
simple int bar_comp_tf_sec = timeframe.in_seconds(bar_comp_tf)
simple int bar_comp_win_sec_cap = not na(bar_comp_tf_sec) and bar_comp_tf_sec > 0 ? bar_comp_tf_sec * math.max(1, bar_comp_n) : na
simple int cap_bar_comp = not na(bar_comp_win_sec_cap) and not na(chart_sec_req) and chart_sec_req > 0 ? math.max(1, math.min(MAX_BARS_BACK, int(math.ceil(float(bar_comp_win_sec_cap) / float(chart_sec_req))) + 2)) : 1
int sess_win_sec_cap = f_session_window_seconds(range_mode, sess_comp_n_cap)
int cap_session = not na(sess_win_sec_cap) and not na(chart_sec_req) and chart_sec_req > 0 ? math.max(1, math.min(MAX_BARS_BACK, int(math.ceil(float(sess_win_sec_cap) / float(chart_sec_req))) + 2)) : 1
[range_left_series, range_right_series, bars_in_range_series, range_anchored_series, range_reason_code_series] = f_resolve_range_indices(range_mode, vis_left, vis_right, fixed_lookback, current_candle_only, cap_session, sess_comp_n, sess_start0_series, sess_start1_series, sess_startN_series, candleCompN_idx_series)
int needed_chart_bars = bars_in_range_series
int needed_chart_bars_cap =
     range_mode == 'All Loaded Bars (Current TF)' ? cap_all :
     range_mode == 'Fixed Lookback Bars' ? cap_fixed :
     need_visible ? cap_visible :
     (range_mode == '4H (Prev+Current)' or range_mode == 'D (Prev+Current)' or range_mode == 'W (Prev+Current)' or range_mode == 'M (Prev+Current)' or range_mode == '3M (Prev+Current)' or range_mode == '12M (Prev+Current)') ? cap_htf :
     range_mode == 'Bar Composite (N)' ? cap_bar_comp :
     (range_mode == 'Session (Current)' or range_mode == 'Session (Prev+Current)' or range_mode == 'Session Composite (N)') ? cap_session :
     cap_fixed
int needed_chart_bars_cap_intrabar = intrabar_request_on ? math.max(1, math.min(needed_chart_bars_cap, math.min(ib_cap_req, 240))) : needed_chart_bars_cap
int calc_needed_ltf = needed_chart_bars_cap_intrabar * ltf_per_chart + (2 * ltf_per_chart)
int calc_needed_ltf_unclamped = math.max(1, math.min(calc_needed_ltf, 180000))
int calc_budget_ltf = math.min(calc_needed_ltf_unclamped, 60000)
simple int sess_win_sec_cap_req =
     range_mode == 'Session (Current)' ? 24 * 60 * 60 :
     range_mode == 'Session (Prev+Current)' ? 48 * 60 * 60 :
     range_mode == 'Session Composite (N)' ? math.max(1, sess_comp_n_cap) * 24 * 60 * 60 :
     na
simple int bar_comp_win_sec_req = not na(bar_comp_tf_sec) and bar_comp_tf_sec > 0 ? bar_comp_tf_sec * math.max(1, bar_comp_n) : na
simple int cap_bar_comp_req = not na(bar_comp_win_sec_req) and not na(chart_sec_req) and chart_sec_req > 0 ? math.max(1, math.min(MAX_BARS_BACK, int(math.ceil(float(bar_comp_win_sec_req) / float(chart_sec_req))) + 2)) : 1
simple int cap_session_req = not na(sess_win_sec_cap_req) and not na(chart_sec_req) and chart_sec_req > 0 ? math.max(1, math.min(MAX_BARS_BACK, int(math.ceil(float(sess_win_sec_cap_req) / float(chart_sec_req))) + 2)) : 1
simple int needed_chart_bars_cap_req =
     range_mode == 'All Loaded Bars (Current TF)' ? cap_all :
     range_mode == 'Fixed Lookback Bars' ? cap_fixed :
     need_visible ? cap_visible :
     (range_mode == '4H (Prev+Current)' or range_mode == 'D (Prev+Current)' or range_mode == 'W (Prev+Current)' or range_mode == 'M (Prev+Current)' or range_mode == '3M (Prev+Current)' or range_mode == '12M (Prev+Current)') ? cap_htf :
     range_mode == 'Bar Composite (N)' ? cap_bar_comp_req :
     (range_mode == 'Session (Current)' or range_mode == 'Session (Prev+Current)' or range_mode == 'Session Composite (N)') ? cap_session_req :
     cap_fixed
simple int needed_chart_bars_cap_req_intrabar = intrabar_request_on_req ? math.max(1, math.min(needed_chart_bars_cap_req, math.min(ib_cap_req, 240))) : needed_chart_bars_cap_req
simple int calc_needed_ltf_req = needed_chart_bars_cap_req_intrabar * ltf_per_chart + (2 * ltf_per_chart)
simple int calc_needed_ltf_unclamped_req = math.max(1, math.min(calc_needed_ltf_req, 180000))
simple int calc_budget_ltf_req = math.min(calc_needed_ltf_unclamped_req, 60000)
simple int of_src_mode_req = OF_DELTA_SRC_MODE
simple int of_neut_mode_req = OF_NEUTRAL_MODE
bool of_native_request_enabled = of_enable and of_source_mode == 'Native Only'
footprint of_native_fp_req = na
if of_native_request_enabled
    of_native_fp_req := request.footprint(of_native_ticks_per_row, va_percent, of_native_imbalance)
bool use_calc_bars = true
bool intrabar_disabled_non_anchored = intrabar_on_series and not range_anchored_series
bool in_needed_window = range_anchored_series ? (last_bar_index - bar_index) <= (needed_chart_bars_cap_intrabar - 1) : true
bool allow_intrabar_processing = in_needed_window and not intrabar_disabled_non_anchored
bool intrabar_request_window = intrabar_request_on and allow_intrabar_processing
array<float> ltfO_series = na
array<float> ltfH_series = na
array<float> ltfL_series = na
array<float> ltfC_series = na
array<float> ltfV_series = na
if intrabar_request_window
    [ltfO_tmp, ltfH_tmp, ltfL_tmp, ltfC_tmp, ltfV_tmp] = request.security_lower_tf(syminfo.tickerid, ltf_resolved_series, [open, high, low, close, volume], ignore_invalid_timeframe = true, calc_bars_count = calc_budget_ltf_req)
    ltfO_series := ltfO_tmp
    ltfH_series := ltfH_tmp
    ltfL_series := ltfL_tmp
    ltfC_series := ltfC_tmp
    ltfV_series := ltfV_tmp
else
    ltfO_series := na
    ltfH_series := na
    ltfL_series := na
    ltfC_series := na
    ltfV_series := na
if barstate.islast
    bool mode_vis = range_mode == 'Visible Range'
    bool mode_vis_anchor = range_mode == 'Visible Range (Right Anchored)'
    bool mode_fixed = range_mode == 'Fixed Lookback Bars'
    bool mode_all = range_mode == 'All Loaded Bars (Current TF)'
    bool mode_sess_cur = range_mode == 'Session (Current)'
    bool mode_sess_prevcur = range_mode == 'Session (Prev+Current)'
    bool mode_sess_comp = range_mode == 'Session Composite (N)'
    bool mode_bar_comp = range_mode == 'Bar Composite (N)'
    bool mode_session = mode_sess_cur or mode_sess_prevcur or mode_sess_comp
    bool mode_candle_4h_prevcur = range_mode == '4H (Prev+Current)'
    bool mode_candle_d_prevcur = range_mode == 'D (Prev+Current)'
    bool mode_candle_w_prevcur = range_mode == 'W (Prev+Current)'
    bool mode_candle_m_prevcur = range_mode == 'M (Prev+Current)'
    bool mode_candle_3m_prevcur = range_mode == '3M (Prev+Current)'
    bool mode_candle_12m_prevcur = range_mode == '12M (Prev+Current)'
    bool mode_candle_prevcur = mode_candle_4h_prevcur or mode_candle_d_prevcur or mode_candle_w_prevcur or mode_candle_m_prevcur or mode_candle_3m_prevcur or mode_candle_12m_prevcur
    int left_idx = range_left_series
    int right_idx = range_right_series
    int bars_in_range = bars_in_range_series
    bool range_anchored_to_last = range_anchored_series
    int range_reason_code = range_reason_code_series
    string range_reason =
         range_reason_code == 1 ? 'all_loaded_capped_to_max_bars_back' :
         range_reason_code == 2 ? 'fixed_lookback' :
         range_reason_code == 3 ? 'visible_left_to_last_bar' :
         range_reason_code == 4 ? 'visible_left_fallback+to_last_bar' :
         range_reason_code == 5 ? 'session_anchor' :
         range_reason_code == 6 ? 'session_anchor_fallback_to_cap_window' :
         range_reason_code == 7 ? 'htf_window' :
         'unknown_mode_fallback_to_last_bar'
    bool session_fallback_cap_used = range_reason_code == 6
    bool range_fallback_used = range_reason_code == 4 or session_fallback_cap_used or range_reason_code == 8
    string ltf_resolved = ltf_resolved_series
    bool intrabar_on = intrabar_on_series
    bool ltf_valid = ltf_valid_series
    bool intrabar_capped = calc_needed_ltf > 180000
    string cfg_hash_vp = str.format('{0}|{1}|{2}|{3}|{4}|{5}|{6}|{7}|{8}|{9}|{10}|{11}|{12}|{13}|{14}|{15}|{16}|{17}|{18}|{19}|{20}|{21}|{22}|{23}|{24}|{25}|{26}|{27}|{28}|{29}|{30}|{31}|{32}|{33}|{34}|{35}|{36}|{37}',
        range_mode, fixed_lookback, precision_mode, ltf_tf, ltf_resolved, style_mode, dock_gap_bars, dock_width_bars, panel_bg_alpha,
        render_rows_in, internal_bins_mode, smoothing_bins, intensity_gamma,
        show_poc, show_va, va_percent, show_profile_hilo, show_level_labels, extend_level_rays,
        show_hvn, show_lvn, show_lvg, hvn_abs_count, lvn_abs_count, hvn_rel_count, lvn_rel_count, node_tuning_mode, node_min_separation_bins, hvn_prominence_pct, lvn_threshold_pct,
        lvg_threshold_mode, lvg_threshold_value, lvg_min_height_bins, lvg_max_zones,
        f_hash_color(line_color), f_hash_color(area_color), f_hash_color(heat_low_col), f_hash_color(heat_high_col))
    cfg_hash_vp := cfg_hash_vp + '|' + str.tostring(current_candle_only) + '|' + str.tostring(lvg_auto_scale) + '|' + dist_mode + '|' + str.tostring(body_weight_mult)
    string cfg_hash_sessions = str.format('{0}|{1}|{2}|{3}|{4}|{5}|{6}|{7}|{8}|{9}|{10}|{11}|{12}|{13}|{14}|{15}',
         session_engine, session_preset, session_custom, session_comp_opt,
         sess_timezone, sess_style, sess_line_limit, sess_box_limit,
         london_sess, ny_sess, tokyo_sess, sydney_sess,
         london_show, ny_show, tokyo_show, sydney_show)
    string cfg_hash_ads = str.format('{0}|{1}|{2}|{3}|{4}|{5}|{6}|{7}|{8}|{9}|{10}|{11}|{12}',
         ads_enable, ads_show_panel, ads_show_markers, ads_show_marker_legend, panel_location,
         ads_alert_accept, ads_alert_fail, ads_alert_reentry, ads_alert_new_value,
         ads_alert_regime, ads_alert_reversal, ads_strictness, ads_accept_confirm)
    string cfg_hash_of = str.format('{0}|{1}|{2}|{3}|{4}|{5}|{6}|{7}|{8}|{9}|{10}|{11}|{12}|{13}',
         of_enable, of_source_mode, of_native_ticks_per_row, of_native_imbalance, of_profile_type, OF_DELTA_SRC_MODE, OF_NEUTRAL_MODE, of_require_intrabar,
         of_show_base_underlay, of_fill_alpha_min,
         of_fill_alpha_max, f_hash_color(of_buy_col), f_hash_color(of_sell_col), f_hash_color(of_delta_pos_col), f_hash_color(of_delta_neg_col))
    string cfg_hash_ctx = str.format('{0}|{1}|{2}|{3}|{4}', ctx_pack_mode, ctx_ib_minutes, ctx_show_panel, ctx_visual_extras, ctx_pane_plot_mode)
    string cfg_hash_avwap = str.format('{0}|{1}|{2}|{3}|{4}|{5}|{6}|{7}', avwap_enable, avwap_anchor, avwap_src, avwap_bands_enable, avwap_band_mults, avwap_band_method, avwap_show_labels, avwap_manual_ts)
    string cfg_hash_npoc = str.format('{0}|{1}|{2}|{3}|{4}|{5}|{6}|{7}|{8}', npoc_enable, npoc_source, npoc_lookback, npoc_max_levels, npoc_touch_rule, npoc_touch_ticks, npoc_prioritize, npoc_fade_by_age, npoc_labels)
    string cfg_hash_hist_poc = str.format('{0}|{1}|{2}|{3}', hist_poc_enable, hist_poc_count, hist_poc_show_labels, hist_poc_fade_by_age)
    string cfg_hash = str.format('vp:{0}|sess:{1}|ads:{2}|of:{3}|ctx:{4}|avwap:{5}|npoc:{6}|hist:{7}',
         cfg_hash_vp, cfg_hash_sessions, cfg_hash_ads, cfg_hash_of, cfg_hash_ctx, cfg_hash_avwap, cfg_hash_npoc, cfg_hash_hist_poc)
    bool view_dependent = mode_vis or mode_vis_anchor
    bool dirty_view = view_dependent and (chart.left_visible_bar_time != last_left_vis or chart.right_visible_bar_time != last_right_vis)
    bool dirty_range = left_idx != last_calc_left_idx or right_idx != last_calc_right_idx or range_fallback_used != last_range_fallback_used
    bool dirty_cfg = cfg_hash != last_cfg_hash
    bool dirty_heal = false
    if na(panel_box)
        dirty_heal := true
    if not dirty_heal and array.size(row_boxes) > 0 and na(array.get(row_boxes, 0))
        dirty_heal := true
    if not dirty_heal and array.size(hvn_boxes) > 0 and na(array.get(hvn_boxes, 0))
        dirty_heal := true
    if not dirty_heal and array.size(npoc_lines) > 0 and na(array.get(npoc_lines, 0))
        dirty_heal := true
    if not dirty_heal and array.size(hist_poc_lines_in_period) > 0 and na(array.get(hist_poc_lines_in_period, 0))
        dirty_heal := true
    if not dirty_heal and array.size(hist_poc_lines_extended) > 0 and na(array.get(hist_poc_lines_extended, 0))
        dirty_heal := true
    if not dirty_heal and array.size(split_buy_boxes) > 0 and na(array.get(split_buy_boxes, 0))
        dirty_heal := true
    dirty := dirty_view or dirty_range or dirty_cfg or dirty_heal
    if dirty
        int win_len = right_idx - left_idx + 1
        float pmin = high
        float pmax = low
        for bi = left_idx to right_idx by 1
            int off = bar_index - bi
            pmin := math.min(pmin, low[off])
            pmax := math.max(pmax, high[off])
            pmax
        float p_range = pmax - pmin
        if p_range <= 0
            f_hide_all_visuals()
            if na(warn_label)
                warn_label := label.new(bar_index, high, '', xloc = xloc.bar_index, style = label.style_label_left)
                warn_label
            label.set_xy(warn_label, bar_index, high)
            label.set_text(warn_label, 'Flat range: profile skipped')
            label.set_textcolor(warn_label, color.new(color.white, 0))
            label.set_color(warn_label, color.new(color.black, 65))
            label.set_size(warn_label, size.small)
        else
            bars_in_range := right_idx - left_idx + 1
            float mt = syminfo.mintick
            int ticks_span = mt > 0 ? int(math.ceil(p_range / mt)) : na
            bool range_too_small = bars_in_range <= 2 or (not na(ticks_span) and ticks_span <= 4)
            int internal_n = f_compute_internal_bins(p_range)
            int render_n_req = math.min(450, render_rows_in)
            int hvn_total_wanted = math.min(50, hvn_abs_count + hvn_rel_count)
            int lvn_total_wanted = math.min(50, lvn_abs_count + lvn_rel_count)
            int node_pool_n = math.max(hvn_total_wanted, lvn_total_wanted)
            int lvg_pool_n = show_lvg ? math.min(12, lvg_max_zones) : 0
            int of_cap = 160
            bool of_bidask = str.contains(of_profile_type, 'Bid/Ask')
            bool of_delta_net = of_profile_type == 'Delta (Net)'
            bool of_strip_forced_to_split = of_bidask
            string of_vis_eff = of_delta_net ? 'Delta Strip (recommended)' : of_bidask ? 'Centered Split' : 'Delta Strip (recommended)'
            bool of_mode_strip = of_vis_eff == 'Delta Strip (recommended)'
            bool of_mode_split = of_vis_eff == 'Centered Split' or of_vis_eff == 'Stacked Split'
            bool of_intent = of_enable and of_profile_type != 'Total Volume (classic)'
            int npoc_pool_size = math.min(20, math.max(5, npoc_max_levels))
            bool hist_poc_mode_ok = f_hist_poc_mode_supported(range_mode)
            int hist_poc_pool_size = math.min(12, math.max(1, hist_poc_count))
            int hist_poc_line_slots = hist_poc_pool_size * 2
            int reserved_lines = 5
            reserved_lines += show_hvn ? hvn_total_wanted : 0
            reserved_lines += show_lvn ? lvn_total_wanted : 0
            reserved_lines += avwap_enable ? 7 : 0
            reserved_lines += npoc_enable ? npoc_pool_size : 0
            reserved_lines += (hist_poc_enable and hist_poc_mode_ok) ? hist_poc_line_slots : 0
            reserved_lines += (sess_style == 'Vertical Line' and timeframe.isintraday and timeframe.multiplier <= 60) ? sess_line_limit : 0
            reserved_lines += (ctx_pack_mode != 'Off' ? 5 : 0)
            int reserved_labels = 1
            reserved_labels += avwap_enable and avwap_show_labels ? 7 : 0
            reserved_labels += npoc_enable and npoc_labels ? npoc_pool_size : 0
            reserved_labels += (hist_poc_enable and hist_poc_mode_ok and hist_poc_show_labels) ? hist_poc_pool_size : 0
            reserved_labels += show_level_labels ? 1 : 0
            int box_budget_eff = math.max(30, 488)
            int line_budget_eff = math.max(20, 480 - reserved_lines)
            int label_budget_eff = math.max(10, 140 - reserved_labels)
            bool sess_boxes_active = sess_style == 'Box' and timeframe.isintraday and timeframe.multiplier <= 60
            int sess_boxes_total = sess_boxes_active ? array.size(sess_boxes) + f_count_active_session_boxes() : 0
            int sess_budget_max = sess_boxes_active ? math.min(sess_box_limit, box_budget_eff - 1) : 0
            int sess_room = box_budget_eff - (1 + lvg_pool_n + hvn_total_wanted + lvn_total_wanted)
            int sess_reserved = sess_boxes_active ? math.max(0, math.min(sess_boxes_total, math.min(sess_budget_max, sess_room))) : 0
            sess_box_cap_runtime := sess_boxes_active ? math.max(0, math.min(sess_budget_max, sess_room - 1)) : 0
            if sess_boxes_active
                while array.size(sess_boxes) + f_count_active_session_boxes() > sess_box_cap_runtime and array.size(sess_boxes) > 0
                    box old_sb = array.shift(sess_boxes)
                    box.delete(old_sb)
            else if array.size(sess_boxes) > 0
                while array.size(sess_boxes) > 0
                    box old_sb = array.shift(sess_boxes)
                    box.delete(old_sb)
            int fixed_boxes = 1 + lvg_pool_n + (show_hvn ? hvn_total_wanted : 0) + (show_lvn ? lvn_total_wanted : 0) + sess_reserved
            int available = box_budget_eff - fixed_boxes
            int render_n_pre = math.max(1, math.min(render_n_req, math.min(450, math.max(1, available))))
            if of_intent and of_mode_split
                int split_pre = math.min(render_n_pre, of_cap)
                int total_need = fixed_boxes + render_n_pre + split_pre * 2
                if total_need > box_budget_eff
                    if render_n_pre <= of_cap
                        render_n_pre := int(math.floor(float(box_budget_eff - fixed_boxes) / 3.0))
                    else
                        render_n_pre := box_budget_eff - fixed_boxes - 2 * of_cap
                    render_n_pre := math.max(1, math.min(render_n_req, math.min(450, render_n_pre)))
            int render_n_tick_cap = not na(ticks_span) ? math.max(1, ticks_span) : render_n_pre
            bool rows_tick_capped = render_n_pre > render_n_tick_cap
            int render_n = math.max(1, math.min(render_n_pre, render_n_tick_cap))
            int of_rows = of_intent ? (of_mode_split ? math.min(render_n, of_cap) : render_n) : 0
            bool rows_capped_budget = render_n_pre < render_n_req
            bool rows_capped = rows_capped_budget or rows_tick_capped
            f_ensure_float_array(vol_internal, internal_n)
            f_ensure_float_array(smt_internal, internal_n)
            f_ensure_float_array(pref_internal, internal_n + 1)
            f_ensure_float_array(pref_buy, internal_n + 1)
            f_ensure_float_array(pref_sell, internal_n + 1)
            f_ensure_float_array(diff_internal, internal_n + 1)
            f_ensure_float_array(vol_render, render_n)
            f_ensure_float_array(diff_buy_internal, internal_n + 1)
            f_ensure_float_array(diff_sell_internal, internal_n + 1)
            f_ensure_float_array(buy_internal, internal_n)
            f_ensure_float_array(sell_internal, internal_n)
            f_ensure_float_array(buy_smt_internal, internal_n)
            f_ensure_float_array(sell_smt_internal, internal_n)
            f_ensure_float_array(buy_render, render_n)
            f_ensure_float_array(sell_render, render_n)
            f_ensure_float_array(delta_render, render_n)
            array.fill(vol_internal, 0.0)
            array.fill(diff_internal, 0.0)
            array.fill(diff_buy_internal, 0.0)
            array.fill(diff_sell_internal, 0.0)
            float step_i = p_range / internal_n
            float inv_i = 1.0 / step_i
            bool dist_weighted = dist_mode == 'Body Weighted'
            bool fallback_used = false
            int fallback_bars = 0
            int native_bars_used = 0
            int native_bars_seen = 0
            int proxy_bars_used = 0
            int bars_without_native = 0
            string fallback_reason = ''
            bool strict_intrabar = of_require_intrabar == 'Strict (disable if no intrabar)'
            bool of_native_available_now = f_of_native_available_for_bar(of_native_fp_req)
            of_source_mode_active := of_enable ? (of_source_mode == 'Proxy Only' ? 'Proxy' : 'Native') : 'Off'
            of_native_available := of_native_available_now
            of_native_used := false
            of_fallback_used := false
            of_status_text := of_enable ? (of_source_mode == 'Proxy Only' ? 'OF Source: Proxy' : 'OF Source: Native') : 'OF Source: Off'
            of_status_reason := ''
            bool native_requested = of_enable and (of_source_mode == 'Auto' or of_source_mode == 'Native Only')
            bool proxy_bar_allowed = of_source_mode == 'Proxy Only' or of_source_mode == 'Auto'
            bool delta_available = of_enable
            bool of_need = of_intent and delta_available
            int last_sign = 1
            bool arrays_non_empty = not na(ltfV_series) and not na(ltfO_series) and not na(ltfH_series) and not na(ltfL_series) and not na(ltfC_series) and array.size(ltfV_series) > 0 and array.size(ltfO_series) > 0 and array.size(ltfH_series) > 0 and array.size(ltfL_series) > 0 and array.size(ltfC_series) > 0
            for bi = left_idx to right_idx by 1
                int off = bar_index - bi
                bool native_bar_processed = false
                if native_requested
                    footprint bar_fp = of_native_fp_req[off]
                    if not na(bar_fp)
                        native_bars_seen += 1
                        array<volume_row> rows_arr = footprint.rows(bar_fp)
                        int row_n = array.size(rows_arr)
                        if row_n > 0
                            native_bar_processed := true
                            native_bars_used += 1
                            for ri = 0 to row_n - 1 by 1
                                volume_row row = array.get(rows_arr, ri)
                                float row_hi = row.up_price()
                                float row_lo = row.down_price()
                                float row_buy = row.buy_volume()
                                float row_sell = row.sell_volume()
                                f_of_accumulate_native_row_into_bins(diff_internal, diff_buy_internal, diff_sell_internal, row_lo, row_hi, row_buy, row_sell, of_need, pmin, inv_i, internal_n)
                    if not native_bar_processed
                        bars_without_native += 1
                bool have_intrabar = intrabar_on and ltf_valid and allow_intrabar_processing and arrays_non_empty and (off <= needed_chart_bars_cap_intrabar - 1)
                if not native_bar_processed and proxy_bar_allowed and have_intrabar
                    proxy_bars_used += 1
                    array<float> oArr = ltfO_series[off]
                    array<float> cArr = ltfC_series[off]
                    array<float> hArr = ltfH_series[off]
                    array<float> lArr = ltfL_series[off]
                    array<float> vArr = ltfV_series[off]
                    int n = (na(hArr) or na(lArr) or na(vArr) or na(oArr) or na(cArr)) ? 0 : math.min(array.size(hArr), math.min(array.size(lArr), math.min(array.size(vArr), math.min(array.size(oArr), array.size(cArr)))))
                    if n > 0
                        for j = 0 to n - 1 by 1
                            float hi = array.get(hArr, j)
                            float lo = array.get(lArr, j)
                            float vv = array.get(vArr, j)
                            vv := na(vv) ? 0.0 : vv
                            float oo = array.get(oArr, j)
                            float cc = array.get(cArr, j)
                            float cp = j > 0 ? array.get(cArr, j - 1) : oo
                            if dist_weighted
                                f_add_weighted_ohlc(diff_internal, oo, hi, lo, cc, vv, pmin, inv_i, internal_n, body_weight_mult)
                            else
                                f_add_uniform_range(diff_internal, lo, hi, vv, pmin, inv_i, internal_n)
                            if of_need
                                int dsg = f_delta_sign_i(oo, cc, cp, last_sign, of_src_mode_req, of_neut_mode_req)
                                if dsg == 0
                                    f_add_uniform_range(diff_buy_internal, lo, hi, vv * 0.5, pmin, inv_i, internal_n)
                                    f_add_uniform_range(diff_sell_internal, lo, hi, vv * 0.5, pmin, inv_i, internal_n)
                                else if dsg == 99
                                    na
                                else if dsg > 0
                                    f_add_uniform_range(diff_buy_internal, lo, hi, vv, pmin, inv_i, internal_n)
                                    last_sign := 1
                                else
                                    f_add_uniform_range(diff_sell_internal, lo, hi, vv, pmin, inv_i, internal_n)
                                    last_sign := -1
                    else
                        fallback_used := true
                        fallback_bars += 1
                        if fallback_reason == ''
                            fallback_reason := 'No intrabar data'
                        if dist_weighted
                            f_add_weighted_ohlc(diff_internal, open[off], high[off], low[off], close[off], volume[off], pmin, inv_i, internal_n, body_weight_mult)
                        else
                            f_add_uniform_range(diff_internal, low[off], high[off], volume[off], pmin, inv_i, internal_n)
                        if of_need
                            if strict_intrabar
                                delta_available := false
                            else
                                int dsg_fb = f_delta_sign_i(open[off], close[off], close[off + 1], last_sign, of_src_mode_req, of_neut_mode_req)
                                if dsg_fb == 0
                                    f_add_uniform_range(diff_buy_internal, low[off], high[off], volume[off] * 0.5, pmin, inv_i, internal_n)
                                    f_add_uniform_range(diff_sell_internal, low[off], high[off], volume[off] * 0.5, pmin, inv_i, internal_n)
                                else if dsg_fb != 99
                                    if dsg_fb > 0
                                        f_add_uniform_range(diff_buy_internal, low[off], high[off], volume[off], pmin, inv_i, internal_n)
                                        last_sign := 1
                                    else
                                        f_add_uniform_range(diff_sell_internal, low[off], high[off], volume[off], pmin, inv_i, internal_n)
                                        last_sign := -1
                else if not native_bar_processed and proxy_bar_allowed
                    proxy_bars_used += 1
                    if intrabar_on
                        fallback_used := true
                        fallback_bars += 1
                        if fallback_reason == ''
                            fallback_reason := ltf_valid ? 'No intrabar data' : 'Invalid LTF (>= chart TF)'
                    if dist_weighted
                        f_add_weighted_ohlc(diff_internal, open[off], high[off], low[off], close[off], volume[off], pmin, inv_i, internal_n, body_weight_mult)
                    else
                        f_add_uniform_range(diff_internal, low[off], high[off], volume[off], pmin, inv_i, internal_n)
                    if of_need
                        if strict_intrabar
                            delta_available := false
                        else
                            int dsg2 = f_delta_sign_i(open[off], close[off], close[off + 1], last_sign, of_src_mode_req, of_neut_mode_req)
                            if dsg2 == 0
                                f_add_uniform_range(diff_buy_internal, low[off], high[off], volume[off] * 0.5, pmin, inv_i, internal_n)
                                f_add_uniform_range(diff_sell_internal, low[off], high[off], volume[off] * 0.5, pmin, inv_i, internal_n)
                            else if dsg2 != 99
                                if dsg2 > 0
                                    f_add_uniform_range(diff_buy_internal, low[off], high[off], volume[off], pmin, inv_i, internal_n)
                                    last_sign := 1
                                else
                                    f_add_uniform_range(diff_sell_internal, low[off], high[off], volume[off], pmin, inv_i, internal_n)
                                    last_sign := -1
            int range_bar_count = right_idx - left_idx + 1
            bool native_range_has_coverage = native_bars_used > 0
            bool native_partial = native_bars_used > 0 and bars_without_native > 0
            bool auto_proxy_fallback_active = of_source_mode == 'Auto' and proxy_bars_used > 0
            bool native_symbol_or_plan_unavailable = native_requested and native_bars_seen <= 0 and not of_native_available_now and bars_without_native >= range_bar_count
            of_fallback_bars_last := proxy_bars_used
            if of_enable
                of_native_available := native_bars_seen > 0 or of_native_available_now
                of_fallback_used := proxy_bars_used > 0 and of_source_mode != 'Proxy Only'
                if of_source_mode == 'Proxy Only'
                    of_native_coverage := 'proxy'
                else
                    of_native_coverage := native_range_has_coverage ? (native_partial ? 'partial' : 'full') : 'none'
                if of_source_mode == 'Auto'
                    if native_range_has_coverage
                        of_source_mode_active := 'Native'
                        of_native_used := true
                        of_status_text := 'OF Source: Auto → Native'
                        if auto_proxy_fallback_active
                            of_status_reason := 'Native partial | Auto FB. Native bars: ' + str.tostring(native_bars_used) + ' / Proxy bars: ' + str.tostring(proxy_bars_used) + '.'
                        else
                            of_status_reason := 'Native agg active. Native bars: ' + str.tostring(native_bars_used) + ' / Proxy bars: 0.'
                    else
                        of_source_mode_active := 'Proxy'
                        of_native_used := false
                        of_status_text := 'OF Source: Auto → Proxy fallback'
                        of_status_reason := native_symbol_or_plan_unavailable ? 'Native unavail (sym/plan/data). Native bars: 0 / Proxy bars: ' + str.tostring(proxy_bars_used) + '.' : 'Native unavail in range. Native bars: 0 / Proxy bars: ' + str.tostring(proxy_bars_used) + '.'
                else if of_source_mode == 'Native Only'
                    if native_range_has_coverage
                        of_source_mode_active := 'Native'
                        of_native_used := true
                        of_status_text := 'OF Source: Native'
                        of_status_reason := native_partial ? 'Native partial. Missing bars skipped (no proxy). Native bars: ' + str.tostring(native_bars_used) + ' / Missing native bars: ' + str.tostring(bars_without_native) + '.' : 'Native agg active. Native bars: ' + str.tostring(native_bars_used) + '.'
                    else
                        of_source_mode_active := 'Native unavail'
                        of_native_used := false
                        delta_available := false
                        of_status_text := 'OF Source: Native unavail'
                        of_status_reason := native_symbol_or_plan_unavailable ? 'Native unavail (sym/plan/data).' : 'Native unavail in range.'
                else if of_source_mode == 'Proxy Only'
                    of_source_mode_active := 'Proxy'
                    of_native_used := false
                    of_status_text := 'OF Source: Proxy'
                    of_status_reason := 'Proxy Only mode active.'
            float run = 0.0
            float run_buy = 0.0
            float run_sell = 0.0
            for i = 0 to internal_n - 1 by 1
                run := run + array.get(diff_internal, i)
                array.set(vol_internal, i, run)
                if of_need
                    run_buy := run_buy + array.get(diff_buy_internal, i)
                    run_sell := run_sell + array.get(diff_sell_internal, i)
                    array.set(buy_internal, i, run_buy)
                    array.set(sell_internal, i, run_sell)
            array.set(pref_internal, 0, 0.0)
            if of_need
                array.set(pref_buy, 0, 0.0)
                array.set(pref_sell, 0, 0.0)
            float rsum = 0.0
            float bsum_run = 0.0
            float ssum_run = 0.0
            for i = 0 to internal_n - 1 by 1
                rsum := rsum + array.get(vol_internal, i)
                array.set(pref_internal, i + 1, rsum)
                if of_need
                    bsum_run += array.get(buy_internal, i)
                    ssum_run += array.get(sell_internal, i)
                    array.set(pref_buy, i + 1, bsum_run)
                    array.set(pref_sell, i + 1, ssum_run)
            for i = 0 to internal_n - 1 by 1
                int l = math.max(0, i - smoothing_bins)
                int r = math.min(internal_n - 1, i + smoothing_bins)
                float sv = (array.get(pref_internal, r + 1) - array.get(pref_internal, l)) / (r - l + 1)
                array.set(smt_internal, i, sv)
                if of_need
                    float bsum = array.get(pref_buy, r + 1) - array.get(pref_buy, l)
                    float ssum = array.get(pref_sell, r + 1) - array.get(pref_sell, l)
                    array.set(buy_smt_internal, i, bsum / (r - l + 1))
                    array.set(sell_smt_internal, i, ssum / (r - l + 1))
            f_resample_sum(smt_internal, internal_n, vol_render, render_n)
            if of_need
                f_resample_sum(buy_smt_internal, internal_n, buy_render, render_n)
                f_resample_sum(sell_smt_internal, internal_n, sell_render, render_n)
            else
                array.fill(buy_render, 0.0)
                array.fill(sell_render, 0.0)
            float delta_abs_max = 0.0
            for i = 0 to render_n - 1 by 1
                float d = of_need ? (array.get(buy_render, i) - array.get(sell_render, i)) : 0.0
                array.set(delta_render, i, d)
                delta_abs_max := math.max(delta_abs_max, math.abs(d))
            float maxv = 0.0
            float totv = 0.0
            int poc_idx = 0
            for i = 0 to render_n - 1 by 1
                float v = array.get(vol_render, i)
                totv := totv + v
                if v > maxv
                    maxv := v
                    poc_idx := i
                    poc_idx
            int va_lo = poc_idx
            int va_hi = poc_idx
            float target_va = totv * va_percent * 0.01
            float va_sum = array.get(vol_render, poc_idx)
            while va_sum < target_va and (va_lo > 0 or va_hi < render_n - 1)
                float d = va_lo > 0 ? array.get(vol_render, va_lo - 1) : -1
                float u = va_hi < render_n - 1 ? array.get(vol_render, va_hi + 1) : -1
                if u >= d
                    va_hi := va_hi + 1
                    va_sum := va_sum + array.get(vol_render, va_hi)
                    va_sum
                else
                    va_lo := va_lo - 1
                    va_sum := va_sum + array.get(vol_render, va_lo)
                    va_sum
            float step_r = p_range / render_n
            float poc_price = f_snap_tick(pmin + (poc_idx + 0.5) * step_r)
            float vah_price = f_snap_tick(pmin + (va_hi + 1) * step_r)
            float val_price = f_snap_tick(pmin + va_lo * step_r)
            poc_price := math.max(pmin, math.min(pmax, poc_price))
            vah_price := math.max(pmin, math.min(pmax, vah_price))
            val_price := math.max(pmin, math.min(pmax, val_price))
            vah_price := math.max(vah_price, val_price)
            float va_buy = 0.0
            float va_tot = 0.0
            float cvd_sum = 0.0
            for i = 0 to render_n - 1 by 1
                float b = array.get(buy_render, i)
                float sv = array.get(sell_render, i)
                float tv = array.get(vol_render, i)
                if i >= va_lo and i <= va_hi
                    va_buy += b
                    va_tot += tv
                cvd_sum += array.get(delta_render, i)
            of_cvd := cvd_sum
            of_delta_at_poc := array.get(delta_render, poc_idx)
            of_max_abs_delta := delta_abs_max
            of_buy_pct_in_va := va_tot > 0 ? va_buy / va_tot : na
            int hvn_wanted_eff = math.min(50, hvn_abs_count + hvn_rel_count)
            int lvn_wanted_eff = math.min(50, lvn_abs_count + lvn_rel_count)
            int node_sep_eff = node_min_separation_bins
            float hvn_thr_abs_eff = maxv * hvn_prominence_pct * 0.01
            float lvn_thr_abs_eff = maxv * lvn_threshold_pct * 0.01
            if node_tuning_mode == 'Auto (Count-driven)'
                int wanted_max = math.max(1, math.max(hvn_wanted_eff, lvn_wanted_eff))
                node_sep_eff := math.max(1, int(math.round(render_n / math.max(12.0, wanted_max * 3.0))))
                array<float> node_cp = f_sorted_copy(vol_render, render_n)
                float hvn_q = f_clamp(0.90 - math.max(0, hvn_wanted_eff - 1) * 0.03, 0.45, 0.90)
                float lvn_q = f_clamp(0.08 + math.max(0, lvn_wanted_eff - 1) * 0.025, 0.08, 0.45)
                hvn_thr_abs_eff := hvn_wanted_eff > 0 ? f_quantile_from_sorted(node_cp, render_n, hvn_q) : maxv * 2.0
                lvn_thr_abs_eff := lvn_wanted_eff > 0 ? f_quantile_from_sorted(node_cp, render_n, lvn_q) : -1.0
            array<int> hvn_abs_idx_tmp = array.new_int(0)
            array<int> lvn_abs_idx_tmp = array.new_int(0)
            array<int> hvn_rel_idx_tmp = array.new_int(0)
            array<int> lvn_rel_idx_tmp = array.new_int(0)
            f_pick_nodes(hvn_abs_idx_tmp, vol_render, render_n, true, hvn_abs_count, node_sep_eff, hvn_thr_abs_eff)
            f_pick_nodes(lvn_abs_idx_tmp, vol_render, render_n, false, lvn_abs_count, node_sep_eff, lvn_thr_abs_eff)
            f_pick_relative_nodes(hvn_rel_idx_tmp, vol_render, render_n, true, hvn_rel_count, node_sep_eff, hvn_thr_abs_eff)
            f_pick_relative_nodes(lvn_rel_idx_tmp, vol_render, render_n, false, lvn_rel_count, node_sep_eff, lvn_thr_abs_eff)
            f_merge_unique_ranked(hvn_idx, hvn_abs_idx_tmp, hvn_rel_idx_tmp, hvn_wanted_eff)
            f_merge_unique_ranked(lvn_idx, lvn_abs_idx_tmp, lvn_rel_idx_tmp, lvn_wanted_eff)
            array.clear(lvg_start)
            array.clear(lvg_end)
            if show_lvg and render_n > 0 and maxv > 0
                array<float> lvg_cp = na
                float lvg_med = na
                bool need_sorted = lvg_threshold_mode == 'Quantile' or lvg_auto_scale
                if need_sorted
                    lvg_cp := f_sorted_copy(vol_render, render_n)
                    lvg_med := f_quantile_from_sorted(lvg_cp, render_n, 0.5)
                float lvg_eff = lvg_threshold_value
                if lvg_auto_scale
                    lvg_eff := lvg_threshold_value * f_lvg_tf_scale() * f_lvg_dist_scale(maxv, lvg_med)
                    lvg_eff
                float eff_clamped = f_clamp(lvg_eff, 0.5, 50.0)
                float lvg_thr = 0.0
                if lvg_threshold_mode == 'Quantile'
                    float q = math.min(0.5, eff_clamped * 0.01)
                    if na(lvg_cp)
                        lvg_cp := f_sorted_copy(vol_render, render_n)
                    lvg_thr := f_quantile_from_sorted(lvg_cp, render_n, q)
                else
                    lvg_thr := maxv * eff_clamped * 0.01
                int s = -1
                for i = 0 to render_n - 1 by 1
                    float v = array.get(vol_render, i)
                    bool thin = v <= lvg_thr
                    if thin and s == -1
                        s := i
                        s
                    if (not thin or i == render_n - 1) and s != -1
                        int e = thin and i == render_n - 1 ? i : i - 1
                        if e - s + 1 >= lvg_min_height_bins
                            array.push(lvg_start, s)
                            array.push(lvg_end, e)
                        s := -1
                        s
                int zone_count = array.size(lvg_start)
                if zone_count > lvg_max_zones
                    array<float> lvg_scores = array.new_float(zone_count, 0.0)
                    array<bool> lvg_picked = array.new_bool(zone_count, false)
                    for i = 0 to zone_count - 1 by 1
                        int zs_i = array.get(lvg_start, i)
                        int ze_i = array.get(lvg_end, i)
                        int height_i = ze_i - zs_i + 1
                        float sum_i = 0.0
                        for k = zs_i to ze_i by 1
                            sum_i := sum_i + array.get(vol_render, k)
                        float avg_i = height_i > 0 ? sum_i / height_i : sum_i
                        array.set(lvg_scores, i, avg_i)
                    array<int> sel_start = array.new_int(0)
                    array<int> sel_end = array.new_int(0)
                    for _ = 0 to lvg_max_zones - 1 by 1
                        int best_idx = -1
                        float best_score = 10e10
                        for i = 0 to zone_count - 1 by 1
                            if not array.get(lvg_picked, i)
                                float sc = array.get(lvg_scores, i)
                                if best_idx == -1 or sc < best_score
                                    best_idx := i
                                    best_score := sc
                        if best_idx != -1
                            array.set(lvg_picked, best_idx, true)
                            array.push(sel_start, array.get(lvg_start, best_idx))
                            array.push(sel_end, array.get(lvg_end, best_idx))
                    array.clear(lvg_start)
                    array.clear(lvg_end)
                    for i = 0 to array.size(sel_start) - 1 by 1
                        array.push(lvg_start, array.get(sel_start, i))
                        array.push(lvg_end, array.get(sel_end, i))
            float prev_ads_poc = ads_poc
            float prev_ads_vah = ads_vah
            float prev_ads_val = ads_val
            ads_poc := poc_price
            ads_vah := vah_price
            ads_val := val_price
            vp_poc_last := poc_price
            vp_vah_last := vah_price
            vp_val_last := val_price
            ads_value_mid := (ads_vah + ads_val) * 0.5
            ads_profile_w := math.max(ads_vah - ads_val, syminfo.mintick)
            int range_len = right_idx - left_idx + 1
            int ref_interval = math.max(10, math.min(60, int(math.round(range_len * 0.02))))
            bool session_roll = mode_session and not na(ads_last_session_left) and (left_idx != ads_last_session_left)
            if mode_session
                if na(ads_last_session_left)
                    ads_last_session_left := left_idx
                else if session_roll
                    if not na(prev_ads_poc)
                        ads_prev_sess_poc := prev_ads_poc
                        ads_prev_sess_vah := prev_ads_vah
                        ads_prev_sess_val := prev_ads_val
                        ads_ref_poc := ads_prev_sess_poc
                        ads_ref_vah := ads_prev_sess_vah
                        ads_ref_val := ads_prev_sess_val
                    ads_last_session_left := left_idx
            else if na(ads_ref_bar_index) or bar_index - ads_ref_bar_index >= ref_interval
                ads_ref_poc := ads_poc
                ads_ref_vah := ads_vah
                ads_ref_val := ads_val
                ads_ref_bar_index := bar_index
            [ovh, ovl, shf, rh, rl, rvt, skt, tpt, drf, nvt] = f_ads_auto_thresholds(ads_strictness, ads_profile_w, range_len)
            ads_shape := f_ads_shape(vol_render, render_n, skt)
            [ads_tail_low_tmp, ads_tail_high_tmp] = f_ads_tails(vol_render, render_n, tpt)
            ads_tail_low := ads_tail_low_tmp
            ads_tail_high := ads_tail_high_tmp
            if not na(ads_ref_poc)
                ads_overlap := f_ads_overlap(ads_vah, ads_val, ads_ref_vah, ads_ref_val)
                ads_shift := f_ads_shift(ads_poc, ads_ref_poc, ads_profile_w)
            int av_anchor_idx = left_idx
            if avwap_anchor == 'Session Start (engine current)' and not na(sess_start0_series)
                av_anchor_idx := sess_start0_series
            else if avwap_anchor == 'Daily (TZ)'
                av_anchor_idx := avwap_anchor_day_series
            else if avwap_anchor == 'Weekly (TZ)'
                av_anchor_idx := avwap_anchor_week_series
            else if avwap_anchor == 'Manual (timestamp)'
                av_anchor_idx := avwap_anchor_manual_series
            av_anchor_idx := na(av_anchor_idx) ? left_idx : math.max(left_idx, math.min(right_idx, av_anchor_idx))
            float av_sumv = 0.0
            float av_sumpv = 0.0
            float av_sump2v = 0.0
            float av_simple_sum = 0.0
            float av_simple_sum2 = 0.0
            int av_n = 0
            for bi = av_anchor_idx to right_idx by 1
                int off = bar_index - bi
                float pp = avwap_src == 'Close' ? close[off] : (high[off] + low[off] + close[off]) / 3.0
                float vv = math.max(0.0, volume[off])
                av_sumv += vv
                av_sumpv += pp * vv
                av_sump2v += pp * pp * vv
                av_simple_sum += pp
                av_simple_sum2 += pp * pp
                av_n += 1
            float av_vwap = av_sumv > 0 ? av_sumpv / av_sumv : na
            float av_var = na
            if avwap_band_method == 'Volume-Weighted'
                av_var := av_sumv > 0 ? av_sump2v / av_sumv - av_vwap * av_vwap : na
            else
                float mu = av_n > 0 ? av_simple_sum / av_n : na
                av_var := av_n > 1 ? av_simple_sum2 / av_n - mu * mu : na
            float av_sd = na(av_var) ? na : math.sqrt(math.max(0.0, av_var))
            int width_use = dock_width_bars
            int gap_use = math.max(0, dock_gap_bars)
            int x0 = right_idx + gap_use
            int x1 = x0 + width_use
            int px0 = x0
            int px1 = x1
            if px1 <= px0
                px1 := px0 + 1
                px1
            if na(panel_box)
                panel_box := box.new(x0, pmax, x1, pmin, xloc = xloc.bar_index)
                panel_box
            box.set_lefttop(panel_box, x0, pmax)
            box.set_rightbottom(panel_box, x1, pmin)
            box.set_bgcolor(panel_box, color.new(color.black, panel_bg_alpha))
            box.set_border_color(panel_box, color.new(area_color, 99))
            f_ensure_row_boxes(render_n)
            bool of_draw_active = of_intent and delta_available
            bool show_base_profile = not of_draw_active or of_show_base_underlay
            bool need_row_geom = show_base_profile or (of_draw_active and of_mode_strip)
            for r = 0 to render_n - 1 by 1
                box rb = array.get(row_boxes, r)
                float v = array.get(vol_render, r)
                float y0 = pmin + r * step_r
                float y1 = y0 + step_r
                if need_row_geom and maxv > 0 and v > 0
                    float nrm = math.min(1.0, v / maxv)
                    float curved = math.pow(nrm, intensity_gamma)
                    int usable_w = math.max(1, px1 - px0)
                    int span = math.max(1, int(math.round(curved * usable_w)))
                    int bxL = px1 - span
                    int bxR = px1
                    int a = math.max(18, 90 - int(curved * 75))
                    color c = style_mode == 'Monochrome (No-Heatmap)' ? color.new(color.gray, a) : color.new(area_color, a)
                    if style_mode == 'Histogram (Classic)'
                        bool is_va_row = show_va and r >= va_lo and r <= va_hi
                        color classic_base = is_va_row ? color.rgb(math.min(255, color.r(area_color) + 24), math.min(255, color.g(area_color) + 24), math.min(255, color.b(area_color) + 24)) : area_color
                        c := color.new(classic_base, 70)
                        c
                    else if style_mode == 'Heatmap (Pro)'
                        color c_raw = color.from_gradient(curved, 0.0, 1.0, heat_low_col, heat_high_col)
                        int heat_alpha = math.max(10, math.min(80, 92 - int(curved * 78)))
                        if show_va and r >= va_lo and r <= va_hi
                            heat_alpha := math.max(10, heat_alpha - 10)
                        c := color.new(c_raw, heat_alpha)
                    box.set_lefttop(rb, bxL, y1)
                    box.set_rightbottom(rb, bxR, y0)
                    box.set_bgcolor(rb, show_base_profile ? c : color.new(color.black, 100))
                    box.set_border_color(rb, color.new(area_color, 98))
                else
                    f_hide_box(rb)
            f_ensure_box_pool(delta_strip_boxes, 0)
            f_ensure_box_pool(split_buy_boxes, (of_draw_active and of_mode_split) ? of_rows : 0)
            f_ensure_box_pool(split_sell_boxes, (of_draw_active and of_mode_split) ? of_rows : 0)
            if of_draw_active and of_mode_split and of_rows > 0
                for r = 0 to of_rows - 1 by 1
                    box bb = array.get(split_buy_boxes, r)
                    box sb = array.get(split_sell_boxes, r)
                    int r0 = int(math.floor(float(r) * float(render_n) / float(of_rows)))
                    int r1 = int(math.floor(float(r + 1) * float(render_n) / float(of_rows))) - 1
                    r0 := math.max(0, math.min(render_n - 1, r0))
                    r1 := math.max(r0, math.min(render_n - 1, r1))
                    float y0 = pmin + r0 * step_r
                    float y1 = pmin + (r1 + 1) * step_r
                    float b = 0.0
                    float sv = 0.0
                    float tv = 0.0
                    for rr = r0 to r1 by 1
                        b += array.get(buy_render, rr)
                        sv += array.get(sell_render, rr)
                        tv += array.get(vol_render, rr)
                    tv := math.max(1e-10, tv)
                    float seg_den = tv
                    int mid = px0 + (px1 - px0) / 2
                    float br = math.min(1.0, b / tv)
                    float sr = math.min(1.0, sv / seg_den)
                    int bw = math.max(1, int(math.round((px1 - px0) * 0.45 * br)))
                    int sw = math.max(1, int(math.round((px1 - px0) * 0.45 * sr)))
                    int of_alpha_min = math.min(of_fill_alpha_min, of_fill_alpha_max)
                    int of_alpha_max = math.max(of_fill_alpha_min, of_fill_alpha_max)
                    int buy_alpha = of_alpha_max - int((of_alpha_max - of_alpha_min) * br)
                    int sell_alpha = of_alpha_max - int((of_alpha_max - of_alpha_min) * sr)
                    if of_vis_eff == 'Centered Split'
                        box.set_lefttop(sb, mid - sw, y1)
                        box.set_rightbottom(sb, mid, y0)
                        box.set_bgcolor(sb, color.new(of_sell_col, sell_alpha))
                        box.set_border_color(sb, color.new(of_sell_col, 85))
                        box.set_lefttop(bb, mid, y1)
                        box.set_rightbottom(bb, mid + bw, y0)
                        box.set_bgcolor(bb, color.new(of_buy_col, buy_alpha))
                        box.set_border_color(bb, color.new(of_buy_col, 85))
                    else
                        int left = px1 - (bw + sw)
                        box.set_lefttop(sb, left, y1)
                        box.set_rightbottom(sb, left + sw, y0)
                        box.set_bgcolor(sb, color.new(of_sell_col, sell_alpha))
                        box.set_border_color(sb, color.new(of_sell_col, 85))
                        box.set_lefttop(bb, left + sw, y1)
                        box.set_rightbottom(bb, left + sw + bw, y0)
                        box.set_bgcolor(bb, color.new(of_buy_col, buy_alpha))
                        box.set_border_color(bb, color.new(of_buy_col, 85))
            if of_draw_active and of_mode_strip and of_rows > 0
                int of_alpha_min = math.min(of_fill_alpha_min, of_fill_alpha_max)
                int of_alpha_max = math.max(of_fill_alpha_min, of_fill_alpha_max)
                for r = 0 to of_rows - 1 by 1
                    box rb = array.get(row_boxes, r)
                    float d = array.get(delta_render, r)
                    float row_v = math.max(0.0, array.get(vol_render, r))
                    float len_ratio = math.pow(math.min(1.0, row_v / math.max(1e-10, maxv)), intensity_gamma)
                    int delta_alpha = of_alpha_max - int((of_alpha_max - of_alpha_min) * len_ratio)
                    color dc = d > 0 ? color.new(of_delta_pos_col, delta_alpha) : d < 0 ? color.new(of_delta_neg_col, delta_alpha) : color.new(line_color, 60)
                    box.set_bgcolor(rb, dc)
                    box.set_border_width(rb, 0)
                    box.set_border_color(rb, color.new(dc, 100))
            else if render_n > 0
                for r = 0 to render_n - 1 by 1
                    box rb = array.get(row_boxes, r)
                    box.set_border_width(rb, 1)
                    box.set_border_color(rb, color.new(area_color, 98))
            if na(poc_line)
                poc_line := line.new(px0, poc_price, px1, poc_price, xloc = xloc.bar_index)
                vah_line := line.new(px0, vah_price, px1, vah_price, xloc = xloc.bar_index)
                val_line := line.new(px0, val_price, px1, val_price, xloc = xloc.bar_index)
                hi_line := line.new(px0, pmax, px1, pmax, xloc = xloc.bar_index)
                lo_line := line.new(px0, pmin, px1, pmin, xloc = xloc.bar_index)
                level_label := label.new(px1, poc_price, '', xloc = xloc.bar_index, style = label.style_label_left)
                warn_label := label.new(px1, pmax, '', xloc = xloc.bar_index, style = label.style_label_left)
                warn_label
            color C_POC = color.new(line_color, 0)
            color C_VA = color.new(line_color, 35)
            color C_NODE = color.new(line_color, 55)
            color C_NODE2 = color.new(line_color, 70)
            color C_HILO = color.new(color.white, 82)
            color C_LVGf = color.new(area_color, 90)
            color C_LVGb = color.new(area_color, 70)
            int level_x0 = extend_level_rays ? left_idx : px0
            int level_x1 = extend_level_rays ? px0 : px1
            line.set_extend(poc_line, extend.none)
            line.set_extend(vah_line, extend.none)
            line.set_extend(val_line, extend.none)
            if show_poc
                line.set_xy1(poc_line, level_x0, poc_price)
                line.set_xy2(poc_line, level_x1, poc_price)
                line.set_color(poc_line, C_POC)
                line.set_width(poc_line, 1)
                line.set_style(poc_line, line.style_solid)
            else
                f_hide_line(poc_line)
            if show_va
                line.set_xy1(vah_line, level_x0, vah_price)
                line.set_xy2(vah_line, level_x1, vah_price)
                line.set_xy1(val_line, level_x0, val_price)
                line.set_xy2(val_line, level_x1, val_price)
                line.set_color(vah_line, C_VA)
                line.set_color(val_line, C_VA)
                line.set_width(vah_line, 1)
                line.set_width(val_line, 1)
                line.set_style(vah_line, line.style_dashed)
                line.set_style(val_line, line.style_dashed)
            else
                f_hide_line(vah_line)
                f_hide_line(val_line)
            if show_profile_hilo
                line.set_xy1(hi_line, px0, pmax)
                line.set_xy2(hi_line, px1, pmax)
                line.set_xy1(lo_line, px0, pmin)
                line.set_xy2(lo_line, px1, pmin)
                line.set_color(hi_line, C_HILO)
                line.set_color(lo_line, C_HILO)
                line.set_width(hi_line, 1)
                line.set_width(lo_line, 1)
            else
                f_hide_line(hi_line)
                f_hide_line(lo_line)
            if show_level_labels
                string txt = 'POC ' + str.tostring(poc_price, format.mintick)
                txt := txt + (show_va ? ' | VAH ' + str.tostring(vah_price, format.mintick) + ' | VAL ' + str.tostring(val_price, format.mintick) : '')
                label.set_xy(level_label, px1, poc_price)
                label.set_text(level_label, txt)
                label.set_textcolor(level_label, color.new(color.white, 0))
                label.set_color(level_label, color.new(color.black, 70))
                label.set_size(level_label, size.small)
            else
                f_hide_label(level_label)
            f_ensure_line_pool(hvn_lines, show_hvn ? hvn_total_wanted : 0)
            f_ensure_line_pool(lvn_lines, show_lvn ? lvn_total_wanted : 0)
            f_ensure_node_boxes(hvn_boxes, show_hvn ? hvn_total_wanted : 0)
            f_ensure_node_boxes(lvn_boxes, show_lvn ? lvn_total_wanted : 0)
            if node_pool_n > 0
                for i = 0 to node_pool_n - 1 by 1
                    line l1 = show_hvn and i < array.size(hvn_lines) ? array.get(hvn_lines, i) : na
                    line l2 = show_lvn and i < array.size(lvn_lines) ? array.get(lvn_lines, i) : na
                    box hb = show_hvn and i < array.size(hvn_boxes) ? array.get(hvn_boxes, i) : na
                    box lb = show_lvn and i < array.size(lvn_boxes) ? array.get(lvn_boxes, i) : na
                    f_hide_box(hb)
                    f_hide_box(lb)
                    if show_hvn and i < array.size(hvn_idx)
                        int idx = array.get(hvn_idx, i)
                        float py = f_snap_tick(pmin + (idx + 0.5) * step_r)
                        line.set_xy1(l1, level_x0, py)
                        line.set_xy2(l1, level_x1, py)
                        line.set_color(l1, C_NODE)
                        line.set_width(l1, 1)
                        line.set_style(l1, line.style_solid)
                        line.set_extend(l1, extend.none)
                    else
                        f_hide_line(l1)
                    if show_lvn and i < array.size(lvn_idx)
                        int idx2 = array.get(lvn_idx, i)
                        float py2 = f_snap_tick(pmin + (idx2 + 0.5) * step_r)
                        line.set_xy1(l2, level_x0, py2)
                        line.set_xy2(l2, level_x1, py2)
                        line.set_color(l2, C_NODE2)
                        line.set_width(l2, 2)
                        line.set_style(l2, line.style_dotted)
                        line.set_extend(l2, extend.none)
                    else
                        f_hide_line(l2)
            int zone_x0 = left_idx
            int zone_x1 = px0
            if zone_x1 <= zone_x0
                zone_x1 := zone_x0 + 1
                zone_x1
            int zcount = lvg_pool_n > 0 ? array.size(lvg_start) : 0
            zcount := math.min(zcount, lvg_pool_n)
            f_ensure_lvg_boxes(lvg_pool_n)
            if lvg_pool_n > 0
                for i = 0 to lvg_pool_n - 1 by 1
                    box zb = array.get(lvg_boxes, i)
                    if i < zcount
                        int zs = array.get(lvg_start, i)
                        int ze = array.get(lvg_end, i)
                        float zy0_raw = pmin + zs * step_r
                        float zy1_raw = pmin + (ze + 1) * step_r
                        float zy0 = math.max(pmin, f_floor_tick(zy0_raw))
                        float zy1 = math.min(pmax, f_ceil_tick(zy1_raw))
                        if zy1 <= zy0
                            zy1 := math.min(pmax, zy0 + syminfo.mintick)
                        box.set_lefttop(zb, zone_x0, zy1)
                        box.set_rightbottom(zb, zone_x1, zy0)
                        box.set_bgcolor(zb, C_LVGf)
                        box.set_border_color(zb, color.new(C_LVGb, 100))
                        box.set_extend(zb, extend.none)
                    else
                        f_hide_box(zb)
                        box.set_extend(zb, extend.none)
            int avwap_pool_size = avwap_enable ? 7 : 0
            f_ensure_line_pool(avwap_lines, avwap_pool_size)
            f_ensure_label_pool(avwap_labels, avwap_pool_size)
            array<float> mults = array.new_float(0)
            if str.contains(avwap_band_mults, '±1σ')
                array.push(mults, 1.0)
            if str.contains(avwap_band_mults, '±2σ')
                array.push(mults, 2.0)
            if str.contains(avwap_band_mults, '±3σ')
                array.push(mults, 3.0)
            int av_count = 0
            int avwap_pool_n = array.size(avwap_lines)
            if avwap_pool_n > 0
                for i = 0 to avwap_pool_n - 1 by 1
                    f_hide_line(array.get(avwap_lines, i))
                    f_hide_label(array.get(avwap_labels, i))
            if avwap_enable and avwap_pool_n > 0 and not na(av_vwap)
                line base = array.get(avwap_lines, av_count)
                line.set_xy1(base, av_anchor_idx, av_vwap)
                line.set_xy2(base, px1, av_vwap)
                line.set_color(base, color.new(color.yellow, 0))
                line.set_width(base, 2)
                av_count += 1
                if avwap_show_labels
                    label lb0 = array.get(avwap_labels, 0)
                    label.set_xy(lb0, px1 + 1, av_vwap)
                    label.set_text(lb0, 'AVWAP')
                    label.set_color(lb0, color.new(color.black, 65))
                    label.set_textcolor(lb0, color.new(color.yellow, 0))
                if avwap_bands_enable and not na(av_sd)
                    for i = 0 to array.size(mults) - 1 by 1
                        float m = array.get(mults, i)
                        float up = av_vwap + m * av_sd
                        float dn = av_vwap - m * av_sd
                        line lup = array.get(avwap_lines, av_count)
                        line ldn = array.get(avwap_lines, av_count + 1)
                        line.set_xy1(lup, av_anchor_idx, up)
                        line.set_xy2(lup, px1, up)
                        line.set_xy1(ldn, av_anchor_idx, dn)
                        line.set_xy2(ldn, px1, dn)
                        line.set_color(lup, color.new(color.yellow, 45))
                        line.set_color(ldn, color.new(color.yellow, 45))
                        av_count += 2
            npoc_pool_size := math.min(20, math.max(1, npoc_max_levels))
            int npoc_line_headroom = math.max(0, line_budget_eff - 12)
            int npoc_label_headroom = math.max(0, label_budget_eff - 4)
            int npoc_draw_pool = npoc_enable ? math.min(npoc_pool_size, npoc_line_headroom) : 0
            int npoc_label_pool = npoc_enable and npoc_labels ? math.min(npoc_draw_pool, npoc_label_headroom) : 0
            f_ensure_line_pool(npoc_lines, npoc_draw_pool)
            f_ensure_label_pool(npoc_labels_pool, npoc_label_pool)
            if npoc_draw_pool > 0
                for i = 0 to npoc_draw_pool - 1 by 1
                    f_hide_line(array.get(npoc_lines, i))
            if npoc_label_pool > 0
                for i = 0 to npoc_label_pool - 1 by 1
                    f_hide_label(array.get(npoc_labels_pool, i))
            if npoc_enable
                array<int> sel_idx = array.new_int(0)
                array<float> sel_score = array.new_float(0)
                int n = array.size(npoc_price)
                if n > 0
                    for j = 0 to n - 1 by 1
                        int i = (n - 1) - j
                        bool src_ok = (npoc_source == 'Both') or (npoc_source == 'Daily' and array.get(npoc_kind, i) == 'D') or (npoc_source == 'Session' and array.get(npoc_kind, i) == 'S')
                        if src_ok and not array.get(npoc_tested, i)
                            float lvl = array.get(npoc_price, i)
                            float dist = math.abs(close - lvl)
                            float s_recent = 1.0 / (math.max(0, bar_index - array.get(npoc_close_idx, i)) + 1.0)
                            float s_near = 1.0 / (dist + syminfo.mintick)
                            float sc = npoc_prioritize == 'Most recent' ? s_recent : npoc_prioritize == 'Nearest' ? s_near : (0.6 * s_near + 0.4 * s_recent)
                            array.push(sel_idx, i)
                            array.push(sel_score, sc)
                int draw_n = math.min(npoc_draw_pool, math.min(npoc_max_levels, array.size(sel_idx)))
                if draw_n > 0
                    array<float> chosen_lvls = array.new_float(0)
                    float min_sep = syminfo.mintick * 20.0
                    for d = 0 to draw_n - 1 by 1
                        bool accepted = false
                        int csz = array.size(sel_idx)
                        if csz > 0
                            for attempt = 0 to csz - 1 by 1
                                int best_j = -1
                                float best_sc = na
                                for j = 0 to csz - 1 by 1
                                    int cand_i = array.get(sel_idx, j)
                                    float cand_sc = array.get(sel_score, j)
                                    if cand_i != -1 and (best_j == -1 or cand_sc > best_sc)
                                        best_j := j
                                        best_sc := cand_sc
                                        best_sc
                                if best_j == -1
                                    break
                                int idx = array.get(sel_idx, best_j)
                                array.set(sel_idx, best_j, -1)
                                float lvl = array.get(npoc_price, idx)
                                bool too_close = false
                                int ck = array.size(chosen_lvls)
                                if ck > 0
                                    for k = 0 to ck - 1 by 1
                                        if math.abs(lvl - array.get(chosen_lvls, k)) <= min_sep
                                            too_close := true
                                            break
                                if too_close
                                    continue
                                accepted := true
                                array.push(chosen_lvls, lvl)
                                int age_ord = math.max(0, npoc_ord_counter - array.get(npoc_ord, idx))
                                int alpha = npoc_fade_by_age ? math.min(70, 20 + age_ord * 8) : 25
                                int xst = array.get(npoc_close_idx, idx) + 1
                                xst := math.min(px1, xst)
                                line nln = array.get(npoc_lines, d)
                                line.set_xy1(nln, xst, lvl)
                                line.set_xy2(nln, px1, lvl)
                                line.set_style(nln, line.style_dotted)
                                line.set_color(nln, color.new(color.aqua, alpha))
                                if npoc_labels and d < npoc_label_pool
                                    label nlb = array.get(npoc_labels_pool, d)
                                    label.set_xy(nlb, px1 + 1, lvl)
                                    string ktxt = array.get(npoc_kind, idx) == 'D' ? 'D' : array.get(npoc_tag, idx)
                                    int back = age_ord + 1
                                    string lt = 'NPOC ' + ktxt + '-' + str.tostring(back)
                                    label.set_text(nlb, lt)
                                    label.set_color(nlb, color.new(color.black, 75))
                                    label.set_textcolor(nlb, color.new(color.aqua, 0))
                                break
            f_render_hist_pocs(hist_poc_enable, range_mode, bar_comp_tf, bar_comp_n, hist_poc_count, hist_poc_show_labels, hist_poc_fade_by_age, line_budget_eff, label_budget_eff, px1)
            npoc_prev_enable := npoc_enable
            bool ads_panel_on = ads_enable and ads_show_panel
            bool ctx_panel_on = ctx_pack_on and ctx_show_panel
            bool ctx_prev_ready = ctx_prev_valid and not na(ctx_pd_poc) and not na(ctx_pd_vah) and not na(ctx_pd_val)
            bool sig_panel_on = sig_enable
            bool avwap_panel_on = avwap_enable and not na(av_vwap)
            bool marker_legend_on = (ads_panel_on or sig_panel_on) and ads_show_marker_legend
            bool magnet_on = npoc_enable or show_hvn or show_lvn or show_lvg
            string magnet_txt = magnet_on ? f_panel_nearest_magnet_txt(npoc_enable, show_hvn, show_lvn, show_lvg, close, pmin, step_r) : ''
            string va_loc_txt = f_panel_va_loc(close, vah_price, val_price)
            float value_w = (not na(vah_price) and not na(val_price)) ? (vah_price - val_price) : ads_profile_w
            string poc_dist_txt = f_panel_poc_dist(close, poc_price, value_w)
            int panel_rows = f_panel_rows_needed(true, ads_panel_on, marker_legend_on, ctx_panel_on, ctx_extras_on, ctx_prev_ready, sig_panel_on, avwap_enable, not na(av_vwap), magnet_txt != '', of_enable)
            if dirty_cfg or na(vcd_panel) or panel_rows != last_panel_rows
                if not na(vcd_panel)
                    table.delete(vcd_panel)
                vcd_panel := table.new(f_panel_pos(panel_location), 2, panel_rows, border_width = 1)
                last_panel_rows := panel_rows
            if not na(vcd_panel) and not na(last_panel_rows) and last_panel_rows > 0
                table.clear(vcd_panel, 0, 0, 1, last_panel_rows - 1)
                color key_bg = color.new(color.black, 25)
                color val_bg = color.new(color.black, 18)
                int row = 0
                if marker_legend_on
                    row := f_panel_put_marker_legend(vcd_panel, row, color.new(color.rgb(33, 42, 62), 16))
                row := f_panel_put_row(vcd_panel, row, 'VCD', 'Overview', color.new(color.white, 0), key_bg, key_bg)
                row := f_panel_put_row(vcd_panel, row, 'Range', f_panel_range_txt(range_mode, bars_in_range, session_engine, sess_timezone, range_fallback_used, range_reason), color.new(color.white, 0), key_bg, val_bg)
                row := f_panel_put_row(vcd_panel, row, 'VA Loc', va_loc_txt, color.new(color.white, 0), key_bg, val_bg)
                row := f_panel_put_row(vcd_panel, row, 'POC Dist', poc_dist_txt, color.new(color.white, 0), key_bg, val_bg)
                if magnet_txt != ''
                    row := f_panel_put_row(vcd_panel, row, 'Magnet', magnet_txt, color.new(color.aqua, 0), key_bg, val_bg)
                string bias_txt = ads_bias > 10 ? 'Up' : ads_bias < -10 ? 'Dn' : 'N'
                string rev_txt = ads_reversal_risk >= 70 ? 'High' : ads_reversal_risk >= 40 ? 'Med' : 'Low'
                color bias_col = ads_bias > 10 ? color.new(color.lime, 0) : ads_bias < -10 ? color.new(color.red, 0) : color.new(color.gray, 5)
                color rev_col = ads_reversal_risk >= 70 ? color.new(color.orange, 0) : ads_reversal_risk >= 40 ? color.new(color.yellow, 0) : color.new(color.lime, 0)
                if ads_panel_on
                    row := f_panel_put_row(vcd_panel, row, 'Regime', ads_state, color.new(color.white, 0), key_bg, val_bg)
                    row := f_panel_put_row(vcd_panel, row, 'Bias/Rev', bias_txt + ' | ' + rev_txt, ads_reversal_risk >= 70 ? rev_col : bias_col, key_bg, val_bg)
                    row := f_panel_put_row(vcd_panel, row, 'Shape', ads_shape, color.new(color.white, 0), key_bg, val_bg)
                    if not na(ads_overlap)
                        string rot_ovl_txt = 'Rot ' + str.tostring(ads_rotation) + ' | OVL ' + str.tostring(ads_overlap, '#.00')
                        row := f_panel_put_row(vcd_panel, row, 'Rot/OVL', rot_ovl_txt, color.new(color.white, 0), key_bg, val_bg)
                if ctx_panel_on
                    string cvd_txt = f_fmt_k(ctx_cvd)
                    string delta_txt = f_fmt_k(ctx_cvd_delta)
                    row := f_panel_put_row(vcd_panel, row, 'CVD(Sess)', cvd_txt, color.new(color.white, 0), key_bg, val_bg)
                    row := f_panel_put_row(vcd_panel, row, 'Δ', delta_txt, color.new(color.white, 0), key_bg, val_bg)
                    if ctx_extras_on and not na(ctx_oi_delta)
                        row := f_panel_put_row(vcd_panel, row, 'OIΔ', f_fmt_k(ctx_oi_delta), color.new(color.white, 0), key_bg, val_bg)
                    if ctx_prev_ready
                        string prev_va_txt = 'POC ' + str.tostring(ctx_pd_poc, format.mintick) + '\nVA ' + str.tostring(ctx_pd_vah, format.mintick) + ' / ' + str.tostring(ctx_pd_val, format.mintick)
                        row := f_panel_put_row(vcd_panel, row, 'Prev VA', prev_va_txt, color.new(color.white, 0), key_bg, val_bg)
                if sig_panel_on
                    string sig_mode_txt = (range_mode == 'Visible Range' or range_mode == 'Visible Range (Right Anchored)') ? 'Fixed Lookback Bars' : range_mode
                    string sig_mode_compact = sig_mode_txt == 'Fixed Lookback Bars' ? ('Fixed ' + str.tostring(fixed_lookback)) : sig_mode_txt == 'Session Composite (N)' ? ('SessN ' + str.tostring(sess_comp_n)) : sig_mode_txt
                    int sig_bins_panel = math.min(240, f_sig_auto_bins(sig_quality, render_rows_in))
                    int sig_chart_tf_sec = int(timeframe.in_seconds(timeframe.period))
                    int sig_rc_panel = f_sig_auto_recompute(sig_quality, sig_chart_tf_sec, bars_in_range)
                    string sig_txt = sig_mode_compact + ' | VA VP\n' + 'bins ' + str.tostring(sig_bins_panel) + ' | rc ' + str.tostring(sig_rc_panel)
                    row := f_panel_put_row(vcd_panel, row, 'Sig', sig_txt, color.new(color.white, 0), key_bg, val_bg)
                if avwap_panel_on
                    string av_side = close >= av_vwap ? 'Above' : 'Below'
                    row := f_panel_put_row(vcd_panel, row, 'AVWAP', str.tostring(av_vwap, format.mintick) + ' | ' + av_side, color.new(color.white, 0), key_bg, val_bg)
                if of_enable
                    row := f_panel_put_row(vcd_panel, row, 'OF', ads_panel_of_status, color.new(color.white, 0), key_bg, val_bg)
                    string of_cov_txt = 'Cov ' + of_native_coverage + '\nFB bars ' + str.tostring(of_fallback_bars_last)
                    row := f_panel_put_row(vcd_panel, row, 'OF Info', of_cov_txt, color.new(color.white, 0), key_bg, val_bg)
                    string of_reason_txt = f_panel_of_why_txt(of_status_reason)
                    row := f_panel_put_row(vcd_panel, row, 'OF Why', of_reason_txt, color.new(color.white, 0), key_bg, val_bg)
            int ctx_line_x0 = not na(sess_start0_series) ? sess_start0_series : bar_index
            int ctx_line_x1 = px1
            bool ctx_has_ib = ctx_pack_on and not na(ctx_ib_start_ts) and not na(ctx_ib_hi) and not na(ctx_ib_lo)
            int ctx_ib_line_n = ctx_has_ib ? 2 : 0
            f_ensure_line_pool(ctx_ib_lines, ctx_ib_line_n)
            if ctx_ib_line_n == 2
                line ctx_ibh = array.get(ctx_ib_lines, 0)
                line ctx_ibl = array.get(ctx_ib_lines, 1)
                line.set_xy1(ctx_ibh, ctx_line_x0, ctx_ib_hi)
                line.set_xy2(ctx_ibh, ctx_line_x1, ctx_ib_hi)
                line.set_color(ctx_ibh, color.new(line_color, 10))
                line.set_style(ctx_ibh, line.style_solid)
                line.set_width(ctx_ibh, 1)
                line.set_extend(ctx_ibh, extend.none)
                line.set_xy1(ctx_ibl, ctx_line_x0, ctx_ib_lo)
                line.set_xy2(ctx_ibl, ctx_line_x1, ctx_ib_lo)
                line.set_color(ctx_ibl, color.new(line_color, 10))
                line.set_style(ctx_ibl, line.style_solid)
                line.set_width(ctx_ibl, 1)
                line.set_extend(ctx_ibl, extend.none)
            bool ctx_has_prev = ctx_pack_on and ctx_prev_valid and not na(ctx_pd_poc) and not na(ctx_pd_vah) and not na(ctx_pd_val)
            int ctx_pd_line_n = ctx_has_prev ? 3 : 0
            f_ensure_line_pool(ctx_pd_lines, ctx_pd_line_n)
            if ctx_pd_line_n == 3
                line ctx_poc_ln = array.get(ctx_pd_lines, 0)
                line ctx_vah_ln = array.get(ctx_pd_lines, 1)
                line ctx_val_ln = array.get(ctx_pd_lines, 2)
                line.set_xy1(ctx_poc_ln, ctx_line_x0, ctx_pd_poc)
                line.set_xy2(ctx_poc_ln, ctx_line_x1, ctx_pd_poc)
                line.set_color(ctx_poc_ln, color.new(color.aqua, 10))
                line.set_style(ctx_poc_ln, line.style_dotted)
                line.set_width(ctx_poc_ln, 1)
                line.set_extend(ctx_poc_ln, extend.none)
                line.set_xy1(ctx_vah_ln, ctx_line_x0, ctx_pd_vah)
                line.set_xy2(ctx_vah_ln, ctx_line_x1, ctx_pd_vah)
                line.set_color(ctx_vah_ln, color.new(color.aqua, 35))
                line.set_style(ctx_vah_ln, line.style_dashed)
                line.set_width(ctx_vah_ln, 1)
                line.set_extend(ctx_vah_ln, extend.none)
                line.set_xy1(ctx_val_ln, ctx_line_x0, ctx_pd_val)
                line.set_xy2(ctx_val_ln, ctx_line_x1, ctx_pd_val)
                line.set_color(ctx_val_ln, color.new(color.aqua, 35))
                line.set_style(ctx_val_ln, line.style_dashed)
                line.set_width(ctx_val_ln, 1)
                line.set_extend(ctx_val_ln, extend.none)
            float info_warn_y = pmax + (syminfo.mintick * 5.0)
            bool of_classic_no_render = of_enable and of_profile_type == 'Total Volume (classic)'
            bool intrabar_budget_capped = calc_needed_ltf_unclamped > 60000 or calc_needed_ltf > 180000
            bool show_warn = (intrabar_on and fallback_used) or range_fallback_used or intrabar_budget_capped or intrabar_disabled_non_anchored or of_enable or npoc_enable or rows_capped or of_classic_no_render
            if show_warn
                string msg = ''
                if of_enable
                    if of_source_mode_active == 'Native'
                        msg := 'Orderflow source: Native. ' + of_status_text
                    else if of_source_mode_active == 'Native unavail'
                        msg := 'Orderflow source: Native unavailable. ' + of_status_text
                    else
                        msg := 'Orderflow source: Proxy (Up/Down-Volume-Modell, kein echtes Bid/Ask-Aggressor-Tape). ' + of_status_text
                    if of_classic_no_render
                        msg := msg + ' | Orderflow aktiv, aber Profile Type = Total Volume (classic) → kein OF Rendering. Wähle Bid/Ask oder Delta.'
                    if strict_intrabar and not delta_available
                        msg := msg + ' | Delta disabled: no intrabar data / invalid LTF.'
                    else if fallback_used
                        msg := msg + ' | Delta fallback: chart TF proxy (less accurate).'
                    if of_status_reason != ''
                        msg := msg + ' | ' + of_status_reason
                if range_fallback_used
                    msg := msg != '' ? msg + ' | ' : ''
                    if range_reason_code == 6
                        msg := msg + 'Session start not found in loaded history; using capped session window'
                    else
                        msg := msg + 'Range fallback: ' + range_reason
                if intrabar_on and fallback_used
                    int total_bars = right_idx - left_idx + 1
                    string imsg = 'Intrabar fallback ' + str.tostring(fallback_bars) + '/' + str.tostring(total_bars) + ' bars'
                    if fallback_reason != ''
                        imsg := imsg + ' (' + fallback_reason + ')'
                    imsg := imsg + ' | LTF ' + ltf_resolved
                    if intrabar_capped
                        imsg := imsg + ' | budget capped'
                    msg := msg != '' ? msg + ' | ' + imsg : imsg
                if npoc_enable
                    string nmsg = 'NPOC = streaming POC of closed Day/Session windows (no old-window scan).'
                    msg := msg != '' ? msg + ' | ' + nmsg : nmsg
                if intrabar_budget_capped
                    msg := msg != '' ? msg + ' | ' : ''
                    msg := msg + 'Intrabar LTF budget capped: ' + str.tostring(calc_needed_ltf) + '→' + str.tostring(calc_budget_ltf)
                if intrabar_disabled_non_anchored
                    msg := msg != '' ? msg + ' | ' : ''
                    msg := msg + 'Intrabar disabled for non-anchored range'
                if of_strip_forced_to_split
                    msg := msg != '' ? msg + ' | ' : ''
                    msg := msg + 'Bid/Ask mode uses Centered Split visual.'
                if rows_capped_budget
                    msg := msg != '' ? msg + ' | ' : ''
                    msg := msg + 'Render rows capped to ' + str.tostring(render_n_pre) + ' by drawing budget'
                if rows_tick_capped
                    msg := msg != '' ? msg + ' | ' : ''
                    msg := msg + 'Rows capped by tick-span: ' + str.tostring(render_n_pre) + '→' + str.tostring(render_n)
                if bars_in_range <= 2
                    msg := msg != '' ? msg + ' | ' : ''
                    msg := msg + 'Range contains only ' + str.tostring(bars_in_range) + ' bars (check Range Mode / Current Candle Only).'
                label.set_style(warn_label, label.style_label_lower_left)
                label.set_xy(warn_label, px0, info_warn_y)
                label.set_text(warn_label, msg)
                label.set_textcolor(warn_label, color.new(color.white, 0))
                label.set_color(warn_label, color.new(color.black, 88))
                label.set_size(warn_label, size.small)
            else
                f_hide_label(warn_label)
    last_right_vis := chart.right_visible_bar_time
    last_calc_left_idx := left_idx
    last_calc_right_idx := right_idx
    last_range_fallback_used := range_fallback_used
    last_cfg_hash := cfg_hash
    dirty := false
    dirty
evt_accept_up := false
evt_accept_dn := false
evt_fail_up := false
evt_fail_dn := false
evt_reentry := false
evt_new_value := false
evt_regime_change := false
evt_reversal_high := false
ads_fire_accept_up := false
ads_fire_accept_dn := false
ads_fire_fail_up := false
ads_fire_fail_dn := false
ads_fire_reentry := false
ads_fire_new_value := false
ads_fire_regime := false
ads_fire_reversal := false
if not ads_prev_toggle_init
    ads_prev_enable := ads_enable
    ads_prev_show_markers := ads_show_markers
    ads_prev_toggle_init := true
if ads_prev_enable and not ads_enable
    f_ads_clear_markers()
    ads_last_event_bar := na
    ads_out_up := 0
    ads_out_dn := 0
    ads_was_outside := false
    array.clear(ads_rot_buf)
    ads_rot_count := 0
if ads_enable and ads_prev_show_markers and not ads_show_markers
    f_ads_clear_markers()
ads_prev_enable := ads_enable
ads_prev_show_markers := ads_show_markers
int ads_range_len_last = (not na(last_calc_left_idx) and not na(last_calc_right_idx)) ? (last_calc_right_idx - last_calc_left_idx + 1) : 1
ads_range_len_last := math.max(1, ads_range_len_last)
bool ads_bar_ready = barstate.isconfirmed
bool ads_levels_ready_live = ads_enable and not na(ads_vah) and not na(ads_val) and ads_profile_w > 0
bool ads_calc_now = ads_enable and ads_levels_ready_live and ads_bar_ready
if not ads_enable
    ads_out_up := 0
    ads_out_dn := 0
    ads_was_outside := false
    ads_panel_of_status := 'Off'
    ads_panel_last_update_bar := na
else if ads_calc_now
    ads_sig_poc := ads_poc
    ads_sig_vah := ads_vah
    ads_sig_val := ads_val
    ads_sig_profile_w := ads_profile_w
    ads_sig_value_mid := (ads_sig_vah + ads_sig_val) * 0.5
    ads_sig_overlap := ads_overlap
    ads_sig_shift := ads_shift
    ads_sig_shape := ads_shape
    ads_sig_tail_low := ads_tail_low
    ads_sig_tail_high := ads_tail_high
    ads_sig_ref_poc := ads_ref_poc
    ads_sig_ref_vah := ads_ref_vah
    ads_sig_ref_val := ads_ref_val
    [ovh_b, ovl_b, shf_b, rh_b, rl_b, rvt_b, skt_b, tpt_b, drf_b, nvt_b] = f_ads_auto_thresholds(ads_strictness, ads_sig_profile_w, ads_range_len_last)
    int rot_w = math.max(50, math.min(300, int(math.round(ads_range_len_last * 0.12))))
    bool crossed = not na(ads_sig_value_mid) and ((close > ads_sig_value_mid and close[1] <= ads_sig_value_mid) or (close < ads_sig_value_mid and close[1] >= ads_sig_value_mid))
    int cross_i = crossed ? 1 : 0
    array.push(ads_rot_buf, cross_i)
    ads_rot_count += cross_i
    if array.size(ads_rot_buf) > rot_w
        int old = array.shift(ads_rot_buf)
        ads_rot_count -= old
    ads_rotation := int(f_ads_clamp(math.round(100.0 * f_ads_safe_div(ads_rot_count, math.max(rot_w / 20.0, 1.0), 0.0)), 0.0, 100.0))
    bool outside_up = close > ads_sig_vah
    bool outside_dn = close < ads_sig_val
    bool in_va = close <= ads_sig_vah and close >= ads_sig_val
    int prev_up = ads_out_up
    int prev_dn = ads_out_dn
    ads_out_up := outside_up ? ads_out_up + 1 : 0
    ads_out_dn := outside_dn ? ads_out_dn + 1 : 0
    evt_accept_up := ads_out_up == ads_accept_confirm
    evt_accept_dn := ads_out_dn == ads_accept_confirm
    evt_fail_up := ads_accept_confirm == 1 ? (prev_up == 1 and in_va) : (prev_up > 0 and prev_up < ads_accept_confirm and in_va)
    evt_fail_dn := ads_accept_confirm == 1 ? (prev_dn == 1 and in_va) : (prev_dn > 0 and prev_dn < ads_accept_confirm and in_va)
    evt_reentry := ads_was_outside and in_va and not evt_fail_up and not evt_fail_dn
    ads_was_outside := outside_up or outside_dn or evt_accept_up or evt_accept_dn
    float shift_comp = f_ads_clamp(nz(ads_sig_shift, 0.0), -1.0, 1.0)
    float overlap_comp = na(ads_sig_overlap) ? 0.0 : (2.0 * (1.0 - ads_sig_overlap) - 1.0)
    float loc_comp = f_ads_clamp(f_ads_safe_div(close - ads_sig_poc, ads_sig_profile_w, 0.0), -1.0, 1.0)
    float accept_comp = evt_accept_up ? 1.0 : evt_accept_dn ? -1.0 : 0.0
    ads_bias := int(f_ads_clamp(math.round(100.0 * (0.40 * shift_comp + 0.25 * overlap_comp + 0.20 * loc_comp + 0.15 * accept_comp)), -100.0, 100.0))
    float dist_v = 0.0
    if close > ads_sig_vah
        dist_v := f_ads_safe_div(close - ads_sig_vah, drf_b, 0.0)
    else if close < ads_sig_val
        dist_v := f_ads_safe_div(ads_sig_val - close, drf_b, 0.0)
    float A = f_ads_clamp01(dist_v)
    float rng = math.max(high - low, syminfo.mintick)
    float wick_up = high - math.max(open, close)
    float wick_dn = math.min(open, close) - low
    float B = outside_up ? f_ads_clamp01(wick_up / rng) : outside_dn ? f_ads_clamp01(wick_dn / rng) : 0.0
    bool tail_high_thin = not na(ads_sig_tail_high) and ads_sig_tail_high < 0.08
    bool tail_low_thin = not na(ads_sig_tail_low) and ads_sig_tail_low < 0.08
    float C = outside_up and tail_high_thin ? 1.0 : outside_dn and tail_low_thin ? 1.0 : 0.0
    int D = (evt_fail_up or evt_fail_dn) ? 20 : 0
    ads_reversal_risk := int(f_ads_clamp(math.round(100.0 * (0.40 * A + 0.25 * B + 0.25 * C) + D), 0.0, 100.0))
    string prev_state = ads_state
    if evt_accept_up
        ads_state := 'BREAKOUT_UP'
    else if evt_accept_dn
        ads_state := 'BREAKOUT_DOWN'
    else if (evt_fail_up or evt_fail_dn) and ads_reversal_risk >= rvt_b
        ads_state := 'REVERSAL_RISK'
    else if not na(ads_sig_overlap) and ads_sig_overlap <= ovl_b and math.abs(nz(ads_sig_shift, 0.0)) >= shf_b and ads_rotation <= rl_b
        ads_state := ads_bias >= 0 ? 'TREND_UP' : 'TREND_DOWN'
    else if not na(ads_sig_overlap) and ads_sig_overlap >= ovh_b and ads_rotation >= rh_b and math.abs(nz(ads_sig_shift, 0.0)) < shf_b
        ads_state := 'BALANCED'
    else
        ads_state := ads_bias > 35 ? 'BULL_BIAS' : ads_bias < -35 ? 'BEAR_BIAS' : 'NEUTRAL'
    evt_regime_change := prev_state != 'N/A' and ads_state != prev_state
    nv_ratio_series := not na(ads_sig_ref_poc) ? f_ads_safe_div(math.abs(ads_sig_poc - ads_sig_ref_poc), ads_sig_profile_w, 0.0) : 0.0
    bool ref_changed = not na(ads_sig_ref_poc) and ads_sig_ref_poc != nz(ads_sig_ref_poc[1], ads_sig_ref_poc)
    evt_new_value := not ref_changed and (nv_ratio_series >= nvt_b) and (nz(nv_ratio_series[1], 0.0) < nvt_b)
    evt_reversal_high := ads_reversal_risk >= rvt_b and nz(ads_reversal_risk[1], 0) < rvt_b
    ads_fire_accept_up := evt_accept_up
    ads_fire_accept_dn := evt_accept_dn
    ads_fire_fail_up := evt_fail_up
    ads_fire_fail_dn := evt_fail_dn
    ads_fire_reentry := evt_reentry
    ads_fire_new_value := evt_new_value
    ads_fire_regime := evt_regime_change
    ads_fire_reversal := evt_reversal_high
    bool event_fired = evt_accept_up or evt_accept_dn or evt_fail_up or evt_fail_dn or evt_reentry or evt_new_value
    bool allow_bar = na(ads_last_event_bar) or bar_index != ads_last_event_bar
    if event_fired and allow_bar and ads_show_markers
        ads_last_event_bar := bar_index
        if evt_accept_up
            f_ads_emit_marker('A+', high, color.new(color.green, 10), math.max((high - low) * 0.35, syminfo.mintick * 3.0))
        else if evt_accept_dn
            f_ads_emit_marker('A-', low, color.new(color.red, 10), -math.max((high - low) * 0.35, syminfo.mintick * 3.0))
        else if evt_fail_up
            f_ads_emit_marker('F+', high, color.new(color.orange, 10), math.max((high - low) * 0.35, syminfo.mintick * 3.0))
        else if evt_fail_dn
            f_ads_emit_marker('F-', low, color.new(color.orange, 10), -math.max((high - low) * 0.35, syminfo.mintick * 3.0))
        else if evt_reentry
            f_ads_emit_marker('R', close, color.new(color.blue, 10), math.max((high - low) * 0.25, syminfo.mintick * 2.0))
        else if evt_new_value
            f_ads_emit_marker('NV', close, color.new(color.purple, 10), math.max((high - low) * 0.25, syminfo.mintick * 2.0))
    if na(ads_panel_last_update_bar) or ads_panel_last_update_bar != bar_index
        ads_panel_last_update_bar := bar_index
        ads_panel_of_status := of_enable ? of_status_text : 'Off'
else if ads_enable and ads_bar_ready and not ads_levels_ready_live
    if na(ads_panel_last_update_bar) or ads_panel_last_update_bar != bar_index
        ads_panel_last_update_bar := bar_index
        ads_panel_of_status := of_enable ? of_status_text : 'Off'
string sig_range_mode_eff = (range_mode == 'Visible Range' or range_mode == 'Visible Range (Right Anchored)') ? 'Fixed Lookback Bars' : range_mode
int sig_lookback_raw = fixed_lookback
int sig_lookback_eff = math.min(5000, sig_lookback_raw)
int sig_comp_eff = sess_comp_n
float sig_va_pct_eff = va_percent / 100.0
int sig_bins_eff = math.min(240, f_sig_auto_bins(sig_quality, render_rows_in))
bool sig_on = sig_enable
bool bg_sig_ready = sig_on and bg_sig_select != 'None'
bool sig_bar_ready = barstate.isconfirmed
sig_evt_accept_up := false
sig_evt_accept_dn := false
sig_evt_fail_up := false
sig_evt_fail_dn := false
sig_evt_reentry := false
sig_evt_new_value := false
sig_evt_regime := false
sig_evt_reversal := false
[sig_left_pre, sig_right_pre] = f_sig_resolve_range(sig_range_mode_eff, sig_lookback_eff, sig_comp_eff)
int sig_len_pre = math.max(1, sig_right_pre - sig_left_pre + 1)
int sig_hist_window_base = sig_quality == 'Fast (Low CPU)' ? 300 : sig_quality == 'High (More detail)' ? 1200 : 700
int sig_hist_window = sig_hist_window_base * 10
sig_hist_window := math.min(sig_len_pre, sig_hist_window)
bool sig_runtime_bar = barstate.isrealtime or barstate.islastconfirmedhistory or (last_bar_index - bar_index <= sig_hist_window)
float pmin_s_pre = ta.lowest(low, sig_len_pre)
float pmax_s_pre = ta.highest(high, sig_len_pre)
bool sig_first_init = na(sig_left_series) or na(sig_right_series) or na(sig_poc) or na(sig_vah) or na(sig_val)
bool heavy_forced = sig_first_init or sig_left_pre != sig_left_series or sig_right_pre != sig_right_series
int chart_tf_sec = int(timeframe.in_seconds(timeframe.period))
int auto_recompute = f_sig_auto_recompute(sig_quality, chart_tf_sec, sig_len_pre)
bool sig_should_calc_heavy = sig_on and sig_bar_ready and sig_runtime_bar and (auto_recompute <= 1 or bar_index % auto_recompute == 0 or heavy_forced)
if sig_should_calc_heavy
    int sig_left = sig_left_pre
    int sig_right = sig_right_pre
    float pmin_s = pmin_s_pre
    float pmax_s = pmax_s_pre
    sig_left_series := sig_left
    sig_right_series := sig_right
    float p_rng_s = math.max(pmax_s - pmin_s, syminfo.mintick)
    float step_s = p_rng_s / sig_bins_eff
    sig_pmin := pmin_s
    sig_step := step_s
    f_ensure_float_array(sig_bins, sig_bins_eff)
    for i = 0 to sig_bins_eff - 1 by 1
        array.set(sig_bins, i, 0.0)
    for bi = sig_left to sig_right by 1
        int off = bar_index - bi
        float v = math.max(volume[off], 0.0)
        if v <= 0
            continue
        float lo = low[off]
        float hi = high[off]
        int sb = f_sig_clampi(int(math.floor((lo - pmin_s) / step_s)), 0, sig_bins_eff - 1)
        int eb = f_sig_clampi(int(math.floor((hi - pmin_s) / step_s)), 0, sig_bins_eff - 1)
        int touched = math.max(1, eb - sb + 1)
        float add = v / touched
        for b = sb to eb by 1
            array.set(sig_bins, b, array.get(sig_bins, b) + add)
    [sig_poc_n, sig_vah_n, sig_val_n, sig_pw_n, sig_maxv] = f_sig_profile_levels(sig_bins, pmin_s, step_s, sig_va_pct_eff)
    sig_poc := sig_poc_n
    sig_vah := sig_vah_n
    sig_val := sig_val_n
    sig_value_mid := (sig_vah + sig_val) * 0.5
    sig_profile_w := sig_pw_n
    array.clear(sig_lvg_start)
    array.clear(sig_lvg_end)
    if sig_bins_eff > 0 and sig_maxv > 0
        array<float> lvg_cp_s = na
        float lvg_med_s = na
        bool need_sorted_s = lvg_threshold_mode == 'Quantile' or lvg_auto_scale
        if need_sorted_s
            lvg_cp_s := f_sorted_copy(sig_bins, sig_bins_eff)
            lvg_med_s := f_quantile_from_sorted(lvg_cp_s, sig_bins_eff, 0.5)
        float lvg_eff_s = lvg_threshold_value
        if lvg_auto_scale
            lvg_eff_s := lvg_threshold_value * f_lvg_tf_scale() * f_lvg_dist_scale(sig_maxv, lvg_med_s)
            lvg_eff_s
        float eff_clamped_s = f_clamp(lvg_eff_s, 0.5, 50.0)
        float lvg_thr_s = 0.0
        if lvg_threshold_mode == 'Quantile'
            float q_s = math.min(0.5, eff_clamped_s * 0.01)
            if na(lvg_cp_s)
                lvg_cp_s := f_sorted_copy(sig_bins, sig_bins_eff)
            lvg_thr_s := f_quantile_from_sorted(lvg_cp_s, sig_bins_eff, q_s)
        else
            lvg_thr_s := sig_maxv * eff_clamped_s * 0.01
        int min_h_s = math.max(1, lvg_min_height_bins)
        int max_z_s = math.max(1, math.min(lvg_max_zones, 12))
        int s_s = -1
        for i = 0 to sig_bins_eff - 1 by 1
            float v_s = array.get(sig_bins, i)
            bool thin_s = v_s <= lvg_thr_s
            if thin_s and s_s == -1
                s_s := i
                s_s
            if (not thin_s or i == sig_bins_eff - 1) and s_s != -1
                int e_s = thin_s and i == sig_bins_eff - 1 ? i : i - 1
                if e_s - s_s + 1 >= min_h_s
                    array.push(sig_lvg_start, s_s)
                    array.push(sig_lvg_end, e_s)
                s_s := -1
                s_s
        int zone_count_s = array.size(sig_lvg_start)
        if zone_count_s > max_z_s
            array<float> lvg_scores_s = array.new_float(zone_count_s, 0.0)
            array<bool> lvg_picked_s = array.new_bool(zone_count_s, false)
            for i = 0 to zone_count_s - 1 by 1
                int zs_i = array.get(sig_lvg_start, i)
                int ze_i = array.get(sig_lvg_end, i)
                int height_i = ze_i - zs_i + 1
                float sum_i = 0.0
                for k = zs_i to ze_i by 1
                    sum_i := sum_i + array.get(sig_bins, k)
                float avg_i = height_i > 0 ? sum_i / height_i : sum_i
                array.set(lvg_scores_s, i, avg_i)
            array<int> sel_start_s = array.new_int(0)
            array<int> sel_end_s = array.new_int(0)
            for _ = 0 to max_z_s - 1 by 1
                int best_idx = -1
                float best_score = 10e10
                for i = 0 to zone_count_s - 1 by 1
                    if not array.get(lvg_picked_s, i)
                        float sc = array.get(lvg_scores_s, i)
                        if best_idx == -1 or sc < best_score
                            best_idx := i
                            best_score := sc
                if best_idx != -1
                    array.set(lvg_picked_s, best_idx, true)
                    array.push(sel_start_s, array.get(sig_lvg_start, best_idx))
                    array.push(sel_end_s, array.get(sig_lvg_end, best_idx))
            array.clear(sig_lvg_start)
            array.clear(sig_lvg_end)
            for i = 0 to array.size(sel_start_s) - 1 by 1
                array.push(sig_lvg_start, array.get(sel_start_s, i))
                array.push(sig_lvg_end, array.get(sel_end_s, i))
bool sig_levels_ready = sig_on and sig_bar_ready and not na(sig_poc) and not na(sig_vah) and not na(sig_val) and not na(sig_pmin) and not na(sig_step)
bool sig_should_calc_light = sig_levels_ready and sig_runtime_bar
if sig_should_calc_light
    sig_in_lvg_zone := f_sig_lvg_hit(sig_lvg_start, sig_lvg_end, sig_pmin, sig_step)
    bool sig_session_mode = sig_range_mode_eff == 'Session (Current)' or sig_range_mode_eff == 'Session (Prev+Current)' or sig_range_mode_eff == 'Session Composite (N)'
    bool ref_boundary = sig_session_mode and sig_left_pre != nz(sig_left_pre[1], sig_left_pre)
    int auto_ref = f_sig_auto_ref_interval(sig_quality, sig_len_pre)
    if na(sig_ref_poc)
        sig_ref_poc := sig_poc
        sig_ref_vah := sig_vah
        sig_ref_val := sig_val
        sig_ref_bar := bar_index
    else if ref_boundary
        sig_ref_poc := nz(sig_poc[1], sig_poc)
        sig_ref_vah := nz(sig_vah[1], sig_vah)
        sig_ref_val := nz(sig_val[1], sig_val)
        sig_ref_bar := bar_index
    else if bar_index - nz(sig_ref_bar, bar_index) >= auto_ref
        sig_ref_poc := sig_poc
        sig_ref_vah := sig_vah
        sig_ref_val := sig_val
        sig_ref_bar := bar_index
    sig_overlap := f_ads_overlap(sig_vah, sig_val, sig_ref_vah, sig_ref_val)
    sig_shift := f_ads_shift(sig_poc, sig_ref_poc, sig_profile_w)
    int rot_w_sig = math.max(50, math.min(300, int(math.round(sig_len_pre * 0.12))))
    bool crossed_mid_sig = not na(sig_value_mid) and ((close > sig_value_mid and close[1] <= sig_value_mid) or (close < sig_value_mid and close[1] >= sig_value_mid))
    int c_sig = crossed_mid_sig ? 1 : 0
    array.push(sig_rot_buf, c_sig)
    sig_rot_count += c_sig
    if array.size(sig_rot_buf) > rot_w_sig
        sig_rot_count -= array.shift(sig_rot_buf)
    sig_rotation := int(f_ads_clamp(math.round(100.0 * f_ads_safe_div(sig_rot_count, math.max(rot_w_sig / 20.0, 1.0), 0.0)), 0.0, 100.0))
    bool out_up_s = close > sig_vah
    bool out_dn_s = close < sig_val
    bool in_va_s = close <= sig_vah and close >= sig_val
    int prev_up_s = sig_out_up
    int prev_dn_s = sig_out_dn
    sig_out_up := out_up_s ? sig_out_up + 1 : 0
    sig_out_dn := out_dn_s ? sig_out_dn + 1 : 0
    sig_evt_accept_up := sig_out_up == ads_accept_confirm
    sig_evt_accept_dn := sig_out_dn == ads_accept_confirm
    sig_evt_fail_up := ads_accept_confirm == 1 ? (prev_up_s == 1 and in_va_s) : (prev_up_s > 0 and prev_up_s < ads_accept_confirm and in_va_s)
    sig_evt_fail_dn := ads_accept_confirm == 1 ? (prev_dn_s == 1 and in_va_s) : (prev_dn_s > 0 and prev_dn_s < ads_accept_confirm and in_va_s)
    sig_evt_reentry := sig_was_outside and in_va_s and not sig_evt_fail_up and not sig_evt_fail_dn
    sig_was_outside := out_up_s or out_dn_s or sig_evt_accept_up or sig_evt_accept_dn
    float shift_comp_s = f_ads_clamp(nz(sig_shift, 0.0), -1.0, 1.0)
    float overlap_comp_s = na(sig_overlap) ? 0.0 : (2.0 * (1.0 - sig_overlap) - 1.0)
    float loc_comp_s = f_ads_clamp(f_ads_safe_div(close - sig_poc, sig_profile_w, 0.0), -1.0, 1.0)
    float accept_comp_s = sig_evt_accept_up ? 1.0 : sig_evt_accept_dn ? -1.0 : 0.0
    sig_bias := int(f_ads_clamp(math.round(100.0 * (0.40 * shift_comp_s + 0.25 * overlap_comp_s + 0.20 * loc_comp_s + 0.15 * accept_comp_s)), -100.0, 100.0))
    float rv = math.min(100.0, math.abs(sig_bias) * 0.5 + (sig_evt_fail_up or sig_evt_fail_dn ? 30.0 : 0.0))
    sig_reversal_risk := int(math.round(rv))
    int prev_state_sig = sig_state_enum
    sig_state_enum := sig_evt_accept_up ? 2 : sig_evt_accept_dn ? -2 : sig_reversal_risk >= 70 ? 3 : sig_bias >= 35 ? 1 : sig_bias <= -35 ? -1 : 0
    sig_evt_regime := prev_state_sig != 0 and sig_state_enum != prev_state_sig
    sig_nv_ratio := f_ads_safe_div(math.abs(sig_poc - sig_ref_poc), sig_profile_w, 0.0)
    sig_evt_new_value := sig_nv_ratio >= 0.25 and nz(sig_nv_ratio[1], 0.0) < 0.25
    sig_evt_reversal := sig_reversal_risk >= 70 and nz(sig_reversal_risk[1], 0) < 70
    sig_evt_priority := sig_evt_accept_up or sig_evt_accept_dn ? 7 : sig_evt_fail_up or sig_evt_fail_dn ? 6 : sig_evt_reentry ? 5 : sig_evt_new_value ? 4 : sig_evt_regime ? 3 : sig_evt_reversal ? 2 : 0
    if bg_sig_ready and bg_sig_select == 'Signal Events Pulse' and sig_evt_priority > 0
        // Hold includes current event bar + N following bars.
        bg_pulse_left := bg_event_hold_bars + 1
        bg_pulse_prio := sig_evt_priority
        bg_pulse_col := f_evt_color(sig_evt_priority)
else
    sig_evt_priority := 0
if bg_sig_ready and bg_sig_select == 'Signal Events Pulse' and sig_bar_ready
    bool pulse_was_refreshed = sig_should_calc_light and sig_evt_priority > 0
    if not pulse_was_refreshed
        bg_pulse_left := math.max(0, bg_pulse_left - 1)
        if bg_pulse_left == 0
            bg_pulse_prio := 0
            bg_pulse_col := na
else
    bg_pulse_left := 0
    bg_pulse_prio := 0
    bg_pulse_col := na
color bias_col = sig_bias > 0 ? color.rgb(0, 175, 0) : sig_bias < 0 ? color.rgb(190, 0, 0) : na
color risk_col = sig_reversal_risk >= 70 ? color.rgb(255, 120, 0) : sig_reversal_risk >= 40 ? color.rgb(220, 170, 0) : na
color regime_col = sig_state_enum == 2 ? color.green : sig_state_enum == -2 ? color.red : sig_state_enum == 3 ? color.orange : sig_state_enum == 1 ? color.rgb(30, 130, 30) : sig_state_enum == -1 ? color.rgb(150, 40, 40) : na
color va_col = close > sig_vah ? color.green : close < sig_val ? color.red : na
color bg_sig_col = na
if bg_sig_ready and sig_bar_ready
    bg_sig_col :=
         bg_sig_select == 'Signal Regime (Discrete)' ? regime_col :
         bg_sig_select == 'Signal Bias' ? bias_col :
         bg_sig_select == 'Signal Reversal Risk' ? risk_col :
         bg_sig_select == 'Signal VA Location (Above/In/Below)' ? va_col :
         bg_sig_select == 'Signal LVG Zone' ? (sig_in_lvg_zone ? color.rgb(210, 160, 60) : na) :
         bg_sig_select == 'Signal Events Pulse' ? (bg_pulse_left > 0 ? bg_pulse_col : na) : na
bool sig_marker_gate = sig_show_markers and sig_on and sig_bar_ready
plotshape(sig_marker_gate and sig_evt_accept_up, title = 'Sig A+', style = shape.triangleup, location = location.abovebar, color = color.new(color.green, 5), text = 'A+', textcolor = color.white, size = size.tiny)
plotshape(sig_marker_gate and sig_evt_accept_dn, title = 'Sig A-', style = shape.triangledown, location = location.belowbar, color = color.new(color.red, 5), text = 'A-', textcolor = color.white, size = size.tiny)
plotshape(sig_marker_gate and sig_evt_fail_up, title = 'Sig F+', style = shape.circle, location = location.abovebar, color = color.new(color.orange, 0), text = 'F+', textcolor = color.white, size = size.tiny)
plotshape(sig_marker_gate and sig_evt_fail_dn, title = 'Sig F-', style = shape.circle, location = location.belowbar, color = color.new(color.orange, 0), text = 'F-', textcolor = color.white, size = size.tiny)
plotshape(sig_marker_gate and sig_evt_reentry, title = 'Sig R', style = shape.diamond, location = location.belowbar, color = color.new(color.blue, 0), text = 'R', textcolor = color.white, size = size.tiny)
plotshape(sig_marker_gate and sig_evt_new_value, title = 'Sig NV', style = shape.square, location = location.abovebar, color = color.new(color.purple, 0), text = 'NV', textcolor = color.white, size = size.tiny)
plotshape(sig_marker_gate and sig_evt_regime, title = 'Sig Regime', style = shape.square, location = location.top, color = color.new(color.yellow, 0), text = 'RG', textcolor = color.black, size = size.tiny)
plotshape(sig_marker_gate and sig_evt_reversal, title = 'Sig RevRisk', style = shape.square, location = location.top, color = color.new(color.orange, 0), text = 'RR', textcolor = color.white, size = size.tiny)
plot(sig_expose_series ? sig_state_enum : na, title = 'Sig State Enum', color = na, display = display.data_window)
plot(sig_expose_series ? sig_bias : na, title = 'Sig Bias', color = na, display = display.data_window)
plot(sig_expose_series ? sig_reversal_risk : na, title = 'Sig Reversal Risk', color = na, display = display.data_window)
plot(sig_expose_series ? sig_evt_priority : na, title = 'Sig Event Priority', color = na, display = display.data_window)
plot(sig_expose_series ? sig_nv_ratio : na, title = 'Sig NV Ratio', color = na, display = display.data_window)
bool ads_alert_accept_on = ads_enable and ads_alert_accept
bool ads_alert_fail_on = ads_enable and ads_alert_fail
bool ads_alert_reentry_on = ads_enable and ads_alert_reentry
bool ads_alert_new_value_on = ads_enable and ads_alert_new_value
bool ads_alert_regime_on = ads_enable and ads_alert_regime
bool ads_alert_reversal_on = ads_enable and ads_alert_reversal
alertcondition(ads_alert_accept_on and ads_fire_accept_up and barstate.isconfirmed, 'ADS: VA Break & Accept Up', 'ADS Accept Up {{ticker}}')
alertcondition(ads_alert_accept_on and ads_fire_accept_dn and barstate.isconfirmed, 'ADS: VA Break & Accept Down', 'ADS Accept Down {{ticker}}')
alertcondition(ads_alert_fail_on and ads_fire_fail_up and barstate.isconfirmed, 'ADS: VA Break & Fail Up', 'ADS Fail Up {{ticker}}')
alertcondition(ads_alert_fail_on and ads_fire_fail_dn and barstate.isconfirmed, 'ADS: VA Break & Fail Down', 'ADS Fail Down {{ticker}}')
alertcondition(ads_alert_reentry_on and ads_fire_reentry and barstate.isconfirmed, 'ADS: Re-Entry Into Value', 'ADS Reentry {{ticker}}')
alertcondition(ads_alert_new_value_on and ads_fire_new_value and barstate.isconfirmed, 'ADS: New Value Established', 'ADS New Value {{ticker}}')
alertcondition(ads_alert_regime_on and ads_fire_regime and barstate.isconfirmed, 'ADS: Regime Change', 'ADS Regime Change {{ticker}}')
alertcondition(ads_alert_reversal_on and ads_fire_reversal and barstate.isconfirmed, 'ADS: Reversal Risk High', 'ADS Reversal Risk High {{ticker}}')
var line[] sess_lines = array.new_line()
f_apply_restriction(bool in_raw, bool is_start, bool restrict_on, int restrict_min, int start_t_state) =>
    int st = start_t_state
    if is_start
        st := time
    bool in_eff = in_raw
    if restrict_on and in_raw and not na(st)
        int ms_limit = restrict_min * 60 * 1000
        if (time - st) >= ms_limit
            in_eff := false
    [in_eff, st]
bool show_sess_on_tf = timeframe.isintraday and timeframe.multiplier <= 60
var float h_lon = na
var float l_lon = na
var int st_lon = na
var float h_ny = na
var float l_ny = na
var int st_ny = na
var float h_tok = na
var float l_tok = na
var int st_tok = na
var float h_syd = na
var float l_syd = na
var int st_syd = na
bool lon_raw = london_show and show_sess_on_tf and ts_lon_in_base_series
bool ny_raw  = ny_show and show_sess_on_tf and ts_ny_in_base_series
bool tok_raw = tokyo_show and show_sess_on_tf and ts_tok_in_base_series
bool syd_raw = sydney_show and show_sess_on_tf and ts_syd_in_base_series
bool lon_start = lon_raw and not lon_raw[1]
bool ny_start  = ny_raw and not ny_raw[1]
bool tok_start = tok_raw and not tok_raw[1]
bool syd_start = syd_raw and not syd_raw[1]
bool lon_active = false
bool ny_active  = false
bool tok_active = false
bool syd_active = false
[lon_active_tmp, st_lon_tmp] = f_apply_restriction(lon_raw, lon_start, use_sess_rest, sess_rest_time, st_lon)
[ny_active_tmp,  st_ny_tmp]  = f_apply_restriction(ny_raw,  ny_start,  use_sess_rest, sess_rest_time, st_ny)
[tok_active_tmp, st_tok_tmp] = f_apply_restriction(tok_raw, tok_start, use_sess_rest, sess_rest_time, st_tok)
[syd_active_tmp, st_syd_tmp] = f_apply_restriction(syd_raw, syd_start, use_sess_rest, sess_rest_time, st_syd)
lon_active := lon_active_tmp
ny_active  := ny_active_tmp
tok_active := tok_active_tmp
syd_active := syd_active_tmp
st_lon := st_lon_tmp
st_ny  := st_ny_tmp
st_tok := st_tok_tmp
st_syd := st_syd_tmp
if sess_style == "Vertical Line"
    if lon_start
        line new_l = line.new(x1 = bar_index, y1 = low, x2 = bar_index, y2 = high, extend = extend.both, color = color.new(london_col, 70), style = line.style_solid, width = 1)
        array.push(sess_lines, new_l)
        if array.size(sess_lines) > sess_line_limit
            line.delete(array.shift(sess_lines))
    if ny_start
        line new_l = line.new(x1 = bar_index, y1 = low, x2 = bar_index, y2 = high, extend = extend.both, color = color.new(ny_col, 70), style = line.style_solid, width = 1)
        array.push(sess_lines, new_l)
        if array.size(sess_lines) > sess_line_limit
            line.delete(array.shift(sess_lines))
    if tok_start
        line new_l = line.new(x1 = bar_index, y1 = low, x2 = bar_index, y2 = high, extend = extend.both, color = color.new(tokyo_col, 70), style = line.style_solid, width = 1)
        array.push(sess_lines, new_l)
        if array.size(sess_lines) > sess_line_limit
            line.delete(array.shift(sess_lines))
    if syd_start
        line new_l = line.new(x1 = bar_index, y1 = low, x2 = bar_index, y2 = high, extend = extend.both, color = color.new(sydney_col, 70), style = line.style_solid, width = 1)
        array.push(sess_lines, new_l)
        if array.size(sess_lines) > sess_line_limit
            line.delete(array.shift(sess_lines))
if sess_style == "Box"
    if lon_active
        if lon_start
            h_lon := high
            l_lon := low
            b_lon := box.new(left = bar_index, top = h_lon, right = bar_index, bottom = l_lon, border_color = london_col, bgcolor = london_col)
            array.push(sess_boxes, b_lon)
            if array.size(sess_boxes) + f_count_active_session_boxes() > sess_box_cap_runtime and array.size(sess_boxes) > 0
                box.delete(array.shift(sess_boxes))
        else if not na(b_lon)
            h_lon := math.max(h_lon, high)
            l_lon := math.min(l_lon, low)
            box.set_top(b_lon, h_lon)
            box.set_bottom(b_lon, l_lon)
            box.set_right(b_lon, bar_index + 1)
    if ny_active
        if ny_start
            h_ny := high
            l_ny := low
            b_ny := box.new(left = bar_index, top = h_ny, right = bar_index, bottom = l_ny, border_color = ny_col, bgcolor = ny_col)
            array.push(sess_boxes, b_ny)
            if array.size(sess_boxes) + f_count_active_session_boxes() > sess_box_cap_runtime and array.size(sess_boxes) > 0
                box.delete(array.shift(sess_boxes))
        else if not na(b_ny)
            h_ny := math.max(h_ny, high)
            l_ny := math.min(l_ny, low)
            box.set_top(b_ny, h_ny)
            box.set_bottom(b_ny, l_ny)
            box.set_right(b_ny, bar_index + 1)
    if tok_active
        if tok_start
            h_tok := high
            l_tok := low
            b_tok := box.new(left = bar_index, top = h_tok, right = bar_index, bottom = l_tok, border_color = tokyo_col, bgcolor = tokyo_col)
            array.push(sess_boxes, b_tok)
            if array.size(sess_boxes) + f_count_active_session_boxes() > sess_box_cap_runtime and array.size(sess_boxes) > 0
                box.delete(array.shift(sess_boxes))
        else if not na(b_tok)
            h_tok := math.max(h_tok, high)
            l_tok := math.min(l_tok, low)
            box.set_top(b_tok, h_tok)
            box.set_bottom(b_tok, l_tok)
            box.set_right(b_tok, bar_index + 1)
    if syd_active
        if syd_start
            h_syd := high
            l_syd := low
            b_syd := box.new(left = bar_index, top = h_syd, right = bar_index, bottom = l_syd, border_color = sydney_col, bgcolor = sydney_col)
            array.push(sess_boxes, b_syd)
            if array.size(sess_boxes) + f_count_active_session_boxes() > sess_box_cap_runtime and array.size(sess_boxes) > 0
                box.delete(array.shift(sess_boxes))
        else if not na(b_syd)
            h_syd := math.max(h_syd, high)
            l_syd := math.min(l_syd, low)
            box.set_top(b_syd, h_syd)
            box.set_bottom(b_syd, l_syd)
            box.set_right(b_syd, bar_index + 1)
bool any_sess_configured = london_show or ny_show or tokyo_show or sydney_show
bool any_sess_active     = lon_active or ny_active or tok_active or syd_active
color bg_sess_color = na
if show_sess_on_tf
    if sess_style == "Background"
        bg_sess_color := ny_active ? ny_col : lon_active ? london_col : tok_active ? tokyo_col : syd_active ? sydney_col : na
    else if sess_style == "Inv. Background"
        if any_sess_configured
            bg_sess_color := any_sess_active ? na : color.new(color.blue, 85)
bgcolor(show_sess_on_tf ? bg_sess_color : na)
plot(ctx_plot_overlay_band ? ctx_cvd_ovl_y : na, title = 'CVD Overlay', color = color.new(color.aqua, 0), linewidth = 2, style = plot.style_linebr, display = display.all, force_overlay = true)
plot(ctx_plot_overlay_band ? ctx_band_mid : na, title = 'CVD Overlay Mid', color = color.new(color.gray, 70), linewidth = 1, style = plot.style_linebr, display = display.all, force_overlay = true)
plot(ctx_plot_overlay_band ? ctx_oi_ovl_y : na, title = 'OI Overlay', color = color.new(color.orange, 20), linewidth = 1, style = plot.style_linebr, display = display.all, force_overlay = true)
plotshape(ctx_bear_div, title = 'CVD Bear Divergence', style = shape.triangledown, location = location.abovebar, color = color.new(color.red, 0), size = size.tiny, text = 'CVD▼', offset = -CTX_DIV_P, display = display.all)
plotshape(ctx_bull_div, title = 'CVD Bull Divergence', style = shape.triangleup, location = location.belowbar, color = color.new(color.lime, 0), size = size.tiny, text = 'CVD▲', offset = -CTX_DIV_P, display = display.all)
color bg_sig_plot = bg_sig_col
bgcolor(bg_sig_ready and sig_bar_ready ? (na(bg_sig_plot) ? na : color.new(bg_sig_plot, bg_sig_transp)) : na, title = 'VCD Signal BG (Backtestable)')
````
