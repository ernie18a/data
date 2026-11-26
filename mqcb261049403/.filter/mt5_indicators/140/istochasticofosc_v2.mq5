//+------------------------------------------------------------------+
//|                                             iStochasticOfOsc.mq5 |
//|                                        MetaQuotes Software Corp. |
//|                                                 http://dmffx.com |
//+------------------------------------------------------------------+

/*
   The Stochastic of all oscillator-like indicators, included in MetaTrader 5 client terminal.

   Parameters:
      Indicator - type of the indicator,
      Volume - volume type, 
      Period_1 - 1st period,
      Period_2 - 2nd period,
      Period_3 - 3rd period, 
      Price - applied price type, 
      Method - smoothing method, 
      Shift_1 - shift 1, 
      Shift_2 - shift 2,
      Shift_3 shift 3,
      Line - selected line of the indicator,
      StPeriod_K - Stochastic К period,
      StPeriod_D - Stochastic D period,
      StPeriod_S - Stochastic S period,
      StMethod - Smoothing method for the signal line.
      
   The parameters, used for each indicator:
      AD: Volume,
      ADX: Period_1,
      ADXW: Period_1,
      ATR: Period_1,
      BEARS: Period_1,
      BULLS: Period_1,
      BWMFI: Volume,
      CCI: Period_1, Price,
      CHAIKIN: Period_1 (Fast), Period_2 (Slow), Method, Volume,
      DEMARKER: Period_1,
      FORCE: Period_1, Method, Volume,
      GATOR: Period_1, Shift_1 (Jaw), Period_2, Shift_2 (Teeth), Period_3, Shift_3 (Lips), Method, Price,
      MACD: Period_1 (Fast), Period_2 (Slow), Period_3 (Signal), Price,
      MFI: Period_1, Volume,
      MOMENTUM: Period_1, Price,
      OBV: Volume,
      OSMA: Period_1 (Fast), Period_2 (Slow), Period_3 (Signal), Price,
      RSI: Period_1, Price,
      RVI: Period_1,
      STDDEV: Period_1, Method, Price,
      STOCHASTIC: Period_1 (K), Period_2 (D), Period_3 (S), Method, Price,
      TRIX: Period_1, Price,
      VOLUMES: Volume,
      WPR: Period_1.
      
   Note:
      The following values of the Line parameters should be used:
         
      STOCHASTIC and MACD: MAIN and SIGNAL.
      ADX and ADXW: ADX_ADX, ADX_PDI and ADX_MDI.
      GATOR: GATOR_UPPER_HISTOGRAM and GATOR_LOWER_HISTOGRAM.
      For other indicators: MAIN.
      
      Because of the fact, that some of the different Line identifiers have the same values,
      after the change of the Line value and opending the indicator properties window, you may see the different Line value.
      
      It's not an error, the other identifier can be plotted, but with the same value, as has been selected before.
      The different identifiers with same values are used for the convience.
      
      The same with the Price parameter - the CLOSECLOSE and LOWHIGH are added for the Stochastic,
      the standard values for the other indicators.
         
*/

#include <MovingAverages.mqh>

#property copyright "Integer"
#property link      "http://dmffx.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_minimum -3
#property indicator_maximum 103
#property indicator_level1 0
#property indicator_level2 100
#property indicator_level3 50
#property indicator_level4 20
#property indicator_level5 80

#property indicator_buffers 7
#property indicator_plots   2
//--- plot Main
#property indicator_label1  "Main"
#property indicator_type1   DRAW_LINE
#property indicator_color1  DodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  Red
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

enum eOscType
  {
   AC=IND_AC,
   AD=IND_AD,
   ADX=IND_ADX,
   ADXW=IND_ADXW,
   AO=IND_AO,
   ATR=IND_ATR,
   BEARS=IND_BEARS,
   BULLS=IND_BULLS,
   BWMFI=IND_BWMFI,
   CCI=IND_CCI,
   CHAIKIN=IND_CHAIKIN,
   DEMARKER=IND_DEMARKER,
   FORCE=IND_FORCE,
   GATOR=IND_GATOR,
   MACD=IND_MACD,
   MFI=IND_MFI,
   MOMENTUM=IND_MOMENTUM,
   OBV=IND_OBV,
   OSMA=IND_OSMA,
   RSI=IND_RSI,
   RVI=IND_RVI,
   STDDEV=IND_STDDEV,
   STOCHASTIC=IND_STOCHASTIC,
   TRIX=IND_TRIX,
   VOLUMES=IND_VOLUMES,
   WPR=IND_WPR
  };

enum ePrice
  {
   CLOSECLOSE=STO_CLOSECLOSE,
   LOWHIGH=STO_LOWHIGH,
   CLOSE=PRICE_CLOSE,
   HIGH=PRICE_HIGH,
   LOW=PRICE_LOW,
   MEDIAN=PRICE_MEDIAN,
   OPEN=PRICE_OPEN,
   TYPICAL=PRICE_TYPICAL,
   WEIGHTED=PRICE_WEIGHTED
  };

enum eInLine
  {
   GATOR_UPPER_HISTOGRAM=UPPER_HISTOGRAM,
   GATOR_LOWER_HISTOGRAM=LOWER_HISTOGRAM,
   ADX_ADX=MAIN_LINE,
   ADX_PDI=PLUSDI_LINE,
   ADX_MDI=MINUSDI_LINE,
   MAIN=MAIN_LINE,
   SIGNAL=SIGNAL_LINE
  };

//--- input parameters
input    eOscType             Indicator   =  RSI;
input    ENUM_APPLIED_VOLUME  Volume      =  VOLUME_TICK;
input    int                  Period_1    =  14;
input    int                  Period_2    =  10;
input    int                  Period_3    =  10;
input    ePrice               Price       =  CLOSE;
input    ENUM_MA_METHOD       Method      =  MODE_SMA;
input    int                  Shift_1     =  8;
input    int                  Shift_2     =  5;
input    int                  Shift_3     =  3;
input    eInLine              Line        =  MAIN;
input    int                  StPeriod_K  =  200;
input    int                  StPeriod_D  =  5;
input    int                  StPeriod_S  =  7;
input    ENUM_MA_METHOD       StMethod    =  MODE_SMA;

int HandleX;
int Handle;

//--- indicator buffers
double         MainBuffer[];
double         SignalBuffer[];
double         IndBuffer[];
double         HighestBuffer[];
double         LowestBuffer[];
double         SumVBuffer[];
double         SumRBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MainBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,SignalBuffer,INDICATOR_DATA);

   SetIndexBuffer(2,IndBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,HighestBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,LowestBuffer,INDICATOR_CALCULATIONS);

   SetIndexBuffer(5,SumVBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,SumRBuffer,INDICATOR_CALCULATIONS);


   switch(Indicator)
     {
      case AC:
         HandleX=iAC(_Symbol,PERIOD_CURRENT);
         break;
      case AD:
         HandleX=iAD(_Symbol,PERIOD_CURRENT,Volume);
         break;
      case ADX:
         HandleX=iADX(_Symbol,PERIOD_CURRENT,Period_1);
         break;
      case ADXW:
         HandleX=iADXWilder(_Symbol,PERIOD_CURRENT,Period_1);
         break;
      case AO:
         HandleX=iAO(_Symbol,PERIOD_CURRENT);
         break;
      case ATR:
         HandleX=iATR(_Symbol,PERIOD_CURRENT,Period_1);
         break;
      case BEARS:
         HandleX=iBearsPower(_Symbol,PERIOD_CURRENT,Period_1);
         break;
      case BULLS:
         HandleX=iBullsPower(_Symbol,PERIOD_CURRENT,Period_1);
         break;
      case BWMFI:
         HandleX=iBWMFI(_Symbol,PERIOD_CURRENT,Volume);
         break;
      case CCI:
         HandleX=iCCI(_Symbol,PERIOD_CURRENT,Period_1,Price);
         break;
      case CHAIKIN:
         HandleX=iChaikin(_Symbol,PERIOD_CURRENT,Period_1,Period_2,Method,Volume);
         break;
      case DEMARKER:
         HandleX=iDeMarker(_Symbol,PERIOD_CURRENT,Period_1);
         break;
      case FORCE:
         HandleX=iForce(_Symbol,PERIOD_CURRENT,Period_1,Method,Volume);
         break;
      case GATOR:
         HandleX=iGator(_Symbol,PERIOD_CURRENT,Period_1,Shift_1,Period_2,Shift_2,Period_3,Shift_3,Method,Price);
         break;
      case MACD:
         HandleX=iMACD(_Symbol,PERIOD_CURRENT,Period_1,Period_2,Period_3,Price);
         break;
      case MFI:
         HandleX=iMFI(_Symbol,PERIOD_CURRENT,Period_1,Volume);
         break;
      case MOMENTUM:
         HandleX=iMomentum(_Symbol,PERIOD_CURRENT,Period_1,Price);
         break;
      case OBV:
         HandleX=iOBV(_Symbol,PERIOD_CURRENT,Volume);
         break;
      case OSMA:
         HandleX=iOsMA(_Symbol,PERIOD_CURRENT,Period_1,Period_2,Period_3,Price);
         break;
      case RSI:
         HandleX=iRSI(_Symbol,PERIOD_CURRENT,Period_1,Price);
         break;
      case RVI:
         HandleX=iRVI(_Symbol,PERIOD_CURRENT,Period_1);
         break;
      case STDDEV:
         HandleX=iStdDev(_Symbol,PERIOD_CURRENT,Period_1,0,Method,Price);
         break;
      case STOCHASTIC:
         HandleX=iStochastic(_Symbol,PERIOD_CURRENT,Period_1,Period_2,Period_3,Method,(ENUM_STO_PRICE)Price);
         break;
      case TRIX:
         HandleX=iTriX(_Symbol,PERIOD_CURRENT,Period_1,Price);
         break;
      case VOLUMES:
         HandleX=iVolumes(_Symbol,PERIOD_CURRENT,Volume);
         break;
      case WPR:
         HandleX=iWPR(_Symbol,PERIOD_CURRENT,Period_1);
         break;
     }

   string Label;

   switch(Indicator)
     {
      case AC:
         Label="AC";
         break;
      case AD:
         Label="AD("+fNameVolume(Volume)+")";
         break;
      case ADX:
         Label="ADX-"+fNameADXLine(Line)+"("+ITS(Period_1)+")";
         break;
      case ADXW:
         Label="ADXW-"+fNameADXLine(Line)+"("+ITS(Period_1)+")";
         break;
      case AO:
         Label="AO";
         break;
      case ATR:
         Label="ATR("+ITS(Period_1)+")";
         break;
      case BEARS:
         Label="BEARS("+ITS(Period_1)+")";
         break;
      case BULLS:
         Label="BULLS("+ITS(Period_1)+")";
         break;
      case BWMFI:
         Label="BWMFI("+fNameVolume(Volume)+")";
         break;
      case CCI:
         Label="CCI("+ITS(Period_1)+","+fNamePriceShort(Price)+")";
         break;
      case CHAIKIN:
         Label="CHAIKIN("+ITS(Period_1)+","+ITS(Period_2)+","+fMethodName(Method)+","+fNameVolume(Volume)+")";
         break;
      case DEMARKER:
         Label="DEMARKER("+ITS(Period_1)+")";
         break;
      case FORCE:
         Label="FORCE("+ITS(Period_1)+","+fMethodName(Method)+","+fNameVolume(Volume)+")";
         break;
      case GATOR:
         Label="GATOR("+ITS(Period_1)+","+ITS(Shift_1)+","+ITS(Period_2)+","+ITS(Shift_2)+","+ITS(Period_3)+","+ITS(Shift_3)+","+fMethodName(Method)+","+fNameVolume(Volume)+")";
         break;
      case MACD:
         Label="MACD("+ITS(Period_1)+","+ITS(Period_2)+ITS(Period_3)+","+fNamePriceShort(Price)+")";
         break;
      case MFI:
         Label="MFI("+ITS(Period_1)+","+fNameVolume(Volume)+")";
         break;
      case MOMENTUM:
         Label="MOMENTUM("+ITS(Period_1)+","+fNamePriceShort(Price)+")";
         break;
      case OBV:
         Label="OBV("+fNameVolume(Volume)+")";
         break;
      case OSMA:
         Label="OSMA("+ITS(Period_1)+","+ITS(Period_2)+ITS(Period_3)+","+fNamePriceShort(Price)+")";
         break;
      case RSI:
         Label="RSI("+ITS(Period_1)+","+fNamePriceShort(Price)+")";
         break;
      case RVI:
         Label="RVI-"+fNameMainSignal(Line)+"("+ITS(Period_1)+")";
         break;
      case STDDEV:
         Label="STDDEV("+ITS(Period_1)+","+fMethodName(Method)+","+fNamePriceShort(Price)+")";
         break;
      case STOCHASTIC:
         Label="STOCHASTIC-"+fNameMainSignal(Line)+"("+ITS(Period_1)+","+ITS(Period_2)+ITS(Period_3)+","+fMethodName(Method)+","+fNameStoPriceShort(Price)+")";
         break;
      case TRIX:
         Label="TRIX("+ITS(Period_1)+","+fNamePriceShort(Price)+")";
         break;
      case VOLUMES:
         Label="VOLUMES("+fNameVolume(Volume)+")";
         break;
      case WPR:
         Label="WPR("+ITS(Period_1)+")";
         break;
     }

   PlotIndexSetString(0,PLOT_LABEL,"ST OF "+Label);
   IndicatorSetString(INDICATOR_SHORTNAME,"ST OF "+Label);
   IndicatorSetInteger(INDICATOR_DIGITS,2);

//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(HandleX);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime  &time[],
                const double  &open[],
                const double  &high[],
                const double  &low[],
                const double  &close[],
                const long  &tick_volume[],
                const long  &volume[],
                const int  &spread[])
  {
   static bool error=true;
   int start;
   int start2;
   int start3;
   int start4;
   static int begin;
   int prev_calc=prev_calculated;
   if(prev_calculated==0)
     {
      error=true;
     }
   if(error)
     {
      start=0;
      prev_calc=0;
     }
   else
     {
      start=prev_calculated-1;
     }
   if(CopyBuffer(HandleX,Line,0,rates_total-start,IndBuffer)==-1)
     {
      error=true;
      return(rates_total);
     }
   if(error)
     {
      for(int i=0;i<rates_total;i++)
        {
         if(IndBuffer[i]!=EMPTY_VALUE && IndBuffer[i]!=0)
           {
            begin=i;
            break;
           }
        }
      start2=start+StPeriod_K;
      start3=start2+StPeriod_K+StPeriod_S;
      start4=start3;
      begin=start4;
      ArrayInitialize(MainBuffer,EMPTY_VALUE);
      ArrayInitialize(SignalBuffer,EMPTY_VALUE);
      PlotIndexGetInteger(0,PLOT_DRAW_BEGIN,begin);
      PlotIndexGetInteger(1,PLOT_DRAW_BEGIN,begin+fMADrawBegin(StPeriod_D,StMethod));
      error=false;
     }
   else
     {
      start2=start;
      start3=start;
      start4=start;
     }

   for(int i=start2;i<rates_total;i++)
     {
      HighestBuffer[i]=IndBuffer[i];
      LowestBuffer[i]=IndBuffer[i];
      for(int j=i;j>i-StPeriod_K;j--)
        {
         HighestBuffer[i]=MathMax(HighestBuffer[i],IndBuffer[j]);
         LowestBuffer[i]=MathMin(LowestBuffer[i],IndBuffer[j]);
        }
     }

   for(int i=start3;i<rates_total;i++)
     {
      SumVBuffer[i]=0;
      SumRBuffer[i]=0;
      for(int j=i;j>i-StPeriod_S;j--)
        {
         SumVBuffer[i]+=IndBuffer[j]-LowestBuffer[j];
         SumRBuffer[i]+=HighestBuffer[j]-LowestBuffer[j];
        }
      SumRBuffer[i]=ND8(SumRBuffer[i]);
      if(SumRBuffer[i]==0)
        {
         MainBuffer[i]=100.0;
        }
      else
        {
         MainBuffer[i]=100.0*SumVBuffer[i]/SumRBuffer[i];
        }
     }
   fMAOnArray2(MainBuffer,SignalBuffer,StPeriod_D,StMethod,begin,start4,rates_total);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| fMAOnArray2                                                      |
//+------------------------------------------------------------------+
void fMAOnArray2(const double  &aData[],double  &aMA[],int aPeriod,int aMethod,int aBegin,int aStart,int aRatesTotal)
  {
   double p1;
   double p2;
   double tWS=0;
   switch(aMethod)
     {
      case MODE_SMA:
         aStart=MathMax(aStart,aBegin+aPeriod);
         for(int i=aStart;i<aRatesTotal;i++)
           {
            if(i==aBegin+aPeriod)
              {
               aMA[i]=0;
               for(int j=0;j<aPeriod;j++)
                 {
                  aMA[i]+=aData[i-j];
                 }
               aMA[i]/=aPeriod;
              }
            else
              {
               aMA[i]=aMA[i-1]-(aData[i-aPeriod]-aData[i])/aPeriod;
              }
           }
         break;
      case MODE_EMA:
         if(aStart==aBegin)
           {
            aMA[aBegin]=aData[aBegin];
            aStart++;
           }
         p1=2.0/(1.0+aPeriod);
         p2=(1.0-p1);
         for(int i=aStart;i<aRatesTotal;i++)
           {
            aMA[i]=p1*aData[i]+p2*aMA[i-1];
           }
         break;
      case MODE_LWMA:
         aStart=MathMax(aStart,aBegin+aPeriod);
         tWS=(1.0+aPeriod)/2.0*aPeriod;
         for(int i=aStart;i<aRatesTotal;i++)
           {
            aMA[i]=0;
            for(int j=0;j<aPeriod;j++)
              {
               aMA[i]+=aData[i-j]*(aPeriod-j);

              }
            aMA[i]/=tWS;
           }
         break;
      case MODE_SMMA:
         if(aStart==aBegin)
           {
            aMA[aBegin]=aData[aBegin];
            aStart++;
           }
         p1=1.0/aPeriod;
         p2=(1.0-p1);
         for(int i=aStart;i<aRatesTotal;i++)
           {
            aMA[i]=p1*aData[i]+p2*aMA[i-1];
           }
         break;
     }
  }
//+------------------------------------------------------------------+
//| ND8                                                              |
//+------------------------------------------------------------------+
double ND8(double aValue)
  {
   return(NormalizeDouble(aValue,8));
  }
//+------------------------------------------------------------------+
//| fMADrawBegin                                                     |
//+------------------------------------------------------------------+
int fMADrawBegin(int aPeriod,int aMethod)
  {
   switch(aMethod)
     {
      case 1: return(10*aPeriod);
      case 2: return(20*aPeriod);
     }
   return(aPeriod);
  }
//+------------------------------------------------------------------+
//| fNameVolume                                                      |
//+------------------------------------------------------------------+
string fNameVolume(int aVolume)
  {
   switch(aVolume)
     {
      case VOLUME_REAL: return("R");
      case VOLUME_TICK: return("T");
     }
   return("?");
  }
//+------------------------------------------------------------------+
//| ITS                                                              |
//+------------------------------------------------------------------+
string ITS(int aValue)
  {
   return(IntegerToString(aValue));
  }
//+------------------------------------------------------------------+
//| fNameADXLine                                                     |
//+------------------------------------------------------------------+
string fNameADXLine(int aLine)
  {
   switch(aLine)
     {
      case MAIN_LINE: return("MAIN");
      case PLUSDI_LINE: return("PDI");
      case MINUSDI_LINE: return("MDI");
     }
   return("?");
  }
//+------------------------------------------------------------------+
//| fNameMainSignal                                                  |
//+------------------------------------------------------------------+
string fNameMainSignal(int aLine)
  {
   switch(aLine)
     {
      case MAIN_LINE: return("MAIN");
      case SIGNAL_LINE: return("SIGNAL");
     }
   return("?");
  }
//+------------------------------------------------------------------+
//| fNamePriceShort                                                  |
//+------------------------------------------------------------------+
string fNamePriceShort(int aPrice)
  {
   switch(aPrice)
     {
      case PRICE_CLOSE:
         return("C");
      case PRICE_HIGH:
         return("H");
      case PRICE_LOW:
         return("L");
      case PRICE_MEDIAN:
         return("M");
      case PRICE_OPEN:
         return("O");
      case PRICE_TYPICAL:
         return("T");
      case PRICE_WEIGHTED:
         return("W");
     }
   return("?");
  }
//+------------------------------------------------------------------+
//| fNameStoPriceShort                                               |
//+------------------------------------------------------------------+
string fNameStoPriceShort(int aPrice)
  {
   switch(aPrice)
     {
      case STO_CLOSECLOSE: return("CC");
      case STO_LOWHIGH: return("LH");
     }
   return("?");
  }
//+------------------------------------------------------------------+
//| fMethodName                                                      |
//+------------------------------------------------------------------+
string fMethodName(int aMethod)
  {
   switch(aMethod)
     {
      case MODE_EMA: return("E");
      case MODE_LWMA: return("L");
      case MODE_SMA: return("S");
      case MODE_SMMA: return("SM");
     }
   return("?");
  }
//+------------------------------------------------------------------+
