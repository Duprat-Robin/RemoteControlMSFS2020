#ifndef __SIM_SERVER_H__
#define __SIM_SERVER_H__

#include <string>
#include <windows.h>
#include "SimConnect.h"
#include <iostream>       // std::cout
#include <thread>         // std::thread
#include <mutex>          // std::mutex


enum DATA_DEFINE_ID {
	DEFINITION_1,
    DEFINITION_2,
    DEFINITION_TEST
}; //ID de datum (set de datas)

enum DATA_REQUEST_ID {
	REQUEST_TBASIC,
	REQUEST_2,
}; //ID d'un request

struct SimResponse {
	double altitude;
	int32_t heading;
	float speed;
	int32_t vertical_speed;
    float pitch;
    float bank;
};

struct Inputs {
    int32_t IsFired=0;
};



void CALLBACK MyDispatchProc1(SIMCONNECT_RECV* pData, DWORD cbData, void* pContext);
int initSimEvents();

extern int quit;
extern HANDLE hSimConnect;

extern SimResponse TBASIC;

extern std::mutex m_values_lock;

extern HRESULT hr;

extern Inputs isfired; 
/*
struct structThrottleControl 
{
	double throttlePercent;
};
*/
struct Simthrottle {
    int32_t throttle;
};
extern Simthrottle tc;

//void CALLBACK MyDispatchProc1(SIMCONNECT_RECV* pData, DWORD cbData, void* pContext);

///////////////////////////////////////////////////////////////////////////


#endif

