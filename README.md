# Smarthome components: MQTT-related

* mqtt - utility to manually do sub/pub via command line or with streaming several json commands on stdin

## mqtt
The tool that can do almost all requests possible. ;)  
There are two modes available:
* Command line: classics for quick publish or get a single topic. Or more...
* stdin/pipe mode. It listens for JSON commands on the standard input. Great for long sessions with continuous processes.

For the list of options use --help

For stdin mode (-i | --stdin) the input is in JSON. Other parameters except -c and -d are ignored.
Check if answer's "rc" element (return code) is non-zero as an indication of error.  

_NOTE: All input JSON commands SHOULD be one-liner.
If you want to send the message with line breaks use "mpublish" command (see below)

#### Authentication:
Set username. Overrides what's in .ini:  

    { "user":"username", "password":"is optional" }

#### Special commands:  
    { "cmd":"command" }
*    exit - end session

#### Publishing data:
* simple publish:  

      { "publish":"message content", "topics":[ "topic1", ... ] }

    Optional parameters:
    * "retain":true to make topic retained
    * "qos":qos - optional qos type
* complex, multiline payload:

      { "mpublish":"stop tag" ...the rest of JSON is the same as for "publish" }

  Use for long or multiline messages: the "stop tag" string is a stop-word.
  Start your message right after the JSON closing "}".  
  The message stops when "stop tag" is encountered within the line.
  It is recommennded to use very random stuff like UUID to ensure that this mark will be unique.  
  Answers:
  * { "message":"published", "rc":0 } - OK
  * { "message":"some error", "rc":non-zero_return_code } - Not OK

#### Subscribe to topic(s):
    { "subscribe":[ "topic1", ... ] }    
  Answers:
  * { "message":"subscribed", "rc":0, "topic":"topic name" } - OK
  * { "message":"subscribe failed", "rc":return_code, "topic":"topic name" } - some error occurred
  
  When new message has arrived:

    { "subscription":"topic", "message":"message payload" }

#### Unsubscribe from topic(s):

    { "unsubscribe":[ "topic1", ... ] }

  Answers:
  * { "message":"unsubsribed", "rc":0 }
  * { "message":"unsubsribe failed", "rc":return_code }

#### Common answers (mostly problems):
* { "message":"invalid json", "rc":return_code }
* { "message":"unknown command", "rc":return_code }

# .ini file
Use `[DEFAULT]` section to set common variables that will be re-used as is from worker sections   
Aslo you may reference sections other than DEFAULT variables like this:  

        user = ${your.other section.name:user}
        pass = ${your.other section.name:pass}

### SSL configuration
Please consult openssl documentation for details on how it works.
You should use `auth = ssl` to activate SSL mode!  
`capath` - directory where SSL CA certificate bundle stored. Usually `/etc/pki/tls/certs`  
`cafile` - full path to CA certificate or bundle. Usually `/etc/pki/tls/certs/ca-bundle.crt`   
`crt` - file with our public certificate.     
`key` - file with our private key.  

### Authentication
`auth` - authentication mode: `user` or `ssl`  
`user` - username. Used with `auth = user`
`pass` - Password. Used with `auth = user`

`server` - domain or IP  
`keepalive` - (seconds) how often to send keepalives.    
`max_inactivity` - (seconds) Anti-zombie cheat: how many seconds of caller's process inactivity to allow before forced exit. Comment out if not needed

`clientid` - MQTT client ID.  
If value has `RANDOM_UUID` substring somewhere, it will be replaced with random generated UUID  
If `clientid` option is omitted then it will be generated randomly.

