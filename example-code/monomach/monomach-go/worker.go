
/*
 *   Process Kafka messages into Clickhouse
 */

package main

import (
    "context"
    "encoding/json"
    "github.com/segmentio/kafka-go"
    "github.com/go-redis/redis"
    "log"
    "time"
)

var (
    kafkaReader *kafka.Reader
    redisClient *redis.Client
)

/* Kafka messages receiver & Clickhouse inserter */

func kafkaHandler() {

    /* Connect to Kafka */

    kafkaReader := kafka.NewReader(kafka.ReaderConfig{
        Brokers: []string{kafkaServer},
        Topic:   kafkaTopic,
	GroupID:   kafkaGroup,
        ErrorLogger: logger,
//        Logger: logger,
    })

    /* Read messages from Kafka */

    for {

	m, err := kafkaReader.ReadMessage(context.Background())

	if err != nil {

//    	    break
	    errorsCnt++
    	    totalErrorsCnt++
	    logger.Println(err)

	} else {

	    /* Unmarshal JSON into Message struct */

	    var message Message

	    err := json.Unmarshal(m.Value, &message)
	    if err != nil {
		logger.Println("error:", err)
	    }

	    /* Insert data into Clickhouse */

	    _, err = sess.InsertInto("monomach").Columns(
		    "tag", 
		    "request_number", 
		    "total_requests",
		    "vus",
		    "time",
		    "ip",
		    "method",
		    "url",
		    "useragent",
	    ).Record(&message).Exec()
	    if err != nil {
		queriesErrors++
    		totalQueriesErrors++
		log.Fatal(err)
	    } else {
		queriesCnt++
    		totalQueriesCnt++
	    }

	    /* Count success */

	    messagesCnt++
    	    totalMessagesCnt++
	}

//	logger.Printf("message at offset %d: %s = %s\n", m.Offset, string(m.Key), string(m.Value))

    }
}

/* Redis connector */

func redisConnect() {

    redisClient = redis.NewClient(&redis.Options{
        Addr:     redisAddress,
        Password: redisPassword,
        DB:       0,
    })

    _, err = redisClient.Ping().Result()
    if err != nil {
        log.Fatal(err)
    } else {
        logger.Println("Connected Redis at " + redisAddress)
    }

}

/* Redis statistics inserter */

func redisSet(ticker *time.Ticker) {
    for range ticker.C {

        /* Get statistics from Clickhouse */

	var items []Statistics

        var request = "select tag, vus, count(*) as requests, total_requests, formatDateTime(any(time), '%H:%m') AS time from monomach group by tag, total_requests, vus order by time desc limit 10"
	_, err := sess.SelectBySql(request).Load(&items)
	if err != nil {
    	    log.Fatal(err)
	} else {
	    logger.Println("Clickhouse: statistics received")
	}

	mm, _ := json.Marshal(&items)

	/* Put statistics JSON strings into Redis */

	err = redisClient.MSet("monomach_stat", string(mm)).Err()
	if err != nil {
    	    log.Fatal(err)
	} else {
	    logger.Println("Redis: statistics flushed")
	}
    }
}

/* SIGTERM trigger */

func onSigterm() {

    /* Close Kafka pipe */

    kafkaReader.Close()
}

/**********************************************************/

func main() {

    /* Start logging */

    startLogging("Daemon started")

    /* Log statistics every N sec */

    if statLogging { go statPolling(true) }

    /* Connect to Clickhouse */

    clickhouseConnect()

    /* Connect to Redis */

    redisConnect() 

    /* Push statistics into Redis every N sec */

    go redisSet(time.NewTicker(redisSetInterval * 1000 * time.Millisecond))

    /* Handle Kafka messages */

    kafkaHandler()

    /* Handle OS signals */

    signalHandler(onSigterm)
}
