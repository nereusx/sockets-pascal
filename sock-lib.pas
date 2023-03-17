(*
**	send string msg to socket 'sock' and end-of-line
*)
procedure scSendLn(sock : TSocket; const msg : String);
const crlf = #13#10;
var buf : string;
begin
	buf := ConCat(msg, crlf);
	fpSend(sock, @buf[1], length(buf), 0);
end;

(*
**	receive a string from socket 'sock' and return the number of
**	bytes received minus the CRLF.
*)
function scRecvLn(sock : TSocket; var msg : String) : LongInt;
var n : LongInt;
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

