//+------------------------------------------------------------------+
//|                                                     PipChart.mq5 |
//|                                            Copyright 2019, ernst |
//|                             https://www.mql5.com/en/users/pippod |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, ernst"
#property link      "https://www.mql5.com/en/users/pippod"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_color1  clrRoyalBlue,clrFireBrick,clrYellow
//--- indicator inputs
input ENUM_CHART_MODE Mode=CHART_CANDLES; //Chart mode
//--- indicator buffers
double         OpenBuffer[];
double         HighBuffer[];
double         LowBuffer[];
double         CloseBuffer[];
double         ColorBuffer[];
//---
int muldiv;
double open,close;
//--- chart and price horizontal line objects
#include <Charts\Chart.mqh>
CChart chrt;
#include <ChartObjects\ChartObjectsLines.mqh>
CChartObjectHLine *line;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   int digits=_Digits-1;
   IndicatorSetInteger(INDICATOR_DIGITS,digits);
//--- set chart colors 
   chrt.Attach();
   chrt.Mode(Mode);
   chrt.ShowLineBid(false);
   chrt.ColorBarUp(clrNONE);
   chrt.ColorBarDown(clrNONE);
   chrt.ColorCandleBull(clrNONE);
   chrt.ColorCandleBear(clrNONE);
   chrt.ColorChartLine(clrNONE);         
//--- set chart properties
   switch(Mode)
     {
//--- draw color bars
      case CHART_BARS:
         PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_COLOR_BARS);
         PlotIndexSetString(0,PLOT_LABEL,"Open;High;Low;Close");
         Width();
//--- indicator buffers mapping
         SetIndexBuffer(0,OpenBuffer,INDICATOR_DATA);
         SetIndexBuffer(1,HighBuffer,INDICATOR_DATA);
         SetIndexBuffer(2,LowBuffer,INDICATOR_DATA);
         SetIndexBuffer(3,CloseBuffer,INDICATOR_DATA);
         SetIndexBuffer(4,ColorBuffer,INDICATOR_COLOR_INDEX);
         break;
//--- draw color candles
      case CHART_CANDLES:
         PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_COLOR_CANDLES);
         PlotIndexSetString(0,PLOT_LABEL,"Open;High;Low;Close");
//--- indicator buffers mapping
         SetIndexBuffer(0,OpenBuffer,INDICATOR_DATA);
         SetIndexBuffer(1,HighBuffer,INDICATOR_DATA);
         SetIndexBuffer(2,LowBuffer,INDICATOR_DATA);
         SetIndexBuffer(3,CloseBuffer,INDICATOR_DATA);
         SetIndexBuffer(4,ColorBuffer,INDICATOR_COLOR_INDEX);
         break;
//--- draw color line
      case CHART_LINE:
         PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_COLOR_LINE);
         PlotIndexSetString(0,PLOT_LABEL,"Close");
         Width();
//--- indicator buffers mapping
         SetIndexBuffer(0,CloseBuffer,INDICATOR_DATA);
         SetIndexBuffer(1,ColorBuffer,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,OpenBuffer,INDICATOR_CALCULATIONS);
         SetIndexBuffer(3,HighBuffer,INDICATOR_CALCULATIONS);
         SetIndexBuffer(4,LowBuffer,INDICATOR_CALCULATIONS);
     }   
//---
   muldiv=(int)MathPow(10,digits);
 /*if(StringFind(_Symbol,"XAU")!=-1)
      muldiv=MathPow(10,--digits);*/
//--- horizontal value line
   if(!CheckPointer(line=new CChartObjectHLine))
      return(INIT_FAILED);
   line.Create(ChartID(),"bidLine",0,0);
   line.SetInteger(OBJPROP_COLOR,clrLightSlateGray);
   line.SetInteger(OBJPROP_SELECTABLE,false);
   line.SetString(OBJPROP_TOOLTIP,"\n");   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_volume[],
                const long &Volume[],
                const int &Spread[])
  {
//--- initial values
   int begin=(rates_total!=prev_calculated)?prev_calculated:prev_calculated-1;
   if(!prev_calculated)
      OpenBuffer[begin++]=HighBuffer[0]=LowBuffer[0]=CloseBuffer[0]=(Close[0]>Open[0])?MathFloor(Close[0]*muldiv)/muldiv:MathCeil(Close[0]*muldiv)/muldiv;
//--- main loop 
   for(int i=begin;i<rates_total && !_StopFlag;i++)
     {
//--- set O
      if(rates_total!=prev_calculated)
         OpenBuffer[i]=open=(Open[i]>CloseBuffer[i-1])?MathFloor(Open[i]*muldiv)/muldiv:MathCeil(Open[i]*muldiv)/muldiv;
//--- set HLC
      CloseBuffer[i]=close=(Close[i]>open)?MathFloor(Close[i]*muldiv)/muldiv:MathCeil(Close[i]*muldiv)/muldiv;
      HighBuffer[i]=MathMax(open,MathMax(close,MathFloor(High[i]*muldiv)/muldiv));
      LowBuffer[i]=MathMin(open,MathMin(close,MathCeil(Low[i]*muldiv)/muldiv));
//--- set color
      if(Mode==CHART_LINE)
         ColorBuffer[i]=(close>CloseBuffer[i-1])?0:(close<CloseBuffer[i-1])?1:2;
      else
         ColorBuffer[i]=(close>open)?0:(close<open)?1:2;
     }
//--- set horizontal price line
   if(line!=NULL)
      line.SetDouble(OBJPROP_PRICE,CloseBuffer[rates_total-1]);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- check and delete object/pointer
   if(CheckPointer(line))
     {
      line.Delete();
      delete line;
     }
//--- set default chart colors
   chrt.ShowLineBid(true);
   chrt.ColorBarUp(clrLime);
   chrt.ColorBarDown(clrLime);
   chrt.ColorCandleBull(clrBlack);
   chrt.ColorCandleBear(clrWhite);
   chrt.ColorChartLine(clrLime);         
   chrt.Detach();
  }  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  OnChartEvent(const int id,       
                   const long& lparam,  
                   const double& dparam, 
                   const string& sparam)
  {
   if(id==CHARTEVENT_CHART_CHANGE)
     {
//--- mode is changed
    /*static ENUM_CHART_MODE mode;
      if(mode!=chrt.Mode())
        { 
         OnInit();
         mode=chrt.Mode();
        }*/ 
//--- scale/zoom is changed
      static int scale;
      if(scale!=chrt.Scale() && (Mode==CHART_LINE || Mode==CHART_BARS))
        {
         Width();
         chrt.Redraw();
         scale=chrt.Scale();
        }
     }     
  }                     
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Width()
  {
//--- set bars/line width
   switch(chrt.Scale())
     {
      case 0:
      case 1:
         return(PlotIndexSetInteger(0,PLOT_LINE_WIDTH,1));
      case 2:
         return(PlotIndexSetInteger(0,PLOT_LINE_WIDTH,2));
      case 3:   
         return(PlotIndexSetInteger(0,PLOT_LINE_WIDTH,3));
      case 4:   
         return(PlotIndexSetInteger(0,PLOT_LINE_WIDTH,4));
      case 5:   
         return(PlotIndexSetInteger(0,PLOT_LINE_WIDTH,5));
     }
//---
   return(false);
  }           
//+------------------------------------------------------------------+
