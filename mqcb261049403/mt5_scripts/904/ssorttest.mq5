//+------------------------------------------------------------------+
//|                                                    sSortTest.mq5 |
//|                                                          Integer |
//|                            https://www.mql5.com/en/users/integer |
//+------------------------------------------------------------------+
#property copyright "Integer"
#property link      "https://www.mql5.com/en/users/integer"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   Alert("Start");

   int Size=10000;
   double x0[];
   double x1[];
   ArrayResize(x0,Size);
   ArrayResize(x1,Size);

   long start;
   long t,t1=0,t2=0,t3=0,t4=0,t5=0,t6=0;

   int Rounds=30;

   for(int j=0;j<Rounds;j++)
     {

      Alert("==> Pass "+IntegerToString(j+1));

      for(int i=0;i<Size;i++)
        {
         x0[i]=MathRand();
        }

      ArrayCopy(x1,x0);
      start=GetTickCount();
      SortBubbleUp(x1);
      t=GetTickCount()-start;
      t1+=t;
      Alert("Bubble: "+IntegerToString(t));
      Check(x1);

      ArrayCopy(x1,x0);
      start=GetTickCount();
      SortSelectUp(x1);
      t=GetTickCount()-start;
      t2+=t;
      Alert("Select: "+IntegerToString(t));
      Check(x1);

      ArrayCopy(x1,x0);
      start=GetTickCount();
      SortInsertUp(x1);
      t=GetTickCount()-start;
      t3+=t;
      Alert("Insert: "+IntegerToString(t));
      Check(x1);

      ArrayCopy(x1,x0);
      start=GetTickCount();
      SortShellUp(x1);
      t=GetTickCount()-start;
      t4+=t;
      Alert("Shell: "+IntegerToString(t));
      Check(x1);

      ArrayCopy(x1,x0);
      start=GetTickCount();
      SortHoareUp(x1);
      t=GetTickCount()-start;
      t5+=t;
      Alert("Hoare: "+IntegerToString(t));
      Check(x1);

      ArrayCopy(x1,x0);
      start=GetTickCount();
      SortSelectUpFst(x1);
      t=GetTickCount()-start;
      t6+=t;
      Alert("SelectFst: "+IntegerToString(t));
      Check(x1);
     }

   Alert("==> Average:");
   Alert("Bubble: "+IntegerToString(t1/Rounds));
   Alert("Select: "+IntegerToString(t2/Rounds));
   Alert("Insert: "+IntegerToString(t3/Rounds));
   Alert("Shell: "+IntegerToString(t4/Rounds));
   Alert("Hoare: "+IntegerToString(t5/Rounds));
   Alert("SelectFst: "+IntegerToString(t6/Rounds));

   Alert("Finish");
  }
//+------------------------------------------------------------------+
//| Checks if array is alrady sorted (ascending)                     |
//+------------------------------------------------------------------+
void Check(double  &aAr[])
  {
   for(int i=ArraySize(aAr)-1;i>0;i--)
     {
      if(aAr[i]<aAr[i-1])
        {
         Alert("Error");
         return;
        }
     }
  }
//+------------------------------------------------------------------+
//| ArrayAlertR                                                      |
//| Prints array as line                                             |
//+------------------------------------------------------------------+
void ArrayAlertR(double  &aAr[],int aDigits=0,string aHeader="")
  {
   int Len=ArraySize(aAr);
   string str=aHeader+": ";
   for(int i=0;i<Len;i++)
     {
      str=str+DoubleToString(aAr[i],aDigits)+", ";
     }
   Alert(str);
  }
//+------------------------------------------------------------------+
//| ArrayAlertC                                                      |
//| Prints array as column                                           |
//+------------------------------------------------------------------+
void ArrayAlertC(double  &aAr[],int aDigits=0,string aHeader="")
  {
   int Len=ArraySize(aAr);
   Alert("=== "+aHeader+" ===");
   for(int i=0;i<Len;i++)
     {
      Alert(IntegerToString(i)+": "+DoubleToString(aAr[i],aDigits));
     }
  }
//+------------------------------------------------------------------+
//| SortHoareUp                                                      |
//+------------------------------------------------------------------+
void SortHoareUp(double  &aAr[])
  {
   HoareUp(aAr,0,ArraySize(aAr)-1);
  }
//+------------------------------------------------------------------+
//| HoareUp                                                          |
//| Auxiliary function for Hoare sort                                |
//+------------------------------------------------------------------+
void HoareUp(double  &aAr[],int aLeft,int aRight)
  {
   double tmp;
   int i=aLeft;
   int j=aRight;
   double xx=aAr[(aLeft+aRight)/2];
   do
     {
   while(i<aRight && aAr[i]<xx)i++;
   while(j>aLeft && xx<aAr[j])j--;
   if(i<=j)
     {
      tmp=aAr[i];
      aAr[i]=aAr[j];
      aAr[j]=tmp;
      i++;
      j--;
     }
  }
while(i<=j);
if(aLeft<j)HoareUp(aAr,aLeft,j);
if(i<aRight)HoareUp(aAr,i,aRight);
}
//+------------------------------------------------------------------+
//| SortHoareDn                                                      |
//+------------------------------------------------------------------+
void SortHoareDn(double  &aAr[])
{
   HoareDn(aAr,0,ArraySize(aAr)-1);
}
//+------------------------------------------------------------------+
//| HoareDn                                                          |
//| Auxiliary function for Hoare sort                                |
//+------------------------------------------------------------------+
void HoareDn(double  &aAr[],int aLeft,int aRight)
{
   double tmp;
   int i=aLeft;
   int j=aRight;
   double xx=aAr[(aLeft+aRight)/2];
      do
      {
         while(i<aRight && aAr[i]>xx)i++;
         while(j>aLeft && xx>aAr[j])j--;
            if(i<=j)
            {
               tmp=aAr[i];
               aAr[i]=aAr[j];
               aAr[j]=tmp;
               i++;
               j--;
            }
      }
      while(i<=j);
      if(aLeft<j)HoareDn(aAr,aLeft,j);
      if(i<aRight)HoareDn(aAr,i,aRight);
}
//+------------------------------------------------------------------+
//| SortShellUp                                                      |
//+------------------------------------------------------------------+
void SortShellUp(double  &aAr[])
{
   double tmp;
   int n[]={9,5,3,2,1};
   int i,j,k,g;
   int Len=ArraySize(aAr);
   for(k=0;k<5;k++)
   {
         g=n[k];
            for(i=g;i<Len;i++)
            {
               tmp=aAr[i];
                  for(j=i-g;j>=0 && tmp<aAr[j];j-=g)
                  {
                     aAr[j+g]=aAr[j];
                  }
               aAr[j+g]=tmp;
             }
      }
}
//+------------------------------------------------------------------+
//| SortShellDn                                                      |
//+------------------------------------------------------------------+
void SortShellDn(double  &aAr[])
{
   double tmp;
   int n[]={9,5,3,2,1};
   int i,j,k,g;
   int Len=ArraySize(aAr);
      for(k=0;k<5;k++)
      {
         g=n[k];
            for(i=g;i<Len;i++)
            {
               tmp=aAr[i];
                  for(j=i-g;j>=0 && tmp>aAr[j];j-=g)
                  {
                     aAr[j+g]=aAr[j];
                  }
               aAr[j+g]=tmp;
            }
      }
}
//+------------------------------------------------------------------+
//| SortInsertUp                                                     |
//+------------------------------------------------------------------+
void SortInsertUp(double  &aAr[])
{
   double tmp;
   int i,j,Len=ArraySize(aAr);
   for(i=1;i<Len;i++)
   {
      tmp=aAr[i];
         for(j=i-1;j>=0 && tmp<aAr[j];j--)
         {
            aAr[j+1]=aAr[j];
            aAr[j]=tmp;
         }
   }
}
//+------------------------------------------------------------------+
//| SortInsertDn                                                     |
//+------------------------------------------------------------------+
void SortInsertDn(double  &aAr[])
{
   double tmp;
   int i,j,Len=ArraySize(aAr);
   for(i=1;i<Len;i++)
   {
      tmp=aAr[i];
         for(j=i-1;j>=0 && tmp>aAr[j];j--)
         {
            aAr[j+1]=aAr[j];
            aAr[j]=tmp;
         }
   }
}
//+------------------------------------------------------------------+
//| SortSelectUp                                                     |
//+------------------------------------------------------------------+
void SortSelectUp(double  &aAr[])
{
   double tmp;
   int i,j,k;
   int Len=ArraySize(aAr);
   int Len1=Len-1;
      for(i=0;i<Len1;i++)
      {
         tmp=aAr[i];
         k=i;
            for(j=i+1;j<Len;j++)
            {
               if(aAr[j]<tmp)
               {
                  k=j;
                  tmp=aAr[j];
               }
            }
         aAr[k]=aAr[i];
         aAr[i]=tmp;
      }
}
//+------------------------------------------------------------------+
//| SortSelectDn                                                     |
//+------------------------------------------------------------------+
void SortSelectDn(double  &aAr[])
{
   double tmp;
   int i,j,k;
   int Len=ArraySize(aAr);
   int Len1=Len-1;
      for(i=0;i<Len1;i++)
      {
         tmp=aAr[i];
         k=i;
            for(j=i+1;j<Len;j++)
            {
               if(aAr[j]>tmp)
               {
                  k=j;
                  tmp=aAr[j];
               }
            }
         aAr[k]=aAr[i];
         aAr[i]=tmp;
      }
}
//+------------------------------------------------------------------+
//| SortBubbleUp                                                     |
//+------------------------------------------------------------------+
void SortBubbleUp(double  &aAr[])
{
   double tmp;
   int i,j;
   int Len=ArraySize(aAr);
   int Len1=Len-1;
      for(i=1;i<Len;i++)
      {
         for(j=Len1;j>=i;j--)
         {
            if(aAr[j-1]>aAr[j])
            {
               tmp=aAr[j-1];
               aAr[j-1]=aAr[j];
               aAr[j]=tmp;
            }
         }
      }
}
//+------------------------------------------------------------------+
//| SortBubbleDn                                                     |
//+------------------------------------------------------------------+
void SortBubbleDn(double  &aAr[])
{
   double tmp;
   int i,j;
   int Len=ArraySize(aAr);
   int Len1=Len-1;
      for(i=1;i<Len;i++)
      {
         for(j=Len1;j>=i;j--)
         {
            if(aAr[j-1]<aAr[j])
            {
               tmp=aAr[j-1];
               aAr[j-1]=aAr[j];
               aAr[j]=tmp;
            }
         }
      }
}
//+------------------------------------------------------------------+
//| SortSelectUpFst                                                  |
//+------------------------------------------------------------------+
void SortSelectUpFst(double  &aAr[])
{
   double tmp;
   int i,j,Len=ArraySize(aAr)-1;
      for(i=0;i<Len;i++)
      {
         j=ArrayMinimum(aAr,i);
         tmp=aAr[i];
         aAr[i]=aAr[j];
         aAr[j]=tmp;
      }
}
//+------------------------------------------------------------------+
//| SortSelectDnFst                                                  |
//+------------------------------------------------------------------+
void SortSelectDnFst(double  &aAr[])
{
   double tmp;
   int i,j,Len=ArraySize(aAr)-1;
      for(i=0;i<Len;i++)
      {
         j=ArrayMaximum(aAr,i);
         tmp=aAr[i];
         aAr[i]=aAr[j];
         aAr[j]=tmp;
      }
}
//+------------------------------------------------------------------+
