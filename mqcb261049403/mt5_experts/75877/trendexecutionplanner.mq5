//+------------------------------------------------------------------+
//|                                        TrendExecutionPlanner.mq5 |
//|            Open-source trend-condition and risk-planning utility |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Jawad Bibar"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Non-trading chart utility for assessing trend conditions and planning a hypothetical position."
#property description "It never opens, modifies or closes orders or positions."
#property strict

input group "Trend-condition model"
input int            InpMAPeriod             = 50;       // Moving-average period
input ENUM_MA_METHOD InpMAMethod             = MODE_EMA; // Moving-average method
input int            InpADXPeriod            = 14;       // ADX period
input int            InpEfficiencyPeriod     = 20;       // Efficiency lookback
input double         InpStrongTrendScore     = 50.0;     // Strong-score threshold (0..100)

input group "Hypothetical risk plan"
input bool           InpRiskFromEquity       = true;     // Use equity (false = balance)
input double         InpRiskPercent          = 1.0;      // Risk per hypothetical position, %
input double         InpStopATRMultiple      = 1.5;      // Stop distance, ATR multiple
input double         InpRewardRisk           = 2.0;      // Target, reward/risk multiple
input double         InpMaxSpreadATRPercent  = 10.0;     // Spread limit, % of ATR

input group "Panel"
input ENUM_BASE_CORNER InpPanelCorner        = CORNER_LEFT_UPPER; // Panel corner
input int            InpPanelX               = 10;       // Horizontal distance, px
input int            InpPanelY               = 25;       // Vertical distance, px
input int            InpRefreshSeconds       = 1;        // Refresh interval, seconds

struct TradePlan
  {
   double entry;
   double stop;
   double target;
   double volume;
   double margin;
   double actual_risk;
   bool   valid;
   bool   margin_ok;
   string note;
  };

int    g_ma_handle  = INVALID_HANDLE;
int    g_adx_handle = INVALID_HANDLE;
int    g_atr_handle = INVALID_HANDLE;
string g_prefix;

//+------------------------------------------------------------------+
//| Kaufman efficiency: straight-line distance divided by path.     |
//+------------------------------------------------------------------+
double EfficiencyRatio()
  {
   double close[];
   const int count=InpEfficiencyPeriod+1;
   if(CopyClose(_Symbol,_Period,1,count,close)!=count)
      return 0.0;

   double path=0.0;
   for(int i=1;i<count;i++)
      path+=MathAbs(close[i]-close[i-1]);

   if(path<=0.0)
      return 0.0;
   return MathAbs(close[count-1]-close[0])/path;
  }

//+------------------------------------------------------------------+
//| Decimal places appropriate for the broker's volume step.       |
//+------------------------------------------------------------------+
int VolumeDigits(const double step)
  {
   int digits=0;
   double value=step;
   while(digits<8 && MathAbs(value-MathRound(value))>1e-8)
     {
      value*=10.0;
      digits++;
     }
   return digits;
  }

//+------------------------------------------------------------------+
//| Build a broker-normalized hypothetical plan.                   |
//+------------------------------------------------------------------+
TradePlan BuildPlan(const ENUM_ORDER_TYPE type,const double entry,const double atr)
  {
   TradePlan plan;
   plan.entry=entry;
   plan.stop=0.0;
   plan.target=0.0;
   plan.volume=0.0;
   plan.margin=0.0;
   plan.actual_risk=0.0;
   plan.valid=false;
   plan.margin_ok=false;
   plan.note="Not available";

   const double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   const long stops_level=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   const double min_distance=MathMax(0.0,(double)stops_level*point);
   const double distance=MathMax(atr*InpStopATRMultiple,min_distance);
   if(point<=0.0 || distance<=0.0)
     {
      plan.note="No valid stop distance";
      return plan;
     }

   if(type==ORDER_TYPE_BUY)
     {
      plan.stop=NormalizeDouble(entry-distance,_Digits);
      plan.target=NormalizeDouble(entry+distance*InpRewardRisk,_Digits);
     }
   else
     {
      plan.stop=NormalizeDouble(entry+distance,_Digits);
      plan.target=NormalizeDouble(entry-distance*InpRewardRisk,_Digits);
     }

   double loss_per_lot=0.0;
   if(!OrderCalcProfit(type,_Symbol,1.0,entry,plan.stop,loss_per_lot))
     {
      plan.note="Unable to price one-lot risk";
      return plan;
     }
   loss_per_lot=MathAbs(loss_per_lot);
   if(loss_per_lot<=0.0)
     {
      plan.note="One-lot risk is unavailable";
      return plan;
     }

   const double capital=(InpRiskFromEquity ? AccountInfoDouble(ACCOUNT_EQUITY) : AccountInfoDouble(ACCOUNT_BALANCE));
   const double requested_risk=capital*InpRiskPercent/100.0;
   const double raw_volume=requested_risk/loss_per_lot;
   const double min_volume=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   const double max_volume=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   const double step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   if(min_volume<=0.0 || max_volume<=0.0 || step<=0.0)
     {
      plan.note="Broker volume rules unavailable";
      return plan;
     }

   double volume=MathFloor((raw_volume+1e-12)/step)*step;
   if(volume<min_volume)
     {
      plan.actual_risk=min_volume*loss_per_lot;
      plan.note="Minimum lot exceeds selected risk";
      return plan;
     }
   string note="OK";
   if(volume>max_volume)
     {
      volume=max_volume;
      note="Capped at broker maximum";
     }
   volume=NormalizeDouble(volume,VolumeDigits(step));

   double margin=0.0;
   if(!OrderCalcMargin(type,_Symbol,volume,entry,margin))
     {
      plan.note="Unable to calculate margin";
      return plan;
     }

   plan.volume=volume;
   plan.margin=margin;
   plan.actual_risk=volume*loss_per_lot;
   plan.margin_ok=(margin<=AccountInfoDouble(ACCOUNT_MARGIN_FREE));
   plan.valid=true;
   plan.note=(plan.margin_ok ? note : "Insufficient free margin");
   return plan;
  }

//+------------------------------------------------------------------+
//| Create or update one panel label.                               |
//+------------------------------------------------------------------+
void SetLabel(const string suffix,const string value,const int y,const color text_color,const int font_size=9)
  {
   const string name=g_prefix+suffix;
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,InpPanelCorner);
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
      ObjectSetString(0,name,OBJPROP_FONT,"Consolas");
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
     }
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,InpPanelX+10);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,InpPanelY+y);
   ObjectSetInteger(0,name,OBJPROP_COLOR,text_color);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetString(0,name,OBJPROP_TEXT,value);
  }

//+------------------------------------------------------------------+
//| Create or update the background panel.                          |
//+------------------------------------------------------------------+
void SetBackground()
  {
   const string name=g_prefix+"background";
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,InpPanelCorner);
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_COLOR,clrDimGray);
      ObjectSetInteger(0,name,OBJPROP_BGCOLOR,C'18,23,31');
      ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
     }
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,InpPanelX);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,InpPanelY);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,610);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,300);
  }

//+------------------------------------------------------------------+
//| Delete only the chart objects owned by this utility.            |
//+------------------------------------------------------------------+
void DeletePanel()
  {
   const int total=ObjectsTotal(0,0,-1);
   for(int i=total-1;i>=0;i--)
     {
      const string name=ObjectName(0,i,0,-1);
      if(StringFind(name,g_prefix)==0)
         ObjectDelete(0,name);
     }
  }

//+------------------------------------------------------------------+
//| Format the price levels of a hypothetical long or short plan.  |
//+------------------------------------------------------------------+
string PlanPriceLine(const string label,const TradePlan &plan)
  {
   if(!plan.valid)
      return label+": "+plan.note;

   return StringFormat("%s  Entry %.*f   |   Stop %.*f   |   Target %.*f",
                       label,_Digits,plan.entry,_Digits,plan.stop,_Digits,plan.target);
  }

//+------------------------------------------------------------------+
//| Format the broker-normalized size and margin line.              |
//+------------------------------------------------------------------+
string PlanSizeLine(const TradePlan &plan)
  {
   if(!plan.valid)
      return "          "+plan.note;

   const int volume_digits=VolumeDigits(SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP));
   return StringFormat("          Risk %.2f   |   Volume %.*f lots   |   Margin %.2f   [%s]",
                       plan.actual_risk,volume_digits,plan.volume,plan.margin,plan.note);
  }

//+------------------------------------------------------------------+
//| Refresh transparent calculations and the on-chart panel.        |
//+------------------------------------------------------------------+
void RenderPanel()
  {
   if(g_ma_handle==INVALID_HANDLE || g_adx_handle==INVALID_HANDLE || g_atr_handle==INVALID_HANDLE)
      return;

   double ma[];
   double adx[];
   double atr[];
   ArraySetAsSeries(ma,true);
   ArraySetAsSeries(adx,true);
   ArraySetAsSeries(atr,true);
   if(CopyBuffer(g_ma_handle,0,1,2,ma)!=2 || CopyBuffer(g_adx_handle,0,1,1,adx)!=1 || CopyBuffer(g_atr_handle,0,1,1,atr)!=1)
      return;

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick) || tick.ask<=0.0 || tick.bid<=0.0 || atr[0]<=0.0)
      return;

   const double close=iClose(_Symbol,_Period,1);
   const double efficiency=EfficiencyRatio();
   const double adx_value=MathMax(0.0,MathMin(100.0,adx[0]));
   int direction=0;
   if(close>ma[0] && ma[0]>ma[1])
      direction=1;
   else if(close<ma[0] && ma[0]<ma[1])
      direction=-1;
   const double score=direction*100.0*efficiency*MathMin(1.0,adx_value/50.0);
   const double spread_percent=100.0*(tick.ask-tick.bid)/atr[0];
   const bool spread_ok=(spread_percent<=InpMaxSpreadATRPercent);
   const TradePlan long_plan=BuildPlan(ORDER_TYPE_BUY,tick.ask,atr[0]);
   const TradePlan short_plan=BuildPlan(ORDER_TYPE_SELL,tick.bid,atr[0]);

   string regime="MIXED / NEUTRAL";
   color regime_color=clrSilver;
   if(score>=InpStrongTrendScore)
     {
      regime="STRONG UP-TREND CONDITION";
      regime_color=clrLimeGreen;
     }
   else if(score<=-InpStrongTrendScore)
     {
      regime="STRONG DOWN-TREND CONDITION";
      regime_color=clrTomato;
     }

   const bool selected_plan_ok=((direction>0 && long_plan.valid && long_plan.margin_ok) ||
                                (direction<0 && short_plan.valid && short_plan.margin_ok));
   const bool condition_pass=(MathAbs(score)>=InpStrongTrendScore && spread_ok && selected_plan_ok);
   const string readiness=(condition_pass ? "PASS - condition and execution checks" : "CHECK - one or more conditions are not met");
   const color readiness_color=(condition_pass ? clrPaleGreen : clrGold);
   const string capital_label=(InpRiskFromEquity ? "equity" : "balance");
   const double capital=(InpRiskFromEquity ? AccountInfoDouble(ACCOUNT_EQUITY) : AccountInfoDouble(ACCOUNT_BALANCE));
   const string currency=AccountInfoString(ACCOUNT_CURRENCY);

   SetBackground();
   SetLabel("title","TREND EXECUTION PLANNER   |   INFORMATION ONLY",8,clrWhite,10);
   SetLabel("sub","Read-only dashboard: no order, position or chart-line changes are performed.",29,clrLightSteelBlue,8);
   SetLabel("regime","REGIME: "+regime,49,regime_color,10);
   SetLabel("metrics",StringFormat("Score %+.1f  |  Efficiency %.1f%%  |  ADX %.1f  |  ATR %.*f",score,100.0*efficiency,adx_value,_Digits,atr[0]),69,clrWhite,9);
   SetLabel("execution",StringFormat("Spread %.1f%% of ATR  |  limit %.1f%%  |  %s",spread_percent,InpMaxSpreadATRPercent,(spread_ok ? "within limit" : "above limit")),89,(spread_ok ? clrPaleGreen : clrGold),9);
   SetLabel("risk",StringFormat("Plan risk %.2f%% of %s = %.2f %s  |  stop %.2f ATR  |  target %.2fR",InpRiskPercent,capital_label,capital*InpRiskPercent/100.0,currency,InpStopATRMultiple,InpRewardRisk),109,clrWhite,9);
   SetLabel("plans","HYPOTHETICAL PLANS  (current Bid / Ask)",134,clrLightSteelBlue,8);
   SetLabel("long_price",PlanPriceLine("LONG ",long_plan),153,(long_plan.valid && long_plan.margin_ok ? clrPaleGreen : clrGold),9);
   SetLabel("long_size",PlanSizeLine(long_plan),172,(long_plan.valid && long_plan.margin_ok ? clrPaleGreen : clrGold),8);
   SetLabel("short_price",PlanPriceLine("SHORT",short_plan),196,(short_plan.valid && short_plan.margin_ok ? clrPaleGreen : clrGold),9);
   SetLabel("short_size",PlanSizeLine(short_plan),215,(short_plan.valid && short_plan.margin_ok ? clrPaleGreen : clrGold),8);
   SetLabel("ready","READINESS: "+readiness,239,readiness_color,9);
   SetLabel("footer",StringFormat("%s %s  |  %s  |  updated %s",_Symbol,EnumToString(_Period),currency,TimeToString(TimeCurrent(),TIME_SECONDS)),262,clrLightSteelBlue,8);
   SetLabel("disclaimer","Condition filter and calculator only - not a forecast, recommendation or execution system.",280,clrSilver,8);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Expert initialization.                                          |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpMAPeriod<2 || InpADXPeriod<2 || InpEfficiencyPeriod<2 ||
      InpStrongTrendScore<0.0 || InpStrongTrendScore>100.0 ||
      InpRiskPercent<=0.0 || InpStopATRMultiple<=0.0 || InpRewardRisk<=0.0 ||
      InpMaxSpreadATRPercent<=0.0 || InpRefreshSeconds<1)
     {
      Print("Invalid Trend Execution Planner input values.");
      return INIT_PARAMETERS_INCORRECT;
     }

   g_prefix="TEP_"+IntegerToString((int)ChartID())+"_";
   g_ma_handle=iMA(_Symbol,_Period,InpMAPeriod,0,InpMAMethod,PRICE_CLOSE);
   g_adx_handle=iADX(_Symbol,_Period,InpADXPeriod);
   g_atr_handle=iATR(_Symbol,_Period,InpADXPeriod);
   if(g_ma_handle==INVALID_HANDLE || g_adx_handle==INVALID_HANDLE || g_atr_handle==INVALID_HANDLE)
     {
      Print("Unable to create indicator handles. Error ",GetLastError());
      return INIT_FAILED;
     }

   EventSetTimer(InpRefreshSeconds);
   RenderPanel();
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Tick event: refreshes information only.                         |
//+------------------------------------------------------------------+
void OnTick()
  {
   RenderPanel();
  }

//+------------------------------------------------------------------+
//| Timer event keeps the panel current between ticks where needed. |
//+------------------------------------------------------------------+
void OnTimer()
  {
   RenderPanel();
  }

//+------------------------------------------------------------------+
//| Release resources and leave the chart clean.                    |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   DeletePanel();
   if(g_ma_handle!=INVALID_HANDLE)
      IndicatorRelease(g_ma_handle);
   if(g_adx_handle!=INVALID_HANDLE)
      IndicatorRelease(g_adx_handle);
   if(g_atr_handle!=INVALID_HANDLE)
      IndicatorRelease(g_atr_handle);
  }
//+------------------------------------------------------------------+
