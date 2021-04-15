#ifndef __SIMSERVER_H__
#define __SIMSERVER_H__

#include <string>
#include <winsock2.h>

using namespace std;

extern float KtsVal;

bool initSimEvents();
void handleDispatch();
void closeDispatch();

#endif

