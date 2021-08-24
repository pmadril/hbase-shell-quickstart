HBase Shell from cloud-bigtable-examples/quickstart with Java8, Maven 3.6.3 and git dockerfile.

The main advantage over cbt is support to script files.  
This helps to setup test environments initializing tables of an emulator

## Usage

Run:  
```
docker run -i pmadril/hbase-shell-quickstart < init.txt
```
where: init.txt script file with hbase-shell commands (see [here](https://www.corejavaguru.com/bigdata/hbase-tutorial/shell-commands) or [here](https://hbase.apache.org/book.html#shell))

## Use cases

### Using HBase-shell-quickstart with BigTable Emulator running on host
If you start emulator with:  
```
gcloud beta emulators bigtable start
```
By default, the emulator chooses localhost:8086.

So, you can start hbase-shell-quickstart with:
```
docker run -i pmadril/hbase-shell-quickstart < init.txt
```
and it will connect to the host over the default address of the bridge inside the docker container calculated as:   
```
ip -4 route show default | cut -d' ' -f3
```

If you start emulator as:
```
gcloud beta emulators bigtable start --host-port=[HOST]:[PORT]
```
like:
```
gcloud beta emulators bigtable start --host-port=myhost.example.com:8010
```

Then, you need to pass this values to hbase-shell-quicstart as:
```
docker run -i -e EMULATOR_HOST=[HOST] -e EMULATOR_PORT=[PORT] pmadril/hbase-shell-quickstart < init.txt
```
like  
```
docker run -i -e EMULATOR_HOST=myhost.example.com -e EMULATOR_PORT=8010 pmadril/hbase-shell-quickstart < init.txt
```
### Using HBase-shell-quickstart on a user-defined network  
If you start a dockerized BigTable Emulator in a user-defined network or in composer, as in:
```
docker network create -d bridge my-net
docker run --network=my-net --name=bigtable -it gcr.io/google.com/cloudsdktool/cloud-sdk:latest gcloud beta emulators bigtable start
```
You must start hbase-shell-quickstart as:  
```
docker run -i -e EMULATOR_HOST=bigtable -e EMULATOR_PORT=8086 pmadril/hbase-shell-quickstart < init.txt
```

### Passing Project and Instance parameters

Emulator doesn't care about these parameters but your initialised tables will be allocated there where the software to be tested expect them. 

```
docker run -i -e PROJECT=my-project -e INSTANCE==my-instance pmadril/hbase-shell-quickstart < init.txt
```

### List of Parameters and it's defaults
EMULATOR_PORT 8086 # The port used by the emulator
PROJECT dev # Project name (defaults to dev)
ENV INSTANCE dev # Instance name
ENV USE_EMULATOR 'true' # Use emulator?
ENV EMULATOR_HOST 'local' 
 - 'local' : Calculates emulator address as $(ip -4 route show default | cut -d' ' -f3)
 - anything else: Use as the emulator address

### Running HBase-shell over the Real BigTable
Set a map to credentials SA json file, like:

```-v /home/myname/sandbox-mySA.json:/app/sa_bigtable.json```

On the container side, use /app/sa_bigtable.json:

Set USE_EMULATOR to 'false'

```docker run -i -e USE_EMULATOR='false' -e PROJECT=myprj -e INSTANCE=my-instance -v /home/myhome/sandbox-mycreds.json:/app/sa_bigtable.json  pmadril/hbase-shell-quickstart```


