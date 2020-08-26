//
//  baseSocket.cpp
//  LeePlayer
//
//  Created by Lee Li on 2020/8/26.
//  Copyright © 2020 Lee Li. All rights reserved.
//

#include "baseSocket.hpp"
baseSocket::baseSocket(void)
:na(10)
,nb(20)
{
    printf("lee baseSocket1:%d,nb:%d\n",na,nb);
}
baseSocket::~baseSocket()
{
     
}
void baseSocket::test()
{
    printf("lee baseSocket:%d,nb:%d\n",na,nb);
}
