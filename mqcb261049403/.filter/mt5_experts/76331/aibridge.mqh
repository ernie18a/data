//+------------------------------------------------------------------+
//|                    AIBridge.mqh                                  |
//|                                                                  |
//|  AI Bridge + Decision Intelligence Layer                         |
//|  For : Hybrid Microstructure EA (XAUUSD scalping)                |
//|                                                                  |
//|  PURPOSE                                                         |
//|  Adds a FINAL factual decision gate right before order           |
//|  execution. Two complementary engines:                           |
//|                                                                  |
//|   1) LOCAL DECISION ENGINE (deterministic, explainable, offline) |
//|      Weighted multi-factor score built from REAL measured facts: |
//|      MTF alignment, VWAP deviation Z, sweep depth, snapback,     |
//|      tick velocity, M1 structure, M1 ATR regime, spread, session.|
//|                                                                  |
//|   2) WEB AI BRIDGE (OpenAI-compatible chat API or local server)  |
//|      Sends the same measured facts as strict JSON, receives      |
//|      {decision, confidence, reason} and gates the entry.         |
//|                                                                  |
//|  MODES                                                           |
//|   AI_MODE_OFF    : bridge disabled, EA behaves exactly as before |
//|   AI_MODE_LOCAL  : local scoring engine only (fast, offline)     |
//|   AI_MODE_WEB    : external AI only                              |
//|   AI_MODE_HYBRID : local + AI must AGREE (recommended)           |
//|                                                                  |
//|  SETUP                                                           |
//|   WebRequest URL must be whitelisted in MT5:                     |
//|   Tools -> Options -> Expert Advisors -> Allow WebRequest        |
//|   API key: fill InpAIKey, or create <data>\MQL5\Files\           |
//|            ai_bridge.key containing only the key.                |
//+------------------------------------------------------------------+
#property copyright "Copyright©2023. Ritz EAneha©"
#property link      "https://www.mql5.com/en/users/ritzfalih"
#include <HybridMicrostructure\ParamUX.mqh>
#include <HybridMicrostructure\AIBridgeUX.mqh>
#ifndef AIBRIDGE_MQH
#define AIBRIDGE_MQH
//+------------------------------------------------------------------+
//| ENUMS                                                            |
//+------------------------------------------------------------------+
enum ENUM_AI_MODE
{
    AI_MODE_OFF    = 0, // Off - EA behavior unchanged
    AI_MODE_LOCAL  = 1, // Local decision engine only
    AI_MODE_WEB    = 2, // Web AI only
    AI_MODE_HYBRID = 3  // Local + Web AI must agree (recommended)
};

enum ENUM_AI_FALLBACK
{
    AI_FB_BLOCK = 0, // Block entry if AI unavailable
    AI_FB_ALLOW = 1, // Allow entry if AI unavailable
    AI_FB_LOCAL = 2  // Use local scoring if AI unavailable
};

enum ENUM_AI_VERDICT
{
    AI_VERDICT_WAIT = 0, // No trade
    AI_VERDICT_BUY  = 1, // Long
    AI_VERDICT_SELL = 2  // Short
};

//+------------------------------------------------------------------+
//| INPUTS                                                           |
//+------------------------------------------------------------------+
input group "------------------- AI Bridge & Decision Intelligence ---"

input ENUM_AI_MODE     InpAIMode            = AI_MODE_HYBRID;   // AI decision mode
input bool             InpAILogDecisions    = true;             // Log AI decisions to journal
input double           InpLocalMinScore     = 0.60;             // Local engine min score (0..1)
input double           InpLocalMaxScore     = 0.95;             // Local engine score cap (0..1)
input string           InpAIEndpoint        = "http://127.0.0.1:8787/analyze(http://127.0.0.1:8787/analyze)"; // AI endpoint URL
input string           InpAIKey             = "";               // API key (or load from file)
input string           InpAIKeyFile         = "ai_bridge.key";  // Key file in <data>\MQL5\Files
input string           InpAIModel           = "hybrid-microstructure-v1"; // Model name
input double           InpAIMinConfidence   = 0.60;             // Min AI confidence to allow entry
input int              InpAITimeoutMs       = 3000;             // Web request timeout (ms)
input int              InpAIMaxRetries      = 1;                // Web request retries
input ENUM_AI_FALLBACK InpAIFallback        = AI_FB_LOCAL;      // Behavior if AI is unavailable
input bool             InpAIDisableInTester = true;             // Disable web calls in tester
input int              InpAIWebIntervalMs   = 3000;             // Min interval between web calls (ms)
input int              InpAICircuitFailures = 3;                // Failures before circuit breaker
input int              InpAICircuitCooldownSec = 300;           // Circuit breaker cooldown (sec)
input bool             InpAIUseJSONMode     = true;             // Request JSON response format

//+------------------------------------------------------------------+
//| CONTEXT STRUCT (facts snapshot at decision time)                 |
//+------------------------------------------------------------------+
struct AIBridgeContext
{
    ENUM_ORDER_TYPE   order_type;
    double            price;
    double            bid;
    double            ask;
    datetime          time;
    double            spread_pips;
    double            vwap;
    double            upper_band;
    double            lower_band;
    double            std_dev;
    double            deviation_z;
    double            sweep_depth_pips;
    double            snapback_pips;
    double            extreme_peak;
    bool              high_velocity;
    double            m1_atr_pips;
    double            m1_atr_value;
    bool              m1_available;
    double            m1_body_ratio;
    double            m1_upper_wick;
    double            m1_lower_wick;
    double            m1_close_loc;
    bool              m1_bullish;
    bool              m1_bearish;
    bool              h1_available;
    bool              h1_up;
    bool              h1_down;
    bool              m15_available;
    bool              m15_up;
    bool              m15_down;
    bool              m5_ma_available;
    bool              m5_ma_up;
    bool              m5_ma_down;
    bool              m5_setup_available;
    bool              m5_bullish;
    bool              m5_bearish;
    double            m5_body_ratio;
    double            m5_close_loc;
    double            hour_of_day;
    double            day_of_week;
};

//+------------------------------------------------------------------+
//| INTERNAL STATE                                                    |
//+------------------------------------------------------------------+
string   g_ai_key                  = "";
datetime g_ai_last_call            = 0;
int      g_ai_consecutive_failures = 0;
datetime g_ai_circuit_until        = 0;

// Runtime adaptive thresholds (modified by auto-tune)
double g_ai_local_min = 0.60;
double g_ai_conf_min  = 0.70;

//+------------------------------------------------------------------+
//| DECISION SNAPSHOT (last AI evaluation, for panel/CSV/auto-tune)  |
//+------------------------------------------------------------------+
struct AIDecisionSnapshot
{
    ENUM_ORDER_TYPE order_type;
    datetime        time;
    double          price;
    double          bid;
    double          ask;
    double          spread_pips;
    double          vwap;
    double          std_dev;
    double          deviation_z;
    double          sweep_depth_pips;
    double          snapback_pips;
    bool            high_velocity;
    double          m1_atr_pips;
    double          m1_body_ratio;
    double          m1_upper_wick;
    double          m1_lower_wick;
    double          m1_close_loc;
    bool            m1_bullish;
    bool            m1_bearish;
    bool            h1_up;
    bool            h1_down;
    bool            m15_up;
    bool            m15_down;
    bool            m5_up;
    bool            m5_down;
    bool            m5_bullish;
    bool            m5_bearish;
    double          hour_of_day;
    double          day_of_week;
    double          local_score;
    ENUM_AI_VERDICT local_verdict;
    bool            ai_used;
    bool            ai_ok;
    double          ai_conf;
    ENUM_AI_VERDICT ai_verdict;
    double          final_score;
    bool            allow;
    double          local_min_used;
    double          conf_min_used;
    ENUM_AI_MODE    mode;
    string          reason;
    string          ai_reason;
};

AIDecisionSnapshot g_ai_last;

//+------------------------------------------------------------------+
//| INIT                                                             |
//+------------------------------------------------------------------+
void AIBridge_Init()
{
    g_ai_key = InpAIKey;

    if (StringLen(g_ai_key) == 0)
    {
        string file_key = "";
        if (AIBridge_ReadKeyFromFile(file_key))
            g_ai_key = file_key;
    }

    g_ai_consecutive_failures = 0;
    g_ai_circuit_until        = 0;
    g_ai_last_call            = 0;

    g_ai_local_min = InpLocalMinScore;
    g_ai_conf_min  = InpAIMinConfidence;

    Print(" AI Bridge v1.0 | Mode: ", AIBridge_ModeName(InpAIMode));
    Print(" Endpoint: ", InpAIEndpoint);

    if (InpAIMode == AI_MODE_WEB || InpAIMode == AI_MODE_HYBRID)
    {
        if (StringLen(g_ai_key) > 0)
            Print(" Auth: Bearer key configured");
        else
            Print(" Auth: no key (local/anonymous endpoint only)");

        Print(" Web calls in tester disabled: ", InpAIDisableInTester ? "yes" : "no");
    }

    Print(" Local engine min score: ", DoubleToString(g_ai_local_min, 2));
    Print("--------------------------------------------------");
}

//+------------------------------------------------------------------+
//| MAIN CONFIRMATION GATE                                           |
//| Called by the EA right before ExecuteTrade().                    |
//+------------------------------------------------------------------+
bool AIBridge_Confirm(
    ENUM_ORDER_TYPE order_type,
    double price,
    const MqlTick &tick,
    bool is_high_velocity,
    double vwap,
    double upper_band,
    double lower_band,
    double std_dev,
    double in_extreme_peak,     
    int in_handle_atr_m1,       
    int in_handle_ma_h1,        
    int in_handle_ma_m15,       
    int in_handle_ma_m5)        
{
    if (InpAIMode == AI_MODE_OFF)
        return (true);

    AIBridgeContext ctx;

    // Perbarui pemanggilan variabel di sini
    if (!AIBridge_BuildContext(order_type, price, tick, is_high_velocity, vwap,
                               upper_band, lower_band, std_dev, in_extreme_peak,
                               in_handle_atr_m1, in_handle_ma_h1, in_handle_ma_m15,
                               in_handle_ma_m5, ctx))
        return (InpAIFallback != AI_FB_BLOCK);

    //---------------------------------------------------------------
    // 1) Local decision engine (always computed)
    //---------------------------------------------------------------
    string reasons[];
    double local_score = AIBridge_LocalScore(ctx, reasons);

    ENUM_AI_VERDICT local_verdict = AI_VERDICT_WAIT;

    if (local_score >= g_ai_local_min)
        local_verdict = (order_type == ORDER_TYPE_BUY) ? AI_VERDICT_BUY : AI_VERDICT_SELL;

    //---------------------------------------------------------------
    // 2) Web AI (optional)
    //---------------------------------------------------------------
    bool want_web = (InpAIMode == AI_MODE_WEB || InpAIMode == AI_MODE_HYBRID);
    bool ai_used  = false;
    bool ai_ok    = false;
    double ai_conf         = 0.0;
    ENUM_AI_VERDICT ai_verdict = AI_VERDICT_WAIT;
    string ai_reason       = "";

    if (want_web && !(InpAIDisableInTester && MQLInfoInteger(MQL_TESTER)))
    {
        ai_used = true;
        ai_ok   = AIBridge_WebCall(ctx, ai_conf, ai_verdict, ai_reason);
    }

    //---------------------------------------------------------------
    // 3) Combine per mode
    //---------------------------------------------------------------
    bool allow = false;
    double final_score = local_score;

    if (InpAIMode == AI_MODE_LOCAL)
    {
        allow = (local_verdict != AI_VERDICT_WAIT);
    }
    else if (InpAIMode == AI_MODE_WEB)
    {
        if (ai_ok)
        {
            allow = (ai_verdict != AI_VERDICT_WAIT && ai_conf >= g_ai_conf_min);
            final_score = ai_conf;
        }
        else
            allow = AIBridge_ApplyFallback(local_score, local_verdict);
    }
    else // AI_MODE_HYBRID
    {
        if (ai_ok)
        {
            bool same_dir = (ai_verdict == local_verdict) &&
                            (ai_verdict != AI_VERDICT_WAIT);

            allow = same_dir &&
                    (local_score >= g_ai_local_min) &&
                    (ai_conf >= g_ai_conf_min);

            final_score = 0.6 * local_score + 0.4 * ai_conf;
        }
        else
            allow = AIBridge_ApplyFallback(local_score, local_verdict);
    }

    //---------------------------------------------------------------
    // 4) Logging
    //---------------------------------------------------------------
    if (InpAILogDecisions)
    {
        string reason_text = "";

        for (int i = 0; i < ArraySize(reasons); i++)
        {
            if (i > 0)
                reason_text += " | ";
            reason_text += reasons[i];
        }

        PrintFormat(
            "[AI] %s %s | local=%.2f | web=%s(%.2f) | final=%.2f | ALLOW=%s | %s | %s",
            AIBridge_OrderTypeStr(order_type),
            AIBridge_ModeName(InpAIMode),
            local_score,
            ai_used ? (ai_ok ? AIBridge_VerdictName(ai_verdict) : "unavailable") : "off",
            ai_used ? ai_conf : 0.0,
            final_score,
            allow ? "YES" : "NO",
            ai_used ? ai_reason : "-",
            reason_text
        );
    }

    //---------------------------------------------------------------
    // 5) Store decision snapshot
    //---------------------------------------------------------------
    g_ai_last.order_type       = ctx.order_type;
    g_ai_last.time             = ctx.time;
    g_ai_last.price            = ctx.price;
    g_ai_last.bid              = ctx.bid;
    g_ai_last.ask              = ctx.ask;
    g_ai_last.spread_pips      = ctx.spread_pips;
    g_ai_last.vwap             = ctx.vwap;
    g_ai_last.std_dev          = ctx.std_dev;
    g_ai_last.deviation_z      = ctx.deviation_z;
    g_ai_last.sweep_depth_pips = ctx.sweep_depth_pips;
    g_ai_last.snapback_pips    = ctx.snapback_pips;
    g_ai_last.high_velocity    = ctx.high_velocity;
    g_ai_last.m1_atr_pips      = ctx.m1_atr_pips;
    g_ai_last.m1_body_ratio    = ctx.m1_body_ratio;
    g_ai_last.m1_upper_wick    = ctx.m1_upper_wick;
    g_ai_last.m1_lower_wick    = ctx.m1_lower_wick;
    g_ai_last.m1_close_loc     = ctx.m1_close_loc;
    g_ai_last.m1_bullish       = ctx.m1_bullish;
    g_ai_last.m1_bearish       = ctx.m1_bearish;
    g_ai_last.h1_up            = ctx.h1_up;
    g_ai_last.h1_down          = ctx.h1_down;
    g_ai_last.m15_up           = ctx.m15_up;
    g_ai_last.m15_down         = ctx.m15_down;
    g_ai_last.m5_up            = ctx.m5_ma_up;
    g_ai_last.m5_down          = ctx.m5_ma_down;
    g_ai_last.m5_bullish       = ctx.m5_bullish;
    g_ai_last.m5_bearish       = ctx.m5_bearish;
    g_ai_last.hour_of_day      = ctx.hour_of_day;
    g_ai_last.day_of_week      = ctx.day_of_week;
    g_ai_last.local_score      = local_score;
    g_ai_last.local_verdict    = local_verdict;
    g_ai_last.ai_used          = ai_used;
    g_ai_last.ai_ok            = ai_ok;
    g_ai_last.ai_conf          = ai_conf;
    g_ai_last.ai_verdict       = ai_verdict;
    g_ai_last.final_score      = final_score;
    g_ai_last.allow            = allow;
    g_ai_last.local_min_used   = g_ai_local_min;
    g_ai_last.conf_min_used    = g_ai_conf_min;
    g_ai_last.mode             = InpAIMode;
    g_ai_last.ai_reason        = ai_reason;

    string snap_reason = "";

    for (int i = 0; i < ArraySize(reasons); i++)
    {
        if (i > 0)
            snap_reason += " | ";
        snap_reason += reasons[i];
    }

    g_ai_last.reason = snap_reason;

    AIBridge_UX_OnDecision();

    return (allow);
}

//+------------------------------------------------------------------+
//| BUILD CONTEXT (collect REAL facts)                               |
//+------------------------------------------------------------------+
bool AIBridge_BuildContext(
    ENUM_ORDER_TYPE order_type,
    double price,
    const MqlTick &tick,
    bool is_high_velocity,
    double vwap,
    double upper_band,
    double lower_band,
    double std_dev,
    double in_extreme_peak,     
    int in_handle_atr_m1,       
    int in_handle_ma_h1,        
    int in_handle_ma_m15,       
    int in_handle_ma_m5,        
    AIBridgeContext &ctx)
{
    ZeroMemory(ctx);

    double pip = _Point * AIBridge_GetPipMultiplier();

    ctx.order_type    = order_type;
    ctx.price         = price;
    ctx.bid           = tick.bid;
    ctx.ask           = tick.ask;
    ctx.time          = tick.time;
    ctx.spread_pips   = (tick.ask - tick.bid) / pip;
    ctx.vwap          = vwap;
    ctx.upper_band    = upper_band;
    ctx.lower_band    = lower_band;
    ctx.std_dev       = std_dev;
    ctx.extreme_peak  = in_extreme_peak;
    ctx.high_velocity = is_high_velocity;

    // Deviation Z and sweep depth (directional)
    if (order_type == ORDER_TYPE_SELL)
    {
        ctx.deviation_z      = (std_dev > 0.0) ? (in_extreme_peak - vwap) / std_dev : 0.0;
        ctx.sweep_depth_pips = (in_extreme_peak - vwap) / pip;
        ctx.snapback_pips    = (in_extreme_peak - tick.bid) / pip;
    }
    else
    {
        ctx.deviation_z      = (std_dev > 0.0) ? (vwap - in_extreme_peak) / std_dev : 0.0;
        ctx.sweep_depth_pips = (vwap - in_extreme_peak) / pip;
        ctx.snapback_pips    = (tick.ask - in_extreme_peak) / pip;
    }

    // M1 ATR
    ctx.m1_atr_pips  = AIBridge_ATRPips(in_handle_atr_m1);
    ctx.m1_atr_value = ctx.m1_atr_pips * pip;

    // MTF trend (from EA MA handles)
    ctx.h1_available  = AIBridge_GetMATrend(in_handle_ma_h1,  PERIOD_H1,  ctx.h1_up,  ctx.h1_down);
    ctx.m15_available = AIBridge_GetMATrend(in_handle_ma_m15, PERIOD_M15, ctx.m15_up, ctx.m15_down);
    ctx.m5_ma_available = AIBridge_GetMATrend(in_handle_ma_m5, PERIOD_M5, ctx.m5_ma_up, ctx.m5_ma_down);

    // M1 structure (last closed candle, shift 1)
    MqlRates r[1];

    if (CopyRates(_Symbol, PERIOD_M1, 1, 1, r) > 0)
    {
        double range = r[0].high - r[0].low;

        if (range > 0.0)
        {
            ctx.m1_available  = true;
            ctx.m1_body_ratio = MathAbs(r[0].close - r[0].open) / range;
            ctx.m1_upper_wick = (r[0].high - MathMax(r[0].open, r[0].close)) / range;
            ctx.m1_lower_wick = (MathMin(r[0].open, r[0].close) - r[0].low) / range;
            ctx.m1_close_loc  = (r[0].close - r[0].low) / range;
            ctx.m1_bullish    = (r[0].close > r[0].open);
            ctx.m1_bearish    = (r[0].close < r[0].open);
        }
    }

    // M5 setup (last closed candle, shift 1)
    if (CopyRates(_Symbol, PERIOD_M5, 1, 1, r) > 0)
    {
        double range = r[0].high - r[0].low;

        if (range > 0.0)
        {
            ctx.m5_body_ratio = MathAbs(r[0].close - r[0].open) / range;
            ctx.m5_close_loc  = (r[0].close - r[0].low) / range;
        }

        ctx.m5_setup_available = true;
        ctx.m5_bullish         = (r[0].close > r[0].open);
        ctx.m5_bearish         = (r[0].close < r[0].open);
    }

    // Time facts
    MqlDateTime dt;
    TimeToStruct(tick.time, dt);

    ctx.hour_of_day = (double)dt.hour;
    ctx.day_of_week = (double)dt.day_of_week;

    return (true);
}

//+------------------------------------------------------------------+
//| LOCAL DECISION ENGINE (weighted, explainable score)              |
//+------------------------------------------------------------------+
double AIBridge_LocalScore(const AIBridgeContext &ctx, string &reasons[])
{
    ArrayResize(reasons, 0);

    double score = 0.0;
    double w     = 0.0;

    // 1) MTF alignment (weight 0.20)
    int aligned = 0;
    int used    = 0;

    if (ctx.h1_available)
    {
        used++;
        if (ctx.order_type == ORDER_TYPE_BUY ? ctx.h1_up : ctx.h1_down)
            aligned++;
    }

    if (ctx.m15_available)
    {
        used++;
        if (ctx.order_type == ORDER_TYPE_BUY ? ctx.m15_up : ctx.m15_down)
            aligned++;
    }

    if (ctx.m5_ma_available)
    {
        used++;
        if (ctx.order_type == ORDER_TYPE_BUY ? ctx.m5_ma_up : ctx.m5_ma_down)
            aligned++;
    }

    double factor_mtf = (used > 0) ? (double)aligned / (double)used : 0.5;
    score += 0.20 * factor_mtf;
    w      += 0.20;

    if (used > 0)
    {
        if (aligned == used)
            AIBridge_ArrayPushString(reasons, "MTF aligned " + IntegerToString(aligned) + "/" + IntegerToString(used));
        else if (aligned == 0)
            AIBridge_ArrayPushString(reasons, "MTF AGAINST " + IntegerToString(aligned) + "/" + IntegerToString(used));
        else
            AIBridge_ArrayPushString(reasons, "MTF partial " + IntegerToString(aligned) + "/" + IntegerToString(used));
    }
    else
        AIBridge_ArrayPushString(reasons, "MTF n/a");

    // 2) VWAP deviation Z (weight 0.13)
    double factor_z = (ctx.std_dev > 0.0) ? AIBridge_Clamp01(ctx.deviation_z / 2.0) : 0.5;
    score += 0.13 * factor_z;
    w      += 0.13;
    AIBridge_ArrayPushString(reasons, StringFormat("Z=%.2f", ctx.deviation_z));

    // 3) Sweep depth vs M1 ATR (weight 0.13)
    double ref_depth = (ctx.m1_atr_pips > 0.0) ? ctx.m1_atr_pips * 0.6 : 3.0;
    if (ref_depth <= 0.0)
        ref_depth = 1.0;

    double factor_depth = AIBridge_Clamp01(ctx.sweep_depth_pips / ref_depth);
    score += 0.13 * factor_depth;
    w      += 0.13;
    AIBridge_ArrayPushString(reasons, StringFormat("Sweep=%.1fp", ctx.sweep_depth_pips));

    // 4) Snapback confirmation (weight 0.13)
    double req_snap    = MathMax(0.1, InpSnapbackPips);
    double factor_snap = AIBridge_Clamp01(ctx.snapback_pips / req_snap);
    score += 0.13 * factor_snap;
    w      += 0.13;
    AIBridge_ArrayPushString(reasons, StringFormat("Snap=%.1fp/%.1fp", ctx.snapback_pips, req_snap));

    // 5) Tick velocity (weight 0.08)
    double factor_vel = ctx.high_velocity ? 1.0 : 0.3;
    score += 0.08 * factor_vel;
    w      += 0.08;
    AIBridge_ArrayPushString(reasons, ctx.high_velocity ? "Vel=high" : "Vel=low");

    // 6) M1 structure quality (weight 0.15)
    double factor_m1 = 0.5;

    if (ctx.m1_available)
    {
        int sub = 0;
        int n   = 0;

        if (ctx.order_type == ORDER_TYPE_SELL)
        {
            n++;
            if (ctx.m1_upper_wick >= InpMinWickRatio)
                sub++;

            if (InpMinBodyRatio > 0.0)
            {
                n++;
                if (ctx.m1_body_ratio >= InpMinBodyRatio)
                    sub++;
            }

            if (InpRequireCandleBias)
            {
                n++;
                if (ctx.m1_bearish)
                    sub++;
            }

            if (InpRequireCloseLocation)
            {
                n++;
                if ((1.0 - ctx.m1_close_loc) >= InpMinCloseLocation)
                    sub++;
            }
        }
        else
        {
            n++;
            if (ctx.m1_lower_wick >= InpMinWickRatio)
                sub++;

            if (InpMinBodyRatio > 0.0)
            {
                n++;
                if (ctx.m1_body_ratio >= InpMinBodyRatio)
                    sub++;
            }

            if (InpRequireCandleBias)
            {
                n++;
                if (ctx.m1_bullish)
                    sub++;
            }

            if (InpRequireCloseLocation)
            {
                n++;
                if (ctx.m1_close_loc >= InpMinCloseLocation)
                    sub++;
            }
        }

        factor_m1 = (n > 0) ? (double)sub / (double)n : 0.5;
    }

    score += 0.15 * factor_m1;
    w      += 0.15;
    AIBridge_ArrayPushString(reasons, StringFormat("M1=%.2f", factor_m1));

    // 7) M1 ATR regime (weight 0.05)
    double factor_atr = 1.0;

    if (ctx.m1_atr_pips <= 0.0)
        factor_atr = 0.0;
    else
    {
        if (ctx.m1_atr_pips < InpMinM1ATRPips)
            factor_atr = 0.5 * ctx.m1_atr_pips / MathMax(0.01, InpMinM1ATRPips);
        else if (InpMaxM1ATRPips > 0.0 && ctx.m1_atr_pips > InpMaxM1ATRPips)
            factor_atr = 0.5;
    }

    score += 0.05 * factor_atr;
    w      += 0.05;
    AIBridge_ArrayPushString(reasons, StringFormat("ATR=%.1fp", ctx.m1_atr_pips));

    // 8) Spread quality (weight 0.05)
    double factor_spread = 1.0;

    if (InpMaxSpreadPips > 0.0)
        factor_spread = AIBridge_Clamp01(1.0 - ctx.spread_pips / InpMaxSpreadPips);

    score += 0.05 * factor_spread;
    w      += 0.05;
    AIBridge_ArrayPushString(reasons, StringFormat("Spr=%.1fp", ctx.spread_pips));

    // 9) Session quality (weight 0.05) - server time
    double factor_session = (ctx.hour_of_day >= 7.0 && ctx.hour_of_day <= 16.0) ? 1.0 : 0.5;
    score += 0.05 * factor_session;
    w      += 0.05;

    // Normalize and cap
    if (w > 0.0)
        score /= w;

    score = AIBridge_Clamp01(score);
    score = MathMin(score, InpLocalMaxScore);

    AIBridge_ArrayPushString(reasons, StringFormat("Score=%.2f", score));

    return (score);
}

//+------------------------------------------------------------------+
//| WEB AI CALL (OpenAI-compatible)                                   |
//+------------------------------------------------------------------+
bool AIBridge_WebCall(
    const AIBridgeContext &ctx,
    double &confidence,
    ENUM_AI_VERDICT &verdict,
    string &reason)
{
    confidence = 0.0;
    verdict    = AI_VERDICT_WAIT;
    reason     = "";

    if (StringLen(InpAIEndpoint) < 8)
        return (false);

    // Minimum interval between web calls (responsiveness protection)
    if (g_ai_last_call > 0)
    {
        long elapsed_ms = (long)(TimeCurrent() - g_ai_last_call) * 1000;

        if (elapsed_ms < (long)InpAIWebIntervalMs)
            return (false);
    }

    // Circuit breaker
    if (g_ai_consecutive_failures >= InpAICircuitFailures)
    {
        if (TimeCurrent() < g_ai_circuit_until)
            return (false);

        g_ai_consecutive_failures = 0; // cooldown over, try again
    }

    string payload = AIBridge_BuildPayload(ctx);

    char data[];
    int len = StringToCharArray(payload, data, 0, StringLen(payload), CP_UTF8);

    if (len <= 0)
        return (false);

    string headers = "Content-Type: application/json\r\n";
    string key     = AIBridge_GetKey();

    if (StringLen(key) > 0)
        headers += "Authorization: Bearer " + key + "\r\n";

    int retries = MathMax(0, InpAIMaxRetries);

    for (int attempt = 0; attempt <= retries; attempt++)
    {
        char result[];
        string result_headers = "";

        ResetLastError();
        g_ai_last_call = TimeCurrent();

        int code = WebRequest("POST", InpAIEndpoint, headers, InpAITimeoutMs,
                              data, result, result_headers);

        if (code != -1)
        {
            string body = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
            g_ai_consecutive_failures = 0;

            return (AIBridge_ParseResponse(body, confidence, verdict, reason));
        }

        if (InpAILogDecisions)
        {
            PrintFormat("[AI] WebRequest attempt %d/%d failed | Error=%d",
                        attempt + 1, retries + 1, GetLastError());
        }
    }

    g_ai_consecutive_failures++;

    if (g_ai_consecutive_failures >= InpAICircuitFailures)
        g_ai_circuit_until = TimeCurrent() + InpAICircuitCooldownSec;

    return (false);
}

//+------------------------------------------------------------------+
//| BUILD REQUEST PAYLOAD                                             |
//+------------------------------------------------------------------+
string AIBridge_BuildPayload(const AIBridgeContext &ctx)
{
    string sys = "You are a factual XAUUSD intraday microstructure analyst. ";
    sys += "You receive live measured facts from a tick-level engine. ";
    sys += "Decide objectively using ONLY these facts. ";
    sys += "Respond ONLY with strict JSON: ";
    sys += "{\"decision\":\"BUY\" or \"SELL\" or \"WAIT\",";
    sys += "\"confidence\":0.0..1.0,\"reason\":\"max 60 chars\"}. ";
    sys += "Use WAIT unless facts strongly support the direction.";

    string payload = "{";
    payload += "\"model\":\"" + AIBridge_JsonEscape(InpAIModel) + "\",";
    payload += "\"temperature\":0,";

    if (InpAIUseJSONMode)
        payload += "\"response_format\":{\"type\":\"json_object\"},";

    payload += "\"messages\":[";
    payload += "{\"role\":\"system\",\"content\":\"" + AIBridge_JsonEscape(sys) + "\"},";
    payload += AIBridge_BuildFactsMessage(ctx);
    payload += "]}";

    return (payload);
}

//+------------------------------------------------------------------+
//| BUILD FACTS MESSAGE (user content = escaped JSON facts)           |
//+------------------------------------------------------------------+
string AIBridge_BuildFactsMessage(const AIBridgeContext &ctx)
{
    string f = "{";
    f += "\"symbol\":\"" + _Symbol + "\",";
    f += "\"time_utc\":\"" + TimeToString(ctx.time, TIME_DATE | TIME_SECONDS) + "\",";
    f += "\"hour_utc\":" + DoubleToString(ctx.hour_of_day, 0) + ",";
    f += "\"day_of_week\":" + DoubleToString(ctx.day_of_week, 0) + ",";
    f += "\"order_type\":\"" + AIBridge_OrderTypeStr(ctx.order_type) + "\",";
    f += "\"entry_price\":" + DoubleToString(ctx.price, _Digits) + ",";
    f += "\"bid\":" + DoubleToString(ctx.bid, _Digits) + ",";
    f += "\"ask\":" + DoubleToString(ctx.ask, _Digits) + ",";
    f += "\"spread_pips\":" + DoubleToString(ctx.spread_pips, 2) + ",";
    f += "\"max_spread_pips\":" + DoubleToString(InpMaxSpreadPips, 1) + ",";
    f += "\"vwap\":" + DoubleToString(ctx.vwap, _Digits) + ",";
    f += "\"std_dev\":" + DoubleToString(ctx.std_dev, _Digits) + ",";
    f += "\"deviation_z\":" + DoubleToString(ctx.deviation_z, 2) + ",";
    f += "\"sweep_depth_pips\":" + DoubleToString(ctx.sweep_depth_pips, 2) + ",";
    f += "\"snapback_pips\":" + DoubleToString(ctx.snapback_pips, 2) + ",";
    f += "\"min_snapback_pips\":" + DoubleToString(InpSnapbackPips, 2) + ",";
    f += "\"high_velocity\":" + (ctx.high_velocity ? "true" : "false") + ",";
    f += "\"velocity_window_ms\":" + DoubleToString((double)InpVelocityWindowMs, 0) + ",";
    f += "\"m1_atr_pips\":" + DoubleToString(ctx.m1_atr_pips, 2) + ",";
    f += "\"m1_structure\":{";
    f += "\"body_ratio\":" + DoubleToString(ctx.m1_body_ratio, 3) + ",";
    f += "\"upper_wick_ratio\":" + DoubleToString(ctx.m1_upper_wick, 3) + ",";
    f += "\"lower_wick_ratio\":" + DoubleToString(ctx.m1_lower_wick, 3) + ",";
    f += "\"close_location\":" + DoubleToString(ctx.m1_close_loc, 3) + ",";
    f += "\"bullish\":" + (ctx.m1_bullish ? "true" : "false") + ",";
    f += "\"bearish\":" + (ctx.m1_bearish ? "true" : "false") + "},";
    f += "\"mtf\":{";
    f += "\"h1_up\":" + (ctx.h1_up ? "true" : "false") + ",";
    f += "\"h1_down\":" + (ctx.h1_down ? "true" : "false") + ",";
    f += "\"m15_up\":" + (ctx.m15_up ? "true" : "false") + ",";
    f += "\"m15_down\":" + (ctx.m15_down ? "true" : "false") + ",";
    f += "\"m5_up\":" + (ctx.m5_ma_up ? "true" : "false") + ",";
    f += "\"m5_down\":" + (ctx.m5_ma_down ? "true" : "false") + "},";
    f += "\"m5_setup\":{";
    f += "\"bullish\":" + (ctx.m5_bullish ? "true" : "false") + ",";
    f += "\"bearish\":" + (ctx.m5_bearish ? "true" : "false") + "}";
    f += "}";

    return ("{\"role\":\"user\",\"content\":\"" + AIBridge_JsonEscape(f) + "\"}");
}

//+------------------------------------------------------------------+
//| PARSE AI RESPONSE                                                 |
//+------------------------------------------------------------------+
bool AIBridge_ParseResponse(
    string body,
    double &confidence,
    ENUM_AI_VERDICT &verdict,
    string &reason)
{
    confidence = 0.0;
    verdict    = AI_VERDICT_WAIT;
    reason     = "";

    string rest;

    // Direct JSON (some endpoints) or nested inside "content"
    bool direct = AIBridge_JsonFindValue(body, "decision", rest);

    string json = body;

    if (!direct)
    {
        string content = AIBridge_JsonGetString(body, "content");

        if (StringLen(content) == 0)
            return (false);

        json = content;

        if (!AIBridge_JsonFindValue(json, "decision", rest))
            return (false);
    }

    string decision = AIBridge_JsonGetString(json, "decision");
    StringToUpper(decision);

    if (decision == "BUY")
        verdict = AI_VERDICT_BUY;
    else if (decision == "SELL")
        verdict = AI_VERDICT_SELL;
    else
        verdict = AI_VERDICT_WAIT;

    confidence = AIBridge_Clamp01(AIBridge_JsonGetDouble(json, "confidence"));
    reason     = AIBridge_JsonGetString(json, "reason");

    return (true);
}

//+------------------------------------------------------------------+
//| FALLBACK POLICY                                                   |
//+------------------------------------------------------------------+
bool AIBridge_ApplyFallback(double local_score, ENUM_AI_VERDICT local_verdict)
{
    if (InpAIFallback == AI_FB_BLOCK)
        return (false);

    // AI_FB_ALLOW and AI_FB_LOCAL both rely on the local engine verdict
    return (local_verdict != AI_VERDICT_WAIT);
}

//+------------------------------------------------------------------+
//| JSON HELPERS                                                      |
//+------------------------------------------------------------------+
string AIBridge_JsonEscape(string s)
{
    string out = "";
    int n = StringLen(s);

    for (int i = 0; i < n; i++)
    {
        ushort c = StringGetCharacter(s, i);

        if (c == '"')
            out += "\\\"";
        else if (c == '\\')
            out += "\\\\";
        else if (c == '\n')
            out += "\\n";
        else if (c == '\r')
            out += "\\r";
        else if (c == '\t')
            out += "\\t";
        else
            out += ShortToString(c);
    }

    return (out);
}

// Finds the LAST occurrence of "key" and returns the text after the colon
bool AIBridge_JsonFindValue(string json, string key, string &out)
{
    string needle = "\"" + key + "\"";

    int pos  = -1;
    int from = 0;
    int found = StringFind(json, needle, from);

    while (found >= 0)
    {
        pos   = found;
        from  = found + 1;
        found = StringFind(json, needle, from);
    }

    if (pos < 0)
        return (false);

    int p = pos + StringLen(needle);
    int n = StringLen(json);

    while (p < n && StringGetCharacter(json, p) == ' ')
        p++;

    if (p >= n || StringGetCharacter(json, p) != ':')
        return (false);

    p++;

    while (p < n && StringGetCharacter(json, p) == ' ')
        p++;

    if (p >= n)
        return (false);

    out = StringSubstr(json, p);

    return (true);
}

string AIBridge_JsonGetString(string json, string key)
{
    string rest;

    if (!AIBridge_JsonFindValue(json, key, rest))
        return ("");

    int n = StringLen(rest);

    if (n == 0 || StringGetCharacter(rest, 0) != '"')
        return ("");

    string result = "";
    int i = 1;

    while (i < n)
    {
        ushort c = StringGetCharacter(rest, i);

        if (c == '"')
            break;

        if (c == '\\' && i + 1 < n)
        {
            ushort c2 = StringGetCharacter(rest, i + 1);

            if (c2 == '"')
            {
                result += "\"";
                i += 2;
                continue;
            }

            if (c2 == '\\')
            {
                result += "\\";
                i += 2;
                continue;
            }

            if (c2 == 'n')
            {
                result += "\n";
                i += 2;
                continue;
            }

            if (c2 == 'r')
            {
                result += "\r";
                i += 2;
                continue;
            }

            if (c2 == 't')
            {
                result += "\t";
                i += 2;
                continue;
            }

            if (c2 == 'u' && i + 5 < n)
            {
                result += StringSubstr(rest, i, 6);
                i += 6;
                continue;
            }

            result += ShortToString(c2);
            i += 2;
            continue;
        }

        result += ShortToString(c);
        i++;
    }

    return (result);
}

double AIBridge_JsonGetDouble(string json, string key)
{
    string rest;

    if (!AIBridge_JsonFindValue(json, key, rest))
        return (0.0);

    int n = StringLen(rest);

    if (n == 0)
        return (0.0);

    string num = "";
    int i = 0;

    while (i < n)
    {
        ushort c = StringGetCharacter(rest, i);

        if ((c >= '0' && c <= '9') || c == '-' || c == '+' || c == '.' ||
            c == 'e' || c == 'E')
        {
            num += ShortToString(c);
            i++;
        }
        else
            break;
    }

    if (num == "")
        return (0.0);

    return (StringToDouble(num));
}

//+------------------------------------------------------------------+
//| MISC HELPERS                                                      |
//+------------------------------------------------------------------+
void AIBridge_ArrayPushString(string &arr[], string value)
{
    int n = ArraySize(arr);
    ArrayResize(arr, n + 1);
    arr[n] = value;
}

double AIBridge_Clamp01(double v)
{
    if (v < 0.0)
        return (0.0);
    if (v > 1.0)
        return (1.0);
    return (v);
}

double AIBridge_GetPipMultiplier()
{
    int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
    return ((digits == 3 || digits == 5) ? 10.0 : 1.0);
}

//+------------------------------------------------------------------+
//| Get ATR Pips                                                     |
//+------------------------------------------------------------------+
double AIBridge_ATRPips(int in_handle_atr_m1)   // <-- Diubah
{
    if (in_handle_atr_m1 == INVALID_HANDLE)
        return (0.0);

    double atr[1];

    if (CopyBuffer(in_handle_atr_m1, 0, 1, 1, atr) <= 0)
        return (0.0);

    return (atr[0] / (_Point * AIBridge_GetPipMultiplier()));
}

bool AIBridge_GetMATrend(int ma_handle, ENUM_TIMEFRAMES tf, bool &up, bool &down)
{
    up   = false;
    down = false;

    if (ma_handle == INVALID_HANDLE)
        return (false);

    double ma[1];

    if (CopyBuffer(ma_handle, 0, 1, 1, ma) <= 0)
        return (false);

    MqlRates r[1];

    if (CopyRates(_Symbol, tf, 1, 1, r) <= 0)
        return (false);

    up   = (r[0].close > ma[0]);
    down = (r[0].close < ma[0]);

    return (true);
}

string AIBridge_OrderTypeStr(ENUM_ORDER_TYPE type)
{
    if (type == ORDER_TYPE_BUY)
        return ("BUY");

    if (type == ORDER_TYPE_SELL)
        return ("SELL");

    return ("WAIT");
}

string AIBridge_VerdictName(ENUM_AI_VERDICT verdict)
{
    if (verdict == AI_VERDICT_BUY)
        return ("BUY");

    if (verdict == AI_VERDICT_SELL)
        return ("SELL");

    return ("WAIT");
}

string AIBridge_ModeName(ENUM_AI_MODE mode)
{
    if (mode == AI_MODE_OFF)
        return ("OFF");

    if (mode == AI_MODE_LOCAL)
        return ("LOCAL");

    if (mode == AI_MODE_WEB)
        return ("WEB");

    return ("HYBRID");
}

string AIBridge_GetKey()
{
    return (g_ai_key);
}

bool AIBridge_ReadKeyFromFile(string &key)
{
    key = "";

    int h = FileOpen(InpAIKeyFile, FILE_READ | FILE_TXT | FILE_ANSI);

    if (h == INVALID_HANDLE)
        return (false);

    string content = FileReadString(h);
    FileClose(h);

    StringReplace(content, "\r", "");
    StringReplace(content, "\n", "");
    StringTrimLeft(content);
    StringTrimRight(content);

    if (StringLen(content) == 0)
        return (false);

    key = content;

    return (true);
}

#endif // AIBRIDGE_MQH
