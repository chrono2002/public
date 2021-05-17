import http from "k6/http";
import { check, group, sleep } from "k6";
import { Rate } from "k6/metrics";
var failureRate = new Rate("check_failure_rate");
// import Chance from "chancejs.com/chance.min.js";
// var chance = new Chance();

var iterations = 1000
var vus = 50
var testHost = "http://172.20.0.231"
// export const testTag = chance.last().toLowerCase()

export let options = {
    iterations: iterations,
    vus: vus,
};

export default function() {

    var offset = (iterations/vus)*__VU
    var count = offset-__ITER

    group("Dynamic", function() {

        check(http.get(testHost + "/api/census?tag=" + __ENV.RANDOM_NAME + "&request_number=" + count.toString() + "&total_requests=" + iterations.toString() + '&vus=' + vus.toString()), {
            "status is 200": (res) => res.status === 200,
            "status code ok": (res) => res.html().text() === "0",
        });

    });

    group("Static", function () {

        let resps = http.batch([
            ["GET", testHost + "/", { tags: { staticAsset: "yes" } }],
            ["GET", testHost + "/static/main.css", { tags: { staticAsset: "yes" } }],
            ["GET", testHost + "/static/1.js", { tags: { staticAsset: "yes" } }],
            ["GET", testHost + "/static/main.js", { tags: { staticAsset: "yes" } }],
            ["GET", testHost + "/static/monomach.jpg", { tags: { staticAsset: "yes" } }],
//            ["GET", testHost + "", { tags: { staticAsset: "yes" } }],
        ]);

        failureRate.add(!check(resps, {
            "status is 200": (r) => r[0].status === 200 && r[1].status === 200 && r[2].status === 200 && r[3].status === 200 && r[4].status === 200,
        }));

        offset--

    });

};
