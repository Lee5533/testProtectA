//
//  socketServer.hpp
//  LeePlayer
//
//  Created by Lee Li on 2020/9/1.
//  Copyright © 2020 Lee Li. All rights reserved.
//

#ifndef socketServer_hpp
#define socketServer_hpp

#include <stdio.h>
#include <sys/time.h>
#include <sys/socket.h>
#include <pthread.h>
class socketServer
{
public:
    socketServer(void);
    virtual ~socketServer(void);
    
    int na;
    int nb;
    
    void test();
    void start();
    void* listenClient();
    static void* listenClient1();
    
    int                m_hSocket;
    fd_set            m_fdsRead;
    fd_set            m_fdsWrite;
    fd_set            m_fdsExcept;
    timeval            m_tmout;
    
    };

#endif /* socketServer_hpp */
