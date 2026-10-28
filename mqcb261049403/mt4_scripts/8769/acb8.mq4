int init ()                                                                                      //<   1>
{                                                                                                //<   2>
string acs.Operation [] = { "Buy" , "Sell"                                                   } ; //<   3>
                                                                                                 //<   4>
double avd.QuotePoint   = MarketInfo  ( Symbol ()        , MODE_POINT       )                  ; //<   5>
double avd.QuoteTick    = MarketInfo  ( Symbol ()        , MODE_TICKSIZE    )                  ; //<   6>
double avd.NominalTick  = MarketInfo  ( Symbol ()        , MODE_TICKVALUE   )                  ; //<   7>
double ald.NominalPoint = avd.NominalTick                * avd.QuotePoint   / avd.QuoteTick    ; //<   8>
                                                                                                 //<   9>
Alert ( ""                                                                                   ) ; //<  10>
Alert ( "avd.QuotePoint:   "          , DoubleToStr      ( avd.QuotePoint   , Digits       ) ) ; //<  11>
Alert ( "avd.QuoteTick:    "          , DoubleToStr      ( avd.QuoteTick    , Digits       ) ) ; //<  12>
Alert ( "avd.NominalTick:  "          , DoubleToStr      ( avd.NominalTick  , 2            ) ) ; //<  13>
Alert ( "ald.NominalPoint: "          , DoubleToStr      ( ald.NominalPoint , 2            ) ) ; //<  14>
                                                                                                 //<  15>
if ( OrdersTotal ()   > 0             )                                                          //<  16>
   { int   i , N ; N  = OrdersTotal  () - 1                                                    ; //<  17>
     for ( i = N ; i >= 0 ; i --      )                                                          //<  18>
       {   OrderSelect    ( i         , SELECT_BY_POS    , MODE_TRADES      )                  ; //<  19>
                                                                                                 //<  20>
           double ald.OrderProfit     = OrderProfit      ()                                    ; //<  21>
           double ald.ContractSize    = OrderLots        ()                                    ; //<  22>
           double ald.OrderPoint      = ald.NominalPoint * ald.ContractSize                    ; //<  23>
           int    ali.OrderProfit     = MathRound        ( ald.OrderProfit  / ald.OrderPoint ) ; //<  24>
                                                                                                 //<  25>
           Alert ( ""                                                                        ) ; //<  26>
                                                                                                 //<  27>
           Alert ( "Profit, points: " , ali.OrderProfit                                      ) ; //<  28>
                                                                                                 //<  29>
           Alert ( "Profit, "         , AccountCurrency  ()                                  ,   //<  30>
                                " : " , DoubleToStr      ( ald.OrderProfit  , 2            ) ) ; //<  31>
                                                                                                 //<  32>
           Alert ( "Order Point, "    , AccountCurrency  ()                                  ,   //<  33>
                                " : " , DoubleToStr      ( ald.OrderPoint   , 2            ) ) ; //<  34>
                                                                                                 //<  35>
           Alert ( "Size, lots:     " , DoubleToStr      ( ald.ContractSize , 2            ) ) ; //<  36>
           Alert ( "Type:           " , acs.Operation    [ OrderType     () ]                ) ; //<  37>
           Alert ( "Ticket:        #" , OrderTicket      ()                                  ) ; //<  38>
                                                                                                 //<  39>
       } // for                                                                                  //<  40>
   } // if                                                                                       //<  41>
}                                                                                                //<  42>