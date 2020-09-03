//
//  baseServer.cpp
//  LeePlayer
//
//  Created by Lee Li on 2020/9/3.
//  Copyright © 2020 Lee Li. All rights reserved.
//

#include "baseServer.hpp"
baseServer::baseServer(void)
:na(10)
,nb(20)
{
    printf("lee baseServer:%d,nb:%d\n",na,nb);
}

baseServer::~baseServer()
{
     
}

void baseServer::start()
{
    printf("baseServer socket test");
    if (m_plistenSocket == NULL)
    {
        m_plistenSocket = new listenSocket(this, 3000);
    }
    
    m_plistenSocket->start();
    
}
