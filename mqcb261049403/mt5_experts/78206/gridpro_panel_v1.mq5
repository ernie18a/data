//+------------------------------------------------------------------+
//|                                              GridPro_Panel.mq5   |
//|   MT5 网格策略 EA + 可视化控制面板（暗色主题，运行时可改参数）      |
//|   需要【对冲账户】(Hedging)                                       |
//|                                                                  |
//|   版权所有 (C) 2026 超哥量化                                      |
//|   微信技术交流：fxquant                                           |
//|                                                                  |
//|   本源码随公众号文章公开，供量化爱好者学习交流使用；               |
//|   转载请保留本版权声明，请勿用于商业转售。                         |
//|   English: released open-source for study and personal use.       |
//|   Keep this copyright header if reposting. No commercial resale.  |
//+------------------------------------------------------------------+
#property copyright "Copyright (C) 2026 超哥量化 (Chaoge Quant) · WeChat: fxquant"
#property link      "WeChat Official Account: 超哥量化 (fxquant)"
#property version   "1.00"
#property description "Customizable grid EA: multi-signal entry / flexible averaging / multi-level risk control / live on-chart panel"
#property description "Open source for study and personal use - keep the copyright header if reposting, no commercial resale"

#include <Trade/Trade.mqh>

//--- Enums ---------------------------------------------------------
enum ENUM_DIR      { DIR_BOTH=0,  // Both (BUY & SELL)
                     DIR_BUY=1,   // Buy only
                     DIR_SELL=2 };// Sell only
enum ENUM_SIG      { SIG_NONE=0,  // None (enter immediately)
                     SIG_MA=1,    // MA cross
                     SIG_RSI=2,   // RSI oversold/overbought
                     SIG_BOLL=3,  // Bollinger Bands return
                     SIG_STOCH=4 };// Stochastic
enum ENUM_LOTMODE  { LOT_FIXED=0, // Fixed lot
                     LOT_MARTI=1, // Martingale multiplier
                     LOT_ARITH=2 };// Arithmetic increment
enum ENUM_STEPMODE { STEP_FIXED=0,// Fixed points
                     STEP_ATR=1 };// ATR dynamic

//--- Input parameters ---------------------------------------------
input group "═══ General ═══"
input long          InpMagic       = 20260101;     // Magic number
input string        InpComment     = "GridPro";    // Order comment
input ENUM_DIR      InpDir         = DIR_BOTH;     // Trade direction
input int           InpSlippage    = 30;           // Max slippage (points)
input int           InpMinInterval = 1;            // Min interval between orders (sec)

input group "═══ Lots ═══"
input double        InpFirstLot    = 0.01;         // First order lot
input double        InpAutoLotBal  = 0;            // Auto-lot: scale first lot by balance/N (0=off)
input ENUM_LOTMODE  InpLotMode     = LOT_MARTI;    // Averaging lot mode
input double        InpLotMult     = 1.5;          // Lot multiplier (martingale)
input double        InpLotAdd      = 0.01;         // Lot increment (arithmetic)
input double        InpMaxLot      = 1.0;          // Max lot per order

input group "═══ Grid ═══"
input ENUM_STEPMODE InpStepMode    = STEP_FIXED;   // Step mode
input double        InpStepPts     = 300;          // Averaging step (points)
input double        InpStepMult    = 1.0;          // Step multiplier (per level)
input int           InpAtrPeriod   = 14;           // ATR period
input ENUM_TIMEFRAMES InpAtrTf     = PERIOD_H1;    // ATR timeframe
input double        InpAtrMult     = 1.0;          // ATR step multiplier
input int           InpMaxLevels   = 10;           // Max levels per side (incl. first)

input group "═══ Entry signal (first order only) ═══"
input ENUM_SIG      InpSignal      = SIG_NONE;     // Entry signal
input ENUM_TIMEFRAMES InpSigTf     = PERIOD_M15;   // Signal timeframe
input bool          InpReverse     = false;        // Reverse signal
input int           InpMAFast      = 10;           // MA fast
input int           InpMASlow      = 30;           // MA slow
input ENUM_MA_METHOD InpMAMethod   = MODE_EMA;     // MA method
input int           InpRSIPeriod   = 14;           // RSI period
input double        InpRSIBuy      = 30;           // RSI buy level (<=)
input double        InpRSISell     = 70;           // RSI sell level (>=)
input int           InpBBPeriod    = 20;           // Bollinger period
input double        InpBBDev       = 2.0;          // Bollinger deviation
input int           InpStochK      = 5;           // Stochastic %K
input int           InpStochD      = 3;           // Stochastic %D
input int           InpStochSlow   = 3;           // Stochastic slowing
input double        InpStochLow    = 20;           // Stochastic oversold
input double        InpStochHigh   = 80;           // Stochastic overbought

input group "═══ Take profit (per side basket) ═══"
input double        InpTPMoney     = 10.0;         // Basket TP money ($, 0=off)
input double        InpTPPoints    = 0;            // Avg-price TP points (0=off)
input bool          InpTrailOn     = false;        // Basket trailing TP (overrides money TP)
input double        InpTrailStart  = 8.0;          // Trailing start profit ($)
input double        InpTrailGap    = 3.0;          // Trailing pullback ($)

input group "═══ Risk management ═══"
input double        InpBasketSL    = 0;            // Basket SL money ($, 0=off)
input double        InpMaxDDPct    = 30.0;         // Account drawdown stop % (0=off)
input double        InpDailyLoss   = 0;            // Daily loss limit % (0=off)
input double        InpDailyProfit = 0;            // Daily profit target % (0=off)
input double        InpMaxSpread   = 0;            // Max spread (points, 0=off)
input double        InpMaxTotalLots= 0;            // Max total lots (0=off)
input double        InpMinMarginLvl= 300;          // Min margin level % (0=off)
input bool          InpUseTime     = false;        // Use trading session (first order only)
input int           InpStartHour   = 8;            // Start hour (server time)
input int           InpEndHour     = 22;           // End hour (server time)
input int           InpFriCloseHr  = 0;            // Friday close-all hour (0=off)

input group "═══ Panel ═══"
input bool          InpShowPanel   = true;         // Show panel
input int           InpPanelX      = 15;           // Panel X
input int           InpPanelY      = 25;           // Panel Y
input color         InpAccent      = C'64,156,255';// Theme accent color
input bool          InpDrawLines   = true;         // Draw avg-price lines

//--- 常量 ---------------------------------------------------------
#define P        "GP_"
#define PW       330
const string FONT = "Segoe UI";

//--- 配色 ---------------------------------------------------------
color C_BG     = C'16,20,30';
color C_HEAD   = C'26,32,48';
color C_CARD   = C'24,29,42';
color C_TEXT   = C'214,222,238';
color C_MUTED  = C'124,134,156';
color C_GREEN  = C'38,200,130';
color C_RED    = C'240,84,100';
color C_AMBER  = C'255,184,64';
color C_EDIT   = C'34,41,60';

//--- 统计结构 -----------------------------------------------------
struct SideStat
  {
   int      n;
   double   lots;
   double   profit;
   double   avg;
   double   ext;       // 多单: 最低开仓价, 空单: 最高开仓价
   double   lastLot;
   datetime lastTime;
  };

//--- 全局状态 -----------------------------------------------------
CTrade   trade;
SideStat g_b, g_s;
int      hFast=INVALID_HANDLE, hSlow=INVALID_HANDLE, hRSI=INVALID_HANDLE,
         hBB=INVALID_HANDLE, hStoch=INVALID_HANDLE, hATR=INVALID_HANDLE;

// 运行时可修改参数（面板可调）
double   g_firstLot, g_stepPts, g_stepMult, g_lotMult, g_tpMoney, g_tpPts, g_ddPct;
int      g_maxLevels;

bool     g_running   = true;
bool     g_minimized = false;
string   g_halt      = "";     // 风控停止原因
bool     g_haltDaily = false;  // 是否为日内风控（次日自动解除）
string   g_note      = "";
datetime g_dayKey    = 0;
double   g_dayStartEq= 0;
double   g_peakB=0, g_peakS=0;
datetime g_lastOpen  = 0;
int      g_lotDigits = 2;
int      g_runStyle  = -1;
string   g_res[];
#define  BTNW  ((PW-16-12)/3)

//+------------------------------------------------------------------+
//| 初始化                                                            |
//+------------------------------------------------------------------+
int OnInit()
  {
   if((ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE)!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      Alert("Grid EA requires a HEDGING account - the current account type is not supported!");
      return INIT_FAILED;
     }

   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(InpSlippage);
   trade.SetTypeFillingBySymbol(_Symbol);

   double vs=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   g_lotDigits=0;
   while(g_lotDigits<8 && MathAbs(vs*MathPow(10,g_lotDigits)-MathRound(vs*MathPow(10,g_lotDigits)))>1e-9) g_lotDigits++;

   g_firstLot=InpFirstLot;  g_stepPts=InpStepPts;  g_stepMult=InpStepMult;
   g_lotMult=InpLotMult;    g_tpMoney=InpTPMoney;  g_tpPts=InpTPPoints;
   g_ddPct=InpMaxDDPct;     g_maxLevels=InpMaxLevels;

   // 指标句柄
   switch(InpSignal)
     {
      case SIG_MA:
         hFast=iMA(_Symbol,InpSigTf,InpMAFast,0,InpMAMethod,PRICE_CLOSE);
         hSlow=iMA(_Symbol,InpSigTf,InpMASlow,0,InpMAMethod,PRICE_CLOSE);
         if(hFast==INVALID_HANDLE||hSlow==INVALID_HANDLE) return INIT_FAILED;
         break;
      case SIG_RSI:
         hRSI=iRSI(_Symbol,InpSigTf,InpRSIPeriod,PRICE_CLOSE);
         if(hRSI==INVALID_HANDLE) return INIT_FAILED;
         break;
      case SIG_BOLL:
         hBB=iBands(_Symbol,InpSigTf,InpBBPeriod,0,InpBBDev,PRICE_CLOSE);
         if(hBB==INVALID_HANDLE) return INIT_FAILED;
         break;
      case SIG_STOCH:
         hStoch=iStochastic(_Symbol,InpSigTf,InpStochK,InpStochD,InpStochSlow,MODE_SMA,STO_LOWHIGH);
         if(hStoch==INVALID_HANDLE) return INIT_FAILED;
         break;
      default: break;
     }
   if(InpStepMode==STEP_ATR)
     {
      hATR=iATR(_Symbol,InpAtrTf,InpAtrPeriod);
      if(hATR==INVALID_HANDLE) return INIT_FAILED;
     }

   RollDay();
   if(InpShowPanel) BuildPanel();
   EventSetMillisecondTimer(500);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(hFast!=INVALID_HANDLE)  IndicatorRelease(hFast);
   if(hSlow!=INVALID_HANDLE)  IndicatorRelease(hSlow);
   if(hRSI!=INVALID_HANDLE)   IndicatorRelease(hRSI);
   if(hBB!=INVALID_HANDLE)    IndicatorRelease(hBB);
   if(hStoch!=INVALID_HANDLE) IndicatorRelease(hStoch);
   if(hATR!=INVALID_HANDLE)   IndicatorRelease(hATR);
   ObjectsDeleteAll(0,P);
   for(int i=0;i<ArraySize(g_res);i++) ResourceFree("::"+g_res[i]);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| 主循环                                                            |
//+------------------------------------------------------------------+
void OnTick()
  {
   RollDay();
   GetStats(POSITION_TYPE_BUY,g_b);
   GetStats(POSITION_TYPE_SELL,g_s);

   // 1) 账户级风控
   if(CheckGlobalRisk()) { UpdatePanel(); return; }

   // 2) 篮子出场
   bool closed=false;
   if(ManageExit(true,g_b,g_peakB))  closed=true;
   if(ManageExit(false,g_s,g_peakS)) closed=true;
   if(closed)
     {
      GetStats(POSITION_TYPE_BUY,g_b);
      GetStats(POSITION_TYPE_SELL,g_s);
     }

   // 3) 入场 / 加仓
   ManageEntries(true,g_b);
   ManageEntries(false,g_s);
  }

void OnTimer()
  {
   UpdatePanel();
   DrawLines();
  }

//+------------------------------------------------------------------+
//| 统计                                                              |
//+------------------------------------------------------------------+
void GetStats(const ENUM_POSITION_TYPE type,SideStat &s)
  {
   s.n=0; s.lots=0; s.profit=0; s.avg=0; s.ext=0; s.lastLot=0; s.lastTime=0;
   double pv=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong t=PositionGetTicket(i);
      if(t==0) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=InpMagic) continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)!=type) continue;
      double   v=PositionGetDouble(POSITION_VOLUME);
      double   p=PositionGetDouble(POSITION_PRICE_OPEN);
      datetime tm=(datetime)PositionGetInteger(POSITION_TIME);
      s.n++;
      s.lots+=v;
      pv+=p*v;
      s.profit+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
      if(type==POSITION_TYPE_BUY) { if(s.ext==0 || p<s.ext) s.ext=p; }
      else                        { if(p>s.ext) s.ext=p; }
      if(tm>=s.lastTime) { s.lastTime=tm; s.lastLot=v; }
     }
   if(s.lots>0) s.avg=pv/s.lots;
  }

//+------------------------------------------------------------------+
//| 手数计算                                                          |
//+------------------------------------------------------------------+
double NormLot(double lot)
  {
   double step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   double mn=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double mx=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   if(InpMaxLot>0) mx=MathMin(mx,InpMaxLot);
   lot=MathFloor(lot/step+1e-8)*step;
   lot=MathMax(mn,MathMin(mx,lot));
   return NormalizeDouble(lot,g_lotDigits);
  }

double FirstLot()
  {
   double lot=g_firstLot;
   if(InpAutoLotBal>0)
     {
      double k=MathMax(1.0,MathFloor(AccountInfoDouble(ACCOUNT_BALANCE)/InpAutoLotBal));
      lot*=k;
     }
   return lot;
  }

double CalcLot(int n,double lastLot)
  {
   double lot;
   if(n==0) lot=FirstLot();
   else
     {
      switch(InpLotMode)
        {
         case LOT_MARTI: lot=lastLot*g_lotMult;            break;
         case LOT_ARITH: lot=FirstLot()+n*InpLotAdd;        break;
         default:        lot=FirstLot();                    break;
        }
     }
   return NormLot(lot);
  }

//+------------------------------------------------------------------+
//| 间距（点）                                                        |
//+------------------------------------------------------------------+
double StepDistance(int n)
  {
   double base=g_stepPts;
   if(InpStepMode==STEP_ATR && hATR!=INVALID_HANDLE)
     {
      double a[];
      ArraySetAsSeries(a,true);
      if(CopyBuffer(hATR,0,1,1,a)==1 && a[0]>0) base=a[0]*InpAtrMult/_Point;
     }
   return base*MathPow(g_stepMult,MathMax(0,n-1));
  }

//+------------------------------------------------------------------+
//| 入场信号: 1=买 -1=卖 0=无                                         |
//+------------------------------------------------------------------+
bool Buf(int h,int idx,double &arr[],int cnt=3)
  {
   ArraySetAsSeries(arr,true);
   return CopyBuffer(h,idx,0,cnt,arr)==cnt;
  }

int GetSignal()
  {
   int sig=0;
   double a[],b[],c[];
   switch(InpSignal)
     {
      case SIG_NONE: return 0;
      case SIG_MA:
         if(Buf(hFast,0,a) && Buf(hSlow,0,b))
           {
            if(a[2]<=b[2] && a[1]>b[1]) sig=1;
            if(a[2]>=b[2] && a[1]<b[1]) sig=-1;
           }
         break;
      case SIG_RSI:
         if(Buf(hRSI,0,a))
           {
            if(a[1]<=InpRSIBuy)  sig=1;
            if(a[1]>=InpRSISell) sig=-1;
           }
         break;
      case SIG_BOLL:
         if(Buf(hBB,1,a) && Buf(hBB,2,b))
           {
            double cl=iClose(_Symbol,InpSigTf,1);
            if(cl<b[1]) sig=1;
            if(cl>a[1]) sig=-1;
           }
         break;
      case SIG_STOCH:
         if(Buf(hStoch,0,a) && Buf(hStoch,1,b))
           {
            if(a[1]<=InpStochLow  && a[1]>b[1]) sig=1;
            if(a[1]>=InpStochHigh && a[1]<b[1]) sig=-1;
           }
         break;
     }
   if(InpReverse) sig=-sig;
   return sig;
  }

//+------------------------------------------------------------------+
//| 过滤条件                                                          |
//+------------------------------------------------------------------+
bool TimeOK()
  {
   MqlDateTime t; TimeToStruct(TimeCurrent(),t);
   if(InpFriCloseHr>0 && t.day_of_week==5 && t.hour>=InpFriCloseHr) return false;
   if(!InpUseTime) return true;
   if(InpStartHour<=InpEndHour) return (t.hour>=InpStartHour && t.hour<InpEndHour);
   return (t.hour>=InpStartHour || t.hour<InpEndHour);   // 跨午夜
  }

bool EntryAllowed()
  {
   if(!g_running)      { return false; }
   if(g_halt!="")      { return false; }
   if(TimeCurrent()-g_lastOpen<InpMinInterval) return false;
   if(InpMaxSpread>0 && SymbolInfoInteger(_Symbol,SYMBOL_SPREAD)>InpMaxSpread)
     { g_note="Spread too wide - opening paused"; return false; }
   double ml=AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
   if(InpMinMarginLvl>0 && ml>0 && ml<InpMinMarginLvl)
     { g_note="Margin level too low - averaging paused"; return false; }
   return true;
  }

//+------------------------------------------------------------------+
//| 开仓                                                              |
//+------------------------------------------------------------------+
bool OpenOrder(bool isBuy,double lot)
  {
   if(lot<=0) return false;
   if(InpMaxTotalLots>0 && g_b.lots+g_s.lots+lot>InpMaxTotalLots+1e-8)
     { g_note="Max total lots reached"; return false; }

   double price=isBuy?SymbolInfoDouble(_Symbol,SYMBOL_ASK):SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double m;
   if(OrderCalcMargin(isBuy?ORDER_TYPE_BUY:ORDER_TYPE_SELL,_Symbol,lot,price,m) &&
      m>AccountInfoDouble(ACCOUNT_MARGIN_FREE))
     { g_note="Insufficient free margin"; return false; }

   bool ok=isBuy?trade.Buy(lot,_Symbol,0,0,0,InpComment):trade.Sell(lot,_Symbol,0,0,0,InpComment);
   if(ok) { g_lastOpen=TimeCurrent(); g_note=""; }
   else   { g_note="Open failed: "+IntegerToString(trade.ResultRetcode()); Print(g_note," ",trade.ResultRetcodeDescription()); }
   return ok;
  }

void ManageEntries(bool isBuy,SideStat &s)
  {
   if(isBuy  && InpDir==DIR_SELL) return;
   if(!isBuy && InpDir==DIR_BUY)  return;
   if(!EntryAllowed()) return;

   if(s.n==0)   // 首单
     {
      if(!TimeOK()) return;
      if(InpSignal!=SIG_NONE)
        {
         int sig=GetSignal();
         if(isBuy && sig!=1)   return;
         if(!isBuy && sig!=-1) return;
        }
      OpenOrder(isBuy,CalcLot(0,0));
      return;
     }

   if(s.n>=g_maxLevels) return;   // 加仓
   double dist =StepDistance(s.n)*_Point;
   double price=isBuy?SymbolInfoDouble(_Symbol,SYMBOL_ASK):SymbolInfoDouble(_Symbol,SYMBOL_BID);
   bool hit=isBuy?(price<=s.ext-dist):(price>=s.ext+dist);
   if(hit) OpenOrder(isBuy,CalcLot(s.n,s.lastLot));
  }

//+------------------------------------------------------------------+
//| 平仓                                                              |
//+------------------------------------------------------------------+
void CloseSide(bool isBuy)
  {
   ENUM_POSITION_TYPE type=isBuy?POSITION_TYPE_BUY:POSITION_TYPE_SELL;
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong t=PositionGetTicket(i);
      if(t==0) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=InpMagic) continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)!=type) continue;
      trade.PositionClose(t);
     }
  }

void CloseAll() { CloseSide(true); CloseSide(false); }

bool ManageExit(bool isBuy,SideStat &s,double &peak)
  {
   if(s.n==0) { peak=0; return false; }
   bool close=false;

   if(InpBasketSL>0 && s.profit<=-InpBasketSL) close=true;
   else if(InpTrailOn)
     {
      if(s.profit>=InpTrailStart)
        {
         peak=MathMax(peak,s.profit);
         if(s.profit<=peak-InpTrailGap) close=true;
        }
     }
   else if(g_tpMoney>0 && s.profit>=g_tpMoney) close=true;

   if(!close && g_tpPts>0)
     {
      double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
      double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      if(isBuy  && bid>=s.avg+g_tpPts*_Point) close=true;
      if(!isBuy && ask<=s.avg-g_tpPts*_Point) close=true;
     }

   if(close) { CloseSide(isBuy); peak=0; return true; }
   return false;
  }

//+------------------------------------------------------------------+
//| 风控                                                              |
//+------------------------------------------------------------------+
void RollDay()
  {
   datetime d=iTime(_Symbol,PERIOD_D1,0);
   if(d!=g_dayKey)
     {
      g_dayKey=d;
      g_dayStartEq=AccountInfoDouble(ACCOUNT_EQUITY);
      if(g_haltDaily) { g_halt=""; g_haltDaily=false; }
     }
  }

bool CheckGlobalRisk()
  {
   double bal=AccountInfoDouble(ACCOUNT_BALANCE);
   double eq =AccountInfoDouble(ACCOUNT_EQUITY);
   bool   has=(g_b.n+g_s.n)>0;

   // 周五定时全平
   if(InpFriCloseHr>0 && has)
     {
      MqlDateTime t; TimeToStruct(TimeCurrent(),t);
      if(t.day_of_week==5 && t.hour>=InpFriCloseHr)
        { CloseAll(); g_note="Friday close-all"; return true; }
     }

   if(has && g_ddPct>0 && bal>0 && (bal-eq)/bal*100.0>=g_ddPct)
     {
      CloseAll();
      g_halt="Drawdown stop"; g_haltDaily=false; g_running=false;
      Alert("GridPro: account drawdown reached ",DoubleToString(g_ddPct,1),"% - all positions closed, EA halted");
      return true;
     }
   if(g_dayStartEq>0)
     {
      if(InpDailyLoss>0 && (g_dayStartEq-eq)/g_dayStartEq*100.0>=InpDailyLoss && g_halt=="")
        {
         if(has) CloseAll();
         g_halt="Daily loss limit"; g_haltDaily=true;
         return has;
        }
      if(InpDailyProfit>0 && (eq-g_dayStartEq)/g_dayStartEq*100.0>=InpDailyProfit && g_halt=="")
        {
         if(has) CloseAll();
         g_halt="Daily profit target"; g_haltDaily=true;
         return has;
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
//| 图上均价线                                                        |
//+------------------------------------------------------------------+
void DrawLine(string name,double price,color clr)
  {
   name=P+name;
   if(!InpDrawLines || price<=0) { ObjectDelete(0,name); return; }
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_HLINE,0,0,price);
      ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DASH);
      ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
     }
   ObjectSetDouble(0,name,OBJPROP_PRICE,price);
  }

void DrawLines()
  {
   SideStat b,s;
   GetStats(POSITION_TYPE_BUY,b);
   GetStats(POSITION_TYPE_SELL,s);
   DrawLine("L_buy",b.avg,C_GREEN);
   DrawLine("L_sell",s.avg,C_RED);
  }

//+------------------------------------------------------------------+
//| ============================ 面板 ============================== |
//+------------------------------------------------------------------+
void RegRes(string name)
  {
   for(int i=0;i<ArraySize(g_res);i++) if(g_res[i]==name) return;
   int n=ArraySize(g_res);
   ArrayResize(g_res,n+1);
   g_res[n]=name;
  }

// 生成抗锯齿圆角矩形位图资源（带 1px 描边）
void RoundRes(string name,int w,int h,int r,color fill,color border)
  {
   uint px[];
   ArrayResize(px,w*h);
   double fr=(double)((uint)fill&0xFF),   fg=(double)(((uint)fill>>8)&0xFF),   fb=(double)(((uint)fill>>16)&0xFF);
   double br=(double)((uint)border&0xFF), bg=(double)(((uint)border>>8)&0xFF), bb=(double)(((uint)border>>16)&0xFF);
   double hw=w/2.0, hh=h/2.0;
   for(int y=0;y<h;y++)
      for(int x=0;x<w;x++)
        {
         double qx=MathAbs(x+0.5-hw)-(hw-r);
         double qy=MathAbs(y+0.5-hh)-(hh-r);
         double ox=MathMax(qx,0.0), oy=MathMax(qy,0.0);
         double d=MathSqrt(ox*ox+oy*oy)+MathMin(MathMax(qx,qy),0.0)-r;
         double ao=MathMax(0.0,MathMin(1.0,0.5-d));
         double ai=MathMax(0.0,MathMin(1.0,0.5-(d+1.0)));
         uint rr=(uint)MathRound(br+(fr-br)*ai);
         uint gg=(uint)MathRound(bg+(fg-bg)*ai);
         uint b2=(uint)MathRound(bb+(fb-bb)*ai);
         px[y*w+x]=((uint)MathRound(ao*255.0)<<24)|(rr<<16)|(gg<<8)|b2;
        }
   ResourceCreate("::"+name,px,w,h,0,0,w,COLOR_FORMAT_ARGB_NORMALIZE);
   RegRes(name);
  }

void SetBmp(string objName,string resName)
  {
   ObjectSetString(0,objName,OBJPROP_BMPFILE,0,"::"+resName);
   ObjectSetString(0,objName,OBJPROP_BMPFILE,1,"::"+resName);
  }

// 圆角矩形（位图实现，MT5 原生矩形不支持圆角）
void Rect(string id,int x,int y,int w,int h,color bg,color border,int r=10)
  {
   string n=P+id;
   string res="GP_"+id;
   RoundRes(res,w,h,r,bg,border);
   ObjectCreate(0,n,OBJ_BITMAP_LABEL,0,0,0);
   ObjectSetInteger(0,n,OBJPROP_XDISTANCE,InpPanelX+x);
   ObjectSetInteger(0,n,OBJPROP_YDISTANCE,InpPanelY+y);
   SetBmp(n,res);
   ObjectSetInteger(0,n,OBJPROP_BACK,false);
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,n,OBJPROP_ZORDER,0);
  }

void Label(string id,int x,int y,string txt,color clr,int size=9)
  {
   string n=P+id;
   ObjectCreate(0,n,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,n,OBJPROP_XDISTANCE,InpPanelX+x);
   ObjectSetInteger(0,n,OBJPROP_YDISTANCE,InpPanelY+y);
   ObjectSetInteger(0,n,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,n,OBJPROP_FONTSIZE,size);
   ObjectSetString(0,n,OBJPROP_FONT,FONT);
   ObjectSetString(0,n,OBJPROP_TEXT,txt);
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,n,OBJPROP_ZORDER,1);
  }

void Button(string id,int x,int y,int w,int h,string txt,color bg,color fg=clrWhite)
  {
   Rect("r_bb_"+id,x,y,w,h,bg,bg,8);       // 圆角底板
   string n=P+id;
   ObjectCreate(0,n,OBJ_BUTTON,0,0,0);     // 原生按钮内缩 3px 叠在底板上，负责点击
   ObjectSetInteger(0,n,OBJPROP_XDISTANCE,InpPanelX+x+3);
   ObjectSetInteger(0,n,OBJPROP_YDISTANCE,InpPanelY+y+3);
   ObjectSetInteger(0,n,OBJPROP_XSIZE,w-6);
   ObjectSetInteger(0,n,OBJPROP_YSIZE,h-6);
   ObjectSetInteger(0,n,OBJPROP_BGCOLOR,bg);
   ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,bg);
   ObjectSetInteger(0,n,OBJPROP_COLOR,fg);
   ObjectSetInteger(0,n,OBJPROP_FONTSIZE,9);
   ObjectSetString(0,n,OBJPROP_FONT,FONT);
   ObjectSetString(0,n,OBJPROP_TEXT,txt);
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,n,OBJPROP_ZORDER,2);
  }

void EditBox(string id,int x,int y,int w,int h,string txt)
  {
   Rect("r_eb_"+id,x,y,w,h,C_EDIT,InpAccent,7);   // 圆角描边底板
   string n=P+id;
   ObjectCreate(0,n,OBJ_EDIT,0,0,0);
   ObjectSetInteger(0,n,OBJPROP_XDISTANCE,InpPanelX+x+3);
   ObjectSetInteger(0,n,OBJPROP_YDISTANCE,InpPanelY+y+3);
   ObjectSetInteger(0,n,OBJPROP_XSIZE,w-6);
   ObjectSetInteger(0,n,OBJPROP_YSIZE,h-6);
   ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C_EDIT);
   ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C_EDIT);
   ObjectSetInteger(0,n,OBJPROP_COLOR,C_TEXT);
   ObjectSetInteger(0,n,OBJPROP_ALIGN,ALIGN_CENTER);
   ObjectSetInteger(0,n,OBJPROP_FONTSIZE,9);
   ObjectSetString(0,n,OBJPROP_FONT,FONT);
   ObjectSetString(0,n,OBJPROP_TEXT,txt);
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,n,OBJPROP_ZORDER,2);
  }

void ParamRow(string key,string title,int lx,int ex,int y,int ew)
  {
   Label("t_"+key,lx,y+5,title,C_MUTED,8);
   EditBox("E_"+key,ex,y,ew,24,"");
  }

void BuildPanel()
  {
   ObjectsDeleteAll(0,P+"E_");
   ObjectsDeleteAll(0,P+"b_");
   ObjectsDeleteAll(0,P+"t_");
   ObjectsDeleteAll(0,P+"v_");
   ObjectsDeleteAll(0,P+"r_");

   g_runStyle=-1;
   int H=g_minimized?36:408;
   Rect("r_bg",0,0,PW,H,C_BG,InpAccent,16);
   Rect("r_head",3,3,PW-6,30,C_HEAD,C_HEAD,13);
   Rect("r_bar",12,11,4,14,InpAccent,InpAccent,2);
   Label("t_title",24,9,"◆ GRID PRO  "+_Symbol,C_TEXT,10);
   Label("v_status",196,11,"● Running",C_GREEN,8);
   Button("b_min",PW-38,4,28,28,g_minimized?"+":"–",C_EDIT,C_TEXT);
   if(g_minimized) { UpdatePanel(); ChartRedraw(); return; }

   // 账户卡片
   Rect("r_c1",8,42,PW-16,68,C_CARD,C_CARD);
   Label("t_bal",16,50,"Balance",C_MUTED,8);  Label("v_bal",54,49,"-",C_TEXT,9);
   Label("t_eq",172,50,"Equity",C_MUTED,8);   Label("v_eq",210,49,"-",C_TEXT,9);
   Label("t_pl",16,72,"P/L",C_MUTED,8);       Label("v_pl",54,71,"-",C_TEXT,9);
   Label("t_dd",172,72,"DD%",C_MUTED,8);      Label("v_dd",210,71,"-",C_TEXT,9);
   Label("t_sp",16,94,"Spread",C_MUTED,8);    Label("v_sp",54,93,"-",C_TEXT,9);
   Label("t_day",172,94,"Today",C_MUTED,8);   Label("v_day",210,93,"-",C_TEXT,9);

   // 持仓卡片
   Rect("r_c2",8,116,PW-16,46,C_CARD,C_CARD);
   Label("v_b",16,122,"-",C_GREEN,9);
   Label("v_s",16,142,"-",C_RED,9);

   // 参数卡片
   Rect("r_c3",8,168,PW-16,142,C_CARD,C_CARD);
   Label("t_ptitle",16,174,"Params - press Enter to apply",InpAccent,8);
   ParamRow("lot",  "First lot",16, 84,194,64);
   ParamRow("step", "Step pts",172,238,194,72);
   ParamRow("smult","Step mult",16, 84,222,64);
   ParamRow("lmult","Lot mult",172,238,222,72);
   ParamRow("maxlv","Max lvls",16, 84,250,64);
   ParamRow("tp",   "TP $",    172,238,250,72);
   ParamRow("tppts","TP pts",  16, 84,278,64);
   ParamRow("dd",   "DD stop", 172,238,278,72);
   SyncEdits();

   // 按钮
   int bw=BTNW;
   Button("b_run", 8,        318,bw,30,"",C_GREEN);
   Button("b_buy", 8+bw+6,   318,bw,30,"BUY",C'30,110,200');
   Button("b_sell",8+2*(bw+6),318,bw,30,"SELL",C'200,70,90');
   Button("b_cb",  8,        354,bw,30,"Close Buys",C_EDIT,C_TEXT);
   Button("b_cs",  8+bw+6,   354,bw,30,"Close Sells",C_EDIT,C_TEXT);
   Button("b_ca",  8+2*(bw+6),354,bw,30,"Close All",C'150,50,60');

   Label("v_note",14,390,"",C_AMBER,8);
   UpdatePanel();
   ChartRedraw();
  }

void SetT(string id,string txt,color clr=clrNONE)
  {
   string n=P+id;
   ObjectSetString(0,n,OBJPROP_TEXT,txt);
   if(clr!=clrNONE) ObjectSetInteger(0,n,OBJPROP_COLOR,clr);
  }

color PnlColor(double v) { return v>0?C_GREEN:(v<0?C_RED:C_TEXT); }

void SyncEdits()
  {
   ObjectSetString(0,P+"E_lot",  OBJPROP_TEXT,DoubleToString(g_firstLot,g_lotDigits));
   ObjectSetString(0,P+"E_step", OBJPROP_TEXT,DoubleToString(g_stepPts,0));
   ObjectSetString(0,P+"E_smult",OBJPROP_TEXT,DoubleToString(g_stepMult,2));
   ObjectSetString(0,P+"E_lmult",OBJPROP_TEXT,DoubleToString(g_lotMult,2));
   ObjectSetString(0,P+"E_maxlv",OBJPROP_TEXT,IntegerToString(g_maxLevels));
   ObjectSetString(0,P+"E_tp",   OBJPROP_TEXT,DoubleToString(g_tpMoney,2));
   ObjectSetString(0,P+"E_tppts",OBJPROP_TEXT,DoubleToString(g_tpPts,0));
   ObjectSetString(0,P+"E_dd",   OBJPROP_TEXT,DoubleToString(g_ddPct,1));
  }

void UpdatePanel()
  {
   if(!InpShowPanel) return;
   SideStat b,s;
   GetStats(POSITION_TYPE_BUY,b);
   GetStats(POSITION_TYPE_SELL,s);

   double bal=AccountInfoDouble(ACCOUNT_BALANCE);
   double eq =AccountInfoDouble(ACCOUNT_EQUITY);
   double pl =b.profit+s.profit;
   double dd =(bal>0)?MathMax(0.0,(bal-eq)/bal*100.0):0.0;
   double day=eq-g_dayStartEq;

   // 状态
   if(g_halt!="")      SetT("v_status","● "+g_halt,C_RED);
   else if(!g_running) SetT("v_status","● Paused",C_AMBER);
   else                SetT("v_status","● Running",C_GREEN);

   if(g_minimized) return;

   SetT("v_bal",DoubleToString(bal,2));
   SetT("v_eq", DoubleToString(eq,2));
   SetT("v_pl", (pl>=0?"+":"")+DoubleToString(pl,2),PnlColor(pl));
   SetT("v_dd", DoubleToString(dd,2)+"%",dd>=10?C_RED:C_TEXT);
   SetT("v_sp", IntegerToString((int)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD)));
   SetT("v_day",(day>=0?"+":"")+DoubleToString(day,2),PnlColor(day));

   SetT("v_b","▲ BUY   "+IntegerToString(b.n)+" | "+DoubleToString(b.lots,g_lotDigits)+" | "+
        (b.profit>=0?"+":"")+DoubleToString(b.profit,2));
   SetT("v_s","▼ SELL  "+IntegerToString(s.n)+" | "+DoubleToString(s.lots,g_lotDigits)+" | "+
        (s.profit>=0?"+":"")+DoubleToString(s.profit,2));

   // 运行按钮（圆角底板随状态换色）
   int rs=g_running?1:0;
   color rc=g_running?C_AMBER:C_GREEN;
   if(rs!=g_runStyle)
     {
      g_runStyle=rs;
      RoundRes("GP_r_bb_b_run",BTNW,30,8,rc,rc);
      SetBmp(P+"r_bb_b_run","GP_r_bb_b_run");
      ObjectSetInteger(0,P+"b_run",OBJPROP_BGCOLOR,rc);
      ObjectSetInteger(0,P+"b_run",OBJPROP_BORDER_COLOR,rc);
     }
   ObjectSetString(0,P+"b_run",OBJPROP_TEXT,g_running?"⏸ Pause":"▶ Start");
   ObjectSetInteger(0,P+"b_run",OBJPROP_COLOR,C'20,20,20');

   SetT("v_note",g_note);
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| 面板事件                                                          |
//+------------------------------------------------------------------+
void ManualOpen(bool isBuy)
  {
   GetStats(POSITION_TYPE_BUY,g_b);
   GetStats(POSITION_TYPE_SELL,g_s);
   SideStat s=isBuy?g_b:g_s;
   OpenOrder(isBuy,CalcLot(s.n,s.lastLot));
  }

void ApplyEdit(string name)
  {
   string key=StringSubstr(name,StringLen(P)+2);   // 去掉 "GP_E_"
   double v=StringToDouble(ObjectGetString(0,name,OBJPROP_TEXT));

   if(key=="lot"   && v>0)  g_firstLot=v;
   if(key=="step"  && v>0)  g_stepPts=v;
   if(key=="smult" && v>0)  g_stepMult=v;
   if(key=="lmult" && v>0)  g_lotMult=v;
   if(key=="maxlv" && v>=1) g_maxLevels=(int)v;
   if(key=="tp"    && v>=0) g_tpMoney=v;
   if(key=="tppts" && v>=0) g_tpPts=v;
   if(key=="dd"    && v>=0) g_ddPct=v;
   SyncEdits();
   ChartRedraw();
  }

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(!InpShowPanel) return;

   if(id==CHARTEVENT_OBJECT_ENDEDIT && StringFind(sparam,P+"E_")==0)
     { ApplyEdit(sparam); return; }

   if(id!=CHARTEVENT_OBJECT_CLICK) return;
   if(StringFind(sparam,P+"b_")!=0) return;

   if(sparam==P+"b_min")  { g_minimized=!g_minimized; BuildPanel(); return; }
   if(sparam==P+"b_run")
     {
      g_running=!g_running;
      if(g_running) { g_halt=""; g_haltDaily=false; g_note=""; }
     }
   else if(sparam==P+"b_buy")  ManualOpen(true);
   else if(sparam==P+"b_sell") ManualOpen(false);
   else if(sparam==P+"b_cb")   CloseSide(true);
   else if(sparam==P+"b_cs")   CloseSide(false);
   else if(sparam==P+"b_ca")   CloseAll();

   ObjectSetInteger(0,sparam,OBJPROP_STATE,false);   // 按钮弹起
   UpdatePanel();
  }
//+------------------------------------------------------------------+
