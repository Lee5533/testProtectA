//
//  baseServer.hpp
//  LeePlayer
//
//  Created by Lee Li on 2020/9/3.
//  Copyright © 2020 Lee Li. All rights reserved.
//

#ifndef baseServer_hpp
#define baseServer_hpp

#include <stdio.h>
#include "listenSocket.hpp"

class baseServer
{
public:
    baseServer(void);
    virtual ~baseServer(void);
    
    int na;
    int nb;
    
    void start();
    listenSocket* m_plistenSocket;
private:
    
};
#endif /* baseServer_hpp */
