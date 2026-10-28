//+------------------------------------------------------------------+
//|                                                      i-SKB-F.mq5 |
//|                                          Copyright © 2006, KimIV |
//|                                              http://www.kimiv.ru |
//+------------------------------------------------------------------+
//---- Copyright
#property copyright "Copyright © 2006, KimIV"
//---- link to the website of the author
#property link      "http://www.kimiv.ru"
//---- описание индикатора
#property description "Barishpolts' moving channels on fractals"
//---- Indicator version number
#property version   "1.00"
//---- Drawing the indicator in the main window
#property indicator_chart_window
//----two buffers are used for calculating and drawing the indicator
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  i-SKB-F indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- blue color is used as the color of a bullish candlestick
#property indicator_color1  clrBlue
//---- the line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator 1 line width is equal to 1
#property indicator_width1  1
//---- display of the bullish label of the indicator line
#property indicator_label1  "Up i-SKB-F"
//+----------------------------------------------+
//|  i-SKB-F indicator drawing parameters        |
//+----------------------------------------------+
//---- dawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- red color is used as the color of the bearish indicator line
#property indicator_color2  clrRed
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- display of the bearish label of the indicator line
#property indicator_label2  "Down i-SKB-F"
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input int  OffSet=-3;
input bool ShowRay=true;
input color UpChannelColor=clrTeal;
input color DnChannelColor=clrRed;
//+----------------------------------------------+
//---- declaration of dynamic arrays that 
//---- will be used as indicator buffers
double UpBuffer[];
double DnBuffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of integer variables for the indicators handles
int FRA_Handle;
//+------------------------------------------------------------------+
//| iBarShift() function                                             |
//+------------------------------------------------------------------+
int iBarShift(string symbol,ENUM_TIMEFRAMES timeframe,datetime time)
  {
//----+
   if(time<0) return(-1);
   datetime Arr[],time1;

   time1=(datetime)SeriesInfoInteger(symbol,timeframe,SERIES_LASTBAR_DATE);

   if(CopyTime(symbol,timeframe,time,time1,Arr)>0)
     {
      int size=ArraySize(Arr);
      return(size-1);
     }
   else return(-1);
//----+
  }
//+------------------------------------------------------------------+
//|  Trend line creation                                             |
//+------------------------------------------------------------------+
void CreateTline(long     chart_id,      // Chart ID
                 string   name,          // object name
                 int      nwin,          // window index
                 datetime time1,         // price level time 1
                 double   price1,        // price level 1
                 datetime time2,         // price level time 2
                 double   price2,        // price level 2
                 color    Color,         // line color
                 int      style,         // line style
                 int      width,         // line width
                 string   text)          // текст
  {
//----
   ObjectCreate(chart_id,name,OBJ_TREND,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,true);
//----
  }
//+------------------------------------------------------------------+
//|  Resetting a trend line                                          |
//+------------------------------------------------------------------+
void SetTline(long     chart_id,      // Chart ID
              string   name,          // object name
              int      nwin,          // window index
              datetime time1,         // price level time 1
              double   price1,        // price level 1
              datetime time2,         // price level time 2
              double   price2,        // price level 2
              color    Color,         // line color
              int      style,         // line style
              int      width,         // line width
              string   text)          // текст
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateTline(chart_id,name,nwin,time1,price1,time2,price2,Color,style,width,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=30;

//---- getting handle of the iFractals indicator
   FRA_Handle=iFractals(NULL,PERIOD_CURRENT);
   if(FRA_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the iFractals indicator");
      return(INIT_FAILED);
     }
//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator 1 drawing by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(UpBuffer,true);
//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator 2 drawing by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(DnBuffer,true);
//---- Initializations of variable for indicator short name
   string shortname="i-SKB-F";
//---- Creating a name for displaying in a separate sub-window and in tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- Set accuracy of displaying for the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| DelObj                                                           |
//+------------------------------------------------------------------+
void DelObj()
  {
//----
   ObjectDelete(0,"Upper CHN");
   ObjectDelete(0,"Lower CHN");
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+     
void OnDeinit(const int reason)
  {
//----
   DelObj();
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| The equation of the line.                                        |
//| Calculates Y value for X at point of intersection with the line. |
//| Parameters:                                                      |
//|   x1,y1 - coordinates of the first point,                        |
//|   x2,y2 - coordinates of the second point,                       |
//|   x     - the value for which Y should be calculated             |
//+------------------------------------------------------------------+
double EquationDirect(double x1,double y1,double x2,double y2,double x)
  {
   if((x2-x1)*(x-x1)==0) return(y1);
   return((y2-y1)/(x2-x1)*(x-x1)+y1);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(BarsCalculated(FRA_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

   double y3=0,y2=0,y1=0,zz;         // fractals
   double y4,u2,u1,d2,d1;            // price levels of the lines
   int    x3=0,x2=0,x1=0,sh=2,limit; // bar indexes
   double Up[1],Dn[1];
   string sL1,sL2;
   static int X2;

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(time,true);

//---- Take three extremes of the Zig-Zag
   while(!y3)
     {

      if(CopyBuffer(FRA_Handle,0,sh,1,Up)<=0) return(RESET);
      if(CopyBuffer(FRA_Handle,1,sh,1,Dn)<=0) return(RESET);

      zz=Up[0];
      if(!zz || zz==EMPTY_VALUE) zz=Dn[0];
      if(zz && zz!=EMPTY_VALUE)
        {
         if(!y1)
           {
            x1=sh;
            y1=zz;
           }
         else if(!y2)
           {
            x2=sh;
            y2=zz;
           }
         else if(!y3)
           {
            x3=sh;
            y3=zz;
           }
        }
      sh++;
     }

   y4=EquationDirect(x3,y3,x1,y1,x2);

   if(y2>y1)
     {
      u2=y3+y2-y4;
      u1=EquationDirect(x3,u2,x2,y2,0);
      d2=y3;
      d1=EquationDirect(x3,y3,x1,y1,0);
     }
   else
     {
      u2=y3;
      u1=EquationDirect(x3,y3,x1,y1,0);
      d2=y3+y2-y4;
      d1=EquationDirect(x3,d2,x2,y2,0);
     }

   double res=OffSet*_Point;
   u2+=res;
   u1+=res;
   d2-=res;
   d1-=res;

   x2=iBarShift(Symbol(),PERIOD_CURRENT,time[x3]);

//---- calculations of the necessary amount of data to be copied
//---- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
     {
      limit=rates_total-1; // starting index for calculation of all bars
      X2=0;
     }
   else
     {
      limit=rates_total-prev_calculated+2; // starting index for calculation of new bars
     }

   for(sh=X2+limit; sh>x2; sh--)
     {
      UpBuffer[sh]=0.0;
      DnBuffer[sh]=0.0;
     }

   X2=x2;

   for(sh=x2; sh>=0; sh--)
     {
      UpBuffer[sh]=EquationDirect(x2,u2,0,u1,sh);
      DnBuffer[sh]=EquationDirect(x2,d2,0,d1,sh);
     }

   if(ShowRay)
     {
      SetTline(0,"Upper CHN",0,time[x3],u2,time[0],u1,UpChannelColor,STYLE_DOT,1,"Upper CHN");
      SetTline(0,"Lower CHN",0,time[x3],d2,time[0],d1,DnChannelColor,STYLE_DOT,1,"Lower CHN");
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
