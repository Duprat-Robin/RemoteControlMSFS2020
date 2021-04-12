#include "server.h"
#include <io.h>
#include <stdio.h>
#include <winsock2.h>
#include <string.h>
#pragma comment(lib,"ws2_32.lib") //Winsock Library

using namespace std; 

SOCKET s = NULL;

SOCKET init(char * ipadr, int nport)
{
    WSADATA wsa;
    SOCKET new_socket;
    struct sockaddr_in server , client;
    int c;
    char *message;
 
    printf("\nInitialising Winsock...");
    if (WSAStartup(MAKEWORD(2,2),&wsa) != 0)
    {
        printf("Failed. Error Code : %d",WSAGetLastError());
        return 1;
    }
     
    printf("Initialised.\n");
     
    //Create a socket
    if((s = socket(AF_INET , SOCK_STREAM , 0 )) == INVALID_SOCKET)
    {
        printf("Could not create socket : %d" , WSAGetLastError());
    }
 
    printf("Socket created.\n");
     
    //Prepare the sockaddr_in structure
    server.sin_family = AF_INET;
//    server.sin_addr.s_addr = INADDR_ANY;
    server.sin_addr.s_addr = inet_addr(ipadr);
    server.sin_port = htons( nport );
     
    //Bind
    if( bind(s ,(struct sockaddr *)&server , sizeof(server)) == SOCKET_ERROR)
    {
        printf("Bind failed with error code : %d" , WSAGetLastError());
    }
     
    puts("Bind done");
 
    //Listen to incoming connections
    listen(s , 2);
     
    //Accept and incoming connection
    puts("Waiting for incoming connections...");
    c = sizeof(struct sockaddr_in);
    new_socket = accept(s , (struct sockaddr *)&client, &c);
    if (new_socket == INVALID_SOCKET)
    {
        printf("accept failed with error code : %d" , WSAGetLastError());
    }
     
    puts("Connection accepted");
 
    //Reply to client
    message = "Hello Client , I have received your connection\n";
    send(new_socket , message , strlen(message) , 0);

   // closesocket(s);
   // WSACleanup();
     
    return new_socket;
}

int send_a_mess(SOCKET sc,char * mess) {
    return send(sc, mess, strlen(mess), 0);
}
/*
int main() {
    SOCKET sclient = init("10.1.129.157",9999);

    char message[] = "Hello World !\n";
    send_a_mess(sclient, message);
    getchar();
    send_a_mess(sclient, message);
    closesocket(s);
    WSACleanup();
    return 0;
} */