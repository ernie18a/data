//+------------------------------------------------------------------+
//|                                                     Coppock .mq4 |
//|                                    Copyright © 2007, Robert Hill |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2007, Robert Hill"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 1
#property  indicator_color1  Red
//---- indicator parameters
extern string  strROC="ROC Period for lookback";
extern int     RPeriod1=80;
extern string  strType1="Moving Average Types" ;
extern string  str10="0 = SMA, 1 = EMA";
extern string  str11="2 = SMMA, 3 = LWMA";
extern int     RMAMode1=0;
extern string  sep0="----------------------------------";
extern int     RPeriod2=10;
extern string  strType2="Moving Average Types" ;
extern string  str20="0 = SMA, 1 = EMA";
extern string  str21="2 = SMMA, 3 = LWMA";
extern int     RMAMode2=0;
extern string  sep1="----------------------------------";
extern string  strMA="MA input parameters";
extern int     MAPeriod=20;
extern string  strType="Moving Average Types" ;
extern string  strm0="0 = SMA, 1 = EMA";
extern string  strm1="2 = SMMA, 3 = LWMA";
extern int     MAType=0;
extern string  sep2="----------------------------------";
extern bool    UsePercent=false;
//---- indicator buffers
double     Coppock[];
double     RateOfChange1[];
double     RateOfChange2[];
double     RateOfChange3[];
//---- variables
int    MAMode;
string strMAType;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   IndicatorBuffers(4);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexDrawBegin(0,MAPeriod);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
//---- indicator buffers mapping
   SetIndexBuffer(0,Coppock);
   SetIndexBuffer(1,RateOfChange1);
   SetIndexBuffer(2,RateOfChange2);
   SetIndexBuffer(3,RateOfChange3);
   switch(MAType)
     {
      case 1: strMAType="EMA"; MAMode=MODE_EMA; break;
      case 2: strMAType="SMMA"; MAMode=MODE_SMMA; break;
      case 3: strMAType="LWMA"; MAMode=MODE_LWMA; break;
      default: strMAType="SMA"; MAMode=MODE_SMA; break;
     }
   IndicatorShortName( "Coppock (" + RPeriod1 + "," + RPeriod2 + ") " + strMAType+ " (" +MAPeriod + ") ");
//---- name for DataWindow and indicator subwindow label
   SetIndexLabel(0,"Coppock");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Coppock                                                          |
//+------------------------------------------------------------------+
int start()
  {
   int limit, i;
   double MA_Cur1, MA_Prev1;
   double MA_Cur2, MA_Prev2;
   double ROC1, ROC2;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- ROC calculations
   for( i=0; i<limit; i++)
     {
      MA_Cur1=iMA(NULL,0,RPeriod1,0,RMAMode1, PRICE_CLOSE,i);
      MA_Prev1=iMA(NULL,0,RPeriod1,0,RMAMode1, PRICE_CLOSE,i+RPeriod1);
      MA_Cur2=iMA(NULL,0,RPeriod2,0,RMAMode2, PRICE_CLOSE,i);
      MA_Prev2=iMA(NULL,0,RPeriod2,0,RMAMode2, PRICE_CLOSE,i+RPeriod2);
      ROC1=MA_Cur1-MA_Prev1;
      ROC2=MA_Cur2-MA_Prev2;
      if (UsePercent)
        {
         RateOfChange1[i]=NormalizeDouble(100 * ROC1/MA_Prev1, 3);
         RateOfChange2[i]=NormalizeDouble(100 * ROC2/MA_Prev2, 3);
        }
      else
        {
         RateOfChange1[i]=NormalizeDouble(ROC1/Point,1);
         RateOfChange2[i]=NormalizeDouble(ROC2/Point,1);
        }
      RateOfChange3[i]=RateOfChange1[i] + RateOfChange2[i];
     }
   for( i=0; i<limit; i++)
     {
      Coppock[i]=iMAOnArray(RateOfChange3,0,MAPeriod,0,MAMode,i);
     }
//---- done
   return(0);
  }
//+------------------------------------------------------------------+