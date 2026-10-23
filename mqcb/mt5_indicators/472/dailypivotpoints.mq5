//+------------------------------------------------------------------+
//|                                             DailyPivotPoints.mq5 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       https://www.metaquotes.net |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
//---- link to the website of the author
#property link      "https://www.metaquotes.net/"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- two buffers are used for calculation and drawing the indicator
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- blue color is used as the color of the indicator 1 line
#property indicator_color1  Blue
//---- the indicator 1 line is a continuous curve
#property indicator_style1  STYLE_DASHDOTDOT
//---- thickness of the indicator 1 line is equal to 1
#property indicator_width1  1
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//---- drawing indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- magenta color is used for the indicator 2 line
#property indicator_color2  Magenta
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_DASHDOTDOT
//---- thickness of the indicator 2 line is equal to 1
#property indicator_width2  1
//+-----------------------------------+
//|  enumeration declaration          |
//+-----------------------------------+
enum Number
  {
   Number_0,
   Number_1,
   Number_2,
   Number_3
  };
//+-----------------------------------+
//|  enumeration declaration          |
//+-----------------------------------+  
enum Width
  {
   Width_1=1, //1
   Width_2,   //2
   Width_3,   //3
   Width_4,   //4
   Width_5    //5
  };
//+-----------------------------------+
//|  enumeration declaration          |
//+-----------------------------------+
enum STYLE
  {
   SOLID_,      //Solid line
   DASH_,       //Dashed line
   DOT_,        //Dotted line
   DASHDOT_,    //Dot-dash line
   DASHDOTDOT_  //Dot-dash line with double dots
  };
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input Number  ExtFormula=Number_0;
input int  ExtHowManyDays=30;
input bool ExtDraw=true;

input color  Color_R30 = MediumSeaGreen; //R30 level color
input color  Color_R25 = MediumSeaGreen; //R25 level color
input color  Color_R20 = MediumSeaGreen; //R20 level color
input color  Color_R15 = MediumSeaGreen; //R15 level color
input color  Color_R10 = MediumSeaGreen; //R10 level color
input color  Color_R05 = MediumSeaGreen; //R05 level color
input color     Color_P= DarkOrchid;     //P level color
input color  Color_S05 = Red;            //S05 level color
input color  Color_S10 = Red;            //S10 level color
input color  Color_S15 = Red;            //S15 level color
input color  Color_S20 = Red;            //S20 level color
input color  Color_S25 = Red;            //S25 level color
input color  Color_S30 = Red;            //S30 level color
//----
input STYLE  Style_R30 = SOLID_;      //R30 level line style
input STYLE  Style_R25 = DASHDOTDOT_; //R25 level line style
input STYLE  Style_R20 = SOLID_;      //R20 level line style
input STYLE  Style_R15 = DASHDOTDOT_; //R15 level line style
input STYLE  Style_R10 = SOLID_;      //R10 level line style
input STYLE  Style_R05 = DASHDOTDOT_; //R05 level line style
input STYLE    Style_P = DASH_;       //P level line style
input STYLE  Style_S05 = DASHDOTDOT_; //S05 level line style
input STYLE  Style_S10 = SOLID_;      //S10 level line style
input STYLE  Style_S15 = DASHDOTDOT_; //S15 level line style
input STYLE  Style_S20 = SOLID_;      //S20 level line style
input STYLE  Style_S25 = DASHDOTDOT_; //S25 level line style
input STYLE  Style_S30 = SOLID_;      //S30 level line style
//----
input Width  Width_R30 = Width_1; //R30 level line width
input Width  Width_R25 = Width_1; //R25 level line width
input Width  Width_R20 = Width_2; //R20 level line width
input Width  Width_R15 = Width_1; //R15 level line width
input Width  Width_R10 = Width_3; //R10 level line width
input Width  Width_R05 = Width_1; //R05 level line width
input Width    Width_P = Width_1; //P level line width
input Width  Width_S05 = Width_1; //S05 level line width
input Width  Width_S10 = Width_3; //S10 level line width
input Width  Width_S15 = Width_1; //S15 level line width
input Width  Width_S20 = Width_2; //S20 level line width
input Width  Width_S25 = Width_1; //S25 level line width
input Width  Width_S30 = Width_1; //S30 level line width
//+----------------------------------------------+
//---- declaration of dynamic arrays that
// will be used as indicator buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//|  Creating horizontal price level                                 |
//+------------------------------------------------------------------+
void CreateHline
(
 long   chart_id,  // chart ID
 string name,      // object name
 int    nwin,      // window index
 double price,     // price level
 color  Color,     // line color
 int    style,     // line style
 int    width,     // line width
 string text       // text
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_HLINE,0,0,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//----
  }
//+------------------------------------------------------------------+
//|  Reinstallation of the horizontal price level                    |
//+------------------------------------------------------------------+
void SetHline(long   chart_id,  // chart ID
              string name,      // object name
              int    nwin,      // window index
              double price,     // price level
              color  Color,     // line color
              int    style,     // line style
              int    width,     // line width
              string text       // text
              )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateHline(chart_id,name,nwin,price,Color,style,width,text);
   else
     {
      //ObjectSetDouble(chart_id,name,OBJPROP_PRICE,price);
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,0,price);
     }
//----
  }
//+------------------------------------------------------------------+   
//| iBarShift() function                                             |
//+------------------------------------------------------------------+
int iBarShift(string symbol,ENUM_TIMEFRAMES timeframe,datetime time)
  {
//----
   if(time<0) return(-1);
   datetime Arr[],time1;

   time1=(datetime)SeriesInfoInteger(symbol,timeframe,SERIES_LASTBAR_DATE);

   if(CopyTime(symbol,timeframe,time,time1,Arr)>0)
     {
      int size=ArraySize(Arr);
      return(size-1);
     }
   else return(-1);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//----
   int draw_begin;
   if(ExtHowManyDays < 1) draw_begin=0;
   else                   draw_begin=ExtHowManyDays;
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtMapBuffer1,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,0);
//---- performing the shift of beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,draw_begin);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtMapBuffer1,true);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set ExtMapBuffer2[] dynamic array as indicator buffer
   SetIndexBuffer(1,ExtMapBuffer2,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,0);
//---- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,draw_begin);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtMapBuffer2,true);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- create the labels to display in DataWindow and the name 
//---- to be displayed in a separate sub-window and in a tooltip
   if(ExtDraw)
     {
      if(ExtFormula==Number_0)
        {
         IndicatorSetString(INDICATOR_SHORTNAME,"Pivot");
         PlotIndexSetString(0,PLOT_LABEL,"Pivot");
         PlotIndexSetString(1,PLOT_LABEL,NULL);
        }
      else
        {
         IndicatorSetString(INDICATOR_SHORTNAME,"Support&Resistance");
         PlotIndexSetString(0,PLOT_LABEL,"Resistance");
         PlotIndexSetString(1,PLOT_LABEL,"Support");
        }
     }
   else
     {
      PlotIndexSetString(0,PLOT_LABEL,NULL);
      PlotIndexSetString(1,PLOT_LABEL,NULL);
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,"Pivot_Line");
   ObjectDelete(0,"R0.5_Line");
   ObjectDelete(0,"R1.0_Line");
   ObjectDelete(0,"R1.5_Line");
   ObjectDelete(0,"R2.0_Line");
   ObjectDelete(0,"R2.5_Line");
   ObjectDelete(0,"R3.0_Line");
   ObjectDelete(0,"S0.5_Line");
   ObjectDelete(0,"S1.0_Line");
   ObjectDelete(0,"S1.5_Line");
   ObjectDelete(0,"S2.0_Line");
   ObjectDelete(0,"S2.5_Line");
   ObjectDelete(0,"S3.0_Line");
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- 
   if(_Period>=PERIOD_D1) return(0);

//---- declarations of static variables    
   static double yesterday_high,yesterday_low,yesterday_close;
   static double P,S05,R05,S10,R10,S15,R15,S20,R20,S25,R25,S30,R30;

   if(prev_calculated!=rates_total)
     {
      //---- declarations of local variables 
      int    begin_bar,first_bar,last_bar,cnt,copy;
      double S=0,R=0,today_open;
      double iClose[],iOpen[],iHigh[],iLow[];
      datetime iTime[];

      //---- set check beginning
      if(ExtHowManyDays < 1) begin_bar=Bars(NULL,PERIOD_D1)-2;
      else                   begin_bar=ExtHowManyDays-1;

      //---- indexing elements in arrays as timeseries  
      ArraySetAsSeries(time,true);
      ArraySetAsSeries(iTime,true);
      ArraySetAsSeries(iClose,true);
      ArraySetAsSeries(iOpen,true);
      ArraySetAsSeries(iHigh,true);
      ArraySetAsSeries(iLow,true);

      copy=begin_bar+2;

      if(CopyTime(NULL,PERIOD_D1,0,copy,iTime)<copy)return(0);
      if(CopyClose(NULL,PERIOD_D1,0,copy,iClose)<copy)return(0);
      if(CopyOpen(NULL,PERIOD_D1,0,copy,iOpen)<copy)return(0);
      if(CopyHigh(NULL,PERIOD_D1,0,copy,iHigh)<copy)return(0);
      if(CopyLow(NULL,PERIOD_D1,0,copy,iLow)<copy)return(0);

      //---- 
      cnt=0;
      while(true)
        {
         if(iTime[0]>=(time[0]-PERIOD_D1*60)) break;
         cnt++;
         if(cnt>5) return(0);
         Sleep(1000);
        }

      //----
      if(ExtDraw==false || prev_calculated!=0) begin_bar=0;

      //----
      for(cnt=begin_bar; cnt>=0; cnt--)
        {

         if(cnt<rates_total)
           {
            ExtMapBuffer1[cnt]=0.0;
            ExtMapBuffer2[cnt]=0.0;
           }

         yesterday_close=iClose[cnt+1];
         today_open=iOpen[cnt];
         yesterday_high=iHigh[cnt+1];
         yesterday_low=iLow[cnt+1];
         P=(yesterday_high+yesterday_low+yesterday_close+today_open)/4;
         switch(ExtFormula)
           {
            case 1 :
               R = P + P - yesterday_low;
               S = P + P - yesterday_high;
               break;
            case 2 :
               R = P + yesterday_high - yesterday_low;
               S = P - yesterday_high + yesterday_low;
               break;
            case 3 :
               R = P + P - yesterday_low - yesterday_low + yesterday_high;
               S = P + P - yesterday_high - yesterday_high + yesterday_low;
           }
         if(ExtDraw==true)
           {
            first_bar=iBarShift(NULL,0,iTime[cnt])-1;

            if(cnt>0) last_bar=iBarShift(NULL,0,iTime[cnt-1])-1;
            else last_bar=0;

            while(first_bar>=last_bar)
              {
               if(first_bar==last_bar && last_bar>0 || first_bar<0) break;
               if(ExtFormula==0) ExtMapBuffer1[first_bar]=P;
               else
                 {
                  ExtMapBuffer1[first_bar]=R;
                  ExtMapBuffer2[first_bar]=S;
                 }
               first_bar--;
              }
           }
        }

      P=NormalizeDouble((yesterday_high+yesterday_low+yesterday_close)/3,_Digits);

      R10 = NormalizeDouble((2*P)-yesterday_low,_Digits);
      S10 = NormalizeDouble((2*P)-yesterday_high,_Digits);

      R05 = NormalizeDouble((P+R10)/2,_Digits);
      S05 = NormalizeDouble((P+S10)/2,_Digits);

      R20 = NormalizeDouble(P+(yesterday_high-yesterday_low),_Digits);
      S20 = NormalizeDouble(P-(yesterday_high-yesterday_low),_Digits);

      R15 = NormalizeDouble((R10+R20)/2,_Digits);
      S15 = NormalizeDouble((S10+S20)/2,_Digits);

      R30 = NormalizeDouble(2*P+(yesterday_high-2*yesterday_low),_Digits);
      S30 = NormalizeDouble(2*P-(2*yesterday_high-yesterday_low),_Digits);

      R25 = NormalizeDouble((R20+R30)/2,_Digits);
      S25 = NormalizeDouble((S20+S30)/2,_Digits);
     }

   SetHline(0,"R3.0_Line",0,R30,Color_R30,Style_R30,Width_R30,"Pivot "+DoubleToString(R30,_Digits));
   SetHline(0,"R2.5_Line",0,R25,Color_R25,Style_R25,Width_R25,"Pivot "+DoubleToString(R25,_Digits));
   SetHline(0,"R2.0_Line",0,R20,Color_R20,Style_R20,Width_R20,"Pivot "+DoubleToString(R20,_Digits));
   SetHline(0,"R1.5_Line",0,R15,Color_R15,Style_R15,Width_R15,"Pivot "+DoubleToString(R15,_Digits));
   SetHline(0,"R1.0_Line",0,R10,Color_R10,Style_R10,Width_R10,"Pivot "+DoubleToString(R10,_Digits));
   SetHline(0,"R0.5_Line",0,R05,Color_R05,Style_R05,Width_R05,"Pivot "+DoubleToString(R05,_Digits));
   SetHline(0,"Pivot_Line",0,P,Color_P,Style_P,Width_P,"Pivot "+DoubleToString(P,_Digits));
   SetHline(0,"S0.5_Line",0,S05,Color_S05,Style_S05,Width_S05,"Pivot "+DoubleToString(S05,_Digits));
   SetHline(0,"S1.0_Line",0,S10,Color_S10,Style_S10,Width_S10,"Pivot "+DoubleToString(S10,_Digits));
   SetHline(0,"S1.5_Line",0,S15,Color_S15,Style_S15,Width_S15,"Pivot "+DoubleToString(S15,_Digits));
   SetHline(0,"S2.0_Line",0,S20,Color_S20,Style_S20,Width_S20,"Pivot "+DoubleToString(S20,_Digits));
   SetHline(0,"S2.5_Line",0,S25,Color_S25,Style_S25,Width_S25,"Pivot "+DoubleToString(S25,_Digits));
   SetHline(0,"S3.0_Line",0,S30,Color_S30,Style_S30,Width_S30,"Pivot "+DoubleToString(S30,_Digits));
//----
   ChartRedraw(0);
//----   
   return(rates_total);
  }
//+------------------------------------------------------------------+