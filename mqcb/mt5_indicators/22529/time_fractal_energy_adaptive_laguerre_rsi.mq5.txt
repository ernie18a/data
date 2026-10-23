//------------------------------------------------------------------
#property copyright "© mladen"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDodgerBlue,clrPaleVioletRed
#property indicator_width1  2
//
//---
//
enum enColorDisplay
{
   change_onLevel, // Change colors on levels crossing
   change_onSlope  // Change colors on Laguerre RSI slope
};
input int                inpAtrPeriod    = 14;             // ATR period 
input ENUM_APPLIED_PRICE inpRsiPrice     = PRICE_CLOSE;    // Price
input double             inpSmooth       = 5;              // Smoothing factor
input double             inpLevelUp      = 0.85;           // Level up
input double             inpLevelDown    = 0.15;           // Level down
input enColorDisplay     inpColorDisplay = change_onLevel; // Color change mode :

//
//--- buffers and global variables declarations
//
double val[],valc[],tr[];
double _smoothFactor;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0,val ,INDICATOR_DATA); 
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX); 
   SetIndexBuffer(2,tr  ,INDICATOR_CALCULATIONS); 
      IndicatorSetInteger(INDICATOR_LEVELS,2);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0, inpLevelUp);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,1, inpLevelDown);
         _smoothFactor = MathMax(1,inpSmooth);
      IndicatorSetString(INDICATOR_SHORTNAME,"Time Fractal Energy adaptive Laguerre RSI ("+(string)inpAtrPeriod+","+(string)_smoothFactor+")");
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
   int i=(int)MathMax(prev_calculated-1,0); for (; i<rates_total && !_StopFlag; i++)
   {
      tr[i] = (i>0) ? MathMax(high[i],close[i-1])-MathMin(low[i],close[i-1]) : high[i]-low[i];
      double _atr = tr[i],_min = low[i],_max = high[i];
         for (int k=1; k<inpAtrPeriod && (i-k)>=0; k++)
         {
            _atr += tr[i-k];
            _max = MathMax(high[i-k],_max);
            _min = MathMin(low [i-k],_min);
         }
      double _gamma = (_min!=_max) ? MathLog(_atr/(_max-_min))/MathLog(inpAtrPeriod) : 0;
      double _rsi   = iLaGuerreRsi(getPrice(inpRsiPrice,open,close,high,low,i,rates_total),_gamma,i);
             val[i] = iLaGuerreFil(_rsi,_gamma/_smoothFactor,i);
      switch (inpColorDisplay)
      {
         case change_onLevel : valc[i] = (val[i]>inpLevelUp) ? 1 : (val[i]<inpLevelDown) ? 2 : 0; break;
         case change_onSlope : valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
      }         
   }
   return(i);
}
//------------------------------------------------------------------
//    custom functions
//------------------------------------------------------------------
#define _lagRsiInstances 1
#define _lagRsiInstancesSize 4
#define _lagRsiRingSize 5
double workLagRsi[_lagRsiRingSize][_lagRsiInstances*_lagRsiInstancesSize];
double iLaGuerreRsi(double price, double gamma, int i, int instance=0)
{
   int _indP = (i-1)%_lagRsiRingSize;
   int _indC = (i  )%_lagRsiRingSize;
   int _inst = instance*_lagRsiInstancesSize;

   //
   //---
   //

      workLagRsi[_indC][_inst  ] = (i>0) ? (1.0 - gamma)*price                                            + gamma*workLagRsi[_indP][_inst  ] : price;
	   workLagRsi[_indC][_inst+1] = (i>0) ? -gamma*workLagRsi[_indC][_inst  ] + workLagRsi[_indP][_inst  ] + gamma*workLagRsi[_indP][_inst+1] : price;
	   workLagRsi[_indC][_inst+2] = (i>0) ? -gamma*workLagRsi[_indC][_inst+1] + workLagRsi[_indP][_inst+1] + gamma*workLagRsi[_indP][_inst+2] : price;
	   workLagRsi[_indC][_inst+3] = (i>0) ? -gamma*workLagRsi[_indC][_inst+2] + workLagRsi[_indP][_inst+2] + gamma*workLagRsi[_indP][_inst+3] : price;

      double CU = 0.00;
      double CD = 0.00;
      if (i>0)
      {   
            if (workLagRsi[_indC][_inst] >= workLagRsi[_indC][_inst+1])
            			CU =      workLagRsi[_indC][_inst  ] - workLagRsi[_indC][_inst+1];
            else	   CD =      workLagRsi[_indC][_inst+1] - workLagRsi[_indC][_inst  ];
            if (workLagRsi[_indC][_inst+1] >= workLagRsi[_indC][_inst+2])
            			CU = CU + workLagRsi[_indC][_inst+1] - workLagRsi[_indC][_inst+2];
            else	   CD = CD + workLagRsi[_indC][_inst+2] - workLagRsi[_indC][_inst+1];
            if (workLagRsi[_indC][_inst+2] >= workLagRsi[_indC][_inst+3])
   	       		   CU = CU + workLagRsi[_indC][_inst+2] - workLagRsi[_indC][_inst+3];
            else	   CD = CD + workLagRsi[_indC][_inst+3] - workLagRsi[_indC][_inst+2];
         }            

   //
   //---
   //

   return((CU + CD != 0) ? CU / (CU + CD) : 0);
}

//
//---
//
#define _lagFilInstances 1
#define _lagFilInstancesSize 4
#define _lagFilRingSize 5
double workLagFil[_lagFilRingSize][_lagFilInstances*_lagFilInstancesSize];
double iLaGuerreFil(double price, double gamma, int i, int instance=0)
{
   if (gamma<=0) return(price);
   int _indP = (i-1)%_lagFilRingSize;
   int _indC = (i  )%_lagFilRingSize;
   int _inst = instance*_lagFilInstancesSize;

   //
   //---
   //
      
      workLagFil[_indC][_inst  ] = (i>0) ? (1.0 - gamma)*price                                            + gamma*workLagFil[_indP][_inst  ] : price;
	   workLagFil[_indC][_inst+1] = (i>0) ? -gamma*workLagFil[_indC][_inst  ] + workLagFil[_indP][_inst  ] + gamma*workLagFil[_indP][_inst+1] : price;
	   workLagFil[_indC][_inst+2] = (i>0) ? -gamma*workLagFil[_indC][_inst+1] + workLagFil[_indP][_inst+1] + gamma*workLagFil[_indP][_inst+2] : price;
	   workLagFil[_indC][_inst+3] = (i>0) ? -gamma*workLagFil[_indC][_inst+2] + workLagFil[_indP][_inst+2] + gamma*workLagFil[_indP][_inst+3] : price;

      //
      //---
      //
 
   return((workLagFil[_indC][_inst+0]+2.0*workLagFil[_indC][_inst+1]+2.0*workLagFil[_indC][_inst+2]+workLagFil[_indC][_inst+3])/6.0);
}

//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
   switch(tprice)
     {
      case PRICE_CLOSE:     return(close[i]);
      case PRICE_OPEN:      return(open[i]);
      case PRICE_HIGH:      return(high[i]);
      case PRICE_LOW:       return(low[i]);
      case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
      case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
      case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
     }
   return(0);
  }
//------------------------------------------------------------------
