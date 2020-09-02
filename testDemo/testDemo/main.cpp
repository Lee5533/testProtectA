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

#include <pthread.h>
using namespace std;
void* say_hello(void* args);
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

//int main(int argc, const char * argv[]) {
//    // insert code here...
//    std::cout << "Hello, World!\n";
//
//
//
//       map<string,int> mapDevice;
//       SetDevicesMap(mapDevice);
//       map<string,int>::iterator nameIter;
//
//    string strMaker = "HUAWEI HUAWEI";
//       nameIter = mapDevice.find(strMaker);
//
//       int Index=9999;
//       if(nameIter != mapDevice.end())
//       {
//           Index=nameIter->second;
//       }
//       switch (Index)
//       {
//       case 0:
//               printf("lee0");
////               return 0;
//           break;
//       case 1:
//               printf("lee1");
//           break;
//       case 2:
//               printf("lee2");
//           break;
//       case 3:
//               printf("lee3");
//           break;
//       default:
//               printf("lee4");
//           break;
//
//               printf("lee5");
//       }
//
//    printf("lee6");
//    return 0;
//}

int main(int argc, const char * argv[]) {
    printf("lee test\n");
    // 定义线程的 id 变量，多个变量使用数组
    printf("main thread id is %p\n",pthread_self());
    pthread_t tids[3];
    for(int i = 0; i < 3; ++i)
    {
        //参数依次是：创建的线程id，线程参数，调用的函数，传入的函数参数
        int ret = pthread_create(&tids[i], NULL, say_hello, NULL);
        if (ret != 0)
        {
           cout << "pthread_create error: error_code=" << ret << endl;
        }
    }
    printf("lee test2\n");
    //等各个线程退出后，进程才结束，否则进程强制结束了，线程可能还没反应过来；
    pthread_exit(NULL);
    return 0;
}

void* say_hello(void* args)
{
   int  i = 0;
    while (i<5) {
        printf("zixiancheng thread id is %p\n",pthread_self());
        i++;
    }
    cout << "Hello Runoob！" << endl;
    return 0;
}
