#ifndef __SERVER_H__
#define __SERVER_H__

#include <string>
#include <winsock2.h>

using namespace std;

extern SOCKET s;

SOCKET init(char * ipadr, int nport);

int send_a_mess(SOCKET sc, char * mess);

#endif

