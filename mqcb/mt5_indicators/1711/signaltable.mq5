//+------------------------------------------------------------------+
//|                                                  SignalTable.mq5 |
//|                                   Copyright © 2007, Antonuk Oleg |
//|                                            antonukoleg@gmail.com | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Antonuk Oleg"
#property link      "antonukoleg@gmail.com"
#property version   "1.00"
#property description "Buy and sell signals а several indicators and different timeframes in a table"

//---- The indicator version
#property version   "1.00"
//---- The indicator drawn in the main window
#property indicator_chart_window
//---- No buffers used for the calculation and drawing of the indicator
#property indicator_buffers 0
//---- 0 graphical constructions used
#property indicator_plots   0
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0 // A constant for returning indicator recalculation commands to the terminal
//+----------------------------------------------+
// Description of the type_font enumeration      |
// Description of the CFontName class            | 
//+----------------------------------------------+ 
#include <GetFontName.mqh>
//+----------------------------------------------+
//| Input parameters of the indicator                 |
//+----------------------------------------------+
input string Symbol_="";                              // Financial symbol
input color  TextColor=clrGray;                       // Text color
input color  UpColor=clrTeal;                         // The color of an upward trend
input color  MdColor=clrGray;                         // The color of no trend
input color  DnColor=clrMagenta;                      // The color of a downward trend
input int    FontSize=13;                             // Font size
input type_font FontType=Font14;                      // Font type
input ENUM_BASE_CORNER  WhatCorner=CORNER_LEFT_LOWER; // The corner to position
input uint Y_=20;                                     // Vertical positioning
input uint X_=5;                                      // Horizontal positioning
input string LableSirname="SignalTable 1";
//+----------------------------------------------+
//---- Declaring integer variables of data calculation start
int min_rates_total;
double Width;
ENUM_ANCHOR_POINT SPoint;
string sFontType,Lable1,Lable2,Lable3,Lable4,Lable1_[9],Lable2_[9],Lable3_[9],Lable4_[9],symbol;
uint shift_1,shift_2,shift_3,shift_4,X1,X2,X2i[9];
ENUM_TIMEFRAMES period[]={PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
//---- Create one more array with the indicator names
string signalNameString[]={"MA","WPR","SAR"};
//---- Declaring integer variables or the indicator handles
int FsMA_Handle[9],SlMA_Handle[9],WPR_Handle[9],SAR_Handle[9];
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=1;

//---- initialization of variables 
   if(Symbol_!="") symbol=Symbol_;
   else symbol=Symbol();
   Width=3.3; //Width between the symbols
   SPoint=ENUM_ANCHOR_POINT(2*WhatCorner);

//---- Getting handles
   for(int iii=0; iii<9; iii++)
     {      
      //---- Getting the handle of the iMA indicator
      FsMA_Handle[iii]=iMA(symbol,period[iii],13,0,MODE_SMA,PRICE_CLOSE);
      if(FsMA_Handle[iii]==INVALID_HANDLE) Print(" Failed to get the handle of iMA");

      //---- Getting the handle of the iMA indicator
      SlMA_Handle[iii]=iMA(symbol,period[iii],24,0,MODE_SMA,PRICE_CLOSE);
      if(SlMA_Handle[iii]==INVALID_HANDLE) Print(" Failed to get the handle of iMA");

      //---- getting handle of the iWPR indicator
      WPR_Handle[iii]=iWPR(symbol,period[iii],13);
      if(WPR_Handle[iii]==INVALID_HANDLE) Print(" Failed to get the handle of iWPR");

      //---- getting handle of the iSAR indicator
      SAR_Handle[iii]=iSAR(symbol,period[iii],0.02,0.2);
      if(SAR_Handle[iii]==INVALID_HANDLE) Print(" Failed to get the handle of iSAR");
     }

//----
   CFontName FONT;
   sFontType=FONT.GetFontName(FontType);
   Deinit();
//---- 
   Lable1=LableSirname+"_"+"String_0";
   Lable2=LableSirname+"_"+"String_1";
   Lable3=LableSirname+"_"+"String_2";
   Lable4=LableSirname+"_"+"String_3";

   for(int iii=0; iii<9; iii++)
     {
      Lable1_[iii]=LableSirname+"_"+"String_0_"+string(iii);
      Lable2_[iii]=LableSirname+"_"+"String_1_"+string(iii);
      Lable3_[iii]=LableSirname+"_"+"String_2_"+string(iii);
      Lable4_[iii]=LableSirname+"_"+"String_3_"+string(iii);
     }

//----
   switch(WhatCorner)
     {
      case CORNER_RIGHT_LOWER:
        {
         shift_1=int(Y_+FontSize*6);
         shift_2=int(Y_+FontSize*4);
         shift_3=int(Y_+FontSize*2);
         shift_4=int(Y_+0);
         X1=int(X_+FontSize*3);
         X2=int(X_);
         break;
        }

      case CORNER_LEFT_LOWER:
        {
         shift_1=int(Y_+FontSize*6);
         shift_2=int(Y_+FontSize*4);
         shift_3=int(Y_+FontSize*2);
         shift_4=int(Y_+0);
         X1=int(X_);
         X2=X_+FontSize*5;
         break;
        }

      case CORNER_RIGHT_UPPER:
        {
         shift_1=int(Y_+0);
         shift_2=int(Y_+FontSize*2);
         shift_3=int(Y_+FontSize*4);
         shift_4=int(Y_+FontSize*6);
         X1=int(X_+FontSize*3);
         X2=int(X_);
         break;
        }

      case CORNER_LEFT_UPPER:
        {
         shift_1=int(Y_+0);
         shift_2=int(Y_+FontSize*2);
         shift_3=int(Y_+FontSize*4);
         shift_4=int(Y_+FontSize*6);
         X1=int(X_);
         X2=int(X_+FontSize*5);
        }
     }

   SetTLabel(0,Lable1,0,WhatCorner,SPoint,X1,shift_1,"Sar: ",TextColor,sFontType,FontSize);
   SetTLabel(0,Lable2,0,WhatCorner,SPoint,X1,shift_2,"WPR: ",TextColor,sFontType,FontSize);
   SetTLabel(0,Lable3,0,WhatCorner,SPoint,X1,shift_3,"MA: ",TextColor,sFontType,FontSize);
   
   for(int iii=0; iii<9; iii++) X2i[iii]=X2+int(Width*iii*FontSize);

   for(int iii=0; iii<9; iii++)
      SetTLabel(0,Lable4_[iii],0,WhatCorner,SPoint,X2i[iii],shift_4,GetStringTimeframe(period[iii]),TextColor,sFontType,FontSize);
//---- End of initialization
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   Deinit();
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//|  Variable arrays fro creating indicator values                   |
//+------------------------------------------------------------------+  
class CArray
  {
public: double    IndArr[];
  };
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
  //---- Check if the number of bars is enough for the calculation
   for(int iii=0; iii<9; iii++)
      if(BarsCalculated(FsMA_Handle[iii])<min_rates_total
         || BarsCalculated(SlMA_Handle[iii])<min_rates_total
         || BarsCalculated(WPR_Handle[iii])<min_rates_total
         || BarsCalculated(SAR_Handle[iii])<min_rates_total)
         return(RESET);

//----
   CArray FsMA[9],SlMA[9],WPR[9],SAR[9];
   string Symb;
   color Color;

//---- copy newly appeared data into the arrays
   for(int iii=0; iii<9; iii++)
     {
      if(CopyBuffer(WPR_Handle[iii],0,0,1,WPR[iii].IndArr)<=0) return(RESET);
      if(CopyBuffer(SAR_Handle[iii],0,0,1,SAR[iii].IndArr)<=0) return(RESET);
      if(CopyBuffer(FsMA_Handle[iii],0,0,1,FsMA[iii].IndArr)<=0) return(RESET);
      if(CopyBuffer(SlMA_Handle[iii],0,0,1,SlMA[iii].IndArr)<=0) return(RESET);
     }
//---- 
   for(int iii=0; iii<9; iii++)
     {
      if(SAR[iii].IndArr[0]<close[rates_total-1])
        {
         Symb="г";
         Color=UpColor;
        }
      else if(SAR[iii].IndArr[0]>close[rates_total-1])
        {
         Symb="д";
         Color=DnColor;
        }
      else
        {
         Symb="a";
         Color=MdColor;
        }

      SetTLabel(0,Lable1_[iii],0,WhatCorner,SPoint,X2i[iii],shift_1,Symb,Color,"Wingdings 3",FontSize);
     }
//----
   for(int iii=0; iii<9; iii++)
     {
      if(WPR[iii].IndArr[0]<20)
        {
         Symb="г";
         Color=UpColor;
        }
      else if(WPR[iii].IndArr[0]>80)
        {
         Symb="д";
         Color=DnColor;
        }
      else
        {
         Symb="a";
         Color=MdColor;
        }

      SetTLabel(0,Lable2_[iii],0,WhatCorner,SPoint,X2i[iii],shift_2,Symb,Color,"Wingdings 3",FontSize);
     }
//----
   for(int iii=0; iii<9; iii++)
     {
      if(FsMA[iii].IndArr[0]>SlMA[iii].IndArr[0])
        {
         Symb="г";
         Color=UpColor;
        }
      else if(FsMA[iii].IndArr[0]<SlMA[iii].IndArr[0])
        {
         Symb="д";
         Color=DnColor;
        }
      else
        {
         Symb="a";
         Color=MdColor;
        }

      SetTLabel(0,Lable3_[iii],0,WhatCorner,SPoint,X2i[iii],shift_3,Symb,Color,"Wingdings 3",FontSize);
     }
//----  
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void Deinit()
  {
//----
   ObjectDelete(0,Lable1);
   ObjectDelete(0,Lable2);
   ObjectDelete(0,Lable3);
   ObjectDelete(0,Lable4);

   for(int iii=0; iii<9; iii++)
     {
      ObjectDelete(0,Lable1_[iii]);
      ObjectDelete(0,Lable2_[iii]);
      ObjectDelete(0,Lable3_[iii]);
      ObjectDelete(0,Lable4_[iii]);
     }
//----
  }
//+------------------------------------------------------------------+
//|  Getting a string timeframe                                      |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//----
   return(StringSubstr(EnumToString(timeframe),7,-1));
//----
  }
//+------------------------------------------------------------------+
//|  Creating a text label                                           |
//+------------------------------------------------------------------+
void CreateTLabel
(
 long   chart_id,         // Chart ID
 string name,             // Object name
 int    nwin,             // window index
 ENUM_BASE_CORNER corner,// base corner location
 ENUM_ANCHOR_POINT point, // anchor point location
 int    X,                // the distance from the base corner along the X-axis in pixels
 int    Y,                // the distance from the base corner along the Y-axis in pixels
 string text,             // text
 color  Color,            // text color
 string Font,             // text font
 int    Size              // font size
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(chart_id,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(chart_id,name,OBJPROP_ANCHOR,point);
   ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
   ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
   ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//----
  }
//+------------------------------------------------------------------+
//|  Resetting text label                                            |
//+------------------------------------------------------------------+
void SetTLabel
(
 long   chart_id,         // Chart ID
 string name,             // Object name
 int    nwin,             // window index
 ENUM_BASE_CORNER corner,// base corner location
 ENUM_ANCHOR_POINT point, // anchor point location
 int    X,                // the distance from the base corner along the X-axis in pixels
 int    Y,                // the distance from the base corner along the Y-axis in pixels
 string text,             // text
 color  Color,            // text color
 string Font,             // text font
 int    Size              // font size
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateTLabel(chart_id,name,nwin,corner,point,X,Y,text,Color,Font,Size);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
      ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
      ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
      ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
     }
//----
  }
//+------------------------------------------------------------------+
