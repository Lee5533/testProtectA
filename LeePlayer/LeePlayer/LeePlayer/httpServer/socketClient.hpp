//
//  socketClient.hpp
//  LeePlayer
//
//  Created by Lee Li on 2020/9/1.
//  Copyright © 2020 Lee Li. All rights reserved.
//

#ifndef socketClient_hpp
#define socketClient_hpp

#include <stdio.h>

class socketClient
{
public:
    socketClient(void);
    virtual ~socketClient(void);
    
    int na;
    int nb;
    
    void test();
    void start();
    static void* connectServer(void* arg);
    void connectThreadLoop();
    
};
#endif /* socketClient_hpp */
