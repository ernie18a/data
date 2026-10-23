//+------------------------------------------------------------------+
//|                    AIBridgeUX.mqh                                |
//|                                                                  |
//|  UX / Analytics extension for Hybrid Microstructure EA V1.0      |
//|  DEPENDS ON: AIBridge.mqh (must be #included first)              |
//|                                                                  |
//|  Provides:                                                       |
//|   1) LIVE PANEL  - chart labels showing the last AI decision,    |
//|      scores, factors and adaptive thresholds                     |
//|   2) CSV LOGGING - every AI decision appended to a CSV file      |
//|      (ai_decisions.csv) for backtest / forward analysis          |
//|   3) AUTO-TUNE   - online learning: thresholds (local min score, |
//|      AI confidence) adapt from realized R-multiples of trades    |
//|                                                                  |
//|  INTEGRATION (in the EA):                                        |
//|   #include <HybridMicrostructure\AIBridgeUX.mqh>                 |
//|   OnTick()   -> AIBridge_TickMaintenance();                      |
//|   OnDeinit() -> AIBridge_Deinit();                               |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright©2023. Ritz EAneha©"
#property link      "https://www.mql5.com/en/users/ritzfalih"
#include <HybridMicrostructure\ParamUX.mqh>
#include <HybridMicrostructure\AIBridge.mqh>
#ifndef AIBRIDGEUX_MQH
#define AIBRIDGEUX_MQH
//+------------------------------------------------------------------+
//| INPUTS                                                           |
//+------------------------------------------------------------------+
input group "------------------- AI Panel & CSV Logging ---"

input bool             InpAIShowPanel        = true;
input ENUM_BASE_CORNER InpAIPanelCorner      = CORNER_LEFT_UPPER;
input int              InpAIPanelX           = 10;
input int              InpAIPanelY           = 20;
input bool             InpAILogCSV           = true;
input string           InpAICSVFile          = "ai_decisions.csv";

input group "------------------- AI Auto-Tune (online learning) ---"

input bool             InpAIAutoTune         = false;
input int              InpAIAutoTuneLookback = 30;
input double           InpAIAutoTuneMinScore = 0.45;
input double           InpAIAutoTuneMaxScore = 0.90;
input double           InpAIAutoTuneStep     = 0.02;
input double           InpAIAutoTuneTargetR  = 0.30;

//+------------------------------------------------------------------+
//| PANEL CONSTANTS                                                  |
//+------------------------------------------------------------------+
#define AI_PNL_PREFIX       "AI_PNL_"
#define AI_PNL_BGNAME       "AI_PNL_BG"

#define AI_PNL_WIDTH        292
#define AI_PNL_LINE_HEIGHT  16
#define AI_PNL_PADDING      6
#define AI_PNL_TOP_PADDING  6
#define AI_PNL_BOTTOM_PAD   8

// Z-order:
// Background = low
// Text       = high
#define AI_PNL_BG_ZORDER    0
#define AI_PNL_TEXT_ZORDER  100

//+------------------------------------------------------------------+
//| INTERNAL STATE                                                   |
//+------------------------------------------------------------------+
bool     g_ai_ux_inited     = false;
bool     g_ai_panel_created = false;
int      g_ai_panel_lines   = 0;
datetime g_ai_maint_last    = 0;
datetime g_ai_panel_last    = 0;

//+------------------------------------------------------------------+
//| POSITION TRACKING                                                |
//+------------------------------------------------------------------+
struct AIPosRecord
{
    ulong              ticket;
    datetime           open_time;
    ENUM_POSITION_TYPE type;
    double             entry;
    double             sl;
    double             volume;
    double             local_score;
    double             ai_conf;
    bool               allow;
    bool               closed;
    double             r;
};

AIPosRecord g_ai_pos[];
double      g_ai_outcomes_r[];

//+------------------------------------------------------------------+
//| PANEL BACKGROUND                                                 |
//|                                                                  |
//| IMPORTANT:                                                        |
//| OBJPROP_BACK=true guarantees that this object is behind candles  |
//| and other foreground objects.                                    |
//|                                                                  |
//| Text labels explicitly use OBJPROP_BACK=false and a higher       |
//| Z-order so they remain visible above the panel background.       |
//+------------------------------------------------------------------+
void AIBridge_PanelBackground()
{
    if(!InpAIShowPanel)
        return;

    string name = AI_PNL_BGNAME;

    // Calculate panel size
    int width  = AI_PNL_WIDTH;

    int height =
        AI_PNL_TOP_PADDING +
        (g_ai_panel_lines * AI_PNL_LINE_HEIGHT) +
        AI_PNL_BOTTOM_PAD;

    // Create background if necessary
    if(ObjectFind(0, name) < 0)
    {
        ResetLastError();

        if(!ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0))
        {
            PrintFormat("[AI-PANEL] Failed to create background. Error=%d",
                        GetLastError());
            return;
        }

        g_ai_panel_created = true;
    }

    // --------------------------------------------------------------
    // POSITION
    // --------------------------------------------------------------
    ObjectSetInteger(0, name,
                     OBJPROP_CORNER,
                     InpAIPanelCorner);

    ObjectSetInteger(0, name,
                     OBJPROP_XDISTANCE,
                     InpAIPanelX);

    ObjectSetInteger(0, name,
                     OBJPROP_YDISTANCE,
                     InpAIPanelY);

    // --------------------------------------------------------------
    // SIZE
    // --------------------------------------------------------------
    ObjectSetInteger(0, name,
                     OBJPROP_XSIZE,
                     width);

    ObjectSetInteger(0, name,
                     OBJPROP_YSIZE,
                     height);

    // --------------------------------------------------------------
    // BACKGROUND COLOR
    // --------------------------------------------------------------
    ObjectSetInteger(0, name,
                     OBJPROP_BGCOLOR,
                     C'18,22,30');

    // --------------------------------------------------------------
    // BORDER
    // --------------------------------------------------------------
    ObjectSetInteger(0, name,
                     OBJPROP_BORDER_TYPE,
                     BORDER_FLAT);

    ObjectSetInteger(0, name,
                     OBJPROP_BORDER_COLOR,
                     C'60,80,120');

    // --------------------------------------------------------------
    // CRITICAL LAYER SETTINGS
    // --------------------------------------------------------------

    // Background must stay behind text
    ObjectSetInteger(0, name,
                     OBJPROP_BACK,
                     true);

    // Lowest z-order
    ObjectSetInteger(0, name,
                     OBJPROP_ZORDER,
                     AI_PNL_BG_ZORDER);

    // User must not accidentally select/move background
    ObjectSetInteger(0, name,
                     OBJPROP_SELECTABLE,
                     false);

    ObjectSetInteger(0, name,
                     OBJPROP_SELECTED,
                     false);

    ObjectSetInteger(0, name,
                     OBJPROP_HIDDEN,
                     true);
}

//+------------------------------------------------------------------+
//| PANEL LINE                                                       |
//+------------------------------------------------------------------+
void AIBridge_PanelLine(int idx,
                        string text,
                        color clr)
{
    if(!InpAIShowPanel)
        return;

    string name = AI_PNL_PREFIX + IntegerToString(idx);

    // --------------------------------------------------------------
    // Create text object
    // --------------------------------------------------------------
    if(ObjectFind(0, name) < 0)
    {
        ResetLastError();

        if(!ObjectCreate(0,
                         name,
                         OBJ_LABEL,
                         0,
                         0,
                         0))
        {
            PrintFormat("[AI-PANEL] Failed to create label %s. Error=%d",
                        name,
                        GetLastError());
            return;
        }
    }

    // --------------------------------------------------------------
    // POSITION
    // --------------------------------------------------------------
    ObjectSetInteger(0,
                     name,
                     OBJPROP_CORNER,
                     InpAIPanelCorner);

    ObjectSetInteger(0,
                     name,
                     OBJPROP_XDISTANCE,
                     InpAIPanelX + AI_PNL_PADDING);

    ObjectSetInteger(0,
                     name,
                     OBJPROP_YDISTANCE,
                     InpAIPanelY +
                     AI_PNL_TOP_PADDING +
                     idx * AI_PNL_LINE_HEIGHT);

    // --------------------------------------------------------------
    // TEXT STYLE
    // --------------------------------------------------------------
    ObjectSetInteger(0,
                     name,
                     OBJPROP_FONTSIZE,
                     9);

    ObjectSetString(0,
                    name,
                    OBJPROP_FONT,
                    "Consolas");

    // --------------------------------------------------------------
    // TEXT
    // --------------------------------------------------------------
    ObjectSetString(0,
                    name,
                    OBJPROP_TEXT,
                    text);

    ObjectSetInteger(0,
                     name,
                     OBJPROP_COLOR,
                     clr);

    // --------------------------------------------------------------
    // CRITICAL LAYER SETTINGS
    // --------------------------------------------------------------

    // Text is NOT a background object
    ObjectSetInteger(0,
                     name,
                     OBJPROP_BACK,
                     false);

    // Text is above background
    ObjectSetInteger(0,
                     name,
                     OBJPROP_ZORDER,
                     AI_PNL_TEXT_ZORDER + idx);

    // Do not allow selection
    ObjectSetInteger(0,
                     name,
                     OBJPROP_SELECTABLE,
                     false);

    ObjectSetInteger(0,
                     name,
                     OBJPROP_SELECTED,
                     false);

    ObjectSetInteger(0,
                     name,
                     OBJPROP_HIDDEN,
                     true);

    // Prevent text from interfering with chart mouse interaction
    ObjectSetInteger(0,
                     name,
                     OBJPROP_ANCHOR,
                     ANCHOR_LEFT_UPPER);

    g_ai_panel_lines =
        MathMax(g_ai_panel_lines,
                idx + 1);
}

//+------------------------------------------------------------------+
//| DELETE UNUSED PANEL LINES                                        |
//+------------------------------------------------------------------+
void AIBridge_PanelCleanupUnusedLines(int active_lines)
{
    // Remove old labels that are no longer used
    // Example:
    // previous panel = 12 lines
    // current panel  = 10 lines
    // labels 10 and 11 must be deleted.

    for(int i = active_lines; i < 100; i++)
    {
        string name =
            AI_PNL_PREFIX +
            IntegerToString(i);

        if(ObjectFind(0, name) >= 0)
            ObjectDelete(0, name);
    }
}

//+------------------------------------------------------------------+
//| PANEL UPDATE                                                     |
//+------------------------------------------------------------------+
void AIBridge_PanelUpdate(bool force)
{
    if(!InpAIShowPanel)
        return;

    if(!force &&
       (TimeCurrent() - g_ai_panel_last) < 1)
    {
        return;
    }

    g_ai_panel_last = TimeCurrent();

    // --------------------------------------------------------------
    // IMPORTANT:
    //
    // Reset line count before drawing.
    //
    // Background will be resized after all labels are known.
    // --------------------------------------------------------------
    g_ai_panel_lines = 0;

    // --------------------------------------------------------------
    // Waiting state
    // --------------------------------------------------------------
    if(g_ai_last.time == 0)
    {
        // Create background first
        g_ai_panel_lines = 2;
        AIBridge_PanelBackground();

        // Then text
        AIBridge_PanelLine(
            0,
            "AI BRIDGE v1.0  |  " +
            AIBridge_ModeName(InpAIMode),
            clrDodgerBlue);

        AIBridge_PanelLine(
            1,
            "Waiting for first signal...",
            clrGray);

        AIBridge_PanelCleanupUnusedLines(
            g_ai_panel_lines);

        // Recalculate background
        AIBridge_PanelBackground();

        ChartRedraw();
        return;
    }

    // --------------------------------------------------------------
    // Determine colors
    // --------------------------------------------------------------
    color gate_clr =
        g_ai_last.allow
        ? clrLime
        : clrTomato;

    string verdict_str =
        AIBridge_VerdictName(
            g_ai_last.local_verdict);

    // --------------------------------------------------------------
    // 0 - TITLE
    // --------------------------------------------------------------
    AIBridge_PanelLine(
        0,
        "AI BRIDGE v1.0  |  " +
        AIBridge_ModeName(g_ai_last.mode),
        clrDodgerBlue);

    // --------------------------------------------------------------
    // 1 - THRESHOLDS
    // --------------------------------------------------------------
    AIBridge_PanelLine(
        1,
        StringFormat(
            "Gate: local>=%.2f  AIconf>=%.2f%s",
            g_ai_last.local_min_used,
            g_ai_last.conf_min_used,
            InpAIAutoTune
            ? "  [AUTO-TUNE]"
            : ""),
        InpAIAutoTune
        ? clrGold
        : clrGray);

    // --------------------------------------------------------------
    // 2 - LAST SIGNAL
    // --------------------------------------------------------------
    AIBridge_PanelLine(
        2,
        "Signal: " +
        TimeToString(
            g_ai_last.time,
            TIME_DATE | TIME_MINUTES) +
        "  " +
        AIBridge_PnlDirStr(
            g_ai_last.order_type) +
        " @" +
        DoubleToString(
            g_ai_last.price,
            _Digits),
        clrWhite);

    // --------------------------------------------------------------
    // 3 - LOCAL SCORE
    // --------------------------------------------------------------
    AIBridge_PanelLine(
        3,
        StringFormat(
            "Local : %.2f [%s]  (min %.2f)",
            g_ai_last.local_score,
            verdict_str,
            g_ai_last.local_min_used),
        g_ai_last.local_verdict ==
        AI_VERDICT_WAIT
        ? clrOrange
        : clrLime);

    // --------------------------------------------------------------
    // 4 - WEB AI
    // --------------------------------------------------------------
    if(g_ai_last.ai_used)
    {
        string ai_str =
            g_ai_last.ai_ok
            ? StringFormat(
                "%.2f [%s]%s",
                g_ai_last.ai_conf,
                AIBridge_VerdictName(
                    g_ai_last.ai_verdict),
                g_ai_last.ai_conf >=
                g_ai_last.conf_min_used
                ? ""
                : " <min")
            : "unavailable";

        AIBridge_PanelLine(
            4,
            "WebAI: " + ai_str,
            g_ai_last.ai_ok
            ? clrLime
            : clrGray);
    }
    else
    {
        AIBridge_PanelLine(
            4,
            "WebAI: off",
            clrGray);
    }

    // --------------------------------------------------------------
    // 5 - FINAL + ALLOW
    // --------------------------------------------------------------
    AIBridge_PanelLine(
        5,
        StringFormat(
            "Final: %.2f  |  ALLOW %s",
            g_ai_last.final_score,
            g_ai_last.allow
            ? "YES"
            : "NO"),
        gate_clr);

    // --------------------------------------------------------------
    // 6 - SWEEP FACTS
    // --------------------------------------------------------------
    AIBridge_PanelLine(
        6,
        StringFormat(
            "Z=%.2f  Sweep=%.1fp  Snap=%.1fp  Vel=%s",
            g_ai_last.deviation_z,
            g_ai_last.sweep_depth_pips,
            g_ai_last.snapback_pips,
            g_ai_last.high_velocity
            ? "high"
            : "low"),
        clrSilver);

    // --------------------------------------------------------------
    // 7 - M1 STRUCTURE + ATR
    // --------------------------------------------------------------
    AIBridge_PanelLine(
        7,
        StringFormat(
            "M1: b=%.2f u=%.2f l=%.2f cl=%.2f | ATR=%.1fp",
            g_ai_last.m1_body_ratio,
            g_ai_last.m1_upper_wick,
            g_ai_last.m1_lower_wick,
            g_ai_last.m1_close_loc,
            g_ai_last.m1_atr_pips),
        clrSilver);

    // --------------------------------------------------------------
    // 8 - MTF + M5 BIAS
    // --------------------------------------------------------------
    AIBridge_PanelLine(
        8,
        StringFormat(
            "MTF: H1 %s M15 %s M5 %s | M5bias=%s",
            g_ai_last.h1_up
            ? "up"
            : (g_ai_last.h1_down
               ? "dn"
               : "-"),

            g_ai_last.m15_up
            ? "up"
            : (g_ai_last.m15_down
               ? "dn"
               : "-"),

            g_ai_last.m5_up
            ? "up"
            : (g_ai_last.m5_down
               ? "dn"
               : "-"),

            g_ai_last.m5_bullish
            ? "up"
            : (g_ai_last.m5_bearish
               ? "dn"
               : "-")),
        clrSilver);

    // --------------------------------------------------------------
    // 9 - SPREAD + SESSION + VWAP
    // --------------------------------------------------------------
    AIBridge_PanelLine(
        9,
        StringFormat(
            "Spr=%.1fp  Hr=%.0f  VWAP=%s",
            g_ai_last.spread_pips,
            g_ai_last.hour_of_day,
            DoubleToString(
                g_ai_last.vwap,
                _Digits)),
        clrSilver);

    // --------------------------------------------------------------
    // 10 - OUTCOME STATISTICS
    // --------------------------------------------------------------
    int n_out =
        ArraySize(g_ai_outcomes_r);

    if(n_out > 0)
    {
        int wins = 0;
        double sum = 0.0;

        for(int i = 0; i < n_out; i++)
        {
            if(g_ai_outcomes_r[i] > 0.0)
                wins++;

            sum += g_ai_outcomes_r[i];
        }

        AIBridge_PanelLine(
            10,
            StringFormat(
                "Outcomes n=%d  meanR=%.2f  WR=%d%%",
                n_out,
                sum / n_out,
                (int)MathRound(
                    100.0 *
                    wins /
                    n_out)),
            clrSilver);
    }
    else
    {
        AIBridge_PanelLine(
            10,
            "Outcomes: none yet",
            clrGray);
    }

    // --------------------------------------------------------------
    // 11 - AUTO-TUNE STATE
    // --------------------------------------------------------------
    if(InpAIAutoTune)
    {
        AIBridge_PanelLine(
            11,
            StringFormat(
                "Adaptive: local=%.2f conf=%.2f",
                g_ai_local_min,
                g_ai_conf_min),
            clrGold);
    }

    // --------------------------------------------------------------
    // CLEANUP UNUSED OLD LABELS
    // --------------------------------------------------------------
    AIBridge_PanelCleanupUnusedLines(
        g_ai_panel_lines);

    // --------------------------------------------------------------
    // UPDATE BACKGROUND SIZE
    // --------------------------------------------------------------
    AIBridge_PanelBackground();

    ChartRedraw();
}

//+------------------------------------------------------------------+
//| PANEL DIRECTION STRING                                           |
//+------------------------------------------------------------------+
string AIBridge_PnlDirStr(ENUM_ORDER_TYPE t)
{
    if(t == ORDER_TYPE_BUY)
        return "BUY";

    if(t == ORDER_TYPE_SELL)
        return "SELL";

    return "-";
}

//+------------------------------------------------------------------+
//| PANEL DELETE                                                     |
//+------------------------------------------------------------------+
void AIBridge_PanelDelete()
{
    // Delete text objects
    for(int i = 0; i < 100; i++)
    {
        string name =
            AI_PNL_PREFIX +
            IntegerToString(i);

        if(ObjectFind(0, name) >= 0)
            ObjectDelete(0, name);
    }

    // Delete background
    if(ObjectFind(0, AI_PNL_BGNAME) >= 0)
        ObjectDelete(0, AI_PNL_BGNAME);

    g_ai_panel_lines   = 0;
    g_ai_panel_created = false;
}

//+------------------------------------------------------------------+
//| CSV LOGGING                                                      |
//+------------------------------------------------------------------+
void AIBridge_LogCSV()
{
    if(!InpAILogCSV)
        return;

    if(g_ai_last.time == 0)
        return;

    int h =
        FileOpen(
            InpAICSVFile,
            FILE_READ |
            FILE_WRITE |
            FILE_CSV |
            FILE_ANSI,
            ',');

    if(h == INVALID_HANDLE)
        return;

    // --------------------------------------------------------------
    // HEADER
    // --------------------------------------------------------------
    if(FileSize(h) == 0)
    {
        FileWrite(
            h,
            "time",
            "symbol",
            "dir",
            "price",
            "bid",
            "ask",
            "spread_pips",
            "vwap",
            "std_dev",
            "z",
            "sweep_pips",
            "snap_pips",
            "velocity",
            "m1_atr_pips",
            "m1_body",
            "m1_upper_wick",
            "m1_lower_wick",
            "m1_close",
            "m1_bull",
            "m1_bear",
            "h1_up",
            "h1_down",
            "m15_up",
            "m15_down",
            "m5_up",
            "m5_down",
            "m5_bull",
            "hour",
            "local_score",
            "local_verdict",
            "ai_used",
            "ai_ok",
            "ai_conf",
            "ai_verdict",
            "final_score",
            "allow",
            "local_min",
            "conf_min",
            "reason",
            "ai_reason");
    }

    FileSeek(h, 0, SEEK_END);

    // --------------------------------------------------------------
    // DATA
    // --------------------------------------------------------------
    FileWrite(
        h,

        TimeToString(
            g_ai_last.time,
            TIME_DATE | TIME_SECONDS),

        _Symbol,

        AIBridge_OrderTypeStr(
            g_ai_last.order_type),

        DoubleToString(
            g_ai_last.price,
            _Digits),

        DoubleToString(
            g_ai_last.bid,
            _Digits),

        DoubleToString(
            g_ai_last.ask,
            _Digits),

        DoubleToString(
            g_ai_last.spread_pips,
            2),

        DoubleToString(
            g_ai_last.vwap,
            _Digits),

        DoubleToString(
            g_ai_last.std_dev,
            _Digits),

        DoubleToString(
            g_ai_last.deviation_z,
            2),

        DoubleToString(
            g_ai_last.sweep_depth_pips,
            2),

        DoubleToString(
            g_ai_last.snapback_pips,
            2),

        g_ai_last.high_velocity
        ? "1"
        : "0",

        DoubleToString(
            g_ai_last.m1_atr_pips,
            2),

        DoubleToString(
            g_ai_last.m1_body_ratio,
            3),

        DoubleToString(
            g_ai_last.m1_upper_wick,
            3),

        DoubleToString(
            g_ai_last.m1_lower_wick,
            3),

        DoubleToString(
            g_ai_last.m1_close_loc,
            3),

        g_ai_last.m1_bullish
        ? "1"
        : "0",

        g_ai_last.m1_bearish
        ? "1"
        : "0",

        g_ai_last.h1_up
        ? "1"
        : "0",

        g_ai_last.h1_down
        ? "1"
        : "0",

        g_ai_last.m15_up
        ? "1"
        : "0",

        g_ai_last.m15_down
        ? "1"
        : "0",

        g_ai_last.m5_up
        ? "1"
        : "0",

        g_ai_last.m5_down
        ? "1"
        : "0",

        g_ai_last.m5_bullish
        ? "1"
        : "0",

        DoubleToString(
            g_ai_last.hour_of_day,
            0),

        DoubleToString(
            g_ai_last.local_score,
            3),

        AIBridge_VerdictName(
            g_ai_last.local_verdict),

        g_ai_last.ai_used
        ? "1"
        : "0",

        g_ai_last.ai_ok
        ? "1"
        : "0",

        DoubleToString(
            g_ai_last.ai_conf,
            3),

        g_ai_last.ai_used
        ? AIBridge_VerdictName(
            g_ai_last.ai_verdict)
        : "-",

        DoubleToString(
            g_ai_last.final_score,
            3),

        g_ai_last.allow
        ? "1"
        : "0",

        DoubleToString(
            g_ai_last.local_min_used,
            3),

        DoubleToString(
            g_ai_last.conf_min_used,
            3),

        g_ai_last.reason,

        g_ai_last.ai_reason);

    FileClose(h);
}

//+------------------------------------------------------------------+
//| DECISION HOOK                                                    |
//+------------------------------------------------------------------+
void AIBridge_UX_OnDecision()
{
    if(!g_ai_ux_inited)
    {
        g_ai_ux_inited     = true;
        g_ai_panel_created = false;
        g_ai_panel_lines   = 0;
    }

    if(InpAIShowPanel)
        AIBridge_PanelUpdate(true);

    if(InpAILogCSV)
        AIBridge_LogCSV();
}

//+------------------------------------------------------------------+
//| POSITION INDEX                                                   |
//+------------------------------------------------------------------+
int AIBridge_PosIndex(ulong ticket)
{
    for(int i = ArraySize(g_ai_pos) - 1;
        i >= 0;
        i--)
    {
        if(g_ai_pos[i].ticket == ticket)
            return i;
    }

    return -1;
}

//+------------------------------------------------------------------+
//| REMOVE POSITION RECORD                                           |
//+------------------------------------------------------------------+
void AIBridge_PosRemove(int idx)
{
    int n = ArraySize(g_ai_pos);

    if(idx < 0 || idx >= n)
        return;

    for(int i = idx; i < n - 1; i++)
        g_ai_pos[i] = g_ai_pos[i + 1];

    ArrayResize(
        g_ai_pos,
        n - 1);
}

//+------------------------------------------------------------------+
//| RISK PER LOT                                                     |
//+------------------------------------------------------------------+
double AIBridge_RiskPerLot(
    const AIPosRecord &rec)
{
    if(rec.sl <= 0.0)
        return 0.0;

    ENUM_ORDER_TYPE type =
        (rec.type == POSITION_TYPE_BUY)
        ? ORDER_TYPE_BUY
        : ORDER_TYPE_SELL;

    double profit = 0.0;

    if(OrderCalcProfit(
        type,
        _Symbol,
        1.0,
        rec.entry,
        rec.sl,
        profit))
    {
        return MathAbs(profit);
    }

    // --------------------------------------------------------------
    // FALLBACK
    // --------------------------------------------------------------
    double tick_val =
        SymbolInfoDouble(
            _Symbol,
            SYMBOL_TRADE_TICK_VALUE_LOSS);

    double tick_sz =
        SymbolInfoDouble(
            _Symbol,
            SYMBOL_TRADE_TICK_SIZE);

    if(tick_val <= 0.0 ||
       tick_sz <= 0.0)
    {
        return 0.0;
    }

    return
        MathAbs(
            rec.entry - rec.sl) /
        tick_sz *
        tick_val;
}

//+------------------------------------------------------------------+
//| GET CLOSED PROFIT                                                |
//+------------------------------------------------------------------+
double AIBridge_GetClosedProfit(
    const AIPosRecord &rec)
{
    if(!HistorySelect(
        0,
        TimeCurrent()))
    {
        return 0.0;
    }

    int total =
        HistoryDealsTotal();

    for(int i = total - 1;
        i >= 0;
        i--)
    {
        ulong dticket =
            HistoryDealGetTicket(i);

        if(dticket == 0)
            continue;

        if(HistoryDealGetInteger(
            dticket,
            DEAL_POSITION_ID) !=
           (long)rec.ticket)
        {
            continue;
        }

        if((ENUM_DEAL_ENTRY)
           HistoryDealGetInteger(
               dticket,
               DEAL_ENTRY) !=
           DEAL_ENTRY_OUT)
        {
            continue;
        }

        return
            HistoryDealGetDouble(
                dticket,
                DEAL_PROFIT)

            +

            HistoryDealGetDouble(
                dticket,
                DEAL_SWAP)

            +

            HistoryDealGetDouble(
                dticket,
                DEAL_COMMISSION);
    }

    return 0.0;
}

//+------------------------------------------------------------------+
//| PUSH OUTCOME                                                     |
//+------------------------------------------------------------------+
void AIBridge_PushOutcome(double r)
{
    int n =
        ArraySize(
            g_ai_outcomes_r);

    ArrayResize(
        g_ai_outcomes_r,
        n + 1);

    g_ai_outcomes_r[n] = r;

    // Keep bounded to 200 outcomes
    if(ArraySize(g_ai_outcomes_r) > 200)
    {
        for(int i = 0; i < 199; i++)
        {
            g_ai_outcomes_r[i] =
                g_ai_outcomes_r[i + 1];
        }

        ArrayResize(
            g_ai_outcomes_r,
            200);
    }
}

//+------------------------------------------------------------------+
//| AUTO TUNE                                                        |
//+------------------------------------------------------------------+
void AIBridge_AutoTune()
{
    if(!InpAIAutoTune)
        return;

    int n =
        ArraySize(
            g_ai_outcomes_r);

    if(n < InpAIAutoTuneLookback)
        return;

    double sum = 0.0;

    for(int i =
        n - InpAIAutoTuneLookback;
        i < n;
        i++)
    {
        sum +=
            g_ai_outcomes_r[i];
    }

    double mean =
        sum /
        InpAIAutoTuneLookback;

    // --------------------------------------------------------------
    // LOSING -> TIGHTEN
    // --------------------------------------------------------------
    if(mean < 0.0)
    {
        double nl =
            MathMin(
                InpAIAutoTuneMaxScore,
                g_ai_local_min +
                InpAIAutoTuneStep);

        double nc =
            MathMin(
                0.90,
                g_ai_conf_min +
                InpAIAutoTuneStep);

        if(nl != g_ai_local_min ||
           nc != g_ai_conf_min)
        {
            g_ai_local_min = nl;
            g_ai_conf_min  = nc;

            PrintFormat(
                "[AI-TUNE] meanR=%.2f -> "
                "TIGHTEN local=%.2f conf=%.2f "
                "(last %d trades)",
                mean,
                g_ai_local_min,
                g_ai_conf_min,
                InpAIAutoTuneLookback);
        }
    }

    // --------------------------------------------------------------
    // PROFITABLE -> EASE
    // --------------------------------------------------------------
    else if(mean >
            InpAIAutoTuneTargetR)
    {
        double nl =
            MathMax(
                InpAIAutoTuneMinScore,
                g_ai_local_min -
                InpAIAutoTuneStep);

        double nc =
            MathMax(
                0.50,
                g_ai_conf_min -
                InpAIAutoTuneStep);

        if(nl != g_ai_local_min ||
           nc != g_ai_conf_min)
        {
            g_ai_local_min = nl;
            g_ai_conf_min  = nc;

            PrintFormat(
                "[AI-TUNE] meanR=%.2f -> "
                "EASE local=%.2f conf=%.2f "
                "(last %d trades)",
                mean,
                g_ai_local_min,
                g_ai_conf_min,
                InpAIAutoTuneLookback);
        }
    }
}

//+------------------------------------------------------------------+
//| RECONCILE POSITIONS                                              |
//+------------------------------------------------------------------+
void AIBridge_Reconcile()
{
    // --------------------------------------------------------------
    // 1. Detect NEW positions
    // --------------------------------------------------------------
    for(int i = PositionsTotal() - 1;
        i >= 0;
        i--)
    {
        ulong ticket =
            PositionGetTicket(i);

        if(ticket == 0)
            continue;

        if(PositionGetString(
            POSITION_SYMBOL) !=
           _Symbol)
        {
            continue;
        }

        if((ulong)PositionGetInteger(
            POSITION_MAGIC) !=
           InpMagicNumber)
        {
            continue;
        }

        if(AIBridge_PosIndex(ticket) >= 0)
            continue;

        AIPosRecord rec;

        rec.ticket =
            ticket;

        rec.open_time =
            (datetime)PositionGetInteger(
                POSITION_TIME);

        rec.type =
            (ENUM_POSITION_TYPE)
            PositionGetInteger(
                POSITION_TYPE);

        rec.entry =
            PositionGetDouble(
                POSITION_PRICE_OPEN);

        rec.sl =
            PositionGetDouble(
                POSITION_SL);

        rec.volume =
            PositionGetDouble(
                POSITION_VOLUME);

        rec.closed = false;
        rec.r      = 0.0;

        // ----------------------------------------------------------
        // Link with latest AI decision
        // ----------------------------------------------------------
        bool fresh =
            (g_ai_last.time > 0) &&
            ((TimeCurrent() -
              g_ai_last.time) <= 30);

        bool dir_ok =
            (rec.type == POSITION_TYPE_BUY)
            ?
            (g_ai_last.order_type ==
             ORDER_TYPE_BUY)
            :
            (g_ai_last.order_type ==
             ORDER_TYPE_SELL);

        if(fresh && dir_ok)
        {
            rec.local_score =
                g_ai_last.local_score;

            rec.ai_conf =
                g_ai_last.ai_conf;

            rec.allow =
                g_ai_last.allow;
        }
        else
        {
            rec.local_score = 0.0;
            rec.ai_conf     = 0.0;
            rec.allow       = true;
        }

        int n =
            ArraySize(g_ai_pos);

        ArrayResize(
            g_ai_pos,
            n + 1);

        g_ai_pos[n] = rec;

        PrintFormat(
            "[AI-TRACK] Position %I64u opened | "
            "local=%.2f ai=%.2f allow=%s",
            ticket,
            rec.local_score,
            rec.ai_conf,
            rec.allow
            ? "1"
            : "0");
    }

    // --------------------------------------------------------------
    // 2. Process CLOSED positions
    // --------------------------------------------------------------
    for(int i =
        ArraySize(g_ai_pos) - 1;
        i >= 0;
        i--)
    {
        if(g_ai_pos[i].closed)
            continue;

        // Still open
        if(AIBridge_PosIndex(
            g_ai_pos[i].ticket) >= 0)
        {
            continue;
        }

        g_ai_pos[i].closed = true;

        double profit =
            AIBridge_GetClosedProfit(
                g_ai_pos[i]);

        double risk_lot =
            AIBridge_RiskPerLot(
                g_ai_pos[i]);

        double r = 0.0;

        if(profit != 0.0 &&
           risk_lot > 0.0 &&
           g_ai_pos[i].volume > 0.0)
        {
            r =
                profit /
                (risk_lot *
                 g_ai_pos[i].volume);
        }

        g_ai_pos[i].r = r;

        AIBridge_PushOutcome(r);

        PrintFormat(
            "[AI-TRACK] Position %I64u closed | "
            "R=%.2f | profit=%.2f",
            g_ai_pos[i].ticket,
            r,
            profit);

        AIBridge_AutoTune();

        AIBridge_PosRemove(i);
    }
}

//+------------------------------------------------------------------+
//| TICK MAINTENANCE                                                 |
//+------------------------------------------------------------------+
void AIBridge_TickMaintenance()
{
    if((TimeCurrent() -
        g_ai_maint_last) < 1)
    {
        return;
    }

    g_ai_maint_last =
        TimeCurrent();

    // Position/outcome maintenance
    AIBridge_Reconcile();

    // Panel maintenance
    if(InpAIShowPanel)
        AIBridge_PanelUpdate(false);
}

//+------------------------------------------------------------------+
//| DEINIT                                                           |
//+------------------------------------------------------------------+
void AIBridge_Deinit()
{
    AIBridge_PanelDelete();

    g_ai_ux_inited = false;

    g_ai_panel_created = false;

    g_ai_panel_lines = 0;

    g_ai_maint_last = 0;

    g_ai_panel_last = 0;

    ArrayResize(
        g_ai_pos,
        0);
}

//+------------------------------------------------------------------+
#endif // AIBRIDGEUX_MQH