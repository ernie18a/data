#property copyright "Evgeniy Chumakov | © Copyright 2024"
#property description "Buy and Sell Trading Simulation ZigZag"
#property version "1.0"
#property link "https://www.mql5.com/en/users/jack857752"
#property strict

#property indicator_chart_window
#property indicator_buffers 10
#property indicator_label1 "Buy: Take Profit"
#property indicator_label2 "Buy: Stop Loss"
#property indicator_label3 "Sell: Stop Loss"
#property indicator_label4 "Sell: Take Profit"

input int InpTP = 600; // TP
input int InpSL = 300; // SL

input color InpColor_1 = clrDodgerBlue; // Color Buy
input color InpColor_2 = clrRed; // Color Sell

double ArrayHighZZ_Buy[]; // Maximum price buffer
double ArrayLowZZ_Buy[];  // Minimum price buffer
double ArrayTypeZZ_Buy[]; // The direction of the zigzag
double ArrayHighBarZZ_Buy[]; // Maximum bars buffer
double ArrayLowBarZZ_Buy[]; // Minimum bars buffer

double ArrayHighZZ_Sell[]; // Maximum price buffer
double ArrayLowZZ_Sell[];  // Minimum price buffer
double ArrayTypeZZ_Sell[]; // The direction of the zigzag
double ArrayHighBarZZ_Sell[]; // Maximum bars buffer
double ArrayLowBarZZ_Sell[]; // Minimum bars buffer

//+------------------------------------------------------------------+
int OnInit(){

ArraySetAsSeries(ArrayHighZZ_Buy,true);
ArraySetAsSeries(ArrayLowZZ_Buy,true);
ArraySetAsSeries(ArrayTypeZZ_Buy,true);
ArraySetAsSeries(ArrayHighBarZZ_Buy,true);
ArraySetAsSeries(ArrayLowBarZZ_Buy,true);

ArraySetAsSeries(ArrayHighZZ_Sell,true);
ArraySetAsSeries(ArrayLowZZ_Sell,true);
ArraySetAsSeries(ArrayTypeZZ_Sell,true);
ArraySetAsSeries(ArrayHighBarZZ_Sell,true);
ArraySetAsSeries(ArrayLowBarZZ_Sell,true);

SetIndexBuffer(0,ArrayHighZZ_Buy,INDICATOR_DATA);
SetIndexStyle(0,DRAW_ZIGZAG,STYLE_DOT,1,InpColor_1);
   
SetIndexBuffer(1,ArrayLowZZ_Buy,INDICATOR_DATA);
SetIndexStyle(1,DRAW_ZIGZAG,STYLE_DOT,1,InpColor_1);
 
SetIndexBuffer(2,ArrayHighZZ_Sell,INDICATOR_DATA);
SetIndexStyle(2,DRAW_ZIGZAG,STYLE_DOT,1,InpColor_2);
   
SetIndexBuffer(3,ArrayLowZZ_Sell,INDICATOR_DATA);
SetIndexStyle(3,DRAW_ZIGZAG,STYLE_DOT,1,InpColor_2);
    
SetIndexBuffer(4,ArrayTypeZZ_Buy,INDICATOR_CALCULATIONS);
SetIndexStyle(4,DRAW_NONE,STYLE_SOLID,0,clrNONE);
  
SetIndexBuffer(5,ArrayHighBarZZ_Buy,INDICATOR_CALCULATIONS);
SetIndexStyle(5,DRAW_NONE,STYLE_SOLID,0,clrNONE);

SetIndexBuffer(6,ArrayLowBarZZ_Buy,INDICATOR_CALCULATIONS);
SetIndexStyle(6,DRAW_NONE,STYLE_SOLID,0,clrNONE);

SetIndexBuffer(7,ArrayTypeZZ_Sell,INDICATOR_CALCULATIONS);
SetIndexStyle(7,DRAW_NONE,STYLE_SOLID,0,clrNONE);
  
SetIndexBuffer(8,ArrayHighBarZZ_Sell,INDICATOR_CALCULATIONS);
SetIndexStyle(8,DRAW_NONE,STYLE_SOLID,0,clrNONE);

SetIndexBuffer(9,ArrayLowBarZZ_Sell,INDICATOR_CALCULATIONS);
SetIndexStyle(9,DRAW_NONE,STYLE_SOLID,0,clrNONE);

IndicatorSetInteger(INDICATOR_DIGITS,Digits());
IndicatorSetString(INDICATOR_SHORTNAME,"BuySellZigZag");

return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void OnDeinit(const int reason){

ObjectDelete("Buy: Open");
ObjectDelete("Buy: Take Profit");
ObjectDelete("Buy: Stop Loss");

ObjectDelete("Sell: Open");
ObjectDelete("Sell: Take Profit");
ObjectDelete("Sell: Stop Loss");

return;
}
//+------------------------------------------------------------------+

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
                const int &spread[]){

// Checking for the minimum number of bars to calculate
if(rates_total < 3){return(0);}

// Setting array indexing as in timeseries
ArraySetAsSeries(open,true);
ArraySetAsSeries(high,true);
ArraySetAsSeries(low,true);
ArraySetAsSeries(close,true);

// Checking and calculating the number of calculated bars
int total = rates_total - 2;
int limit = rates_total - IndicatorCounted();

if(limit > 1){

limit = total;

ArrayInitialize(ArrayHighZZ_Buy,EMPTY_VALUE);
ArrayInitialize(ArrayLowZZ_Buy,EMPTY_VALUE);
ArrayInitialize(ArrayTypeZZ_Buy,EMPTY_VALUE);
ArrayInitialize(ArrayHighBarZZ_Buy,EMPTY_VALUE);
ArrayInitialize(ArrayLowBarZZ_Buy,EMPTY_VALUE);

ArrayInitialize(ArrayHighZZ_Sell,EMPTY_VALUE);
ArrayInitialize(ArrayLowZZ_Sell,EMPTY_VALUE);
ArrayInitialize(ArrayTypeZZ_Sell,EMPTY_VALUE);
ArrayInitialize(ArrayHighBarZZ_Sell,EMPTY_VALUE);
ArrayInitialize(ArrayLowBarZZ_Sell,EMPTY_VALUE);
}

// Calculating the indicator
for(int i = limit; i >= 0 && !IsStopped(); i--){

if(i == total){
         
ArrayTypeZZ_Buy[i] = 1;
ArrayLowBarZZ_Buy[i] = i;
ArrayHighBarZZ_Buy[i] = i;

ArrayTypeZZ_Sell[i] = 1;
ArrayLowBarZZ_Sell[i] = i;
ArrayHighBarZZ_Sell[i] = i;

if(close[i] > open[i]){ArrayHighZZ_Buy[i] = ArrayLowZZ_Buy[i] = high[i]; ArrayHighZZ_Sell[i] = ArrayLowZZ_Sell[i] = high[i];}else{ArrayHighZZ_Buy[i] = ArrayLowZZ_Buy[i] = low[i]; ArrayHighZZ_Sell[i] = ArrayLowZZ_Sell[i] = low[i];}
       
}else{
         
ArrayLowBarZZ_Buy[i] = ArrayLowBarZZ_Buy[i + 1];
ArrayHighBarZZ_Buy[i] = ArrayHighBarZZ_Buy[i + 1];
ArrayTypeZZ_Buy[i] = ArrayTypeZZ_Buy[i + 1];
ArrayLowZZ_Buy[i] = EMPTY_VALUE;
ArrayHighZZ_Buy[i] = EMPTY_VALUE;

ArrayLowBarZZ_Sell[i] = ArrayLowBarZZ_Sell[i + 1];
ArrayHighBarZZ_Sell[i] = ArrayHighBarZZ_Sell[i + 1];
ArrayTypeZZ_Sell[i] = ArrayTypeZZ_Sell[i + 1];
ArrayLowZZ_Sell[i] = EMPTY_VALUE;
ArrayHighZZ_Sell[i] = EMPTY_VALUE;

if(close[i] < open[i]){ 

CalculateReferencePoint_Buy(i,high[i],high,low); 
CalculateReferencePoint_Buy(i,low[i],high,low);

CalculateReferencePoint_Sell(i,high[i],high,low); 
CalculateReferencePoint_Sell(i,low[i],high,low);

}else{

CalculateReferencePoint_Buy(i,low[i],high,low);
CalculateReferencePoint_Buy(i,high[i],high,low);

CalculateReferencePoint_Sell(i,low[i],high,low);
CalculateReferencePoint_Sell(i,high[i],high,low);
}

}

} 
// ------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| COLLECTING DATA FROM BUFFERS INTO ARRAYS FOR WORK                |
//+------------------------------------------------------------------+
double ARRAY_OPEN_Buy[];
ArrayResize(ARRAY_OPEN_Buy,0,0);

double ARRAY_OPEN_Sell[];
ArrayResize(ARRAY_OPEN_Sell,0,0);

// let's find the extremes and write them into arrays
for(int bar_pos = 0; bar_pos < iBars(Symbol(),PERIOD_CURRENT); bar_pos++){

double Buf_Max_Buy = ArrayHighZZ_Buy[bar_pos];
double Buf_Min_Buy = ArrayLowZZ_Buy[bar_pos];

double Buf_Max_Sell = ArrayHighZZ_Sell[bar_pos];
double Buf_Min_Sell = ArrayLowZZ_Sell[bar_pos];

// Determining the presence of a Maximum Extreme on a bar
if(Buf_Max_Buy != EMPTY_VALUE && Buf_Min_Buy == EMPTY_VALUE){

ArrayResize(ARRAY_OPEN_Buy,ArraySize(ARRAY_OPEN_Buy) + 1,0);
ArrayFill(ARRAY_OPEN_Buy,ArraySize(ARRAY_OPEN_Buy) - 1,1,Buf_Max_Buy); 
}

if(Buf_Max_Sell != EMPTY_VALUE && Buf_Min_Sell == EMPTY_VALUE){

ArrayResize(ARRAY_OPEN_Sell,ArraySize(ARRAY_OPEN_Sell) + 1,0);
ArrayFill(ARRAY_OPEN_Sell,ArraySize(ARRAY_OPEN_Sell) - 1,1,Buf_Max_Sell); 
}
//-------------------------------------------------------//

// Determining the presence of a Minimum Extreme on a bar
if(Buf_Min_Buy != EMPTY_VALUE && Buf_Max_Buy == EMPTY_VALUE){

ArrayResize(ARRAY_OPEN_Buy,ArraySize(ARRAY_OPEN_Buy) + 1,0);
ArrayFill(ARRAY_OPEN_Buy,ArraySize(ARRAY_OPEN_Buy) - 1,1,Buf_Min_Buy); 
}

if(Buf_Min_Sell != EMPTY_VALUE && Buf_Max_Sell == EMPTY_VALUE){

ArrayResize(ARRAY_OPEN_Sell,ArraySize(ARRAY_OPEN_Sell) + 1,0);
ArrayFill(ARRAY_OPEN_Sell,ArraySize(ARRAY_OPEN_Sell) - 1,1,Buf_Min_Sell); 
}
//-------------------------------------------------------//

}

// Let's Draw ZigZag Level Lines
double Buy_TP = NormalizeDouble(ARRAY_OPEN_Buy[0] + InpTP * Point(),Digits);
double Buy_SL = NormalizeDouble(ARRAY_OPEN_Buy[0] - InpSL * Point(),Digits);

double Sell_TP = NormalizeDouble(ARRAY_OPEN_Sell[0] - InpTP * Point(),Digits);
double Sell_SL = NormalizeDouble(ARRAY_OPEN_Sell[0] + InpSL * Point(),Digits);

string P1_Name = "Buy: Open";

bool P1_Line = ObjectCreate(ChartID(),P1_Name,OBJ_HLINE,0,0,0,0,0);
ObjectSetInteger(ChartID(),P1_Name,OBJPROP_COLOR,InpColor_1);
ObjectSetInteger(ChartID(),P1_Name,OBJPROP_STYLE,STYLE_DOT);
ObjectSetInteger(ChartID(),P1_Name,OBJPROP_WIDTH,1);
ObjectSetInteger(ChartID(),P1_Name,OBJPROP_HIDDEN,false);
ObjectSetDouble(ChartID(),P1_Name,OBJPROP_PRICE1,ARRAY_OPEN_Buy[0]);

string P2_Name = "Buy: Take Profit";

bool P2_Line = ObjectCreate(ChartID(),P2_Name,OBJ_HLINE,0,0,0,0,0);
ObjectSetInteger(ChartID(),P2_Name,OBJPROP_COLOR,InpColor_1);
ObjectSetInteger(ChartID(),P2_Name,OBJPROP_STYLE,STYLE_DOT);
ObjectSetInteger(ChartID(),P2_Name,OBJPROP_WIDTH,1);
ObjectSetInteger(ChartID(),P2_Name,OBJPROP_HIDDEN,false);
ObjectSetDouble(ChartID(),P2_Name,OBJPROP_PRICE1,Buy_TP);

string P3_Name = "Buy: Stop Loss";

bool P3_Line = ObjectCreate(ChartID(),P3_Name,OBJ_HLINE,0,0,0,0,0);
ObjectSetInteger(ChartID(),P3_Name,OBJPROP_COLOR,InpColor_1);
ObjectSetInteger(ChartID(),P3_Name,OBJPROP_STYLE,STYLE_DOT);
ObjectSetInteger(ChartID(),P3_Name,OBJPROP_WIDTH,1);
ObjectSetInteger(ChartID(),P3_Name,OBJPROP_HIDDEN,false);
ObjectSetDouble(ChartID(),P3_Name,OBJPROP_PRICE1,Buy_SL);


string P4_Name = "Sell: Open";

bool P4_Line = ObjectCreate(ChartID(),P4_Name,OBJ_HLINE,0,0,0,0,0);
ObjectSetInteger(ChartID(),P4_Name,OBJPROP_COLOR,InpColor_2);
ObjectSetInteger(ChartID(),P4_Name,OBJPROP_STYLE,STYLE_DOT);
ObjectSetInteger(ChartID(),P4_Name,OBJPROP_WIDTH,1);
ObjectSetInteger(ChartID(),P4_Name,OBJPROP_HIDDEN,false);
ObjectSetDouble(ChartID(),P4_Name,OBJPROP_PRICE1,ARRAY_OPEN_Sell[0]);

string P5_Name = "Sell: Take Profit";

bool P5_Line = ObjectCreate(ChartID(),P5_Name,OBJ_HLINE,0,0,0,0,0);
ObjectSetInteger(ChartID(),P5_Name,OBJPROP_COLOR,InpColor_2);
ObjectSetInteger(ChartID(),P5_Name,OBJPROP_STYLE,STYLE_DOT);
ObjectSetInteger(ChartID(),P5_Name,OBJPROP_WIDTH,1);
ObjectSetInteger(ChartID(),P5_Name,OBJPROP_HIDDEN,false);
ObjectSetDouble(ChartID(),P5_Name,OBJPROP_PRICE1,Sell_TP);

string P6_Name = "Sell: Stop Loss";

bool P6_Line = ObjectCreate(ChartID(),P6_Name,OBJ_HLINE,0,0,0,0,0);
ObjectSetInteger(ChartID(),P6_Name,OBJPROP_COLOR,InpColor_2);
ObjectSetInteger(ChartID(),P6_Name,OBJPROP_STYLE,STYLE_DOT);
ObjectSetInteger(ChartID(),P6_Name,OBJPROP_WIDTH,1);
ObjectSetInteger(ChartID(),P6_Name,OBJPROP_HIDDEN,false);
ObjectSetDouble(ChartID(),P6_Name,OBJPROP_PRICE1,Sell_SL);
//-------------------------------------------------------------------+

return(rates_total);
}
//+------------------------------------------------------------------+
//| Calculation of the top point / Mode Buy                          |
//+------------------------------------------------------------------+
void HighZZPoint_Buy(const int index,const double price,const double &high[]){

int last_bar = (int)ArrayHighBarZZ_Buy[index];
   
if(ArrayHighZZ_Buy[last_bar] == EMPTY_VALUE){ArrayHighZZ_Buy[last_bar] = high[last_bar];}
   
// Price deviation from the last extreme
double Step = MathAbs(price - ArrayHighZZ_Buy[last_bar])/Point();
   
// Price continues to move / update the previous extreme 
if(price > ArrayHighZZ_Buy[last_bar] && Step >= InpTP){
ArrayHighZZ_Buy[last_bar] = EMPTY_VALUE;
ArrayHighZZ_Buy[index] = price;
ArrayHighBarZZ_Buy[index] = index;
last_bar = index;
}

// The price turned around and formed the opposite extreme
if(price < ArrayHighZZ_Buy[last_bar] && MathAbs(index - last_bar) >= 1 && Step >= InpSL){
ArrayTypeZZ_Buy[index] = -1;
ArrayLowZZ_Buy[index] = price;
ArrayLowBarZZ_Buy[index] = index;
}

return;
}
//+------------------------------------------------------------------+
//| Calculating the bottom point / Mode Buy                          |
//+------------------------------------------------------------------+
void LowZZPoint_Buy(const int index,const double price,const double &low[]){
   
int last_bar = (int)ArrayLowBarZZ_Buy[index];
   
if(ArrayLowZZ_Buy[last_bar] == EMPTY_VALUE){ArrayLowZZ_Buy[last_bar] = low[last_bar];}

// Price deviation from the last extreme
double Step = MathAbs(price - ArrayLowZZ_Buy[last_bar])/Point();

// Price continues to move / update the previous extreme    
if(price < ArrayLowZZ_Buy[last_bar] && Step >= InpSL){     
ArrayLowZZ_Buy[last_bar] =  EMPTY_VALUE;
ArrayLowZZ_Buy[index] = price;
ArrayLowBarZZ_Buy[index] = index;
last_bar = index;
}
 
// The price turned around and formed the opposite extreme
if(price > ArrayLowZZ_Buy[last_bar] && MathAbs(index - last_bar) >= 1 && Step >= InpTP){
ArrayTypeZZ_Buy[index] = 1;
ArrayHighZZ_Buy[index] = price;
ArrayHighBarZZ_Buy[index] = index;
}  

return;
}
//+------------------------------------------------------------------+
//| Calculation of reference points  / Mode Buy                      |
//+------------------------------------------------------------------+
void CalculateReferencePoint_Buy(const int index,const double price,const double &high[],const double &low[]){

if(ArrayTypeZZ_Buy[index] == 1){HighZZPoint_Buy(index,price,high);}else{LowZZPoint_Buy(index,price,low);}
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Calculation of the top point / Mode Sell                         |
//+------------------------------------------------------------------+
void HighZZPoint_Sell(const int index,const double price,const double &high[]){

int last_bar = (int)ArrayHighBarZZ_Sell[index];
   
if(ArrayHighZZ_Sell[last_bar] == EMPTY_VALUE){ArrayHighZZ_Sell[last_bar] = high[last_bar];}
   
// Price deviation from the last extreme   
double Step = MathAbs(price - ArrayHighZZ_Sell[last_bar])/Point();
   
// Price continues to move / update the previous extreme   
if(price > ArrayHighZZ_Sell[last_bar] && Step >= InpSL){
ArrayHighZZ_Sell[last_bar] = EMPTY_VALUE;
ArrayHighZZ_Sell[index] = price;
ArrayHighBarZZ_Sell[index] = index;
last_bar = index;
}

// The price turned around and formed the opposite extreme
if(price < ArrayHighZZ_Sell[last_bar] && MathAbs(index - last_bar) >= 1 && Step >= InpTP){
ArrayTypeZZ_Sell[index] = -1;
ArrayLowZZ_Sell[index] = price;
ArrayLowBarZZ_Sell[index] = index;
}

return;
}
//+------------------------------------------------------------------+
//| Calculating the bottom point / Mode Sell                         |
//+------------------------------------------------------------------+
void LowZZPoint_Sell(const int index,const double price,const double &low[]){
   
int last_bar = (int)ArrayLowBarZZ_Sell[index];
   
if(ArrayLowZZ_Sell[last_bar] == EMPTY_VALUE){ArrayLowZZ_Sell[last_bar] = low[last_bar];}

// Price deviation from the last extreme
double Step = MathAbs(price - ArrayLowZZ_Sell[last_bar])/Point();

// Price continues to move / update the previous extreme   
if(price < ArrayLowZZ_Sell[last_bar] && Step >= InpTP){     
ArrayLowZZ_Sell[last_bar] =  EMPTY_VALUE;
ArrayLowZZ_Sell[index] = price;
ArrayLowBarZZ_Sell[index] = index;
last_bar = index;
}
 
// The price turned around and formed the opposite extreme
if(price > ArrayLowZZ_Sell[last_bar] && MathAbs(index - last_bar) >= 1 && Step >= InpSL){
ArrayTypeZZ_Sell[index] = 1;
ArrayHighZZ_Sell[index] = price;
ArrayHighBarZZ_Sell[index] = index;
}  

return;
}
//+------------------------------------------------------------------+
//| Calculation of reference points  / Mode Sell                     |
//+------------------------------------------------------------------+
void CalculateReferencePoint_Sell(const int index,const double price,const double &high[],const double &low[]){

if(ArrayTypeZZ_Sell[index] == 1){HighZZPoint_Sell(index,price,high);}else{LowZZPoint_Sell(index,price,low);}
}
//+------------------------------------------------------------------+