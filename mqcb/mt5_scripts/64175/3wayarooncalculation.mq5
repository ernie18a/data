//+------------------------------------------------------------------+
//|                                            3wayAroon Calculation |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {

//old fashioned variables declaration, yes I am an old fart, sorry
   int TimeInterval  = 20;
   int Size          = 0;
   int CopyHighIndex = 0;
   int CopyLowIndex  = 0;
   int HighestIndex  = 0;
   int LowestIndex   = 0;
   int AroonUp       = 0;
   int AroonDown     = 0;

   double High_TargetArray[];
   double Low_TargetArray[];
   ArraySetAsSeries(High_TargetArray,true);
   ArraySetAsSeries(Low_TargetArray,true);

   double Aroon_Up[];
   double Aroon_Down[];
   ArraySetAsSeries(Aroon_Up,true);
   ArraySetAsSeries(Aroon_Down,true);

   int  handle_Aroon = iCustom(_Symbol,PERIOD_CURRENT,"AROON",20,70,30);
   CopyBuffer(handle_Aroon,0,0,20,Aroon_Up);
   CopyBuffer(handle_Aroon,1,0,20,Aroon_Down);


//using ihigh and ilow to verify the High_Target and Low_Target arrays, but
// they do not contribute to the aroon calculation
   CopyHigh(_Symbol,PERIOD_CURRENT,0,TimeInterval,High_TargetArray);
   Size = ArraySize(High_TargetArray);
   for(int i = 0;i < Size; i++)
     {
      Print("i: ",i," - HighValue: ", High_TargetArray[i]);
      Print("   ",i," - High:      ", iHigh(_Symbol,PERIOD_CURRENT,i));
     }
   CopyLow(_Symbol,PERIOD_CURRENT,0,TimeInterval,Low_TargetArray);
   Size = ArraySize(Low_TargetArray);
   for(int i = 0;i < Size;i++)
     {
      Print("i: ",i," - LowValue: ", Low_TargetArray[i]);
      Print("   ",i," - Low:      ", iLow(_Symbol,PERIOD_CURRENT,i));

     }

   CopyHighIndex = ArrayMaximum(High_TargetArray);
   HighestIndex = iHighest(_Symbol, PERIOD_CURRENT, MODE_HIGH, TimeInterval, 0);
   Print("CopyHighIndex: ",CopyHighIndex);
   Print("iHighest:      ",HighestIndex);

   CopyLowIndex = ArrayMinimum(Low_TargetArray);
   LowestIndex = iLowest(_Symbol, PERIOD_CURRENT, MODE_LOW, TimeInterval, 0);
   Print("CopyLowIndex: ", CopyLowIndex);
   Print("iLowest:      ",LowestIndex);

// Calculate Aroon Up and Aroon Down
   Print("Calculating the Aroon values:\n");
   Print("Aroon values based on CopyHigh & CopyLow");
   AroonUp   = 100.0 * (TimeInterval - CopyHighIndex) / TimeInterval;
   AroonDown = 100.0 * (TimeInterval - CopyLowIndex) / TimeInterval;
   Print(" AroonUp:   ",AroonUp);
   Print(" AroonDown: ",AroonDown);
   Print("\n");
   Print("Aroon values based on iHighest & iLowest");
   AroonUp   = 100.0 * (TimeInterval - HighestIndex) / TimeInterval;
   AroonDown = 100.0 * (TimeInterval - LowestIndex) / TimeInterval;
   Print(" AroonUp:   ",AroonUp);
   Print(" AroonDown: ",AroonDown);
   Print("\n");

   Print("Aroon values based AroonIndicator");
   Print(" AroonUp:   ",Aroon_Up[0]);
   Print(" AroonDown: ",Aroon_Down[0]);
   Print("\n");

  }
//+------------------------------------------------------------------+
