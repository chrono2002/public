import React, { Component } from 'react';
import axios from 'axios';
const queryString = require('query-string');
const parsed = queryString.parse(window.location.search);

class Census extends React.Component {
  state = {
    color: "",
    error: 0,
    message: "is in progress",
  }

  componentDidMount() {
    this.doCensus();
  }

  async doCensus() {
    var error = 0;
    var tag = "browser";
    var request_number = 1;
    var total_requests = 1;
    var vus = 1;

    if (parsed.tag) tag = parsed.tag;
    if (parsed.request_number) request_number = parsed.request_number;
    if (parsed.total_requests) total_requests = parsed.total_requests;
    if (parsed.vus) vus = parsed.vus;

    try {
	const message = await axios.get('/api/census', {
	    params: {
		tag: tag,
		request_number: request_number,
		total_requests: total_requests,
		vus: vus
	    }
	})

	if (message.data == "0") {
	    this.setState({
	        error: 0,
    		message: "is done",
		color: "green"
	    });
	} else {
	    error = 1;
	}
    } catch (e) {
	error = 1;
    }

    if (error == 1) {
        this.setState({
    	    error: 1,
    	    message: "can't be done",
	    color: "red"
	});
    }
  }

  render() {
    return (
      <h4>Vladimir Vsevolodovich census <span className={this.state.color}>{this.state.message}</span>!</h4>
    );
  }
}

export default Census;