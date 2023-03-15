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

(*
**	send string msg to socket 'sock' and end-of-line
*)
procedure scSendLn(sock : TSocket; const msg : String);
const crlf  = #13#10;
var		buf : string;
begin
	buf := ConCat(msg, crlf);
	fpSend(sock, @buf[1], length(buf), 0);
end;

(*
**	receive a string from socket 'sock' and return the number of
**	bytes received minus the CRLF.
*)
function scRecvLn(sock : TSocket; var msg : String) : LongInt;
var n   : LongInt;
	buf : Array [0..1024] of Char;
begin
	msg := '';
	n := fpRecv(sock, @buf, 1024, 0);
	if n > 0 then begin
		buf[n] := #0;
		while n > 0 do begin
			if (buf[n-1] = #10) or (buf[n-1] = #13) then begin
				n := n - 1;
				buf[n] := #0;
				end
			else
				break;
			end;
		msg := PChar(@buf);
		end;
	scRecvLn := n;
end;

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
