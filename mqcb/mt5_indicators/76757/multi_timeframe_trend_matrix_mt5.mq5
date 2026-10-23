//+------------------------------------------------------------------+
//|                             Multi Timeframe Trend Matrix MT5.mq5 |
//|                                         Copyright 2026, Shahrukh |
//|                       https://forge.mql5.io                      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Shahrukh"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Compact multi timeframe EMA and ADX trend dashboard."
#property indicator_chart_window
#property indicator_plots 0
#property indicator_buffers 0

input group "Trend Model"
input int              InpFastEmaPeriod      = 20;
input int              InpSlowEmaPeriod      = 50;
input int              InpAdxPeriod          = 14;
input double           InpMinimumAdx         = 20.0;
input ENUM_APPLIED_PRICE InpAppliedPrice     = PRICE_CLOSE;
input bool             InpUseClosedBar       = true;

input group "Panel"
input ENUM_BASE_CORNER InpCorner             = CORNER_LEFT_UPPER;
input int              InpPanelX             = 15;
input int              InpPanelY             = 25;
input color            InpBullishColor       = clrSeaGreen;
input color            InpBearishColor       = clrIndianRed;
input color            InpNeutralColor       = clrSlateGray;
input color            InpPanelColor         = clrBlack;
input color            InpTextColor          = clrWhite;
input int              InpRefreshSeconds     = 2;

#define TF_COUNT 6

ENUM_TIMEFRAMES g_timeframes[TF_COUNT]={PERIOD_M5,PERIOD_M15,PERIOD_M30,
                                        PERIOD_H1,PERIOD_H4,PERIOD_D1};
string g_tf_names[TF_COUNT]={"M5","M15","M30","H1","H4","D1"};
int    g_fast_handles[TF_COUNT];
int    g_slow_handles[TF_COUNT];
int    g_adx_handles[TF_COUNT];
string g_prefix="MTFMATRIX_";

//+------------------------------------------------------------------+
void SetLabel(const string name,const string text,const int x,const int y,
              const color text_color,const int font_size=9)
  {
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,InpCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,InpPanelX+x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,InpPanelY+y);
   ObjectSetInteger(0,name,OBJPROP_COLOR,text_color);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }

//+------------------------------------------------------------------+
void SetPanel(const string name,const int x,const int y,const int width,
              const int height,const color panel_color)
  {
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,InpCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,InpPanelX+x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,InpPanelY+y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,panel_color);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrDimGray);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
  }

//+------------------------------------------------------------------+
bool ReadValue(const int handle,const int buffer,const int shift,double &value)
  {
   double data[1];
   if(handle==INVALID_HANDLE || CopyBuffer(handle,buffer,shift,1,data)!=1)
      return(false);
   value=data[0];
   return(MathIsValidNumber(value));
  }

//+------------------------------------------------------------------+
int TrendState(const int index,double &adx_value)
  {
   const int shift=(InpUseClosedBar ? 1 : 0);
   double fast=0.0,slow=0.0;
   if(!ReadValue(g_fast_handles[index],0,shift,fast) ||
      !ReadValue(g_slow_handles[index],0,shift,slow) ||
      !ReadValue(g_adx_handles[index],0,shift,adx_value))
      return(0);

   double closes[1];
   if(CopyClose(_Symbol,g_timeframes[index],shift,1,closes)!=1)
      return(0);

   if(adx_value<InpMinimumAdx)
      return(0);
   if(closes[0]>fast && fast>slow)
      return(1);
   if(closes[0]<fast && fast<slow)
      return(-1);
   return(0);
  }

//+------------------------------------------------------------------+
void UpdatePanel()
  {
   SetPanel(g_prefix+"BACKGROUND",0,0,420,118,InpPanelColor);
   SetLabel(g_prefix+"TITLE","MULTI TIMEFRAME TREND MATRIX",14,10,InpTextColor,10);
   SetLabel(g_prefix+"MODEL",StringFormat("EMA %d and %d   ADX %.0f",InpFastEmaPeriod,
            InpSlowEmaPeriod,InpMinimumAdx),14,31,clrSilver,8);

   int bullish_count=0,bearish_count=0;
   for(int index=0; index<TF_COUNT; index++)
     {
      double adx=0.0;
      const int state=TrendState(index,adx);
      if(state>0) bullish_count++;
      if(state<0) bearish_count++;

      const int tile_x=12+index*67;
      color tile_color=InpNeutralColor;
      string direction="RANGE";
      if(state>0)
        {
         tile_color=InpBullishColor;
         direction="BULL";
        }
      else if(state<0)
        {
         tile_color=InpBearishColor;
         direction="BEAR";
        }

      SetPanel(g_prefix+"TILE_"+IntegerToString(index),tile_x,53,60,50,tile_color);
      SetLabel(g_prefix+"TF_"+IntegerToString(index),g_tf_names[index],tile_x+20,59,clrWhite,9);
      SetLabel(g_prefix+"DIR_"+IntegerToString(index),direction,tile_x+12,76,clrWhite,8);
      SetLabel(g_prefix+"ADX_"+IntegerToString(index),StringFormat("%.0f",adx),tile_x+22,91,clrWhite,7);
     }

   color border=InpNeutralColor;
   if(bullish_count>=4) border=InpBullishColor;
   if(bearish_count>=4) border=InpBearishColor;
   ObjectSetInteger(0,g_prefix+"BACKGROUND",OBJPROP_COLOR,border);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpFastEmaPeriod<1 || InpSlowEmaPeriod<=InpFastEmaPeriod ||
      InpAdxPeriod<1 || InpMinimumAdx<0.0 || InpRefreshSeconds<1)
     {
      Print("Invalid trend matrix settings.");
      return(INIT_PARAMETERS_INCORRECT);
     }

   for(int index=0; index<TF_COUNT; index++)
     {
      g_fast_handles[index]=iMA(_Symbol,g_timeframes[index],InpFastEmaPeriod,0,MODE_EMA,InpAppliedPrice);
      g_slow_handles[index]=iMA(_Symbol,g_timeframes[index],InpSlowEmaPeriod,0,MODE_EMA,InpAppliedPrice);
      g_adx_handles[index]=iADX(_Symbol,g_timeframes[index],InpAdxPeriod);
      if(g_fast_handles[index]==INVALID_HANDLE || g_slow_handles[index]==INVALID_HANDLE ||
         g_adx_handles[index]==INVALID_HANDLE)
        {
         Print("Unable to create indicator handles for ",g_tf_names[index]);
         return(INIT_FAILED);
        }
     }

   IndicatorSetString(INDICATOR_SHORTNAME,"Multi Timeframe Trend Matrix");
   EventSetTimer(InpRefreshSeconds);
   UpdatePanel();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   for(int index=0; index<TF_COUNT; index++)
     {
      if(g_fast_handles[index]!=INVALID_HANDLE) IndicatorRelease(g_fast_handles[index]);
      if(g_slow_handles[index]!=INVALID_HANDLE) IndicatorRelease(g_slow_handles[index]);
      if(g_adx_handles[index]!=INVALID_HANDLE) IndicatorRelease(g_adx_handles[index]);
     }
   ObjectsDeleteAll(0,g_prefix);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
void OnTimer()
  {
   UpdatePanel();
  }

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &time[],const double &open[],
                const double &high[],const double &low[],
                const double &close[],const long &tick_volume[],
                const long &volume[],const int &spread[])
  {
   return(rates_total);
  }
//+------------------------------------------------------------------+
