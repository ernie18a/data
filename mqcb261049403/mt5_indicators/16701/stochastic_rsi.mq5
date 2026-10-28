//+------------------------------------------------------------------+
//|                                               Stochastic RSI.mq5 |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"
#property version   "1.00"

#property indicator_separate_window
#property indicator_buffers   5
#property indicator_plots     2
#property indicator_minimum  -1
#property indicator_maximum 101

//
//
//
//
//

#property indicator_label1  "Stochastic"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  Green,Red
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_type2   DRAW_LINE
#property indicator_color2  DimGray
#property indicator_width2  2


//
//
//
//
//

input int                inpRSIPeriod  = 14;          // RSI period
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // RSI applied to price
input int                inpStoPeriod1 = 55;          // Stochastic period 1 (less than 2 - no stochastic)
input int                inpStoPeriod2 = 55;          // Stochastic period 2 (less than 2 - no stochastic)
input int                inpEMAPeriod  = 15;          // Smoothing period (less than 2 - no smoothing)
input double             inpUpLevel    = 80.0;        // Overbought level
input double             inpDnLevel    = 20.0;        // Oversold level

//
//
//
//
//

double RsiBuffer[];
double StoBuffer[];
double StcBuffer[];
double StlBuffer[];
double LevBuffer[];

//
//
//
//
//

int iRSIPeriod;
int iStoPeriod1;
int iStoPeriod2;
int iEMAPeriod;
int rsiHandle;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int OnInit()
{
   SetIndexBuffer(0,StoBuffer,INDICATOR_DATA);         ArraySetAsSeries(StoBuffer,true);
   SetIndexBuffer(1,LevBuffer,INDICATOR_DATA);         ArraySetAsSeries(LevBuffer,true);
   SetIndexBuffer(2,StlBuffer,INDICATOR_DATA);         ArraySetAsSeries(StlBuffer,true);
   SetIndexBuffer(3,RsiBuffer,INDICATOR_CALCULATIONS); ArraySetAsSeries(RsiBuffer,true);
   SetIndexBuffer(4,StcBuffer,INDICATOR_CALCULATIONS); ArraySetAsSeries(StcBuffer,true);

   //
   //
   //
   //
   //
   
   iRSIPeriod  = (inpRSIPeriod>0)  ? inpRSIPeriod  : 1;
   iEMAPeriod  = (inpEMAPeriod>0)  ? inpEMAPeriod  : 1;
   iStoPeriod1 = (inpStoPeriod1>0) ? inpStoPeriod1 : 1;
   iStoPeriod2 = (inpStoPeriod2>0) ? inpStoPeriod2 : 1;
     rsiHandle = iRSI(NULL,0,iRSIPeriod,inpPrice);
     
   //
   //
   //
   //
   //
        
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,inpUpLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,inpDnLevel);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,DimGray);
   
   string strSmooth = (iEMAPeriod>1) ? "smoothed " : "";
   string strStoch  = (iStoPeriod1>1 || iStoPeriod2>1) ? "stochastic " : "";
          strStoch  = (iStoPeriod1>1 && iStoPeriod2>1) ? "double stochastic " : strStoch;
   IndicatorSetString(INDICATOR_SHORTNAME,strSmooth+strStoch+"RSI("+(string)iRSIPeriod+","+(string)iStoPeriod1+","+(string)iStoPeriod2+","+(string)iEMAPeriod+")");
     
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{

   //
   //
   //
   //
   //

      int limit = rates_total-prev_calculated;
         if (prev_calculated > 0) limit++;
         if (prev_calculated ==0)
         {
            int last   = (iStoPeriod1>iStoPeriod2) ? iStoPeriod1 : iStoPeriod2;
                limit -= (last+1);
                        for (int i=1; i<=last; i++) StoBuffer[rates_total-i] = 0;
         }
         if (!checkCalculated(rsiHandle,rates_total,"RSI")) return(prev_calculated);
         if (!doCopy(rsiHandle,RsiBuffer,0,limit   ,"RSI")) return(prev_calculated);

   //
   //
   //
   //
   //
           
      double max,min,sto;
      double alpha = 2.0/(1.0+iEMAPeriod);
      
      //
      //
      //
      //
      //
         
      for (int i=limit; i>=0; i--)
      {
         if (iStoPeriod1>1)
         {
            max = RsiBuffer[i]; for(int k=1; k<iStoPeriod1; k++) max = MathMax(max,RsiBuffer[i+k]);
            min = RsiBuffer[i]; for(int k=1; k<iStoPeriod1; k++) min = MathMin(min,RsiBuffer[i+k]);
            if (max!=min)
                  StcBuffer[i] = (RsiBuffer[i]-min)/(max-min)*100.00;
            else  StcBuffer[i] = 0;
         }
         else StcBuffer[i] = RsiBuffer[i];
         
         //
         //
         //
         //
         //
                     
         if (iStoPeriod2>1)
         {
            max = StcBuffer[i]; for(int k=1; k<iStoPeriod2; k++) max = MathMax(max,StcBuffer[i+k]);
            min = StcBuffer[i]; for(int k=1; k<iStoPeriod2; k++) min = MathMin(min,StcBuffer[i+k]);
            if (max!=min)
                  sto = (StcBuffer[i]-min)/(max-min)*100.00;
            else  sto = 0;
         }
         else sto = StcBuffer[i];
         StoBuffer[i] = StoBuffer[i+1]+alpha*(sto-StoBuffer[i+1]);
         StlBuffer[i] = StoBuffer[i];
         LevBuffer[i] = StoBuffer[i];
   
         //
         //
         //
         //
         //
               
         if (StoBuffer[i]>inpUpLevel) LevBuffer[i] = inpUpLevel;
         if (StoBuffer[i]<inpDnLevel) LevBuffer[i] = inpDnLevel;
   }
   
   //
   //
   //
   //
   //

   return(rates_total);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//

bool checkCalculated(int bufferHandle, int total, string checkDescription)
{
   int calculated=BarsCalculated(bufferHandle);
   if (calculated<total)
   {
      Print("Not all data of "+checkDescription+" calculated (",(string)(total-calculated)," un-calculated bars )");
      return(false);
   }
   return(true);
}

//
//
//
//
//

bool doCopy(const int bufferHandle, double& buffer[], const int buffNum, const int copyCount, string copyDescription)
{
   if(CopyBuffer(bufferHandle,buffNum,0,copyCount,buffer)<=0)
   {
      Print("Getting "+copyDescription+" failed! Error",GetLastError());
      return(false);
   }
   return(true);
}
