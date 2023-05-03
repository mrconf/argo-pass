#!/usr/bin/env bash

# Define UUID and masquerade path, please modify it yourself. (Note: The masquerading path starts with / symbol, in order to avoid unnecessary trouble, please do not use special symbols.)
UUID=${UUID:-'de04add9-5c68-8bab-950c-08cd5320df18'}
VMESS_WSPATH=${VMESS_WSPATH:-'/vmess'}
VLESS_WSPATH=${VLESS_WSPATH:-'/vless'}
TROJAN_WSPATH=${TROJAN_WSPATH:-'/trojan'}
SS_WSPATH=${SS_WSPATH:-'/shadowsocks'}
sed -i "s#UUID#$UUID#g;s#VMESS_WSPATH#${VMESS_WSPATH}#g;s#VLESS_WSPATH#${VLESS_WSPATH}#g;s#TROJAN_WSPATH#${TROJAN_WSPATH}#g;s#SS_WSPATH#${SS_WSPATH}#g" config.json
sed -i "s#VMESS_WSPATH#${VMESS_WSPATH}#g;s#VLESS_WSPATH#${VLESS_WSPATH}#g;s#TROJAN_WSPATH#${TROJAN_WSPATH}#g;s#SS_WSPATH#${SS_WSPATH}#g" /etc/nginx/nginx.conf

# Set nginx masquerade station
rm -rf /usr/share/nginx/*
wget https://gitlab.com/Misaka-blog/xray-paas/-/raw/main/mikutap.zip -O /usr/share/nginx/mikutap.zip
unzip -o "/usr/share/nginx/mikutap.zip" -d /usr/share/nginx/html
rm -f /usr/share/nginx/mikutap.zip

# Fake xray executable file
RELEASE_RANDOMNESS=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6)
mv xray ${RELEASE_RANDOMNESS}
wget https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat
wget https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat
cat config.json | base64 > config
rm -f config.json

# If there are three variables set for the Nezha probe, it will be installed. If not filled or incomplete, it will not be installed
[ -n "${NEZHA_SERVER}" ] && [ -n "${NEZHA_PORT}" ] && [ -n "${NEZHA_KEY}" ] && wget https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh -O nezha.sh && chmod +x nezha.sh && ./nezha.sh install_agent ${NEZHA_SERVER} ${NEZHA_PORT} ${NEZHA_KEY}

# Enable Argo, and output node logs
cloudflared tunnel --url http://localhost:80 --no-autoupdate > argo.log 2>&1 &
sleep 5 && argo_url=$(cat argo.log | grep -oE "https://.*[a-z]+cloudflare.com" | sed "s#https://##")

vmlink=$(echo -e '\x76\x6d\x65\x73\x73')://$(echo -n "{\"v\":\"2\",\"ps\":\"Argo_xray_vmess\",\"add\":\"$argo_url\",\"port\":\"443\",\"id\":\"$UUID\",\"aid\":\"0\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"$argo_url\",\"path\":\"$VMESS_WSPATH?ed=2048\",\"tls\":\"tls\"}" | base64 -w 0)
vllink=$(echo -e '\x76\x6c\x65\x73\x73')"://"$UUID"@"$argo_url":443?encryption=none&security=tls&type=ws&host="$argo_url"&path="$VLESS_WSPATH"?ed=2048#Argo_xray_vless"
trlink=$(echo -e '\x74\x72\x6f\x6a\x61\x6e')"://"$UUID"@"$argo_url":443?security=tls&type=ws&host="$argo_url"&path="$TROJAN_WSPATH"?ed2048#Argo_xray_trojan"

qrencode -o /usr/share/nginx/html/M$UUID.png $vmlink
qrencode -o /usr/share/nginx/html/L$UUID.png $vllink
qrencode -o /usr/share/nginx/html/T$UUID.png $trlink

cat > /usr/share/nginx/html/$UUID.html<<-EOF

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
 <head>
     <meta charset="utf-8" />
     <title>MrPanda-Xray</title>
     <!-- Link Favicon -->
     <link rel="shortcut icon" href="favicon.png" type="image/x-png"/>
     <style>
        .buttonA {
           border: none;
           color: white;
           padding: 15px 40px;
           text-align: center;
           text-decoration: none;
           display: inline-block;
           font-size: 25px;
           margin: 15px 20px;
           transition-duration: 0.3s;
           cursor: pointer;
         }
         .button1 {
           background-color: white;
           color: black;
           border: 2px solid #D30000;
         }
         .button1:hover {
           background-color: #D30000;
           color: white;
         }
         .button2 {
           background-color: white;
           color: black;
           border: 2px solid #008CBA;
         }

         .button2:hover {
           background-color: #008CBA;
           color: white;
         }
         .button3 {
           background-color: white;
           color: black;
           border: 2px solid #5953A2;
         }

         .button3:hover {
           background-color: #5953A2;
           color: white;
         }

        .buttonx {
           border: none;
           color: white;
           padding: 15px 15px;
           text-align: center;
           text-decoration: none;
           display: inline-block;
           font-size: 25px;
           margin: 15px 20px;
           transition-duration: 0.3s;
           cursor: pointer;
         }
         .button4 {
           background-color: white;
           color: black;
           border: 2px solid #2F4F4F;
         }
         .button4:hover {
           background-color: #2F4F4F;
           color: #E9967A;
         }
         .button5 {
           background-color: white;
           color: black;
           border: 2px solid #6A5ABC;
         }

         .button5:hover {
           background-color: #6A5ABC;
           color: #E9967A;
         }
         .button6 {
           background-color: white;
           color: black;
           border: 2px solid #1E90FF;
         }

         .button6:hover {
           background-color: #1E90FF;
           color: #F38020;
         }
     </style>
 </head>
<body>
    <header>
        <font face="Gabriola" color="#009900"><h2 align="center"><b>MrPanda-ArgoPass</b></h2></font>
    </header>
    <hr>
    <p>
        <b><font face="Helvetica" size="4" color="#009900">Argo-Xray Informaion:</font></b>
    </p>
    <table style="width:70%" border="1" cellpadding="5" cellspacing="5">
        <tr>
            <th>Adress</th>
            <th>Port</th>
            <th>UUID</th>
            <th>Encryption method</th>
            <th>TP Protocol</th>
            <th>WS Host</th>
            <th>Path</th>
            <th>TLS</th>
            <th>SNI</th>
        </tr>
        <tr>
            <td>$argo_url</td>
            <td>443</td>
            <td>$UUID</td>
            <td>auto</td>
            <td>WS</td>
            <td>$argo_url</td>
            <td>/vmess?ed=2048 <br> /vless?ed=2048 <br> /trojan?ed=2048</td>
            <td>ON</td>
            <td>$argo_url</td>
        </tr>
    </table>
    <hr>
    <font face="Helvetica" size="4" color="#009900"><b>V2Ray Argo-URL:</b></font>
    <br>
	<button id="VMess1" onclick="VMess1()" class="buttonA button1"> 
    <?xml version="1.0" encoding="utf-8"?><svg fill="currentColor" width="25" height="25" version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 115.77 122.88" style="enable-background:new 0 0 115.77 122.88" xml:space="preserve"><style type="text/css">.st0{fill-rule:evenodd;clip-rule:evenodd;}</style><g><path class="st0" d="M89.62,13.96v7.73h12.19h0.01v0.02c3.85,0.01,7.34,1.57,9.86,4.1c2.5,2.51,4.06,5.98,4.07,9.82h0.02v0.02 v73.27v0.01h-0.02c-0.01,3.84-1.57,7.33-4.1,9.86c-2.51,2.5-5.98,4.06-9.82,4.07v0.02h-0.02h-61.7H40.1v-0.02 c-3.84-0.01-7.34-1.57-9.86-4.1c-2.5-2.51-4.06-5.98-4.07-9.82h-0.02v-0.02V92.51H13.96h-0.01v-0.02c-3.84-0.01-7.34-1.57-9.86-4.1 c-2.5-2.51-4.06-5.98-4.07-9.82H0v-0.02V13.96v-0.01h0.02c0.01-3.85,1.58-7.34,4.1-9.86c2.51-2.5,5.98-4.06,9.82-4.07V0h0.02h61.7 h0.01v0.02c3.85,0.01,7.34,1.57,9.86,4.1c2.5,2.51,4.06,5.98,4.07,9.82h0.02V13.96L89.62,13.96z M79.04,21.69v-7.73v-0.02h0.02 c0-0.91-0.39-1.75-1.01-2.37c-0.61-0.61-1.46-1-2.37-1v0.02h-0.01h-61.7h-0.02v-0.02c-0.91,0-1.75,0.39-2.37,1.01 c-0.61,0.61-1,1.46-1,2.37h0.02v0.01v64.59v0.02h-0.02c0,0.91,0.39,1.75,1.01,2.37c0.61,0.61,1.46,1,2.37,1v-0.02h0.01h12.19V35.65 v-0.01h0.02c0.01-3.85,1.58-7.34,4.1-9.86c2.51-2.5,5.98-4.06,9.82-4.07v-0.02h0.02H79.04L79.04,21.69z M105.18,108.92V35.65v-0.02 h0.02c0-0.91-0.39-1.75-1.01-2.37c-0.61-0.61-1.46-1-2.37-1v0.02h-0.01h-61.7h-0.02v-0.02c-0.91,0-1.75,0.39-2.37,1.01 c-0.61,0.61-1,1.46-1,2.37h0.02v0.01v73.27v0.02h-0.02c0,0.91,0.39,1.75,1.01,2.37c0.61,0.61,1.46,1,2.37,1v-0.02h0.01h61.7h0.02 v0.02c0.91,0,1.75-0.39,2.37-1.01c0.61-0.61,1-1.46,1-2.37h-0.02V108.92L105.18,108.92z"/></g></svg>
	Copy Vmess
	</button>
	    <script>
        var pre = document.getElementById("VMess1");
        function VMess1(){
        navigator.clipboard.writeText("$vmlink");
        }
    </script>
	
	<br>
	
    <button id="VLess1" onclick="VLess1()" class="buttonA button2">
	<?xml version="1.0" encoding="utf-8"?><svg fill="currentColor" width="25" height="25" version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 115.77 122.88" style="enable-background:new 0 0 115.77 122.88" xml:space="preserve"><style type="text/css">.st0{fill-rule:evenodd;clip-rule:evenodd;}</style><g><path class="st0" d="M89.62,13.96v7.73h12.19h0.01v0.02c3.85,0.01,7.34,1.57,9.86,4.1c2.5,2.51,4.06,5.98,4.07,9.82h0.02v0.02 v73.27v0.01h-0.02c-0.01,3.84-1.57,7.33-4.1,9.86c-2.51,2.5-5.98,4.06-9.82,4.07v0.02h-0.02h-61.7H40.1v-0.02 c-3.84-0.01-7.34-1.57-9.86-4.1c-2.5-2.51-4.06-5.98-4.07-9.82h-0.02v-0.02V92.51H13.96h-0.01v-0.02c-3.84-0.01-7.34-1.57-9.86-4.1 c-2.5-2.51-4.06-5.98-4.07-9.82H0v-0.02V13.96v-0.01h0.02c0.01-3.85,1.58-7.34,4.1-9.86c2.51-2.5,5.98-4.06,9.82-4.07V0h0.02h61.7 h0.01v0.02c3.85,0.01,7.34,1.57,9.86,4.1c2.5,2.51,4.06,5.98,4.07,9.82h0.02V13.96L89.62,13.96z M79.04,21.69v-7.73v-0.02h0.02 c0-0.91-0.39-1.75-1.01-2.37c-0.61-0.61-1.46-1-2.37-1v0.02h-0.01h-61.7h-0.02v-0.02c-0.91,0-1.75,0.39-2.37,1.01 c-0.61,0.61-1,1.46-1,2.37h0.02v0.01v64.59v0.02h-0.02c0,0.91,0.39,1.75,1.01,2.37c0.61,0.61,1.46,1,2.37,1v-0.02h0.01h12.19V35.65 v-0.01h0.02c0.01-3.85,1.58-7.34,4.1-9.86c2.51-2.5,5.98-4.06,9.82-4.07v-0.02h0.02H79.04L79.04,21.69z M105.18,108.92V35.65v-0.02 h0.02c0-0.91-0.39-1.75-1.01-2.37c-0.61-0.61-1.46-1-2.37-1v0.02h-0.01h-61.7h-0.02v-0.02c-0.91,0-1.75,0.39-2.37,1.01 c-0.61,0.61-1,1.46-1,2.37h0.02v0.01v73.27v0.02h-0.02c0,0.91,0.39,1.75,1.01,2.37c0.61,0.61,1.46,1,2.37,1v-0.02h0.01h61.7h0.02 v0.02c0.91,0,1.75-0.39,2.37-1.01c0.61-0.61,1-1.46,1-2.37h-0.02V108.92L105.18,108.92z"/></g></svg>
	Copy Vless
	</button>
    <script>
        var pre = document.getElementById("VLess1");
        function VLess1(){
        navigator.clipboard.writeText("$vllink");
        }
    </script>
	<br>
    <button id="Trojan1" onclick="Trojan1()" class="buttonA button3">
	<?xml version="1.0" encoding="utf-8"?><svg fill="currentColor" width="25" height="25" version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 115.77 122.88" style="enable-background:new 0 0 115.77 122.88" xml:space="preserve"><style type="text/css">.st0{fill-rule:evenodd;clip-rule:evenodd;}</style><g><path class="st0" d="M89.62,13.96v7.73h12.19h0.01v0.02c3.85,0.01,7.34,1.57,9.86,4.1c2.5,2.51,4.06,5.98,4.07,9.82h0.02v0.02 v73.27v0.01h-0.02c-0.01,3.84-1.57,7.33-4.1,9.86c-2.51,2.5-5.98,4.06-9.82,4.07v0.02h-0.02h-61.7H40.1v-0.02 c-3.84-0.01-7.34-1.57-9.86-4.1c-2.5-2.51-4.06-5.98-4.07-9.82h-0.02v-0.02V92.51H13.96h-0.01v-0.02c-3.84-0.01-7.34-1.57-9.86-4.1 c-2.5-2.51-4.06-5.98-4.07-9.82H0v-0.02V13.96v-0.01h0.02c0.01-3.85,1.58-7.34,4.1-9.86c2.51-2.5,5.98-4.06,9.82-4.07V0h0.02h61.7 h0.01v0.02c3.85,0.01,7.34,1.57,9.86,4.1c2.5,2.51,4.06,5.98,4.07,9.82h0.02V13.96L89.62,13.96z M79.04,21.69v-7.73v-0.02h0.02 c0-0.91-0.39-1.75-1.01-2.37c-0.61-0.61-1.46-1-2.37-1v0.02h-0.01h-61.7h-0.02v-0.02c-0.91,0-1.75,0.39-2.37,1.01 c-0.61,0.61-1,1.46-1,2.37h0.02v0.01v64.59v0.02h-0.02c0,0.91,0.39,1.75,1.01,2.37c0.61,0.61,1.46,1,2.37,1v-0.02h0.01h12.19V35.65 v-0.01h0.02c0.01-3.85,1.58-7.34,4.1-9.86c2.51-2.5,5.98-4.06,9.82-4.07v-0.02h0.02H79.04L79.04,21.69z M105.18,108.92V35.65v-0.02 h0.02c0-0.91-0.39-1.75-1.01-2.37c-0.61-0.61-1.46-1-2.37-1v0.02h-0.01h-61.7h-0.02v-0.02c-0.91,0-1.75,0.39-2.37,1.01 c-0.61,0.61-1,1.46-1,2.37h0.02v0.01v73.27v0.02h-0.02c0,0.91,0.39,1.75,1.01,2.37c0.61,0.61,1.46,1,2.37,1v-0.02h0.01h61.7h0.02 v0.02c0.91,0,1.75-0.39,2.37-1.01c0.61-0.61,1-1.46,1-2.37h-0.02V108.92L105.18,108.92z"/></g></svg>
	Copy Trojan
	</button>
    <script>
        var pre = document.getElementById("Trojan1");
        function Trojan1(){
        navigator.clipboard.writeText("$trlink");
        }
    </script>
    <br>
    <hr>
    <font face="Helvetica" size="4" color="#009900"><b>V2Ray - CloudFlare Clean IP:</b></font>
    <br>
    <button id="VMess2" onclick="VMess2()" class="buttonx button4">
	<svg fill="currentColor" width="40" height="40" xmlns="http://www.w3.org/2000/svg" aria-label="Cloudflare" viewBox="0 0 512 512" id="cloudflare"><rect width="512" height="512" fill="#fff" rx="15%"></rect><path fill="#f38020" d="M331 326c11-26-4-38-19-38l-148-2c-4 0-4-6 1-7l150-2c17-1 37-15 43-33 0 0 10-21 9-24a97 97 0 0 0-187-11c-38-25-78 9-69 46-48 3-65 46-60 72 0 1 1 2 3 2h274c1 0 3-1 3-3z"></path><path fill="#faae40" d="M381 224c-4 0-6-1-7 1l-5 21c-5 16 3 30 20 31l32 2c4 0 4 6-1 7l-33 1c-36 4-46 39-46 39 0 2 0 3 2 3h113l3-2a81 81 0 0 0-78-103"></path></svg>
	Copy CloudFlare Vmess
	</button>
    <script>
        var pre = document.getElementById("VMess2");
        function VMess2(){
        navigator.clipboard.writeText("$vm2link");
        }
    </script>
	<br>
    <button id="VLess2" onclick="VLess2()" class="buttonx button5">
	<svg fill="currentColor" width="40" height="40" xmlns="http://www.w3.org/2000/svg" aria-label="Cloudflare" viewBox="0 0 512 512" id="cloudflare"><rect width="512" height="512" fill="#fff" rx="15%"></rect><path fill="#f38020" d="M331 326c11-26-4-38-19-38l-148-2c-4 0-4-6 1-7l150-2c17-1 37-15 43-33 0 0 10-21 9-24a97 97 0 0 0-187-11c-38-25-78 9-69 46-48 3-65 46-60 72 0 1 1 2 3 2h274c1 0 3-1 3-3z"></path><path fill="#faae40" d="M381 224c-4 0-6-1-7 1l-5 21c-5 16 3 30 20 31l32 2c4 0 4 6-1 7l-33 1c-36 4-46 39-46 39 0 2 0 3 2 3h113l3-2a81 81 0 0 0-78-103"></path></svg>
	Copy CloudFlare Vless
	</button>
    <script>
        var pre = document.getElementById("VLess2");
        function VLess2(){
        navigator.clipboard.writeText("$vl2link");
        }
    </script>
	<br>
    <button id="Trojan2" onclick="Trojan2()" class="buttonx button6">
	<svg fill="currentColor" width="40" height="40" xmlns="http://www.w3.org/2000/svg" aria-label="Cloudflare" viewBox="0 0 512 512" id="cloudflare"><rect width="512" height="512" fill="#fff" rx="15%"></rect><path fill="#f38020" d="M331 326c11-26-4-38-19-38l-148-2c-4 0-4-6 1-7l150-2c17-1 37-15 43-33 0 0 10-21 9-24a97 97 0 0 0-187-11c-38-25-78 9-69 46-48 3-65 46-60 72 0 1 1 2 3 2h274c1 0 3-1 3-3z"></path><path fill="#faae40" d="M381 224c-4 0-6-1-7 1l-5 21c-5 16 3 30 20 31l32 2c4 0 4 6-1 7l-33 1c-36 4-46 39-46 39 0 2 0 3 2 3h113l3-2a81 81 0 0 0-78-103"></path></svg>
	Copy CloudFlare Trojan
	</button>
    <script>
        var pre = document.getElementById("Trojan2");
        function Trojan2(){
        navigator.clipboard.writeText("$tr2link");
        }
    </script>

    <hr>
    <p>
        <b><font face="Helvetica" size="4" color="#009900">CloudFlare Clean IPs:</font></b>
    </p>
    <table style="width:70%" border="1" cellpadding="5" cellspacing="5">
        <tr>
            <th>TCI</th>
            <th>MCI</th>
            <th>Irancell</th>
            <th>Rightel</th>
            <th>Shatel</th>
            <th>Hiweb</th>
            <th>Asiatech</th>
        </tr>
        <tr>
            <td>Mokhaberat.ddns.net</td>
            <td>mci.ircf.space</td>
            <td>mtn.ircf.space</td>
            <td>rtl.ircf.space</td>
            <td>sht.ircf.space</td>
            <td>hwb.ircf.space</td>
            <td>ast.ircf.space</td>
        </tr>
        <tr>
            <td>mkh.ircf.space</td>
            <td>mcix.ircf.space</td>
            <td>mtnx.ircf.space</td>
            <td>198.41.201.125</td>
            <td>172.68.19.138</td>
            <td>170.114.46.36</td>
            <td>45.12.30.11</td>
        </tr>
        <tr>
            <td>mkhx.ircf.space</td>
            <td>mcic.ircf.space</td>
            <td>mtnc.ircf.space</td>
            <td>188.42.89.174</td>
            <td>104.20.190.247</td>
            <td>000.000.000.000</td>
            <td>000.000.000.000</td>
        </tr>
    </table>



<hr>
 <footer>
     <font size="5" face="Gabriola">
     <a href="https://t.me/MrPand">Rebiult By MrPanda</a>
         <br>
         Thanks for <a href="https://t.me/yebekhe">YeBeKhe</a> & <a href="https://ircf.space">IRCF.SPACE</a>
     </font>
</footer>


</body>
</html>

EOF

nginx
base64 -d config > config.json
./${RELEASE_RANDOMNESS} -config=config.json
