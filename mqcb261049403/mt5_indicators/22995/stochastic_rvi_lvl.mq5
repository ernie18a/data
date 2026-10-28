//------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Stochastic RVI - levels"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_plots   3
#property indicator_label1  "Level up"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGray
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Level down"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Stochastic RVI"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width3  2

//
//--- input parameters
//

input int     inpRviPeriod    = 32; // RVI period
input double  inpLevelPeriod  = 10; // Levels period

//
//--- buffers declarations
//

double val[],valc[],lup[],ldn[],rvi[],work[],rvi_num[],rvi_denom[],rvi_nums[],rvi_denoms[],ª_lvlPeriod,ª_alphal; 

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
int OnInit()
{
   //--- indicator buffers mapping
         SetIndexBuffer(0,lup       ,INDICATOR_DATA);
         SetIndexBuffer(1,ldn       ,INDICATOR_DATA);
         SetIndexBuffer(2,val       ,INDICATOR_DATA);
         SetIndexBuffer(3,valc      ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(4,rvi       ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(5,work      ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(6,rvi_num   ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(7,rvi_denom ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(8,rvi_nums  ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(9,rvi_denoms,INDICATOR_CALCULATIONS);
         ª_lvlPeriod = inpLevelPeriod>1 ? inpLevelPeriod : 1;
         ª_alphal    = 2.0/(1.0+ª_lvlPeriod);
   //---
   IndicatorSetString(INDICATOR_SHORTNAME,"Stochastic RVI ("+(string)inpRviPeriod+","+(string)ª_lvlPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      rvi_num[i]   = (i>2) ? close[i]-open[i]+2.0*(close[i-1]-open[i-1])+2.0*(close[i-2]-open[i-2])+close[i-3]-open[i-3] : 0;
      rvi_denom[i] = (i>2) ? high[i]-low[i]+2.0*(high[i-1]-low[i-1])+2.0*(high[i-2]-low[i-2])+high[i-3]-low[i-3] : 0;
      if (i>inpRviPeriod+3)
      {
         rvi_nums[i]   = rvi_nums[i-1]+rvi_num[i]-rvi_num[i-inpRviPeriod];
         rvi_denoms[i] = rvi_denoms[i-1]+rvi_denom[i]-rvi_denom[i-inpRviPeriod];
      }
      else
      {
         rvi_nums[i]   = rvi_num[i];
         rvi_denoms[i] = rvi_denom[i];
         for(int k=1; k<inpRviPeriod && i>=k; k++)
         {
            rvi_nums[i]   += rvi_num[i-k];
            rvi_denoms[i] += rvi_denom[i-k];
         }
      }

      //
      //---
      //

      rvi[i] = (rvi_denoms[i]!=0.0) ? rvi_nums[i]/rvi_denoms[i] : rvi_nums[i];
            int    _start = (i>inpRviPeriod) ? i-inpRviPeriod+1 : 0;
            double _lo    = rvi[ArrayMinimum(rvi,_start,inpRviPeriod)];
            double _hi    = rvi[ArrayMaximum(rvi,_start,inpRviPeriod)];
      work[i] = (_hi!=_lo) ? (rvi[i]-_lo)/(_hi-_lo) : 0;
      val[i]  = (i>2) ? (4.0*work[i]+3.0*work[i-1]+2.0*work[i-2]+work[i-3])/10.0 : 0;
      lup[i]  = (i>0) ? (val[i]<ldn[i-1]) ? lup[i-1] : lup[i-1]+ª_alphal*(val[i]-lup[i-1]) : val[i];
      ldn[i]  = (i>0) ? (val[i]>lup[i-1]) ? ldn[i-1] : ldn[i-1]+ª_alphal*(val[i]-ldn[i-1]) : val[i];
      valc[i] = (val[i]>lup[i]) ? 1 :(val[i]<ldn[i]) ? 2 : 0;
   }
   return (i);
}
//------------------------------------------------------------------