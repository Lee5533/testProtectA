//
//  socketClient.cpp
//  LeePlayer
//
//  Created by Lee Li on 2020/9/1.
//  Copyright © 2020 Lee Li. All rights reserved.
//

#include "socketClient.hpp"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <pthread.h>


socketClient::socketClient(void)
:na(10)
,nb(20)
{
    printf("lee socketClient:%d,nb:%d\n",na,nb);
}
socketClient::~socketClient()
{
     
}
void socketClient::test()
{
    start();
}

void socketClient::start()
{
    pthread_t tids;

    int nRet = pthread_create(&tids, NULL, (void*(*)(void*))connectServer, this);
    
    printf("socketClient pthread_create:--->%d", nRet);

    if (nRet != 0)
    {
        printf("pthread_create error: error_code= %d",nRet);
    }
}

void* socketClient::connectServer(void * arg)
{
    socketClient* temp = (socketClient*)arg;
    temp->connectThreadLoop();
    return 0;
}

void socketClient::connectThreadLoop()
{
    sleep(5);
    printf("lee socketClient:%d,nb:%d\n",na,nb);
    //创建套接字
    int sock = socket(AF_INET, SOCK_STREAM, 0);
        
    //向服务器（特定的IP和端口）发起请求
    struct sockaddr_in serv_addr;
    memset(&serv_addr, 0, sizeof(serv_addr));  //每个字节都用0填充
    serv_addr.sin_family = AF_INET;  //使用IPv4地址
    serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    //    serv_addr.sin_addr.s_addr = inet_addr("127.0.0.1");  //具体的IP地址
    serv_addr.sin_port = htons(1234);  //端口
        
    connect(sock, (struct sockaddr*)&serv_addr, sizeof(serv_addr));
       
    //读取服务器传回的数据
    char buffer[40];
    read(sock, buffer, sizeof(buffer)-1);
       
    printf("Message form server: %s\n", buffer);
       
    //关闭套接字
    close(sock);
        
}
