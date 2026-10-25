//+------------------------------------------------------------------+
//|                                           ytg_Fractals_Price.mq5 |
//|                                   Copyright © 2007, Yuriy Tokman |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Yuriy Tokman"
#property link      "yuriytokman@gmail.com"
#property description ""
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- two buffers are used for the indicator calculation and drawing
#property indicator_buffers 2
//---- only two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Upper indicator drawing parameters          |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- magenta color is used as the color of the bearish indicator line
#property indicator_color1  clrMagenta
//---- thickness of line of the indicator 1 is equal to 1
#property indicator_width1  1
//---- displaying of the bullish label of the indicator
#property indicator_label1  "Up Fractal"
//+----------------------------------------------+
//|  Lower indicator drawing parameters          |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_ARROW
//---- blue color is used as the color of a bullish candlestick
#property indicator_color2  clrBlue
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying of the bearish label of the indicator
#property indicator_label2 "Down Fractal"

//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input int  UpLable=119;//upper fractal label
input int  DnLable=119;//lower fractal label
input bool ShowPrice=true;
input uint nSize=1;
input color UpColor=clrTeal;
input color DnColor=clrRed;
//+----------------------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double ExtDownFractalsBuffer[];
double ExtUpFractalsBuffer[];
//---
int min_rates_total;
string UpLable_,DnLable_;
//+------------------------------------------------------------------+
//|  Creating a text label                                           |
//+------------------------------------------------------------------+
void CreateArrowRightPrice //CreateArrowRightPrice(0,"",0,Time,Price,Color,3)
(
 long   chart_id,         // chart ID
 string name,             // object name
 int    nwin,             // window index
 datetime Time,           // position of price label by time
 double Price,            // position of price label by vertical
 color  Color,            // text color
 uint    Size             // font size
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_ARROW_RIGHT_PRICE,nwin,Time,Price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,Size);
//ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+     
void Deinit()
  {
//----
   int total;
   string name,sirname;

   total=ObjectsTotal(0,0,-1)-1;

   for(int numb=total; numb>=0 && !IsStopped(); numb--)
     {
      name=ObjectName(0,numb,0,-1);
      sirname=StringSubstr(name,0,StringLen(UpLable_));

      if(sirname==UpLable_) ObjectDelete(0,name);
     }

   total=ObjectsTotal(0,0,-1)-1;

   for(int numb=total; numb>=0 && !IsStopped(); numb--)
     {
      name=ObjectName(0,numb,0,-1);
      sirname=StringSubstr(name,0,StringLen(DnLable_));

      if(sirname==DnLable_) ObjectDelete(0,name);
     }
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of global variables 
   min_rates_total=5;
   UpLable_="Up_Fractals_Price";
   DnLable_="Dn_Fractals_Price";

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtDownFractalsBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,UpLable);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(ExtDownFractalsBuffer,true);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,ExtUpFractalsBuffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator 2 drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,DnLable);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(ExtUpFractalsBuffer,true);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- Setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="Fractals_Price";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   Deinit();
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
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
   if(rates_total<min_rates_total) return(0);

//---- declaration of local variables 
   int limit;
   bool   bFound;
   double dCurrent;
   string stime;

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-3; // starting index for the calculation of all bars
     }
   else
     {
      if(rates_total==prev_calculated) return(rates_total);
      limit=rates_total-prev_calculated+2; // starting index for the calculation of new bars
     }

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Time,true);

//---- main indicator calculation loop
   for(int bar=2; bar<=limit && !IsStopped(); bar++)
     {
      ExtUpFractalsBuffer[bar]=0.0;
      ExtDownFractalsBuffer[bar]=0.0;
            
      //----Fractals up
      bFound=false;
      dCurrent=High[bar];

      if(dCurrent>High[bar+1] && dCurrent>High[bar+2] && dCurrent>High[bar-1] && dCurrent>High[bar-2])
        {
         bFound=true;
         ExtUpFractalsBuffer[bar]=dCurrent;
         if(ShowPrice)
           {
            stime=TimeToString(Time[bar],TIME_DATE|TIME_MINUTES);
            CreateArrowRightPrice(0,DnLable_+stime,0,Time[bar],High[bar],DnColor,nSize);
           }
        }
      //----6 bars Fractal
      if(!bFound && (rates_total-bar-1)>=3)
        {
         if(dCurrent==High[bar+1] && dCurrent>High[bar+2] && dCurrent>High[bar+3] && 
            dCurrent>High[bar-1] && dCurrent>High[bar-2])
           {
            bFound=true;
            ExtUpFractalsBuffer[bar]=dCurrent;
           }
        }
      //----7 bars Fractal
      if(!bFound && (rates_total-bar-1)>=4)
        {
         if(dCurrent>=High[bar+1] && dCurrent==High[bar+2] && dCurrent>High[bar+3] && dCurrent>High[bar+4] && 
            dCurrent>High[bar-1] && dCurrent>High[bar-2])
           {
            bFound=true;
            ExtUpFractalsBuffer[bar]=dCurrent;
           }
        }
      //----8 bars Fractal                          
      if(!bFound && (rates_total-bar-1)>=5)
        {
         if(dCurrent>=High[bar+1] && dCurrent==High[bar+2] && dCurrent==High[bar+3] && dCurrent>High[bar+4] && dCurrent>High[bar+5] && 
            dCurrent>High[bar-1] && dCurrent>High[bar-2])
           {
            bFound=true;
            ExtUpFractalsBuffer[bar]=dCurrent;
           }
        }
      //----9 bars Fractal                                        
      if(!bFound && (rates_total-bar-1)>=6)
        {
         if(dCurrent>=High[bar+1] && dCurrent==High[bar+2] && dCurrent>=High[bar+3] && dCurrent==High[bar+4] && dCurrent>High[bar+5] && 
            dCurrent>High[bar+6] && dCurrent>High[bar-1] && dCurrent>High[bar-2])
           {
            bFound=true;
            ExtUpFractalsBuffer[bar]=dCurrent;
           }
        }

      //----Fractals down
      bFound=false;
      dCurrent=Low[bar];

      if(dCurrent<Low[bar+1] && dCurrent<Low[bar+2] && dCurrent<Low[bar-1] && dCurrent<Low[bar-2])
        {
         bFound=true;
         ExtDownFractalsBuffer[bar]=dCurrent;
         if(ShowPrice)
           {
            stime=TimeToString(Time[bar],TIME_DATE|TIME_MINUTES);
            CreateArrowRightPrice(0,UpLable_+stime,0,Time[bar],Low[bar],UpColor,nSize);
           }
        }
      //----6 bars Fractal
      if(!bFound && (rates_total-bar-1)>=3)
        {
         if(dCurrent==Low[bar+1] && dCurrent<Low[bar+2] && dCurrent<Low[bar+3] && 
            dCurrent<Low[bar-1] && dCurrent<Low[bar-2])
           {
            bFound=true;
            ExtDownFractalsBuffer[bar]=dCurrent;
           }
        }
      //----7 bars Fractal
      if(!bFound && (rates_total-bar-1)>=4)
        {
         if(dCurrent<=Low[bar+1] && dCurrent==Low[bar+2] && dCurrent<Low[bar+3] && dCurrent<Low[bar+4] && 
            dCurrent<Low[bar-1] && dCurrent<Low[bar-2])
           {
            bFound=true;
            ExtDownFractalsBuffer[bar]=dCurrent;
           }
        }
      //----8 bars Fractal                          
      if(!bFound && (rates_total-bar-1)>=5)
        {
         if(dCurrent<=Low[bar+1] && dCurrent==Low[bar+2] && dCurrent==Low[bar+3] && dCurrent<Low[bar+4] && dCurrent<Low[bar+5] && 
            dCurrent<Low[bar-1] && dCurrent<Low[bar-2])
           {
            bFound=true;
            ExtDownFractalsBuffer[bar]=dCurrent;
           }
        }
      //----9 bars Fractal                                        
      if(!bFound && (rates_total-bar-1)>=6)
        {
         if(dCurrent<=Low[bar+1] && dCurrent==Low[bar+2] && dCurrent<=Low[bar+3] && dCurrent==Low[bar+4] && dCurrent<Low[bar+5] && 
            dCurrent<Low[bar+6] && dCurrent<Low[bar-1] && dCurrent<Low[bar-2])
           {
            bFound=true;
            ExtDownFractalsBuffer[bar]=dCurrent;
           }
        }
     }
//----     
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
