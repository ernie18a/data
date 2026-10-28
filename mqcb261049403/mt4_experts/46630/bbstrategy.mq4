//+------------------------------------------------------------------+
//|                                                   BBStrategy.mq4 |
//|                                       Copyright 2023, Los Group. |
//|                https://www.mql5.com/en/users/lothimailoan/seller |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Los Group."
#property link      "https://www.mql5.com/en/users/lothimailoan/seller"
#property version   "1.00"
#property strict

//--- input parameters
input int      BB_KIKAN=20;  // BB period
input double   Lots=0.01;   // Lots size
input int      SL=220;  // stop loss points
input int      TP=220;  // take profit points

double waitBB;
datetime prevtime;

int orderPtn=0; // 0: Do nothing, 1: Buy, 2: Sell
int total=0;

int errorcode;  //error code
int ea_ticket_No,ea_order_entry_Type=0,ea_order_MagicNo;
double ea_order_stop_price=0,ea_order_good_price=0,ea_order_entry_price=0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
//---

//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnTick() {

// Get the values of Bollinger Bands
   double BB3UP = iBands(NULL, 0, BB_KIKAN, 3, 0, PRICE_CLOSE, MODE_UPPER, 0); // 3σ upper
   double BB3LO = iBands(NULL, 0, BB_KIKAN, 3, 0, PRICE_CLOSE, MODE_LOWER, 0); // 3σ lower

   double BB2UP = iBands(NULL, 0, BB_KIKAN, 2, 0, PRICE_CLOSE, MODE_UPPER, 0); // 2σ upper
   double BB2LO = iBands(NULL, 0, BB_KIKAN, 2, 0, PRICE_CLOSE, MODE_LOWER, 0); // 2σ lower

//*** Buy/Sell Conditions ***//
   if (BB3UP < Ask) {
      orderPtn = 1; // Buy when Ask price crosses above 3σ BB
   } else if (BB3LO > Bid) {
      orderPtn = 2; // Sell when Bid price crosses below 3σ BB
   } else {
      orderPtn = 0; // Do nothing in other cases
   }

// If in a Buy or Buy-wait state
   if ((orderPtn == 1) || (waitBB > 0)) {
// Buy within BB2 range
      if ((BB2UP > Ask) && (BB2LO < Bid)) {
         orderPtn = 1;
         waitBB = 0;
      } else {
         orderPtn = 0;
         waitBB = 1;
      }
   }

// If in a Sell or Sell-wait state
   if ((orderPtn == 2) || (waitBB < 0)) {
// Sell within 2σ BB range
      if ((BB2LO < Bid) && (BB2UP > Ask)) {
         orderPtn = 2;
         waitBB = 0;
      } else {
         orderPtn = 0;
         waitBB = -1;
      }
   }

//***Trading Decision point***//

   total = OrdersTotal();

   if (total == 1) {
// Already have an open order, do nothing
      waitBB = 0;
   }
//*** Open Orders ***//
   else if ((total == 0) && (orderPtn > 0)) {
      if (orderPtn == 1) {
         ea_order_entry_price = Ask; //Enter at the current Ask price
         ea_order_entry_Type = OP_BUY; // OP_BUY
         ea_order_stop_price = Ask - SL * Point; //Stop loss point
         ea_order_good_price = Ask + TP * Point; //Take profit point
      }

      else if (orderPtn == 2) {
         ea_order_entry_price = Bid; // Entry at the current  price
         ea_order_entry_Type = OP_SELL; // OP_SELL
         ea_order_stop_price = Bid + SL * Point; //Stop loss point
         ea_order_good_price = Bid - TP * Point; //Take profit point
      }

      ea_order_MagicNo = 0000; //magit number is fixed at value 0000
// new entry order
      string s = "";
      if (!CheckVolumeValue(Lots,s)) return;
      ea_ticket_No = OrderSend(
                        NULL,                //Currency pair
                        ea_order_entry_Type, // Order type [OP_BUY / OP_SELL]
                        Lots,                //Lots (in increments of 0.01, FXTF uses 1=10Lot)
                        ea_order_entry_price,//Order price rate
                        20,                  // Slippage limit
                        ea_order_stop_price, //Stop-loss rate
                        ea_order_good_price, // Take profit rate
                        "Test Order",        // Order comment
                        ea_order_MagicNo,    // Magic number (for identification)
                        0,                   // pending order expiration
                        clrRed               // Order icon color
                     );

// Check for order error
      if (ea_ticket_No == -1) {
         errorcode = GetLastError();      // Get error code
         if (errorcode != ERR_NO_ERROR) { // Error occurred
            printf("Error");
         }
      } else {
// Order executed
         Print("New order executed. Ticket No=", ea_ticket_No);
      }
   }

}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &description) {
//--- minimal allowed volume for trade operations
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<min_volume) {
      description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
   }

//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>max_volume) {
      description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
   }

//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001) {
      description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                               volume_step,ratio*volume_step);
      return(false);
   }
   description="Correct volume value";
   return(true);
}
