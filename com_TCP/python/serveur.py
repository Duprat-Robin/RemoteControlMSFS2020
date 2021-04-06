import socket
import time

time.time()
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((socket.gethostname(), 1234))
s.listen(1)
clientsocket, address = s.accept()
print("début des hostilités")
print(socket.gethostname())
while True:
    # now our endpoint knows about the OTHER endpoint.
  #  print(f"Connection from {address} has been established.")
    
   # print(clientsocket.send(bytes("{}\n".format(time.time()),"utf-8")))
    time.sleep(0.1)
    msg=clientsocket.recv(20)
    fmess=msg.decode("utf-8")
    print(fmess)


    

    