#
PC      := fpc
PCFLAGS := -g -O2 -XS

all: sock-serv sock-client

sock-serv: sock-serv.pas
	$(PC) $(PCFLAGS) sock-serv

sock-client: sock-client.pas
	$(PC) $(PCFLAGS) sock-client

clean:
	rm -f *.o sock-serv sock-client
