# Introduction
So. I just completed probably the most amazingly pointless project. I honestly have zero practical use for this. If you can find a use for this, please let me know. Reach out to devagent42 (at) protonmail (dot) com and we can have a chat.

I just wrote a connector between a fax and ChatGPT, which I call FaxGPT. The fax I used is from 1996. 

FaxGPT enables you to send a fax to a number with a question, the server OCR's the document, sends it to ChatGPT, and then it sends you the reply via fax to the number specified in the original document. It takes about 2-3 minutes from start to finish. Took me 2-3 days of work to get this far, mostly spent fighting with the PBX, the ATA, and the USB fax modem.

I drew inspiration from this project where they made a fax C compiler (https://github.com/lexbailey/compilerfax). I thought it would be hilarious to replace the C compiler with ChatGPT.

# List of software
- Ubuntu 20.04
- tesseract-ocr-eng 
- imagemagick 
- lpr 
- enscript 
- hylafax-server 
- hylafax-client 
- jq

# List of hardware
- StarTech USB Modem USB56KEMH2
- Cisco SPA112 2-Port Phone Adapter
- Brother FAX 255 from 1996
- Grandstream UCM6202

# List of possible uses?
- Medical?
    - Automatic classification/routing of faxed documnets based on content?
    - Possible detection of fake prescriptions?
- Government?
    - https://www.dw.com/en/over-80-of-german-companies-still-use-fax-machines-survey/a-65514581
    - https://faxination.com/fax-remains-a-dominant-form-of-communication-in-these-countries/
- AI enabled fax?