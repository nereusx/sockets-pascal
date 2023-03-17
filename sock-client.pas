(*
**	TCP client example by using FP's socket unit.
**	Nicholas Christopoulos <nereus@freemail.gr>
*)

Program SocketClient;
{$MODE fpc}{$LONGSTRINGS+}{$CODEPAGE UTF8}
{$DESCRIPTION Socket client example by using standard sockets}

Uses Sockets;

const
	host   = 'localhost';
	port   : LongInt = 4096;
	domain = AF_INET; (* or AF_UNIX, or AF_BLUETOOTH. etc *)
	protc  = IPPROTO_TCP;

(*
**	print error message...
*)
procedure Warn(const msg : string);
begin
	WriteLn(msg, '; socket error=', SocketError);
end;

(* send/recieve functions *)
{$INCLUDE common.pas}

(* === main === *)
Var
	saddr		: TSockAddr; (* or TUnixSockAddr; *)
	msg			: string;
	sock		: TSocket;
	n 			: LongInt;

begin
	sock   := fpSocket(domain, SOCK_STREAM, protc);
	if sock <> -1 then begin
		saddr.sin_family := domain;
		saddr.sin_port   := htons(port);
		saddr.sin_addr   := StrToHostAddr(host);
		if fpConnect(sock, @saddr, sizeOf(saddr)) = 0 then begin
			repeat
				n := scRecvLn(sock, msg);
				if n > 0 then begin
					WriteLn('> ', msg);
					msg := 'test master';
					scSendLn(sock, msg);
					WriteLn('< ', msg);
					n := scRecvLn(sock, msg);
					if n > 0 then begin
						WriteLn('> ', msg);
						msg := 'quit';
						scSendLn(sock, msg);
						WriteLn('< ', msg);
						n := scRecvLn(sock, msg);
						if n > 0 then WriteLn('> ', msg);
						end
					end
			until n <= 0;
			end
		else warn('failed to connect');
		CloseSocket(sock);
		end
	else warn('create socket failed')
end.
