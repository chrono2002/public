import React, { Component } from 'react';
import ReactTable from "react-table";
import "react-table/react-table.css";
import axios from 'axios';

class Statistics extends Component {
  constructor(props) {
    super(props);
    
    this.state = {
      divClass: null,
      data: []
    };
  }

  componentDidMount() {
    this.getStat();
    this.timerID = setInterval(
      () => this.getStat(),
      15000
    );
  }

  componentWillUnmount() {
    clearInterval(this.timerID);
  }

  async getStat() {
    await axios
      .get('/api/stat')
      .then(({ data })=> {
        this.setState({ 
          data: data,
	  divClass: "ok"
        });
      })
      .catch((err)=> {
	this.setState({
	  divClass: "error"
	});
      })
  }

  render() {
    return (
      <div>
	<h3>Census Statistics</h3>
	<div className={'stat ' + this.state.divClass}>
            <ReactTable
                data={this.state.data}
                columns={[
                    {
                        Header: "TAG",
                        accessor: "tag"
                    },
                    {
                        Header: "Time",
                        accessor: "time"
                    },
                    {
                        Header: "VUS",
                        accessor: "vus"
                    },
                    {
                        Header: "Requests",
                        accessor: "requests"
                    },
                    {
                        Header: "Total Requests",
                        accessor: "total_requests"
                    }
                ]}
                defaultPageSize={10}
                className="-striped -highlight"
            />

	</div>
      </div>
    );
  }

}

export default Statistics;
