import React, { useState, useEffect, useCallback } from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

// See react-d3-graph docs at https://danielcaldas.github.io/react-d3-graph/docs/index.html
import { Graph } from 'react-d3-graph'

const D3_GRAPH_CONFIG = {
  linkHighlightBehavior: true,
  width: 900,
  height: 600,
  node: {
    color: 'yellow',
    size: 120,
    highlightStrokeColor: 'blue',
  },
  link: {
    highlightColor: '#efefef',
  },
}

// custom prop types
const NodeShape = PropTypes.shape({
  id: PropTypes.string.isRequired,
})

const LinkShape = PropTypes.shape({
  source: PropTypes.string.isRequired,
  target: PropTypes.string.isRequired,
})

const SnapshotShape = PropTypes.shape({
  nodes: PropTypes.arrayOf(NodeShape).isRequired,
  links: PropTypes.arrayOf(LinkShape).isRequired,
})

// components
const Inspector = ({ source, target, topics }) => {
  // Function to format topics with comma and 'and' before last topic
  const formatTopics = useCallback((topics) => {
    if (topics.length === 1) {
      return topics[0];
    } else {
      const lastTopic = topics.pop();
      return `${topics.join(', ')} and ${lastTopic}`;
    }
  }, []);

  return (
  <p>
    {source && target ? (
      <span>
        <strong>{source}</strong> and <strong>{target}</strong> chatted about{' '}
        <em>{Array.isArray(topics) ? formatTopics(topics) : topics}</em>
      </span>
    ) : (
      <em>Hover your cursor over a connection line</em>
    )}
  </p>
  )
}

Inspector.propTypes = {
  source: PropTypes.string,
  target: PropTypes.string,
  topics: PropTypes.arrayOf(PropTypes.string),
}

const App = ({ snapshot: { nodes, links, topics } }) => {
  const [currentSource, setCurrentSource] = useState()
  const [currentTarget, setCurrentTarget] = useState()
  const [currentTopics, setCurrentTopics] = useState([])

  const handleClickNode = useCallback(() => {}, []);
  const handleMouseOverNode = useCallback(() => {}, []);
  const handleMouseOutNode = useCallback(() => {}, []);
  const handleClickLink = useCallback(() => {}, []);

  const handleMouseOverLink = useCallback((source, target) => {
    setCurrentSource(source);
    setCurrentTarget(target);
  }, []);

  const handleMouseOutLink = useCallback(() => {
    setCurrentSource(undefined);
    setCurrentTarget(undefined);
    setCurrentTopics(undefined);
  }, []);

  useEffect(() => {
    if (currentSource && currentTarget) {
      const key = [currentSource, currentTarget].sort().join('-');
      setCurrentTopics(topics[key] || []);
    }
  }, [currentSource, currentTarget, topics]);

  return (
    <div>
      <Inspector
        source={currentSource}
        target={currentTarget}
        topics={currentTopics}
      />
      <Graph
        id='graph'
        data={{ nodes, links }}
        config={D3_GRAPH_CONFIG}
        onClickNode={handleClickNode}
        onClickLink={handleClickLink}
        onMouseOverNode={handleMouseOverNode}
        onMouseOutNode={handleMouseOutNode}
        onMouseOverLink={handleMouseOverLink}
        onMouseOutLink={handleMouseOutLink}
      />
    </div>
  )
}

App.propTypes = {
  snapshot: SnapshotShape.isRequired,
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <App snapshot={SNAPSHOT_DATA} />,
    document
      .getElementById('layout-wrapper')
      .appendChild(document.createElement('div'))
  )
})
