//+------------------------------------------------------------------+
//|                    Quantora ADR Calculator MT5                   |
//|           Professional Trading Utility for MetaTrader 5          |
//|                                                                  |
//| Copyright © 2026 Quantora                                        |
//| https://www.mql5.com/en/users/quantora/seller                    |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2026 Quantora"
#property link      "https://www.mql5.com/en/users/quantora/seller"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_plots 0
#property description "Professional Average Daily Range calculator for MetaTrader 5."
#property description "Displays ADR, current day range, ADR usage and projected daily range levels."

input group "========== ADR SETTINGS =========="
input int                 InpADRPeriod          = 14;
input bool                InpUseCompletedDays   = true;
input bool                InpShowADRLevels      = true;
input bool                InpShowPips           = true;
input bool                InpShowPoints         = true;

input group "========== DASHBOARD =========="
input bool                InpShowPanel          = true;
input ENUM_BASE_CORNER    InpPanelCorner        = CORNER_LEFT_UPPER;
input int                 InpPanelX             = 15;
input int                 InpPanelY             = 145;
input int                 InpTimerSeconds       = 1;

//============================== BRAND COLORS ===============================
#define Q_BG       C'8,23,38'
#define Q_GOLD     C'212,175,55'
#define Q_WHITE    C'245,245,245'
#define Q_GRAY     C'169,176,184'
#define Q_GREEN    C'0,200,83'
#define Q_YELLOW   C'255,193,7'
#define Q_ORANGE   C'255,152,0'
#define Q_RED      C'255,82,82'
#define Q_BLUE     C'32,93,145'
#define Q_BORDER   C'62,76,89'
#define Q_DARK2    C'5,14,24'

//============================== STATE ======================================
string g_prefix="QADR5_";
string g_status="INITIALIZING";

double g_adr_price=0.0;
double g_adr_points=0.0;
double g_adr_pips=0.0;

double g_today_high=0.0;
double g_today_low=0.0;
double g_today_open=0.0;
double g_today_range_price=0.0;
double g_today_range_points=0.0;
double g_today_range_pips=0.0;

double g_adr_used_pct=0.0;
double g_remaining_price=0.0;
double g_remaining_points=0.0;
double g_remaining_pips=0.0;

double g_adr_high=0.0;
double g_adr_low=0.0;

//============================== HELPERS ====================================
int PipFactor()
{
   int digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
   return (digits==3 || digits==5 ? 10 : 1);
}

double PointSize()
{
   return SymbolInfoDouble(_Symbol,SYMBOL_POINT);
}

double PriceToPoints(double distance)
{
   double point=PointSize();
   return (point>0.0 ? distance/point : 0.0);
}

double PriceToPips(double distance)
{
   int pf=PipFactor();
   return (pf>0 ? PriceToPoints(distance)/pf : 0.0);
}

bool LoadDailyRates(MqlRates &rates[])
{
   int start_shift=(InpUseCompletedDays ? 1 : 0);
   int need=InpADRPeriod+start_shift;

   ArraySetAsSeries(rates,true);
   int copied=CopyRates(_Symbol,PERIOD_D1,0,need,rates);

   if(copied<need)
      return false;

   return true;
}

bool CalculateADR()
{
   if(InpADRPeriod<1)
   {
      g_status="INVALID ADR PERIOD";
      return false;
   }

   MqlRates rates[];
   if(!LoadDailyRates(rates))
   {
      g_status="WAITING FOR DAILY HISTORY";
      return false;
   }

   int start_shift=(InpUseCompletedDays ? 1 : 0);

   double total=0.0;
   int valid=0;

   for(int i=start_shift;i<start_shift+InpADRPeriod;i++)
   {
      double range=rates[i].high-rates[i].low;
      if(range<=0.0)
         continue;

      total+=range;
      valid++;
   }

   if(valid<=0)
   {
      g_status="NO VALID DAILY DATA";
      return false;
   }

   g_adr_price=total/valid;
   g_adr_points=PriceToPoints(g_adr_price);
   g_adr_pips=PriceToPips(g_adr_price);

   MqlRates today[1];
   ArraySetAsSeries(today,true);

   if(CopyRates(_Symbol,PERIOD_D1,0,1,today)!=1)
   {
      g_status="WAITING FOR TODAY DATA";
      return false;
   }

   g_today_open=today[0].open;
   g_today_high=today[0].high;
   g_today_low=today[0].low;

   g_today_range_price=MathMax(0.0,g_today_high-g_today_low);
   g_today_range_points=PriceToPoints(g_today_range_price);
   g_today_range_pips=PriceToPips(g_today_range_price);

   g_adr_used_pct=(g_adr_price>0.0 ? 100.0*g_today_range_price/g_adr_price : 0.0);

   g_remaining_price=MathMax(0.0,g_adr_price-g_today_range_price);
   g_remaining_points=PriceToPoints(g_remaining_price);
   g_remaining_pips=PriceToPips(g_remaining_price);

   g_adr_high=g_today_open+g_adr_price;
   g_adr_low=g_today_open-g_adr_price;

   g_status="CALCULATION READY";
   return true;
}

color UsageColor()
{
   if(g_adr_used_pct<50.0)
      return Q_GREEN;
   if(g_adr_used_pct<80.0)
      return Q_YELLOW;
   if(g_adr_used_pct<100.0)
      return Q_ORANGE;
   return Q_RED;
}

//============================== OBJECT HELPERS =============================
bool CreateRectangle(string name,int x,int y,int width,int height,color background,color border)
{
   if(!ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0))
      return false;

   ObjectSetInteger(0,name,OBJPROP_CORNER,InpPanelCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,background);
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,border);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);

   return true;
}

bool CreateLabel(string name,string text,int x,int y,int size,color text_color,bool bold=false)
{
   if(!ObjectCreate(0,name,OBJ_LABEL,0,0,0))
      return false;

   ObjectSetInteger(0,name,OBJPROP_CORNER,InpPanelCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_COLOR,text_color);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,size);
   ObjectSetString(0,name,OBJPROP_FONT,(bold ? "Arial Bold" : "Arial"));
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);

   return true;
}

void DeleteObjects()
{
   for(int i=ObjectsTotal(0)-1;i>=0;i--)
   {
      string name=ObjectName(0,i);
      if(StringFind(name,g_prefix)==0)
         ObjectDelete(0,name);
   }
}

void CreateADRLine(string name,double price,color clr,ENUM_LINE_STYLE style)
{
   if(!ObjectCreate(0,name,OBJ_HLINE,0,0,price))
      return;

   ObjectSetDouble(0,name,OBJPROP_PRICE,price);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
}

void BuildPanel()
{
   if(!InpShowPanel)
      return;

   int x=InpPanelX;
   int y=InpPanelY;

   CreateRectangle(g_prefix+"BG",x,y,500,430,Q_BG,Q_GOLD);

   CreateLabel(g_prefix+"TITLE","QUANTORA",x+18,y+14,14,Q_GOLD,true);
   CreateLabel(g_prefix+"SUB","ADR CALCULATOR",x+18,y+38,11,Q_WHITE,true);
   CreateLabel(g_prefix+"VER","MT5 v1.00",x+410,y+18,9,Q_GRAY);

   CreateLabel(g_prefix+"STATUS","STATUS: INITIALIZING",x+18,y+74,10,Q_GREEN,true);

   CreateLabel(g_prefix+"SYMBOL","SYMBOL: "+_Symbol,x+18,y+106,10,Q_WHITE);
   CreateLabel(g_prefix+"PERIOD","ADR PERIOD: "+IntegerToString(InpADRPeriod),x+260,y+106,10,Q_WHITE);

   CreateLabel(g_prefix+"ADR","AVERAGE DAILY RANGE: 0.0",x+18,y+146,12,Q_GOLD,true);
   CreateLabel(g_prefix+"TODAY","TODAY RANGE: 0.0",x+18,y+182,11,Q_WHITE,true);
   CreateLabel(g_prefix+"USED","ADR USED: 0.0 %",x+260,y+182,11,Q_GREEN,true);

   CreateLabel(g_prefix+"HIGH","TODAY HIGH: 0.00000",x+18,y+220,10,Q_WHITE);
   CreateLabel(g_prefix+"LOW","TODAY LOW: 0.00000",x+260,y+220,10,Q_WHITE);

   CreateLabel(g_prefix+"OPEN","TODAY OPEN: 0.00000",x+18,y+248,10,Q_GRAY);
   CreateLabel(g_prefix+"REMAIN","REMAINING RANGE: 0.0",x+260,y+248,10,Q_GRAY);

   CreateLabel(g_prefix+"ADRHIGH","ADR HIGH: 0.00000",x+18,y+286,10,Q_GREEN,true);
   CreateLabel(g_prefix+"ADRLOW","ADR LOW: 0.00000",x+260,y+286,10,Q_RED,true);

   CreateLabel(g_prefix+"POINTS","ADR POINTS: 0.0",x+18,y+322,10,Q_GRAY);
   CreateLabel(g_prefix+"PIPS","ADR PIPS: 0.0",x+260,y+322,10,Q_GRAY);

   CreateRectangle(g_prefix+"PB_BG",x+18,y+356,464,22,Q_DARK2,Q_BORDER);
   CreateRectangle(g_prefix+"PB_FILL",x+20,y+358,1,18,Q_GREEN,Q_GREEN);

   CreateLabel(g_prefix+"FOOT","mql5.com/en/users/quantora/seller",x+18,y+402,9,Q_GOLD);

   ChartRedraw();
}

void UpdateADRLines()
{
   string high_name=g_prefix+"ADR_HIGH_LINE";
   string low_name=g_prefix+"ADR_LOW_LINE";

   if(!InpShowADRLevels)
   {
      ObjectDelete(0,high_name);
      ObjectDelete(0,low_name);
      return;
   }

   if(ObjectFind(0,high_name)<0)
      CreateADRLine(high_name,g_adr_high,Q_GREEN,STYLE_DASH);
   else
      ObjectSetDouble(0,high_name,OBJPROP_PRICE,g_adr_high);

   if(ObjectFind(0,low_name)<0)
      CreateADRLine(low_name,g_adr_low,Q_RED,STYLE_DASH);
   else
      ObjectSetDouble(0,low_name,OBJPROP_PRICE,g_adr_low);
}

void UpdatePanel()
{
   if(!InpShowPanel)
      return;

   int digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
   color used_color=UsageColor();

   ObjectSetString(0,g_prefix+"STATUS",OBJPROP_TEXT,"STATUS: "+g_status);
   ObjectSetInteger(0,g_prefix+"STATUS",OBJPROP_COLOR,
                    g_status=="CALCULATION READY" ? Q_GREEN : Q_YELLOW);

   string adr_text="AVERAGE DAILY RANGE: ";
   if(InpShowPoints)
      adr_text+=DoubleToString(g_adr_points,1)+" pts";
   if(InpShowPips)
      adr_text+=(InpShowPoints ? " / " : "")+DoubleToString(g_adr_pips,1)+" pips";

   string today_text="TODAY RANGE: ";
   if(InpShowPoints)
      today_text+=DoubleToString(g_today_range_points,1)+" pts";
   if(InpShowPips)
      today_text+=(InpShowPoints ? " / " : "")+DoubleToString(g_today_range_pips,1)+" pips";

   string remain_text="REMAINING RANGE: ";
   if(InpShowPoints)
      remain_text+=DoubleToString(g_remaining_points,1)+" pts";
   if(InpShowPips)
      remain_text+=(InpShowPoints ? " / " : "")+DoubleToString(g_remaining_pips,1)+" pips";

   ObjectSetString(0,g_prefix+"SYMBOL",OBJPROP_TEXT,"SYMBOL: "+_Symbol);
   ObjectSetString(0,g_prefix+"PERIOD",OBJPROP_TEXT,"ADR PERIOD: "+IntegerToString(InpADRPeriod));
   ObjectSetString(0,g_prefix+"ADR",OBJPROP_TEXT,adr_text);
   ObjectSetString(0,g_prefix+"TODAY",OBJPROP_TEXT,today_text);
   ObjectSetString(0,g_prefix+"USED",OBJPROP_TEXT,"ADR USED: "+DoubleToString(g_adr_used_pct,1)+" %");
   ObjectSetInteger(0,g_prefix+"USED",OBJPROP_COLOR,used_color);

   ObjectSetString(0,g_prefix+"HIGH",OBJPROP_TEXT,"TODAY HIGH: "+DoubleToString(g_today_high,digits));
   ObjectSetString(0,g_prefix+"LOW",OBJPROP_TEXT,"TODAY LOW: "+DoubleToString(g_today_low,digits));
   ObjectSetString(0,g_prefix+"OPEN",OBJPROP_TEXT,"TODAY OPEN: "+DoubleToString(g_today_open,digits));
   ObjectSetString(0,g_prefix+"REMAIN",OBJPROP_TEXT,remain_text);

   ObjectSetString(0,g_prefix+"ADRHIGH",OBJPROP_TEXT,"ADR HIGH: "+DoubleToString(g_adr_high,digits));
   ObjectSetString(0,g_prefix+"ADRLOW",OBJPROP_TEXT,"ADR LOW: "+DoubleToString(g_adr_low,digits));

   ObjectSetString(0,g_prefix+"POINTS",OBJPROP_TEXT,"ADR POINTS: "+DoubleToString(g_adr_points,1));
   ObjectSetString(0,g_prefix+"PIPS",OBJPROP_TEXT,"ADR PIPS: "+DoubleToString(g_adr_pips,1));

   int fill=(int)MathRound(460.0*MathMin(g_adr_used_pct,100.0)/100.0);
   fill=MathMax(1,MathMin(460,fill));

   ObjectSetInteger(0,g_prefix+"PB_FILL",OBJPROP_XSIZE,fill);
   ObjectSetInteger(0,g_prefix+"PB_FILL",OBJPROP_BGCOLOR,used_color);
   ObjectSetInteger(0,g_prefix+"PB_FILL",OBJPROP_BORDER_COLOR,used_color);

   ChartRedraw();
}

//============================== INDICATOR EVENTS ===========================
int OnInit()
{
   if(InpADRPeriod<1 || InpTimerSeconds<1)
      return INIT_PARAMETERS_INCORRECT;

   IndicatorSetString(INDICATOR_SHORTNAME,"Quantora ADR Calculator MT5 v1.00");

   BuildPanel();
   CalculateADR();
   UpdatePanel();
   UpdateADRLines();

   if(!EventSetTimer(InpTimerSeconds))
   {
      Print("Quantora ADR Calculator MT5: EventSetTimer failed. Error ",GetLastError());
      return INIT_FAILED;
   }

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   DeleteObjects();
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   return rates_total;
}

void OnTimer()
{
   CalculateADR();
   UpdatePanel();
   UpdateADRLines();
}

//===========================================================
// Developed by Quantora
//
// More Professional Trading Robots
//
// https://www.mql5.com/en/users/quantora/seller
//===========================================================
