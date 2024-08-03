PICKUP_DIR="/var/spool/hylafax/recvq"
PROCESS_DIR="/opt/FaxGPT/process"
DONE_DIR="/opt/FaxGPT/done"
TMP_DIR="/tmp/FaxGPT"
OPENAI_API_KEY=$(cat .openai_key)
PROMPT="You are an assistant that will respond to a users question, if the question does not make sense, make something up that is funny. Limit your responses to 250 words or less. Return the response to the question as a JSON object with the response in a field called response. The question from the user will contain a phone number, extract the phone number and return the phone number in the same JSON object but in a field called phone. The phone number might not be a standard format phone number, do your best to return what you think is correct. There might be mistakes in the question or random characters, do your best to ignore them while keeping the context of the question. Do not use markdown syntax in the response."

# cleanup while in dev
sudo rm -rf "/opt/FaxGPT"
# make the directories
sudo mkdir -p $PROCESS_DIR
sudo chown user:user $PROCESS_DIR
sudo mkdir -p $DONE_DIR
sudo chown user:user $DONE_DIR
sudo mkdir -p $TMP_DIR
sudo chown user:user $TMP_DIR
# check if the modem is in use
MODEM_STATUS=$(sudo faxstat | grep -i "idle" | wc -w)
#if it's not in use, process the files in the modem directory
if [ $MODEM_STATUS -ne 0 ]
then
echo "Modem not in use. Doing stuff."
STUFF_IN_PICKUP_DIR=($(ls $PICKUP_DIR | grep "tif" ))

for i in "${STUFF_IN_PICKUP_DIR[@]}"
do
   echo "$i"
   #change to mv when ready to go for real
   sudo mv "$PICKUP_DIR/$i" "$PROCESS_DIR/$i"
   #change the owner
   sudo chown user:user "$PROCESS_DIR/$i"
   #OCR the document
   convert "$PROCESS_DIR/$i" -resize 2100x2970\! "$TMP_DIR/temp_precrop.tif"
   convert "$TMP_DIR/temp_precrop.tif" -crop 2100x2670+0+150 "$TMP_DIR/temp.tif"
   tesseract "$TMP_DIR/temp.tif" "$TMP_DIR/output" -l eng
   QUESTION=$(cat "$TMP_DIR/output.txt" | xargs)
   OBJECT=$(cat <<EOF
{
   "model": "gpt-4o",
   "messages": [
      {
         "role": "system",
         "content": "$PROMPT"
      },
      {
         "role": "user",
         "content": "$QUESTION"
      }
   ]
}
EOF
)
   #echo $OBJECT
   RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions -H "Content-Type: application/json" -H "Authorization: Bearer $OPENAI_API_KEY" -d "$OBJECT")
   RESPONSE_TO_QUESTION=$(echo $RESPONSE | jq -r '.choices[0].message.content' | jq -r ".response")
   PHONE=$(echo $RESPONSE | jq -r '.choices[0].message.content' | jq -r ".phone")
   # Output the extracted values for verification
   echo "Original question: $QUESTION"
   echo "Response to question: $RESPONSE_TO_QUESTION"
   echo "Phone to reply to: $PHONE"
   cat > "$TMP_DIR/reply.txt" << EOF
Hello,
Thank you for using the most pointless project I have ever made.
====
Here is what I interepreted from your original fax.

$QUESTION

====
Here is the response from ChatGPT.

$RESPONSE_TO_QUESTION

====
EOF

   enscript "$TMP_DIR/reply.txt" -p "$TMP_DIR/reply.ps" --font=Courier12
   sendfax -n -d "$PHONE" "$TMP_DIR/reply.ps"
   mv "$PROCESS_DIR/$i" "$DONE_DIR/$i"
done
#else, do not do anything and wait for the modem to not be in use.
else
echo "Modem in use. Not doing anything."
fi