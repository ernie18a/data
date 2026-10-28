//+------------------------------------------------------------------+
//|                                             DropAdjust_SL-TP.mq5 |
//|                                                 Fernando Morales |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Fernando Morales"
#property link      "https://forge.mql5.io"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---

//--- declare and initialize the trade request and result of trade request
   MqlTradeRequest request;
   MqlTradeResult  result;

   double priceTarget=ChartPriceOnDropped();

   ulong ticket;
   int pos_total=PositionsTotal();
   double price_TP=0,price_SL=0;

   printf("Found %d open positions",pos_total);
   Print("Target price is ",priceTarget);

   for(int i=0; i<=pos_total; i++)

      if((ticket=PositionGetTicket(i))>0)
        {
         if(PositionGetSymbol(i)!=_Symbol) continue;

         double price_bid = SymbolInfoDouble( _Symbol, SYMBOL_BID );
         double price_ask = SymbolInfoDouble( _Symbol, SYMBOL_ASK );

         // Obtaining current millisecond count
         ulong ms_inicial=GetTickCount();

         switch((int)PositionGetInteger(POSITION_TYPE))
           {
            case 0: // BUY

               if(priceTarget>price_bid)
                 {
                  price_SL = PositionGetDouble( POSITION_SL );
                  price_TP = priceTarget;
                 }
               else if(priceTarget<price_bid)
                 {
                  price_SL = priceTarget;
                  price_TP = PositionGetDouble( POSITION_TP );
                 }
               break;

            case 1:   // SELL

               if(priceTarget<price_ask)
                 {
                  price_SL = PositionGetDouble( POSITION_SL );
                  price_TP = priceTarget;
                 }
               else if(priceTarget>price_ask)
                 {
                  price_SL = priceTarget;
                  price_TP = PositionGetDouble( POSITION_TP );
                 }

               break;
           }

         //--- zeroing the request and result values
         ZeroMemory(request);
         ZeroMemory(result);

         //--- setting the operation parameters
         request.action= TRADE_ACTION_SLTP;// type of trade operation
         request.position= ticket;         // ticket of the position
         request.symbol= _Symbol;         // symbol 
         request.sl      = price_SL;      // Stop Loss of the position
         request.tp      = price_TP;      // Take Profit of the position

         //--- output information about the modification
         PrintFormat("Updating trade #%I64d: SL=%f .. TP= %f",ticket,price_SL,price_TP);

         //--- send the request
         if(!OrderSend(request,result))
            printf("OrderSend error %d",GetLastError());  // if unable to send the request, output the error code

         //--- information about the operation   
         printf("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
         printf("####---> Updating the trade took %d ms",GetTickCount()-ms_inicial);

        }
  }
//+------------------------------------------------------------------+
