
/*
 *   Store client HTTP requests as Kafka messages
 */

package main

import (
    "context"
    "encoding/json"
    "fmt"
    "github.com/segmentio/kafka-go"
    "log"
    "net/http"
    "os"
    "strconv"
    "time"
)

var (
    kafkaWriter *kafka.Writer
)

/* HTTP census traffic handler */

func censusHandler(w http.ResponseWriter, r *http.Request) {

    /* Form a JSON message from HTTP request */

    request_number, _ := strconv.Atoi(r.URL.Query().Get("request_number"))
    total_requests, _ := strconv.Atoi(r.URL.Query().Get("total_requests"))
    vus, _ := strconv.Atoi(r.URL.Query().Get("vus"))

    m := Message{
	Tag:	r.URL.Query().Get("tag"),
	RequestNumber: request_number,
	TotalRequests: total_requests,
	VUS:	vus,
	Time: 	time.Now(),
	IP:	r.Header.Get("X-Forwarded-For"),
	Method:	r.Method,
	URL: 	r.URL.String(),
	UserAgent: r.UserAgent(),
    }

    mm, _ := json.Marshal(m)

    /* Send message to Kafka */

    err := kafkaWriter.WriteMessages(context.Background(),
	kafka.Message{Value: []byte(mm)},
    )
    if err != nil {
	errorsCnt++
	totalErrorsCnt++
	logger.Println(err)

	/* Print error state to browser */

	fmt.Fprintf(w, "1")

    } else {
	messagesCnt++
	totalMessagesCnt++

	/* Print okay state to browser */

	fmt.Fprintf(w, "0")

    }
}

/* HTTP statistics traffic handler */

func statHandler(w http.ResponseWriter, r *http.Request) {

    /* Query Clickhouse */

    var items []Statistics

    sess := connectDbr.NewSession(nil)

    var request = "select tag, vus, count(*) as requests, total_requests, formatDateTime(any(time), '%H:%m') AS time from monomach group by tag, total_requests, vus order by time desc limit 10"
    _, err := sess.SelectBySql(request).Load(&items)
    if err != nil {
        log.Fatal(err)
    } else {
	logger.Println("Clickhouse: statistics received")
    }

    mm, _ := json.Marshal(&items)

    /* Output statistics array */

    fmt.Fprintf(w, string(mm))
}

/* Kafka connector */

func kafkaConnect() {
    kafkaWriter = kafka.NewWriter(kafka.WriterConfig{
	Brokers: []string{kafkaServer},
	Topic:   kafkaTopic,
//	Async:	 true,
	ErrorLogger: logger,
	Logger: logger,
//	MaxAttempts: 1,
//	QueueCapacity: 1,
//	BatchSize: 1,
//	BatchTimeout: 1,
//	ReadTimeout: 1,
//	WriteTimeout: 1,
    })
}

/* SIGTERM trigger */ 

func onSigterm() {

    /* Close Kafka pipe */
    kafkaWriter.Close()
    
    os.Exit(1)
}

/*******************************************************/

func main() {

    /* Start logging */              
                                     
    startLogging("Daemon started on port " + port)

    /* Connect to Clickhouse */

    if !redisStatEnabled { clickhouseConnect() }

    /* Connect to Kafka */

    kafkaConnect()

    /* Print statistics every n sec */

    if statLogging { go statPolling(false) }

    /* Handle HTTP traffic */

    http.HandleFunc("/api/census", censusHandler)
    if !redisStatEnabled { http.HandleFunc("/api/stat", statHandler) }
    log.Fatal(http.ListenAndServe(":" + port, nil))

    /* Handle OS signals */

    signalHandler(onSigterm)

}
