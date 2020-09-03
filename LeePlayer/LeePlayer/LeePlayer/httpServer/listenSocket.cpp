//
//  listenSocket.cpp
//  LeePlayer
//
//  Created by Lee Li on 2020/9/3.
//  Copyright © 2020 Lee Li. All rights reserved.
//

#include "listenSocket.hpp"

listenSocket::listenSocket(void * hUserData, int nPortNum)
:na(10)
,nb(20)
{
    printf("lee listenSocket:%d,nb:%d\n",na,nb);
}

listenSocket::~listenSocket()
{
     
}

void listenSocket::start()
{
    printf("listern socket test");
}
