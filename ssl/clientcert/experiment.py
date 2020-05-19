#!/usr/bin/python3

import os
import socket
import ssl
import threading
import time

hostname = '127.0.0.1'
port = 40000

thisdir = os.path.dirname(os.path.realpath(__file__))
CA_FOLDER = thisdir + '/ca-rsa'
CLIENT_FOLDER = thisdir + '/client-rsa'
SERVER_FOLDER = thisdir + '/server-rsa'


def server_thread():
    #srvctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    srvctx = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
    srvctx.verify_mode = ssl.CERT_REQUIRED
    srvctx.load_cert_chain(
        SERVER_FOLDER + '/server.crt', SERVER_FOLDER + '/server.key')
    srvctx.load_verify_locations(CA_FOLDER + '/CA.Root.pem')

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM, 0) as sock:
        sock.bind((hostname, port))
        sock.listen(5)
        while True:
            print('waiting for client')
            newsock, addr = sock.accept()
            print("Client connected: {}:{}".format(addr[0], addr[1]))
            with srvctx.wrap_socket(newsock, server_side=True) as ssock:
                print("SSL established. Peer: {}".format(ssock.getpeercert()))
                buf = b''  # Buffer to hold received client data
                try:
                    while True:
                        data = ssock.recv(4096)
                        if data:
                            # Client sent us data. Append to buffer
                            buf += data
                        else:
                            # No more data from client. Show buffer and close connection.
                            print("Received:", buf)
                            break
                finally:
                    print("Closing connection")
                    ssock.shutdown(socket.SHUT_RDWR)
                    ssock.close()


def client_thread():
    # PROTOCOL_TLS_CLIENT requires valid cert chain and hostname
    #cltctx = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
    #cltctx.load_verify_locations(CLIENT_FOLDER + '/client.crt')
    cltctx = ssl.create_default_context(
        ssl.Purpose.SERVER_AUTH)
    # ssl.Purpose.SERVER_AUTH, cafile=SERVER_FOLDER + '/server.crt')
    cltctx.load_cert_chain(certfile=CLIENT_FOLDER + '/client.crt',
                           keyfile=CLIENT_FOLDER + '/client.key')
    cltctx.load_verify_locations(CA_FOLDER + '/CA.Root.pem')

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM, 0) as sock:
        with cltctx.wrap_socket(sock, server_side=False, server_hostname=hostname) as ssock:
            print(ssock.version())
            ssock.connect((hostname, port))
            print("SSL established. Peer: {}".format(ssock.getpeercert()))
            print("Sending: 'Hello, world!")
            ssock.send(b"Hello, world!")
            print("Closing connection")
            ssock.close()


def main():
    print('Starting!')
    srv = threading.Thread(target=server_thread, name='SERVER')
    clt = threading.Thread(target=client_thread, name='CLIENT')
    srv.start()
    time.sleep(1)
    clt.start()
    clt.join()
    srv.join()


main()
