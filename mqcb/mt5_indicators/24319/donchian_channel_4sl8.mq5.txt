//------------------------------------------------------------------
#property copyright "© mladen, 2019"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   6

#property indicator_label1  "High fill"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'220,235,220'
#property indicator_label2  "Low fill"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  C'235,220,220'
#property indicator_label3  "Highest high"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrMediumSeaGreen
#property indicator_label4  "Lowest high"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrMediumSeaGreen
#property indicator_style4  STYLE_DOT
#property indicator_label5  "Lowest low"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrOrangeRed
#property indicator_label6  "Highest low"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrOrangeRed
#property indicator_style6  STYLE_DOT
//
//--- input parameters
//
input int inpChannelPeriod=20; // Period
//
//--- indicator buffers
//
double valuu[],valud[],valdd[],valdu[],filluu[],fillud[],filldd[],filldu[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,filluu,INDICATOR_DATA);
         SetIndexBuffer(1,fillud,INDICATOR_DATA);
         SetIndexBuffer(2,filldu,INDICATOR_DATA);
         SetIndexBuffer(3,filldd,INDICATOR_DATA);
         SetIndexBuffer(4,valuu ,INDICATOR_DATA);
         SetIndexBuffer(5,valud ,INDICATOR_DATA);
         SetIndexBuffer(6,valdd ,INDICATOR_DATA);
         SetIndexBuffer(7,valdu ,INDICATOR_DATA);
   return(INIT_SUCCEEDED);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   static int    prev_i = -1;
   static double prev_hh,prev_hl,prev_ll,prev_lh;
   
   //
   //
   //
   
   int i = prev_calculated; for (; i<rates_total && !_StopFlag; i++)
   {
      if (prev_i != i)
      {
         int start = i-inpChannelPeriod; if (start<0) start=0;
            prev_hh = high[ArrayMaximum(high,start,inpChannelPeriod)];
            prev_hl = low [ArrayMaximum(low ,start,inpChannelPeriod)];
            prev_ll = low [ArrayMinimum(low ,start,inpChannelPeriod)];
            prev_lh = high[ArrayMinimum(high,start,inpChannelPeriod)];
      }         
      valuu[i]=filluu[i]=prev_hh;
      valud[i]=fillud[i]=prev_hl;
      valdd[i]=filldd[i]=prev_ll;
      valdu[i]=filldu[i]=prev_lh;
   }
   return(i);
}
//------------------------------------------------------------------