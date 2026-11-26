//+------------------------------------------------------------------+
//|                                                       AtrMonitor |
//|                                 Copyright 2026, Nima Foroozanfar |
//|                       https://www.mql5.com/en/users/trade.aibots |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#property copyright "https://www.mql5.com/en/users/trade.aibots"
#property description "Compact D1/W1/MN1 ATR, range, range/ATR and move from open."
#property description "Uses candle 0. Updates on ticks; includes minimize/restore."
#property indicator_chart_window
#property indicator_buffers 0

// Calculation
input int    ATRPeriod       = 14;     // ATR period for D1, W1 and MN1
input double MaxATRPercent   = 100.0;  // Highlight Used at/above this percentage

// Panel
input int    PanelX          = 7;      // Panel left position in pixels
input int    PanelY          = 30;     // Panel top position in pixels
input int    PanelXSize      = 400;    // Panel width before scaling
input int    PanelYSize      = 146;    // Panel height before scaling
input double PanelScale      = 1.0;    // Scale panel dimensions and font

// Colors
input color  BackgroundColor = C'13,25,39';
input color  BorderColor     = C'57,77,95';
input color  TextColor       = C'225,234,243';
input color  MutedColor      = C'155,174,192';
input color  HeaderColor     = C'97,215,236';
input color  UpColor         = C'40,214,167';
input color  DownColor       = C'244,111,117';
input color  MaxATRColor     = C'255,190,65';

bool PanelMinimized = false;
ENUM_TIMEFRAMES TimeFrames[3] = {PERIOD_D1, PERIOD_W1, PERIOD_MN1};
string PeriodNames[3] = {"Day", "Week", "Month"};
string ObjectPrefix = "";
//+------------------------------------------------------------------+
//| Validate inputs and create the panel once.                      |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(ATRPeriod<1 || MaxATRPercent<=0 || !MathIsValidNumber(MaxATRPercent) ||
      PanelX<0 || PanelY<0 || PanelXSize<1 || PanelYSize<1 ||
      PanelScale<0.5 || PanelScale>3.0 || !MathIsValidNumber(PanelScale))
     {
      Print("ATR Monitor: use positive period, threshold and sizes; nonnegative X/Y; scale 0.5..3.");
      return INIT_PARAMETERS_INCORRECT;
     }

   ObjectPrefix="AtrMonitor_"+IntegerToString((long)GetMicrosecondCount())+"_";

   IndicatorShortName("ATR Monitor ("+IntegerToString(ATRPeriod)+")");

   if(!CreatePanel())
      return INIT_FAILED;

   RefreshValues();

   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Delete only this indicator instance's chart objects.            |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(ObjectPrefix!="")
      ObjectsDeleteAll(0,ObjectPrefix);
  }

//+------------------------------------------------------------------+
//| Refresh current values on ticks and retry data that is loading.  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &time[],const double &open[],
                const double &high[],const double &low[],const double &close[],
                const long &tick_volume[],const long &volume[],const int &spread[])
  {
   if(!PanelMinimized)
      RefreshValues();

   return rates_total;
  }

//+------------------------------------------------------------------+
//| Minimize or restore the table when its title button is clicked.  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id!=CHARTEVENT_OBJECT_CLICK || sparam!=ObjectPrefix+"toggle")
      return;

   PanelMinimized=!PanelMinimized;

   ObjectsDeleteAll(0,ObjectPrefix);

   if(!CreatePanel())
      Print("ATR Monitor: could not rebuild the panel.");

   if(!PanelMinimized)
      RefreshValues();

   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Convert broker points to pips using the symbol's quote digits.   |
//+------------------------------------------------------------------+
double PointsToPips(const double points)
  {
   return points/((_Digits==3 || _Digits==5) ? 10.0 : 1.0);
  }

//+------------------------------------------------------------------+
//| Create a label at a proportional position inside the panel.      |
//+------------------------------------------------------------------+
bool CreateLabel(const string suffix,const double x,const double y,
                 const string text,const color textColor,const bool right=false)
  {
   string name=ObjectPrefix+suffix;
   if(!ObjectCreate(0,name,OBJ_LABEL,0,0,0))
      return false;
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,right ? ANCHOR_RIGHT_UPPER : ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,PanelX+(int)MathRound(x*PanelXSize*PanelScale));
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,PanelY+(int)MathRound(y*PanelYSize*PanelScale));
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,(int)MathRound(9*PanelScale));
   ObjectSetInteger(0,name,OBJPROP_COLOR,textColor);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   return true;
  }

//+------------------------------------------------------------------+
//| Draw the background, headers and three rows using input sizes.   |
//+------------------------------------------------------------------+
bool CreatePanel()
  {
   string name=ObjectPrefix+"background";

   if(!ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0))
      return false;

   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,PanelX);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,PanelY);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,(int)MathRound(PanelXSize*PanelScale));
   ObjectSetInteger(0,name,OBJPROP_YSIZE,(int)MathRound((PanelMinimized ? 28 : PanelYSize)*PanelScale));
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,BackgroundColor);
   ObjectSetInteger(0,name,OBJPROP_COLOR,BorderColor);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);

   if(!CreateLabel("title",0.03,0.05,_Symbol+" | ATR "+IntegerToString(ATRPeriod),HeaderColor))
      return false;

   ObjectSetString(0,ObjectPrefix+"title",OBJPROP_TOOLTIP,
                   "ATR, Range and From open are in pips. ATR % = range / ATR x 100.");

// Keep the title at the same height when the table is minimized.
   ObjectSetInteger(0,ObjectPrefix+"title",OBJPROP_YDISTANCE,PanelY+(int)MathRound(6*PanelScale));

   string buttonName=ObjectPrefix+"toggle";

   if(!ObjectCreate(0,buttonName,OBJ_BUTTON,0,0,0))
      return false;

   ObjectSetInteger(0,buttonName,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,buttonName,OBJPROP_XDISTANCE,PanelX+(int)MathRound((PanelXSize-25)*PanelScale));
   ObjectSetInteger(0,buttonName,OBJPROP_YDISTANCE,PanelY+(int)MathRound(4*PanelScale));
   ObjectSetInteger(0,buttonName,OBJPROP_XSIZE,(int)MathRound(20*PanelScale));
   ObjectSetInteger(0,buttonName,OBJPROP_YSIZE,(int)MathRound(20*PanelScale));
   ObjectSetInteger(0,buttonName,OBJPROP_BGCOLOR,BackgroundColor);
   ObjectSetInteger(0,buttonName,OBJPROP_BORDER_COLOR,BorderColor);
   ObjectSetInteger(0,buttonName,OBJPROP_COLOR,HeaderColor);
   ObjectSetInteger(0,buttonName,OBJPROP_FONTSIZE,(int)MathRound(9*PanelScale));
   ObjectSetInteger(0,buttonName,OBJPROP_ZORDER,10);
   ObjectSetInteger(0,buttonName,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,buttonName,OBJPROP_HIDDEN,true);
   ObjectSetString(0,buttonName,OBJPROP_TEXT,PanelMinimized ? "+" : "-");
   ObjectSetString(0,buttonName,OBJPROP_TOOLTIP,PanelMinimized ? "Restore table" : "Minimize table");

   if(PanelMinimized)
      return true;

   string headings[5]= {"Period","ATR","Range","ATR %","From open"};
   string explanations[5]= {"Current daily, weekly and monthly candles",
                            "Current ATR in pips",
                            "Current high minus low, in pips",
                            "Range divided by ATR, as a percentage",
                            "Current price minus period open, in pips"
                           };

   double positions[5]= {0.03,0.32,0.51,0.69,0.97};

   for(int col=0;col<5;col++)
     {
      if(!CreateLabel("header"+IntegerToString(col),positions[col],0.25,
                      headings[col],MutedColor,col>0))
         return false;

      ObjectSetString(0,ObjectPrefix+"header"+IntegerToString(col),OBJPROP_TOOLTIP,explanations[col]);

      for(int row=0;row<3;row++)
         if(!CreateLabel(IntegerToString(row)+"_"+IntegerToString(col),
                         positions[col],0.43+row*0.175,
                         col==0 ? PeriodNames[row] : "--",TextColor,col>0))
            return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Set the text and color of an existing data cell.                   |
//+------------------------------------------------------------------+
void UpdateCell(const int row,const int col,const string text,const color textColor)
  {
   string name=ObjectPrefix+IntegerToString(row)+"_"+IntegerToString(col);

   if(ObjectGetString(0,name,OBJPROP_TEXT)!=text)
      ObjectSetString(0,name,OBJPROP_TEXT,text);

   if((color)ObjectGetInteger(0,name,OBJPROP_COLOR)!=textColor)
      ObjectSetInteger(0,name,OBJPROP_COLOR,textColor);
  }

//+------------------------------------------------------------------+
//| Read current candle values and update the table cells.           |
//+------------------------------------------------------------------+
void RefreshValues()
  {
   for(int row=0;row<3;row++)
     {
      MqlRates candle[1];
      ResetLastError();
      bool hasCandle=CopyRates(_Symbol,TimeFrames[row],0,1,candle)==1;
      double atr=iATR(_Symbol,TimeFrames[row],ATRPeriod,0);
      int dataError=GetLastError();

      if(!hasCandle || dataError!=0 || iBars(_Symbol,TimeFrames[row])<=ATRPeriod ||
         !MathIsValidNumber(atr) || atr==EMPTY_VALUE || atr<0)
        {
         for(int col=1;col<5;col++)
            UpdateCell(row,col,"--",MutedColor);
         continue;
        }

      double range=candle[0].high-candle[0].low;
      double changeFromOpen=NormalizeDouble(PointsToPips((candle[0].close-candle[0].open)/_Point),1);

      UpdateCell(row,1,DoubleToString(PointsToPips(atr/_Point),1),TextColor);
      UpdateCell(row,2,DoubleToString(PointsToPips(range/_Point),1),TextColor);
      UpdateCell(row,4,(changeFromOpen>0 ? "+" : "")+DoubleToString(changeFromOpen,1),
                 changeFromOpen>0 ? UpColor : (changeFromOpen<0 ? DownColor : MutedColor));

      if(atr==0)
         UpdateCell(row,3,"N/A",MutedColor);
      else
        {
         double atrUsedPercent=100.0*range/atr;
         UpdateCell(row,3,DoubleToString(atrUsedPercent,1)+"%",atrUsedPercent>=MaxATRPercent ? MaxATRColor : TextColor);
        }
     }
  }
//+------------------------------------------------------------------+
