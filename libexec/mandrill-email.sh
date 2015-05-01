#!/bin/bash
# Initial script created by black @ LET
# Rewritten and improved by t0xicCode @ OpenConcept

show_help() {
  cat << EOF
Usage: ${0##*/} -k API_KEY -f FROM_EMAIL -s FROM_NAME -- RECIPIENT_EMAIL SUBJECT [MESSAGE]
Send an email using the mandrill API. With no MESSAGE or when MESSAGE is -,
read standard input.
EOF
}

OPTIND=1
while getopts ":k:f:s:h" opt; do
  case $opt in
    k)
      key="$OPTARG"
      ;;
    f)
      from_email="$OPTARG"
      reply_to="$from_email"
      ;;
    s)
      from_name="$OPTARG"
      ;;
    h)
      show_help
      exit
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      show_help >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      show_help >&2
      exit 1
      ;;
  esac
done
shift "$((OPTIND-1))";

if [ -z "$key" -o -z "$from_email" -o -z "$from_name" ]; then
  echo "Required parameter not present" >&2
  show_help >&2
  exit 1
fi

if [ $# -eq 2 -o $# -eq 3 ]; then
  recipient="$1"; shift
  subject="$1"; shift
  [ $# -eq 0 -o "$1" == '-' ] && message=$(cat -) || message="$1"
  
  msg='{ "async": false, "key": "'$key'", "message": { "from_email": "'$from_email'", "from_name": "'$from_name'", "headers": { "Reply-To": "'$reply_to'" }, "return_path_domain": null, "subject": "'$subject'", "text": "'$message'", "to": [ { "email": "'$recipient'", "type": "to" } ] } }'
  
  results=$(curl -A 'Mandrill-Curl/1.0' -d "$msg" 'https://mandrillapp.com/api/1.0/messages/send.json' -s 2>&1);
  echo "$results" | grep "sent" -q;
  if [ $? -ne 0 ]; then
    echo "An error occured: $results";
    exit 2;
  fi
else
  show_help >&2
  exit 1;
fi

# vim: sts=2:ts=2:sw=2:et:ai:si
