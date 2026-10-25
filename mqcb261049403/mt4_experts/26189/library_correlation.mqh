//+------------------------------------------------------------------+
//|                                          Library_Correlation.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                           https://www.mql5.com/en/users/alex2356 |
//+------------------------------------------------------------------+
// created from MQL5 correlation indicators - A. Fedsov
 // calling description:
 
 //  enum CorTyp
 //   {
 //    Pearson  = 1,
 //    Spearman = 2,
 //    Kendall  = 3,
 //    Fechner  = 4
 //   };
 // input int corr_range  = 10;
//  input CorTyp cType =  0;
  
//   double CorrBuffer[5];
//   GetCorrValue(cor_range,cType, CorrBuffer);

 void GetCorrValue(int rangeN, int corrType, double &CorrBuffer[])
  {
   
//----
   double PriceFlt[],price[]; 
   int PriceInt[];
   double multiply;
   int i,k,CorrSize;
   double R2[],TrueRanks[];
   //
   CorrSize=5;
   multiply=MathPow(10,_Digits);
   //Pearson
   ArrayResize(PriceInt,rangeN); // Spearman
   ArrayResize(PriceFlt,rangeN); // Person, Kendall
   ArrayResize(CorrBuffer,CorrSize);
   ArrayResize(price,rangeN+CorrSize);
   ArrayInitialize(PriceFlt,0.0);
   ArrayInitialize(PriceInt,0);
   // Spearman
   ArrayResize(R2,rangeN);
   ArrayResize(TrueRanks,rangeN);

   // load price array
   for (i=0;i<rangeN+CorrSize;i++) price[i] = iClose(NULL,0,i+1);
   //
   //----------------- Pearson ------------------------------
   if(corrType==1) 
    {
     for(i=0; i<CorrSize; i++)
      {
       for(k=0; k<rangeN; k++) PriceFlt[k]=price[k+i];
       CorrBuffer[i] = PearsonCalc(PriceFlt,rangeN);
      }
    }//--- Pearson ------
 // ------------- Spearman ----------------------------   
   if(corrType==2) 
    {
     for(i=CorrSize-1; i>=0; i--)
      {
       for(k=0; k<rangeN; k++) PriceInt[k]=int(price[i+k]*multiply);
       RankPrices(R2,TrueRanks,PriceInt,rangeN);
       CorrBuffer[i]=SpearmanCalc(R2,rangeN);
      }
    }
  //----------------- Kendall --------------------------
   if(corrType==3) 
    {
     for(i=0; i< CorrSize; i++)
      {
       for(k=0; k<rangeN; k++) PriceFlt[k]=price[k+i];
       CorrBuffer[i]=KendallCalc(PriceFlt,rangeN);
      } 
    }   
  // ------------------- Fechner -------------------------
    if(corrType==4) 
    {
     for(i=0; i< CorrSize; i++)
      {
       for(k=0; k<rangeN; k++) PriceFlt[k]=price[k+i];
       CorrBuffer[i]=FechnerCalc(PriceFlt,rangeN);
      } 
    }  
   return;
  }
//+------------------------------------------------------------------+
//| Calculation of the  Pearson numerator                                     |
//+------------------------------------------------------------------+
double Numerator(double &Ranks[],int N)
  {
//----
   double Y[],dx[],dy[],mx=0.0,my=0.0,sum=0.0,sm=0.0;
   ArrayResize(Y,N);
   ArrayResize(dx,N);
   ArrayResize(dy,N);

   int n=N;
   for(int i=0; i<N; i++)
     {
      Y[i]=n;
      n--;
     }

   mx=Average(Y);
   my=Average(Ranks);

   for(int j=0;j<N;j++)
     {
      dx[j]=Y[j]-mx;
      dy[j]=Ranks[j]-my;
      sm+=dx[j]*dy[j];
     }
   return sm;
  }
//+------------------------------------------------------------------+
//| Calculation of the Pearson denominator                                   |
//+------------------------------------------------------------------+
double Denominator(double &Ranks[],int N)
  {
//----
   double Y[],dx2[],dy2[],mx=0.0,my=0.0,sum=0.0,smx2=0.0,smy2=0.0;
   ArrayResize(Y,N);
   ArrayResize(dx2,N);
   ArrayResize(dy2,N);

   int n=N;
   for(int i=0; i<N; i++)
     {
      Y[i]=n;
      n--;
     }

   mx=Average(Y);
   my=Average(Ranks);

   for(int j=0;j<N;j++)
     {
      dx2[j]=MathPow(Y[j]-mx,2);
      dy2[j]=MathPow(Ranks[j]-my,2);
      smx2+=dx2[j];
      smy2+=dy2[j];
     }
   return(MathSqrt(smx2*smy2));
  }
//+------------------------------------------------------------------+
//| Calculation of Pearson correlation coefficient                   |
//+------------------------------------------------------------------+
double PearsonCalc(double &Ranks[],int N)
  {
   double ch,zn;
   ch=Numerator(Ranks,N);
   zn=Denominator(Ranks,N);
   return (ch/zn);
  }
  //
 //------------------------------------------------------------------
 // Spearman
//-------------------------------------------------------------------
//+------------------------------------------------------------------+
//| Arithmetical mean of the entire sampling Spearman                |
//+------------------------------------------------------------------+
double Average(double &arr[])
  {
   int size=ArraySize(arr);
   double Sum=0.0;
   for(int i=0; i<size; i++)
      Sum+=arr[i];
   return(Sum/size);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Calculation of Spearman correlation coefficient                  |
//+------------------------------------------------------------------+
double SpearmanCalc(double &Ranks[],int N)
  {
//----
   double sumd2=0.0;

   for(int i=0; i<N; i++)
      sumd2+=MathPow(Ranks[i]-i-1,2);

   return(1-6*sumd2/(N*(MathPow(N,2)-1)));
  }
//+------------------------------------------------------------------+
//| Spearman Price ranking                                           |
//+------------------------------------------------------------------+
void RankPrices(double &R2[], double &TrueRanks_[],int &InitialArray[], int rangeN)
  {
//----
   int SortInt[];
   int i,k,m,dublicat,counter,etalon;
   double dcounter,averageRank;
   ArrayResize(SortInt,rangeN);
   ArraySetAsSeries(SortInt,true);

   ArrayCopy(SortInt,InitialArray,0,0,WHOLE_ARRAY);

   for(i=0; i<rangeN; i++)
      TrueRanks_[i]=i+1;

   ArraySort(SortInt);

   for(i=0; i<rangeN-1; i++)
     {
      if(SortInt[i]!=SortInt[i+1])
         continue;

      dublicat=SortInt[i];
      k=i+1;
      counter=1;
      averageRank=i+1;

      while(k<rangeN)
        {
         if(SortInt[k]==dublicat)
           {
            counter++;
            averageRank+=k+1;
            k++;
           }
         else
            break;
        }
      dcounter=counter;
      averageRank=averageRank/dcounter;

      for(m=i; m<k; m++)
         TrueRanks_[m]=averageRank;
      i=k;
     }

   for(i=0; i<rangeN; i++)
     {
      etalon=InitialArray[i];
      k=0;
      while(k<rangeN)
        {
         if(etalon==SortInt[k])
           {
            R2[i]=TrueRanks_[k];
            break;
           }
         k++;
        }
     }
//----
   return;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Calculation of Kendall correlation coefficient                   |
//+------------------------------------------------------------------+
double KendallCalc(double &Ranks[],int N)
  {
   double Y[],t;
   ArrayResize(Y,N);

   int n=N;
   for(int i=0; i<N; i++)
     {
      Y[i]=n;
      n--;
     }
   MathCorrelationKendall(Ranks,Y,t);
   return (t);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| MathCorrelationKendall                                           |
//+------------------------------------------------------------------+
//| The function calculates Kendall's tau correlation coefficient.   |
//|                                                                  |
//| Arguments:                                                       |
//| array1[]    : First array with double values                     |
//| array2[]    : Second array with double values                    |
//| tau         : Variable for calculated value of the Kendall's tau |
//|                                                                  |
//| Return value: true if successful, otherwise false                |
//+------------------------------------------------------------------+
bool MathCorrelationKendall(const double &array1[],const double &array2[],double &tau)
  {
  //+------------------------------------------------------------------+
  //| Nans                                                             |
  //+------------------------------------------------------------------+
   double QNaN   =(double)"nan";   // QNaN
   double QPOSINF=(double)"inf";   // +infinity 1.#INF 
   double QNEGINF=(double)"-inf";  // -infinity -1.#INF 

   tau=QNaN;
   int size=ArraySize(array1);
   if(size==0 || ArraySize(array2)!=size)
      return(false);
//---
   int cnt1=0,cnt2=0,cnt=0;
//---
   for(int i=0; i<size; i++)
     {
      for(int j=i+1; j<size; j++)
        {
         double delta1=array1[i]-array1[j];
         double delta2=array2[i]-array2[j];
         double delta=delta1*delta2;
         if(delta==0)
           {
            if(delta1!=0)
               cnt1++;
            if(delta2!=0)
               cnt2++;
           }
         else
           {
            cnt1++;
            cnt2++;
            if(delta>0.0)
               cnt++;
            else
               cnt--;
           }
        }
     }
//--- calculate Kendall tau
   double den=cnt1*cnt2;
   if(den==0)
      return(false);
   tau=cnt/MathSqrt(den);
//---
   return(true);
  }
  //----------------------------------------------------------
//+------------------------------------------------------------------+
//| Calculation of Fechner correlation coefficient                   |
//+------------------------------------------------------------------+
double FechnerCalc(double &Ranks[],int N)
  {
   double Y[],res,mx,my,sum=0.0,markx[],marky[];
   double Na=0.0,Nb=0.0;
   ArrayResize(Y,N);
   ArrayResize(markx,N);
   ArrayResize(marky,N);

   int n=N;
   for(int i=0; i<N; i++)
     {
      Y[i]=n;
      n--;
     }

   mx=Average(Y);
   my=Average(Ranks);

   for(int j=0; j<N; j++)
     {
      markx[j]=(Y[j]>mx)?1:-1;
      marky[j]=(Ranks[j]>my)?1:-1;
      if(markx[j]==marky[j])
         Na++;
      else
         Nb++;
     }

   res=(Na-Nb)/(Na+Nb);
   return (res);
  }
//+------------------------------------------------------------------+