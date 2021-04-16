#include <windows.h>
#include <iostream>

#include "SimConnect.h"

#include <stdio.h>
#include <conio.h>
#include <tchar.h>

#define BUF_SIZE 256
TCHAR szName[]=TEXT("Global\\MyFileMappingObject");
TCHAR szMsg[40]=TEXT("100.000");

HANDLE hMapFile;
LPCTSTR pBuf;

int config()
{
  

   hMapFile = CreateFileMapping(
                 INVALID_HANDLE_VALUE,    // use paging file
                 NULL,                    // default security
                 PAGE_READWRITE,          // read/write access
                 0,                       // maximum object size (high-order DWORD)
                 BUF_SIZE,                // maximum object size (low-order DWORD)
                 szName);                 // name of mapping object

   if (hMapFile == NULL)
   {
      _tprintf(TEXT("Could not create file mapping object (%d).\n"),
             GetLastError());
      return 1;
   }
   pBuf = (LPTSTR) MapViewOfFile(hMapFile,   // handle to map object
                        FILE_MAP_ALL_ACCESS, // read/write permission
                        0,
                        0,
                        BUF_SIZE);

   if (pBuf == NULL)
   {
      _tprintf(TEXT("Could not map view of file (%d).\n"),
             GetLastError());

       CloseHandle(hMapFile);

      return 1;
   }


   CopyMemory((PVOID)pBuf, szMsg, (_tcslen(szMsg) * sizeof(TCHAR)));
  
   return 0;
}


int quit = 0;
HANDLE hSimConnect = NULL;


enum DATA_DEFINE_ID {
	DEFINITION_1,
};

enum DATA_REQUEST_ID {
	REQUEST_1,
	REQUEST_2,
};

struct SimResponse {
	double altitude;
	int32_t heading;
	float speed;
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
			_stprintf(szMsg, TEXT("%f"), pS->speed);
			CopyMemory((PVOID)pBuf, szMsg, (_tcslen(szMsg) * sizeof(TCHAR)));
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
	std::cout<< "configuration en cours\n";
	HRESULT hr;
	config();
	if (SUCCEEDED(SimConnect_Open(&hSimConnect, "Client Event Demo", NULL, 0, NULL, 0))) {
		std::cout << "\nConnected To Microsoft Flight Simulator 2020!\n";


		// DATA
		hr = SimConnect_AddToDataDefinition(hSimConnect, DEFINITION_1, "Indicated Altitude", "feet");
		hr = SimConnect_AddToDataDefinition(hSimConnect, DEFINITION_1, "HEADING INDICATOR", "degrees", SIMCONNECT_DATATYPE_INT32);
		hr = SimConnect_AddToDataDefinition(hSimConnect, DEFINITION_1, "Airspeed Indicated", "knots", SIMCONNECT_DATATYPE_FLOAT32);
		hr = SimConnect_AddToDataDefinition(hSimConnect, DEFINITION_1, "VERTICAL SPEED", "Feet per second", SIMCONNECT_DATATYPE_INT32);

		// EVERY SECOND REQUEST DATA FOR DEFINITION 1 ON THE CURRENT USER AIRCRAFT (SIMCONNECT_OBJECT_ID_USER)
		hr = SimConnect_RequestDataOnSimObject(hSimConnect, REQUEST_1, DEFINITION_1, SIMCONNECT_OBJECT_ID_USER, SIMCONNECT_PERIOD_VISUAL_FRAME);

		// Process incoming SimConnect Server messages
		int compteur =0;
		while (quit == 0 && _kbhit()==0) {
			// Continuously call SimConnect_CallDispatch until quit - MyDispatchProc1 will handle simulation events
			SimConnect_CallDispatch(hSimConnect, MyDispatchProc1, NULL);
			Sleep(25);
		}
		
		hr = SimConnect_Close(hSimConnect);
		return true;
	}
	else {
		std::cout << "\nFailed to Connect!!!!\n";
		while (_kbhit()==0) {

		}
		return false;
	}

}

int main() {
	initSimEvents();
	UnmapViewOfFile(pBuf);

    CloseHandle(hMapFile);

	return 0;
}