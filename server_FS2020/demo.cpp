#include <windows.h>
#include <iostream>

#include "SimConnect.h"

int quit = 0;
HANDLE hSimConnect = NULL;


static enum DATA_DEFINE_ID {
	DEFINITION_1,
};

static enum DATA_REQUEST_ID {
	REQUEST_1,
	REQUEST_2,
};

struct SimResponse {
	double altitude;
	int32_t heading;
	int32_t speed;
	int32_t vertical_speed;
};

void CALLBACK MyDispatchProc1(SIMCONNECT_RECV* pData, DWORD cbData, void* pContext) {
	switch (pData->dwID)
	{

	case SIMCONNECT_RECV_ID_SIMOBJECT_DATA:
	{
		SIMCONNECT_RECV_SIMOBJECT_DATA* pObjData = (SIMCONNECT_RECV_SIMOBJECT_DATA*)pData;

		switch (pObjData->dwRequestID)
		{
		case REQUEST_1:

			SimResponse* pS = (SimResponse*)&pObjData->dwData;

			std::cout
				
				<< "\rAltitude: " << pS->altitude
				<< " - Heading: " << pS->heading
				<< " - Speed (knots): " << pS->speed
				<< " - Vertical Speed: " << pS->vertical_speed
				
				<< std::flush;

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

bool initSimEvents() {
	HRESULT hr;

	if (SUCCEEDED(SimConnect_Open(&hSimConnect, "Client Event Demo", NULL, 0, NULL, 0))) {
		std::cout << "\nConnected To Microsoft Flight Simulator 2020!\n";

		// DATA
		hr = SimConnect_AddToDataDefinition(hSimConnect, DEFINITION_1, "Indicated Altitude", "feet");
		hr = SimConnect_AddToDataDefinition(hSimConnect, DEFINITION_1, "HEADING INDICATOR", "degrees", SIMCONNECT_DATATYPE_INT32);
		hr = SimConnect_AddToDataDefinition(hSimConnect, DEFINITION_1, "Airspeed Indicated", "knots", SIMCONNECT_DATATYPE_INT32);
		hr = SimConnect_AddToDataDefinition(hSimConnect, DEFINITION_1, "VERTICAL SPEED", "Feet per second", SIMCONNECT_DATATYPE_INT32);

		// EVERY SECOND REQUEST DATA FOR DEFINITION 1 ON THE CURRENT USER AIRCRAFT (SIMCONNECT_OBJECT_ID_USER)
		hr = SimConnect_RequestDataOnSimObject(hSimConnect, REQUEST_1, DEFINITION_1, SIMCONNECT_OBJECT_ID_USER, SIMCONNECT_PERIOD_SECOND);

		// Process incoming SimConnect Server messages
		while (quit == 0) {
			// Continuously call SimConnect_CallDispatch until quit - MyDispatchProc1 will handle simulation events
			SimConnect_CallDispatch(hSimConnect, MyDispatchProc1, NULL);
			Sleep(1);
		}

		hr = SimConnect_Close(hSimConnect);
		return true;
	}
	else {
		std::cout << "\nFailed to Connect!!!!\n";
		return false;
	}
}

int main() {
	initSimEvents();

	return 0;
}