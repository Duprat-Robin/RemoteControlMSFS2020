#include <windows.h>
#include "SimConnect.h"
#include "sim_server.h"

void CALLBACK MyDispatchProc1(SIMCONNECT_RECV* pData, DWORD cbData, void* pContext) {
	switch (pData->dwID)
	{

	case SIMCONNECT_RECV_ID_SIMOBJECT_DATA:
	{
		SIMCONNECT_RECV_SIMOBJECT_DATA* pObjData = (SIMCONNECT_RECV_SIMOBJECT_DATA*)pData;

		switch (pObjData->dwRequestID)
		{
		case REQUEST_TBASIC:

			SimResponse* provi = (SimResponse*)&pObjData->dwData;
            m_values_lock.lock();
            TBASIC.speed = provi->speed;
            TBASIC.pitch = provi->pitch;
            TBASIC.bank = provi->bank;
            m_values_lock.unlock();
            

//            sprintf(VAL_GLOBALE,"%f",pS->speed);

		/*	std::cout << " - Speed (knots): " << pS->speed << " - Vertical Speed: " << pS->vertical_speed ;<< std::flush; */
			break;
		}
		break;
	}

	case SIMCONNECT_RECV_ID_QUIT:
	{
		quit = 1;
		break;
	}

	default:
		break;
	}
}

HRESULT hr;
int initSimEvents() {
        
        if (SUCCEEDED(SimConnect_Open(&hSimConnect, "Client Event Demo", NULL, 0, NULL, 0))) {
            std::cout << "\nConnected To Microsoft Flight Simulator 2020!\n";

            //DEFINITION <=> priority 
            // DATA
            hr = SimConnect_AddToDataDefinition(hSimConnect, DEFINITION_1, "Indicated Altitude", "feet");
            hr = SimConnect_AddToDataDefinition(hSimConnect, DEFINITION_1, "HEADING INDICATOR", "degrees", SIMCONNECT_DATATYPE_INT32);
            hr = SimConnect_AddToDataDefinition(hSimConnect, DEFINITION_1, "Airspeed Indicated", "knots", SIMCONNECT_DATATYPE_FLOAT32);
            hr = SimConnect_AddToDataDefinition(hSimConnect, DEFINITION_1, "VERTICAL SPEED", "Feet per second", SIMCONNECT_DATATYPE_INT32);
            hr = SimConnect_AddToDataDefinition(hSimConnect, DEFINITION_1, "ATTITUDE INDICATOR PITCH DEGREES", "Radians", SIMCONNECT_DATATYPE_FLOAT32);
            hr = SimConnect_AddToDataDefinition(hSimConnect, DEFINITION_1, "ATTITUDE INDICATOR BANK DEGREES", "Radians", SIMCONNECT_DATATYPE_FLOAT32);

            hr = SimConnect_AddToDataDefinition(hSimConnect, DEFINITION_2, "ENG ON FIRE", "Bool", SIMCONNECT_DATATYPE_INT32);

            hr = SimConnect_AddToDataDefinition(hSimConnect, DEFINITION_TEST, "VERTICAL SPEED", "Feet per second",SIMCONNECT_DATATYPE_INT32);
            // EVERY SECOND REQUEST DATA FOR DEFINITION 1 ON THE CURRENT USER AIRCRAFT (SIMCONNECT_OBJECT_ID_USER)
            hr = SimConnect_RequestDataOnSimObject(hSimConnect, REQUEST_TBASIC, DEFINITION_1, SIMCONNECT_OBJECT_ID_USER, SIMCONNECT_PERIOD_VISUAL_FRAME);

            // Process incoming SimConnect Server messages
            return 1;
	    }
        else {
            return 0;
        }
}

Inputs isfired;