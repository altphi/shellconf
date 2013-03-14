function FindProxyForURL(url, host) {
     var P = "PROXY localhost:3128; DIRECT";
     if (shExpMatch(url,"*.iago*"))			{return P;}
     if (shExpMatch(url,"*iago*"))			{return P;}
     if (shExpMatch(url,"*.rove*"))			{return P;}
     if (shExpMatch(url,"*.sdev*"))			{return P;}
     if (shExpMatch(url,"*.phpmyadmin*"))		{return P;}
     if (shExpMatch(url,"*.coptix.lan*"))		{return P;}
     if (shExpMatch(url,"*.coptix.lan:3000"))		{return P;}
     if (shExpMatch(url,"http://ccc/*")) 		{return P;}
   /*if (shExpMatch(url,"http://*:9080*"))		{return P;}*/
     if (shExpMatch(url,"http://*:9081*"))		{return P;}
	 if (shExpMatch(url,"http://www.jstor.org*"))  {return "http://www.jstor.org.proxycu.wrlc.org/";}
     return "DIRECT";
}
