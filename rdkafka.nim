#
#  librdkafka - Apache Kafka C library
# 
#  Copyright (c) 2012-2013 Magnus Edenhill
#  All rights reserved.
#  
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met: 
#  
#  1. Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer. 
#  2. Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution. 
#  
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
#  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
#  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
#  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
#  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
#  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
#  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#  POSSIBILITY OF SUCH DAMAGE.
# 
#*
#  Apache Kafka consumer & producer
# 
#  rdkafka.h contains the public API for librdkafka.
#  The API isdocumented in this file as comments prefixing the function, type,
#  enum, define, etc.
# 

#*
#  librdkafka version
# 
#  Interpreted as hex MM.mm.rr.xx:
#    MM = Major
#    mm = minor
#    rr = revision
#    xx = currently unused
# 
#  I.e.: 0x00080100 = 0.8.1
# 
{.deadCodeElim: on.}
{.passL: "-lz -lpthread -lrt" .}

when defined(windows): 
  const 
    librdkafka* = "librdkafka.dll"
elif defined(macosx): 
  const 
    librdkafka* = "librdkafka.dylib"
else: 
  const 
    librdkafka* = "librdkafka.so.1"

const
  RD_KAFKA_VERSION* = 0x00080600
  ## Supported debug contexts (CSV "debug" configuration property)
  RD_KAFKA_DEBUG_CONTEXTS* = "all,generic,broker,topic,metadata,producer,queue,msg,protocol"

  RD_KAFKA_PARTITION_UA* =  2_147_483_647  ##\
  ##Unassigned partition.
  ##The unassigned partition is used by the producer API for messages
  ##that should be partitioned using the configured or default partitioner.

type
  uint32_t = int32
  int32_t = int32
  int64_t = int64
  ssize_t = int64

  mode_t = object

  rd_kafka_resp_err_t* {.size: sizeof(cint).} = enum
    ## Internal errors to rdkafka: 
    RD_KAFKA_RESP_ERR_BEGIN = - 200, # begin internal error codes 
    RD_KAFKA_RESP_ERR_BAD_MSG = - 199, # Received message is incorrect 
    RD_KAFKA_RESP_ERR_BAD_COMPRESSION = - 198, # Bad/unknown compression 
    RD_KAFKA_RESP_ERR_DESTROY = - 197, # Broker is going away 
    RD_KAFKA_RESP_ERR_FAIL = - 196, # Generic failure 
    RD_KAFKA_RESP_ERR_TRANSPORT = - 195, # Broker transport error 
    RD_KAFKA_RESP_ERR_CRIT_SYS_RESOURCE = - 194, # Critical system resource
                                              #             failure 
    RD_KAFKA_RESP_ERR_RESOLVE = - 193, # Failed to resolve broker 
    RD_KAFKA_RESP_ERR_MSG_TIMED_OUT = - 192, # Produced message timed out
    RD_KAFKA_RESP_ERR_PARTITION_EOF = - 191, # Reached the end of the
                                          #         topic+partition queue on
                                          #         the broker.
                                          #         Not really an error. 
    RD_KAFKA_RESP_ERR_UNKNOWN_PARTITION = - 190, # Permanent:
                                              #             Partition does not
                                              #             exist in cluster. 
    RD_KAFKA_RESP_ERR_FS = - 189, # File or filesystem error 
    RD_KAFKA_RESP_ERR_UNKNOWN_TOPIC = - 188, # Permanent:
                                          #         Topic does not exist
                                          #         in cluster. 
    RD_KAFKA_RESP_ERR_ALL_BROKERS_DOWN = - 187, # All broker connections
                                             #            are down. 
    RD_KAFKA_RESP_ERR_INVALID_ARG = - 186, # Invalid argument, or
                                        #        invalid configuration 
    RD_KAFKA_RESP_ERR_TIMED_OUT = - 185, # Operation timed out 
    RD_KAFKA_RESP_ERR_QUEUE_FULL = - 184, # Queue is full 
    RD_KAFKA_RESP_ERR_ISR_INSUFF = - 183, # ISR count < required.acks 
    RD_KAFKA_RESP_ERR_NODE_UPDATE = - 182, # Broker node update 
    RD_KAFKA_RESP_ERR_END = - 100, # end internal error codes 
                                # Standard Kafka errors: 
    RD_KAFKA_RESP_ERR_UNKNOWN = - 1, RD_KAFKA_RESP_ERR_NO_ERROR = 0,
    RD_KAFKA_RESP_ERR_OFFSET_OUT_OF_RANGE = 1, RD_KAFKA_RESP_ERR_INVALID_MSG = 2,
    RD_KAFKA_RESP_ERR_UNKNOWN_TOPIC_OR_PART = 3,
    RD_KAFKA_RESP_ERR_INVALID_MSG_SIZE = 4,
    RD_KAFKA_RESP_ERR_LEADER_NOT_AVAILABLE = 5,
    RD_KAFKA_RESP_ERR_NOT_LEADER_FOR_PARTITION = 6,
    RD_KAFKA_RESP_ERR_REQUEST_TIMED_OUT = 7,
    RD_KAFKA_RESP_ERR_BROKER_NOT_AVAILABLE = 8,
    RD_KAFKA_RESP_ERR_REPLICA_NOT_AVAILABLE = 9,
    RD_KAFKA_RESP_ERR_MSG_SIZE_TOO_LARGE = 10,
    RD_KAFKA_RESP_ERR_STALE_CTRL_EPOCH = 11,
    RD_KAFKA_RESP_ERR_OFFSET_METADATA_TOO_LARGE = 12,
    RD_KAFKA_RESP_ERR_OFFSETS_LOAD_IN_PROGRESS = 14,
    RD_KAFKA_RESP_ERR_CONSUMER_COORDINATOR_NOT_AVAILABLE = 15,
    RD_KAFKA_RESP_ERR_NOT_COORDINATOR_FOR_CONSUMER = 16

type
  rd_kafka_metadata_broker_t* = object
    ##Metadata: Broker information
    id*: int32_t               ## Broker Id 
    host*: cstring             ## Broker hostname 
    port*: cint                ## Broker listening port 
  
  rd_kafka_metadata_partition_t* = object
    ##Metadata: Partition information
    id*: int32_t               ## Partition Id 
    err*: rd_kafka_resp_err_t  ## Partition error reported by broker 
    leader*: int32_t           ## Leader broker 
    replica_cnt*: cint         ## Number of brokers in 'replicas' 
    replicas*: ptr int32_t     ## Replica brokers 
    isr_cnt*: cint             ## Number of ISR brokers in 'isrs' 
    isrs*: ptr int32_t         ## In-Sync-Replica brokers 
  
  rd_kafka_metadata_topic_t* = object
    ##Metadata: Topic information
    topic*: cstring            ## Topic name 
    partition_cnt*: cint       ## Number of partitions in 'partitions' 
    partitions*: ptr rd_kafka_metadata_partition_t ## Partitions 
    err*: rd_kafka_resp_err_t  ## Topic error reported by broker 
  
  rd_kafka_metadata_t* = object
    ##Metadata container
    broker_cnt*: cint          ## Number of brokers in 'brokers' 
    brokers*: ptr rd_kafka_metadata_broker_t ## Brokers 
    topic_cnt*: cint           ## Number of topics in 'topics' 
    topics*: ptr rd_kafka_metadata_topic_t ## Topics 
    orig_broker_id*: int32_t   ## Broker originating this metadata 
    orig_broker_name*: cstring ## Name of originating broker 


type
  rd_kafka_type_t* {.size: sizeof(cint).} = enum
    ## Kafka handler type
    RD_KAFKA_PRODUCER, RD_KAFKA_CONSUMER

# Private types to provide ABI compatibility 
type    
  rd_kafka_t* = object 
  rd_kafka_topic_t* = object 
  rd_kafka_conf_t* = object 
  rd_kafka_topic_conf_t* = object 
  rd_kafka_queue_t* = object 


proc rd_kafka_version*(): cint {.cdecl, importc: "rd_kafka_version",
                              dynlib: librdkafka.} ##\
      ##Returns the librdkafka version as integer.


proc rd_kafka_version_str*(): cstring {.cdecl, importc: "rd_kafka_version_str",
                                     dynlib: librdkafka.} ## Returns the librdkafka version as string.


proc rd_kafka_err2str*(err: rd_kafka_resp_err_t): cstring {.cdecl,
    importc: "rd_kafka_err2str", dynlib: librdkafka.} ## \
    ## Returns a human readable representation of a kafka error.

proc rd_kafka_errno2err*(errnox: cint): rd_kafka_resp_err_t {.cdecl,
    importc: "rd_kafka_errno2err", dynlib: librdkafka.} ## \
    ##Converts `errno` to a `rd_kafka_resp_err_t` error code
    ##upon failure from the following functions:
    ##   - rd_kafka_topic_new()
    ##   - rd_kafka_consume_start()
    ##   - rd_kafka_consume_stop()
    ##   - rd_kafka_consume()
    ##   - rd_kafka_consume_batch()
    ##   - rd_kafka_consume_callback()
    ##   - rd_kafka_produce()
    ##  

#******************************************************************
# 								   *
#  Kafka messages                                                  *
# 								   *
# *****************************************************************

type
  rd_kafka_message_t* = object
    ##A Kafka message as returned by the `rd_kafka_consume*()` family
    ##of functions.
    ##This object has two purposes:
    ##   - provide the application with a consumed message. ('err' == 0)
    ##   - report per-topic+partition consumer errors ('err' != 0)
    ## 
    ##The application must check 'err' to decide what action to take.
    ## 
    ##When the application is finished with a message it must call
    ##`rd_kafka_message_destroy()`.
    ## 
    err*: rd_kafka_resp_err_t   ## Non-zero for error signaling. 
    rkt*: ptr rd_kafka_topic_t  ## Topic 
    partition*: int32           ## Partition 
    payload*: pointer           ## err==0: Message payload
                                ## err!=0: Error string
    len*: csize                 ## err==0: Message payload length
                                ## err!=0: Error string length 
    key*: pointer               ## err==0: Optional message key 
    key_len*: csize             ## err==0: Optional message key length 
    offset*: int64              ## Message offset (or offset for error
                                ## if err!=0 if applicable). 
    private*: pointer           ## rdkafka private pointer: DO NOT MODIFY 
  
proc rd_kafka_message_destroy*(rkmessage: ptr rd_kafka_message_t) {.cdecl,
    importc: "rd_kafka_message_destroy", dynlib: librdkafka.} ##\
    ## Frees resources for 'rkmessage' and hands ownership back to rdkafka.

proc rd_kafka_message_errstr*(rkmessage: ptr rd_kafka_message_t): cstring {.inline,
    cdecl.} =
  ##Returns the error string for an errored rd_kafka_message_t or NULL if
  ##there was no error.
  if rkmessage.err == rd_kafka_resp_err_t.RD_KAFKA_RESP_ERR_NO_ERROR:
    return nil
  if rkmessage.payload != nil: return cast[cstring](rkmessage.payload)
  return rd_kafka_err2str(rkmessage.err)

#******************************************************************
# 								   *
#  Main configuration property interface			   *
# 								   *
# *****************************************************************

type
  rd_kafka_conf_res_t* {.size: sizeof(cint).} = enum
    ##Configuration result type
    RD_KAFKA_CONF_UNKNOWN = - 2, ##Unknown configuration name. 
    RD_KAFKA_CONF_INVALID = - 1, ##Invalid configuration value. 
    RD_KAFKA_CONF_OK = 0

proc rd_kafka_conf_new*(): ptr rd_kafka_conf_t {.cdecl, importc: "rd_kafka_conf_new",
    dynlib: librdkafka.} ## \
    ##Create configuration object.
    ##When providing your own configuration to the `rd_kafka_*_new_*()` calls
    ##the rd_kafka_conf_t objects needs to be created with this function
    ##which will set up the defaults.
    ##I.e.
    ##
    ## .. code-block::
    ##    var myconf:rd_kafka_conf_t ;
    ##    var res:rd_kafka_conf_res_t ;
    ## 
    ##    myconf = rd_kafka_conf_new();
    ##    res = rd_kafka_conf_set(myconf, "socket.timeout.ms", "600",
    ##                            errstr, sizeof(errstr));
    ##    if (res != RD_KAFKA_CONF_OK)
    ##       echo(errstr);
    ##    
    ##    rk = rd_kafka_new(..., myconf);
    ## 
    ## 
    ##The properties are identical to the Apache Kafka configuration properties
    ##whenever possible.
 
proc rd_kafka_conf_destroy*(conf: ptr rd_kafka_conf_t) {.cdecl,
    importc: "rd_kafka_conf_destroy", dynlib: librdkafka.} ##\
    ##Destroys a conf object.

proc rd_kafka_conf_dup*(conf: ptr rd_kafka_conf_t): ptr rd_kafka_conf_t {.cdecl,
    importc: "rd_kafka_conf_dup", dynlib: librdkafka.} ##\
    ##Creates a copy/duplicate of configuration object 'conf'.


proc rd_kafka_conf_set*(conf: ptr rd_kafka_conf_t; name: cstring; value: cstring;
                       errstr: cstring; errstr_size: csize): rd_kafka_conf_res_t {.
    cdecl, importc: "rd_kafka_conf_set", dynlib: librdkafka.} ##\
    ##Sets a configuration property.
    ##'conf' must have been previously created with rd_kafka_conf_new().
    ##Returns rd_kafka_conf_res_t to indicate success or failure.
    ##In case of failure 'errstr' is updated to contain a human readable
    ##error string.
     
proc rd_kafka_conf_set_dr_cb*(conf: ptr rd_kafka_conf_t; dr_cb: proc (
    rk: ptr rd_kafka_t; payload: pointer; len: csize; err: rd_kafka_resp_err_t;
    opaque: pointer; msg_opaque: pointer) {.cdecl.}) {.cdecl,
    importc: "rd_kafka_conf_set_dr_cb", dynlib: librdkafka.} ##\
    ##Producer:
    ##Set delivery report callback in provided conf object.

proc rd_kafka_conf_set_dr_msg_cb*(conf: ptr rd_kafka_conf_t; dr_msg_cb: proc (
    rk: ptr rd_kafka_t; rkmessage: ptr rd_kafka_message_t; opaque: pointer) {.cdecl.}) {.
    cdecl, importc: "rd_kafka_conf_set_dr_msg_cb", dynlib: librdkafka.} ##\
    ##Producer:
    ##Set delivery report callback in provided conf object.

proc rd_kafka_conf_set_error_cb*(conf: ptr rd_kafka_conf_t; error_cb: proc (
    rk: ptr rd_kafka_t; err: cint; reason: cstring; opaque: pointer) {.cdecl.}) {.cdecl,
    importc: "rd_kafka_conf_set_error_cb", dynlib: librdkafka.} ##\
    ##Set error callback in provided conf object.
    ##The error callback is used by librdkafka to signal critical errors
    ##back to the application.

proc rd_kafka_conf_set_log_cb*(conf: ptr rd_kafka_conf_t; log_cb: proc (
    rk: ptr rd_kafka_t; level: cint; fac: cstring; buf: cstring) {.cdecl.}) {.cdecl,
    importc: "rd_kafka_conf_set_log_cb", dynlib: librdkafka.} ##\
    ##Set logger callback.
    ##The default is to print to stderr, but a syslog logger is also available,
    ##see rd_kafka_log_(print|syslog) for the builtin alternatives.
    ##Alternatively the application may provide its own logger callback.
    ##Or pass 'func' as NULL to disable logging.
    ##This is the configuration alternative to `rd_kafka_set_logger()`.



proc rd_kafka_conf_set_stats_cb*(conf: ptr rd_kafka_conf_t; stats_cb: proc (
    rk: ptr rd_kafka_t; json: cstring; json_len: csize; opaque: pointer): cint {.cdecl.}) {.
    cdecl, importc: "rd_kafka_conf_set_stats_cb", dynlib: librdkafka.} ##\
    ##Set statistics callback in provided conf object.
    ##The statistics callback is called from `rd_kafka_poll()` every
    ##`statistics.interval.ms` (needs to be configured separately).
    ##Function arguments:
    ##  'rk' - Kafka handle
    ##  'json' - String containing the statistics data in JSON format
    ##  'json_len' - Length of 'json' string.
    ##  'opaque' - Application-provided opaque.
    ## 
    ##If the application wishes to hold on to the 'json' pointer and free
    ##it at a later time it must return 1 from the `stats_cb`.
    ##If the application returns 0 from the `stats_cb` then librdkafka
    ##will immediately free the 'json' pointer.
 

proc rd_kafka_conf_set_socket_cb*(conf: ptr rd_kafka_conf_t; socket_cb: proc (
    domain: cint; `type`: cint; protocol: cint; opaque: pointer): cint {.cdecl.}) {.cdecl,
    importc: "rd_kafka_conf_set_socket_cb", dynlib: librdkafka.} ##\
    ##Set socket callback.
    ##The socket callback is responsible for opening a socket
    ##according to the supplied domain, type and protocol.
    ##The socket shall be created with CLOEXEC set in a racefree fashion, if
    ##possible.
    ##Default:
    ## on linux: racefree CLOEXEC
    ## others  : non-racefree CLOEXEC
    
proc rd_kafka_conf_set_open_cb*(conf: ptr rd_kafka_conf_t; open_cb: proc (
    pathname: cstring; flags: cint; mode: mode_t; opaque: pointer): cint {.cdecl.}) {.
    cdecl, importc: "rd_kafka_conf_set_open_cb", dynlib: librdkafka.} ##\
    ##Set open callback.
    ##The open callback is responsible for opening the file specified by
    ##pathname, flags and mode.
    ##The file shall be opened with CLOEXEC set in a racefree fashion, if
    ##possible.
    ## 
    ##Default:
    ## on linux: racefree CLOEXEC
    ## others  : non-racefree CLOEXEC
 
proc rd_kafka_conf_set_opaque*(conf: ptr rd_kafka_conf_t; opaque: pointer) {.cdecl,
    importc: "rd_kafka_conf_set_opaque", dynlib: librdkafka.} ##\
    ##Sets the application's opaque pointer that will be passed to `dr_cb`
    ##and `error_cb_` callbacks as the 'opaque' argument.

proc rd_kafka_opaque*(rk: ptr rd_kafka_t): pointer {.cdecl,
    importc: "rd_kafka_opaque", dynlib: librdkafka.} ##\
    ##Retrieves the opaque pointer previously set with rd_kafka_conf_set_opaque()

proc rd_kafka_conf_dump*(conf: ptr rd_kafka_conf_t; cntp: ptr csize): cstringArray {.
    cdecl, importc: "rd_kafka_conf_dump", dynlib: librdkafka.} ##\
    ##Dump the configuration properties and values of `conf` to an array
    ##with "key", "value" pairs. The number of entries in the array is
    ##returned in `*cntp`.
    ##The dump must be freed with `rd_kafka_conf_dump_free()`.

proc rd_kafka_topic_conf_dump*(conf: ptr rd_kafka_topic_conf_t; cntp: ptr csize): cstringArray {.
    cdecl, importc: "rd_kafka_topic_conf_dump", dynlib: librdkafka.} ##\
    ##Dump the topic configuration properties and values of `conf` to an array
    ##with "key", "value" pairs. The number of entries in the array is
    ##returned in `*cntp`.
    ##The dump must be freed with `rd_kafka_conf_dump_free()`. 

proc rd_kafka_conf_dump_free*(arr: cstringArray; cnt: csize) {.cdecl,
    importc: "rd_kafka_conf_dump_free", dynlib: librdkafka.} ##\
    ##Frees a configuration dump returned from `rd_kafka_conf_dump()` or
    ##`rd_kafka_topic_conf_dump()`.

proc rd_kafka_conf_properties_show*(fp: ptr FILE) {.cdecl,
    importc: "rd_kafka_conf_properties_show", dynlib: librdkafka.} ##\
    ##Prints a table to 'fp' of all supported configuration properties,
    ##their default values as well as a description.

#******************************************************************
# 								   *
#  Topic configuration property interface			   *
# 								   *
# *****************************************************************

proc rd_kafka_topic_conf_new*(): ptr rd_kafka_topic_conf_t {.cdecl,
    importc: "rd_kafka_topic_conf_new", dynlib: librdkafka.} ##\
    ##Create topic configuration object
    ##Same semantics as for rd_kafka_conf_new().

proc rd_kafka_topic_conf_dup*(conf: ptr rd_kafka_topic_conf_t): ptr rd_kafka_topic_conf_t {.
    cdecl, importc: "rd_kafka_topic_conf_dup", dynlib: librdkafka.} ##\
    ##Creates a copy/duplicate of topic configuration object 'conf'.

proc rd_kafka_topic_conf_destroy*(topic_conf: ptr rd_kafka_topic_conf_t) {.cdecl,
    importc: "rd_kafka_topic_conf_destroy", dynlib: librdkafka.} ##\
    ##Destroys a topic conf object.

proc rd_kafka_topic_conf_set*(conf: ptr rd_kafka_topic_conf_t;
                              name: cstring;
                              value: cstring;
                              errstr: cstring;
                              errstr_size: csize): rd_kafka_conf_res_t {.
    cdecl, importc: "rd_kafka_topic_conf_set", dynlib: librdkafka.} ##\
    ##  Sets a single rd_kafka_topic_conf_t value by property name.
    ##  'topic_conf' should have been previously set up
    ##   with `rd_kafka_topic_conf_new()`.
    ##  Returns rd_kafka_conf_res_t to indicate success or failure.
 

proc rd_kafka_topic_conf_set_opaque*(conf: ptr rd_kafka_topic_conf_t;
                                    opaque: pointer) {.cdecl,
    importc: "rd_kafka_topic_conf_set_opaque", dynlib: librdkafka.} ##\
    ##Sets the application's opaque pointer that will be passed to all topic
    ##callbacks as the 'rkt_opaque' argument.


proc rd_kafka_topic_conf_set_partitioner_cb*(
    topic_conf: ptr rd_kafka_topic_conf_t; partitioner: proc (
    rkt: ptr rd_kafka_topic_t; keydata: pointer; keylen: csize; partition_cnt: int32;
    rkt_opaque: pointer; msg_opaque: pointer): int32 {.cdecl.}) {.cdecl,
    importc: "rd_kafka_topic_conf_set_partitioner_cb", dynlib: librdkafka.} ##\
    ##Set partitioner callback in `provided` topic conf object
    ##The partitioner may be called in any thread at any time,
    ##it may be called multiple times for the same message/key.
    ##Partitioner function constraints:
    ##   - MUST NOT call any `rd_kafka_*()` functions except:
    ##       rd_kafka_topic_partition_available()
    ##   - MUST NOT block or execute for prolonged periods of time.
    ##   - MUST return a value between 0 and partition_cnt-1, or the
    ##     special RD_KAFKA_PARTITION_UA value if partitioning
    ##     could not be performed.
 
proc rd_kafka_topic_partition_available*(rkt: ptr rd_kafka_topic_t;
                                        partition: int32_t): cint {.cdecl,
    importc: "rd_kafka_topic_partition_available", dynlib: librdkafka.} ##\
    ##Check if partition is available (has a leader broker).
    ##Returns 1 if the partition is available, else 0.
    ##NOTE: This function must only be called from inside a partitioner function.
 
#******************************************************************
# 								   *
#  Partitioners provided by rdkafka                                *
# 								   *
# *****************************************************************

proc rd_kafka_msg_partitioner_random*(rkt: ptr rd_kafka_topic_t;
                                      key: pointer;
                                      keylen: csize;
                                      partition_cnt: int32_t;
                                      opaque: pointer;
                                      msg_opaque: pointer): int32_t {.
    cdecl, importc: "rd_kafka_msg_partitioner_random", dynlib: librdkafka.} ##\
    ##Random partitioner.
    ##This is the default partitioner.
    ##Returns a random partition between 0 and 'partition_cnt'-1.
 

## 

proc rd_kafka_msg_partitioner_consistent*(rkt: ptr rd_kafka_topic_t;
                                          key: pointer;
                                          keylen: csize;
                                          partition_cnt: int32_t;
                                          opaque: pointer;
                                          msg_opaque: pointer): int32_t {.
    cdecl, importc: "rd_kafka_msg_partitioner_consistent", dynlib: librdkafka.} ##\
    ##Consistent partitioner 
    ##Uses consistent hashing to map identical keys onto identical partitions.
    ##Returns a 'random' partition between 0 and partition_cnt - 1 based on the crc value of the key

#******************************************************************
# 								   *
#  Kafka object handle                                             *
# 								   *
# *****************************************************************

proc rd_kafka_new*(`type`: rd_kafka_type_t;
                   conf: ptr rd_kafka_conf_t;
                   errstr: cstring;
                   errstr_size: csize): ptr rd_kafka_t {.cdecl,
    importc: "rd_kafka_new", dynlib: librdkafka.} ##\
    ##Creates a new Kafka handle and starts its operation according to the
    ##specified 'type'.
    ##'conf' is an optional struct created with `rd_kafka_conf_new()` that will
    ##be used instead of the default configuration.
    ##The 'conf' object is freed by this function and must not be used or
    ##destroyed by the application sub-sequently.
    ##See `rd_kafka_conf_set()` et.al for more information.
    ##'errstr' must be a pointer to memory of at least size 'errstr_size' where
    ##`rd_kafka_new()` may write a human readable error message in case the
    ##creation of a new handle fails. In which case the function returns NULL.
    ##Returns the Kafka handle on success or NULL on error.
    ##To destroy the Kafka handle, use rd_kafka_destroy().
 

proc rd_kafka_destroy*(rk: ptr rd_kafka_t) {.cdecl, importc: "rd_kafka_destroy",
    dynlib: librdkafka.} ##Destroy Kafka handle.

proc rd_kafka_name*(rk: ptr rd_kafka_t): cstring {.cdecl, importc: "rd_kafka_name",
    dynlib: librdkafka.} ##Returns Kafka handle name.

proc rd_kafka_topic_new*(rk: ptr rd_kafka_t;
                         topic: cstring;
                         conf: ptr rd_kafka_topic_conf_t): ptr rd_kafka_topic_t {.
    cdecl, importc: "rd_kafka_topic_new", dynlib: librdkafka.} ##\
    ##Creates a new topic handle for topic named 'topic'.
    ##'conf' is an optional configuration for the topic created with
    ##`rd_kafka_topic_conf_new()` that will be used instead of the default
    ##topic configuration.
    ##The 'conf' object is freed by this function and must not be used or
    ##destroyed by the application sub-sequently.
    ##See `rd_kafka_topic_conf_set()` et.al for more information.
    ##Returns the new topic handle or NULL on error (see `errno`).
 

proc rd_kafka_topic_destroy*(rkt: ptr rd_kafka_topic_t) {.cdecl,
    importc: "rd_kafka_topic_destroy", dynlib: librdkafka.} ##\
    ##Destroy topic handle previously created with `rd_kafka_topic_new()`.

proc rd_kafka_topic_name*(rkt: ptr rd_kafka_topic_t): cstring {.cdecl,
    importc: "rd_kafka_topic_name", dynlib: librdkafka.} ##Returns the topic name.

proc rd_kafka_topic_opaque*(rkt: ptr rd_kafka_topic_t): pointer {.cdecl,
    importc: "rd_kafka_topic_opaque", dynlib: librdkafka.} ##\
    ##Get the rkt_opaque pointer that was set in the topic configuration.


#******************************************************************
# 								   *
#  Queue API                                                       *
# 								   *
# *****************************************************************

proc rd_kafka_queue_new*(rk: ptr rd_kafka_t): ptr rd_kafka_queue_t {.cdecl,
    importc: "rd_kafka_queue_new", dynlib: librdkafka.} ##\
    ##Create a new message queue.
    ##Message queues allows the application to re-route consumed messages
    ##from multiple topic+partitions into one single queue point.
    ##This queue point, containing messages from a number of topic+partitions,
    ##may then be served by a single rd_kafka_consume*_queue() call,
    ##rather than one per topic+partition combination.
    ##
    ##See rd_kafka_consume_start_queue(), rd_kafka_consume_queue(), et.al.

proc rd_kafka_queue_destroy*(rkqu: ptr rd_kafka_queue_t) {.cdecl,
    importc: "rd_kafka_queue_destroy", dynlib: librdkafka.} ##\
    ##Destroy a queue, purging all of its enqueued messages.

#******************************************************************
# 								   *
#  Consumer API                                                    *
# 								   *
# *****************************************************************

const
  RD_KAFKA_OFFSET_BEGINNING* = - 2
  RD_KAFKA_OFFSET_END* = - 1
  RD_KAFKA_OFFSET_STORED* = - 1000
  RD_KAFKA_OFFSET_TAIL_BASE* = - 2000 

template RD_KAFKA_OFFSET_TAIL*(CNT: expr): expr =
  ##Start consuming `CNT` messages from topic's current `.._END` offset.
  ##That is, if current end offset is 12345 and `CNT` is 200, it will start
  ##consuming from offset 12345-200 = 12145. 
  (RD_KAFKA_OFFSET_TAIL_BASE - (CNT))



proc rd_kafka_consume_start*(rkt: ptr rd_kafka_topic_t;
                             partition: int32_t;
                             offset: int64_t): cint {.cdecl,
    importc: "rd_kafka_consume_start", dynlib: librdkafka.} ##\
    ##Start consuming messages for topic 'rkt' and 'partition'
    ##at offset 'offset' which may either be a proper offset (0..N)
    ##or one of the the special offsets:
    ## `RD_KAFKA_OFFSET_BEGINNING`, `RD_KAFKA_OFFSET_END`,
    ## `RD_KAFKA_OFFSET_STORED`, `RD_KAFKA_OFFSET_TAIL(..)`
    ##rdkafka will attempt to keep 'queued.min.messages' (config property)
    ##messages in the local queue by repeatedly fetching batches of messages
    ##from the broker until the threshold is reached.
    ##The application shall use one of the `rd_kafka_consume*()` functions
    ##to consume messages from the local queue, each kafka message being
    ##represented as a `rd_kafka_message_t *` object.
    ##`rd_kafka_consume_start()` must not be called multiple times for the same
    ##topic and partition without stopping consumption first with
    ##`rd_kafka_consume_stop()`.
    ## eRurns 0 on success or -1 on error (see `errno`).
    
 


proc rd_kafka_consume_start_queue*(rkt: ptr rd_kafka_topic_t;
                                   partition: int32_t;
                                   offset: int64_t;
                                   rkqu: ptr rd_kafka_queue_t): cint {.
    cdecl, importc: "rd_kafka_consume_start_queue", dynlib: librdkafka.} ##\
    ##Same as rd_kafka_consume_start() but re-routes incoming messages to
    ##the provided queue 'rkqu' (which must have been previously allocated
    ##with `rd_kafka_queue_new()`.
    ##The application must use one of the `rd_kafka_consume_*_queue()` functions
    ##to receive fetched messages.
    ##`rd_kafka_consume_start_queue()` must not be called multiple times for the
    ##same topic and partition without stopping consumption first with
    ##`rd_kafka_consume_stop()`.
    ##`rd_kafka_consume_start()` and `rd_kafka_consume_start_queue()` must not
    ##be combined for the same topic and partition.



proc rd_kafka_consume_stop*(rkt: ptr rd_kafka_topic_t; partition: int32_t): cint {.
    cdecl, importc: "rd_kafka_consume_stop", dynlib: librdkafka.} ##\
    ##Stop consuming messages for topic 'rkt' and 'partition', purging
    ##all messages currently in the local queue.
    ##The application needs to be stop all consumers before calling
    ##`rd_kafka_destroy()` on the main object handle.
    ##Returns 0 on success or -1 on error (see `errno`).
 


proc rd_kafka_consume*(rkt: ptr rd_kafka_topic_t;
                       partition: int32_t;
                       timeout_ms: cint): ptr rd_kafka_message_t {.
    cdecl, importc: "rd_kafka_consume", dynlib: librdkafka.} ##\
    ##Consume a single message from topic 'rkt' and 'partition'.
    ##
    ##'timeout_ms' is maximum amount of time to wait for a message to be received.
    ##Consumer must have been previously started with `rd_kafka_consume_start()`.
    ##
    ##Returns a message object on success and NULL on error.
    ##The message object must be destroyed with `rd_kafka_message_destroy()`
    ##when the application is done with it.
    ##
    ##Errors (when returning NULL):
    ##  ETIMEDOUT - 'timeout_ms' was reached with no new messages fetched.
    ##  ENOENT    - 'rkt'+'partition' is unknown.
    ##               (no prior `rd_kafka_consume_start()` call)
    ##
    ##NOTE: The returned message's '..->err' must be checked for errors.
    ##NOTE: '..->err == RD_KAFKA_RESP_ERR__PARTITION_EOF' signals that the end
    ##      of the partition has been reached, which should typically not be
    ##      considered an error. The application should handle this case
    ##      (e.g., ignore).
 
proc rd_kafka_consume_callback*(rkt: ptr rd_kafka_topic_t;
                                partition: int32_t;
                                timeout_ms: cint; consume_cb: proc (
    rkmessage: ptr rd_kafka_message_t; opaque: pointer) {.cdecl.}; opaque: pointer): cint {.
    cdecl, importc: "rd_kafka_consume_callback", dynlib: librdkafka.} ##\
    ##Consumes messages from topic 'rkt' and 'partition', calling
    ##the provided callback for each consumed messsage.
    ##`rd_kafka_consume_callback()` provides higher throughput performance
    ##than both `rd_kafka_consume()` and `rd_kafka_consume_batch()`.
    ##'timeout_ms' is the maximum amount of time to wait for one or more messages
    ##to arrive.
    ##The provided 'consume_cb' function is called for each message,
    ##the application must NOT call `rd_kafka_message_destroy()` on the provided
    ##'rkmessage'.
    ##The 'opaque' argument is passed to the 'consume_cb' as 'opaque'.
    ##Returns the number of messages processed or -1 on error.
    ##See: rd_kafka_consume
 


 
proc rd_kafka_consume_batch*(rkt: ptr rd_kafka_topic_t; partition: int32_t;
                            timeout_ms: cint;
                            rkmessages: ptr ptr rd_kafka_message_t;
                            rkmessages_size: csize): ssize_t {.cdecl,
    importc: "rd_kafka_consume_batch", dynlib: librdkafka.}
    ##Consume up to 'rkmessages_size' from topic 'rkt' and 'partition',
    ##putting a pointer to each message in the application provided
    ##array 'rkmessages' (of size 'rkmessages_size' entries).
    ##`rd_kafka_consume_batch()` provides higher throughput performance
    ##than `rd_kafka_consume()`.
    ##'timeout_ms' is the maximum amount of time to wait for all of
    ##'rkmessages_size' messages to be put into 'rkmessages'.
    ##If no messages were available within the timeout period this function
    ##returns 0 and `rkmessages` remains untouched.
    ##This differs somewhat from `rd_kafka_consume()`.
    ##The message objects must be destroyed with `rd_kafka_message_destroy()`
    ##when the application is done with it.
    ##Returns the number of rkmessages added in 'rkmessages',
    ##or -1 on error (same error codes as for `rd_kafka_consume()`.
    ##See: rd_kafka_consume


#*
#  Queue consumers
# 
#  The following `..._queue()` functions are analogue to the functions above
#  but reads messages from the provided queue `rkqu` instead.
#  `rkqu` must have been previously created with `rd_kafka_queue_new()`
#  and the topic consumer must have been started with
#  `rd_kafka_consume_start_queue()` utilising the the same queue.
# 

proc rd_kafka_consume_queue*(rkqu: ptr rd_kafka_queue_t;
                             timeout_ms: cint): ptr rd_kafka_message_t {.
    cdecl, importc: "rd_kafka_consume_queue", dynlib: librdkafka.} ##See `rd_kafka_consume()` above.

proc rd_kafka_consume_batch_queue*(rkqu: ptr rd_kafka_queue_t; timeout_ms: cint;
                                  rkmessages: ptr ptr rd_kafka_message_t;
                                  rkmessages_size: csize): ssize_t {.cdecl,
    importc: "rd_kafka_consume_batch_queue", dynlib: librdkafka.} ##See `rd_kafka_consume_batch()` above.

proc rd_kafka_consume_callback_queue*(rkqu: ptr rd_kafka_queue_t; timeout_ms: cint;
    consume_cb: proc (rkmessage: ptr rd_kafka_message_t; opaque: pointer) {.cdecl.};
                                     opaque: pointer): cint {.cdecl,
    importc: "rd_kafka_consume_callback_queue", dynlib: librdkafka.} ##\
    ##See `rd_kafka_consume_callback()` above.

#*
#  Topic+partition offset store.


proc rd_kafka_offset_store*(rkt: ptr rd_kafka_topic_t;
                            partition: int32_t;
                            offset: int64_t): rd_kafka_resp_err_t {.cdecl,
    importc: "rd_kafka_offset_store", dynlib: librdkafka.} ##\
    ##If auto.commit.enable is true the offset is stored automatically prior to
    ##returning of the message(s) in each of the rd_kafka_consume*() functions
    ##above.
    ##Store offset 'offset' for topic 'rkt' partition 'partition'.
    ##The offset will be commited (written) to the offset store according
    ##to `auto.commit.interval.ms`.
    ##NOTE: `auto.commit.enable` must be set to "false" when using this API.
    ##Returns RD_KAFKA_RESP_ERR_NO_ERROR on success or an error code on error.
  
#******************************************************************
# 								   *
#  Producer API                                                    *
# 								   *
# *****************************************************************


const
  RD_KAFKA_MSG_F_FREE* = 0x00000001
  RD_KAFKA_MSG_F_COPY* = 0x00000002

proc rd_kafka_produce*(rkt: ptr rd_kafka_topic_t;
                       partitition: int32_t;
                       msgflags: cint;
                       payload: pointer;
                       len: csize;
                       key: pointer;
                       keylen: csize;
                       msg_opaque: pointer): cint {.cdecl,
    importc: "rd_kafka_produce", dynlib: librdkafka.} ##\
    ##Produce and send a single message to broker.
    ##
    ##'rkt' is the target topic which must have been previously created with
    ##`rd_kafka_topic_new()`.
    ##
    ##`rd_kafka_produce()` is an asynch non-blocking API.
    ##
    ##'partition' is the target partition, either:
    ##  - RD_KAFKA_PARTITION_UA (unassigned) for
    ##    automatic partitioning using the topic's partitioner function, or
    ##  - a fixed partition (0..N)
    ##
    ##'msgflags' is zero or more of the following flags OR:ed together:
    ##   RD_KAFKA_MSG_F_FREE - rdkafka will free(3) 'payload' when it is done
    ##			   with it.
    ##   RD_KAFKA_MSG_F_COPY - the 'payload' data will be copied and the 'payload'
    ##			   pointer will not be used by rdkafka after the
    ##			   call returns.
    ##
    ##   .._F_FREE and .._F_COPY are mutually exclusive.
    ##
    ##   If the function returns -1 and RD_KAFKA_MSG_F_FREE was specified, then
    ##   the memory associated with the payload is still the caller's
    ##   responsibility.
    ##
    ##'payload' is the message payload of size 'len' bytes.
    ##
    ##'key' is an optional message key of size 'keylen' bytes, if non-NULL it
    ##will be passed to the topic partitioner as well as be sent with the
    ##message to the broker and passed on to the consumer.
    ##
    ##'msg_opaque' is an optional application-provided per-message opaque
    ##pointer that will provided in the delivery report callback (`dr_cb`) for
    ##referencing this message.
    ##
    ##Returns 0 on success or -1 on error in which case errno is set accordingly:
    ##  ENOBUFS  - maximum number of outstanding messages has been reached:
    ##	       "queue.buffering.max.messages"
    ##	       (RD_KAFKA_RESP_ERR__QUEUE_FULL)
    ##  EMSGSIZE - message is larger than configured max size:
    ##	       "messages.max.bytes".
    ##	       (RD_KAFKA_RESP_ERR_MSG_SIZE_TOO_LARGE)
    ##  ESRCH    - requested 'partition' is unknown in the Kafka cluster.
    ##	       (RD_KAFKA_RESP_ERR__UNKNOWN_PARTITION)
    ##  ENOENT   - topic is unknown in the Kafka cluster.
    ##	       (RD_KAFKA_RESP_ERR__UNKNOWN_TOPIC)
    ##
    ##NOTE: Use `rd_kafka_errno2err()` to convert `errno` to rdkafka error code.
    ##  
 


proc rd_kafka_produce_batch*(rkt: ptr rd_kafka_topic_t;
                             partition: int32_t;
                             msgflags: cint;
                             rkmessages: ptr rd_kafka_message_t;
                             message_cnt: cint): cint {.cdecl,
    importc: "rd_kafka_produce_batch", dynlib: librdkafka.} ##\
    ##Produce multiple messages.
    ##
    ##If partition is RD_KAFKA_PARTITION_UA the configured partitioner will
    ##be run for each message (slower), otherwise the messages will be enqueued
    ##to the specified partition directly (faster).
    ##
    ##The messages are provided in the array `rkmessages` of count `message_cnt`
    ##elements.
    ##The `partition` and `msgflags` are used for all provided messages.
    ##
    ##Honoured `rkmessages[]` fields are:
    ##  payload,len	    - Message payload and length
    ##  key,key_len	    - Optional message key
    ##  _private	    - Message opaque pointer (msg_opaque)
    ##  err		    - Will be set according to success or failure.
    ##		      Application only needs to check for errors if
    ##		      return value != `message_cnt`.
    ##
    ##Returns the number of messages succesfully enqueued for producing.
 

#******************************************************************
# 								   *
#  Metadata API                                                    *
# 								   *
# *****************************************************************

  
proc rd_kafka_metadata*(rk: ptr rd_kafka_t;
                        all_topics: cint;
                        only_rkt: ptr rd_kafka_topic_t;
                        metadatap: ptr ptr rd_kafka_metadata_t;
                        timeout_ms: cint): rd_kafka_resp_err_t {.
    cdecl, importc: "rd_kafka_metadata", dynlib: librdkafka.} ##\
    ##Request Metadata from broker.
    ##
    ## all_topics - if non-zero: request info about all topics in cluster,
    ##		if zero: only request info about locally known topics.
    ## only_rkt   - only request info about this topic
    ## metadatap  - pointer to hold metadata result.
    ##		The `*metadatap` pointer must be released
    ##		with `rd_kafka_metadata_destroy()`.
    ## timeout_ms - maximum response time before failing.
    ##
    ##Returns RD_KAFKA_RESP_ERR_NO_ERROR on success (in which case `*metadatap`)
    ##will be set, else `RD_KAFKA_RESP_ERR__TIMED_OUT` on timeout or
    ##other error code on error.
 

proc rd_kafka_metadata_destroy*(metadata: ptr rd_kafka_metadata_t) {.cdecl,
    importc: "rd_kafka_metadata_destroy", dynlib: librdkafka.} ##Release metadata memory.

#******************************************************************
# 								   *
#  Misc API                                                        *
# 								   *
# *****************************************************************

proc rd_kafka_poll*(rk: ptr rd_kafka_t; timeout_ms: cint): cint {.cdecl,
    importc: "rd_kafka_poll", dynlib: librdkafka.} ##\
    ##Polls the provided kafka handle for events.
    ##
    ##Events will cause application provided callbacks to be called.
    ##
    ##The 'timeout_ms' argument specifies the minimum amount of time
    ##(in milliseconds) that the call will block waiting for events.
    ##For non-blocking calls, provide 0 as 'timeout_ms'.
    ##To wait indefinately for an event, provide -1.
    ##
    ##Events:
    ##  - delivery report callbacks	 (if dr_cb is configured) [producer]
    ##  - error callbacks (if error_cb is configured) [producer & consumer]
    ##  - stats callbacks (if stats_cb is configured) [producer & consumer]
    ##
    ##Returns the number of events served.
 

##	configuration property.

proc rd_kafka_brokers_add*(rk: ptr rd_kafka_t; brokerlist: cstring): cint {.cdecl,
    importc: "rd_kafka_brokers_add", dynlib: librdkafka.} ##\
    ##Adds a one or more brokers to the kafka handle's list of initial brokers.
    ##Additional brokers will be discovered automatically as soon as rdkafka
    ##connects to a broker by querying the broker metadata.
    ##
    ##If a broker name resolves to multiple addresses (and possibly
    ##address families) all will be used for connection attempts in
    ##round-robin fashion.
    ##
    ##'brokerlist' is a ,-separated list of brokers in the format:
    ##  <host1>[:<port1>],<host2>[:<port2>]...
    ##
    ##Returns the number of brokers successfully added.
    ##
    ##NOTE: Brokers may also be defined with the 'metadata.broker.list'
 

proc rd_kafka_set_logger*(rk: ptr rd_kafka_t; `func`: proc (rk: ptr rd_kafka_t;
    level: cint; fac: cstring; buf: cstring) {.cdecl.}) {.cdecl,
    importc: "rd_kafka_set_logger", dynlib: librdkafka.} ##\
    ##Set logger function.
    ##The default is to print to stderr, but a syslog logger is also available,
    ##see rd_kafka_log_(print|syslog) for the builtin alternatives.
    ##Alternatively the application may provide its own logger callback.
    ##Or pass 'func' as NULL to disable logging.
    ##
    ##NOTE: 'rk' may be passed as NULL in the callback.

proc rd_kafka_set_log_level*(rk: ptr rd_kafka_t; level: cint) {.cdecl,
    importc: "rd_kafka_set_log_level", dynlib: librdkafka.} ##\
    ##Specifies the maximum logging level produced by
    ##internal kafka logging and debugging.
    ##If the 'debug' configuration property is set the level is automatically
    ##adjusted to LOG_DEBUG (7).

proc rd_kafka_log_print*(rk: ptr rd_kafka_t; level: cint; fac: cstring; buf: cstring) {.
    cdecl, importc: "rd_kafka_log_print", dynlib: librdkafka.} ##\
    ##Builtin (default) log sink: print to stderr

proc rd_kafka_log_syslog*(rk: ptr rd_kafka_t; level: cint; fac: cstring; buf: cstring) {.
    cdecl, importc: "rd_kafka_log_syslog", dynlib: librdkafka.} ##\
    ##Builtin log sink: print to syslog.

proc rd_kafka_outq_len*(rk: ptr rd_kafka_t): cint {.cdecl,
    importc: "rd_kafka_outq_len", dynlib: librdkafka.} ##\
    ##Returns the current out queue length:
    ##messages waiting to be sent to, or acknowledged by, the broker.

proc rd_kafka_dump*(fp: ptr FILE; rk: ptr rd_kafka_t) {.cdecl, importc: "rd_kafka_dump",
    dynlib: librdkafka.}  ##\
    ##Dumps rdkafka's internal state for handle 'rk' to stream 'fp'
    ##This is only useful for debugging rdkafka, showing state and statistics
    ##for brokers, topics, partitions, etc.


proc rd_kafka_thread_cnt*(): cint {.cdecl, importc: "rd_kafka_thread_cnt",
                                 dynlib: librdkafka.} ##\
    ##Retrieve the current number of threads in use by librdkafka.
    ##Used by regression tests.

proc rd_kafka_wait_destroyed*(timeout_ms: cint): cint {.cdecl,
    importc: "rd_kafka_wait_destroyed", dynlib: librdkafka.} ##\
    ##Wait for all rd_kafka_t objects to be destroyed.
    ##Returns 0 if all kafka objects are now destroyed, or -1 if the
    ##timeout was reached.
    ##Since `rd_kafka_destroy()` is an asynch operation the 
    ##`rd_kafka_wait_destroyed()` function can be used for applications where
    ##a clean shutdown is required.
