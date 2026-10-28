//+------------------------------------------------------------------+
//|                                             MultiSignals_PCH.mq5 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2012, tol64."
#property link        "https://www.mql5.com/ru/users/tol64"
#property description "email: hello.tol64@gmail.com"
#property version     "1.00"
#property icon        "\\Images\\logoMultiSignals_PCH_64x64.ico"
//--- properties
#property indicator_chart_window
//---
#property indicator_buffers 29
#property indicator_plots   29
//-- levels
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
//--- Take Profit/Stop Loss signals
#property indicator_type6   DRAW_ARROW
#property indicator_type7   DRAW_ARROW
#property indicator_type8   DRAW_ARROW
#property indicator_type9   DRAW_ARROW
#property indicator_type10  DRAW_ARROW
#property indicator_type11  DRAW_ARROW
#property indicator_type12  DRAW_ARROW
#property indicator_type13  DRAW_ARROW
#property indicator_type14  DRAW_ARROW
#property indicator_type15  DRAW_ARROW
#property indicator_type16  DRAW_ARROW
#property indicator_type17  DRAW_ARROW
#property indicator_type18  DRAW_ARROW
#property indicator_type19  DRAW_ARROW
#property indicator_type20  DRAW_ARROW
#property indicator_type21  DRAW_ARROW
#property indicator_type22  DRAW_ARROW
#property indicator_type23  DRAW_ARROW
#property indicator_type24  DRAW_ARROW
#property indicator_type25  DRAW_ARROW
#property indicator_type26  DRAW_ARROW
#property indicator_type27  DRAW_ARROW
#property indicator_type28  DRAW_ARROW
#property indicator_type29  DRAW_ARROW
//--- styles
#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_DOT
#property indicator_style4 STYLE_DOT
#property indicator_style5 STYLE_DOT
//--- colors of main levels
#property indicator_color1 clrGold        // H
#property indicator_color2 clrGreenYellow // L
#property indicator_color3 clrSilver
#property indicator_color4 clrSilver
#property indicator_color5 clrSilver
//--- Take Proft/Stop Loss signals
//---------------------------------------------------------------
// MH sell - ML buy
#property indicator_color6 clrMaroon  // signal sell MH
#property indicator_color7 clrBlue    // signal buy ML
//---
#property indicator_color8 clrMaroon  // TP sell MH
#property indicator_color9 clrBlue    // TP buy ML
//---
#property indicator_color10 clrMaroon // SL sell MH
#property indicator_color11 clrBlue   // SL buy ML
//---------------------------------------------------------------
// M sell - M buy
#property indicator_color12 clrBrown      // signal sell M
#property indicator_color13 clrRoyalBlue  // signal buy M
//---
#property indicator_color14 clrBrown      // TP sell M
#property indicator_color15 clrRoyalBlue  // TP buy M
//---
#property indicator_color16 clrBrown      // SL sell M
#property indicator_color17 clrRoyalBlue  // SL buy M
//---------------------------------------------------------------
// ML sell - MH buy
#property indicator_color18 clrRed             // signal sell ML
#property indicator_color19 clrCornflowerBlue  // signal buy MH
//---
#property indicator_color20 clrRed             // TP sell ML
#property indicator_color21 clrCornflowerBlue  // TP buy MH
//---
#property indicator_color22 clrRed             // SL sell ML
#property indicator_color23 clrCornflowerBlue  // SL buy MH
//---------------------------------------------------------------
// L sell - H buy
#property indicator_color24 clrOrange  // signal sell L
#property indicator_color25 clrAqua    // signal buy H
//---
#property indicator_color26 clrOrange  // TP sell L
#property indicator_color27 clrAqua    // TP buy H
//---
#property indicator_color28 clrOrange  // SL sell L
#property indicator_color29 clrAqua    // SL buy H

//---------------------------------------------------------------
#property indicator_label1  "Channel upper"
#property indicator_label2  "Channel lower"
#property indicator_label3  "Channel median"
#property indicator_label4  "Channel UPmedian"
#property indicator_label5  "Channel DWmedian"
//---
#define szArr 29
//--- input parameters
input int  Period_PCH=10;      // Period
//---
input bool MLMH_signal=true;   // ML/MH_PCH signals
input bool M_signal=false;     // M_PCH signals
input bool MHML_signal=false;  // MH/ML_PCH signals
input bool HL_signal=false;    // H/L_PCH signals
//---
input int  TP_MLMH=100;        // Take Profit MLMH
input int  TP_M=100;           // Take Profit M
input int  TP_MHML=100;        // Take Profit MHML
input int  TP_HL=100;          // Take Profit HL
//---
input int  SL_MLMH=50;         // Stop Loss MLMH
input int  SL_M=50;            // Stop Loss M
input int  SL_MHML=50;         // Stop Loss MHML
input int  SL_HL=50;           // Stop Loss HL
//---
int j=0;
//int type=-1; // Type Draw
//---
int tp_MLMH=0,tp_M=0,tp_MHML=0,tp_HL=0;
int sl_MLMH=0,sl_M=0,sl_MHML=0,sl_HL=0;
//---
double High_Buffer[],Low_Buffer[],Mid_Buffer[],High_Mid_Buffer[],Low_Mid_Buffer[]; // Buffers of Lines
//---
double sCross_MH_Buffer[],sCross_M_Buffer[],sCross_ML_Buffer[],sCross_L_Buffer[]; // Sell
double bCross_ML_Buffer[],bCross_M_Buffer[],bCross_MH_Buffer[],bCross_H_Buffer[]; // Buy
//---
double sTP_MH_Buffer[],sTP_M_Buffer[],sTP_ML_Buffer[],sTP_L_Buffer[]; // Take Profit Sell
double bTP_ML_Buffer[],bTP_M_Buffer[],bTP_MH_Buffer[],bTP_H_Buffer[]; // Take Profit Buy
//---
double sSL_MH_Buffer[],sSL_M_Buffer[],sSL_ML_Buffer[],sSL_L_Buffer[]; // Stop Loss Sell
double bSL_ML_Buffer[],bSL_M_Buffer[],bSL_MH_Buffer[],bSL_H_Buffer[]; // Stop Loss Buy
//---
int ArrayPlotShift[szArr],ArrayPlotDrawBegin[szArr],ArrayPlotEmptyValue[szArr],ArrayPlotLineWidth[szArr];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,High_Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,Low_Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,Mid_Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,High_Mid_Buffer,INDICATOR_DATA);
   SetIndexBuffer(4,Low_Mid_Buffer,INDICATOR_DATA);
//-----------------------------------------------------------------------
// MH sell - ML buy
   SetIndexBuffer(5,sCross_MH_Buffer,INDICATOR_DATA); // Signals Sell MH
   SetIndexBuffer(6,bCross_ML_Buffer,INDICATOR_DATA); // Signals Buy ML
//---
   SetIndexBuffer(7,sTP_MH_Buffer,INDICATOR_DATA); // TP Sell MH
   SetIndexBuffer(8,bTP_ML_Buffer,INDICATOR_DATA); // TP Buy ML
//---
   SetIndexBuffer(9,sSL_MH_Buffer,INDICATOR_DATA); // SL Sell MH
   SetIndexBuffer(10,bSL_ML_Buffer,INDICATOR_DATA); // SL Buy ML
//-----------------------------------------------------------------------
// M sell - M buy
   SetIndexBuffer(11,sCross_M_Buffer,INDICATOR_DATA); // Signals Sell M
   SetIndexBuffer(12,bCross_M_Buffer,INDICATOR_DATA); // Signals Buy M
//---
   SetIndexBuffer(13,sTP_M_Buffer,INDICATOR_DATA); // TP Sell M
   SetIndexBuffer(14,bTP_M_Buffer,INDICATOR_DATA); // TP Buy M
//---
   SetIndexBuffer(15,sSL_M_Buffer,INDICATOR_DATA); // SL Sell M
   SetIndexBuffer(16,bSL_M_Buffer,INDICATOR_DATA); // SL Buy M
//-----------------------------------------------------------------------
// ML sell - MH buy
   SetIndexBuffer(17,sCross_ML_Buffer,INDICATOR_DATA); // Signals Sell ML
   SetIndexBuffer(18,bCross_MH_Buffer,INDICATOR_DATA); // Signals Buy MH
//---
   SetIndexBuffer(19,sTP_ML_Buffer,INDICATOR_DATA); // TP Sell ML
   SetIndexBuffer(20,bTP_MH_Buffer,INDICATOR_DATA); // TP Buy MH
//---
   SetIndexBuffer(21,sSL_ML_Buffer,INDICATOR_DATA); // SL Sell ML
   SetIndexBuffer(22,bSL_MH_Buffer,INDICATOR_DATA); // SL Buy MH
//-----------------------------------------------------------------------
// L sell - H buy
   SetIndexBuffer(23,sCross_L_Buffer,INDICATOR_DATA); // Signals Sell L
   SetIndexBuffer(24,bCross_H_Buffer,INDICATOR_DATA); // Signals Buy H
//---
   SetIndexBuffer(25,sTP_L_Buffer,INDICATOR_DATA); // TP Sell L
   SetIndexBuffer(26,bTP_H_Buffer,INDICATOR_DATA); // TP Buy H
//---
   SetIndexBuffer(27,sSL_L_Buffer,INDICATOR_DATA); // SL Sell L
   SetIndexBuffer(28,bSL_H_Buffer,INDICATOR_DATA); // SL Buy H

//--- precision
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits-1);

//--- plot draw begin
   for(j=0; j<szArr; j++) { PlotIndexSetInteger(j,PLOT_DRAW_BEGIN,Period_PCH); }

//--- horizontal shift
   for(j=0; j<szArr; j++) { PlotIndexSetInteger(j,PLOT_SHIFT,1); }

//--- line width
   for(j=0; j<szArr; j++) { PlotIndexSetInteger(j,PLOT_LINE_WIDTH,1); }

//--- vertical shift
   PlotIndexSetInteger(5,PLOT_ARROW_SHIFT,-40);  // MH
   PlotIndexSetInteger(6,PLOT_ARROW_SHIFT,40);   // ML
//---   
   PlotIndexSetInteger(11,PLOT_ARROW_SHIFT,-30); // M
   PlotIndexSetInteger(12,PLOT_ARROW_SHIFT,30);  // M
//---
   PlotIndexSetInteger(17,PLOT_ARROW_SHIFT,-20); // ML
   PlotIndexSetInteger(18,PLOT_ARROW_SHIFT,20);  // MH
//---
   PlotIndexSetInteger(23,PLOT_ARROW_SHIFT,-10); // L
   PlotIndexSetInteger(24,PLOT_ARROW_SHIFT,10);  // H

//--- name for DataWindow and indicator label
   IndicatorSetString(INDICATOR_SHORTNAME,"MultiSignals_PCH ("+string(Period_PCH)+")");
//---
   PlotIndexSetString(0,PLOT_LABEL,"H_PCH");
   PlotIndexSetString(1,PLOT_LABEL,"L_PCH");
   PlotIndexSetString(2,PLOT_LABEL,"M_PCH");
   PlotIndexSetString(3,PLOT_LABEL,"MH_PCH");
   PlotIndexSetString(4,PLOT_LABEL,"ML_PCH");
//---
   PlotIndexSetString(5,PLOT_LABEL,"sell Cross MH");
   PlotIndexSetString(6,PLOT_LABEL,"buy Cross ML");
//---
   PlotIndexSetString(7,PLOT_LABEL,"sell TP MH");
   PlotIndexSetString(8,PLOT_LABEL,"buy TP ML");
//---
   PlotIndexSetString(9,PLOT_LABEL,"sell SL MH");
   PlotIndexSetString(10,PLOT_LABEL,"buy SL ML");
//---
   PlotIndexSetString(11,PLOT_LABEL,"sell Cross M");
   PlotIndexSetString(12,PLOT_LABEL,"buy Cross M");
//---
   PlotIndexSetString(13,PLOT_LABEL,"sell TP M");
   PlotIndexSetString(14,PLOT_LABEL,"buy TP M");
//---
   PlotIndexSetString(15,PLOT_LABEL,"sell SL M");
   PlotIndexSetString(16,PLOT_LABEL,"buy SL M");
//---
   PlotIndexSetString(17,PLOT_LABEL,"sell Cross ML");
   PlotIndexSetString(18,PLOT_LABEL,"buy Cross MH");
//---
   PlotIndexSetString(19,PLOT_LABEL,"sell TP ML");
   PlotIndexSetString(20,PLOT_LABEL,"buy TP MH");
//---
   PlotIndexSetString(21,PLOT_LABEL,"sell SL ML");
   PlotIndexSetString(22,PLOT_LABEL,"buy SL MH");
//---
   PlotIndexSetString(23,PLOT_LABEL,"sell Cross L");
   PlotIndexSetString(24,PLOT_LABEL,"buy Cross H");
//---
   PlotIndexSetString(25,PLOT_LABEL,"sell TP L");
   PlotIndexSetString(26,PLOT_LABEL,"buy TP H");
//---
   PlotIndexSetString(27,PLOT_LABEL,"sell SL L");
   PlotIndexSetString(28,PLOT_LABEL,"buy SL H");

//--- used for signals
   PlotIndexSetInteger(5,PLOT_ARROW,159);
   PlotIndexSetInteger(6,PLOT_ARROW,159);

//--- used for Take Profit levels
   PlotIndexSetInteger(7,PLOT_ARROW,167);
   PlotIndexSetInteger(8,PLOT_ARROW,167);

//--- used for Stop Loss levels
   PlotIndexSetInteger(9,PLOT_ARROW,6);
   PlotIndexSetInteger(10,PLOT_ARROW,6);

//--- used for signals
   PlotIndexSetInteger(11,PLOT_ARROW,159);
   PlotIndexSetInteger(12,PLOT_ARROW,159);

//--- used for Take Profit levels
   PlotIndexSetInteger(13,PLOT_ARROW,167);
   PlotIndexSetInteger(14,PLOT_ARROW,167);

//--- Stop Loss
   PlotIndexSetInteger(15,PLOT_ARROW,6);
   PlotIndexSetInteger(16,PLOT_ARROW,6);

//--- signals
   PlotIndexSetInteger(17,PLOT_ARROW,159);
   PlotIndexSetInteger(18,PLOT_ARROW,159);

//--- Take Profit
   PlotIndexSetInteger(19,PLOT_ARROW,167);
   PlotIndexSetInteger(20,PLOT_ARROW,167);

//--- Stop Loss
   PlotIndexSetInteger(21,PLOT_ARROW,6);
   PlotIndexSetInteger(22,PLOT_ARROW,6);

//--- signals
   PlotIndexSetInteger(23,PLOT_ARROW,159);
   PlotIndexSetInteger(24,PLOT_ARROW,159);

//--- ake Profit
   PlotIndexSetInteger(25,PLOT_ARROW,167);
   PlotIndexSetInteger(26,PLOT_ARROW,167);

//--- Stop Loss
   PlotIndexSetInteger(27,PLOT_ARROW,6);
   PlotIndexSetInteger(28,PLOT_ARROW,6);

//--- remove empty values
   for(j=0; j<szArr; j++) { PlotIndexSetDouble(j,PLOT_EMPTY_VALUE,EMPTY_VALUE); }
  }
//+------------------------------------------------------------------+
//| Price Channel                                                    |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
   int i=0,limit=0;

//--- check for rates
   if(rates_total<Period_PCH) { return(0); }

//--- preliminary calculations
   if(prev_calculated==0) { limit=Period_PCH; } else { limit=prev_calculated-1; }

//--- the main loop of calculations
   for(i=limit; i<rates_total; i++)
     {
      //+------------------------------------------------------------------+
      //| INDICATORS_BUFFERS                                               |
      //+------------------------------------------------------------------+
      High_Buffer[i]=Highest(High,Period_PCH,i);
      Low_Buffer[i]=Lowest(Low,Period_PCH,i);
      Mid_Buffer[i]=(High_Buffer[i]+Low_Buffer[i])/2.0;
      //---
      High_Mid_Buffer[i]=(Mid_Buffer[i]+High_Buffer[i])/2.0;
      Low_Mid_Buffer[i]=(Low_Buffer[i]+Mid_Buffer[i])/2.0;

      //+------------------------------------------------------------------+
      //| SIGNALS_TAKEPROFIT_STOPLOSS                                      |
      //+------------------------------------------------------------------+
      //| MH cross down - ML cross up                                      |
      //+------------------------------------------------------------------+
      if(MLMH_signal)
        {
         //+------------------------------------------------------------------+
         //| SELL                                                             |
         //| Open>MH and Close<MH                                             |
         //+------------------------------------------------------------------+
         if(Open[i]>=High_Mid_Buffer[i-1] && Close[i]<High_Mid_Buffer[i-1])
           {
            sCross_MH_Buffer[i]=High_Buffer[i]; // draw signal
            if(TP_MLMH>0) { sTP_MH_Buffer[i]=Close[i]-vDgtMlt(TP_MLMH)*_Point; } else { sTP_MH_Buffer[i]=EMPTY_VALUE; } // draw Take Profit
            if(SL_MLMH>0) { sSL_MH_Buffer[i]=Close[i]+vDgtMlt(SL_MLMH)*_Point; } else { sSL_MH_Buffer[i]=EMPTY_VALUE; } // draw Stop Loss
           }
         else
           {
            sCross_MH_Buffer[i]=EMPTY_VALUE; sTP_MH_Buffer[i]=EMPTY_VALUE; sSL_MH_Buffer[i]=EMPTY_VALUE; // disable sMH
           }

         //+------------------------------------------------------------------+
         //| BUY                                                              |
         //| Open<ML and Close>ML                                             |
         //+------------------------------------------------------------------+
         if(Open[i]<=Low_Mid_Buffer[i-1] && Close[i]>Low_Mid_Buffer[i-1])
           {
            bCross_ML_Buffer[i]=Low_Buffer[i]; // draw signal
            if(TP_MLMH>0) { bTP_ML_Buffer[i]=Close[i]+vDgtMlt(TP_MLMH)*_Point; } else { bTP_ML_Buffer[i]=EMPTY_VALUE; } // draw Take Profit
            if(SL_MLMH>0) { bSL_ML_Buffer[i]=Close[i]-vDgtMlt(SL_MLMH)*_Point; } else { bSL_ML_Buffer[i]=EMPTY_VALUE; } // draw Stop Loss
           }
         else
           {
            bCross_ML_Buffer[i]=EMPTY_VALUE; bTP_ML_Buffer[i]=EMPTY_VALUE; bSL_ML_Buffer[i]=EMPTY_VALUE; // disable bML
           }
        }
      else if(!MLMH_signal)
        {
         // Disable sMH and bML
         sCross_MH_Buffer[i]=EMPTY_VALUE; bCross_ML_Buffer[i]=EMPTY_VALUE;
         sTP_MH_Buffer[i]=EMPTY_VALUE; bTP_ML_Buffer[i]=EMPTY_VALUE;
         sSL_MH_Buffer[i]=EMPTY_VALUE; bSL_ML_Buffer[i]=EMPTY_VALUE;
        }

      //+------------------------------------------------------------------+
      //| M cross down - M cross up                                        |
      //+------------------------------------------------------------------+
      if(M_signal)
        {
         //+------------------------------------------------------------------+
         //| SELL                                                             |
         //| Open>M and Close<M                                               |
         //+------------------------------------------------------------------+         
         if(Open[i]>=Mid_Buffer[i-1] && Close[i]<Mid_Buffer[i-1])
           {
            sCross_M_Buffer[i]=High_Buffer[i]; // draw signal
            if(TP_M>0) { sTP_M_Buffer[i]=Close[i]-vDgtMlt(TP_M)*_Point; } else { sTP_M_Buffer[i]=EMPTY_VALUE; } // draw Take Profit
            if(SL_M>0) { sSL_M_Buffer[i]=Close[i]+vDgtMlt(SL_M)*_Point; } else { sSL_M_Buffer[i]=EMPTY_VALUE; } // draw Stop Loss
           }
         else { sCross_M_Buffer[i]=EMPTY_VALUE; sTP_M_Buffer[i]=EMPTY_VALUE; sSL_M_Buffer[i]=EMPTY_VALUE; }

         //+------------------------------------------------------------------+
         //| BUY                                                              |
         //| Open<M and Close>M                                               |
         //+------------------------------------------------------------------+ 
         if(Open[i]<=Mid_Buffer[i-1] && Close[i]>Mid_Buffer[i-1])
           {
            bCross_M_Buffer[i]=Low_Buffer[i]; // draw signal
            if(TP_M>0) { bTP_M_Buffer[i]=Close[i]+vDgtMlt(TP_M)*_Point; } else { bTP_M_Buffer[i]=EMPTY_VALUE; } // draw Take Profit
            if(SL_M>0) { bSL_M_Buffer[i]=Close[i]-vDgtMlt(SL_M)*_Point; } else { bSL_M_Buffer[i]=EMPTY_VALUE; } // draw Stop Loss
           }
         else { bCross_M_Buffer[i]=EMPTY_VALUE; bTP_M_Buffer[i]=EMPTY_VALUE; bSL_M_Buffer[i]=EMPTY_VALUE; }
        }
      else if(!M_signal)
        {
         bCross_M_Buffer[i]=EMPTY_VALUE; bTP_M_Buffer[i]=EMPTY_VALUE; bSL_M_Buffer[i]=EMPTY_VALUE;
         sCross_M_Buffer[i]=EMPTY_VALUE; sTP_M_Buffer[i]=EMPTY_VALUE; sSL_M_Buffer[i]=EMPTY_VALUE;
        }

      //+------------------------------------------------------------------+
      //| ML cross down - MH cross up                                      |
      //+------------------------------------------------------------------+
      if(MHML_signal)
        {
         //+------------------------------------------------------------------+
         //| SELL                                                             |
         //| Open>ML and Close<ML                                             |
         //+------------------------------------------------------------------+ 
         if(Open[i]>=Low_Mid_Buffer[i-1] && Close[i]<Low_Mid_Buffer[i-1])
           {
            sCross_ML_Buffer[i]=High_Buffer[i]; // draw signal
            if(TP_MHML>0) { sTP_ML_Buffer[i]=Close[i]-vDgtMlt(TP_MHML)*_Point; } else { sTP_ML_Buffer[i]=EMPTY_VALUE; } // draw Take Profit
            if(SL_MHML>0) { sSL_ML_Buffer[i]=Close[i]+vDgtMlt(SL_MHML)*_Point; } else { sSL_ML_Buffer[i]=EMPTY_VALUE; } // draw Stop Loss
           }
         else { sCross_ML_Buffer[i]=EMPTY_VALUE; sTP_ML_Buffer[i]=EMPTY_VALUE; sSL_ML_Buffer[i]=EMPTY_VALUE; }

         //+------------------------------------------------------------------+
         //| BUY                                                              |
         //| Open<MH and Close>MH                                             |
         //+------------------------------------------------------------------+
         if(Open[i]<=High_Mid_Buffer[i-1] && Close[i]>High_Mid_Buffer[i-1])
           {
            bCross_MH_Buffer[i]=Low_Buffer[i]; // draw signal
            if(TP_MHML>0) { bTP_MH_Buffer[i]=Close[i]+vDgtMlt(TP_MHML)*_Point; } else { bTP_MH_Buffer[i]=EMPTY_VALUE; } // draw Take Profit
            if(SL_MHML>0) { bSL_MH_Buffer[i]=Close[i]-vDgtMlt(SL_MHML)*_Point; } else { bSL_MH_Buffer[i]=EMPTY_VALUE; } // draw Stop Loss            
           }
         else { bCross_MH_Buffer[i]=EMPTY_VALUE; bTP_MH_Buffer[i]=EMPTY_VALUE; bSL_MH_Buffer[i]=EMPTY_VALUE; }
        }
      else if(!MHML_signal)
        {
         bCross_MH_Buffer[i]=EMPTY_VALUE; bTP_MH_Buffer[i]=EMPTY_VALUE; bSL_MH_Buffer[i]=EMPTY_VALUE;
         sCross_ML_Buffer[i]=EMPTY_VALUE; sTP_ML_Buffer[i]=EMPTY_VALUE; sSL_ML_Buffer[i]=EMPTY_VALUE;
        }

      //+------------------------------------------------------------------+
      //| L cross down - H cross up                                        |
      //+------------------------------------------------------------------+
      if(HL_signal)
        {
         //+------------------------------------------------------------------+
         //| SELL                                                             |
         //| Open>L and Close<L                                               |
         //+------------------------------------------------------------------+ 
         if(Open[i]>=Low_Buffer[i-1] && Close[i]<Low_Buffer[i-1])
           {
            sCross_L_Buffer[i]=High_Buffer[i];
            if(TP_HL>0) { sTP_L_Buffer[i]=Close[i]-vDgtMlt(TP_HL)*_Point; } else { sTP_L_Buffer[i]=EMPTY_VALUE; } // draw Take Profit
            if(SL_HL>0) { sSL_L_Buffer[i]=Close[i]+vDgtMlt(SL_HL)*_Point; } else { sSL_L_Buffer[i]=EMPTY_VALUE; } // draw Stop Loss
           }
         else { sCross_L_Buffer[i]=EMPTY_VALUE; sTP_L_Buffer[i]=EMPTY_VALUE; sSL_L_Buffer[i]=EMPTY_VALUE; }

         //+------------------------------------------------------------------+
         //| BUY                                                              |
         //| Open<H and Close>H                                               |
         //+------------------------------------------------------------------+
         if(Open[i]<=High_Buffer[i-1] && Close[i]>High_Buffer[i-1])
           {
            bCross_H_Buffer[i]=Low_Buffer[i];
            if(TP_HL>0) { bTP_H_Buffer[i]=Close[i]+vDgtMlt(TP_HL)*_Point; } else { bTP_H_Buffer[i]=EMPTY_VALUE; } // draw Take Profit
            if(SL_HL>0) { bSL_H_Buffer[i]=Close[i]-vDgtMlt(SL_HL)*_Point; } else { bSL_H_Buffer[i]=EMPTY_VALUE; } // draw Stop Loss
           }
         else { bCross_H_Buffer[i]=EMPTY_VALUE; bTP_H_Buffer[i]=EMPTY_VALUE; bSL_H_Buffer[i]=EMPTY_VALUE; }
        }
      else if(!HL_signal)
        {
         sCross_L_Buffer[i]=EMPTY_VALUE; sTP_L_Buffer[i]=EMPTY_VALUE; sSL_L_Buffer[i]=EMPTY_VALUE;
         bCross_H_Buffer[i]=EMPTY_VALUE; bTP_H_Buffer[i]=EMPTY_VALUE; bSL_H_Buffer[i]=EMPTY_VALUE;
        }
     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Get highest value for range                                      |
//+------------------------------------------------------------------+
double Highest(const double &array[],int range,int fromIndex)
  {
   int i=0;
   double res;
//---
   res=array[fromIndex];
//---
   for(i=fromIndex; i>fromIndex-range && i>=0; i--)
     {
      if(res<array[i]) res=array[i];
     }
//---
   return(res);
  }
//+------------------------------------------------------------------+
//| Get lowest value for range                                       |
//+------------------------------------------------------------------+
double Lowest(const double &array[],int range,int fromIndex)
  {
   int i=0;
   double res;
//---
   res=array[fromIndex];
//---
   for(i=fromIndex;i>fromIndex-range && i>=0;i--)
     {
      if(res>array[i]) res=array[i];
     }
//---
   return(res);
  }
//+------------------------------------------------------------------+
//| Recalculates the value according to 3/5 digit quotes             |
//+------------------------------------------------------------------+
int vDgtMlt(int value)
  {
   if(_Digits==3 || _Digits==5) { return(value*=10); } else { return(value); }
  }
//+------------------------------------------------------------------+
