# WHAT IS THIS?

Yet another mqtt event log saver:

* Intended for use in local network
* Intended for use with small data
  * 500 messages/sec takes approx. 0.5% of CPU on a modern desktop
* Configurable by json,
* Hackable in python. If you need a new filter, just write it in python. No need to learn any new "configuration language"
* Reports its performance back to the broker, so you can monitor it remotely, or even use gyals to log it.  
* Supports multiple streams in separate threads: fully takes advantage of multicore systems
* Writes to a local file set in a clear way, so you can use your favorite tools to analyze the data
* Auto rotates the log files, so that they are easily slice able and transportable
* The log files are an sqlite database file, readable by all the popular tools incl. pandas

# How do I get set up?

1. read setup.sh and run it as needed. Do not just run it -- see what's inside and choose the steps that are right for you.
2. edit config.json to your needs
3. run `python3 go_yals.py`

also, run `python3 go_yals.py --help` for more options.

# Key concepts

### "Stream" 

For a lack of a better name, stream is a single thread that listens to specific topic and then saves the events to its configured database.

One stream can listen to a wildcard topic, e.g. `#` or `+/+/+/+`; in this case, the stream will save all the events that match the topic.

However, if you have a lot of messages per topic, you may want to use the MQTT's strongest side: the broker will do the load balancing for you.

Simply create a stream for each topic, and then you can use a multicore system or even multiple nodes to process the data.

### Log file rotation

Obviously, if you save generated data for a long time, you will have a lot of data. Having very large log files can be problematic.

Here, the problem is addressed by:
 
* Placing output of a stream in dedicated folder, as configured in the config file

* Naming each file by its creation time stamp in unix format

* Starting a new file every period, where period is also configured in the config file

* Preventing the folder clog-up by creating a new folder per day
 

### Timestamp

For this work, I select to use unix epoch time in microseconds,
that is, seconds * 1e6

This is enough of resolution that nearly every message will get a unique timestamp.

Note that the "reception_timestamp" is the local timestamp of the log saver,
and not the timestamp of the event that happened at the source.


### Performance

Throughout the execution, I save the local timestamp of events such as:

* Message received start

* Message saved, end

This enables me to compute the processing time and approximate the "idle time" of each thread, hence
providing the estimation of how much spare capacity there is in the system.

On my machine, at ~560 messages per second, the utilization ratio is <1%.

#### Future work

* port it to async with https://trio.readthedocs.io/en/stable/ and https://pypi.org/project/asyncio-mqtt/ or https://github.com/sabuhish/fastapi-mqtt  -- to be decided 
* Change the configuration from json to yaml. More humane, equally machinae.
* Rewrite the on-message closure generator completely, to make it nicer, and choke less on log file rotation.


# What does it do exactly?

I have made an effort to comment the code, as far as practicable; 
however, since it uses threads, the execution is a bit nonlinear.

The general idea is as follows:

1.Read the configuration from config.json

See config.json for an example, the names of fields in the config should be self-explanatory.

2.Set up a global state dict, "SharedState".

3.Create an "on message" closure function that captures the configuration settings, using a closure-generating-function (`cgf`) named `make_onmessage_callback()`

- The `cgf` sets up the storage folder, and then defines the closure.

- The resulting closure function is passed on to the mqtt client library.

3.Start the mqtt connection, and pass the closure function to the mqtt client library to execute "on message "

4.The closure function is called by the mqtt client library, in the mqtt client thread, when a message is received and it will:

* Check if the system is in shutdown mode.
    * If yes, it will attempt to flush the database, and when successful, exit the function early
* Check if the file rotation timer has expired
    * If yes, force flushing the messages and close the database.
    * Note that this means that the log file may not be rotated until next message is received. This may be an issue for a slow-dripping topics. (TODO: fix this)
* Check if the database link is open
    * If not, open it with a new creation timestamp, and store the link in the shared state dict.
* Add the message to the database, without flushing it. 
* SQLite decides when to flush the messages -- by default, sqlite flushes the messages to disk every 1000 messages, or every 1 second, whichever comes first.

5.That's it. So simple. Profit!

Generally, this is intended to be run as a system service, forever. However, I have made extra effort to support graceful shutdown so that the data can be collected for short periods of time, and aborted at any time. 


# How to read the log files

The files are sqlite databases, so you can use any sqlite tool to read them.

Detailed analysis tools are coming in separate projects.

### Example queries to query

#### What topics are there, and how many messages per topic?

The table is already indexed by topic at the write time, so selecting by topic is fast.

```SQL
select 
        topic, 
        count(*) 
    from data 
    group by topic 
    order by count(*) desc
```


#### give me the specific json value from the topic, as a history, in specified time interval only

```sql
select
    datetime(reception_timestamp*1e-6, "unixepoch") as timestamp,
    reception_timestamp*1e-6 as ux,
    json_extract(payload, '$.data.temperature') as temperature
from data
where
    topic = 'temperatures'
    and reception_timestamp > 1e6*unixepoch('2023-03-24 09:20:00.000')
    and reception_timestamp < 1e6*unixepoch('2023-03-24 09:20:01.000')
```
    

#### What is the time span of the data?

```SQL
select      
    ((max(reception_timestamp)-min(reception_timestamp))*1e-6)/60 as span_minutes 
    from data
```

```csv
span_minutes
9.9999545
```

For more examples, see the notebook folder, or go to this other repository: (link here when available)


### Who do I talk to? 

* Dr George Rey

### License ###

MIT License

Courtesy of STL Tech, 2023


### Acknowledgements ###

* The mqtt client library is paho-mqtt
* The sqlite library is sqlite3
* The json library is json


### Known problems 

* When the remote MQTT broker disconnects, the behaviour is undefined. This is not good. Figure out how to keep attempting to reconnect.

