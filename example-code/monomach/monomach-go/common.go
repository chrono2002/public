
/*
 *   Common library for both client & worker
 */

package main

import (
    _ "github.com/mailru/go-clickhouse"
    "github.com/mailru/dbr"
    "log"
    "os"
    "os/signal"
    "syscall"
    "time"
)

/* Configuration variables */

const (
    logfile = "client.log"
    port = "8080"

    clickhouseURL = "http://127.0.0.1:8123/default"

    kafkaServer = "localhost:9092"
    kafkaGroup = "monomach"
    kafkaTopic = "monomach"

    redisStatEnabled = true
    redisAddress = "localhost:6379"
    redisPassword = ""
    redisSetInterval = 15

    statLogging = true
    statInterval = 15
)

var (
    errorsCnt int = 0
    messagesCnt int = 0
    totalErrorsCnt int = 0
    totalMessagesCnt int = 0

    queriesCnt int = 0
    queriesErrors int = 0
    totalQueriesCnt int = 0
    totalQueriesErrors int = 0

    connectDbr *dbr.Connection
    err error
    sess *dbr.Session
    logger *log.Logger
)

type fn func()

/* Kafka message structure */        

type Message struct {                
    Tag string `json:"tag" db:"tag"`
    RequestNumber int `json:"request_number" db:"request_number"`
    TotalRequests int `json:"total_requests" db:"total_requests"`
    VUS int `json:"vus" db:"vus"`
    Time time.Time `json:"time" db:"time"`     
    IP string `json:"ip" db:"ip"`            
    Method string `json:"method" db:"method"`
    URL string `json:"url" db:"url"`
    UserAgent string `json:"useragent" db:"useragent"`
}

/* Clickhouse message structure */

type Statistics struct {
    Tag string `json:"tag"`
    VUS int `json:"vus"`
    Requests int `json:"requests"`
    TotalRequests int `json:"total_requests"`
    Time string `json:"time"`
}

/* Logging */

//func startLogging(logfile string, startString string) {
func startLogging(startString string) {
//    f, err := os.OpenFile(logfile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0600)
//    if err != nil {
//        log.Fatal(err)
//    }
//    println("LogFile: " + logfile)

    f := os.Stdout
    logger = log.New(f, "", log.LstdFlags|log.Lshortfile)
//    logger.Println("Daemon started on port " + port)
    logger.Println(startString)
}

/* Statistics */
    
func statPolling(db bool) {
  for {
    time.Sleep(statInterval * time.Second)
    logger.Println("----------- Statistics ------------")
    logger.Printf("\tTotal messages/errors = %v/%v\n", totalMessagesCnt, totalErrorsCnt)
    logger.Printf("\tMessages/errors per sec = %v/%v\n", messagesCnt/statInterval, errorsCnt/statInterval)
    if (db) {
	logger.Printf("\tTotal queries/errors = %v/%v\n", totalQueriesCnt, totalQueriesErrors)
	logger.Printf("\tQueries/errors per sec = %v/%v\n", queriesCnt/statInterval, queriesErrors/statInterval)
	queriesCnt = 0
	queriesErrors = 0
    }
    logger.Println("-----------------------------------")
    messagesCnt = 0
    errorsCnt = 0
  }
}

/* OS signals handler */

func signalHandler(onSigterm fn) {
    var stop = make(chan os.Signal)
    signal.Notify(stop, os.Interrupt, syscall.SIGINT, syscall.SIGTERM)
    go func() {
        <-stop
        logger.Println("Daemon stopped.")

        onSigterm()

        os.Exit(1)
    }()
}

/* Clickhouse connector */

func clickhouseConnect() {

    /* Connect to Clickhouse */

    connectDbr, err = dbr.Open("clickhouse", clickhouseURL, nil)
    if err != nil {
        log.Fatal(err)
    } else {
        logger.Println("Connected to Clickhouse at " + clickhouseURL)
    }

    sess = connectDbr.NewSession(nil)

    /* (tmp) Clickhouse: table cleanup */

//    _, err = sess.Exec(`
//	DROP TABLE IF EXISTS monomach
//    `)
//    if err != nil {
//	log.Fatal(err)
//    } else {
//	logger.Println("Clickhouse: table dropped")
//    }

    /* Clickhouse: create statistics table */

    _, err = sess.Exec(`
	CREATE TABLE IF NOT EXISTS monomach (
	    tag String,
	    request_number Int,
	    total_requests Int,
	    vus	Int,
	    time DateTime,
	    ip String,
	    method String,
	    url String,
	    useragent String
	)
	ENGINE = MergeTree() ORDER BY (tag, request_number) SETTINGS index_granularity = 8192
    `)
    if err != nil {
	logger.Println("Clickhouse: failed creating table")
	log.Fatal(err)
    }

}
