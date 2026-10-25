//+--------------------------------------------------------------------------------+
//|                                                                      Float.mq5 |
//|                     Copyright © 2005  Barry Stander  Barry_Stander_4@yahoo.com |
//|                                                  http://www.4Africa.net/4meta/ |
//|                                                Copyright © 2010  Andriy Moraru |
//|                                                      http://www.earnforex.com/ |
//+--------------------------------------------------------------------------------+
#property copyright "Copyright © 2010  Andriy Moraru"
#property link      "http://www.earnforex.com/"
#property description "Float - Trend strength, volume, Fibonacci and DiNapoli levels."

//---- drawing indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers
#property indicator_buffers 2

//---- number of indicator buffers
#property indicator_buffers 2 
//---- only two plots are used
#property indicator_plots   2
//+-----------------------------------+
//|  Indicator 1 drawing parameters   |
//+-----------------------------------+
#property indicator_color1  clrBlue
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//+-----------------------------------+
//|  Indicator 2 drawing parameters   |
//+-----------------------------------+
#property indicator_color2  clrRed
#property indicator_type2   DRAW_LINE
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input int Float=200; //amount of bars for the trends analysis. The lower the number, the newer the data, 
                //but the analysis will be less accurate.
input bool use_fibos=true; //permission Fibonacci levels
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  //volume
//+-----------------------------------+

double high_bar,low_bar;
double cumulativeV,FLOATV,swing;
double prevbars;
double fib23,fib38,fib50,fib62,fib76;
double dinap0,dinap1,dinap2,dinap3,dinap4,dinap5;

double Buffer1[];
double Buffer2[];

bool   first=true;

int bar,swing_time,loopbegin1;
int cvstart,cvend,bars_high,bars_low;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {   
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,Buffer1,INDICATOR_DATA);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(Buffer1,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,Buffer2,INDICATOR_DATA);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(Buffer2,true);

//---- name for the data window and the label for sub-windows 
   string short_name="Float";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   PlotIndexSetString(0,PLOT_LABEL,short_name);

//----
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---- delete graphical objects from a chart
   ObjectDelete(0,"swingtop");
   ObjectDelete(0,"swingbottom");

   ObjectDelete(0,"fib23");
   ObjectDelete(0,"fib38");
   ObjectDelete(0,"fib50");
   ObjectDelete(0,"fib62");
   ObjectDelete(0,"fib76");

   ObjectDelete(0,"fib23t");
   ObjectDelete(0,"fib38t");
   ObjectDelete(0,"fib50t");
   ObjectDelete(0,"fib62t");
   ObjectDelete(0,"fib76t");

   ObjectDelete(0,"dinap0");
   ObjectDelete(0,"dinap1");
   ObjectDelete(0,"dinap2");
   ObjectDelete(0,"dinap3");
   ObjectDelete(0,"dinap4");
   ObjectDelete(0,"dinap5");

   ObjectDelete(0,"CVSTART");
   ObjectDelete(0,"CVEND");
   ObjectDelete(0,"swingend1");
   ObjectDelete(0,"swingend2");
   ObjectDelete(0,"swingend3");
   ObjectDelete(0,"swingend4");
   ObjectDelete(0,"swingend5");
   ObjectDelete(0,"swingend6");
   ObjectDelete(0,"swingend7");
   ObjectDelete(0,"swingend8");
   ObjectDelete(0,"swingend9");

   Comment("");
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &open[],
                const double &High[],
                const double &Low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//----
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(tick_volume,true);
   ArraySetAsSeries(volume,true);
   ArraySetAsSeries(Time,true);

   int counted_bars=prev_calculated;
   if(counted_bars<0) return(-1); // Exit if no data

   cumulativeV=0;

   if((rates_total<prevbars) || (rates_total-prevbars>1))
     {
      first=true;
      prevbars=rates_total;
      FLOATV=0;

      loopbegin1=rates_total-Float;

      for(bar=loopbegin1; bar>=0; bar--)
        {
         //Find bar counts
         bars_high = ArrayMaximum(High, 1, Float);
         bars_low  = ArrayMinimum(Low, 1, Float);

         //Find High and Low
         high_bar = High[bars_high];
         low_bar  = Low[bars_low];

         //Find cumulative volume for float period
         if(bars_high<bars_low) //Uptrend
           {
            cvstart=bars_low;
            cvend=bars_high;
           }
         else //Downtrend
           {
            cvstart=bars_high;
            cvend=bars_low;
           }

         if(first && !FLOATV)
           {
            for(bar=cvstart; bar>=cvend; bar--)
              {
               if(VolumeType==VOLUME_TICK) FLOATV+=double(tick_volume[bar]);
               else                        FLOATV+=double(volume[bar]);
               first=false;
              }
           }
        }

      //Find swing price differance
      swing=high_bar-low_bar;

      //Find float time barcount
      swing_time=MathAbs(bars_low-bars_high);

      //---- performing shift of the beginning of counting of drawing the indicators
      int start=rates_total-cvstart;
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,start);

      //Find cumulative volume since last turnover
      for(bar=cvstart; bar>=0; bar--) //  for    2
        {
         if(VolumeType==VOLUME_TICK) cumulativeV+=double(tick_volume[bar]);
         else                        cumulativeV+=double(volume[bar]);

         if(cumulativeV>=FLOATV) cumulativeV=0;

         Buffer1[bar] = cumulativeV * 0.001; //Blue
         Buffer2[bar] = FLOATV * 0.001;      //Red         

         Comment(
                 "\n","high was   ",bars_high,"  bars ago",
                 "\n","Low was    ",bars_low," bars ago","\n",
                 "\n","Float time was  =      ",swing_time," bars",
                 "\n","Float Vol. left    =     ",FLOATV-cumulativeV,
                 "\n","Float Volume    =     ",FLOATV
                 );
        }

      SetTline(0,"swingtop",0,Time[cvstart],high_bar,Time[1],high_bar,clrBlue,STYLE_SOLID,1,"swingtop");
      SetTline(0,"swingbottom",0,Time[cvstart],low_bar,Time[1],low_bar,clrBlue,STYLE_SOLID,1,"swingbottom");

      //Fibonacci
      if(use_fibos)
        {
         fib23 = (swing * 0.236) + low_bar;
         fib38 = (swing * 0.382) + low_bar;
         fib50 = (swing * 0.500) + low_bar;
         fib62 = (swing * 0.618) + low_bar;
         fib76 = (swing * 0.764) + low_bar;
         dinap0 = (low_bar + fib23) / 2;
         dinap1 = (fib23 + fib38) / 2;
         dinap2 = (fib38 + fib50) / 2;
         dinap3 = (fib50 + fib62) / 2;
         dinap4 = (fib62 + fib76) / 2;
         dinap5 = (high_bar + fib76) / 2;

         SetTline(0,"fib23",0,Time[cvstart],fib23,Time[1],fib23,clrGreen,STYLE_DASH,1,"fib23");
         SetTextObj(0,"fib23t",0,Time[1],fib23,clrGreen,8,"Arial","23.6");

         SetTline(0,"fib38",0,Time[cvstart],fib38,Time[1],fib38,clrGreen,STYLE_DASH,1,"fib38");
         SetTextObj(0,"fib38t",0,Time[1],fib38,clrGreen,8,"Arial","38.2");

         SetTline(0,"fib50",0,Time[cvstart],fib50,Time[1],fib50,clrRed,STYLE_SOLID,2,"fib50");
         SetTextObj(0,"fib50t",0,Time[1],fib50,clrGreen,8,"Arial","50.0");

         SetTline(0,"fib62",0,Time[cvstart],fib62,Time[1],fib62,clrGreen,STYLE_DASH,1,"fib62");
         SetTextObj(0,"fib62t",0,Time[1],fib62,clrGreen,8,"Arial","61.8");

         SetTline(0,"fib76",0,Time[cvstart],fib76,Time[1],fib76,clrGreen,STYLE_DASH,1,"fib76");
         SetTextObj(0,"fib76t",0,Time[1],fib76,clrGreen,8,"Arial","76.4");

         SetTline(0,"dinap0",0,Time[cvstart],dinap0,Time[1],dinap0,clrRed,STYLE_DOT,1,"dinap0");
         SetTline(0,"dinap1",0,Time[cvstart],dinap1,Time[1],dinap1,clrRed,STYLE_DOT,1,"dinap1");
         SetTline(0,"dinap2",0,Time[cvstart],dinap2,Time[1],dinap2,clrRed,STYLE_DOT,1,"dinap2");
         SetTline(0,"dinap3",0,Time[cvstart],dinap3,Time[1],dinap3,clrRed,STYLE_DOT,1,"dinap3");
         SetTline(0,"dinap4",0,Time[cvstart],dinap4,Time[1],dinap4,clrRed,STYLE_DOT,1,"dinap4");
         SetTline(0,"dinap5",0,Time[cvstart],dinap5,Time[1],dinap5,clrRed,STYLE_DOT,1,"dinap5");
        }

      //Vertical float lines. Tthese draw the lines that calculate the float.
      //If you change "trendline" to "Vline" it will draw through oscillators too. Might be fun.
      SetTline(0,"CVSTART",0,Time[cvstart],high_bar,Time[cvstart],low_bar*_Point,clrBlue,STYLE_SOLID,1,"CVSTART");
      SetTline(0,"CVEND",0,Time[cvend],high_bar,Time[cvend],low_bar*_Point,clrBlue,STYLE_SOLID,1,"CVEND");

      //Vertical float predictions. These are only time based.
      //See blue histogram for real float values.
      //If you change "trendline" to "Vline" it will draw through oscillators too. Might be fun.
      for(int number=1; number<10; number++)
        {
         int barX=int(cvend-swing_time*number);
         string name="swingend"+string(number);

         if(barX>0) SetTline(0,name,0,Time[barX+5],high_bar,Time[barX+5],low_bar,clrRed,STYLE_DOT,1,name);
         else ObjectDelete(0,name);
        }
     }
//----
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  Text objecte creating                                           |
//+------------------------------------------------------------------+
void CreateTextObj
(
 long     chart_id,      // chart ID
 string   name,          // object name
 int      nwin,          // window index
 datetime time,          // price level time
 double   price,         // price level
 color    Color,         // color
 uint     size,          // size
 string   font,          // font
 string   text           // text
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_TEXT,nwin,time,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,size);
   ObjectSetString(chart_id,name,OBJPROP_FONT,font);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,false);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,true);
//----
  }
//+------------------------------------------------------------------+
//|  Reset the text object                                           |
//+------------------------------------------------------------------+
void SetTextObj
(
 long     chart_id,      // chart ID
 string   name,          // object name
 int      nwin,          // window index
 datetime time,          // price level time
 double   price,         // price level
 color    Color,         // color
 uint     size,          // size
 string   font,          // font
 string   text           // text
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateTextObj(chart_id,name,nwin,time,price,Color,size,font,text);
   else
     {
      ObjectCreate(chart_id,name,OBJ_TEXT,nwin,time,price);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
     }
//----
  }
//+------------------------------------------------------------------+
//|  Trend line creation                                             |
//+------------------------------------------------------------------+
void CreateTline
(
 long     chart_id,      // chart ID
 string   name,          // object name
 int      nwin,          // window index
 datetime time1,         // price level time 1
 double   price1,        // price level 1
 datetime time2,         // price level time 2
 double   price2,        // price level 2
 color    Color,         // line color
 int      style,         // line style
 int      width,         // line width
 string   text           // text
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_TREND,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,false);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY_LEFT,false);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,true);
//----
  }
//+------------------------------------------------------------------+
//|  Trend line reinstallation                                       |
//+------------------------------------------------------------------+
void SetTline
(
 long     chart_id,      // chart ID
 string   name,          // object name
 int      nwin,          // window index
 datetime time1,         // price level time 1
 double   price1,        // price level 1
 datetime time2,         // price level time 2
 double   price2,        // price level 2
 color    Color,         // line color
 int      style,         // line style
 int      width,         // line width
 string   text           // text
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateTline(chart_id,name,nwin,time1,price1,time2,price2,Color,style,width,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
     }
//----
  }
//+------------------------------------------------------------------+
