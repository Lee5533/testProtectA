//
//  main.cpp
//  testDemo
//
//  Created by Lee Li on 2020/7/11.
//  Copyright © 2020 Lee Li. All rights reserved.
//

#include <iostream>
#include <functional>
#include <string>
#include <map>
using namespace std;
 enum BookType
{
  
};
enum ID_Enum
{
    ID_Invalid    = 0,
    ID_Shape,
    ID_Image,
    ID_Topic,
    ID_Boundary,
    ID_Connector,
};
#define STR_Shape "STR_Shape";

bool SetDevicesMap(map<string,int> &mapDevice)
{
 
    mapDevice.insert(make_pair<string,int>("HUAWEI HUAWEI",0));
    mapDevice.insert(make_pair<string,int>("GLONEE",1));
    mapDevice.insert(make_pair<string,int>("MEIZU",2));
    mapDevice.insert(make_pair<string,int>("COOLPAD",3));
    mapDevice.insert(make_pair<string,int>("OPPO",4));
    mapDevice.insert(make_pair<string,int>("XIAOMI",5));
    return true;
}

int main(int argc, const char * argv[]) {
    // insert code here...
    std::cout << "Hello, World!\n";
    
   

       map<string,int> mapDevice;
       SetDevicesMap(mapDevice);
       map<string,int>::iterator nameIter;
    
    string strMaker = "HUAWEI HUAWEI";
       nameIter = mapDevice.find(strMaker);
    
       int Index=9999;
       if(nameIter != mapDevice.end())
       {
           Index=nameIter->second;
       }
       switch (Index)
       {
       case 0:
               printf("lee0");
//               return 0;
           break;
       case 1:
               printf("lee1");
           break;
       case 2:
               printf("lee2");
           break;
       case 3:
               printf("lee3");
           break;
       default:
               printf("lee4");
           break;
    
               printf("lee5");
       }
    
    printf("lee6");
    return 0;
}

