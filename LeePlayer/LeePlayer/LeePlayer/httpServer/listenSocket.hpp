//
//  listenSocket.hpp
//  LeePlayer
//
//  Created by Lee Li on 2020/9/3.
//  Copyright © 2020 Lee Li. All rights reserved.
//

#ifndef listenSocket_hpp
#define listenSocket_hpp

#include <stdio.h>
class listenSocket
{
public:
    listenSocket(void * hUserData, int nPortNum);
    virtual ~listenSocket(void);
    
    int na;
    int nb;
    
    void start();
private:
    
};

#endif /* listenSocket_hpp */
