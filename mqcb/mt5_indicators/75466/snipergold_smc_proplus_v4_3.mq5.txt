//+------------------------------------------------------------------+
//|                                       SniperGold_SMC_ProPlus.mq5 |
//|     Institutional Smart Money Concepts (SMC) Suite               |
//|  Internal/Swing Structure · Volume OB · MTF FVG · EQH/EQL ·      |
//|  Liquidity Grabs · Premium/Discount · MTF Levels · Confluence ·  |
//|  Candle Coloring · Alerts · Bias Dashboard                       |
//|                                   Copyright Waseem Shahrukh 2026 |
//+------------------------------------------------------------------+
#property copyright "Waseem Shahrukh"
#property version   "4.30"
#property description "SniperGold SMC Pro+ v4.2 : sweeps on internal pivots (fired), structural HTF trend, order flow delta proxy leg, non repaint (closed bar lock), 3 TF top down (TF1->TF2->TF3->chart), mandatory Sweep->CHoCH->OB/FVG gate, proximity-filtered signals, volume OB, MTF FVG, EQH/EQL, premium/discount, dashboard"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_label1  "Bias Candles"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrGray,clrLimeGreen,clrTomato

//==================================================================
//                            INPUTS
//==================================================================
input group "===== GENERAL ====="
input int      InpLookbackBars     = 600;        // History bars to analyze
input bool     InpPresentMode       = false;     // Present mode (latest only for swing points)

input group "===== INTERNAL STRUCTURE ====="
input bool     InpShowInternal      = true;      // Show internal structure
input int      InpInternalLen        = 5;        // Internal pivot length

input group "===== SWING STRUCTURE ====="
input bool     InpShowSwing          = true;     // Show swing structure
input int      InpSwingLen           = 50;       // Swing pivot length
input bool     InpShowSwingPoints    = true;     // Show HH/HL/LH/LL
input bool     InpShowStrongWeak     = true;     // Show Strong/Weak H-L

input group "===== ORDER BLOCKS ====="
input bool     InpShowInternalOB     = true;     // Show internal OBs
input int      InpInternalOBCount    = 5;        // Internal OBs
input bool     InpShowSwingOB         = true;    // Show swing OBs
input int      InpSwingOBCount        = 5;       // Swing OBs
input bool     InpVolumeOB            = true;    // Volume-weighted OB selection

input group "===== FAIR VALUE GAPS ====="
input bool     InpShowFVG            = true;     // Show FVG
input bool     InpFVGAutoThreshold   = true;     // Auto threshold (filter noise)
input int      InpFVGCount           = 6;        // FVGs to display
input ENUM_TIMEFRAMES InpFVGTF        = PERIOD_CURRENT; // FVG timeframe (HTF projects down)

input group "===== EQUAL HIGHS / LOWS ====="
input bool     InpShowEQ             = true;     // Show EQH/EQL
input int      InpEQBarsConfirm      = 3;        // Bars confirmation
input double   InpEQThreshold        = 0.10;     // Threshold (x ATR)

input group "===== LIQUIDITY ====="
input bool     InpShowLiqLevels      = true;     // Mark resting liquidity levels (BSL/SSL)
input int      InpLiqCount           = 3;        // Liquidity levels per side (3-4 main)
input bool     InpLiquidityGrabs     = true;     // Show liquidity-sweep arrows
input int      InpGrabWindow         = 8;        // Bars after pivot to detect sweep
input color    InpLiqCol             = C'53,121,246'; // Liquidity line color

input group "===== CONFLUENCE ====="
input bool     InpConfluenceFilter   = true;     // Internal must align with swing trend

input group "===== PREMIUM / DISCOUNT ====="
input bool     InpShowPD             = true;     // Show Premium/Eq/Discount
input double   InpPremiumPct         = 8.0;      // Premium & Discount band height (%)
input double   InpEquilPct           = 4.0;      // Equilibrium band height (%)

input group "===== MTF HIGHS & LOWS ====="
input bool     InpShowDaily          = true;     // Previous Day H/L
input bool     InpShowWeekly         = true;     // Previous Week H/L
input bool     InpShowMonthly        = false;    // Previous Month H/L

input group "===== MULTI-TIMEFRAME (TOP-DOWN: TF1 -> TF2 -> TF3 -> chart) ====="
input ENUM_TIMEFRAMES InpHTF1        = PERIOD_D1;  // HTF #1 directional bias (master / highest)
input ENUM_TIMEFRAMES InpHTF2        = PERIOD_H4;  // HTF #2 intermediate bias
input ENUM_TIMEFRAMES InpHTF3        = PERIOD_H1;  // HTF #3 confirmation bias
input bool     InpRequireHTFAlign     = true;      // All 3 HTFs must agree to allow a signal
// Entry execution = current chart. Run this indicator on M15.

input group "===== TRADE SIGNALS ====="
input bool     InpShowSignals        = true;     // Show BUY/SELL setup + Entry/SL/TP (Trade Setup)
input int      InpSignalThreshold    = 70;       // Min confluence % to fire a signal
input double   InpSLBufferATR        = 0.50;     // SL buffer beyond OB (x ATR)
input bool     InpSignalAlert        = true;     // Alert when a new BUY/SELL forms
input group "===== SETUP SEQUENCE (institutional gate) ====="
input bool     InpRequireSweep        = true;    // Require a liquidity sweep before entry
input bool     InpRequireCHoCH        = true;    // Require a CHoCH after the sweep
input bool     InpEntryOnFVGorOB      = true;    // Entry must tap a fresh OB or FVG
input int      InpSeqWindow           = 40;      // Max bars: sweep -> CHoCH -> entry must chain within
input double   InpMaxZoneATR          = 6.0;     // Hide pending zone if OB is farther than this (x ATR) from price
input group "===== ORDER FLOW (candle-anatomy proxy) ====="
input bool     InpUseDelta            = true;    // Add delta-proxy confluence (+10) when it agrees with the trade
input int      InpDeltaBars           = 10;      // Recent closed bars used for delta direction

input group "===== ALERTS ====="
input bool     InpAlerts             = true;     // Popup alert on BOS/CHoCH & grabs
input bool     InpPushNotif          = false;    // Push notifications to phone

input group "===== VISUAL ====="
input bool     InpColorCandles       = false;    // Color candles by bias
input bool     InpShowDashboard      = true;     // Show dashboard
input int      InpFontSize           = 9;        // Font size
input string   InpFontName           = "Segoe UI"; // Font

input group "===== COLORS (LuxAlgo style) ====="
input color    InpBull               = C'8,153,129';
input color    InpBear               = C'242,54,69';
input color    InpIntBullOBLine      = C'91,156,246';
input color    InpIntBearOBLine      = C'247,124,128';
input color    InpSwingBullOBLine    = C'24,72,204';
input color    InpSwingBearOBLine    = C'178,40,51';
input color    InpBullFVGLine        = C'0,255,104';
input color    InpBearFVGLine        = C'255,0,8';
input color    InpMTFCol             = C'33,87,243';
input color    InpPremiumLine        = C'242,54,69';
input color    InpEquilLine          = C'178,181,190';
input color    InpDiscountLine       = C'8,153,129';

input group "===== FILL SHADES ====="
input color    InpFillIntBullOB      = C'9,15,28';
input color    InpFillIntBearOB      = C'28,13,15';
input color    InpFillSwingBullOB    = C'8,13,26';
input color    InpFillSwingBearOB    = C'26,9,11';
input color    InpFillBullFVG        = C'7,26,16';
input color    InpFillBearFVG        = C'27,8,10';
input color    InpFillPremium        = C'27,10,12';
input color    InpFillEquil          = C'20,21,24';
input color    InpFillDiscount       = C'7,24,16';

input group "===== PANEL COLORS ====="
input bool     InpPanelTransparent   = true;         // Transparent panels (see chart behind)
input color    InpPanelBG            = C'12,16,22';
input color    InpPanelBorder        = C'40,50,62';
input color    InpTextCol            = clrGainsboro;
input color    InpAccent             = C'33,87,243';

//==================================================================
//                            BUFFERS
//==================================================================
double BufO[],BufH[],BufL[],BufC[],BufCol[];

//==================================================================
//                            STATE
//==================================================================
#define PFX "SGPP_"

struct PivotRec { int bar; double price; bool isHigh; string tag; };
PivotRec g_sp[]; int g_spN=0;
PivotRec g_ip[]; int g_ipN=0;   // INTERNAL pivots (len=5) used for liquidity-sweep detection

struct OBRec { int bar; double top; double bot; bool bull; bool internal; bool mit; };
OBRec g_obs[]; int g_obN=0;

struct FVGRec { int bar; datetime t; double top; double bot; bool bull; bool mit; };
FVGRec g_fvg[]; int g_fvgN=0;

// swing trend timeline (for confluence + candle coloring)
int g_stBar[]; int g_stVal[]; int g_stN=0;

double g_swHigh=0,g_swLow=0; int g_swHighBar=-1,g_swLowBar=-1,g_swTrend=0;
int g_inTrend=0,g_inLastBreak=-1,g_swLastBreak=-1,g_bias=0;

int g_HH=0,g_HL=0,g_LH=0,g_LL=0;
string g_structure="Neutral",g_trend="Range",g_eqPos="Equilibrium",g_liq="Intact";
int g_aiScore=0;
bool g_eqhSwept=false,g_eqlSwept=false;
string g_htfBias="Neutral",g_ltfBias="Neutral";

double g_PDH=0,g_PDL=0,g_PWH=0,g_PWL=0,g_PMH=0,g_PML=0;

double g_atr=0;
datetime g_lastBar=0;
string g_pendingAlert="";

// ---- trade signal state ----
string g_signal="WAIT";
string g_signalNote="No clean SMC setup";
int    g_buyPct=0,g_sellPct=0;
double g_entry=0,g_sl=0,g_tp1=0,g_tp2=0,g_tp3=0,g_rr=0;
bool   g_hasPending=false,g_pendingBuy=false; double g_pendingEntry=0;
string g_lastSignal="";

// ---- 3-TF top-down bias (TF1 master -> TF2 -> TF3) ----
string g_bTF1="Neutral",g_bTF2="Neutral",g_bTF3="Neutral";

// ---- setup-sequence memory (sweep -> CHoCH -> entry) ----
int    g_swpDir=0;   int g_swpBar=-1;   double g_swpLevel=0;   // +1 sell-side swept(bullish intent), -1 buy-side swept(bearish)
int    g_chochDir=0; int g_chochBar=-1;                        // internal CHoCH direction & bar
int    g_lastClosed=0;                                         // last fully-closed bar index used for analysis

// ---- order-flow delta proxy (candle anatomy) ----
int    g_dDir=0; double g_dRecent=0;                           // recent delta sign / magnitude

//==================================================================
//                          INIT / DEINIT
//==================================================================
int OnInit()
{
   IndicatorSetString(INDICATOR_SHORTNAME,"SniperGold SMC Pro+");
   ObjectsDeleteAll(0,PFX);
   g_lastBar=0;

   SetIndexBuffer(0,BufO,INDICATOR_DATA);
   SetIndexBuffer(1,BufH,INDICATOR_DATA);
   SetIndexBuffer(2,BufL,INDICATOR_DATA);
   SetIndexBuffer(3,BufC,INDICATOR_DATA);
   SetIndexBuffer(4,BufCol,INDICATOR_COLOR_INDEX);
   ArraySetAsSeries(BufO,false); ArraySetAsSeries(BufH,false);
   ArraySetAsSeries(BufL,false); ArraySetAsSeries(BufC,false);
   ArraySetAsSeries(BufCol,false);

   PlotIndexSetInteger(0,PLOT_DRAW_TYPE, InpColorCandles?DRAW_COLOR_CANDLES:DRAW_NONE);
   PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,3);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,clrGray);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,InpBull);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,2,InpBear);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0,PFX);
   ChartRedraw();
}

//==================================================================
//                          MAIN
//==================================================================
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &time[],const double &open[],const double &high[],
                const double &low[],const double &close[],const long &tick_volume[],
                const long &volume[],const int &spread[])
{
   if(rates_total < 2*InpSwingLen + 20) return(rates_total);

   ArraySetAsSeries(time,false); ArraySetAsSeries(open,false);
   ArraySetAsSeries(high,false); ArraySetAsSeries(low,false);
   ArraySetAsSeries(close,false); ArraySetAsSeries(tick_volume,false);

   int total=rates_total;
   bool newBar=(time[total-1]!=g_lastBar);

   // CLOSED-BAR LOCK: never analyse the still-forming bar (total-1). All structure,
   // sweeps, CHoCH and signals are evaluated only on fully-closed bars => no repaint.
   int tc=total-1;                       // analysis horizon (forming bar excluded)
   if(tc < 2*InpSwingLen + 20) return(rates_total);
   g_lastClosed=tc-1;

   if(newBar)
   {
      g_lastBar=time[total-1];
      g_pendingAlert="";

      DeleteByPrefix(PFX "ST_"); DeleteByPrefix(PFX "IN_"); DeleteByPrefix(PFX "SP_");
      DeleteByPrefix(PFX "OB_"); DeleteByPrefix(PFX "FVG_"); DeleteByPrefix(PFX "EQ_");
      DeleteByPrefix(PFX "PD_"); DeleteByPrefix(PFX "LV_"); DeleteByPrefix(PFX "SW_");
      DeleteByPrefix(PFX "LG_");
      DeleteByPrefix(PFX "LQL_");
      DeleteByPrefix(PFX "SIG_");

      g_atr=CalcATR(high,low,close,tc,14);
      g_obN=0; ArrayResize(g_obs,0);
      g_fvgN=0; ArrayResize(g_fvg,0);
      g_spN=0; ArrayResize(g_sp,0);
      g_ipN=0; ArrayResize(g_ip,0);
      g_stN=0; ArrayResize(g_stBar,0); ArrayResize(g_stVal,0);
      g_swTrend=0; g_inTrend=0; g_swLastBreak=-1; g_inLastBreak=-1; g_bias=0;
      g_swpDir=0; g_swpBar=-1; g_swpLevel=0; g_chochDir=0; g_chochBar=-1;

      int startBar=MathMax(2*InpSwingLen,tc-InpLookbackBars);

      // SWING first (sets trend timeline + range + swing OBs + swing points)
      ProcessStructure(InpSwingLen,false,time,open,high,low,close,tick_volume,tc,startBar);
      // INTERNAL after (uses confluence vs swing trend; records CHoCH events + internal pivots for sweeps)
      if(InpShowInternal||InpShowInternalOB||InpShowSignals||InpLiquidityGrabs)
         ProcessStructure(InpInternalLen,true,time,open,high,low,close,tick_volume,tc,startBar);

      // responsive bias: direction of whichever structure broke most recently
      g_bias = (g_inLastBreak>=g_swLastBreak && g_inTrend!=0) ? g_inTrend : g_swTrend;
      if(g_bias==0) g_bias = (g_swTrend!=0?g_swTrend:g_inTrend);

      ClassifySwingPoints();
      if(InpShowSwingPoints) DrawSwingPoints(time);

      FilterAndDrawOBs(time,high,low,close,tc);

      if(InpShowFVG) DetectAndDrawFVG(time,high,low,tc,startBar);

      if(InpShowLiqLevels) DrawLiquidityLevels(time,high,low,tc);
      if(InpShowEQ) DetectEQ(time,high,low,tc);
      if(InpLiquidityGrabs) DetectLiquidityGrabs(time,high,low,close,tc);

      if(InpShowPD)         DrawPremiumDiscount(time,tc);
      if(InpShowStrongWeak) DrawStrongWeak(time,tc);

      ComputeMTFLevels(); DrawMTFLevels(time,tc);

      // 3-TF top-down bias: TF1 master, TF2 intermediate, TF3 confirm
      g_bTF1=TFBias(InpHTF1); g_bTF2=TFBias(InpHTF2); g_bTF3=TFBias(InpHTF3);

      // order-flow delta proxy: signed buy/sell pressure over recent CLOSED bars (candle anatomy)
      g_dDir=0; g_dRecent=0;
      if(InpUseDelta)
      {
         double sum=0; int kk=MathMin(InpDeltaBars,tc-3);
         for(int j=tc-1-kk;j<tc-1;j++)
         {
            if(j<1) continue;
            double rng=high[j]-low[j]; if(rng<=0) rng=_Point;
            double body=MathAbs(close[j]-open[j]);
            double uw=high[j]-MathMax(open[j],close[j]);
            double lw=MathMin(open[j],close[j])-low[j];
            double bb,ss; if(close[j]>=open[j]){ bb=body+lw; ss=uw; } else { ss=body+uw; bb=lw; }
            double tt=bb+ss; if(tt<=0) tt=_Point;
            sum += (bb-ss)/tt * (double)tick_volume[j];
         }
         g_dRecent=sum; g_dDir=(sum>0?1:(sum<0?-1:0));
      }
      ComputeContext(close[tc-1]); ComputeAIScore();
      if(InpShowSignals){ ComputeSignal(close[tc-1],high,low,tc); DrawSignalLevels(time,tc); }

      FillCandleBuffers(open,high,low,close,total,startBar);

      // fire one alert per bar
      if(InpAlerts && g_pendingAlert!="")
         Alert(_Symbol+" "+TFToStr(_Period)+": "+g_pendingAlert);
      if(InpPushNotif && g_pendingAlert!="")
         SendNotification(_Symbol+" "+TFToStr(_Period)+": "+g_pendingAlert);

      // alert when a fresh BUY/SELL setup appears
      if(InpSignalAlert && (g_signal=="BUY"||g_signal=="SELL") && g_signal!=g_lastSignal)
      {
         string sm=_Symbol+" "+TFToStr(_Period)+": "+g_signal+" setup "+
                   "("+IntegerToString(g_signal=="BUY"?g_buyPct:g_sellPct)+"%)  Entry "+
                   DoubleToString(g_entry,_Digits)+"  SL "+DoubleToString(g_sl,_Digits)+
                   "  TP "+DoubleToString(g_tp2,_Digits);
         if(InpAlerts) Alert(sm);
         if(InpPushNotif) SendNotification(sm);
      }
      g_lastSignal=g_signal;
   }

   if(InpShowDashboard) DrawDashboard();
   ChartRedraw();
   return(rates_total);
}

//==================================================================
//          STRUCTURE ENGINE (BOS / CHoCH) + trend timeline
//==================================================================
void ProcessStructure(int len,bool internal,const datetime &time[],const double &open[],
                      const double &high[],const double &low[],const double &close[],
                      const long &vol[],int total,int startBar)
{
   double upTarget=DBL_MAX,dnTarget=-DBL_MAX;
   int upBar=-1,dnBar=-1,trend=0;
   int lastLowBar=-1,lastHighBar=-1;
   double lastLow=0,lastHigh=0;
   int drawIdx=0;
   string pfx=internal?PFX "IN_":PFX "ST_";
   int begin=MathMax(startBar,2*len);

   for(int i=begin;i<total;i++)
   {
      int p=i-len;
      if(p>=len)
      {
         if(IsPivotHigh(high,p,len,total)){ upTarget=high[p]; upBar=p; lastHighBar=p; lastHigh=high[p];
            if(!internal) AddSwingPivot(p,high[p],true); else AddInternalPivot(p,high[p],true); }
         if(IsPivotLow(low,p,len,total)){ dnTarget=low[p]; dnBar=p; lastLowBar=p; lastLow=low[p];
            if(!internal) AddSwingPivot(p,low[p],false); else AddInternalPivot(p,low[p],false); }
      }

      // bullish break
      if(upBar>=0 && close[i]>upTarget)
      {
         bool choch=(trend<0);
         bool allow = !internal || !InpConfluenceFilter || SwingTrendAt(i)>=0;
         if(allow && ((internal&&InpShowInternal)||(!internal&&InpShowSwing)))
            DrawStructLine(pfx+IntegerToString(drawIdx++),time[upBar],upTarget,time[i],
                           choch?"CHoCH":"BOS",InpBull,internal);
         int orig=(lastLowBar>=0&&lastLowBar<i)?lastLowBar:upBar;
         if(allow) RecordOB(true,internal,orig,i,open,high,low,close,vol);
         trend=1;
         if(!internal){ g_swTrend=1; g_swLastBreak=i; AddTrend(i,1); }
         else         { g_inTrend=1; g_inLastBreak=i; if(allow&&choch){ g_chochDir=1; g_chochBar=i; } }
         if(allow && i>=total-1) g_pendingAlert=(internal?"Internal ":"Swing ")+(choch?"CHoCH":"BOS")+" (Bullish)";
         upTarget=DBL_MAX; upBar=-1;
      }
      // bearish break
      if(dnBar>=0 && close[i]<dnTarget)
      {
         bool choch=(trend>0);
         bool allow = !internal || !InpConfluenceFilter || SwingTrendAt(i)<=0;
         if(allow && ((internal&&InpShowInternal)||(!internal&&InpShowSwing)))
            DrawStructLine(pfx+IntegerToString(drawIdx++),time[dnBar],dnTarget,time[i],
                           choch?"CHoCH":"BOS",InpBear,internal);
         int orig=(lastHighBar>=0&&lastHighBar<i)?lastHighBar:dnBar;
         if(allow) RecordOB(false,internal,orig,i,open,high,low,close,vol);
         trend=-1;
         if(!internal){ g_swTrend=-1; g_swLastBreak=i; AddTrend(i,-1); }
         else         { g_inTrend=-1; g_inLastBreak=i; if(allow&&choch){ g_chochDir=-1; g_chochBar=i; } }
         if(allow && i>=total-1) g_pendingAlert=(internal?"Internal ":"Swing ")+(choch?"CHoCH":"BOS")+" (Bearish)";
         dnTarget=-DBL_MAX; dnBar=-1;
      }
   }

   if(!internal)
   {
      if(lastHighBar>=0){ g_swHigh=lastHigh; g_swHighBar=lastHighBar; }
      if(lastLowBar>=0){ g_swLow=lastLow; g_swLowBar=lastLowBar; }
   }
}

void AddTrend(int bar,int val)
{
   int n=ArraySize(g_stBar);
   ArrayResize(g_stBar,n+1); ArrayResize(g_stVal,n+1);
   g_stBar[n]=bar; g_stVal[n]=val; g_stN=n+1;
}
int SwingTrendAt(int bar)
{
   int t=0;
   for(int i=0;i<g_stN;i++){ if(g_stBar[i]<=bar) t=g_stVal[i]; else break; }
   return t;
}

bool IsPivotHigh(const double &h[],int idx,int len,int total)
{
   if(idx-len<0||idx+len>=total) return false;
   double v=h[idx];
   for(int k=1;k<=len;k++){ if(h[idx-k]>v) return false; if(h[idx+k]>v) return false; }
   return true;
}
bool IsPivotLow(const double &l[],int idx,int len,int total)
{
   if(idx-len<0||idx+len>=total) return false;
   double v=l[idx];
   for(int k=1;k<=len;k++){ if(l[idx-k]<v) return false; if(l[idx+k]<v) return false; }
   return true;
}

void DrawStructLine(string name,datetime t1,double price,datetime t2,string lbl,color c,bool internal)
{
   ObjectCreate(0,name,OBJ_TREND,0,t1,price,t2,price);
   ObjectSetInteger(0,name,OBJPROP_COLOR,c);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,internal?1:2);
   ObjectSetInteger(0,name,OBJPROP_STYLE,internal?STYLE_DOT:STYLE_SOLID);
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,false);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   CreateText(name+"_t",(datetime)((t1+t2)/2),price+(internal?12:22)*_Point,lbl,c,
              internal?InpFontSize-1:InpFontSize,ANCHOR_LOWER);
}

//==================================================================
//                 SWING POINTS (HH/HL/LH/LL)
//==================================================================
void AddSwingPivot(int bar,double price,bool isHigh)
{
   int n=ArraySize(g_sp);
   ArrayResize(g_sp,n+1);
   g_sp[n].bar=bar; g_sp[n].price=price; g_sp[n].isHigh=isHigh; g_sp[n].tag="";
   g_spN=n+1;
}
void AddInternalPivot(int bar,double price,bool isHigh)
{
   int n=ArraySize(g_ip);
   ArrayResize(g_ip,n+1);
   g_ip[n].bar=bar; g_ip[n].price=price; g_ip[n].isHigh=isHigh; g_ip[n].tag="";
   g_ipN=n+1;
}
void ClassifySwingPoints()
{
   g_HH=0;g_HL=0;g_LH=0;g_LL=0;
   double lastH=0,lastL=0; bool haveH=false,haveL=false;
   for(int i=0;i<g_spN;i++)
   {
      if(g_sp[i].isHigh){
         if(!haveH||g_sp[i].price>lastH){ g_sp[i].tag="HH"; g_HH++; } else { g_sp[i].tag="LH"; g_LH++; }
         lastH=g_sp[i].price; haveH=true;
      } else {
         if(!haveL||g_sp[i].price>lastL){ g_sp[i].tag="HL"; g_HL++; } else { g_sp[i].tag="LL"; g_LL++; }
         lastL=g_sp[i].price; haveL=true;
      }
   }
}
void DrawSwingPoints(const datetime &time[])
{
   int from=InpPresentMode?MathMax(0,g_spN-6):0;
   for(int i=from;i<g_spN;i++)
   {
      string nm=PFX "SP_"+IntegerToString(i);
      color c=(g_sp[i].tag=="HH"||g_sp[i].tag=="HL")?InpBull:InpBear;
      double y=g_sp[i].isHigh?g_sp[i].price+28*_Point:g_sp[i].price-28*_Point;
      CreateText(nm,time[g_sp[i].bar],y,g_sp[i].tag,c,InpFontSize,g_sp[i].isHigh?ANCHOR_LOWER:ANCHOR_UPPER);
   }
}

//==================================================================
//                ORDER BLOCKS (volume-weighted)
//==================================================================
void RecordOB(bool bull,bool internal,int fromBar,int toBar,const double &open[],
              const double &high[],const double &low[],const double &close[],const long &vol[])
{
   int found=-1; long bestVol=-1;
   for(int b=toBar;b>=fromBar;b--)
   {
      bool oppo = bull ? (close[b]<open[b]) : (close[b]>open[b]);
      if(!oppo) continue;
      if(InpVolumeOB)
      {
         if((long)vol[b]>bestVol){ bestVol=(long)vol[b]; found=b; }   // highest-volume opposite candle
      }
      else { found=b; break; }                                        // last opposite candle
   }
   if(found<0) return;
   if((high[found]-low[found])<0.15*g_atr) return;

   int n=ArraySize(g_obs);
   ArrayResize(g_obs,n+1);
   g_obs[n].bar=found; g_obs[n].top=high[found]; g_obs[n].bot=low[found];
   g_obs[n].bull=bull; g_obs[n].internal=internal; g_obs[n].mit=false;
   g_obN=n+1;
}
void FilterAndDrawOBs(const datetime &time[],const double &high[],const double &low[],
                      const double &close[],int total)
{
   for(int i=0;i<g_obN;i++)
      for(int b=g_obs[i].bar+1;b<total;b++)
      {
         if(g_obs[i].bull&&close[b]<g_obs[i].bot){ g_obs[i].mit=true; break; }
         if(!g_obs[i].bull&&close[b]>g_obs[i].top){ g_obs[i].mit=true; break; }
      }
   datetime tEnd=TimeShiftForward(time[total-1],3); int idx=0;
   DrawOBSet(true,true,InpShowInternalOB?InpInternalOBCount:0,time,tEnd,idx);
   DrawOBSet(false,true,InpShowInternalOB?InpInternalOBCount:0,time,tEnd,idx);
   DrawOBSet(true,false,InpShowSwingOB?InpSwingOBCount:0,time,tEnd,idx);
   DrawOBSet(false,false,InpShowSwingOB?InpSwingOBCount:0,time,tEnd,idx);
}
void DrawOBSet(bool bull,bool internal,int maxCount,const datetime &time[],datetime tEnd,int &idx)
{
   if(maxCount<=0) return;
   int drawn=0;
   for(int i=g_obN-1;i>=0&&drawn<maxCount;i--)
   {
      if(g_obs[i].bull!=bull||g_obs[i].internal!=internal||g_obs[i].mit) continue;
      color line=internal?(bull?InpIntBullOBLine:InpIntBearOBLine):(bull?InpSwingBullOBLine:InpSwingBearOBLine);
      color fill=internal?(bull?InpFillIntBullOB:InpFillIntBearOB):(bull?InpFillSwingBullOB:InpFillSwingBearOB);
      string nm=PFX "OB_"+IntegerToString(idx++);
      DrawBox(nm,time[g_obs[i].bar],g_obs[i].top,tEnd,g_obs[i].bot,fill,line,true);
      CreateText(nm+"_t",time[g_obs[i].bar],(g_obs[i].top+g_obs[i].bot)/2.0,
                 (bull?"Bullish OB ":"Bearish OB ")+"("+TFToStr(_Period)+")",line,InpFontSize-1,ANCHOR_LEFT);
      drawn++;
   }
}

//==================================================================
//                FAIR VALUE GAPS (current or MTF)
//==================================================================
void DetectAndDrawFVG(const datetime &time[],const double &high[],const double &low[],
                      int total,int startBar)
{
   ArrayResize(g_fvg,0); g_fvgN=0;
   double minGap=InpFVGAutoThreshold?0.25*g_atr:0.0;

   if(InpFVGTF==PERIOD_CURRENT || InpFVGTF==_Period)
   {
      for(int i=startBar+2;i<total;i++)
      {
         if(low[i]>high[i-2] && (low[i]-high[i-2])>=minGap) AddFVG(i-1,time[i-1],low[i],high[i-2],true);
         if(high[i]<low[i-2] && (low[i-2]-high[i])>=minGap)  AddFVG(i-1,time[i-1],low[i-2],high[i],false);
      }
   }
   else
   {
      // higher-timeframe FVG projected onto current chart
      MqlRates r[];
      int need=MathMin(400,InpLookbackBars);
      int got=CopyRates(_Symbol,InpFVGTF,0,need,r);
      if(got>3)
      {
         ArraySetAsSeries(r,false);
         double hAvg=0; for(int k=0;k<got;k++) hAvg+=(r[k].high-r[k].low); hAvg/=got;
         double mg=InpFVGAutoThreshold?0.25*hAvg:0.0;
         for(int i=2;i<got;i++)
         {
            if(r[i].low>r[i-2].high && (r[i].low-r[i-2].high)>=mg) AddFVG(-1,r[i-1].time,r[i].low,r[i-2].high,true);
            if(r[i].high<r[i-2].low && (r[i-2].low-r[i].high)>=mg)  AddFVG(-1,r[i-1].time,r[i-2].low,r[i].high,false);
         }
      }
   }

   // mitigation (by current-chart price after the gap time)
   for(int k=0;k<g_fvgN;k++)
   {
      int b=(g_fvg[k].bar>=0)?g_fvg[k].bar+1: BarFromTime(time,total,g_fvg[k].t)+1;
      if(b<1) b=1;
      for(int j=b;j<total;j++)
      {
         if(g_fvg[k].bull&&low[j]<=g_fvg[k].bot){ g_fvg[k].mit=true; break; }
         if(!g_fvg[k].bull&&high[j]>=g_fvg[k].top){ g_fvg[k].mit=true; break; }
      }
   }

   datetime tEnd=TimeShiftForward(time[total-1],3);
   int idx=0,drawn=0;
   for(int i=g_fvgN-1;i>=0&&drawn<InpFVGCount;i--)
   {
      if(g_fvg[i].mit) continue;
      color line=g_fvg[i].bull?InpBullFVGLine:InpBearFVGLine;
      color fill=g_fvg[i].bull?InpFillBullFVG:InpFillBearFVG;
      string nm=PFX "FVG_"+IntegerToString(idx++);
      string tag=(InpFVGTF==PERIOD_CURRENT||InpFVGTF==_Period)?TFToStr(_Period):TFToStr(InpFVGTF);
      DrawBox(nm,g_fvg[i].t,g_fvg[i].top,tEnd,g_fvg[i].bot,fill,line,true);
      CreateText(nm+"_t",g_fvg[i].t,(g_fvg[i].top+g_fvg[i].bot)/2.0,
                 (g_fvg[i].bull?"Bullish FVG ":"Bearish FVG ")+"("+tag+")",line,InpFontSize-1,ANCHOR_LEFT);
      drawn++;
   }
}
void AddFVG(int bar,datetime t,double top,double bot,bool bull)
{
   int n=ArraySize(g_fvg);
   ArrayResize(g_fvg,n+1);
   g_fvg[n].bar=bar; g_fvg[n].t=t; g_fvg[n].top=top; g_fvg[n].bot=bot;
   g_fvg[n].bull=bull; g_fvg[n].mit=false;
   g_fvgN=n+1;
}
int BarFromTime(const datetime &time[],int total,datetime t)
{
   for(int i=total-1;i>=0;i--) if(time[i]<=t) return i;
   return 0;
}

//==================================================================
//                  EQUAL HIGHS / LOWS + SWEEP
//==================================================================
void DetectEQ(const datetime &time[],const double &high[],const double &low[],int total)
{
   g_eqhSwept=false; g_eqlSwept=false;
   double tol=InpEQThreshold*g_atr; int idx=0;
   for(int i=1;i<g_spN;i++)
   {
      if(MathAbs(g_sp[i].bar-g_sp[i-1].bar)<InpEQBarsConfirm) continue;
      if(g_sp[i].isHigh&&g_sp[i-1].isHigh&&MathAbs(g_sp[i].price-g_sp[i-1].price)<=tol)
      {
         DrawEQ(PFX "EQ_"+IntegerToString(idx++),time[g_sp[i-1].bar],g_sp[i-1].price,
                time[g_sp[i].bar],g_sp[i].price,"EQH");
         if(high[total-1]>g_sp[i].price) g_eqhSwept=true;
      }
      if(!g_sp[i].isHigh&&!g_sp[i-1].isHigh&&MathAbs(g_sp[i].price-g_sp[i-1].price)<=tol)
      {
         DrawEQ(PFX "EQ_"+IntegerToString(idx++),time[g_sp[i-1].bar],g_sp[i-1].price,
                time[g_sp[i].bar],g_sp[i].price,"EQL");
         if(low[total-1]<g_sp[i].price) g_eqlSwept=true;
      }
   }
}
void DrawEQ(string name,datetime t1,double p1,datetime t2,double p2,string lbl)
{
   ObjectCreate(0,name,OBJ_TREND,0,t1,p1,t2,p2);
   ObjectSetInteger(0,name,OBJPROP_COLOR,InpAccent);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DASH);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   CreateText(name+"_t",t2,p2,lbl,InpAccent,InpFontSize-1,ANCHOR_LEFT);
}

//==================================================================
//                 LIQUIDITY LEVELS (BSL / SSL)
//==================================================================
void DrawLiquidityLevels(const datetime &time[],const double &high[],const double &low[],int total)
{
   datetime t2=TimeShiftForward(time[total-1],3);
   int hi=0,lo=0;
   for(int i=g_spN-1;i>=0 && (hi<InpLiqCount || lo<InpLiqCount);i--)
   {
      if(g_sp[i].isHigh && hi<InpLiqCount)
      {
         bool swept=false;
         for(int b=g_sp[i].bar+1;b<total;b++) if(high[b]>g_sp[i].price){ swept=true; break; }
         DrawLiqLevel(PFX "LQL_H"+IntegerToString(hi),time[g_sp[i].bar],g_sp[i].price,t2,swept);
         hi++;
      }
      else if(!g_sp[i].isHigh && lo<InpLiqCount)
      {
         bool swept=false;
         for(int b=g_sp[i].bar+1;b<total;b++) if(low[b]<g_sp[i].price){ swept=true; break; }
         DrawLiqLevel(PFX "LQL_L"+IntegerToString(lo),time[g_sp[i].bar],g_sp[i].price,t2,swept);
         lo++;
      }
   }
}

void DrawLiqLevel(string name,datetime t1,double price,datetime t2,bool swept)
{
   ObjectCreate(0,name,OBJ_TREND,0,t1,price,t2,price);
   ObjectSetInteger(0,name,OBJPROP_COLOR,InpLiqCol);
   ObjectSetInteger(0,name,OBJPROP_STYLE,swept?STYLE_DOT:STYLE_DASH);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,swept?1:2);
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,false);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   CreateText(name+"_t",t2,price,swept?"Liquidity (swept)":"Liquidity",InpLiqCol,InpFontSize-1,ANCHOR_LEFT);
}

//==================================================================
//                    LIQUIDITY SWEEP ARROWS
//==================================================================
void DetectLiquidityGrabs(const datetime &time[],const double &high[],const double &low[],
                          const double &close[],int total)
{
   int idx=0;
   for(int s=0;s<g_ipN;s++)
   {
      int p=g_ip[s].bar;
      double lvl=g_ip[s].price;
      int last=MathMin(total-1,p+InpGrabWindow);
      for(int b=p+1;b<=last;b++)
      {
         // bearish grab: wick above an internal high but close back below = buy-side liquidity swept
         if(g_ip[s].isHigh && high[b]>lvl && close[b]<lvl)
         {
            string nm=PFX "LG_"+IntegerToString(idx++);
            ObjectCreate(0,nm,OBJ_ARROW,0,time[b],high[b]+15*_Point);
            ObjectSetInteger(0,nm,OBJPROP_ARROWCODE,234);
            ObjectSetInteger(0,nm,OBJPROP_COLOR,InpBear);
            ObjectSetInteger(0,nm,OBJPROP_WIDTH,1);
            ObjectSetInteger(0,nm,OBJPROP_ANCHOR,ANCHOR_BOTTOM);
            ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,false);
            CreateText(nm+"_t",time[b],high[b]+45*_Point,"Liquidity Sweep",InpBear,InpFontSize-1,ANCHOR_LOWER);
            // mark the swept level
            ObjectCreate(0,nm+"_l",OBJ_TREND,0,time[p],lvl,time[b],lvl);
            ObjectSetInteger(0,nm+"_l",OBJPROP_COLOR,InpBear);
            ObjectSetInteger(0,nm+"_l",OBJPROP_STYLE,STYLE_DOT);
            ObjectSetInteger(0,nm+"_l",OBJPROP_WIDTH,1);
            ObjectSetInteger(0,nm+"_l",OBJPROP_RAY_RIGHT,false);
            ObjectSetInteger(0,nm+"_l",OBJPROP_SELECTABLE,false);
            if(b>=total-1) g_pendingAlert="Liquidity Sweep (Bearish)";
            if(b>g_swpBar){ g_swpBar=b; g_swpDir=-1; g_swpLevel=lvl; }   // buy-side swept -> bearish intent
            break;
         }
         // bullish grab: wick below an internal low but close back above = sell-side liquidity swept
         if(!g_ip[s].isHigh && low[b]<lvl && close[b]>lvl)
         {
            string nm=PFX "LG_"+IntegerToString(idx++);
            ObjectCreate(0,nm,OBJ_ARROW,0,time[b],low[b]-15*_Point);
            ObjectSetInteger(0,nm,OBJPROP_ARROWCODE,233);
            ObjectSetInteger(0,nm,OBJPROP_COLOR,InpBull);
            ObjectSetInteger(0,nm,OBJPROP_WIDTH,1);
            ObjectSetInteger(0,nm,OBJPROP_ANCHOR,ANCHOR_TOP);
            ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,false);
            CreateText(nm+"_t",time[b],low[b]-45*_Point,"Liquidity Sweep",InpBull,InpFontSize-1,ANCHOR_UPPER);
            ObjectCreate(0,nm+"_l",OBJ_TREND,0,time[p],lvl,time[b],lvl);
            ObjectSetInteger(0,nm+"_l",OBJPROP_COLOR,InpBull);
            ObjectSetInteger(0,nm+"_l",OBJPROP_STYLE,STYLE_DOT);
            ObjectSetInteger(0,nm+"_l",OBJPROP_WIDTH,1);
            ObjectSetInteger(0,nm+"_l",OBJPROP_RAY_RIGHT,false);
            ObjectSetInteger(0,nm+"_l",OBJPROP_SELECTABLE,false);
            if(b>=total-1) g_pendingAlert="Liquidity Sweep (Bullish)";
            if(b>g_swpBar){ g_swpBar=b; g_swpDir=1; g_swpLevel=lvl; }    // sell-side swept -> bullish intent
            break;
         }
      }
   }
}

//==================================================================
//             PREMIUM / EQUILIBRIUM / DISCOUNT
//==================================================================
void DrawPremiumDiscount(const datetime &time[],int total)
{
   if(g_swHigh<=0||g_swLow<=0||g_swHigh<=g_swLow) return;
   double rng=g_swHigh-g_swLow;
   double pp=InpPremiumPct/100.0;
   double eqHalf=(InpEquilPct/100.0)/2.0;
   int anchorBar=MathMin(g_swHighBar<0?total-1:g_swHighBar,g_swLowBar<0?total-1:g_swLowBar);
   if(anchorBar<0) anchorBar=MathMax(0,total-80);
   datetime t1=time[anchorBar];
   datetime t2=TimeShiftForward(time[total-1],3);

   DrawBox(PFX "PD_PR",t1,g_swHigh,t2,g_swLow+(1.0-pp)*rng,InpFillPremium,InpPremiumLine,true);
   CreateText(PFX "PD_PRt",t2,g_swHigh-(pp/2.0)*rng,"Premium",InpPremiumLine,InpFontSize-1,ANCHOR_RIGHT);

   DrawBox(PFX "PD_EQ",t1,g_swLow+(0.5+eqHalf)*rng,t2,g_swLow+(0.5-eqHalf)*rng,InpFillEquil,InpEquilLine,true);
   CreateText(PFX "PD_EQt",t2,g_swLow+0.5*rng,"Equilibrium",InpEquilLine,InpFontSize-1,ANCHOR_RIGHT);

   DrawBox(PFX "PD_DC",t1,g_swLow+pp*rng,t2,g_swLow,InpFillDiscount,InpDiscountLine,true);
   CreateText(PFX "PD_DCt",t2,g_swLow+(pp/2.0)*rng,"Discount",InpDiscountLine,InpFontSize-1,ANCHOR_RIGHT);
}
void DrawStrongWeak(const datetime &time[],int total)
{
   if(g_swHigh<=0||g_swLow<=0) return;
   datetime t2=TimeShiftForward(time[total-1],3);
   bool bull=(g_swTrend>=0);
   CreateText(PFX "SW_TOP",t2,g_swHigh,bull?"Weak High":"Strong High",bull?InpBear:InpBull,InpFontSize,ANCHOR_RIGHT_LOWER);
   CreateText(PFX "SW_BOT",t2,g_swLow,bull?"Strong Low":"Weak Low",bull?InpBull:InpBear,InpFontSize,ANCHOR_RIGHT_UPPER);
}

//==================================================================
//                     MTF HIGHS / LOWS
//==================================================================
void ComputeMTFLevels()
{
   double h[],l[];
   if(InpShowDaily){ if(CopyHigh(_Symbol,PERIOD_D1,1,1,h)==1)g_PDH=h[0]; if(CopyLow(_Symbol,PERIOD_D1,1,1,l)==1)g_PDL=l[0]; }
   if(InpShowWeekly){ if(CopyHigh(_Symbol,PERIOD_W1,1,1,h)==1)g_PWH=h[0]; if(CopyLow(_Symbol,PERIOD_W1,1,1,l)==1)g_PWL=l[0]; }
   if(InpShowMonthly){ if(CopyHigh(_Symbol,PERIOD_MN1,1,1,h)==1)g_PMH=h[0]; if(CopyLow(_Symbol,PERIOD_MN1,1,1,l)==1)g_PML=l[0]; }
}
void DrawMTFLevels(const datetime &time[],int total)
{
   int anchor=MathMax(0,total-InpLookbackBars);
   datetime t1=time[anchor]; datetime t2=TimeShiftForward(time[total-1],3);
   if(InpShowDaily){ if(g_PDH>0)DrawLevel(PFX "LV_PDH",t1,t2,g_PDH,"PDH",STYLE_SOLID); if(g_PDL>0)DrawLevel(PFX "LV_PDL",t1,t2,g_PDL,"PDL",STYLE_SOLID); }
   if(InpShowWeekly){ if(g_PWH>0)DrawLevel(PFX "LV_PWH",t1,t2,g_PWH,"PWH",STYLE_DASH); if(g_PWL>0)DrawLevel(PFX "LV_PWL",t1,t2,g_PWL,"PWL",STYLE_DASH); }
   if(InpShowMonthly){ if(g_PMH>0)DrawLevel(PFX "LV_PMH",t1,t2,g_PMH,"PMH",STYLE_DOT); if(g_PML>0)DrawLevel(PFX "LV_PML",t1,t2,g_PML,"PML",STYLE_DOT); }
}
void DrawLevel(string name,datetime t1,datetime t2,double price,string lbl,ENUM_LINE_STYLE st)
{
   ObjectCreate(0,name,OBJ_TREND,0,t1,price,t2,price);
   ObjectSetInteger(0,name,OBJPROP_COLOR,InpMTFCol);
   ObjectSetInteger(0,name,OBJPROP_STYLE,st);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   CreateText(name+"_t",t2,price,lbl,InpMTFCol,InpFontSize,ANCHOR_LEFT);
}

//==================================================================
//                MTF BIAS + CONTEXT + AI SCORE
//==================================================================
string TFBias(ENUM_TIMEFRAMES tf)
{
   int need=200; double h[],l[],cl[];
   if(CopyHigh(_Symbol,tf,0,need,h)<need) return "Neutral";
   if(CopyLow(_Symbol,tf,0,need,l)<need) return "Neutral";
   if(CopyClose(_Symbol,tf,0,need,cl)<need) return "Neutral";
   // series=false so index increases with time; exclude forming bar (last index)
   ArraySetAsSeries(h,false); ArraySetAsSeries(l,false); ArraySetAsSeries(cl,false);
   int s=3, m=need-1;                 // m excludes the still-forming HTF bar
   double up=DBL_MAX, dn=-DBL_MAX; int upb=-1, dnb=-1, trend=0;
   for(int i=s+1;i<m;i++)
   {
      int p=i-s;
      if(p>=s)
      {
         bool isH=true,isL=true;
         for(int k=1;k<=s;k++){ if(h[p]<=h[p+k]||h[p]<=h[p-k])isH=false; if(l[p]>=l[p+k]||l[p]>=l[p-k])isL=false; }
         if(isH){ up=h[p]; upb=p; }
         if(isL){ dn=l[p]; dnb=p; }
      }
      if(upb>=0 && cl[i]>up){ trend=1;  up=DBL_MAX; upb=-1; }   // break up  -> bullish, carried forward
      if(dnb>=0 && cl[i]<dn){ trend=-1; dn=-DBL_MAX; dnb=-1; }  // break down -> bearish, carried forward
   }
   return (trend>0)?"Bullish":(trend<0)?"Bearish":"Neutral";
}
void ComputeContext(double price)
{
   if(g_bias>0){ g_structure="Bullish"; g_trend="Uptrend"; }
   else if(g_bias<0){ g_structure="Bearish"; g_trend="Downtrend"; }
   else { g_structure="Neutral"; g_trend="Range"; }
   if(g_swHigh>0&&g_swLow>0){
      double eq=(g_swHigh+g_swLow)/2.0;
      g_eqPos=(price>eq)?"Premium":(price<eq)?"Discount":"Equilibrium";
   }
   g_liq=(g_eqhSwept||g_eqlSwept)?"Swept":"Intact";
}
// count how many of the 3 HTFs are bullish / bearish
void HTFCounts(int &bull,int &bear)
{
   bull=0; bear=0;
   string b[3]; b[0]=g_bTF1; b[1]=g_bTF2; b[2]=g_bTF3;
   for(int i=0;i<3;i++){ if(b[i]=="Bullish")bull++; else if(b[i]=="Bearish")bear++; }
}
// resolve directional HTF gate (master = TF1). Strict mode needs all 3 to agree.
void HTFAlign(bool &alignBull,bool &alignBear)
{
   int bull,bear; HTFCounts(bull,bear);
   if(InpRequireHTFAlign){ alignBull=(bull==3); alignBear=(bear==3); }
   else { alignBull=(g_bTF1=="Bullish" && bear==0); alignBear=(g_bTF1=="Bearish" && bull==0); }
}
void ComputeAIScore()
{
   // 3-TF top-down alignment + structure + location + executed sequence
   int s=0; int bull,bear; HTFCounts(bull,bear);
   bool allAgree=(bull==3 || bear==3);
   bool majAgree=(bull>=2 && bear==0) || (bear>=2 && bull==0);
   if(g_structure!="Neutral")                       s+=10;
   if(allAgree)                                      s+=25;   // all 3 HTFs agree
   else if(majAgree)                                 s+=12;   // 2 agree, none opposite
   if(g_eqPos=="Discount"&&g_structure=="Bullish")   s+=10;
   if(g_eqPos=="Premium" &&g_structure=="Bearish")   s+=10;
   if(g_swpDir!=0)                                   s+=15;   // a sweep happened
   if(g_chochDir!=0 && g_chochDir==g_swpDir)         s+=15;   // CHoCH confirmed the sweep direction
   if((g_swpDir==1 && g_structure=="Bullish")||(g_swpDir==-1 && g_structure=="Bearish")) s+=15;
   g_aiScore=(int)MathMin(100,s);
}

//==================================================================
//                    TRADE SIGNAL ENGINE
//==================================================================
// nearest unmitigated OB on the correct side of price (bull = at/below price, bear = at/above)
int FindEntryOB(bool bull,double price)
{
   int best=-1; double bestDist=DBL_MAX;
   for(int i=0;i<g_obN;i++)
   {
      if(g_obs[i].bull!=bull || g_obs[i].mit) continue;
      double mid=(g_obs[i].top+g_obs[i].bot)/2.0;
      if(bull  && mid>price+0.2*g_atr) continue;   // bullish OB must sit at/below price
      if(!bull && mid<price-0.2*g_atr) continue;   // bearish OB must sit at/above price
      double d=MathAbs(mid-price);
      if(d<bestDist){ bestDist=d; best=i; }
   }
   return best;
}

bool HasFVG(bool bull)
{
   for(int i=0;i<g_fvgN;i++) if(g_fvg[i].bull==bull && !g_fvg[i].mit) return true;
   return false;
}
// nearest unmitigated FVG of the given side that price is currently tapping (within tap)
int FindEntryFVG(bool bull,double price,double tap)
{
   int best=-1; double bestDist=DBL_MAX;
   for(int i=0;i<g_fvgN;i++)
   {
      if(g_fvg[i].bull!=bull || g_fvg[i].mit) continue;
      double top=g_fvg[i].top, bot=g_fvg[i].bot, mid=(top+bot)/2.0;
      if(price<=top+tap && price>=bot-tap)
      {
         double d=MathAbs(mid-price);
         if(d<bestDist){ bestDist=d; best=i; }
      }
   }
   return best;
}

void ComputeSignal(double price,const double &high[],const double &low[],int total)
{
   int curBar=total-1;                                // last CLOSED bar index
   double eq=(g_swHigh>0&&g_swLow>0)?(g_swHigh+g_swLow)/2.0:price;
   bool inDiscount=(g_swHigh>0 && g_swLow>0 && price<eq);
   bool inPremium =(g_swHigh>0 && g_swLow>0 && price>eq);
   double tap=1.0*g_atr;

   // ---- 3-TF TOP-DOWN GATE (TF1 master, TF2/TF3 confirm) ----
   bool alignBull,alignBear; HTFAlign(alignBull,alignBear);
   bool buyCtx  = (g_bias>0) && alignBull;            // chart bias must also agree with HTF stack
   bool sellCtx = (g_bias<0) && alignBear;

   // ---- SEQUENCE FRESHNESS: sweep -> CHoCH (after sweep) -> entry, all within window ----
   bool sweepBull = (g_swpDir== 1 && (curBar-g_swpBar)<=InpSeqWindow);
   bool sweepBear = (g_swpDir==-1 && (curBar-g_swpBar)<=InpSeqWindow);
   bool chochBull = (g_chochDir== 1 && g_chochBar>=g_swpBar && (curBar-g_chochBar)<=InpSeqWindow);
   bool chochBear = (g_chochDir==-1 && g_chochBar>=g_swpBar && (curBar-g_chochBar)<=InpSeqWindow);

   // ---- ENTRY ZONE: must tap a fresh OB or FVG on the correct side ----
   int obB=FindEntryOB(true,price);
   int obS=FindEntryOB(false,price);
   bool buyOBTap  = (obB>=0 && price<=g_obs[obB].top+tap && price>=g_obs[obB].bot-tap);
   bool sellOBTap = (obS>=0 && price>=g_obs[obS].bot-tap && price<=g_obs[obS].top+tap);
   int fvgB=FindEntryFVG(true,price,tap);
   int fvgS=FindEntryFVG(false,price,tap);
   bool buyEntry  = buyOBTap  || fvgB>=0;
   bool sellEntry = sellOBTap || fvgS>=0;

   // ---- MANDATORY GATES (each can be toggled off) ----
   bool buyGate  = buyCtx
                   && (!InpRequireSweep   || sweepBull)
                   && (!InpRequireCHoCH   || chochBull)
                   && (!InpEntryOnFVGorOB || buyEntry)
                   && !inPremium;
   bool sellGate = sellCtx
                   && (!InpRequireSweep   || sweepBear)
                   && (!InpRequireCHoCH   || chochBear)
                   && (!InpEntryOnFVGorOB || sellEntry)
                   && !inDiscount;

   // ---- confluence score (only the legs that actually fired contribute) ----
   int hbull,hbear; HTFCounts(hbull,hbear);
   int buy=0,sell=0;
   if(alignBull) buy+=25; else if(hbull>=2 && hbear==0) buy+=12;
   if(alignBear) sell+=25; else if(hbear>=2 && hbull==0) sell+=12;
   if(inDiscount) buy+=15; else if(inPremium) buy-=15;
   if(inPremium)  sell+=15; else if(inDiscount) sell-=15;
   if(sweepBull) buy+=15;  if(sweepBear) sell+=15;
   if(chochBull) buy+=15;  if(chochBear) sell+=15;
   if(buyOBTap)  buy+=15;  if(sellOBTap) sell+=15;
   if(fvgB>=0)   buy+=10;  if(fvgS>=0)   sell+=10;
   if(g_eqlSwept) buy+=5;  if(g_eqhSwept) sell+=5;
   if(InpUseDelta){ if(g_dDir>0) buy+=10; if(g_dDir<0) sell+=10; }   // order-flow proxy agrees
   g_buyPct =(int)MathMax(0,MathMin(100,buy));
   g_sellPct=(int)MathMax(0,MathMin(100,sell));

   g_signal="WAIT"; g_signalNote="No clean SMC setup";
   g_entry=0;g_sl=0;g_tp1=0;g_tp2=0;g_tp3=0;g_rr=0;
   g_hasPending=false; g_pendingBuy=false; g_pendingEntry=0;

   // ---- ACTIVE BUY: full sequence chained + score >= threshold ----
   if(buyGate && g_buyPct>=InpSignalThreshold && g_buyPct>=g_sellPct)
   {
      double zTop,zBot;
      if(buyOBTap){ zTop=g_obs[obB].top; zBot=g_obs[obB].bot; g_signalNote="Sweep->CHoCH->Bullish OB (discount)"; }
      else        { zTop=g_fvg[fvgB].top; zBot=g_fvg[fvgB].bot; g_signalNote="Sweep->CHoCH->Bullish FVG (discount)"; }
      g_signal="BUY";
      g_entry=zTop; g_sl=zBot-InpSLBufferATR*g_atr;
      g_tp1=(eq>g_entry)?eq:g_entry+(g_entry-g_sl);
      g_tp2=(g_swHigh>g_tp1)?g_swHigh:g_tp1+(g_entry-g_sl);
      double liqUp=NearestAbove(g_entry,g_PDH,g_PWH,g_PMH);
      g_tp3=(liqUp>g_tp2)?liqUp:g_tp2+(g_entry-g_sl);
      if(g_entry>g_sl) g_rr=(g_tp2-g_entry)/(g_entry-g_sl);
   }
   // ---- ACTIVE SELL ----
   else if(sellGate && g_sellPct>=InpSignalThreshold && g_sellPct>g_buyPct)
   {
      double zTop,zBot;
      if(sellOBTap){ zTop=g_obs[obS].top; zBot=g_obs[obS].bot; g_signalNote="Sweep->CHoCH->Bearish OB (premium)"; }
      else         { zTop=g_fvg[fvgS].top; zBot=g_fvg[fvgS].bot; g_signalNote="Sweep->CHoCH->Bearish FVG (premium)"; }
      g_signal="SELL";
      g_entry=zBot; g_sl=zTop+InpSLBufferATR*g_atr;
      g_tp1=(eq<g_entry)?eq:g_entry-(g_sl-g_entry);
      g_tp2=(g_swLow<g_tp1 && g_swLow>0)?g_swLow:g_tp1-(g_sl-g_entry);
      double liqDn=NearestBelow(g_entry,g_PDL,g_PWL,g_PML);
      g_tp3=(liqDn<g_tp2 && liqDn>0)?liqDn:g_tp2-(g_sl-g_entry);
      if(g_sl>g_entry) g_rr=(g_entry-g_tp2)/(g_sl-g_entry);
   }
   // ---- PENDING / DIAGNOSTIC: tell the trader exactly which leg is missing ----
   else
   {
      double maxDist=InpMaxZoneATR*g_atr;
      bool obBNear=(obB>=0 && MathAbs(g_obs[obB].top-price)<=maxDist);
      bool obSNear=(obS>=0 && MathAbs(g_obs[obS].bot-price)<=maxDist);
      if(!alignBull && !alignBear)            g_signalNote="HTF stack not aligned (TF1/TF2/TF3 disagree)";
      else if(buyCtx && InpRequireSweep && !sweepBull)  g_signalNote="Bullish HTF - waiting for sell-side sweep";
      else if(sellCtx&& InpRequireSweep && !sweepBear)  g_signalNote="Bearish HTF - waiting for buy-side sweep";
      else if(buyCtx && InpRequireCHoCH && !chochBull)  g_signalNote="Sweep done - waiting bullish CHoCH";
      else if(sellCtx&& InpRequireCHoCH && !chochBear)  g_signalNote="Sweep done - waiting bearish CHoCH";
      else if(buyCtx && obBNear)  { g_signalNote="Confirmed - wait pullback to bullish OB"; g_hasPending=true; g_pendingBuy=true;  g_pendingEntry=g_obs[obB].top; }
      else if(sellCtx&& obSNear)  { g_signalNote="Confirmed - wait rally to bearish OB";  g_hasPending=true; g_pendingBuy=false; g_pendingEntry=g_obs[obS].bot; }
      else if(buyCtx || sellCtx)  g_signalNote="Confirmed bias - no OB within range (price ran away)";
   }
}

double NearestAbove(double ref,double a,double b,double c)
{
   double best=0;
   if(a>ref && (best==0||a<best)) best=a;
   if(b>ref && (best==0||b<best)) best=b;
   if(c>ref && (best==0||c<best)) best=c;
   return best;
}
double NearestBelow(double ref,double a,double b,double c)
{
   double best=0;
   if(a>0 && a<ref && a>best) best=a;
   if(b>0 && b<ref && b>best) best=b;
   if(c>0 && c<ref && c>best) best=c;
   return best;
}

void DrawSignalLevels(const datetime &time[],int total)
{
   datetime t1=time[MathMax(0,total-40)];
   datetime t2=TimeShiftForward(time[total-1],6);

   if(g_signal=="BUY" || g_signal=="SELL")
   {
      bool buy=(g_signal=="BUY");
      color cE=buy?InpBull:InpBear;
      SigLine(PFX "SIG_E",t1,t2,g_entry,cE,STYLE_SOLID,2,(buy?"BUY @ ":"SELL @ ")+DoubleToString(g_entry,_Digits));
      SigLine(PFX "SIG_SL",t1,t2,g_sl,clrRed,STYLE_DASH,1,"SL "+DoubleToString(g_sl,_Digits));
      SigLine(PFX "SIG_T1",t1,t2,g_tp1,clrLimeGreen,STYLE_DOT,1,"TP1 "+DoubleToString(g_tp1,_Digits));
      SigLine(PFX "SIG_T2",t1,t2,g_tp2,clrLimeGreen,STYLE_DOT,1,"TP2 "+DoubleToString(g_tp2,_Digits));
      SigLine(PFX "SIG_T3",t1,t2,g_tp3,clrLimeGreen,STYLE_DOT,1,"TP3 "+DoubleToString(g_tp3,_Digits));

      string nm=PFX "SIG_AR";
      ObjectCreate(0,nm,OBJ_ARROW,0,time[total-1],g_entry);
      ObjectSetInteger(0,nm,OBJPROP_ARROWCODE,buy?233:234);
      ObjectSetInteger(0,nm,OBJPROP_COLOR,cE);
      ObjectSetInteger(0,nm,OBJPROP_WIDTH,2);
      ObjectSetInteger(0,nm,OBJPROP_ANCHOR,buy?ANCHOR_TOP:ANCHOR_BOTTOM);
      ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,false);
   }
   else if(g_hasPending && g_pendingEntry>0)
   {
      // pending pullback zone — faint dashed line, no active arrow
      color cZ=g_pendingBuy?InpBull:InpBear;
      SigLine(PFX "SIG_PZ",t1,t2,g_pendingEntry,cZ,STYLE_DASH,1,
              (g_pendingBuy?"BUY ZONE (wait) ":"SELL ZONE (wait) ")+DoubleToString(g_pendingEntry,_Digits));
   }
}

void SigLine(string name,datetime t1,datetime t2,double price,color c,ENUM_LINE_STYLE st,int w,string lbl)
{
   if(price<=0) return;
   ObjectCreate(0,name,OBJ_TREND,0,t1,price,t2,price);
   ObjectSetInteger(0,name,OBJPROP_COLOR,c);
   ObjectSetInteger(0,name,OBJPROP_STYLE,st);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,w);
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,false);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   CreateText(name+"_t",t2,price,lbl,c,InpFontSize-1,ANCHOR_LEFT);
}


//==================================================================
//                     CANDLE COLORING
//==================================================================
void FillCandleBuffers(const double &open[],const double &high[],const double &low[],
                       const double &close[],int total,int startBar)
{
   for(int i=0;i<total;i++)
   {
      if(!InpColorCandles || i<startBar)
      { BufO[i]=EMPTY_VALUE; BufH[i]=EMPTY_VALUE; BufL[i]=EMPTY_VALUE; BufC[i]=EMPTY_VALUE; BufCol[i]=0; continue; }
      BufO[i]=open[i]; BufH[i]=high[i]; BufL[i]=low[i]; BufC[i]=close[i];
      int t=SwingTrendAt(i);
      BufCol[i]=(t>0)?1:(t<0)?2:0;
   }
}

//==================================================================
//                          DASHBOARD
//==================================================================
void DrawDashboard()
{
   color bc=(g_structure=="Bullish")?InpBull:(g_structure=="Bearish")?InpBear:clrSilver;

   Panel(PFX "P_BIAS",CORNER_LEFT_UPPER,12,30,252,180);
   PanelLabel(PFX "L_bt",CORNER_LEFT_UPPER,24,40,"SMC BIAS: "+(g_structure=="Neutral"?"RANGE":StrUpper(g_structure)),bc,InpFontSize+2,true);
   int y=72,dy=22,xk=24,xv=132;
   PanelLabel(PFX "L_b1k",CORNER_LEFT_UPPER,xk,y,"Structure:",InpTextCol,InpFontSize);
   PanelLabel(PFX "L_b1v",CORNER_LEFT_UPPER,xv,y,g_structure,bc,InpFontSize); y+=dy;
   PanelLabel(PFX "L_b2k",CORNER_LEFT_UPPER,xk,y,"Trend:",InpTextCol,InpFontSize);
   PanelLabel(PFX "L_b2v",CORNER_LEFT_UPPER,xv,y,g_trend,bc,InpFontSize); y+=dy;
   PanelLabel(PFX "L_b3k",CORNER_LEFT_UPPER,xk,y,"EQ Position:",InpTextCol,InpFontSize);
   PanelLabel(PFX "L_b3v",CORNER_LEFT_UPPER,xv,y,g_eqPos,g_eqPos=="Discount"?InpBull:(g_eqPos=="Premium"?InpBear:clrSilver),InpFontSize); y+=dy;
   PanelLabel(PFX "L_b4k",CORNER_LEFT_UPPER,xk,y,"Liquidity:",InpTextCol,InpFontSize);
   PanelLabel(PFX "L_b4v",CORNER_LEFT_UPPER,xv,y,g_liq,g_liq=="Swept"?InpAccent:clrSilver,InpFontSize); y+=dy;
   PanelLabel(PFX "L_b5k",CORNER_LEFT_UPPER,xk,y,"AI Score:",InpTextCol,InpFontSize);
   PanelLabel(PFX "L_b5v",CORNER_LEFT_UPPER,xv,y,IntegerToString(g_aiScore)+"%",g_aiScore>=70?InpBull:(g_aiScore>=40?clrGold:InpBear),InpFontSize);

   int bw=180,bh=78,gap=10,bx=14,by=14;
   Panel(PFX "P_d1",CORNER_LEFT_LOWER,bx,by+bh,bw,bh);
   PanelLabel(PFX "L_d1t",CORNER_LEFT_LOWER,bx+12,by+bh-12,"STRUCTURE SUMMARY",InpTextCol,InpFontSize,true);
   PanelLabel(PFX "L_d1a",CORNER_LEFT_LOWER,bx+12,by+bh-34,"HH: "+IntegerToString(g_HH),InpBull,InpFontSize);
   PanelLabel(PFX "L_d1b",CORNER_LEFT_LOWER,bx+95,by+bh-34,"HL: "+IntegerToString(g_HL),InpBull,InpFontSize);
   PanelLabel(PFX "L_d1c",CORNER_LEFT_LOWER,bx+12,by+bh-56,"LH: "+IntegerToString(g_LH),InpBear,InpFontSize);
   PanelLabel(PFX "L_d1d",CORNER_LEFT_LOWER,bx+95,by+bh-56,"LL: "+IntegerToString(g_LL),InpBear,InpFontSize);

   int x2=bx+bw+gap;
   Panel(PFX "P_d2",CORNER_LEFT_LOWER,x2,by+bh,bw,bh);
   PanelLabel(PFX "L_d2t",CORNER_LEFT_LOWER,x2+12,by+bh-12,"LIQUIDITY STATUS",InpTextCol,InpFontSize,true);
   PanelLabel(PFX "L_d2a",CORNER_LEFT_LOWER,x2+12,by+bh-40,"EQH Swept:",InpTextCol,InpFontSize);
   PanelLabel(PFX "L_d2av",CORNER_LEFT_LOWER,x2+108,by+bh-40,g_eqhSwept?"Yes":"No",g_eqhSwept?InpAccent:clrGray,InpFontSize);
   PanelLabel(PFX "L_d2b",CORNER_LEFT_LOWER,x2+12,by+bh-62,"EQL Swept:",InpTextCol,InpFontSize);
   PanelLabel(PFX "L_d2bv",CORNER_LEFT_LOWER,x2+108,by+bh-62,g_eqlSwept?"Yes":"No",g_eqlSwept?InpAccent:clrGray,InpFontSize);

   int x3=x2+bw+gap;
   Panel(PFX "P_d3",CORNER_LEFT_LOWER,x3,by+bh,bw,bh);
   PanelLabel(PFX "L_d3t",CORNER_LEFT_LOWER,x3+12,by+bh-12,"MARKET CONTEXT",InpTextCol,InpFontSize,true);
   PanelLabel(PFX "L_d3a",CORNER_LEFT_LOWER,x3+12,by+bh-40,"Price in:",InpTextCol,InpFontSize);
   PanelLabel(PFX "L_d3av",CORNER_LEFT_LOWER,x3+95,by+bh-40,g_eqPos,g_eqPos=="Discount"?InpBull:(g_eqPos=="Premium"?InpBear:clrSilver),InpFontSize);
   PanelLabel(PFX "L_d3b",CORNER_LEFT_LOWER,x3+12,by+bh-62,"Bias:",InpTextCol,InpFontSize);
   PanelLabel(PFX "L_d3bv",CORNER_LEFT_LOWER,x3+95,by+bh-62,g_structure,bc,InpFontSize);

   int x4=x3+bw+gap;
   Panel(PFX "P_d4",CORNER_LEFT_LOWER,x4,by+bh,bw+30,bh);
   PanelLabel(PFX "L_d4t",CORNER_LEFT_LOWER,x4+12,by+bh-12,"KEY LEVELS",InpTextCol,InpFontSize,true);
   PanelLabel(PFX "L_d4a",CORNER_LEFT_LOWER,x4+12,by+bh-40,"PWH: "+DoubleToString(g_PWH,_Digits),InpAccent,InpFontSize);
   PanelLabel(PFX "L_d4b",CORNER_LEFT_LOWER,x4+118,by+bh-40,"PDL: "+DoubleToString(g_PDL,_Digits),InpAccent,InpFontSize);
   PanelLabel(PFX "L_d4c",CORNER_LEFT_LOWER,x4+12,by+bh-62,"PDH: "+DoubleToString(g_PDH,_Digits),InpAccent,InpFontSize);
   PanelLabel(PFX "L_d4d",CORNER_LEFT_LOWER,x4+118,by+bh-62,"PWL: "+DoubleToString(g_PWL,_Digits),InpAccent,InpFontSize);

   int x5=x4+bw+30+gap;
   int bh5=bh+22;                                  // taller panel to fit 3 rows
   Panel(PFX "P_d5",CORNER_LEFT_LOWER,x5,by+bh5,bw,bh5);
   PanelLabel(PFX "L_d5t",CORNER_LEFT_LOWER,x5+12,by+bh5-12,"ALIGNMENT",InpTextCol,InpFontSize,true);
   PanelLabel(PFX "L_d5a",CORNER_LEFT_LOWER,x5+12,by+bh5-36,TFToStr(InpHTF1)+" Bias:",InpTextCol,InpFontSize);
   PanelLabel(PFX "L_d5av",CORNER_LEFT_LOWER,x5+95,by+bh5-36,g_bTF1,g_bTF1=="Bullish"?InpBull:(g_bTF1=="Bearish"?InpBear:clrSilver),InpFontSize);
   PanelLabel(PFX "L_d5b",CORNER_LEFT_LOWER,x5+12,by+bh5-58,TFToStr(InpHTF2)+" Bias:",InpTextCol,InpFontSize);
   PanelLabel(PFX "L_d5bv",CORNER_LEFT_LOWER,x5+95,by+bh5-58,g_bTF2,g_bTF2=="Bullish"?InpBull:(g_bTF2=="Bearish"?InpBear:clrSilver),InpFontSize);
   PanelLabel(PFX "L_d5c",CORNER_LEFT_LOWER,x5+12,by+bh5-80,TFToStr(InpHTF3)+" Bias:",InpTextCol,InpFontSize);
   PanelLabel(PFX "L_d5cv",CORNER_LEFT_LOWER,x5+95,by+bh5-80,g_bTF3,g_bTF3=="Bullish"?InpBull:(g_bTF3=="Bearish"?InpBear:clrSilver),InpFontSize);

   int lw=185,lh=140,lx=14,ly=14+bh+gap;
   Panel(PFX "P_leg",CORNER_RIGHT_LOWER,lx,ly+lh,lw,lh);
   PanelLabel(PFX "L_legt",CORNER_RIGHT_LOWER,lx+lw-12,ly+lh-12,"LEGEND STATUS",InpTextCol,InpFontSize,true,ANCHOR_RIGHT_UPPER);
   string it[5]={"Structure","Order Blocks","FVG","Premium/Discount","Liquidity"};
   bool on[5]={(InpShowSwing||InpShowInternal),(InpShowSwingOB||InpShowInternalOB),InpShowFVG,InpShowPD,InpShowEQ};
   int yy=ly+lh-36;
   for(int i=0;i<5;i++)
   {
      PanelLabel(PFX "L_le"+IntegerToString(i)+"a",CORNER_RIGHT_LOWER,lx+lw-12,yy,it[i],InpTextCol,InpFontSize,false,ANCHOR_RIGHT_UPPER);
      PanelLabel(PFX "L_le"+IntegerToString(i)+"b",CORNER_RIGHT_LOWER,lx+12,yy,on[i]?"On":"Off",on[i]?InpBull:clrGray,InpFontSize,false,ANCHOR_RIGHT_UPPER);
      yy-=22;
   }

   // ---- TRADE SETUP panel (top-right) ----
   if(InpShowSignals)
   {
      color sc=(g_signal=="BUY")?InpBull:(g_signal=="SELL")?InpBear:clrSilver;
      bool active=(g_signal=="BUY"||g_signal=="SELL");
      int rows=active?6:1;                          // entry/sl/tp1/tp2/tp3/rr  OR  note
      int pw=212,px=14,py=30,sdy=21;
      int ph=64+rows*sdy+8;
      Panel(PFX "P_sig",CORNER_RIGHT_UPPER,px,py,pw,ph);
      PanelLabel(PFX "L_st",CORNER_RIGHT_UPPER,px+pw-14,py+10,"TRADE SETUP",InpTextCol,InpFontSize,true,ANCHOR_RIGHT_UPPER);
      int sy=py+38,kx=px+pw-14,vx=px+12;
      PanelLabel(PFX "L_s0",CORNER_RIGHT_UPPER,kx,sy,"Signal:",InpTextCol,InpFontSize+1,true,ANCHOR_RIGHT_UPPER);
      PanelLabel(PFX "L_s0v",CORNER_RIGHT_UPPER,vx,sy,g_signal,sc,InpFontSize+1,true,ANCHOR_RIGHT_UPPER); sy+=sdy+6;

      ObjectsDeleteAll(0,PFX "SR_");                 // clear variable rows, redraw current state
      if(active)
      {
         SetupRow(PFX "SR_2",kx,vx,sy,"Entry:",DoubleToString(g_entry,_Digits),InpTextCol); sy+=sdy;
         SetupRow(PFX "SR_3",kx,vx,sy,"SL:",DoubleToString(g_sl,_Digits),clrTomato); sy+=sdy;
         SetupRow(PFX "SR_4",kx,vx,sy,"TP1:",DoubleToString(g_tp1,_Digits),clrLimeGreen); sy+=sdy;
         SetupRow(PFX "SR_5",kx,vx,sy,"TP2:",DoubleToString(g_tp2,_Digits),clrLimeGreen); sy+=sdy;
         SetupRow(PFX "SR_6",kx,vx,sy,"TP3:",DoubleToString(g_tp3,_Digits),clrLimeGreen); sy+=sdy;
         SetupRow(PFX "SR_7",kx,vx,sy,"R:R (TP2):","1 : "+DoubleToString(g_rr,1),g_rr>=2?InpBull:clrGold);
      }
      else
      {
         PanelLabel(PFX "SR_w",CORNER_RIGHT_UPPER,kx,sy,g_signalNote,clrSilver,InpFontSize-1,false,ANCHOR_RIGHT_UPPER);
      }
   }
}

void SetupRow(string base,int kx,int vx,int sy,string key,string val,color vc)
{
   PanelLabel(base+"k",CORNER_RIGHT_UPPER,kx,sy,key,InpTextCol,InpFontSize,false,ANCHOR_RIGHT_UPPER);
   PanelLabel(base+"v",CORNER_RIGHT_UPPER,vx,sy,val,vc,InpFontSize,false,ANCHOR_RIGHT_UPPER);
}

//==================================================================
//                       DRAWING HELPERS
//==================================================================
void Panel(string name,ENUM_BASE_CORNER corner,int x,int y,int w,int h)
{
   if(ObjectFind(0,name)<0) ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,w);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,h);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,InpPanelTransparent?clrNONE:InpPanelBG);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,name,OBJPROP_COLOR,InpPanelBorder);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
}
void PanelLabel(string name,ENUM_BASE_CORNER corner,int x,int y,string text,color c,int fs,
                bool bold=false,ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER)
{
   if(ObjectFind(0,name)<0) ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,anchor);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_FONT,bold?InpFontName+" Bold":InpFontName);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fs);
   ObjectSetInteger(0,name,OBJPROP_COLOR,c);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
}
void DrawBox(string name,datetime t1,double p1,datetime t2,double p2,color fill,color border,bool back)
{
   if(ObjectFind(0,name)<0) ObjectCreate(0,name,OBJ_RECTANGLE,0,t1,p1,t2,p2);
   else { ObjectMove(0,name,0,t1,p1); ObjectMove(0,name,1,t2,p2); }
   // OBJ_RECTANGLE: the FILL uses OBJPROP_COLOR, so the (dark) fill color must go here.
   ObjectSetInteger(0,name,OBJPROP_COLOR,fill);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,fill);
   ObjectSetInteger(0,name,OBJPROP_FILL,true);
   ObjectSetInteger(0,name,OBJPROP_BACK,back);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
}
void CreateText(string name,datetime t,double price,string text,color c,int fs,ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT)
{
   if(ObjectFind(0,name)<0) ObjectCreate(0,name,OBJ_TEXT,0,t,price);
   else ObjectMove(0,name,0,t,price);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_FONT,InpFontName);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fs);
   ObjectSetInteger(0,name,OBJPROP_COLOR,c);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
}

//==================================================================
//                          UTILITIES
//==================================================================
double CalcATR(const double &high[],const double &low[],const double &close[],int total,int period)
{
   if(total<period+1) return (high[total-1]-low[total-1]);
   double sum=0;
   for(int i=total-period;i<total;i++)
   {
      double tr=high[i]-low[i];
      tr=MathMax(tr,MathMax(MathAbs(high[i]-close[i-1]),MathAbs(low[i]-close[i-1])));
      sum+=tr;
   }
   double atr=sum/period;
   if(atr<=0) atr=(high[total-1]-low[total-1]);
   return atr;
}
datetime TimeShiftForward(datetime base,int bars){ return base+(datetime)((long)PeriodSeconds(_Period)*bars); }
void DeleteByPrefix(string prefix){ ObjectsDeleteAll(0,prefix); }
string TFToStr(int tf)
{
   switch(tf)
   {
      case PERIOD_M1:return "M1"; case PERIOD_M5:return "M5"; case PERIOD_M15:return "M15";
      case PERIOD_M30:return "M30"; case PERIOD_H1:return "H1"; case PERIOD_H4:return "H4";
      case PERIOD_D1:return "D1"; case PERIOD_W1:return "W1"; case PERIOD_MN1:return "MN";
   }
   return "TF";
}
string StrUpper(string s){ string r=s; StringToUpper(r); return r; }
//+------------------------------------------------------------------+
