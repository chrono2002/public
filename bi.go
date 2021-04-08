package main

import (
	"encoding/json"
	"fmt"
	"sort"
	"strconv"
	"strings"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"github.com/valyala/fasthttp"
	"github.com/valyala/fasthttp/fasthttpadaptor"
)

var (
	body               []byte
	btc, symbols, usdt []*Ticker
	client             fasthttp.Client
	err                error
	promAdaptor        fasthttp.RequestHandler
)

type Book struct {
	LastUpdateID int64       `json:"lastUpdateId"`
	Bids         [][2]string `json:"bids"`
	Asks         [][2]string `json:"asks"`
}

type Ticker struct {
	Symbol   string  `json:"symbol"`
	Volume   float64 `json:"volume,string"`
	Count    int64   `json:"count"`
	BidPrice float64 `json:"bidPrice,string"`
	AskPrice float64 `json:"askPrice,string"`
}

func grepBySymbol(t []*Ticker, grep string) []*Ticker {
	var s []*Ticker

	for _, v := range t {
		if strings.Contains(v.Symbol, grep) {
			s = append(s, v)
		}
	}

	return s
}

func sortByCount(t []*Ticker) {
	sort.Slice(t, func(i, j int) bool {
		return t[i].Count > t[j].Count
	})
}

func sortByVolume(t []*Ticker) {
	sort.Slice(t, func(i, j int) bool {
		return t[i].Volume > t[j].Volume
	})
}

func calcBookTotal(book [][2]string) float64 {
	var qty, price float64
	var total float64 = 0

	for _, v := range book {
		if price, err = strconv.ParseFloat(v[0], 64); err != nil {
			panic(err)
		}
		if qty, err = strconv.ParseFloat(v[1], 64); err != nil {
			panic(err)
		}
		total = total + price*qty
	}

	return total
}

func printBookTotal(s []*Ticker) {
	var book Book

	print(fmt.Sprintf("%12s %12s %12s\n", "SYMBOL", "ASKS", "BIDS"))

	for i := 0; i < 5; i++ {
		if _, body, err = client.Get(nil, "https://api.binance.com/api/v3/depth?symbol="+s[i].Symbol); err != nil {
			panic(err)
		}

		if err = json.Unmarshal(body, &book); err != nil {
			panic(err)
		}

		print(fmt.Sprintf("%12s %12f %12f\n", s[i].Symbol, calcBookTotal(book.Asks), calcBookTotal(book.Bids)))
	}
}

func getTickerData() []*Ticker {
	var s []*Ticker

	if _, body, err = client.Get(nil, "https://api.binance.com/api/v3/ticker/24hr"); err != nil {
		panic(err)
	}
	if err = json.Unmarshal(body, &s); err != nil {
		panic(err)
	}

	return s
}

func printAbsoluteDelta() {
	var delta float64
	var lastSpread = make(map[string]float64)
	var metricsSpread = make(map[string]prometheus.Gauge)
	var metricsDelta = make(map[string]prometheus.Gauge)
	var symbol string

	for {
		symbols = getTickerData()
		usdt = grepBySymbol(symbols, "USDT")
		sortByCount(usdt)

		print(fmt.Sprintf("%12s %12s %12s\n", "SYMBOL", "SPREAD", "DELTA"))

		for i := 0; i < 5; i++ {
			symbol = usdt[i].Symbol

			/* Calculate delta and save last spread */
			if value, ok := lastSpread[symbol]; ok {
				delta = (usdt[i].AskPrice - usdt[i].BidPrice) - value
			} else {
				delta = 0
			}
			lastSpread[symbol] = usdt[i].AskPrice - usdt[i].BidPrice

			/* Init or update prometheus metrics */
			if _, ok := metricsSpread[symbol]; !ok {
				metricsSpread[symbol] = prometheus.NewGauge(prometheus.GaugeOpts{
					Name: "bi_usdt_" + symbol + "_spread",
				})
				prometheus.MustRegister(metricsSpread[symbol])
			}
			if _, ok := metricsDelta[symbol]; !ok {
				metricsDelta[symbol] = prometheus.NewGauge(prometheus.GaugeOpts{
					Name: "bi_usdt_" + symbol + "_delta",
				})
				prometheus.MustRegister(metricsDelta[symbol])
			}
			metricsSpread[symbol].Set(lastSpread[symbol])
			metricsDelta[symbol].Set(delta)

			print(fmt.Sprintf("%12s %12f %12f\n", symbol, lastSpread[symbol], delta))
		}
		time.Sleep(10 * time.Second)
	}
}

func handleRequestMetric(ctx *fasthttp.RequestCtx) {
	switch string(ctx.Path()) {
	case "/metric":
		promAdaptor(ctx)
	default:
		ctx.Error("", fasthttp.StatusNotFound)
	}
}

func main() {
	print("\n6. Starting metrics server ----------------------------------------------------\n")
	promAdaptor = fasthttpadaptor.NewFastHTTPHandler(promhttp.Handler())
	go fasthttp.ListenAndServe(":2112", handleRequestMetric)

	symbols = getTickerData()

	print("\n1. Top 5 BTC by volume --------------------------------------------------------\n")
	btc = grepBySymbol(symbols, "BTC")
	sortByVolume(btc)
	for i := 0; i < 5; i++ {
		print(fmt.Sprintf("%12s %f\n", btc[i].Symbol, btc[i].Volume))
	}

	print("\n2. Top 5 USDT by trades -------------------------------------------------------\n")
	usdt = grepBySymbol(symbols, "USDT")
	sortByCount(usdt)
	for i := 0; i < 5; i++ {
		print(fmt.Sprintf("%12s %d\n", usdt[i].Symbol, usdt[i].Count))
	}

	print("\n3. Total notional value of top 200 bids & asks from Q1 ------------------------ \n")
	printBookTotal(btc)

	print("\n4. Price spreads for Q2 -------------------------------------------------------\n")
	for i := 0; i < 5; i++ {
		print(fmt.Sprintf("%12s %12f\n", usdt[i].Symbol, usdt[i].AskPrice-usdt[i].BidPrice))
	}

	print("\n5. Print the result of Q4 and the absolute delta ------------------------------\n")
	printAbsoluteDelta()
}
