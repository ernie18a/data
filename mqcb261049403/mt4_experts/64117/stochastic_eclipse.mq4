#property copyright     "Trade Smart FX Tools"
#property link          "https://tradesmartfxtools.in/"
#property version       "1.00"
#property strict

#property description   "This Expert Advisor opens orders when the Stochastic oscillator passes one of the thresholds"

/*
ENTRY BUY: when the fast MA crosses the slow from the bottom, both MA are going up
ENTRY SELL: when the fast MA crosses the slow from the top, both MA are going down
EXIT: When Stop Loss or Take Profit are reached or, reaching the upper threshold for buy orders and reaching the lower threshold for sell orders
Only 1 order at a time
*/


extern double LotSize=0.1;             //Position size

extern double StopLoss=100;             //Stop loss in pips
extern double TakeProfit=100;           //Take profit in pips

extern int Slippage=10;                 //Slippage in pips

extern bool TradeEnabled=true;         //Enable trade

extern int StochK=5;                   //Stochastic K Period, default 5
extern int StochD=3;                   //Stochastic D Period, default 3
extern int StochSlowing=3;              //Stochastic Slowing, default 3

extern int UpperThreshold=80;          //Upper Threshold, default 80
extern int LowerThreShold=20;          //Lower Threshold, default 20

//Functional variables
double ePoint;                         //Point normalized

bool CanOrder;                         //Check for risk management
bool CanOpenBuy;                       //Flag if there are buy orders open
bool CanOpenSell;                      //Flag if there are sell orders open

int OrderOpRetry=10;                   //Number of attempts to perform a trade operation
int SleepSecs=3;                       //Seconds to sleep if can't order
int MinBars=60;                        //Minimum bars in the graph to enable trading

//Functional variables to determine prices
double MinSL;
double MaxSL;
double TP;
double SL;
double Spread;
int Slip; 


//Variable initialization function
void Initialize(){          
   RefreshRates();
   ePoint=Point;
   Slip=Slippage;
   if (MathMod(Digits,2)==1){
      ePoint*=10;
      Slip*=10;
   }
   TP=TakeProfit*ePoint;
   SL=StopLoss*ePoint;
   CanOrder=TradeEnabled;
   CanOpenBuy=true;
   CanOpenSell=true;
}


//Check if orders can be submitted
void CheckCanOrder(){            
   if( Bars<MinBars ){
      Print("INFO - Not enough Bars to trade");
      CanOrder=false;
   }
   OrdersOpen();
   return;
}


//Check if there are open orders and what type
void OrdersOpen(){
   for( int i = 0 ; i < OrdersTotal() ; i++ ) {
      if( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) == false ) {
         Print("ERROR - Unable to select the order - ",GetLastError());
         break;
      } 
      if( OrderSymbol()==Symbol() && OrderType() == OP_BUY) CanOpenBuy=false;
      if( OrderSymbol()==Symbol() && OrderType() == OP_SELL) CanOpenSell=false;
   }
   return;
}


//Close all the orders of a specific type and current symbol
void CloseAll(int Command){
   double ClosePrice=0;
   for( int i = 0 ; i < OrdersTotal() ; i++ ) {
      if( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) == false ) {
         Print("ERROR - Unable to select the order - ",GetLastError());
         break;
      }
      if( OrderSymbol()==Symbol() && OrderType()==Command) {
         if(Command==OP_BUY) ClosePrice=Bid;
         if(Command==OP_SELL) ClosePrice=Ask;
         double Lots=OrderLots();
         int Ticket=OrderTicket();
         for(int j=1; j<OrderOpRetry; j++){
            bool res=OrderClose(Ticket,Lots,ClosePrice,Slip,Red);
            if(res){
               Print("TRADE - CLOSE - Order ",Ticket," closed at price ",ClosePrice);
               break;
            }
            else Print("ERROR - CLOSE - error closing order ",Ticket," return error: ",GetLastError());
         }
      }
   }
   return;
}


//Open new order of a given type
void OpenNew(int Command){

// --- Validate lot size
string volMsg="";
if(!CheckVolumeValue(LotSize, volMsg))
  {
   Print("ERROR - VOLUME - ", volMsg, " | Requested LotSize=", DoubleToString(LotSize, 2));
   return; // stop here if invalid
  }


   RefreshRates();
   double OpenPrice=0;
   double SLPrice = 0;
   double TPPrice = 0;
   if(Command==OP_BUY){
      OpenPrice=Ask;
      SLPrice=OpenPrice-SL;
      TPPrice=OpenPrice+TP;
   }
   if(Command==OP_SELL){
      OpenPrice=Bid;
      SLPrice=OpenPrice+SL;
      TPPrice=OpenPrice-TP;
   }
   for(int i=1; i<OrderOpRetry; i++){
      int res=OrderSend(Symbol(),Command,LotSize,OpenPrice,Slip,NormalizeDouble(SLPrice,Digits),NormalizeDouble(TPPrice,Digits),"",0,0,Green);
      if(res){
         Print("TRADE - NEW - Order ",res," submitted: Command ",Command," Volume ",LotSize," Open ",OpenPrice," Slippage ",Slip," Stop ",SLPrice," Take ",TPPrice);
         break;
      }
      else Print("ERROR - NEW - error sending order, return error: ",GetLastError());
   }
   return;
}


//Technical analysis of the indicators
bool CrossToOpenBuy=false;
bool CrossToOpenSell=false;
bool CrossToCloseBuy=false;
bool CrossToCloseSell=false;


void CheckStochCross(){
   CrossToOpenBuy=false;
   CrossToOpenSell=false;
   CrossToCloseBuy=false;
   CrossToCloseSell=false;
   double StochPrev=iStochastic(Symbol(),0,StochK,StochD,StochSlowing,MODE_SMA,STO_LOWHIGH,MODE_BASE,1);
   double StochCurr=iStochastic(Symbol(),0,StochK,StochD,StochSlowing,MODE_SMA,STO_LOWHIGH,MODE_BASE,0);
   if(StochPrev<LowerThreShold && StochCurr>LowerThreShold){
      CrossToOpenBuy=true;
   }
   if(StochPrev>UpperThreshold && StochCurr<UpperThreshold){
      CrossToOpenSell=true;
   }
   if(StochCurr>UpperThreshold){
      CrossToCloseBuy=true;
   }
   if(StochCurr<LowerThreShold){
      CrossToCloseSell=true;
   }
}


// ===== Signature Label Inputs =====
extern bool  ShowSignature   = true;
extern ENUM_BASE_CORNER SigCorner = CORNER_LEFT_LOWER; // choose the corner
extern int   SigX            = 10;   // margin from the chosen corner (X)
extern int   SigY            = 50;   // margin from the chosen corner (Y)
extern int   SigFontSize     = 18;   // font size
extern color SigColor        = clrYellow; // text color

// Optional background/border behind the text
extern bool  SigBg           = false;      // set true to show background box
extern color SigBgColor      = clrBlack;   // box fill
extern color SigBorderColor  = clrYellow;  // box border
extern int   SigBgWidth      = 310;        // box width (tweak as you like)
extern int   SigBgHeight     = 28;         // box height
extern int   SigBgPaddingX   = 8;          // left/right padding for box vs text
extern int   SigBgPaddingY   = 4;          // top/bottom padding

#define SIG_LABEL "TSFXT_Signature_Label"
#define SIG_BG    "TSFXT_Signature_BG"

// Create/update the signature objects
void EnsureSignature()
{
   if(!ShowSignature)
   {
      ObjectDelete(0, SIG_LABEL);
      ObjectDelete(0, SIG_BG);
      return;
   }

   // Background box (optional)
   if(SigBg)
   {
      if(ObjectFind(0, SIG_BG) != 0)
         ObjectCreate(0, SIG_BG, OBJ_RECTANGLE_LABEL, 0, 0, 0);

      ObjectSetInteger(0, SIG_BG, OBJPROP_CORNER,     SigCorner);
      ObjectSetInteger(0, SIG_BG, OBJPROP_XDISTANCE,  MathMax(0, SigX - SigBgPaddingX));
      ObjectSetInteger(0, SIG_BG, OBJPROP_YDISTANCE,  MathMax(0, SigY - SigBgPaddingY));
      ObjectSetInteger(0, SIG_BG, OBJPROP_BGCOLOR,    SigBgColor);
      ObjectSetInteger(0, SIG_BG, OBJPROP_COLOR,      SigBorderColor);
      ObjectSetInteger(0, SIG_BG, OBJPROP_BACK,       true);
      ObjectSetInteger(0, SIG_BG, OBJPROP_WIDTH,      SigBgWidth);
      ObjectSetInteger(0, SIG_BG, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, SIG_BG, OBJPROP_HIDDEN,     true);
   }
   else
   {
      ObjectDelete(0, SIG_BG);
   }

   // Text label
   if(ObjectFind(0, SIG_LABEL) != 0)
      ObjectCreate(0, SIG_LABEL, OBJ_LABEL, 0, 0, 0);

   ObjectSetInteger(0, SIG_LABEL, OBJPROP_CORNER,     SigCorner);
   ObjectSetInteger(0, SIG_LABEL, OBJPROP_XDISTANCE,  SigX);
   ObjectSetInteger(0, SIG_LABEL, OBJPROP_YDISTANCE,  SigY);
   ObjectSetString (0, SIG_LABEL, OBJPROP_TEXT,       "created by tradesmartfxtools.in");
   ObjectSetInteger(0, SIG_LABEL, OBJPROP_FONTSIZE,   SigFontSize);
   ObjectSetString (0, SIG_LABEL, OBJPROP_FONT,       "Arial");
   ObjectSetInteger(0, SIG_LABEL, OBJPROP_COLOR,      SigColor);
   ObjectSetInteger(0, SIG_LABEL, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, SIG_LABEL, OBJPROP_HIDDEN,     true);
}



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
     EnsureSignature();  
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- 
 EnsureSignature();  
   //Calling initialization, checks and technical analysis
   Initialize();
   CheckCanOrder();
   CheckStochCross();
   //Check of Entry/Exit signal with operations to perform
   if(CrossToCloseBuy) CloseAll(OP_BUY);
   if(CrossToCloseSell) CloseAll(OP_SELL);
   if(CrossToOpenBuy){
      if(CanOpenBuy && CanOrder) OpenNew(OP_BUY);
   }
   if(CrossToOpenSell){
      if(CanOpenSell && CanOrder) OpenNew(OP_SELL);
   }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &description)
  {
//--- minimal allowed volume for trade operations
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
     {
      description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }

//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                               volume_step,ratio*volume_step);
      return(false);
     }
   description="Correct volume value";
   return(true);
  }