(*
**	TCP client example by using FP's socket unit.
**	Nicholas Christopoulos <nereus@freemail.gr>
*)

Program SocketClient;
{$mode fpc}

Uses Sockets;

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
	fpSend(sock, @buf[1], length(buf), 1);
end;

(*
**	receive a string from socket 'sock' and return the number of
**	bytes received minus the CRLF.
*)
function scRecvLn(sock : TSocket; var msg : String) : LongInt;
var n   : LongInt;
	buf : Array [0..2047] of Char;
begin
	msg := '';
	n := fpRecv(sock, @buf, 2048, 0);
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
	host, msg	: string;
	sock		: TSocket;
	domain, protc, port, n : LongInt;

begin
	host   := 'localhost';
	port   := 4096;
	domain := AF_INET; (* or AF_UNIX, or AF_BLUETOOTH. etc *)
	protc  := IPPROTO_TCP;
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
					scSendLn(sock, 'test master');
					n := scRecvLn(sock, msg);
					if n > 0 then begin
						WriteLn('> ', msg);
						scSendLn(sock, 'quit master');
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
