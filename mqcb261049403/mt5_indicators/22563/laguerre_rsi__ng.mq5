//------------------------------------------------------------------
#property copyright "© mladen"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Laguerre RSI"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDodgerBlue,clrPaleVioletRed
#property indicator_width1  2
//
//--- input parameters
//
input double             RsiPeriod            = 32;             // Laguerre RSI period
input ENUM_APPLIED_PRICE RsiPrice             = PRICE_CLOSE;    // Price
input double             SmoothPeriod         = 1.001;          // Smoothing period (<=1 for no smoothing)
input double             LevelUp              = 0.85;           // Level up
input double             LevelDown            = 0.15;           // Level down
//
//--- buffers and global variables declarations
//
double val[],valc[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0,val ,INDICATOR_DATA); 
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX); 
      IndicatorSetInteger(INDICATOR_LEVELS,2);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0,LevelUp);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,1,LevelDown);
   
      IndicatorSetString(INDICATOR_SHORTNAME,"Laguerre RSI ("+(string)RsiPeriod+","+(string)SmoothPeriod+")");
   return(0);
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
      val[i]  = iLaGuerreFil(iLaGuerreRsi(getPrice(RsiPrice,open,close,high,low,i),RsiPeriod,i),SmoothPeriod,i);
      valc[i] = (val[i]>LevelUp) ? 1 : (val[i]<LevelDown) ? 2 : 0;
   }
   return(i);
}
//------------------------------------------------------------------
//    custom functions
//------------------------------------------------------------------
#define _lagRsiInstances 1
#define _lagRsiInstancesSize 4
#define _lagRsiRingSize 6
double workLagRsi[_lagRsiRingSize][_lagRsiInstances*_lagRsiInstancesSize];
double iLaGuerreRsi(double price, double period, int i, int instance=0)
{
   int _indC = (i  )%_lagRsiRingSize;
   int _inst = instance*_lagRsiInstancesSize;

   //
   //---
   //

      double CU = 0;
      double CD = 0;

      if (i>0 && period>1)
      {      
         int    _indP  = (i-1)%_lagRsiRingSize;
         double _gamma = 1.0 - 10.0/(period+9.0);
         
            workLagRsi[_indC][_inst  ] = price                      + _gamma*(workLagRsi[_indP][_inst  ] - price                     );
            workLagRsi[_indC][_inst+1] = workLagRsi[_indP][_inst  ] + _gamma*(workLagRsi[_indP][_inst+1] - workLagRsi[_indC][_inst  ]);
            workLagRsi[_indC][_inst+2] = workLagRsi[_indP][_inst+1] + _gamma*(workLagRsi[_indP][_inst+2] - workLagRsi[_indC][_inst+1]);
            workLagRsi[_indC][_inst+3] = workLagRsi[_indP][_inst+2] + _gamma*(workLagRsi[_indP][_inst+3] - workLagRsi[_indC][_inst+2]);
            
            //
            //---
            //
            
            if (workLagRsi[_indC][_inst] >= workLagRsi[_indC][_inst+1])
                  CU =  workLagRsi[_indC][_inst  ] - workLagRsi[_indC][_inst+1];
            else  CD =  workLagRsi[_indC][_inst+1] - workLagRsi[_indC][_inst  ];
            if (workLagRsi[_indC][_inst+1] >= workLagRsi[_indC][_inst+2])
                  CU += workLagRsi[_indC][_inst+1] - workLagRsi[_indC][_inst+2];
            else  CD += workLagRsi[_indC][_inst+2] - workLagRsi[_indC][_inst+1];
            if (workLagRsi[_indC][_inst+2] >= workLagRsi[_indC][_inst+3])
                  CU += workLagRsi[_indC][_inst+2] - workLagRsi[_indC][_inst+3];
            else  CD += workLagRsi[_indC][_inst+3] - workLagRsi[_indC][_inst+2];
      }
      else for (int k=0; k<_lagRsiInstancesSize; k++) workLagRsi[_indC][_inst+k]=price;

   //
   //---
   //

   return((CU+CD!=0) ? CU/(CU+CD) : 0);
}
//
//---
//
#define _lagFilInstances 1
#define _lagFilInstancesSize 4
#define _lagFilRingSize 6
double workLagFil[_lagFilRingSize][_lagFilInstances*_lagFilInstancesSize];
double iLaGuerreFil(double price, double period, int i, int instance=0)
{
   int _indC = (i)%_lagFilRingSize;
   int _inst = instance*_lagFilInstancesSize;

      //
      //---
      //

      if (i>0 && period>1)
      {      
         int    _indP  = (i-1)%_lagFilRingSize;
         double _gamma = 1.0 - 10.0/(period+9.0);
            workLagFil[_indC][_inst  ] =  price                      + _gamma*(workLagFil[_indP][_inst  ] - price                     );
            workLagFil[_indC][_inst+1] =  workLagFil[_indP][_inst  ] + _gamma*(workLagFil[_indP][_inst+1] - workLagFil[_indC][_inst  ]);
            workLagFil[_indC][_inst+2] =  workLagFil[_indP][_inst+1] + _gamma*(workLagFil[_indP][_inst+2] - workLagFil[_indC][_inst+1]);
            workLagFil[_indC][_inst+3] =  workLagFil[_indP][_inst+2] + _gamma*(workLagFil[_indP][_inst+3] - workLagFil[_indC][_inst+2]);
      }
      else for (int k=0; k<_lagFilInstancesSize; k++) workLagFil[_indC][_inst+k]=price;

      //
      //---
      //

   return((workLagFil[_indC][_inst]+2.0*workLagFil[_indC][_inst+1]+2.0*workLagFil[_indC][_inst+2]+workLagFil[_indC][_inst+3])/6.0);
}

//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i)
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
