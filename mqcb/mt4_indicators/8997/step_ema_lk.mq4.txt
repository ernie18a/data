//+------------------------------------------------------------------+
//|                                                  Step_EMA_LK.mq4 |
//|                                 Copyright © 2009, Leif Karlsson. |
//|                                        Leffemannen1973@telia.com |
//+------------------------------------------------------------------+
//| Please feel free to copy, modify and / or redistribute this      |
//| software / source code in any way you see fit.                   |
//+------------------------------------------------------------------+
//+ ********************* Shameless Ad. **************************** +
//+ * I do custom programing jobs in Java, C, X86 Assembler & MQL4 * +
//+ ***** Pleace do not hesitate to get in contact if you nead ***** +
//+ ***** something special: EA, indicator or somthing else. ******* +
//+ ****************** Leffemannen1973@telia.com ******************* +
//+ **************************************************************** +
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Leif Kalrsson"
#property link      "mailto://Leffemannen1973@telia.com"
//+------------------------------------------------------------------+
#property  indicator_chart_window
#property  indicator_buffers 2
#property  indicator_color1  Yellow
#property  indicator_color2  Red
#property  indicator_width1  1
//+------------------------------------------------------------------+
extern int EMAPeriod=30;
extern int ERangePeriod =14;
extern int ERangeWindow=8;      // Must be less then ERangePeriod, think of it as custom TF
extern string AppliedPriceText1 = "Close: 0, Open: 1, High: 2, Low: 3";
extern string AppliedPriceText2 = "Median: 4, Typical: 5, Weighted: 6";
extern int AppliedPrice=4;
extern int PriceShift=0;
extern int MaxBars=4000;
//+------------------------------------------------------------------+
double UpBuffer[];
double DwBuffer[];
double Price[];
double ERange[];
double EmaAlpha=0.0;
double ERangeAlpha=0.0;
//+------------------------------------------------------------------+
int init() 
  {

   IndicatorDigits(Digits+1);

   IndicatorBuffers(4);

   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(0,UpBuffer);
   SetIndexBuffer(1,DwBuffer);
   SetIndexBuffer(2,Price);
   SetIndexBuffer(3,ERange);

   IndicatorShortName("Step_EMA, EMAPeriod: "+EMAPeriod+", ERangePeriod: "+ERangePeriod+" ");

   EmaAlpha=2.0/(EMAPeriod+1.0);
   ERangeAlpha=2.0/(ERangePeriod+1.0);

   return(0);
  }
//+------------------------------------------------------------------+
int start() 
  {
   /*int j = 0;
   int i = IndicatorCounted();
   if(i < 0) return(-1);
   i=Bars-i;*/
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+1+PriceShift;

   int j=0;
   int i=limit;        
   
   if(i>MaxBars) 
     {
      i=MaxBars;
      ArrayInitialize(UpBuffer,EMPTY_VALUE);
      ArrayInitialize(DwBuffer,EMPTY_VALUE);
      ArrayInitialize(ERange,High[i]-Low[i]);
     }

   j=i;
   while(j>=0) 
     {
      Price[j]=iMA(NULL,0,1,0,0,AppliedPrice,j+PriceShift);
      j--;
     }

   while(i>=0) 
     {
      double Range=0.0;
      double StepSize=0.0;
      double SEma=0.0;
      double OldSEma=0.0;

      Range=High[ArrayMaximum(High,ERangeWindow,i+PriceShift+1)]-Low[ArrayMinimum(Low,ERangeWindow,i+PriceShift+1)];
      ERange[i]=(1.0-ERangeAlpha)*ERange[i+1]+ERangeAlpha*Range;
      StepSize = ERange[i];

      if(UpBuffer[i+1] != EMPTY_VALUE) SEma = (1.0-EmaAlpha)*UpBuffer[i+1] + EmaAlpha*Price[i];
      if(DwBuffer[i+1] != EMPTY_VALUE) SEma = (1.0-EmaAlpha)*DwBuffer[i+1] + EmaAlpha*Price[i];
      if(SEma==0.0) SEma=Price[i];

      if(SEma < Price[i]-StepSize) SEma = Price[i]-StepSize;
      if(SEma > Price[i]+StepSize) SEma = Price[i]+StepSize;

      if(UpBuffer[i+1]==EMPTY_VALUE) OldSEma=DwBuffer[i+1];
      else OldSEma=UpBuffer[i+1];

      if(SEma>OldSEma) 
        {
         UpBuffer[i] = SEma;
         DwBuffer[i] = EMPTY_VALUE;
         if(UpBuffer[i+1]==EMPTY_VALUE) UpBuffer[i+1]=OldSEma;
        }
      else 
        {
         DwBuffer[i] = SEma;
         UpBuffer[i] = EMPTY_VALUE;
         if(DwBuffer[i+1]==EMPTY_VALUE) DwBuffer[i+1]=OldSEma;
        }
      i--;
     }

   return(0);
  }
//+------------------------------------------------------------------+
