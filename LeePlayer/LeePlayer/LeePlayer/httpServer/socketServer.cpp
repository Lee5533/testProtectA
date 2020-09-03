//
//  socketServer.cpp
//  LeePlayer
//
//  Created by Lee Li on 2020/9/1.
//  Copyright © 2020 Lee Li. All rights reserved.
//


#include "socketServer.hpp"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <netinet/in.h>

#include "unistd.h"
#include <pthread.h>
using namespace std;
socketServer::socketServer(void)
:na(10)
,nb(20)
{
    printf("lee baseSocket1:%d,nb:%d\n",na,nb);
    m_tmout.tv_sec = 0;
    m_tmout.tv_usec = 20000;

}
socketServer::~socketServer()
{
     
}
void socketServer::test()
{
    printf("lee baseSocket:%d,nb:%d\n",na,nb);

    //创建套接字
    m_hSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    
    //将套接字和IP、端口绑定
    struct sockaddr_in serv_addr;
    memset(&serv_addr, 0, sizeof(serv_addr));  //每个字节都用0填充
    serv_addr.sin_family = AF_INET;  //使用IPv4地址
    
    serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
//    serv_addr.sin_addr.s_addr = inet_addr("127.0.0.1");  //具体的IP地址
    serv_addr.sin_port = htons(1234);  //端口
    
    bind(m_hSocket, (struct sockaddr*)&serv_addr, sizeof(serv_addr));
    //进入监听状态，等待用户发起请求
    listen(m_hSocket, 20);
    //接收客户端请求
    
    printf("main thread id is %p\n",pthread_self());

    start();

    
}

void socketServer::start()
{
    pthread_t tids;

    int nRet = pthread_create(&tids, NULL, (void*(*)(void*))listenClient1, this);
    
    printf("socketServer pthread_create:--->%d", nRet);

    if (nRet != 0)
    {
        printf("pthread_create error: error_code= %d",nRet);
    }

    
}
void* socketServer::listenClient1(void * arg)
{
    //https://stackoverflow.com/questions/1151582/pthread-function-from-a-class
    socketServer * temp =  (socketServer *)arg;
    temp->listenClient();
    return 0;
}

void* socketServer::listenClient()
{
    //监听client
    int clnt_sock;
    sleep(1);
    printf("listenClient thread id is %p\n",pthread_self());
    while (1)
    {
        
        int nRC = 0;
        
        FD_ZERO(&m_fdsRead);
        FD_SET(m_hSocket, &m_fdsRead);

        FD_ZERO(&m_fdsWrite);
        FD_SET(m_hSocket, &m_fdsWrite);

        FD_ZERO(&m_fdsExcept);
        FD_SET(m_hSocket, &m_fdsExcept);

        nRC = select (m_hSocket + 1 ,&m_fdsRead, &m_fdsWrite, &m_fdsExcept, &m_tmout);
        
        if (nRC < 0)
        {
            perror("select error");
            exit(-1);
        }
        else if (0 == nRC)
        {
            printf("无数据输入，等待超时.\n");
            sleep(1);
            
        }
        else
        {
            if (FD_ISSET (m_hSocket, &m_fdsRead))
            {
                printf("读取数据。。。.\n");
                // 这里处理Read事件
                struct sockaddr_in clnt_addr;
                socklen_t clnt_addr_size = sizeof(clnt_addr);
                clnt_sock = accept(m_hSocket, (struct sockaddr*)&clnt_addr, &clnt_addr_size);
                
                //向客户端发送数据
                char str[] = "http://c.biancheng.net/socket/";
                write(clnt_sock , str, sizeof(str));

            }

            if (FD_ISSET (m_hSocket, &m_fdsWrite))
            {
                 // 这里处理Write事件
            }

            if (FD_ISSET (m_hSocket, &m_fdsExcept))
            {
                // 这里处理Except事件
                printf("m_fdsExcept\n");
            }
        }
    }
    
        
//     关闭套接字
     close(clnt_sock);
     close(m_hSocket);
    
}
