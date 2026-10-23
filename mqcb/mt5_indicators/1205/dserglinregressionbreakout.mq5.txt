//+------------------------------------------------------------------+
//|                                  Dserg-LinRegressionBreakout.mq5 |
//|                                          Copyright © 2010, Dserg | 
//|                               http://www.mql4.com/ru/users/Dserg | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Dserg"
#property link ""
#property description "http://www.mql4.com/ru/users/Dserg"
//---- indicator version number
#property version   "1.10"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//----8 buffers are used for calculation of drawing of the indicator
#property indicator_buffers 8
//---- Only 8 graphical plots are used
#property indicator_plots   8
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- DodgerBlue color is used for the indicator
#property indicator_color1  clrDodgerBlue
//---- Indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- indicator 1 width is equal to 2
#property indicator_width1  2
//---- displaying the indicator label
#property indicator_label1  "Channel Low"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- DodgerBlue color is used for the indicator
#property indicator_color2  clrDodgerBlue
//---- Indicator line is a solid one
#property indicator_style2 STYLE_SOLID
//---- толщина индикатора 2 равна 2
#property indicator_width2  2
//---- displaying the indicator label
#property indicator_label2 "Channel High"
//+----------------------------------------------+
//|  Indicator 3 drawing parameters              |
//+----------------------------------------------+
//---- drawing indicator 3 as line
#property indicator_type3   DRAW_LINE
//---- DodgerBlue color is used for the indicator
#property indicator_color3  clrDodgerBlue
//---- the indicator line is a dot-dash one
#property indicator_style3 STYLE_DOT
//---- indicator 3 width is equal to 1
#property indicator_width3  1
//---- displaying the indicator label
#property indicator_label3  "Channel Low Extended"
//+----------------------------------------------+
//|  Indicator 4 drawing parameters              |
//+----------------------------------------------+
//---- drawing indicator 4 as line
#property indicator_type4   DRAW_LINE
//---- DodgerBlue color is used for the indicator
#property indicator_color4  clrDodgerBlue
//---- the indicator line is a dot-dash one
#property indicator_style4 STYLE_DOT
//---- indicator 4 width is equal to 1
#property indicator_width4  1
//---- displaying the indicator label
#property indicator_label4 "Channel High Extended"
//+----------------------------------------------+
//|  Indicator 5 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator 5 as a line
#property indicator_type5   DRAW_ARROW
//---- FireBrick color is used for the indicator
#property indicator_color5  clrFireBrick
//---- indicator 5 width is equal to 2
#property indicator_width5  2
//---- displaying the indicator label
#property indicator_label5  "Stop_Buffer/Reverse"
//+----------------------------------------------+
//|  Indicator 6 drawing parameters              |
//+----------------------------------------------+
//---- Drawing indicator 6 as line
#property indicator_type6   DRAW_ARROW
//---- lime color is used for the indicator
#property indicator_color6  clrLime
//---- indicator 6 width is equal to 2
#property indicator_width6  2
//---- displaying the indicator label
#property indicator_label6  "BUY Signal"
//+----------------------------------------------+
//|  Indicator 7 drawing parameters              |
//+----------------------------------------------+
//---- drawing indicator 7 as line
#property indicator_type7   DRAW_ARROW
//---- Red color is used for the indicator
#property indicator_color7  clrRed
//---- indicator 7 width is equal to 2
#property indicator_width7  2
//---- displaying the indicator label
#property indicator_label7  "SELL Signal"
//+----------------------------------------------+
//|  Indicator 8 drawing parameters              |
//+----------------------------------------------+
//---- drawing indicator 8 as line
#property indicator_type8   DRAW_ARROW
//---- blue color is used for the indicator
#property indicator_color8  clrBlue
//---- indicator 8 width is equal to 2
#property indicator_width8  2
//---- displaying the indicator label
#property indicator_label8  "Target_Buffer Signal"
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input uint Nlin=25; //Minimum length of the linear regression channel
input uint r0=150; //Maximum height of the channel in points
input double t0=2.618; //The purpose at breakdown relatively the channel width
input bool useClose=true; //Use to calculate Close,\n if false - High/Low
//+----------------------------------------------+
//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double B1_Buffer[],B0_Buffer[],B3_Buffer[],B4_Buffer[];
double Stop_Buffer[],Up_Buffer[],Dn_Buffer[],Target_Buffer[];
//---- declaration of the integer variables for the start of data calculation
int  min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- Initialization of variables    
   min_rates_total=int(Nlin);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,B0_Buffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(B0_Buffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,B1_Buffer,INDICATOR_DATA);
//---- shifting the beginning of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(B1_Buffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(2,B3_Buffer,INDICATOR_DATA);
//---- shifting the beginning of drawing of the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(B3_Buffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(3,B4_Buffer,INDICATOR_DATA);
//---- shifting the beginning of drawing of the indicator 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(B4_Buffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(4,Stop_Buffer,INDICATOR_DATA);
//---- shifting the beginning of drawing of the indicator 5
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Stop_Buffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0);
//---- indicator symbol
   PlotIndexSetInteger(4,PLOT_ARROW,251);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(5,Up_Buffer,INDICATOR_DATA);
//---- shifting the beginning of drawing of the indicator 6
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Up_Buffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,0);
//---- indicator symbol
   PlotIndexSetInteger(5,PLOT_ARROW,233);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(6,Dn_Buffer,INDICATOR_DATA);
//---- shifting the beginning of drawing of the indicator 7
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Dn_Buffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,0);
//---- indicator symbol
   PlotIndexSetInteger(6,PLOT_ARROW,234);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(7,Target_Buffer,INDICATOR_DATA);
//---- shifting the beginning of drawing of the indicator 8
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Target_Buffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,0);
//---- indicator symbol
   PlotIndexSetInteger(7,PLOT_ARROW,231);

//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="Dserg-LinRegressionBreakout";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate
(const int rates_total,
 const int prev_calculated,
 const datetime &Time[],
 const double &Open[],
 const double &High[],
 const double &Low[],
 const double &Close[],
 const long &Tick_Volume[],
 const long &Volume[],
 const int &Spread[]
 )
  {
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int limit,bar,barj,j;
   bool isChannel;
   double a0,b0,a,b,c,sumy,sumx,sumxy,sumx2,h,l,range,range0;
   static int recount;

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Close,true);
   ArraySetAsSeries(Open,true);
//----
   range=0.0;
   range0=0.0;
   isChannel=false;
   a0=0.0;
   b0=0.0;

//--- calculations of the necessary amount of data to be copied and
//----the limit starting number for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
      recount=limit;
     }
   else limit=rates_total-prev_calculated+recount; // starting index for calculation of new bars

//---- first indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      B0_Buffer[bar]=0;
      B1_Buffer[bar]=0;
      B3_Buffer[bar]=0;
      B4_Buffer[bar]=0;
      Up_Buffer[bar]=0;
      Dn_Buffer[bar]=0;
      Stop_Buffer[bar]=0;
      Target_Buffer[bar]=0;

      //----we already have a channel, wait, wait until it breaks
      if(isChannel)
        {
         double up0=a0*bar+b0+range0;
         double dn0=a0*bar+b0-range0;

         B3_Buffer[bar]=up0;
         B4_Buffer[bar]=dn0;

         //---- check for the upper breakdown
         if(Open[bar]>up0)
           {
            Up_Buffer[bar]=up0;
            Stop_Buffer[bar]=dn0;
            Target_Buffer[bar]=up0+(up0-dn0)*(t0-1);
            isChannel=false;         
            if(bar) recount=bar-1;
           }

         //---- checj\k for the lower breakdown
         if(Open[bar]<dn0)
           {
            Dn_Buffer[bar]=dn0;
            Stop_Buffer[bar]=up0;
            Target_Buffer[bar]=dn0-(up0-dn0)*(t0-1);
            isChannel=false;
            if(bar) recount=bar-1;
           }

         continue;
        }

      bool flag=false;
      for(j=0; j<int(Nlin); j++) if(B3_Buffer[bar+j]>0.0 && !isChannel) {flag=true; break;}
      if(flag) continue;

      sumx=0.0;
      sumy=0.0;
      sumxy=0.0;
      sumx2=0.0;

      //---- calculate the channel of linear regression from i+Nlin to i
      for(j=0; j<int(Nlin); j++)
        {
         barj=bar+j;
         sumy+=Close[barj];
         sumxy+=Close[barj]*barj;
         sumx+=barj;
         sumx2+=barj*barj;
        }

      c=sumx2*Nlin-sumx*sumx;

      if(!c)
        {
         Alert("Error in linear regression!");
         return(RESET);
        }

      h=0.0;
      l=0.0;
      a=(sumxy*Nlin-sumx*sumy)/c;
      b=(sumy-sumx*a)/Nlin;

      //---- define the channel borders
      for(j=0; j<int(Nlin); j++)
        {
         barj=bar+j;
         double LR=a*barj+b;

         if(useClose)
           {
            if(Close[barj]-LR>h) h = Close[barj]-LR;
            if(LR-Close[barj]>l) l = LR - Close[barj];
           }
         else
           {
            if(High[barj]-LR > h) h = High[barj]-LR;
            if(LR - Low[barj]> l) l = LR - Low[barj];
           }
        }

      range=MathMax(l,h);

      //---- check for the channel width
      if(range<r0*_Point)
        {
         //---- there is a channel, save
         isChannel=true;
         a0=a;
         b0=b;
         range0=range;

         for(j=0; j<int(Nlin); j++)
           {
            barj=bar+j;
            double res1=a*barj+b;
            double res2=res1+range;
            double res3=res1-range;

            if(!j)
              {
               B3_Buffer[barj]=res2;
               B4_Buffer[barj]=res3;
              }
            B0_Buffer[barj]=res2;
            B1_Buffer[barj]=res3;
           }
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
