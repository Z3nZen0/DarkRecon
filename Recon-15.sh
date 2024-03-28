#!/bin/bash

# The script starts by displaying a custom logo for the Reconnaissance Script.

echo "
                                                                                        
▀███▀▀▀██▄                 ▀███          ▀███▀▀▀██▄                                     
  ██    ▀██▄                 ██            ██   ▀██▄                                    
  ██     ▀██▄█▀██▄ ▀███▄███  ██  ▄██▀      ██   ▄██   ▄▄█▀██ ▄██▀██  ▄██▀██▄▀████████▄  
  ██      ███   ██   ██▀ ▀▀  ██ ▄█         ███████   ▄█▀   ███▀  ██ ██▀   ▀██ ██    ██  
  ██     ▄██▄█████   ██      ██▄██         ██  ██▄   ██▀▀▀▀▀▀█      ██     ██ ██    ██  
  ██    ▄██▀█   ██   ██      ██ ▀██▄       ██   ▀██▄ ██▄    ▄█▄    ▄██▄   ▄██ ██    ██  
▄████████▀ ▀████▀██▄████▄  ▄████▄ ██▄▄   ▄████▄ ▄███▄ ▀█████▀█████▀  ▀█████▀▄████  ████▄
                                                                                        
"

# This function extracts the domain name from a given URL.

function getDomainName() 
{
  url=$1
  # Remove the protocol if present (e.g., "https://www.example.com" -> "www.example.com")
  if [[ $url == *"http://"* ]]; then
    url="${url#http://}"
  elif [[ $url == *"https://"* ]]; then
    url="${url#https://}"
  fi

  # Extract the domain name from the URL
  IFS='.' read -ra parts <<< "$url"
  if (( ${#parts[@]} >= 2 )); then
    echo "${parts[-2]}.${parts[-1]}"
  fi
}

function option1() 
{
  read -p "Please enter the URL to test and the project name (e.g. example.com_ProjectName): " url_and_project_name
  url="${url_and_project_name%%_*}"
  domain=$(getDomainName $url)
  project_name="${url_and_project_name#*_}"
  folder_path="$(pwd)/$project_name"

  # Check if a folder with the same name already exists in the current directory
  if [ -d "$folder_path" ]; then
    counter=1
    while [ -d "$folder_path" ]; do
      folder_path="$folder_path-$counter"
      counter=$((counter+1))
    done
  fi

  # Perform domain reconnaissance
  performDomainRecon $domain

  # Create the folder for the output files using the provided project name
  mkdir -p "$folder_path/$domain"

  # Perform Web App Test
  echo "Performing Web App Test..."
  echo "Running subfinder to find subdomains..."
  subfinder -d "$domain" -nW -oI -t 20 -o "$folder_path/$domain/Subfinder_$domain.txt"
  echo "Running httpx to perform HTTP enumeration..."
  httpx -title -tech-detect -status-code -ip -asn -t 75 -rl 100 -o "$folder_path/$domain/HTTPX_$domain.txt"
  echo "Running nuclei to scan for vulnerabilities..."
  nuclei -u "$url" -fhr -rl 100 -as  -o "$folder_path/$domain/Nuclei_$domain.txt"
  echo "Running nmap to perform a port scan..."
  sudo nmap -sC -sV -sS -T3 --top-ports 1000 --open "$url" -o "$folder_path/$domain/NMAP_$domain.txt"
  echo "Running wafw00f to detect WAF presence..."
  wafw00f -a "$url" -o "$folder_path/$domain/wafw00f_$domain.txt"
  echo "Running paramspider to collect parameters..."
  cd ~/WebApp_Tools
  python3 paramspider.py --domain "$url" --exclude woff,css,js,png,svg,jpg --output "$folder_path/$domain/Param_$domain.txt"
  cd ~/go/bin
  cat "$folder_path/$domain/Param_$domain.txt" | ./gf redirect | tee -a "$folder_path/$domain/redirect.txt"
  cat "$folder_path/$domain/Param_$domain.txt" | ./gf xss | tee -a "$folder_path/$domain/xss.txt"
  cat "$folder_path/$domain/Param_$domain.txt" | ./gf idor | tee -a "$folder_path/$domain/idor.txt"
  cat "$folder_path/$domain/Param_$domain.txt" | ./gf ssrf | tee -a "$folder_path/$domain/ssrf.txt"
  cat "$folder_path/$domain/Param_$domain.txt" | ./gf wordpress | tee -a "$folder_path/$domain/WordPress.txt"
  echo "Running dalfox to test for XSS vulnerabilities..."
  cd ~/go/bin
  dalfox file "$folder_path/$domain/xss.txt" --report -o "$folder_path/$domain/Dalfox_$domain.txt"
  echo "Running autossrf to test for Server-Side Request Forgery (SSRF) vulnerabilities..."
  cd ~/WebApp_Tools/autossrf
  python3 autossrf.py --file "$folder_path/$domain/ssrf.txt" -v -o "$folder_path/$domain/AutoSSRF_$domain.txt"
  echo "Running openredirex to test for Open Redirect vulnerabilities..."
  cd ~/WebAppApps/autossrf_$domain.txt"
  echo "Running sqlmap to test for SQL injection vulnerabilities..."
  cd ~/go/bin
  sqlmap -r "$folder_path/$domain/Param_$domain.txt" --batch --level=5 --risk=3 --dbms=all --threads=4 --output-dir="$folder_path/$domain"
  echo "Running arjun to test for XSS vulnerabilities..."
  cd ~/go/bin
  arjun -u "$url" -o "$folder_path/$domain/Arjun_$domain.txt"
  echo "Running droopescan to test for OWASP Top Ten vulnerabilities..."
  cd ~/go/bin
  droopescan -u "$url" -o "$folder_path/$domain/Droopescan_$domain.txt"
  echo "Running jsql to test for SQL injection vulnerabilities..."
  cd ~/WebApp_Tools/jsql
  python3 jsql.py -u "$url" -o "$folder_path/$domain/JSQL_$domain.txt"
  echo "Running wfuzz to brute force directories..."
  cd ~/go/bin
  wfuzz -c -f "$folder_path/$domain/fuzz_$domain.txt" -w ~/WebApp_Tools/SecLists/Fuzzing/dirb/big.txt --hc=404 "$url" -o "$folder_path/$domain/Wfuzz_$domain.txt"
  echo "Running wfuzz to brute force files..."
  wfuzz -c -f "$folder_path/$domain/fuzz_$domain.txt" -w ~/WebApp_Tools/SecLists/Fuzzing/dirb/common.txt --hc=404 "$url/FUZZ" -o "$folder_path/$domain/Wfuzz_Files_$domain.txt"

  echo "Web App Test completed for $url in the '$project_name' project folder: $folder_path/$domain"
}
```bash

# This updated `option1` function now accepts the URL and project name as input, checks for duplicate folder names, and appends a unique identifier to the folder name if a duplicate is found. The output files will now be saved in the project folder under the specified domain name.


function option3() 
{
  read -p "Please enter the URL to test: " url
  url=$(echo $url | tr -d '\n\r')
  domain=$(getDomainName $url)
  folder_path="$(pwd)/$domain"

# This function represents Option 3 - Single Tool Option.
# It allows users to run individual tools separately.
# It collects the URL and domain from the user input.
# Creates a folder for the output files using the domain name.
  mkdir -p $folder_path

# Displays the available tools and prompts the user to select the tool(s) to run.
  echo "Available tools:"
  echo "1. Subfinder"
  echo "2. Httpx"
  echo "3. DNSx"
  echo "4. Nuclei"
  echo "5. Nmap"
  echo "6. Wafw00f"
  echo "7. ParamSpider"
  echo "8. Arjun"
  echo "9. Dalfox"
  echo "10. AutoSSRF"
  echo "11. OpenRedireX"

# Based on the user's selection, it runs the chosen tool(s) with appropriate arguments.
  read -p "Enter the tool number(s) to run (comma-separated): " tool_numbers
  IFS=',' read -ra tools <<< "$tool_numbers"

  for tool in "${tools[@]}"; do
    case $tool in
      1)
        cd ~/go/bin
        ./subfinder -d "$domain" -nW -oI -o "$folder_path/Subfinder_$domain.txt"
        ;;
      2)
        cd ~/go/bin
        ./httpx -u "$url" -title -tech-detect -status-code -asn -screenshot -t 75 -rl 100 -o "$folder_path/HTTPX_$domain.txt"
        ;;
      3)
        cd ~/go/bin
        ./dnsx -d "$url" -a -resp -rcode noerror,servfail,refused -o "$folder_path/DNSX_$domain.txt"
        ;;
      4)
        cd ~/go/bin
        ./nuclei -u "$url" -as -fhr -rl 100 -o "$folder_path/Nuclei_$domain.txt"
        ;;
      5)
        sudo nmap -sC -sV -sS -T3 --top-ports 1000 --open "$domain" -o "$folder_path/NMAP_$domain.txt"
        ;;
      6)
        wafw00f -a "$url" -o "$folder_path/wafw00f_$domain.txt"
        ;;
      7)
        cd ~/WebApp_Tools
        python3 paramspider.py --domain "$url" --exclude woff,css,js,png,svg,jpg --output "$folder_path/Param_$domain.txt"
        cd ~/go/bin
        cat "$folder_path/Param_$domain.txt" | ./gf redirect | tee -a "$folder_path/redirect.txt"
        cat "$folder_path/Param_$domain.txt" | ./gf xss | tee -a "$folder_path/xss.txt"
        cat "$folder_path/Param_$domain.txt" | ./gf idor | tee -a "$folder_path/idor.txt"
        cat "$folder_path/Param_$domain.txt" | ./gf ssrf | tee -a "$folder_path/ssrf.txt"
        cat "$folder_path/Param_$domain.txt" | ./gf wordpress | tee -a "$folder_path/WordPress.txt"
        ;;
      8)
        cd ~/WebApp_Tools
        arjun -u "$domain" -t 20 -d 2 -o "$folder_path/Arjun_$domain.txt"
        cd ~/go/bin
        cat "$folder_path/Arjun_$domain.txt" | ./gf redirect | tee -a "$folder_path/redirect_Arjun.txt"
        cat "$folder_path/Arjun_$domain.txt" | ./gf xss | tee -a "$folder_path/xss_Arjun.txt"
        cat "$folder_path/Arjun_$domain.txt" | ./gf idor | tee -a "$folder_path/idor_Arjun.txt"
        cat "$folder_path/Arjun_$domain.txt" | ./gf ssrf | tee -a "$folder_path/ssrf_Arjun.txt"
        cat "$folder_path/Arjun_$domain.txt" | ./gf wordpress | tee -a "$folder_path/WordPress_Arjun.txt"
        ;;
      9)
        cd ~/go/bin      
        read -p "Would you like to change the HTTP method? (Yes/No): " change_method
        change_method=$(echo $change_method | tr '[:upper:]' '[:lower:]')
        if [[ $change_method == "yes" ]]; then
          read -p "Enter the desired HTTP method (POST/PUT): " http_method
          http_method=$(echo $http_method | tr '[:upper:]' '[:lower:]')
          if [[ $http_method == "post" ]]; then
            ./dalfox url "$url" -f --deep-domxss -x POST --remote-payloads=payloadbox,portswigger --remote-wordlists=burp,assetnote --report -o "$folder_path/Dalfox_$domain.txt"
          elif [[ $http_method == "put" ]]; then
            ./dalfox url "$url" -f --deep-domxss -x PUT --remote-payloads=payloadbox,portswigger --remote-wordlists=burp,assetnote --report -o "$folder_path/Dalfox_$domain.txt"
          else
            ./dalfox url "$url" -f --deep-domxss --remote-payloads=payloadbox,portswigger --remote-wordlists=burp,assetnote --report -o "$folder_path/Dalfox_$domain.txt"
          fi
        else
          ./dalfox url "$url" -f --deep-domxss --remote-payloads=payloadbox,portswigger --remote-wordlists=burp,assetnote --report -o "$folder_path/Dalfox_$domain.txt"
        fi
        ;;
      10)
        cd ~/WebApp_Tools/autossrf
        python3 autossrf --url "$url" -o "$folder_path/AutoSSRF_$domain.txt"
        ;;
      11)
        cd /WebApp_Tools/OpenRedireX
        python3 openredirex.py -u "$url" -p payloads.txt --keyword FUZZ
        ;;
      12)
        cd ~/WebApp_Tools
        amass enum -brute -max-depth 5 -o "$folder_path/Amass_$domain.txt" -d $url
        ;;
      *)
        echo "Invalid tool number: $tool"
        ;;
    esac
  done

  echo "Reconnaissance completed for $url"
}

# The script starts by displaying the main menu of options to the user.
echo "Reconnaissance Script"

while true; do
  echo ""
  echo "1. Perform Domain Recon"
  echo "2. Use a Single Tool"
  echo "3. Update All Tools"
  echo "0. Exit"
  read -p "Select an option: " option

  case $option in
    1)
      option1
      ;;
    2)
      echo "Available tools:"
      echo "1. Subfinder"
      echo "2. Httpx"
      echo "3. DNSx"
      echo "4. Nuclei"
      echo "5. Wafw00f"
      echo "6. ParamSpider"
      echo "7. Arjun"
      echo "8. Dalfox"
      echo "9. AutoSSRF"
      echo "10. NMAP"
      echo "11. OpenRedireX"
      echo "12. AMASS"

      read -p "Enter the tool number: " tool_number
      case $tool_number in
        1)
          tool="subfinder"
          ;;
        2)
          tool="httpx"
          ;;
        3)
          tool="dnsx"
          ;;
        4)
          tool="nuclei"
          ;;
        5)
          tool="wafw00f"
          ;;
        6)
          tool="paramSpider"
          ;;
        7)
          tool="arjun"
          ;;
        8)
          tool="dalfox"
          ;;
        9)
          tool="autossrf"
          ;;
        10)
          tool="nmap"
          ;;
        11)
          tool="OpenRedirex"
          ;;
        12)
          tool="AMASS"
          ;;      
        *)
          echo "Invalid tool number: $tool_number"
          continue
          ;;
      esac

      read -p "Enter the URL to test: " url
      url=$(echo $url | tr -d '\n\r')


      output_file="${tool}_$(getDomainName $url).txt"
      command="$tool -o $output_file"
      eval $command

      echo "Output file created: $output_file"
      ;;
    3)
        cd ~/go/bin
        echo "Updating subfinder..."
        subfinder -up
        echo "Updating httpx..."
        httpx -up
        echo "Updating dnsx..."
        dnsx -up
        echo "Updating nuclei..."
        nuclei -up -ut
        echo "Updating nmap..."
        nmap --script-updatedb
        echo "Updating Dalfox..."
        go install github.com/hahwul/dalfox/v2@latest
      ;;
    0)
      echo "Goodbye!"
      exit
      ;;
    *)
      echo "Invalid option. Please try again."
      ;;
  esac
done
