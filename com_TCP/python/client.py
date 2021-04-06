import socket
import time

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(("192.168.137.1",1234))

while True:
    full_msg=""
    while True:
        full_msg=""
      #  msg=s.recv(100)
       # full_msg = msg.decode("utf-8")

        #if len(full_msg) > 0:
       #     print(full_msg)
        time.sleep(0.1)
        s.send(bytes("message reçu\n","utf-8"))
