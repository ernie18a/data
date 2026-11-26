//+------------------------------------------------------------------+
//|                                       MultiLineMovingAverage.mq5 |
//|                                       Copyright © 2011,  PozitiF |
//|                                                    Alex-W-@bk.ru |
//+------------------------------------------------------------------+ 
//--- author of the indicator
#property copyright "Copyright © 2011,  PozitiF"
//--- link to the website of the author
#property link "Alex-W-@bk.ru" 
//--- indicator version
#property version"1.60"
#property description "The indicator gives signals in case"
//--- drawing the indicator in the main window
#property indicator_chart_window 
#property indicator_buffers 1
#property indicator_plots 1
#define RESET  0
//+------------------------------------------------+ 
//| Enumeration for the level width                |
//+------------------------------------------------+ 
enum ENUM_WIDTH // type of constant
  {
   w_1=1,// 1
   w_2,  // 2
   w_3,  // 3
   w_4,  // 4
   w_5   // 5
  };
//+------------------------------------------------+ 
//| Enumeration for the level actuation indication |
//+------------------------------------------------+ 
enum ENUM_TEXT_POSITION // type of constant
  {
   Left,// left
   Right// Right
  };
//+------------------------------------------------+
//| Indicator input parameters                     |
//+------------------------------------------------+
input string level_name="MultiLineMovingAverage 1"; // Actuation level name
input string level_comment="MultiLineMovingAverage";// Actuation level comment
input ENUM_TEXT_POSITION TxtPos=Right;              // Text position
input uint TextSize=15;                             // Text size
input color  Up_levels_color=Lime;                  // Up MA level color
input color  Fl_levels_color=Gray;                  // Flat MA level color
input color  Dn_levels_color=Red;                   // Down MA level color
input uint CandleCount=10;                          // Level length
//---
input bool display_MA1=true;                        // Show MA Level
input ENUM_TIMEFRAMES Timeframe1=PERIOD_M5;         // Timeframe of MA
input ENUM_MA_METHOD MA1_SMethod=MODE_EMA;          // Smoothing MA method
input uint MA1_Length=10;                           // MA period
input uint MA1_Signal_Bar=1;                        // MA signal bar
input ENUM_APPLIED_PRICE AppliedPrice1=PRICE_CLOSE; // Applied price
input ENUM_LINE_STYLE level1_style=STYLE_SOLID;     // Actuation level style
input ENUM_WIDTH level1_width=w_2;                  // Actuation level width
//---
input bool display_MA2=true;                        // Show MA Level
input ENUM_TIMEFRAMES Timeframe2=PERIOD_M30;        // Timeframe of MA
input ENUM_MA_METHOD MA2_SMethod=MODE_EMA;          // Smoothing MA method
input uint MA2_Length=10;                           // MA period
input uint MA2_Signal_Bar=1;                        // MA signal bar
input ENUM_APPLIED_PRICE AppliedPrice2=PRICE_CLOSE; // Applied price
input ENUM_LINE_STYLE level2_style=STYLE_SOLID;     // Actuation level style
input ENUM_WIDTH level2_width=w_2;                  // Actuation level width
//---
input bool display_MA3=true;                        // Show MA Level
input ENUM_TIMEFRAMES Timeframe3=PERIOD_H2;         // Timeframe of MA
input ENUM_MA_METHOD MA3_SMethod=MODE_EMA;          // Smoothing MA method
input uint MA3_Length=10;                           // MA period
input uint MA3_Signal_Bar=1;                        // MA signal bar
input ENUM_APPLIED_PRICE AppliedPrice3=PRICE_CLOSE; // Applied price
input ENUM_LINE_STYLE level3_style=STYLE_SOLID;     // Actuation level style
input ENUM_WIDTH level3_width=w_2;                  // Actuation level width
//---
input bool display_MA4=true;                        // Show MA Level
input ENUM_TIMEFRAMES Timeframe4=PERIOD_H4;         // Timeframe of MA
input ENUM_MA_METHOD MA4_SMethod=MODE_EMA;          // Smoothing MA method
input uint MA4_Length=10;                           // MA period
input uint MA4_Signal_Bar=1;                        // MA signal bar  
input ENUM_APPLIED_PRICE AppliedPrice4=PRICE_CLOSE; // Applied price
input ENUM_LINE_STYLE level4_style=STYLE_SOLID;     // Actuation level style
input ENUM_WIDTH level4_width=w_2;                  // Actuation level width
//---
input bool display_MA5=true;                        // Show MA Level
input ENUM_TIMEFRAMES Timeframe5=PERIOD_H12;        // Timeframe of MA
input ENUM_MA_METHOD MA5_SMethod=MODE_EMA;          // Smoothing MA method
input uint MA5_Length=10;                           // MA period
input uint MA5_Signal_Bar=1;                        // MA signal bar
input ENUM_APPLIED_PRICE AppliedPrice5=PRICE_CLOSE; // Applied price
input ENUM_LINE_STYLE level5_style=STYLE_SOLID;     // Actuation level style
input ENUM_WIDTH level5_width=w_2;                  // Actuation level width
//---
input bool display_MA6=true;                        // Show MA Level
input ENUM_TIMEFRAMES Timeframe6=PERIOD_D1;         // Timeframe of MA
input ENUM_MA_METHOD MA6_SMethod=MODE_EMA;          // Smoothing MA method
input uint MA6_Length=10;                           // MA period
input uint MA6_Signal_Bar=1;                        // MA signal bar  
input ENUM_APPLIED_PRICE AppliedPrice6=PRICE_CLOSE; // Applied price
input ENUM_LINE_STYLE level6_style=STYLE_SOLID;     // Actuation level style
input ENUM_WIDTH level6_width=w_2;                  // Actuation level width
//+----------------------------------------------+
uint PerSec,levellength;
string text1_name,text2_name,text3_name,text4_name,text5_name,text6_name;
string level1_name,level2_name,level3_name,level4_name,level5_name,level6_name;
//--- declaration of variables for the indicators handles
int MA1_Handle,MA2_Handle,MA3_Handle,MA4_Handle,MA5_Handle,MA6_Handle;
//+------------------------------------------------------------------+
//|  GetStringTimeframe                                              |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//---
   return(StringSubstr(EnumToString(timeframe),7,-1));
//---
  }
//+------------------------------------------------------------------+
//|  GetStringMAName                                                 |
//+------------------------------------------------------------------+
string GetStringMAName(ENUM_MA_METHOD SMethod)
  {
//---
   switch(SMethod)
     {
      case MODE_SMA: return("SMA");
      case MODE_EMA: return("EMA");
      case MODE_SMMA: return("SMMA");
      case MODE_LWMA: return("LWMA");
     }
//---
   return("SMA");
  }
//+------------------------------------------------------------------+
//|  Trend line creation                                             |
//+------------------------------------------------------------------+
void CreateTline(long chart_id,  // chart ID
                 string name,    // object name
                 int nwin,       // window index
                 datetime time1, // price level time 1
                 double price1,  // price level 1
                 datetime time2, // price level time 2
                 double price2,  // price level 2
                 color Color,    // line color
                 int style,      // line style
                 int width,      // line width
                 string text)    // text
  {
//---
   ObjectCreate(chart_id,name,OBJ_TREND,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,false);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,false);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY,false);
//---
  }
//+------------------------------------------------------------------+
//|  Trend line reinstallation                                       |
//+------------------------------------------------------------------+
void SetTline(long chart_id,  // chart ID
              string name,    // object name
              int nwin,       // window index
              datetime time1, // price level time 1
              double price1,  // price level 1
              datetime time2, // price level time 2
              double price2,  // price level 2
              color Color,    // line color
              int style,      // line style
              int width,      // line width
              string text)    // text
  {
//---
   if(ObjectFind(chart_id,name)==-1)
     {
      CreateTline(chart_id,name,nwin,time1,price1,time2,price2,Color,style,width,text);
     }
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
     }
//---
  }
//+------------------------------------------------------------------+
//|  Text Label creation                                             |
//+------------------------------------------------------------------+
void CreateText(long chart_id,          // chart ID
                string name,            // object name
                int nwin,               // window index
                datetime time,          // price level time
                double price,           // price level
                string text,            // Labels text
                color Color,            // Text color
                string Font,            // Text font
                int Size,               // Text size
                ENUM_ANCHOR_POINT point // The chart corner to Which an text is attached
                )
//--- 
  {
//---
   ObjectCreate(chart_id,name,OBJ_TEXT,nwin,time,price);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
   ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_id,name,OBJPROP_ANCHOR,point);
//---
  }
//+------------------------------------------------------------------+
//|  Text Label reinstallation                                       |
//+------------------------------------------------------------------+
void SetText(long chart_id,           // chart ID
             string name,             // object name
             int nwin,                // window index
             datetime time,           // price level time
             double price,            // price level
             string text,             // Labels text
             color Color,             // Text color
             string Font,             // Text font
             int Size,                // Text size
             ENUM_ANCHOR_POINT point) // The chart corner to Which an text is attached
  {
//---
   if(ObjectFind(chart_id,name)==-1) CreateText(chart_id,name,nwin,time,price,text,Color,Font,Size,point);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time,price);
     }
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- getting handle of the iMA 1 indicator
   if(display_MA1) //Show MA Level
     {
      MA1_Handle=iMA(NULL,Timeframe1,MA1_Length,0,MA1_SMethod,AppliedPrice1);
      if(MA1_Handle==INVALID_HANDLE)
        {
         Print(" Failed to get handle of the iMA 1 indicator");
         return(INIT_FAILED);
        }
     }
//--- getting handle of the iMA 2 indicator
   if(display_MA2) //Show MA Level
     {
      MA2_Handle=iMA(NULL,Timeframe2,MA2_Length,0,MA2_SMethod,AppliedPrice2);
      if(MA2_Handle==INVALID_HANDLE)
        {
         Print(" Failed to get handle of the iMA 2 indicator");
         return(INIT_FAILED);
        }
     }

//--- getting handle of the iMA 3 indicator
   if(display_MA3) //Show MA Level
     {
      MA3_Handle=iMA(NULL,Timeframe3,MA3_Length,0,MA3_SMethod,AppliedPrice3);
      if(MA3_Handle==INVALID_HANDLE)
        {
         Print(" Failed to get handle of the iMA 3 indicator");
         return(INIT_FAILED);
        }
     }

//--- getting handle of the iMA 4 indicator
   if(display_MA4) //Show MA Level
     {
      MA4_Handle=iMA(NULL,Timeframe4,MA4_Length,0,MA4_SMethod,AppliedPrice4);
      if(MA4_Handle==INVALID_HANDLE)
        {
         Print(" Failed to get handle of the iMA 4 indicator");
         return(INIT_FAILED);
        }
     }

//--- getting handle of the iMA 5 indicator
   if(display_MA5) //Show MA Level
     {
      MA5_Handle=iMA(NULL,Timeframe5,MA5_Length,0,MA5_SMethod,AppliedPrice5);
      if(MA5_Handle==INVALID_HANDLE)
        {
         Print(" Failed to get handle of the iMA 5 indicator");
         return(INIT_FAILED);
        }
     }

//--- getting handle of the iMA 6 indicator
   if(display_MA6) //Show MA Level
     {
      MA6_Handle=iMA(NULL,Timeframe6,MA6_Length,0,MA6_SMethod,AppliedPrice6);
      if(MA6_Handle==INVALID_HANDLE)
        {
         Print(" Failed to get handle of the iMA 6 indicator");
         return(INIT_FAILED);
        }
     }
//---
   level1_name=level_name+"_1";
   level2_name=level_name+"_2";
   level3_name=level_name+"_3";
   level4_name=level_name+"_4";
   level5_name=level_name+"_5";
   level6_name=level_name+"_6";
   text1_name=level1_name+"_Text";
   text2_name=level2_name+"_Text";
   text3_name=level3_name+"_Text";
   text4_name=level4_name+"_Text";
   text5_name=level5_name+"_Text";
   text6_name=level6_name+"_Text";
   levellength=PeriodSeconds()*CandleCount;
   PerSec=PeriodSeconds();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+ 
void OnDeinit(const int reason)
  {
//---
   ObjectDelete(0,level1_name);
   ObjectDelete(0,text1_name);
   ObjectDelete(0,level2_name);
   ObjectDelete(0,text2_name);
   ObjectDelete(0,level3_name);
   ObjectDelete(0,text3_name);
   ObjectDelete(0,level4_name);
   ObjectDelete(0,text4_name);
   ObjectDelete(0,level5_name);
   ObjectDelete(0,text5_name);
   ObjectDelete(0,level6_name);
   ObjectDelete(0,text6_name);
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double &high[],     // price array of maximums of price for the indicator calculation
                const double &low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking the number of bars to be enough for the calculation
   if(rates_total==prev_calculated) return(rates_total);
   if(BarsCalculated(MA1_Handle)<Bars(Symbol(),Timeframe1)) return(prev_calculated);
   if(BarsCalculated(MA2_Handle)<Bars(Symbol(),Timeframe2)) return(prev_calculated);
   if(BarsCalculated(MA3_Handle)<Bars(Symbol(),Timeframe3)) return(prev_calculated);
   if(BarsCalculated(MA4_Handle)<Bars(Symbol(),Timeframe4)) return(prev_calculated);
   if(BarsCalculated(MA5_Handle)<Bars(Symbol(),Timeframe5)) return(prev_calculated);
   if(BarsCalculated(MA6_Handle)<Bars(Symbol(),Timeframe6)) return(prev_calculated);
//--- declarations of local variables 
   color LevelColor;
   string text="";
   ENUM_ANCHOR_POINT Point_;
   datetime timeT,time1,time2;
   double MA[2],price,priceT;
   ArraySetAsSeries(time,true);

   switch(TxtPos)
     {
      case Left:
         time1=time[0]-levellength;
         timeT=time1-2*PerSec;
         time2=time[0]+PerSec;
         Point_=ANCHOR_RIGHT;
         break;

      case Right:
         time1=time[0]-levellength;
         time2=time[0]+PerSec;
         timeT=time2+2*PerSec;
         Point_=ANCHOR_LEFT;
         break;
     }

//--- copy the newly appeared data into the UpFractal and DnFractal arrays
   if(display_MA1) //Show MA Level
     {
      if(CopyBuffer(MA1_Handle,0,MA1_Signal_Bar,2,MA)<=0) return(RESET);
      price=MA[1];
      if(MA[1]-MA[0]>0) LevelColor=Up_levels_color;
      else if(MA[1]-MA[0]<0) LevelColor=Dn_levels_color;
      else LevelColor=Fl_levels_color;
      priceT=price;
      text="";
      StringConcatenate(text,GetStringTimeframe(Timeframe1)," ",GetStringMAName(MA1_SMethod),MA1_Length);
      SetTline(0,level1_name,0,time1,price,time2,price,LevelColor,level1_style,level1_width,level_comment);
      CreateText(0,text1_name,0,timeT,priceT,text,LevelColor,"Georgia",TextSize,Point_);
     }
//--- copy the newly appeared data into the UpFractal and DnFractal arrays
   if(display_MA2) //Show MA Level
     {
      if(CopyBuffer(MA2_Handle,0,MA2_Signal_Bar,2,MA)<=0) return(RESET);
      price=MA[1];
      if(MA[1]-MA[0]>0) LevelColor=Up_levels_color;
      else if(MA[1]-MA[0]<0) LevelColor=Dn_levels_color;
      else LevelColor=Fl_levels_color;
      priceT=price;
      text="";
      StringConcatenate(text,GetStringTimeframe(Timeframe2)," ",GetStringMAName(MA2_SMethod),MA2_Length);
      SetTline(0,level2_name,0,time1,price,time2,price,LevelColor,level2_style,level2_width,level_comment);
      CreateText(0,text2_name,0,timeT,priceT,text,LevelColor,"Georgia",TextSize,Point_);
     }
//--- copy the newly appeared data into the UpFractal and DnFractal arrays
   if(display_MA3) //Show MA Level
     {
      if(CopyBuffer(MA3_Handle,0,MA3_Signal_Bar,2,MA)<=0) return(RESET);
      price=MA[1];
      if(MA[1]-MA[0]>0) LevelColor=Up_levels_color;
      else if(MA[1]-MA[0]<0) LevelColor=Dn_levels_color;
      else LevelColor=Fl_levels_color;
      priceT=price;
      text="";
      StringConcatenate(text,GetStringTimeframe(Timeframe3)," ",GetStringMAName(MA3_SMethod),MA3_Length);
      SetTline(0,level3_name,0,time1,price,time2,price,LevelColor,level3_style,level3_width,level_comment);
      CreateText(0,text3_name,0,timeT,priceT,text,LevelColor,"Georgia",TextSize,Point_);
     }

//--- copy the newly appeared data into the UpFractal and DnFractal arrays
   if(display_MA4) //Show MA Level
     {
      if(CopyBuffer(MA4_Handle,0,MA4_Signal_Bar,2,MA)<=0) return(RESET);
      price=MA[1];
      if(MA[1]-MA[0]>0) LevelColor=Up_levels_color;
      else if(MA[1]-MA[0]<0) LevelColor=Dn_levels_color;
      else LevelColor=Fl_levels_color;
      priceT=price;
      text="";
      StringConcatenate(text,GetStringTimeframe(Timeframe4)," ",GetStringMAName(MA4_SMethod),MA4_Length);
      SetTline(0,level4_name,0,time1,price,time2,price,LevelColor,level4_style,level4_width,level_comment);
      CreateText(0,text4_name,0,timeT,priceT,text,LevelColor,"Georgia",TextSize,Point_);
     }
//--- copy the newly appeared data into the UpFractal and DnFractal arrays
   if(display_MA5) //Show MA Level
     {
      if(CopyBuffer(MA5_Handle,0,MA5_Signal_Bar,2,MA)<=0) return(RESET);
      price=MA[1];
      if(MA[1]-MA[0]>0) LevelColor=Up_levels_color;
      else if(MA[1]-MA[0]<0) LevelColor=Dn_levels_color;
      else LevelColor=Fl_levels_color;
      priceT=price;
      text="";
      StringConcatenate(text,GetStringTimeframe(Timeframe5)," ",GetStringMAName(MA5_SMethod),MA5_Length);
      SetTline(0,level5_name,0,time1,price,time2,price,LevelColor,level5_style,level5_width,level_comment);
      CreateText(0,text5_name,0,timeT,priceT,text,LevelColor,"Georgia",TextSize,Point_);
     }
//--- copy the newly appeared data into the UpFractal and DnFractal arrays
   if(display_MA6) //Show MA Level
     {
      if(CopyBuffer(MA6_Handle,0,MA6_Signal_Bar,2,MA)<=0) return(RESET);
      price=MA[1];
      if(MA[1]-MA[0]>0) LevelColor=Up_levels_color;
      else if(MA[1]-MA[0]<0) LevelColor=Dn_levels_color;
      else LevelColor=Fl_levels_color;
      priceT=price;
      text="";
      StringConcatenate(text,GetStringTimeframe(Timeframe6)," ",GetStringMAName(MA6_SMethod),MA6_Length);
      SetTline(0,level6_name,0,time1,price,time2,price,LevelColor,level6_style,level6_width,level_comment);
      CreateText(0,text6_name,0,timeT,priceT,text,LevelColor,"Georgia",TextSize,Point_);
     }
//---
   return(rates_total);
  }
//+------------------------------------------------------------------+
