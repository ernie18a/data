//+------------------------------------------------------------------+
//|                                              Blue Renko Bars.mq5 |
//+------------------------------------------------------------------+
#property copyright     "© SharmuttaDJ, 2018"
#property link          "https://www.mql5.com/ru/users/sharmuttadj/"
#property version       "1.00"
#property description   "Simplest Renko Chart Indicator for MetaTrader 5"

// indicator settings
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1

// plot Renko
#property indicator_label1  "Open;High;Low;Close"
#property indicator_type1   DRAW_CANDLES
#property indicator_color1  clrDodgerBlue,clrDeepSkyBlue,clrBlack
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

// indicator inputs
input int  BrickSize    =10;     //Brick Size
input bool ShowWicks    = true;  //Show Wicks
input bool TotalBars    = false; //Use full history

int   RedrawChart = 1;           // Redraw Renko Chart Bars
int   BarsCount   = 500;         // Bars Count

                                 // indicator buffers
double         OpenBuffer[];
double         HighBuffer[];
double         LowBuffer[];
double         CloseBuffer[];
double         brickColors[];
MqlRates       renkoBuffer[];

double         brickSize,upWick,downWick;

// total count of bars
int total=Bars(_Symbol,PERIOD_M1);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
// Renko brick size
   brickSize=BrickSize*_Point;
// Minimum brick size
   if(brickSize<_Point*1)
     {
      brickSize=_Point*1;
      Print("Brick size must be a minimum value of ",brickSize);
     }

//--- optimal bars count ------
   if(TotalBars==true)
      BarsCount=total;
   else if(brickSize>1)
     {
      BarsCount=(int)BarsCount *(int)brickSize;
     }

//-------------------------------------------------------
   brickSize=NormalizeDouble(brickSize,_Digits);
// Buffer mapping
   SetIndexBuffer(0,OpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,HighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,LowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,CloseBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,brickColors,INDICATOR_COLOR_INDEX);
// Array series
   ArraySetAsSeries(OpenBuffer,true);
   ArraySetAsSeries(HighBuffer,true);
   ArraySetAsSeries(LowBuffer,true);
   ArraySetAsSeries(CloseBuffer,true);
   ArraySetAsSeries(brickColors,true);
   ArraySetAsSeries(renkoBuffer,true);
// Levels
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   IndicatorSetInteger(INDICATOR_LEVELS,1);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,STYLE_SOLID);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
// Title
   string title="-=BLUErenkoBARS=- (";
   title+="["+(string) BrickSize+" Pips])";
   IndicatorSetString(INDICATOR_SHORTNAME,title);
//
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,      // size of input time series
                 const int prev_calculated,  // bars handled on a previous call
                 const datetime& time[],     // Time
                 const double& open[],       // Open
                 const double& high[],       // High
                 const double& low[],        // Low
                 const double& close[],      // Close
                 const long& tick_volume[],  // Volume Tick
                 const long& volume[],       // Volume Real
                 const int& spread[]         // Spread
                 )
  {
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

   int size=ArraySize(renkoBuffer);

// Calculate once
   if(size==0)
     {
      MqlRates m1Buffer[];
      ArraySetAsSeries(m1Buffer,true);
      total=CopyRates(_Symbol,PERIOD_M1,0,BarsCount,m1Buffer);

      // Fail
      if(total<0)
        {
         Comment("Failed to copy history data for the M1 time frame. Error #",_LastError,". Retry...");
         return(0);
        }

      // Start
      Comment("Reading history... 0% [0 of ",total,"]");

      // Fill Renko history based on M1 OHLC data
      double gap,up,down,progress;
      for(int i=total-2;i>=0;i--)
        {
         gap= MathAbs(m1Buffer[i].open-m1Buffer[i+1].close);
         up = m1Buffer[i].high-MathMax(m1Buffer[i].open,m1Buffer[i].close);
         down=MathMin(m1Buffer[i].open,m1Buffer[i].close)-m1Buffer[i].low;
         // Renko bricks
         if(gap>brickSize) Renko(m1Buffer[i].open);
         // If positive candle, Lo-Hi
         if(m1Buffer[i].open<m1Buffer[i].close)
           {
            if(down>brickSize) Renko(m1Buffer[i].low);
            if(up>brickSize) Renko(m1Buffer[i].high);
              } else { //Else Hi-Lo
            if(up>brickSize) Renko(m1Buffer[i].high);
            if(down>brickSize) Renko(m1Buffer[i].low);
           }
         Renko(m1Buffer[i].close);
         // Progress
         progress= 100-i * 100/total;
         if(i%50 == 0) Comment("Reading history... ",progress,"% [",total-i," of ",total,"]");
        }
      Comment("");
     }

// Current tick
   Renko(close[0]);
   size=ArraySize(renkoBuffer);

//----------------------------------------------------------------------
// Calculation of the starting number 'first' for the cycle of recalculation of bars

   int first;
   if(prev_calculated==0) // checking for the first start of the indicator calculation
     {
      first=(rates_total>size) ? size: rates_total; // starting number for calculation of all bars
     }
   else
     {
      first=int(MathMax(RedrawChart,ChartGetInteger(0,CHART_VISIBLE_BARS,0))); // minimum of visible chart bars
     }

   for(int i=first-2; i>=0; i--)
     {
      OpenBuffer[i+1] = renkoBuffer[i].open;
      HighBuffer[i+1] = renkoBuffer[i].high;
      LowBuffer[i+1]=renkoBuffer[i].low;
      CloseBuffer[i+1]=renkoBuffer[i].close;
      brickColors[i+1]=(renkoBuffer[i].close>renkoBuffer[i+1].close) ? 1 : 0;
      if(i==0)
        {
         OpenBuffer[i] = renkoBuffer[i].close;
         HighBuffer[i] = upWick;
         LowBuffer[i]=downWick;
         CloseBuffer[i]=close[i];
         brickColors[i]=brickColors[i+1];
        }
     }

// Indicator level
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,close[0]);
// Return
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Add one slot to array series and shift 1                         |
//+------------------------------------------------------------------+
void RenkoAdd()
  {
   int size=ArraySize(renkoBuffer);
   ArrayResize(renkoBuffer,size+1,10000);
   ArrayCopy(renkoBuffer,renkoBuffer,1,0,size);
  }
//+------------------------------------------------------------------+
//| Add a up renko bar                                               |
//+------------------------------------------------------------------+
void RenkoUp(double points)
  {
   RenkoAdd();
   renkoBuffer[0].open = renkoBuffer[1].close + points - brickSize;
   renkoBuffer[0].high = renkoBuffer[1].close + points;
   renkoBuffer[0].low=renkoBuffer[1].close;
   if(ShowWicks && downWick<renkoBuffer[1].close) renkoBuffer[0].low=downWick;
   else renkoBuffer[0].low=renkoBuffer[0].open;
   renkoBuffer[0].close=renkoBuffer[1].close+points;
   upWick=downWick=renkoBuffer[0].close;
  }
//+------------------------------------------------------------------+
//| Add a down renko bar                                             |
//+------------------------------------------------------------------+
void RenkoDown(double points)
  {
   RenkoAdd();
   renkoBuffer[0].open=renkoBuffer[1].close-points+brickSize;
   if(ShowWicks && upWick>renkoBuffer[1].close) renkoBuffer[0].high=upWick;
   else renkoBuffer[0].high=renkoBuffer[0].open;
   renkoBuffer[0].low=renkoBuffer[1].close-points;
   renkoBuffer[0].close=renkoBuffer[1].close-points;
   upWick=downWick=renkoBuffer[0].close;
  }
//+------------------------------------------------------------------+
//| Add renko bars                                                   |
//+------------------------------------------------------------------+
void Renko(double price)
  {

   int size=ArraySize(renkoBuffer);

   upWick=MathMax(upWick,price);
   downWick=MathMin(downWick,price);

   if(size==0)
     {
      // First brick
      RenkoAdd();
      renkoBuffer[0].high=renkoBuffer[0].close=NormalizeDouble(MathFloor(price/brickSize)*brickSize,_Digits);
      renkoBuffer[0].open=renkoBuffer[0].low=renkoBuffer[0].close - brickSize;
     }
   else if(size<2)
     {
      // Up
      for(; price>renkoBuffer[0].close+brickSize;)
         RenkoUp(brickSize);
      // Down
      for(; price<renkoBuffer[0].close-brickSize;)
         RenkoDown(brickSize);
     }
   else
     {
      // Up
      if(renkoBuffer[0].close>renkoBuffer[1].close)
        {
         if(price>renkoBuffer[0].close+brickSize)
           {
            for(; price>renkoBuffer[0].close+brickSize;)
               RenkoUp(brickSize);
           }
         // Down 2x
         else if(price<renkoBuffer[0].close-2*brickSize)
           {
            RenkoDown(2*brickSize);
            for(; price<renkoBuffer[1].close-brickSize;)
               RenkoDown(brickSize);
           }
        }
      // Down
      if(renkoBuffer[0].close<renkoBuffer[1].close)
        {
         if(price<renkoBuffer[0].close-brickSize)
           {
            for(; price<renkoBuffer[0].close-brickSize;)
               RenkoDown(brickSize);
           }
         // Up 2x
         else if(price>renkoBuffer[0].close+2*brickSize)
           {
            RenkoUp(2*brickSize);
            for(; price>renkoBuffer[0].close+brickSize;)
               RenkoUp(brickSize);
           }
        }
     }
   return;
  }
//+------------------------------------------------------------------+
