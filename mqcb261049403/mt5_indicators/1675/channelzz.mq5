//+------------------------------------------------------------------+
//|                                                    ChannelZZ.mq5 |
//|                                       Copyright © 2008, Tinytjan |
//|                                                 tinytjan@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Tinytjan"
#property link      "tinytjan@mail.ru"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 5 
//---- only three plots are used
#property indicator_plots   3
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- BlueViolet color is used as the color of the bullish line of the indicator
#property indicator_color1 clrBlueViolet
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- the width of indicator line is equal to 3
#property indicator_width1  3
//---- displaying the indicator label
#property indicator_label1  "ZigZag"

//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type2   DRAW_LINE
//---- DarkOrange color is used as the color of the bullish line of the indicator
#property indicator_color2 clrDarkOrange
//---- the indicator line is a dashed line
#property indicator_style2  STYLE_DASH
//---- indicator line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator label
#property indicator_label2  "Upper boundary of the channel"

//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type3   DRAW_LINE
//---- DarkOrange color is used as the color of the bullish line of the indicator
#property indicator_color3 clrDarkOrange
//---- the indicator line is a dashed line
#property indicator_style3  STYLE_DASH
//---- indicator line width is equal to 1
#property indicator_width3  1
//---- displaying the indicator label
#property indicator_label3  "Lower boundary of the channel"

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input uint  SmoothPeriod=1; //The period for smoothing extremums, for filtering spikes
input uint  ChannelWidth=150; //Channel width, in points
input uint  FontSize=10; //Text font size
input color TextColor=clrBlue; // The text color                                            
input bool  DrawChannel=true; //Full recalculation with delay of the work
input int   Shift=0; // horizontal shift of the indicator in bars
//+-----------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double ZZ[];
double UpChannel[];
double DownChannel[];
double SmoothedMaxValues[];
double SmoothedMinValues[];

string symbol;

//+-----------------------------------+
//|  declaration of constants         |
//+-----------------------------------+
#define RESET 0 // the constant for returning the indicator recalculation command to the terminal
#define UP +1
#define DN -1
#define NONE 0
//+-----------------------------------+
int Direction;

datetime StartMax;
datetime EndMax;
datetime StartMin;
datetime EndMin;

// ZZ variables
datetime StartDraw;
datetime EndDraw;
double StartDrawValue;
double EndDrawValue;

// Channel Variables
datetime StartChannel;
datetime EndChannel;
double StartChannelValue;
double EndChannelValue;

// ObjectVariables
int Counter;
int Length;
double LastLength;

//---- Declaration of integer variables for the indicator handles
int UpMA_Handle,DnMA_Handle;
//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of data calculation starting point
   min_rates_total=int(30+SmoothPeriod+4);

//---- getting the iMA indicator handle
   UpMA_Handle=iMA(NULL,PERIOD_CURRENT,SmoothPeriod,0,MODE_EMA,PRICE_HIGH);
   if(UpMA_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iMA indicator");

//---- getting the iMA indicator handle
   DnMA_Handle=iMA(NULL,PERIOD_CURRENT,SmoothPeriod,0,MODE_EMA,PRICE_LOW);
   if(DnMA_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iMA indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,ZZ,INDICATOR_DATA);
//---- indexing the elements in buffers as in timeseries   
   ArraySetAsSeries(ZZ,true);
//---- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,UpChannel,INDICATOR_DATA);
//---- indexing the elements in buffers as in timeseries   
   ArraySetAsSeries(UpChannel,true);
//---- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(2,DownChannel,INDICATOR_DATA);
//---- indexing the elements in buffers as in timeseries   
   ArraySetAsSeries(DownChannel,true);
//---- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(3,SmoothedMaxValues,INDICATOR_CALCULATIONS);
//---- indexing the elements in buffers as in timeseries   
   ArraySetAsSeries(SmoothedMaxValues,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(4,SmoothedMinValues,INDICATOR_CALCULATIONS);
//---- indexing the elements in buffers as in timeseries   
   ArraySetAsSeries(SmoothedMinValues,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"ChannelZZ(",SmoothPeriod,",",ChannelWidth,",",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- end of initialization
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+     
void OnDeinit(const int reason)
  {
//----
   int total=ObjectsTotal(0,0,-1)-1;
   string name,sirname;

   for(int numb=total; numb>=0 && !IsStopped(); numb--)
     {
      name=ObjectName(0,numb,0,-1);

      sirname=StringSubstr(name,0,StringLen("Stats"));
      if(sirname=="Stats") ObjectDelete(0,name);
     }
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of minimums of price for the calculation of indicator
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking for the sufficiency of the number of bars for the calculation
   if(BarsCalculated(UpMA_Handle)<rates_total
      || BarsCalculated(DnMA_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- declaration of local variables 
   int to_copy,limit,bar;
   double;

//---- calculations of the necessary number of copied data and limit starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-1; // starting number for calculation of all bars
      symbol=Symbol();
      Direction=NONE;
      Counter=0;
      StartMax=0;
      EndMax=0;
      StartMin=0;
      EndMin=0;
      Length=0;
      LastLength=EMPTY_VALUE;
     }
   else
     {
      limit=rates_total-prev_calculated; // starting number for the calculation of new bars
     }

   to_copy=limit+1;

//---- copy newly appeared data into the arrays
   if(CopyBuffer(UpMA_Handle,0,0,to_copy,SmoothedMaxValues)<=0) return(RESET);
   if(CopyBuffer(DnMA_Handle,0,0,to_copy,SmoothedMinValues)<=0) return(RESET);

//---- main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ZZ[bar]=0.0;
      UpChannel[bar]=0.0;
      DownChannel[bar]=0.0;
      RePaintChannels(bar);

      switch(Direction)
        {
         case  NONE: CheckInit(bar,time); break;
         case  UP:   CheckUp(bar,time); break;
         case  DN:   CheckDown(bar,time); break;
        }
     }

   if(prev_calculated>rates_total || prev_calculated<=0) limit-=4;
//---- unnecessary labels deleting loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(ZZ[bar+2]>ZZ[bar+1] && ZZ[bar+1]<ZZ[bar] || ZZ[bar+2]<ZZ[bar+1] && ZZ[bar+1]>ZZ[bar]) continue;
      else if(ZZ[bar+2] && ZZ[bar+1] && ZZ[bar]) ObjectDelete(0,"Stats"+TimeToString(time[bar+1],TIME_DATE|TIME_MINUTES)); 
     }
//----     
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckInit(int offset,const datetime  &Time[])
  {
//----
   if(StartMax==0 || StartMin==0)
     {
      if(!StartMax) StartMax = Time[offset];
      if(!StartMin) StartMin = Time[offset];

      return;
     }

   if(Direction==NONE)
     {
      double maxValue = SmoothedMaxValues[iBarShift(symbol, 0, StartMax)];
      double minValue = SmoothedMinValues[iBarShift(symbol, 0, StartMin)];

      double nowMax = SmoothedMaxValues[offset];
      double nowMin = SmoothedMaxValues[offset];

      if(nowMax>maxValue && Time[offset]>StartMax)
        {
         // Logic
         EndMax=Time[offset];
         StartMin=Time[offset];
         Direction=UP;

         // Drawing
         StartDraw=StartMax;
         EndDraw=EndMax;
         StartDrawValue=maxValue;
         EndDrawValue=nowMax;

         StartChannel=StartMax;
         EndChannel=EndMax;
         StartChannelValue=maxValue;
         EndChannelValue=nowMax;

         Length=int(NormalizeDouble((nowMax-maxValue)/_Point,0));

         RePaint();
        }
      else if(nowMin>minValue && Time[offset]>StartMin)
        {
         // Logic
         EndMin=Time[offset];
         StartMax=Time[offset];
         Direction=DN;

         // Drawing
         StartDraw=StartMin;
         EndDraw=EndMin;
         StartDrawValue=minValue;
         EndDrawValue=nowMin;

         StartChannel=StartMin;
         EndChannel=EndMin;
         StartChannelValue=minValue;
         EndChannelValue=nowMin;

         Length=int(NormalizeDouble((minValue-nowMin)/_Point,0));

         RePaint();
        }
     }
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckUp(int offset,const datetime  &Time[])
  {
//----
   int startIndex=iBarShift(symbol,PERIOD_CURRENT,StartMax);
   int endIndex=iBarShift(symbol,PERIOD_CURRENT,EndMax);

   double endMaxValue=SmoothedMaxValues[endIndex];

   if(endMaxValue<SmoothedMaxValues[offset])
     {
      // Logic
      endMaxValue=SmoothedMaxValues[offset];
      EndMax=Time[offset];

      // Drawing
      EndDraw=EndMax;
      EndDrawValue=endMaxValue;

      EndChannel=EndMax;
      EndChannelValue=endMaxValue;

      double endMinValue=SmoothedMinValues[iBarShift(symbol,PERIOD_CURRENT,EndMin)];
      Length=int(NormalizeDouble((endMaxValue-endMinValue)/_Point,0));

      RePaint();
     }
   else
     {
      double startMaxValue = SmoothedMaxValues[startIndex];
      double startMinValue = SmoothedMinValues[iBarShift(symbol, 0, StartMin)];

      double nowMaxValue=endMaxValue;
      if(startIndex-endIndex!=0)
        {
         nowMaxValue+=(endMaxValue-startMaxValue)/(startIndex-endIndex)*(endIndex-offset);
        }

      double nowMinValue=SmoothedMinValues[offset];

      if(nowMaxValue-nowMinValue>ChannelWidth*_Point)
        {
         if(EndMax!=offset)
           {
            StartMin=Time[offset];
            EndMin=Time[offset];
            Direction=DN;

            // Drawing
            StartDraw=EndMax;
            EndDraw=EndMin;
            StartDrawValue=endMaxValue;
            EndDrawValue=nowMinValue;

            StartChannel=EndMin;
            EndChannel=EndMin;
            StartChannelValue=nowMinValue;
            EndChannelValue=nowMinValue;

            Counter++;

            LastLength=Length;
            Length=int(NormalizeDouble((endMaxValue-nowMinValue)/_Point,0));

            RePaint();
           }
        }
     }
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckDown(int offset,const datetime  &Time[])
  {
//----
   int startIndex=iBarShift(symbol,PERIOD_CURRENT,StartMin);
   int endIndex=iBarShift(symbol,PERIOD_CURRENT,EndMin);

   double endMinValue=SmoothedMinValues[endIndex];

   if(endMinValue>SmoothedMinValues[offset])
     {
      endMinValue=SmoothedMinValues[offset];
      EndMin=Time[offset];

      // Drawing
      EndDraw=EndMin;
      EndDrawValue=endMinValue;

      EndChannel=EndMin;
      EndChannelValue=endMinValue;

      double endMaxValue=SmoothedMaxValues[iBarShift(symbol,PERIOD_CURRENT,EndMax)];
      Length=int(NormalizeDouble((endMaxValue-endMinValue)/_Point,0));

      RePaint();
     }
   else
     {
      double startMinValue = SmoothedMinValues[startIndex];
      double startMaxValue = SmoothedMaxValues[iBarShift(symbol, 0, StartMax)];

      double nowMinValue=endMinValue;
      if(startIndex-endIndex!=0)
        {
         nowMinValue+=(endMinValue-startMinValue)/(startIndex-endIndex)*(endIndex-offset);
        }

      double nowMaxValue=SmoothedMaxValues[offset];

      if(nowMaxValue-nowMinValue>ChannelWidth*_Point)
        {
         if(EndMin!=offset)
           {
            EndMax=Time[offset];
            StartMax=Time[offset];
            Direction=UP;

            // Drawing
            StartDraw=EndMin;
            EndDraw=EndMax;
            StartDrawValue=endMinValue;
            EndDrawValue=nowMaxValue;

            StartChannel=EndMax;
            EndChannel=EndMax;
            StartChannelValue=nowMaxValue;
            EndChannelValue=nowMaxValue;

            Counter++;

            LastLength=Length;
            Length=int(NormalizeDouble((nowMaxValue-endMinValue)/_Point,0));

            RePaint();
           }
        }
     }
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RePaint()
  {
//----
   double pos=EndDrawValue;
   if(Direction==UP) pos+=15*_Point;

   string id="Stats"+TimeToString(EndDraw,TIME_DATE|TIME_MINUTES);
   string text;
   if(LastLength) text=text+DoubleToString((0.0001+Length)/(0.0001+LastLength),2);
   text=text+"("+string(Length)+")";

   SetText(0,id,0,EndDraw,pos,text,TextColor,"Arial Black",FontSize,ANCHOR_CENTER);

   int start=iBarShift(symbol,PERIOD_CURRENT,StartDraw);
   int end=iBarShift(symbol,PERIOD_CURRENT,EndDraw);

   if(start==end)
     {
      ZZ[end]=EndDrawValue;
      return;
     }

   double preValue=(EndDrawValue-StartDrawValue)/(end-start);

   for(int i=start; i>=end; i--)
     {
      ZZ[i]=StartDrawValue+preValue*(i-start);
     }
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RePaintChannels(int offset)
  {
//----
   if(Direction==NONE) return;
   if(!DrawChannel) return;

   int start=iBarShift(symbol,PERIOD_CURRENT,StartChannel);
   int end=iBarShift(symbol,PERIOD_CURRENT,EndChannel);

   if(start==end)
     {
      if(Direction==UP)
        {
         UpChannel[start]=StartChannelValue;
         DownChannel[start]=StartChannelValue-ChannelWidth*_Point;
        }
      else
        {
         DownChannel[start]=StartChannelValue;
         UpChannel[start]=StartChannelValue+ChannelWidth*_Point;
        }

      for(int i=start-1; i>=offset; i--)
        {
         DownChannel[i]=DownChannel[i+1];
         UpChannel[i]=UpChannel[i+1];
        }
      return;
     }

   double preValue=(EndChannelValue-StartChannelValue)/(end-start);

   if(Direction==UP)
     {
      for(int i=start-1; i>=offset; i--)
        {
         UpChannel[i]=StartChannelValue+preValue*(i-start);
         DownChannel[i]=UpChannel[i]-ChannelWidth*_Point;
        }
     }
   else if(Direction==DN)
     {
      for(int i=start; i>=offset; i--)
        {
         DownChannel[i]=StartChannelValue+preValue*(i-start);
         UpChannel[i]=DownChannel[i]+ChannelWidth*_Point;
        }
     }
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int iBarShift(string symbol_,ENUM_TIMEFRAMES timeframe,datetime time)

// iBarShift(symbol, timeframe, time)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   if(time<0) return(-1);
   datetime Arr[],time1;

   time1=(datetime)SeriesInfoInteger(symbol_,timeframe,SERIES_LASTBAR_DATE);

   if(CopyTime(symbol_,timeframe,time,time1,Arr)>0)
     {
      int size=ArraySize(Arr);
      return(size-1);
     }
   else return(-1);
//----
  }
//+------------------------------------------------------------------+
//|  creating a text label                                           |
//+------------------------------------------------------------------+
void CreateText(long chart_id,// chart ID
                string   name,              // object name
                int      nwin,              // window index
                datetime time,              // price level time
                double   price,             // price level
                string   text,              // Labels text
                color    Color,             // Text color
                string   Font,              // Text font
                int      Size,              // Text size
                ENUM_ANCHOR_POINT point     // The chart corner to Which an text is attached
                )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_TEXT,nwin,time,price);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
   ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,false);
   ObjectSetInteger(chart_id,name,OBJPROP_ANCHOR,point);
//----
  }
//+------------------------------------------------------------------+
//|  changing a text label                                           |
//+------------------------------------------------------------------+
void SetText(long chart_id,// chart ID
             string   name,              // object name
             int      nwin,              // window index
             datetime time,              // price level time
             double   price,             // price level
             string   text,              // Labels text
             color    Color,             // Text color
             string   Font,              // Text font
             int      Size,              // Text size
             ENUM_ANCHOR_POINT point     // The chart corner to Which an text is attached
             )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateText(chart_id,name,nwin,time,price,text,Color,Font,Size,point);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time,price);
     }
//----
  }
//+------------------------------------------------------------------+
