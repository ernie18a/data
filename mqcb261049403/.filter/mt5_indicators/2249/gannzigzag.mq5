//+------------------------------------------------------------------+
//|                                                   GannZIGZAG.mq5 |
//|                                        Copyright © 2005, Profi_R |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
//--- Copyright
#property copyright "Copyright © 2005, Profi_R"
//--- a link to the website of the author
#property link "https://www.metaquotes.net"
#property description ""
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- one buffer is used for calculation and drawing of the indicator
#property indicator_buffers 1
//--- one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//--- drawing the indicator 1 as a section
#property indicator_type1   DRAW_SECTION
//--- medium slate blue color is used as the color of the bullish line of the indicator
#property indicator_color1  clrMediumSlateBlue
//--- the line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//--- indicator 1 line width is equal to 3
#property indicator_width1  3
//--- display of the indicator bullish label
#property indicator_label1  "GannZIGZAG"
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint GSv_range=2;
input int Shift=0; // horizontal shift of the indicator in bars 
//+----------------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double IndBuffer[];
//--- declaration of integer variables of data starting point
int min_rates_total;
//---
double h,l;
bool cur_h,cur_l;
bool draw_up,draw_dn,initfl;
int  fPoint_i,sPoint_i,s_up,s_dn,drawf,lb,idFile;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=2;
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- shift the beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndBuffer,true);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"GannZIGZAG");
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of price lows for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(0);
//--- apply timeseries indexing to array elements  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- declaration of integer variables
   int i,bar,bar1,limit,count;
//--- calculations of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total; // starting index for the calculation of all bars
      initfl=0;
      draw_up=0;
      draw_dn=0;
      initfl=0;
      cur_h=0;
      cur_l=0;
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }
//--- The starting initialization
   if(initfl!=1) myInit(rates_total,open,high,low,close);
   int bars2=rates_total-2;
   int bars1=rates_total-1;
//--- main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      bar1=bar+1;
      count=bars1-bar;
      IndBuffer[bar]=0.0;
      //--- if an extremum was drawn on the previous bar
      if(IndBuffer[bar1]>0 && lb!=count)
        {
         if(draw_up) s_dn=0;
         else if(draw_dn) s_up=0;
        }
      if(lb!=count)
        {
         cur_h=0;
         cur_l=0;
        }
      if(bar>bars2-drawf || (high[bar]<=high[bar1] && low[bar]>=low[bar1])) continue;
      if(draw_up)
        {
         //--- if the line is directed upwards
         if(high[bar]>h)
           {
            //--- if a new maximum has been reached
            h=high[bar];
            cur_h=1;
           }
         if(low[bar]<l)
           {
            //--- if a new minimum has been reached
            l=low[bar];
            //--- if this is not the same bar
            if(lb!=count || cur_l!=1)s_dn++;
            cur_l=1;
           }
         //--- if the counters are equal
         if(s_up==s_dn)
           {
            //--- if th elast bar is a new maximum and minimum at the same time
            if(cur_h==cur_l && cur_l==1)
              {
               //--- if a candlestick is bearish
               if(close[bar]<=open[bar])
                 {
                  draw_up=0;
                  draw_dn=1;
                  fPoint_i=sPoint_i;
                  sPoint_i=count;
                  IndBuffer[bar]=l;
                  for(i=bars2-fPoint_i; i>bar; i--) IndBuffer[i]=0.0;
                 }
               else
                 {
                  //--- if a candlestick is bullish
                  sPoint_i=count;
                  IndBuffer[bar]=h;
                  for(i=bars2-fPoint_i; i>bar; i--) IndBuffer[i]=0.0;
                 }
              }
            else
              {
               //--- if th elast bar is only a new maximum
               if(cur_h==1)
                 {
                  sPoint_i=count;
                  IndBuffer[bar]=h;
                  l=low[bar];
                  for(i=bars2-fPoint_i; i>bar; i--) IndBuffer[i]=0.0;
                 }
               else
                 {
                  if(cur_l==1)
                    {
                     //--- if th elast bar is only a new minimum
                     draw_up=0;
                     draw_dn=1;
                     fPoint_i=sPoint_i;
                     sPoint_i=count;
                     IndBuffer[bar]=l;
                     h=high[bar];
                     for(i=bars2-fPoint_i; i>bar; i--) IndBuffer[i]=0.0;
                    }
                 }
              }
           }
         else
           {
            //--- otherwise, if there is no explicit change of direction (the Dn candlestick counter is not equal to GSv_range)
            //--- if a new maximum has been reached
            if(cur_h==1)
              {
               sPoint_i=count;
               IndBuffer[bar]=h;
               for(i=bars2-fPoint_i; i>bar; i--) IndBuffer[i]=0.0;
               l=low[bar];
              }
           }
        }
      else
        {
         //--- if the line is directed downwards
         if(high[bar]>h)
           {
            //--- if a new maximum has been reached
            h=high[bar];
            if(lb!=count || cur_h!=1)s_up++;
            cur_h=1;
            //--- if this is not the same bar
           }
         if(low[bar]<l)
           {
            //--- if a new minimum has been reached
            l=low[bar];
            cur_l=1;
           }
         //--- if the counters are equal 
         if(s_up==s_dn)
           {
            //--- if th elast bar is a new maximum and minimum at the same time
            if(cur_h==cur_l && cur_l==1)
              {
               //--- if a candlestick is bearish
               if(close[bar]<=open[bar])
                 {
                  sPoint_i=count;
                  IndBuffer[bar]=l;
                  for(i=bars2-fPoint_i; i>bar; i--) IndBuffer[i]=0.0;
                 }
               else
                 {
                  //--- if a candlestick is bullish
                  draw_up=1;
                  draw_dn=0;
                  fPoint_i=sPoint_i;
                  sPoint_i=count;
                  IndBuffer[bar]=h;
                  for(i=bars2-fPoint_i; i>bar; i--) IndBuffer[i]=0.0;
                 }
              }
            else
              {
               //--- if th elast bar is only a new maximum
               if(cur_h==1)
                 {
                  draw_up=1;
                  draw_dn=0;
                  fPoint_i=sPoint_i;
                  sPoint_i=count;
                  IndBuffer[bar]=h;
                  l=low[bar];
                  for(i=bars2-fPoint_i; i>bar; i--) IndBuffer[i]=0.0;
                 }
               else
                 {
                  if(cur_l==1)
                    {
                     //--- if th elast bar is only a new minimum
                     sPoint_i=count;
                     IndBuffer[bar]=l;
                     h=high[bar];
                     for(i=bars2-fPoint_i; i>bar; i--) IndBuffer[i]=0.0;
                    }
                 }
              }
           }
         else
           {
            //--- otherwise, if there is no explicit change of direction (the Up candlestick counter is not equal to GSv_range)
            //--- if a new minimum has been reached
            if(cur_l==1)
              {
               sPoint_i=count;
               IndBuffer[bar]=l;
               for(i=bars2-fPoint_i; i>bar; i--) IndBuffer[i]=0.0;
               h=high[bar];
              }
           }
        }
      if(lb!=count) lb=count;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| The function of indicator's first initialization                 |
//+------------------------------------------------------------------+
void myInit(const int bars,
            const double &Open[],
            const double &High[],
            const double &Low[],
            const double &Close[])
  {
//--- 
   int index,index1;
   int bars1=bars-1;
   fPoint_i=0;
   h=High[bars1];
   l=Low[bars1];
   for(index=bars-2; index>=0; index--)
     {
      index1=index+1;
      if(High[index]>High[index1] || Low[index]<Low[index1])
        {
         if(High[index]>h && High[index]>High[index1]) s_up++;
         if(Low[index]<l && Low[index]<Low[index1]) s_dn++;
        }
      else continue;
      if(s_up==s_dn && s_up==GSv_range)
        {
         h=High[index];
         l=Low[index];
         sPoint_i=bars1-index;
         if(Close[index]>=Open[index])
           {
            s_dn=0;
            IndBuffer[bars1]=Low[bars1];
            IndBuffer[index]=High[index];
            draw_up=1;
            break;
           }
         else
           {
            s_up=0;
            IndBuffer[bars1]=High[bars1];
            IndBuffer[index]=Low[index];
            draw_dn=1;
            break;
           }
        }
      else
        {
         h=High[index];
         l=Low[index];
         sPoint_i=bars1-index;
         if(s_up==GSv_range)
           {
            s_dn=0;
            IndBuffer[bars1]=Low[bars1];
            IndBuffer[index]=High[index];
            draw_up=1;
            break;
           }
         else
           {
            if(s_dn==GSv_range)
              {
               s_up=0;
               IndBuffer[bars1]=High[bars1];
               IndBuffer[index]=Low[index];
               draw_dn=1;
               break;
              }
           }
        }
     }
   initfl=1;
   drawf=sPoint_i;
//---
  }
//+------------------------------------------------------------------+
