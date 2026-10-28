//+------------------------------------------------------------------+
//|                                            Spread statistics.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.000"
#property description "Spread statistics for current symbol"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0
#include <Canvas\Canvas.mqh>
CCanvas m_canvas;
//--- input parameters
input uchar    averaging_period  = 5;                 // averaging period
input color    clr_background    = clrAquamarine;     // background
input uchar    alpha_background  = 150;               // background alpha
input color    clr_text          = clrRed;            // text color 
input uchar    alpha_text        = 255;               // text alpha 
//---
bool     first_start          = false;
string   canvas_name          = "Spread statistics";
int      canvas_x             = 10;
int      canvas_y             = 15;
int      canvas_width         = 415;
int      canvas_height        = 39;
long     prev_show_one_click  = -1;
long     spread[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---   
   prev_show_one_click=ChartGetInteger(0,CHART_SHOW_ONE_CLICK);
   ArrayResize(spread,averaging_period);
   ArrayInitialize(spread,0);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
//Print(__FUNCTION__,", ",reason);
   if(reason==1) // REASON_REMOVE
     {
      m_canvas.Destroy();
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//---
   if(!first_start)
     {
      long temp=ChartGetInteger(0,CHART_SHOW_ONE_CLICK);
      prev_show_one_click=temp;
      int temp_y=(prev_show_one_click==0)?canvas_y:canvas_y+72;
      //--- COLOR_FORMAT_ARGB_NORMALIZE
      if(!m_canvas.CreateBitmapLabel(canvas_name,canvas_x,temp_y,canvas_width,canvas_height,COLOR_FORMAT_ARGB_NORMALIZE))
        {
         Print("Error creating canvas: ",GetLastError());
         return(rates_total);
        }
      m_canvas.FontNameSet("Consolas");
      m_canvas.Erase(ColorToARGB(clr_background,alpha_background));
      m_canvas.Update();
      first_start=true;
     }
   long spread_temp[];
   ArrayCopy(spread_temp,spread,1,0);
   spread_temp[0]=SymbolInfoInteger(Symbol(),SYMBOL_SPREAD);
   ArrayCopy(spread,spread_temp,0,0);

   string text="";
   long average=0;
   int limit=(averaging_period>7)?7:averaging_period;
   for(int i=0;i<averaging_period;i++)
     {
      if(i<limit)
        {
         if(i==0)
            text=(string)spread[i];
         else
            text=text+", "+(string)spread[i];
        }
      average+=spread[i];
     }
   average/=averaging_period;
   text=text+" | "+(string)average;
   int x=10;
   int y=10;
   int width=m_canvas.TextWidth(text);
   if(m_canvas.Width()!=width+25)
      m_canvas.Resize(width+25,canvas_height);
   m_canvas.Erase(ColorToARGB(clr_background,alpha_background));
   m_canvas.TextOut(x,y,text,ColorToARGB(clr_text,alpha_text));
   m_canvas.Update();
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   if(id!=CHARTEVENT_CHART_CHANGE)
      return;
   long temp=ChartGetInteger(0,CHART_SHOW_ONE_CLICK);
   if(temp==prev_show_one_click)
      return;
   prev_show_one_click=temp;
   int temp_y=(prev_show_one_click==0)?canvas_y:canvas_y+70;
   string temp_name=m_canvas.ChartObjectName();
//--- reset the error value 
   ResetLastError();
//--- move the object 
   if(!ObjectSetInteger(0,temp_name,OBJPROP_YDISTANCE,temp_y))
     {
      Print(__FUNCTION__,
            ": failed to move X coordinate of the object! Error code = ",GetLastError());
      return;
     }
  }
//+------------------------------------------------------------------+
