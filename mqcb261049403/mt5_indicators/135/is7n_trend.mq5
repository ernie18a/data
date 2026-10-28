//+------------------------------------------------------------------+
//|                                                 iS7N_TREND.mq5   |
//|                                       Copyright 2010, SHOOTER777 |
//|                                                      s7n@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, SHOOTER777"
#property link      "s7n@mail.ru"
#property version   "1.00"
//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
//---- plot settings
#property indicator_label1  "iTREND"
//---  
#property indicator_color1  DarkBlue, LightBlue
#property indicator_type1 DRAW_COLOR_LINE 
#property indicator_width1  2

enum eColor
  {
   one_color_indicator,
   two_color_indicator
  };

//--- input parameters of the iS7N_TREND indicator
input int    Per=20;  // indicator period
input eColor eC=1; // color scheme
input color  Up    = DarkBlue;    // bull color (uptrend)
input color  Down  = LightBlue;   // bear color (downtrend)
input int    iMax=200; //calc and plot iMx bars
//--- as a fact, the number of calculated bars is iMx-Per 
//--- or in some cases more, for example if the specified period is greater than iMx
//--- indicator buffers
double dPlot[];
double dColor[];
//---  calculations buffers
double dBuf_I[];
//---  handles buffers
double dBuf_1[];
double dBuf_2[];
//--- handles
int ihMA_1;
int ihMA_2;
//--- global variables
int P0,P2,P4;
int iMx;
int limit;
string sShNm;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   int iPer=StringConcatenate(sShNm,"iS7N_TREND( ",Per," )");
   int iBars=Bars(_Symbol,_Period);  // number of bars in the history
   iMx=iMax;
   Print(" Total ",iBars," bars in the history are available");
//---
   SetIndexBuffer(0,dPlot,INDICATOR_DATA);
   PlotIndexSetString(0,PLOT_LABEL,"TREND");
   ArraySetAsSeries(dPlot,true);
//---
   SetIndexBuffer(1,dColor,INDICATOR_COLOR_INDEX);
   ArraySetAsSeries(dColor,true);
//---
   SetIndexBuffer(2,dBuf_I,INDICATOR_CALCULATIONS);
   ArraySetAsSeries(dBuf_I,true);
//---
   ArraySetAsSeries(dBuf_1,true);
   ArraySetAsSeries(dBuf_2,true);
//---
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits-1);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,sShNm);
//---  
// setting the buffer colors
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,Up);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,Down);
//---
// if one color mode is selected
   if(eC==0)
     {
      Print("One color mode is selected");
      //--- set the second color the same as the first
      PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,Up);
     }
   else
//--- don't change anything
      Print("Two-color mode is selected");
//---
   vInPr();          // calculate periods
//---
   if(!vInHandl()) // get the indicator handles
     {
      Print("???There was an error in initialization???");
      Print("Error  №",GetLastError());
      return(-1);
     }
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//---
   if(prev_calculated<=0)
     {
      for(int i=0;i<=rates_total-1;i++)
        {
         dPlot[i]=EMPTY_VALUE;
        }
     }

//--- the number of available bars should be greater than 10 periods of the indicator
   int iMn=10*P0;
//--- we return if rates_total is less than needed (iMn)
   if(iMn>rates_total)return(0);
//--- set correct size
   if(iMn>iMx) iMx=iMn;
//--- calc as is 
   if(iMx>rates_total)iMx=rates_total;
//---    
   int iii;  // variable for the main loop

//--- we will recalculate only preMx last bars
   int preMx=1;
//--- if it first call...
   if(prev_calculated<=0)
      //--- recalculate all the bars
     {
      limit=iMx;
      Print("The indicator will be calculated for the ",limit-P0," last bars");
      Print("After that, the indicator will be calculated for the ",P0+preMx," last bars");
      //--- ArrayInitialize(dPlot,EMPTY_VALUE);
     }
//--- otherwise, we recalc only preMx last bars
   else
     {
      limit=P0+preMx;
     }
//---
   ArrayResize(dBuf_1,limit);
   ArrayResize(dBuf_2,limit);

   if(!vCopy()) return(0);

   for(iii=0; iii<limit; iii++)
     {
      dBuf_I[iii]=2.0*dBuf_2[iii]-dBuf_1[iii];
     }
//---
//Print("The indicator will be calculated for ",limit," bars");
//---
   ArrayResize(dBuf_I,limit);
//---
   for(iii=0; iii<limit-P0;iii++)
     {
      dPlot[iii]=iLWMA(dBuf_I,P4,iii);
     }
//---
   for(iii=0; iii<limit-P0;iii++)
     {
      if(dPlot[iii]>dPlot[iii+1])
         dColor[iii]=0;
      else
         dColor[iii]=1;
     }
   ChartRedraw();
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| vInPr                                                            |
//+------------------------------------------------------------------+
void vInPr()
  {
   P0=Per;
   P2=Per/2;
   P4= int (MathSqrt(Per));
  }
//+------------------------------------------------------------------+
//| vInHandl                                                         |
//+------------------------------------------------------------------+
bool vInHandl()
  {
   Print("Get the indicator handles for the iS7N_TREND indicator");
//---
   ihMA_1  = iMA(Symbol(), 0, P0 , 0, MODE_EMA, PRICE_CLOSE);
   ihMA_2  = iMA(Symbol(), 0, P2 , 0, MODE_EMA, PRICE_CLOSE);
//---
   if(ihMA_1<0 || ihMA_1<0)
     {
      Print(" Error creating indicators");
      return(false);
     }
   else
     {
      Print("The handles has been initialized successfully");
      Print("The main      : Period = ",P0,"   Handle =",ihMA_1);
      Print("The secondary : Period = ",P2,"   Handle =",ihMA_2);
      return(true);
     }
  }
//+------------------------------------------------------------------+
//| vCopy                                                            |
//+------------------------------------------------------------------+
bool vCopy()
  {
   int n1,n2;
   n1=CopyBuffer(ihMA_1,0,0,limit,dBuf_1);
   n2=CopyBuffer(ihMA_2,0,0,limit,dBuf_2);
   if(n1==-1 || n2==-1)
     {
      Print("Error in call of the CopyBuffer function, error №=",GetLastError());
      return(false);
     }
   else return(true);
  }
//+------------------------------------------------------------------+
//| LWMA iMAOnArrayMQL4                                              |
//+------------------------------------------------------------------+
double iLWMA(double &array[],
             int period,
             int shift)
  {
   double buf[],arr[];
   int total=ArraySize(array);
   if(total>0 && total<=period) return(0);
   if(shift>total-period) return(0);

   if(ArrayResize(buf,total)<0) return(0);
   double sum=0.0,lsum=0.0;
   double price;
   int    i,weight=0,pos=total-1;
   for(i=1;i<=period;i++,pos--)
     {
      price=array[pos];
      sum+=price*i;
      lsum+=price;
      weight+=i;
     }
   pos++;
   i=pos+period;
   while(pos>=0)
     {
      buf[pos]=sum/weight;
      if(pos==0) break;
      pos--;
      i--;
      price=array[pos];
      sum=sum-lsum+price*period;
      lsum-=array[i];
      lsum+=price;
     }
   return(buf[shift]);

  }
//+------------------------------------------------------------------+
