import React, { useEffect, useRef } from 'react';
import * as d3 from 'd3';
import './TraceVisualization.css';

function TraceVisualization({ alert }) {
  const svgRef = useRef();
  const containerRef = useRef();

  useEffect(() => {
    if (!alert) {
      d3.select(svgRef.current).selectAll('*').remove();
      return;
    }

    const width = containerRef.current?.clientWidth || 600;
    const height = 400;
    const margin = { top: 20, right: 20, bottom: 40, left: 60 };

    d3.select(svgRef.current).selectAll('*').remove();

    const svg = d3.select(svgRef.current)
      .attr('width', width)
      .attr('height', height);

    const g = svg.append('g')
      .attr('transform', `translate(${margin.left},${margin.top})`);

    const chartWidth = width - margin.left - margin.right;
    const chartHeight = height - margin.top - margin.bottom;

    // Create mock trace data (in production, fetch from Corda)
    const traceData = [
      { hop: 0, bank: 'BankA', amount: alert.amount, timestamp: alert.timestamp },
      { hop: 1, bank: 'BankB', amount: alert.amount * 0.8, timestamp: alert.timestamp },
      { hop: 2, bank: 'BankC', amount: alert.amount * 0.6, timestamp: alert.timestamp }
    ];

    // X scale for hops
    const xScale = d3.scaleBand()
      .domain(traceData.map(d => d.hop))
      .range([0, chartWidth])
      .padding(0.2);

    // Y scale for amounts
    const yScale = d3.scaleLinear()
      .domain([0, d3.max(traceData, d => d.amount) * 1.1])
      .range([chartHeight, 0]);

    // Draw bars
    g.selectAll('.bar')
      .data(traceData)
      .enter()
      .append('rect')
      .attr('class', 'bar')
      .attr('x', d => xScale(d.hop))
      .attr('y', d => yScale(d.amount))
      .attr('width', xScale.bandwidth())
      .attr('height', d => chartHeight - yScale(d.amount))
      .attr('fill', (d, i) => d3.schemeCategory10[i % 10]);

    // Draw lines connecting bars
    const line = d3.line()
      .x(d => xScale(d.hop) + xScale.bandwidth() / 2)
      .y(d => yScale(d.amount))
      .curve(d3.curveMonotoneX);

    g.append('path')
      .datum(traceData)
      .attr('class', 'trace-line')
      .attr('d', line)
      .attr('fill', 'none')
      .attr('stroke', '#666')
      .attr('stroke-width', 2);

    // X axis
    g.append('g')
      .attr('transform', `translate(0,${chartHeight})`)
      .call(d3.axisBottom(xScale).tickFormat(d => `Hop ${d}`))
      .append('text')
      .attr('x', chartWidth / 2)
      .attr('y', 35)
      .attr('fill', '#333')
      .style('text-anchor', 'middle')
      .text('Trace Hops');

    // Y axis
    g.append('g')
      .call(d3.axisLeft(yScale).tickFormat(d => `$${(d / 1000).toFixed(0)}k`))
      .append('text')
      .attr('transform', 'rotate(-90)')
      .attr('y', -50)
      .attr('x', -chartHeight / 2)
      .attr('fill', '#333')
      .style('text-anchor', 'middle')
      .text('Amount');

    // Add labels
    g.selectAll('.bar-label')
      .data(traceData)
      .enter()
      .append('text')
      .attr('class', 'bar-label')
      .attr('x', d => xScale(d.hop) + xScale.bandwidth() / 2)
      .attr('y', d => yScale(d.amount) - 5)
      .attr('text-anchor', 'middle')
      .attr('fill', '#333')
      .attr('font-size', '12px')
      .text(d => d.bank);

  }, [alert]);

  if (!alert) {
    return (
      <div className="trace-visualization">
        <h2>Transaction Trace</h2>
        <div className="empty-state">
          <p>Select an alert to view transaction trace</p>
        </div>
      </div>
    );
  }

  return (
    <div className="trace-visualization">
      <h2>Transaction Trace: {alert.txId}</h2>
      <div className="alert-info">
        <div className="info-item">
          <span className="info-label">Amount:</span>
          <span className="info-value">
            ${new Intl.NumberFormat('en-US').format(alert.amount)}
          </span>
        </div>
        <div className="info-item">
          <span className="info-label">Risk Score:</span>
          <span className="info-value risk-high">
            {(alert.riskScore * 100).toFixed(1)}%
          </span>
        </div>
        <div className="info-item">
          <span className="info-label">Timestamp:</span>
          <span className="info-value">
            {new Date(alert.timestamp || alert.receivedAt).toLocaleString()}
          </span>
        </div>
      </div>
      <div ref={containerRef} className="chart-container">
        <svg ref={svgRef}></svg>
      </div>
    </div>
  );
}

export default TraceVisualization;

