//+------------------------------------------------------------------+
//|                                         Intrabar Tick Volume.mq5 |
//|                            Copyright phade 2025, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.01"
#property description "Incoming tick volume in a rolling histogram format"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots 1

#property indicator_color1 clrGreen, clrRed
#property indicator_type1 DRAW_COLOR_HISTOGRAM

double plot[];
double col[];
double incomingVolume[];

double ma[];
double closes[];


input bool granularTrend = false; // Granular trend

int period = 20;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
  SetIndexBuffer(0, plot, INDICATOR_DATA);
  SetIndexBuffer(1, col,  INDICATOR_COLOR_INDEX);
  SetIndexBuffer(2, ma, INDICATOR_CALCULATIONS);
  SetIndexBuffer(3, incomingVolume, INDICATOR_CALCULATIONS);
  SetIndexBuffer(4, closes, INDICATOR_CALCULATIONS); 
  
  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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

  int buffSize = ArraySize(incomingVolume);
  
  ArrayCopy(incomingVolume, tick_volume, 0, rates_total-1);
  ArrayCopy(closes, close, 0, rates_total-1);
  
  long volumeThreshold = 0;
  long sum = 0;

  if(prev_calculated == 0){  initialzeBuffers();
  }
  for (int j = buffSize - 20; j < buffSize; j++) sum += tick_volume[j];

  volumeThreshold = sum / 20;
   
  int empty_data = rates_total - buffSize; 
  int start = rates_total - 2;
   
  for(int i = buffSize-1; i>=empty_data; i--){
  
      plot[i] = (buffSize - i > 0) ? incomingVolume[buffSize - i - 1] : 0;      
      
      if (granularTrend) trend(period, i, ma, closes, buffSize); else trend(period, i, ma, close, buffSize);
            
      if (i > 1){ 
             if (granularTrend){ col[i] = (tick_volume[i] >= volumeThreshold && ma[buffSize - i] > ma[buffSize - i - 1]) ? 0 : 1; 
             }
             else { col[i] = ma[buffSize - 1] > ma[buffSize - 2] ? 0 : 1;  
             }
          }
      
  } 
  shift(incomingVolume); shift(col); shift(closes); shift(ma);  
  
  return buffSize;
}


void initialzeBuffers(){

  ArrayInitialize(plot, EMPTY_VALUE); 
  ArrayInitialize(col, EMPTY_VALUE); 
  ArrayInitialize(ma, EMPTY_VALUE); 
  ArrayInitialize(incomingVolume, EMPTY_VALUE); 
  ArrayInitialize(closes, EMPTY_VALUE);
}

void shift(double &arr[])
{
  ArrayCopy(arr, arr, 1, 0, ArraySize(arr));
}

void trend(int per, int idx, double &arr[], const double &close[], int buffsize)
{
  double sum = 0.0;

  for(int j = 1; j < per && (idx - j)>0; j++)
    sum += close[idx-j];

  arr[idx] = sum / per;
}


