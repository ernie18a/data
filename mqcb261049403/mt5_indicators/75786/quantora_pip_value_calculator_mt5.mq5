//+------------------------------------------------------------------+
//|                                Quantora Pip Value Calculator MT5 |
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
#property description "Professional pip and point value calculator for MetaTrader 5."
#property description "Calculates broker-aware pip and point values using symbol specifications."

//============================== INPUTS =====================================
input group "========== CALCULATION SETTINGS =========="
input double              InpLotSize            = 0.10;
input bool                InpUseCurrentSymbol   = true;
input string              InpCustomSymbol       = "";

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
#define Q_RED      C'255,82,82'
#define Q_BLUE     C'32,93,145'
#define Q_BORDER   C'62,76,89'
#define Q_DARK2    C'5,14,24'

//============================== STATE ======================================
string g_prefix="QPVC5_";
string g_status="INITIALIZING";
string g_symbol="";
string g_account_currency="";

int    g_digits=0;
double g_point=0.0;
double g_tick_size=0.0;
double g_tick_value=0.0;
double g_contract_size=0.0;
double g_pip_size=0.0;

double g_point_value_per_lot=0.0;
double g_pip_value_per_lot=0.0;

double g_point_value_selected=0.0;
double g_pip_value_selected=0.0;

double g_pip_value_001=0.0;
double g_pip_value_010=0.0;
double g_pip_value_100=0.0;

//============================== HELPERS ====================================
string SelectedSymbol()
{
   if(InpUseCurrentSymbol || StringLen(InpCustomSymbol)==0)
      return _Symbol;

   return InpCustomSymbol;
}

double PipSizeForSymbol(string symbol)
{
   int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);

   if(point<=0.0)
      return 0.0;

   // Standard FX convention:
   // 5-digit and 3-digit symbols: 1 pip = 10 points.
   // Other symbols: 1 pip = 1 point.
   if(digits==3 || digits==5)
      return point*10.0;

   return point;
}

double MoneyValueForDistancePerLot(double distance)
{
   if(g_tick_size<=0.0 || g_tick_value<=0.0 || distance<=0.0)
      return 0.0;

   return (distance/g_tick_size)*g_tick_value;
}

bool CalculateValues()
{
   g_symbol=SelectedSymbol();

   if(!SymbolSelect(g_symbol,true))
   {
      g_status="SYMBOL NOT AVAILABLE";
      return false;
   }

   if(InpLotSize<=0.0)
   {
      g_status="SET VALID LOT SIZE";
      return false;
   }

   g_digits=(int)SymbolInfoInteger(g_symbol,SYMBOL_DIGITS);
   g_point=SymbolInfoDouble(g_symbol,SYMBOL_POINT);
   g_tick_size=SymbolInfoDouble(g_symbol,SYMBOL_TRADE_TICK_SIZE);
   g_tick_value=SymbolInfoDouble(g_symbol,SYMBOL_TRADE_TICK_VALUE);
   g_contract_size=SymbolInfoDouble(g_symbol,SYMBOL_TRADE_CONTRACT_SIZE);
   g_account_currency=AccountInfoString(ACCOUNT_CURRENCY);
   g_pip_size=PipSizeForSymbol(g_symbol);

   if(g_point<=0.0 || g_tick_size<=0.0 || g_tick_value<=0.0 || g_pip_size<=0.0)
   {
      g_status="INVALID SYMBOL DATA";
      return false;
   }

   g_point_value_per_lot=MoneyValueForDistancePerLot(g_point);
   g_pip_value_per_lot=MoneyValueForDistancePerLot(g_pip_size);

   g_point_value_selected=g_point_value_per_lot*InpLotSize;
   g_pip_value_selected=g_pip_value_per_lot*InpLotSize;

   g_pip_value_001=g_pip_value_per_lot*0.01;
   g_pip_value_010=g_pip_value_per_lot*0.10;
   g_pip_value_100=g_pip_value_per_lot*1.00;

   g_status="CALCULATION READY";
   return true;
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

void DeletePanel()
{
   for(int i=ObjectsTotal(0)-1;i>=0;i--)
   {
      string name=ObjectName(0,i);
      if(StringFind(name,g_prefix)==0)
         ObjectDelete(0,name);
   }
}

//============================== DASHBOARD ==================================
void BuildPanel()
{
   if(!InpShowPanel)
      return;

   DeletePanel();

   int x=InpPanelX;
   int y=InpPanelY;

   CreateRectangle(g_prefix+"BG",x,y,520,470,Q_BG,Q_GOLD);

   CreateLabel(g_prefix+"TITLE","QUANTORA",x+18,y+14,14,Q_GOLD,true);
   CreateLabel(g_prefix+"SUB","PIP VALUE CALCULATOR",x+18,y+38,11,Q_WHITE,true);
   CreateLabel(g_prefix+"VER","MT5 v1.00",x+430,y+18,9,Q_GRAY);

   CreateLabel(g_prefix+"STATUS","STATUS: INITIALIZING",x+18,y+76,10,Q_GREEN,true);

   CreateLabel(g_prefix+"SYMBOL","SYMBOL: --",x+18,y+110,10,Q_WHITE);
   CreateLabel(g_prefix+"CUR","ACCOUNT CURRENCY: --",x+270,y+110,10,Q_WHITE);

   CreateLabel(g_prefix+"DIGITS","DIGITS: 0",x+18,y+140,10,Q_GRAY);
   CreateLabel(g_prefix+"LOT","LOT SIZE: 0.10",x+270,y+140,10,Q_GRAY);

   CreateLabel(g_prefix+"PIPSIZE","PIP SIZE: 0.00000",x+18,y+180,10,Q_WHITE);
   CreateLabel(g_prefix+"POINTSIZE","POINT SIZE: 0.00000",x+270,y+180,10,Q_WHITE);

   CreateLabel(g_prefix+"PIPVALUE","PIP VALUE: 0.00",x+18,y+220,13,Q_GOLD,true);
   CreateLabel(g_prefix+"POINTVALUE","POINT VALUE: 0.00",x+270,y+220,11,Q_WHITE,true);

   CreateRectangle(g_prefix+"SEP1",x+18,y+260,484,2,Q_BORDER,Q_BORDER);

   CreateLabel(g_prefix+"QUICK","QUICK PIP VALUES",x+18,y+278,10,Q_GOLD,true);
   CreateLabel(g_prefix+"V001","0.01 LOT: 0.00",x+18,y+310,10,Q_WHITE);
   CreateLabel(g_prefix+"V010","0.10 LOT: 0.00",x+180,y+310,10,Q_WHITE);
   CreateLabel(g_prefix+"V100","1.00 LOT: 0.00",x+350,y+310,10,Q_WHITE);

   CreateRectangle(g_prefix+"SEP2",x+18,y+346,484,2,Q_BORDER,Q_BORDER);

   CreateLabel(g_prefix+"TICKSIZE","TICK SIZE: 0.00000",x+18,y+368,10,Q_GRAY);
   CreateLabel(g_prefix+"TICKVALUE","TICK VALUE: 0.00",x+270,y+368,10,Q_GRAY);

   CreateLabel(g_prefix+"CONTRACT","CONTRACT SIZE: 0.00",x+18,y+398,10,Q_GRAY);
   CreateLabel(g_prefix+"PERLOT","PIP VALUE / 1 LOT: 0.00",x+270,y+398,10,Q_GREEN,true);

   CreateLabel(g_prefix+"FOOT","mql5.com/en/users/quantora/seller",x+18,y+444,9,Q_GOLD);

   ChartRedraw();
}

void UpdatePanel()
{
   if(!InpShowPanel)
      return;

   color status_color=(g_status=="CALCULATION READY" ? Q_GREEN : Q_YELLOW);

   ObjectSetString(0,g_prefix+"STATUS",OBJPROP_TEXT,"STATUS: "+g_status);
   ObjectSetInteger(0,g_prefix+"STATUS",OBJPROP_COLOR,status_color);

   ObjectSetString(0,g_prefix+"SYMBOL",OBJPROP_TEXT,"SYMBOL: "+g_symbol);
   ObjectSetString(0,g_prefix+"CUR",OBJPROP_TEXT,"ACCOUNT CURRENCY: "+g_account_currency);

   ObjectSetString(0,g_prefix+"DIGITS",OBJPROP_TEXT,"DIGITS: "+IntegerToString(g_digits));
   ObjectSetString(0,g_prefix+"LOT",OBJPROP_TEXT,"LOT SIZE: "+DoubleToString(InpLotSize,2));

   ObjectSetString(0,g_prefix+"PIPSIZE",OBJPROP_TEXT,
                   "PIP SIZE: "+DoubleToString(g_pip_size,g_digits));
   ObjectSetString(0,g_prefix+"POINTSIZE",OBJPROP_TEXT,
                   "POINT SIZE: "+DoubleToString(g_point,g_digits));

   ObjectSetString(0,g_prefix+"PIPVALUE",OBJPROP_TEXT,
                   "PIP VALUE: "+DoubleToString(g_pip_value_selected,2)+" "+g_account_currency);
   ObjectSetString(0,g_prefix+"POINTVALUE",OBJPROP_TEXT,
                   "POINT VALUE: "+DoubleToString(g_point_value_selected,2)+" "+g_account_currency);

   ObjectSetString(0,g_prefix+"V001",OBJPROP_TEXT,
                   "0.01 LOT: "+DoubleToString(g_pip_value_001,2)+" "+g_account_currency);
   ObjectSetString(0,g_prefix+"V010",OBJPROP_TEXT,
                   "0.10 LOT: "+DoubleToString(g_pip_value_010,2)+" "+g_account_currency);
   ObjectSetString(0,g_prefix+"V100",OBJPROP_TEXT,
                   "1.00 LOT: "+DoubleToString(g_pip_value_100,2)+" "+g_account_currency);

   ObjectSetString(0,g_prefix+"TICKSIZE",OBJPROP_TEXT,
                   "TICK SIZE: "+DoubleToString(g_tick_size,g_digits));
   ObjectSetString(0,g_prefix+"TICKVALUE",OBJPROP_TEXT,
                   "TICK VALUE: "+DoubleToString(g_tick_value,4)+" "+g_account_currency);

   ObjectSetString(0,g_prefix+"CONTRACT",OBJPROP_TEXT,
                   "CONTRACT SIZE: "+DoubleToString(g_contract_size,2));
   ObjectSetString(0,g_prefix+"PERLOT",OBJPROP_TEXT,
                   "PIP VALUE / 1 LOT: "+DoubleToString(g_pip_value_per_lot,2)+" "+g_account_currency);

   ChartRedraw();
}

//============================== INDICATOR EVENTS ===========================
int OnInit()
{
   if(InpLotSize<=0.0 || InpTimerSeconds<1)
      return INIT_PARAMETERS_INCORRECT;

   IndicatorSetString(INDICATOR_SHORTNAME,"Quantora Pip Value Calculator MT5 v1.00");

   g_symbol=SelectedSymbol();

   BuildPanel();
   CalculateValues();
   UpdatePanel();

   if(!EventSetTimer(InpTimerSeconds))
   {
      Print("Quantora Pip Value Calculator MT5: EventSetTimer failed. Error ",GetLastError());
      return INIT_FAILED;
   }

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   DeletePanel();
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
   CalculateValues();
   UpdatePanel();
}

//===========================================================
// Developed by Quantora
//
// More Professional Trading Robots
//
// https://www.mql5.com/en/users/quantora/seller
//===========================================================
