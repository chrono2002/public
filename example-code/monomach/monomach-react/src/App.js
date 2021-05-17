import React, { Component } from 'react';
import { BrowserRouter as Router, Route, Link  } from 'react-router-dom'
import MetaTags from 'react-meta-tags';
import moment from 'moment';

import Census from './Census';
import Statistics from './Statistics';
import './App.css';
import logo from './monomach.jpg';

var ip = require('ip');

class App extends Component {
  render() {
    return (
      <Router>

      <div className="App">

	<MetaTags>
          <title>Vladimir Monomakh census</title>
	  <meta http-equiv="cache-control" content="max-age=0" />
	  <meta http-equiv="cache-control" content="no-cache" />
	  <meta http-equiv="expires" content="0" />
	  <meta http-equiv="expires" content="Tue, 01 Jan 1980 1:00:00 GMT" />
	  <meta http-equiv="pragma" content="no-cache" />
        </MetaTags>

        <header className="App-header">
	  <div className="fixed">
	    <Link to="/">Home</Link>&nbsp;|&nbsp; 
	    <Link to="/stat">Statistics</Link>
	  </div>
	  <img src={logo} className="App-logo" alt="logo" />
        </header>

	<Route exact path="/" component={Home} />
	<Route path="/stat" component={Statistics} />

      </div>

      </Router>
    );
  }
}

const Home = () => (
  <div>
    <h3>Behold, villein!</h3>
    <React.Fragment>
	<Census />
    </React.Fragment>
	<div className="left">
	<div>Thou dwelling is: {ip.address()}</div>
	<div>Epoch: {moment().format()}</div>
	<div>Thou horse is: {window.navigator.userAgent}</div>
    </div>
  </div>
);

export default App;
