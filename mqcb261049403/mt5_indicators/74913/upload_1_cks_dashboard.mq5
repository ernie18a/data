#property copyright "Cheng Kah Seng"
#property version   "1.00"
#property strict
#property description "Displays account, symbol, position-risk and suggested-volume information."
#property indicator_chart_window
#property indicator_plots 0

input group "Risk Calculation"
input double InpRiskPercent=1.0;
input int    InpPlannedStopPoints=200;
input bool   InpUseEquity=true;
input double InpMaximumSuggestedLot=10.0;

input group "Dashboard"
input ENUM_BASE_CORNER InpCorner=CORNER_LEFT_UPPER;
input int    InpX=15;
input int    InpY=25;
input int    InpWidth=330;
input color  InpBackground=C'22,27,38';
input color  InpTextColor=clrWhite;
input color  InpAccentColor=C'0,190,160';
input color  InpWarningColor=C'255,175,70';
input int    InpRefreshSeconds=1;

string PREFIX="CKS_RISK_";

double NormalizeVolume(const double requested)
{
   double minimum=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double maximum=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   if(step<=0.0) step=minimum;
   maximum=MathMin(maximum,InpMaximumSuggestedLot);
   double volume=MathFloor(requested/step+1e-9)*step;
   volume=MathMax(minimum,MathMin(maximum,volume));
   return NormalizeDouble(volume,8);
}

double SuggestedVolume()
{
   if(InpRiskPercent<=0.0 || InpPlannedStopPoints<=0) return 0.0;
   double capital=InpUseEquity?AccountInfoDouble(ACCOUNT_EQUITY):AccountInfoDouble(ACCOUNT_BALANCE);
   double riskMoney=capital*InpRiskPercent/100.0;
   double tickSize=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   double tickValue=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE_LOSS);
   double stopDistance=InpPlannedStopPoints*_Point;
   if(capital<=0.0 || tickSize<=0.0 || tickValue<=0.0 || stopDistance<=0.0) return 0.0;
   return NormalizeVolume(riskMoney/(stopDistance/tickSize*tickValue));
}

int SymbolPositions()
{
   int count=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket>0 && PositionGetString(POSITION_SYMBOL)==_Symbol) count++;
   }
   return count;
}

double SymbolFloatingProfit()
{
   double result=0.0;
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0 || PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      result+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
   }
   return result;
}

double SymbolOpenRisk()
{
   double result=0.0;
   double tickSize=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   double tickValue=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE_LOSS);
   if(tickSize<=0.0 || tickValue<=0.0) return 0.0;
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0 || PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      double openPrice=PositionGetDouble(POSITION_PRICE_OPEN);
      double stopLoss=PositionGetDouble(POSITION_SL);
      double volume=PositionGetDouble(POSITION_VOLUME);
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      if(stopLoss<=0.0) continue;
      bool protective=(type==POSITION_TYPE_BUY?stopLoss<openPrice:stopLoss>openPrice);
      if(protective) result+=MathAbs(openPrice-stopLoss)/tickSize*tickValue*volume;
   }
   return result;
}

void SetLabel(const string suffix,const int x,const int y,const string text,const color clr,const int size=9)
{
   string name=PREFIX+suffix;
   if(ObjectFind(0,name)<0) ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,InpCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,size);
   ObjectSetString(0,name,OBJPROP_FONT,"Segoe UI");
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
}

string TimeframeName()
{
   string value=EnumToString((ENUM_TIMEFRAMES)_Period);
   StringReplace(value,"PERIOD_","");
   return value;
}

void DrawDashboard()
{
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick)) return;
   double balance=AccountInfoDouble(ACCOUNT_BALANCE);
   double equity=AccountInfoDouble(ACCOUNT_EQUITY);
   double freeMargin=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double marginLevel=AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
   double riskMoney=(InpUseEquity?equity:balance)*InpRiskPercent/100.0;
   double suggested=SuggestedVolume();
   double openRisk=SymbolOpenRisk();
   double openRiskPercent=(equity>0.0?openRisk/equity*100.0:0.0);
   double floating=SymbolFloatingProfit();
   long spread=SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
   double minimum=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double maximum=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);

   string body=StringFormat(
      "Symbol / timeframe       %s / %s\n"
      "Bid / Ask                %.*f / %.*f\n"
      "Spread                   %d points\n"
      "Balance                  %.2f\n"
      "Equity                   %.2f\n"
      "Free margin              %.2f\n"
      "Margin level             %.2f%%\n"
      "Planned risk             %.2f%% / %.2f\n"
      "Planned stop             %d points\n"
      "Suggested volume         %.2f lots\n"
      "Broker volume limits     %.2f / %.2f / %.2f\n"
      "Symbol positions         %d\n"
      "Symbol floating P/L      %.2f\n"
      "Protected open risk      %.2f (%.2f%%)",
      _Symbol,TimeframeName(),_Digits,tick.bid,_Digits,tick.ask,spread,balance,equity,freeMargin,
      marginLevel,InpRiskPercent,riskMoney,InpPlannedStopPoints,suggested,minimum,maximum,step,
      SymbolPositions(),floating,openRisk,openRiskPercent);

   string background=PREFIX+"BACKGROUND";
   if(ObjectFind(0,background)<0) ObjectCreate(0,background,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,background,OBJPROP_CORNER,InpCorner);
   ObjectSetInteger(0,background,OBJPROP_XDISTANCE,InpX);
   ObjectSetInteger(0,background,OBJPROP_YDISTANCE,InpY);
   ObjectSetInteger(0,background,OBJPROP_XSIZE,InpWidth);
   ObjectSetInteger(0,background,OBJPROP_YSIZE,305);
   ObjectSetInteger(0,background,OBJPROP_BGCOLOR,InpBackground);
   ObjectSetInteger(0,background,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,background,OBJPROP_COLOR,InpAccentColor);
   ObjectSetInteger(0,background,OBJPROP_SELECTABLE,false);

   SetLabel("TITLE",InpX+14,InpY+12,"CKS POSITION RISK DASHBOARD",InpAccentColor,11);
   SetLabel("BODY",InpX+14,InpY+38,body,InpTextColor,9);
   string status=(suggested>0.0?"CALCULATION READY":"CHECK SYMBOL DATA / INPUTS");
   SetLabel("STATUS",InpX+14,InpY+278,status,suggested>0.0?InpAccentColor:InpWarningColor,9);
   ChartRedraw();
}

int OnInit()
{
   if(InpRiskPercent<0.0 || InpPlannedStopPoints<0 || InpMaximumSuggestedLot<=0.0 || InpRefreshSeconds<1)
      return INIT_PARAMETERS_INCORRECT;
   IndicatorSetString(INDICATOR_SHORTNAME,"CKS Position Risk Dashboard");
   EventSetTimer(InpRefreshSeconds);
   DrawDashboard();
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   ObjectsDeleteAll(0,PREFIX);
   ChartRedraw();
}

void OnTimer()
{
   DrawDashboard();
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
