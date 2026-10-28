//+------------------------------------------------------------------+
//|                                               Moving Average.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Los Group"
#property link      "https://www.mql5.com/en/users/lothimailoan/seller"
#property version   "1.00"
#property strict

input int      FasterMA = 21;    // Medium Moving Average period
input int      MediumMA = 84;    // Slow Moving Average period
input int      Spread   = 20;    // Alow max spread in points
input double   Lots     = 0.01;  // Fixed Lots
input int      Stoploss = 60;    // Stop loss in points

int MAShift =    0;
int MAMode  =    1;              // 0 = sma, 1 = ema, 2 = smma, 3 = lwma

double Lotsize=0.01;
datetime prevtime;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
   int orderPtn=0; //1-buy, 2-sell
   int total=0;

   double ea_order_stop_price=0,ea_order_good_price=0;
   bool OrderKekka;

   //check new bars
   if(Time[0] != prevtime) {
      prevtime = Time[0];
   } else {
      return;
   }

   //Check buy sell conditions//

   //----  Fast MA value
   double fasterMA_ATAI_1   = iMA(NULL, 0, FasterMA, MAShift, MAMode, PRICE_CLOSE, 1);
   double fasterMA_ATAI_2   = iMA(NULL, 0, FasterMA, MAShift, MAMode, PRICE_CLOSE, 2);

   //---- Medium MA value
   double MediumMA_ATAI_1   = iMA(NULL, 0, MediumMA, MAShift, MAMode, PRICE_CLOSE, 1);
   double MediumMA_ATAI_2   = iMA(NULL, 0, MediumMA, MAShift, MAMode, PRICE_CLOSE, 2);


   // Check Golden Cross for BUY Signal
   if(fasterMA_ATAI_1 > MediumMA_ATAI_1 && fasterMA_ATAI_2 < MediumMA_ATAI_2 && fasterMA_ATAI_1 > fasterMA_ATAI_2) {
      orderPtn=1;
   }
   // Check Dead Cross for SELL Signal
   else if(fasterMA_ATAI_1 < MediumMA_ATAI_1 && fasterMA_ATAI_2 > MediumMA_ATAI_2 && fasterMA_ATAI_1 < fasterMA_ATAI_2) {
      orderPtn=2;
   } else {
      orderPtn=0;   // nothing
   }


   // Entry, Stoploss, TakeProfit and Exit Order
   total=OrdersTotal();
   if(total ==0 && orderPtn > 0) {
      if(orderPtn == 1) { // BUY
         ea_order_stop_price = MediumMA_ATAI_1 - Stoploss * Point;
         ea_order_good_price = Ask + ((Ask - ea_order_stop_price));
      } else if(orderPtn == 2) { // SELL
         ea_order_stop_price = MediumMA_ATAI_1 + Stoploss * Point;
         ea_order_good_price = Bid - ((ea_order_stop_price - Bid));
      }

      // Entry
      OrderKekka = funcOrder_Send(orderPtn - 1,ea_order_stop_price,ea_order_good_price,0,0);

   }

}

//+------------------------------------------------------------------+
//| Order Send
//|
//|【Param】 ea_order_entry_Type:0- BUY, 1-SELL
//|【Param】 ea_order_stop_price:Stoploss  ea_order_good_price:Take Profit
//|【Param】 orderComment:Comment     ea_order_MagicNo:Magic Number
//|
//|【Return】True:Success
//|
//+------------------------------------------------------------------+
bool funcOrder_Send(int ea_order_entry_Type, double ea_order_stop_price, double ea_order_good_price,int orderComment,int ea_order_MagicNo) {

   int order_resend_num;
   int ea_ticket_res;
   int errorcode;
   double ea_order_entry_price;
   color order_Color;
   bool kekka;

   for( order_resend_num = 0; order_resend_num < 10; order_resend_num++ ) {

      if(MarketInfo(NULL,MODE_SPREAD) < Spread ) {

         if(ea_order_entry_Type == OP_BUY) {
            ea_order_entry_price = Ask;
            order_Color = clrBlue;
            Print(" Bought at @"+Ask);
         } else if(ea_order_entry_Type == OP_SELL) {
            ea_order_entry_price = Bid;
            order_Color = clrRed;
            Print("Sold at @"+Bid);
         }

         //
         ea_ticket_res = OrderSend(
                            NULL,
                            ea_order_entry_Type,
                            Lots,
                            ea_order_entry_price,
                            20,
                            ea_order_stop_price,
                            ea_order_good_price,
                            orderComment,
                            ea_order_MagicNo,
                            0,
                            order_Color
                         );

         Print("Result:"+ea_ticket_res);

         if ( ea_ticket_res == -1) {
            errorcode = GetLastError();

            if( errorcode != ERR_NO_ERROR) {
               printf("Error");
            }

            Sleep(2000);
            RefreshRates();

            printf("Repeat orders:%d, update entry :%g",order_resend_num+1,ea_order_entry_price);

         } else {
            Print("Order OK。 ticketNo=",ea_ticket_res," trade:",ea_order_entry_price);
            Sleep(300);

            break;
         }



      } else {
         Print("Spread NG Alow smaller spread :"+Spread+"pips Current spread:"+MarketInfo(NULL,MODE_SPREAD)+"pips");
         Sleep(2000);
         RefreshRates();
      }


   }
   return kekka;
}
//+------------------------------------------------------------------+
