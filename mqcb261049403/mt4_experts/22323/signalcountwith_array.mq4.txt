//+------------------------------------------------------------------+
//|                                                Tipu_CCI_Oppo.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com | inceabdullah@yahoo.com
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property strict
//--- input parameters

input string IndName="super_signals_v2_alert"; // Indicator Name

double GetInd_iCustom[101];
double GetInd_iCustom_old[101];
double GetInd_iCustom_changed[101];
double GetInd_iCustom_maxInt[101];
double GetInd_iCustom_minInt[101];
double GetInd_iCustom_Zero[101];
double GetInd_iCustom_NewNotMax[101];
double GetInd_iCustom_OldNotMax[101];

double ConsExp;
double ConsExp_old;

string GetInd_iCustom_changed_Cons;
string GetInd_iCustom_maxInt_Cons;
string GetInd_iCustom_minInt_Cons;
string GetInd_iCustom_Zero_Cons;
string GetInd_iCustom_NewNotMax_Cons;
string GetInd_iCustom_OldNotMax_Cons;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetInd()

  {

   for(int iiCustomFOR=0; iiCustomFOR<=7; iiCustomFOR++)
     {
      for(int jiCustomFOR=0; jiCustomFOR<=1; jiCustomFOR++)
        {

         ConsExp_old=GetInd_iCustom[(iiCustomFOR*10)+jiCustomFOR];
         GetInd_iCustom_old[(iiCustomFOR*10)+jiCustomFOR]=ConsExp_old;
         ConsExp=iCustom(NULL,0,IndName,iiCustomFOR,jiCustomFOR);
         GetInd_iCustom[(iiCustomFOR*10)+jiCustomFOR]=ConsExp;



        }


     }


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TradeChanged()
  {

   for(int iiCustomFOR=0; iiCustomFOR<=7; iiCustomFOR++)
     {
      for(int jiCustomFOR=0; jiCustomFOR<=1; jiCustomFOR++)
        {
         if(GetInd_iCustom_old[(iiCustomFOR*10)+jiCustomFOR]!=GetInd_iCustom[(iiCustomFOR*10)+jiCustomFOR]) // if different before it was
           {
            GetInd_iCustom_changed_Cons=GetInd_iCustom_changed[(iiCustomFOR*10)+jiCustomFOR]+1;
            GetInd_iCustom_changed[(iiCustomFOR*10)+jiCustomFOR]=GetInd_iCustom_changed_Cons;

           }

         if(GetInd_iCustom[(iiCustomFOR*10)+jiCustomFOR]==2147483647) // if different before it was
           {
            GetInd_iCustom_maxInt_Cons=GetInd_iCustom_maxInt[(iiCustomFOR*10)+jiCustomFOR]+1;
            GetInd_iCustom_maxInt[(iiCustomFOR*10)+jiCustomFOR]=GetInd_iCustom_maxInt_Cons;

           }

         if(GetInd_iCustom[(iiCustomFOR*10)+jiCustomFOR]==-2147483646) // if different before it was
           {
            GetInd_iCustom_minInt_Cons=GetInd_iCustom_minInt[(iiCustomFOR*10)+jiCustomFOR]+1;
            GetInd_iCustom_minInt[(iiCustomFOR*10)+jiCustomFOR]=GetInd_iCustom_minInt_Cons;

           }
         if(GetInd_iCustom[(iiCustomFOR*10)+jiCustomFOR]!=0 && GetInd_iCustom_old[(iiCustomFOR*10)+jiCustomFOR]==0) // if Zero but before not
           {
            GetInd_iCustom_Zero_Cons=GetInd_iCustom_Zero[(iiCustomFOR*10)+jiCustomFOR]+1;
            GetInd_iCustom_Zero[(iiCustomFOR*10)+jiCustomFOR]=GetInd_iCustom_Zero_Cons;

           }
         if(GetInd_iCustom[(iiCustomFOR*10)+jiCustomFOR]!=2147483647 && GetInd_iCustom_old[(iiCustomFOR*10)+jiCustomFOR]==2147483647) // if Zero
           {
            GetInd_iCustom_NewNotMax_Cons=GetInd_iCustom_NewNotMax[(iiCustomFOR*10)+jiCustomFOR]+1;
            GetInd_iCustom_NewNotMax[(iiCustomFOR*10)+jiCustomFOR]=GetInd_iCustom_NewNotMax_Cons;

           }
         if(GetInd_iCustom[(iiCustomFOR*10)+jiCustomFOR]==2147483647 && GetInd_iCustom_old[(iiCustomFOR*10)+jiCustomFOR]!=2147483647) // if Zero
           {
            GetInd_iCustom_OldNotMax_Cons=GetInd_iCustom_OldNotMax[(iiCustomFOR*10)+jiCustomFOR]+1;
            GetInd_iCustom_OldNotMax[(iiCustomFOR*10)+jiCustomFOR]=GetInd_iCustom_OldNotMax_Cons;

           }

        }


     } //for  iiCustomFOR ends




  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+


string TotComments;

string Comments="Indicator Name:"+IndName+"\n";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CommentArrays()
  {

   for(int iiCustomFOR=0; iiCustomFOR<=7; iiCustomFOR++)
     {
      for(int jiCustomFOR=0; jiCustomFOR<=1; jiCustomFOR++)
        {

         TotComments=TotComments+iiCustomFOR+","+jiCustomFOR+" - Old Dif New : "+GetInd_iCustom_changed[(iiCustomFOR*10)+jiCustomFOR]+" MaxInt "+GetInd_iCustom_maxInt[(iiCustomFOR*10)+jiCustomFOR]+"  MinInt "+GetInd_iCustom_minInt[(iiCustomFOR*10)+jiCustomFOR]+" Zero "+GetInd_iCustom_Zero[(iiCustomFOR*10)+jiCustomFOR]+" NewNotax "+GetInd_iCustom_NewNotMax[(iiCustomFOR*10)+jiCustomFOR]+" OldNotMax "+GetInd_iCustom_OldNotMax[(iiCustomFOR*10)+jiCustomFOR]+"\n";

        }



     }


   Comment(Comments+TotComments);

// Comment(GetInd_iCustom_changed[10]);

   TotComments="";

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//---


   GetInd(); //Get Indicator via iCustom

   TradeChanged(); //Do Trade

   CommentArrays();



  }
//+------------------------------------------------------------------+
