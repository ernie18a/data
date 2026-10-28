/****************************************************************/
void OnStart() {ClassExample(); StructExample();}
/***************************************************************
   Have you ever wondered how to safely return automatic objects
    from functions without memory leaks?
   Here is one option that will work in MQL.
   The technique is called 'copy constructor'. Make sure that
    all fields are copied, including complex data types,
    recursively.
   Please refer to the example code below, you will figure out
    how it works.
*/
void ClassExample()
  {
   Print(__FUNCTION__);
   A a1;
   A a2=Fa(); //object receive from function
   a1.Work();
   a1.Report(); //1 1 1 1
   a2.Report(); //3 3 3 3
   /*CONTINUE USE OBJECT FROM FUNCTION*/
   a2.Work();
   a2.Report(); //4 4 4 4
   return;
  }
/***************************************************************
   PARTS OF CLASS A*/
struct C {int mx; C():mx(0) {}};
class D {public:int mx; D():mx(0) {} D(D &d):mx(d.mx) {}};
/****************************************************************/
class A
  {
protected:
   int               mx;   //simple
   int               ma[]; //array
   C                 mc;   //struct
   D                 d;    //class
public:
   /*COPY CONSTRUCTOR*/
                     A(A &a):mx(a.mx),d(a.d) {ArrayCopy(ma,a.ma); mc=a.mc;}
   /*EXPLICIT DEFAULT CONSTRUCTOR*/
                     A():mx(0) {}
   /*METHODS*/
   void              Work() {mx++; ArrayResize(ma,mx); mc.mx=mx; d.mx=mx;}
   void              Report() {Print(mx," ",ArraySize(ma)," ",mc.mx," ",d.mx);}
  };
/****************************************************************/
A Fa()
  {
   A a;
   for(int i=0; i<3; i++)
     {a.Work();} //a lot of work
   return a; //object return
  }
/***************************************************************
   Want to return a structure?
   Structures can be normally updated with function as parameters
    sent by reference.
   If you wish to RETURN a struct with function, it is also
    possible, but unlike classes, structs do not require an
    explicit 'copy constructor'.
*/
void StructExample()
  {
   Print(__FUNCTION__);
   B b1;
   B b2=Fb(); //struct receive from function
   b1.mx++;
   /**/
   Print(b1.mx," ",ArraySize(b1.ma)); //  1 0
   Print(b2.mx," ",ArraySize(b2.ma)); // 10 9
   return;
  }
/****************************************************************/
struct B
  {
   int               mx;
   int               ma[];
                     B():mx(0) {} //constructor, not needed formally
  };
/****************************************************************/
B Fb()
  {
   B b;
   for(int i=0; i<10; i++)
     {b.mx++; ArrayResize(b.ma,i);} //work hard
   return b; //struct return
  }
/**/
