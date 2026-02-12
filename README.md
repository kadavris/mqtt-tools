# Smarthome components: MQTT-related

* mqtt - utility to manually do sub/pub via command line or with streaming several json commands on stdin

## mqtt
The tool that can do almost all possible requests. ;)  
There are two modes available:
* Command line: classics for quick publish or get a single topic. Or more...
* stdin/pipe mode. It listens for JSON commands on the standard input. Great for long sessions with continuous processes.

For the list of options use --help

For stdin mode (-i | --stdin) the input should came in as JSON. Also most of other command line parameters, except -c and -d are ignored.  
Check if answer's "rc" element (return code) is non-zero as an indication of error.  

*NOTE: All JSON elements that set the parameters SHOULD be one-liner.*
If you want to send the message with line breaks use "mpublish" command (see below)

### Input requests examples

#### Authentication:
Set username. Overrides what's in .ini:  

    ```json
    { "user":"<username>", "password":"<can be optional>" }
    ```

#### Special commands:  
    `{ "cmd":"<command>" }`
*    exit - end session

#### Publishing data:
* simple and short message publish:  

```json
{ "publish":"<message content>", "topics":[ "topic1", ... ] }
```

Optional parameters:
    - "retain":true to make topic retained
    - "qos":qos - Quality of Service type

* complex, multiline payload:

```json
{ "mpublish":"<stop tag>", "topics":[ "<topic1>", ... ]  }
```

Use **mpublish** for long or multiline messages: the "stop tag" string is a stop-word.
Start your message right after the JSON closing "}".  
The message stops when "stop tag" is encountered within the line.
It is recommennded to use very random stuff like UUID to ensure that this mark will be unique.  
Answers:
* `{ "message":"published", "rc":0 }` - OK
* `{ "message":"some error", "rc":<non-zero return code> }` - Not OK

#### Subscribe to topic(s):
`{ "subscribe":[ "topic1", ... ] }`

Possible answers:
* `{ "message":"subscribed", "rc":0, "topic":"<topic name>" }` - OK
* `{ "message":"subscribe failed", "rc":<return code>, "topic":"<topic name>" }` - some error occurred
  
Later, when new message has arrived your progrma will get:
`{ "subscription":"<topic>", "message":"<message payload>" }`

#### Unsubscribe from topic(s):

`{ "unsubscribe":[ "<topic1>", ... ] }`

Answers:
* `{ "message":"unsubsribed", "rc":0 }` - OK
* `{ "message":"unsubsribe failed", "rc":<non-zero return code> }` - Not OK

#### Common answers:
* `{ "message":"invalid json", "rc":<return code> }`
* `{ "message":"unknown command", "rc":<return code> }`

And at the end of most messages there will be "mqtt-tool" object with the folowing members:
* answer_date_time: human-readable time YYYY-MM-DDTHH:MM:SS
* answer_timestamp: UNIX timestamp

# .ini file
Use `[DEFAULT]` section to set common variables that will be re-used as is from worker sections   
Also you may reference sections other than DEFAULT variables like this:
```ini
user = ${<other section name>:user}
pass = ${<other section name>:pass}
```

### SSL configuration
Please consult openssl documentation for details on how it all works.
You should use `auth = ssl` .ini keyword to activate SSL mode!

Other SSL-related parameters in .ini file:
- `capath` - directory where SSL CA certificate bundle stored. Usually `/etc/pki/tls/certs`
- `cafile` - full path to CA certificate or bundle. Usually `/etc/pki/tls/certs/ca-bundle.crt`
- `crt` - file with our public certificate.
- `key` - file with our private key.

### Basic authentication:
.ini parameters that you can use to establish user/password authenticated session:
- `auth` - authentication mode: `user` or `ssl`. You need to use `auth = user` for simple auth mode. 
- `user=<username>`
- `pass=<password>`

### Connection parameters:
- `server=<address>` - Can be domain or IP
- `keepalive=<seconds>` - how often to send keepalives.
- `max_inactivity=<seconds>` - Anti-zombie cheat: how many seconds of caller process inactivity to allow before we force exit on ourself. Comment out if not needed
- `clientid=<MQTT client ID>` - use to set a default ID here. Can be overriden from the command line.  
  * If value has `RANDOM_UUID` substring somewhere, it will be replaced with random generated UUID
  * If `clientid` option is omitted then it will be generated randomly.

