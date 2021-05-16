#include <string>
#include <vector>
#include <windows.h>
#include "SimConnect.h"
#include "sim_server.h"


Inputs isfired;
Radpan radpan;

void CALLBACK MyDispatchProc1(SIMCONNECT_RECV* pData, DWORD cbData, void* pContext) {
	switch (pData->dwID)
	{

	case SIMCONNECT_RECV_ID_SIMOBJECT_DATA:
	{
		SIMCONNECT_RECV_SIMOBJECT_DATA* pObjData = (SIMCONNECT_RECV_SIMOBJECT_DATA*)pData;

		switch (pObjData->dwRequestID)
		{
		case REQUEST_TBASIC:{

			SimResponse* provi = (SimResponse*)&pObjData->dwData;
            m_values_lock.lock();
            TBASIC.speed = provi->speed;
            TBASIC.pitch = provi->pitch;
            TBASIC.bank = provi->bank;
            m_values_lock.unlock();

            //sprintf(VAL_GLOBALE,"%f",pS->speed);
		    //std::cout << " - Speed (knots): " << pS->speed << " - Vertical Speed: " << pS->vertical_speed ;<< std::flush; */
			break;
        }
        case REQUEST_RADPANNEL:{
            Radpan* provi = (Radpan*)&pObjData->dwData;
            std::cout << "\nVHF1: " << provi->VHF1 << std::endl;
            break;
        }
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

enum GROUP_ID {
    GROUP0,
};


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

            hr = SimConnect_AddToDataDefinition(hSimConnect, DEFINITION_BREAKDOWNS, "ENG ON FIRE", "Bool", SIMCONNECT_DATATYPE_INT32);

            hr = SimConnect_AddToDataDefinition(hSimConnect, DEFINITION_RADPANNELS, "COM STANDBY FREQUENCY:1", "Megahertz", SIMCONNECT_DATATYPE_FLOAT32);
            hr = SimConnect_MapClientEventToSimEvent(hSimConnect, COM_RADIO_WHOLE_INC, "COM_RADIO_WHOLE_INC");
            hr = SimConnect_MapClientEventToSimEvent(hSimConnect, COM_RADIO_WHOLE_DEC, "COM_RADIO_WHOLE_DEC");

            hr = SimConnect_AddClientEventToNotificationGroup(hSimConnect, GROUP0, COM_RADIO_WHOLE_INC);
            hr = SimConnect_AddClientEventToNotificationGroup(hSimConnect, GROUP0, COM_RADIO_WHOLE_DEC);
            hr = SimConnect_SetNotificationGroupPriority(hSimConnect, GROUP0, SIMCONNECT_GROUP_PRIORITY_HIGHEST);


            // EVERY SECOND REQUEST DATA FOR DEFINITION 1 ON THE CURRENT USER AIRCRAFT (SIMCONNECT_OBJECT_ID_USER)
            hr = SimConnect_RequestDataOnSimObject(hSimConnect, REQUEST_TBASIC, DEFINITION_1, SIMCONNECT_OBJECT_ID_USER, SIMCONNECT_PERIOD_VISUAL_FRAME);
            hr = SimConnect_RequestDataOnSimObject(hSimConnect, REQUEST_RADPANNEL, DEFINITION_RADPANNELS, SIMCONNECT_OBJECT_ID_USER, SIMCONNECT_PERIOD_SECOND);

            // Process incoming SimConnect Server messages
            return 1;
	    }
        else {
            return 0;
        }
}

int parser(std::string strings) {
    char *buffer = &strings[0];
    DATUM datum;
    char values[100];
    sscanf(buffer,"%d:%s", &datum, values);
    printf("datum:%d,value:%s\n",datum,values);
    switch (datum) {
        case ISFIRED:{
            if (isfired.IsFired) {
                isfired.IsFired=0;
            }
            else {
                isfired.IsFired=1;
            }
            hr = SimConnect_SetDataOnSimObject(hSimConnect, DEFINITION_BREAKDOWNS, SIMCONNECT_OBJECT_ID_USER, 0, 0, sizeof(isfired),&isfired);
            std::cout << "panne feu envoyee\n";
            break;
        }
        case COM_RADIO_WHOLE_INC:{
            hr = SimConnect_TransmitClientEvent(hSimConnect, 0, COM_RADIO_WHOLE_INC, 0, SIMCONNECT_GROUP_PRIORITY_HIGHEST, SIMCONNECT_EVENT_FLAG_GROUPID_IS_PRIORITY);
            std::cout << "augmentation de frequence\n";
            break;
        }
        case COM_RADIO_WHOLE_DEC:{
            hr = SimConnect_TransmitClientEvent(hSimConnect, 0, COM_RADIO_WHOLE_DEC, 0, SIMCONNECT_GROUP_PRIORITY_HIGHEST, SIMCONNECT_EVENT_FLAG_GROUPID_IS_PRIORITY);
            std::cout << "diminution de frequence\n";
            break;
        }
        return 0;
    }
    return 1;
}