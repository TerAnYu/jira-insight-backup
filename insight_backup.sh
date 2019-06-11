#!/bin/sh
# Writer: TerAnYu
# need: command-line JSON processor
# wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -O jq && chmod +x jq
# curl with libssl

url=http://127.0.0.1:8080
listreq=/rest/insight/1.0/objectschema/list
exportreq=/rest/insight/1.0/objectschema/export/server
username="localuser"
password="localpassword"
archpwd=123456
date=`date +"%Y%m%d_%H%M%S"`


data=`curl -s \
--connect-timeout 5 \
-u "${username}":"${password}" \
-H "Accept: application/json" \
-H "Content-Type: application/json" \
-X GET ${url}${listreq}`
    ids=`echo ${data} | ./jq -r '.objectschemas[].id'`
    cnt=0

for i in $ids; do
    name=`echo ${data} | ./jq -r ".objectschemas[${cnt}].name"`
    countobj=`echo ${data} | ./jq -r ".objectschemas[${cnt}].objectCount"`
# echo output: "${cnt}; ${date}; ${i}; ${name}; ${countobj}"
   cnt=$((cnt+1))


param(){
  cat <<EOF
{
"fileName":"${date}_${name}.zip",
"objectSchemaId":"${i}",
"includeObjects":"true",
"password":"${archpwd}",
"objectSchemaName":"${name}",
"totalObjectsInExport":"${countobj}"
}
EOF
}

status_code=$(
curl -s -u ${username}:${password} \
        -H "Content-Type: application/json" \
        --write-out %{http_code} \
        --silent \
        --connect-timeout 5 \
        -X POST \
        --output "/dev/null" \
        --data "$(param)" \
        "${url}${exportreq}"
)

if [ $status_code -ne 200 ] ; then
    echo "Site bad status (${date}_${name}.zip): $status_code"
else
    echo "Site good status (${date}_${name}.zip): $status_code"
fi

done
exit

